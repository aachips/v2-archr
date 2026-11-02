#!/usr/bin/env node
"use strict";

/**
 * Render a local HTML template with Docupilot-style {{tokens}} whose values
 * are fetched from Airtable using the Docupilot Params export.
 *
 * Node 18+. No npm packages required. Chrome or Edge is required for PDF.
 */

const fs = require("node:fs");
const path = require("node:path");
const { execFileSync } = require("node:child_process");
const {
  parseCsv,
  cleanTokenName,
  normalizeValue,
  parseFieldUrl,
  extractHtmlTokens,
  renderHtmlTemplate,
  safeFilename
} = require("./local-docupilot-generator.js");

const DEFAULT_PARAMS_PATH = path.join(__dirname, "All_Fields.csv");
const DEFAULT_PAT_PATH = path.join(__dirname, "PAT.txt");

function parseArgs(argv) {
  const result = {};
  for (let index = 0; index < argv.length; index += 1) {
    const argument = argv[index];
    if (!argument.startsWith("--")) continue;
    const [rawKey, inlineValue] = argument.slice(2).split(/=(.*)/s, 2);
    const key = rawKey.replace(/-([a-z])/g, (_, letter) => letter.toUpperCase());
    if (inlineValue !== undefined) result[key] = inlineValue;
    else if (argv[index + 1] && !argv[index + 1].startsWith("--")) result[key] = argv[++index];
    else result[key] = true;
  }
  return result;
}

function usage() {
  console.log(`Usage:
  node document-generation/local-airtable-template-generator.js \\
    --template <template.html> \\
    --record-id <rec...> [options]

Required:
  --template <path>         Local HTML template containing {{tokens}}
  --record-id <record-id>   Default Airtable source record

Options:
  --params <path>           Docupilot Params CSV; defaults to All_Fields.csv
  --config <path>           Optional Docupilot-style JSON config with tokens[]
  --record-map <json|path>  Record IDs by app ID or app:table ID
  --output <path>           Output filename or directory
  --format <both|pdf|html>  Defaults to both
  --strict                  Reject blank or unresolved tokens
  --dry-run                 Fetch and report values without rendering
  --help                    Show this help

Environment:
  AIRTABLE_PAT              Airtable personal access token
  AIRTABLE_TOKEN            Alternate token variable

Record map example:
  {"appSubmissionBase":"recSubmission","appEligibilityBase":"recReport"}`);
}

function readJsonFile(filePath, label) {
  let parsed;
  try {
    parsed = JSON.parse(fs.readFileSync(path.resolve(filePath), "utf8").replace(/^\uFEFF/, ""));
  } catch (error) {
    throw new Error(`Could not read ${label} ${filePath}: ${error.message}`);
  }
  if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) {
    throw new Error(`${label} must contain a JSON object.`);
  }
  return parsed;
}

function parseRecordMap(value) {
  if (!value) return {};
  const text = String(value).trim();
  const parsed = text.startsWith("{") ? JSON.parse(text) : readJsonFile(text, "record map");
  return Object.fromEntries(
    Object.entries(parsed).map(([key, recordId]) => [key, String(recordId || "").trim()])
  );
}

function resolvePat() {
  const environmentValue = String(process.env.AIRTABLE_PAT || process.env.AIRTABLE_TOKEN || "").trim();
  if (environmentValue) return environmentValue;
  if (fs.existsSync(DEFAULT_PAT_PATH)) return fs.readFileSync(DEFAULT_PAT_PATH, "utf8").trim();
  return "";
}

function configTokens(config) {
  if (!config) return [];
  if (!Array.isArray(config.tokens)) throw new Error("Config must contain a tokens array.");
  return config.tokens;
}

function definitionsFromCsv(csvPath) {
  const rows = parseCsv(fs.readFileSync(path.resolve(csvPath), "utf8"));
  const definitions = new Map();
  for (const row of rows) {
    const tokenName = cleanTokenName(row.Name);
    if (!tokenName) continue;
    if (definitions.has(tokenName)) throw new Error(`Duplicate token in Params CSV: ${tokenName}`);
    definitions.set(tokenName, {
      tokenName,
      valueFieldUrl: row.fieldURL || row.valueFieldUrl || "",
      valueType: row.valueType || "string"
    });
  }
  return definitions;
}

function buildTokenDefinitions(templateHtml, paramsByName, config = null) {
  const configured = new Map(
    configTokens(config).map(token => [cleanTokenName(token.tokenName), token])
  );
  return extractHtmlTokens(templateHtml).map(tokenName => {
    const csv = paramsByName.get(tokenName) || {};
    const token = configured.get(tokenName) || {};
    return {
      ...csv,
      ...token,
      tokenName,
      valueFieldUrl: token.valueFieldUrl || token.fieldURL || csv.valueFieldUrl || "",
      valueType: token.valueType || csv.valueType || "string"
    };
  });
}

function recordIdForToken(token, source, defaultRecordId, recordMap) {
  return String(
    token.recordId ||
    recordMap[`${source.baseId}:${source.tableId}`] ||
    recordMap[source.baseId] ||
    defaultRecordId ||
    ""
  ).trim();
}

function groupTokenRequests(tokens, defaultRecordId, recordMap) {
  const groups = new Map();
  const unresolved = [];

  for (const token of tokens) {
    const source = parseFieldUrl(token.valueFieldUrl);
    if (!source) {
      unresolved.push({ token, reason: "No valid Airtable field URL is configured." });
      continue;
    }
    const recordId = recordIdForToken(token, source, defaultRecordId, recordMap);
    if (!/^rec[A-Za-z0-9]+$/.test(recordId)) {
      unresolved.push({ token, source, reason: `No valid source record is configured for ${source.baseId}/${source.tableId}.` });
      continue;
    }
    const groupKey = `${source.baseId}:${source.tableId}:${recordId}`;
    if (!groups.has(groupKey)) {
      groups.set(groupKey, { ...source, recordId, fieldIds: new Set(), tokens: [] });
    }
    const group = groups.get(groupKey);
    group.fieldIds.add(source.fieldId);
    group.tokens.push(token);
  }

  return { groups: [...groups.values()], unresolved };
}

async function fetchAirtableRecord(pat, request) {
  const query = new URLSearchParams({ returnFieldsByFieldId: "true" });
  for (const fieldId of request.fieldIds) query.append("fields[]", fieldId);
  const url = `https://api.airtable.com/v0/${request.baseId}/${request.tableId}/${request.recordId}?${query}`;
  console.log(`Reading ${request.baseId}/${request.tableId}/${request.recordId} (${request.fieldIds.size} fields)`);
  const response = await fetch(url, {
    headers: { Authorization: `Bearer ${pat}`, Accept: "application/json" }
  });
  const text = await response.text();
  let body;
  try { body = text ? JSON.parse(text) : {}; }
  catch { body = { raw: text }; }
  if (!response.ok) {
    throw new Error(
      `Airtable ${response.status} while reading ${request.baseId}/${request.tableId}/${request.recordId}: ` +
      JSON.stringify(body).slice(0, 1000)
    );
  }
  return body;
}

async function resolveTokenValues(tokens, pat, defaultRecordId, recordMap) {
  const { groups, unresolved } = groupTokenRequests(tokens, defaultRecordId, recordMap);
  const values = {};
  const report = unresolved.map(item => ({
    token: item.token.tokenName,
    status: "unresolved",
    reason: item.reason
  }));

  for (const item of unresolved) values[item.token.tokenName] = "";

  for (const group of groups) {
    const record = await fetchAirtableRecord(pat, group);
    for (const token of group.tokens) {
      const source = parseFieldUrl(token.valueFieldUrl);
      const rawValue = record.fields?.[source.fieldId];
      const value = normalizeValue(rawValue, token.valueType);
      values[token.tokenName] = value;
      report.push({
        token: token.tokenName,
        status: value === "" ? "blank" : "resolved",
        reason: value === "" ? "The Airtable source field is blank." : "",
        source: `${source.baseId}/${source.tableId}/${group.recordId}/${source.fieldId}`,
        valueType: token.valueType || "string",
        preview: String(value).slice(0, 160)
      });
    }
  }

  return { values, report };
}

function findBrowser() {
  const candidates = [
    process.env.CHROME_PATH,
    "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe",
    "C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe",
    "C:\\Program Files\\Microsoft\\Edge\\Application\\msedge.exe"
  ].filter(Boolean);
  return candidates.find(candidate => fs.existsSync(candidate)) || "";
}

function outputPaths(args, templatePath, values, config) {
  const format = String(args.format || "both").toLowerCase();
  if (!["both", "pdf", "html"].includes(format)) throw new Error(`Unsupported --format: ${format}`);
  const defaultName = String(config?.outputNameTemplate || "")
    .replace(/\{\{\s*([^}]+?)\s*\}\}/g, (_, token) => values[token.trim()] || "") ||
    path.basename(templatePath, path.extname(templatePath));
  const requested = args.output ? path.resolve(args.output) : path.join(path.dirname(templatePath), "generated");
  const requestedExtension = path.extname(requested).toLowerCase();
  const directory = requestedExtension ? path.dirname(requested) : requested;
  const baseName = safeFilename(
    requestedExtension ? path.basename(requested, requestedExtension) : defaultName,
    "document"
  );
  fs.mkdirSync(directory, { recursive: true });
  return {
    format,
    htmlPath: path.join(directory, `${baseName}.html`),
    pdfPath: path.join(directory, `${baseName}.pdf`),
    reportPath: path.join(directory, `${baseName}.tokens.json`)
  };
}

function printPdf(htmlPath, pdfPath) {
  const browser = findBrowser();
  if (!browser) throw new Error("Chrome or Edge was not found. Set CHROME_PATH to a browser executable.");
  const fileUrl = new URL(`file:///${htmlPath.replaceAll("\\", "/")}`).href;
  execFileSync(browser, [
    "--headless=new",
    "--disable-gpu",
    "--no-sandbox",
    "--allow-file-access-from-files",
    "--run-all-compositor-stages-before-draw",
    "--virtual-time-budget=5000",
    `--print-to-pdf=${pdfPath}`,
    "--print-to-pdf-no-header",
    fileUrl
  ], { stdio: "inherit" });
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) { usage(); return; }
  if (!args.template) throw new Error("Missing --template.");
  if (!args.recordId) throw new Error("Missing --record-id.");

  const templatePath = path.resolve(args.template);
  if (!fs.existsSync(templatePath)) throw new Error(`Template not found: ${templatePath}`);
  if (path.extname(templatePath).toLowerCase() !== ".html") {
    throw new Error("The first local renderer supports HTML templates. Export Docupilot templates as HTML before rendering.");
  }

  const pat = resolvePat();
  if (!pat) throw new Error("Set AIRTABLE_PAT or add document-generation/PAT.txt.");
  const templateHtml = fs.readFileSync(templatePath, "utf8");
  const paramsByName = definitionsFromCsv(args.params || DEFAULT_PARAMS_PATH);
  const config = args.config ? readJsonFile(args.config, "Docupilot config") : null;
  const tokens = buildTokenDefinitions(templateHtml, paramsByName, config);
  if (!tokens.length) throw new Error("The template contains no {{tokens}}.");

  const recordMap = parseRecordMap(args.recordMap);
  const { values, report } = await resolveTokenValues(tokens, pat, args.recordId, recordMap);
  const unresolved = report.filter(item => item.status !== "resolved");

  console.log(`Tokens: ${tokens.length - unresolved.length} resolved, ${unresolved.length} blank or unresolved.`);
  for (const item of unresolved) console.log(`  ${item.token}: ${item.reason}`);
  if (args.strict && unresolved.length) {
    throw new Error(`Strict mode rejected ${unresolved.length} blank or unresolved tokens.`);
  }

  const paths = outputPaths(args, templatePath, values, config);
  fs.writeFileSync(paths.reportPath, JSON.stringify({
    generatedAt: new Date().toISOString(),
    template: templatePath,
    defaultRecordId: args.recordId,
    recordMap,
    tokens: report
  }, null, 2));

  if (args.dryRun) {
    console.log(`Dry run complete. Token report: ${paths.reportPath}`);
    return;
  }

  const rendered = renderHtmlTemplate(templateHtml, values);
  fs.writeFileSync(paths.htmlPath, rendered, "utf8");
  if (["both", "pdf"].includes(paths.format)) printPdf(paths.htmlPath, paths.pdfPath);
  if (paths.format === "pdf") fs.rmSync(paths.htmlPath, { force: true });

  console.log("Created:");
  if (["both", "html"].includes(paths.format)) console.log(`  HTML:   ${paths.htmlPath}`);
  if (["both", "pdf"].includes(paths.format)) console.log(`  PDF:    ${paths.pdfPath}`);
  console.log(`  Tokens: ${paths.reportPath}`);
}

if (require.main === module) {
  main().catch(error => {
    console.error(`Error: ${error.message}`);
    process.exitCode = 1;
  });
}

module.exports = {
  parseArgs,
  parseRecordMap,
  definitionsFromCsv,
  buildTokenDefinitions,
  recordIdForToken,
  groupTokenRequests,
  outputPaths
};
