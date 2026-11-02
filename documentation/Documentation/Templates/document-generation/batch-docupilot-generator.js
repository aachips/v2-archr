#!/usr/bin/env node
"use strict";

/**
 * Run local-docupilot-generator.js for every record in an Airtable view.
 *
 * Example (PowerShell):
 *   node .\document-generation\batch-docupilot-generator.js `
 *     --input-view-url "https://airtable.com/appXXX/tblXXX/viwXXX" `
 *     --project-key-field-url "https://airtable.com/appXXX/tblXXX/viwXXX/fldXXX" `
 *     --doc-code "CDBG-ERR"
 *
 * The Airtable PAT is read from AIRTABLE_PAT (or AIRTABLE_TOKEN).
 */

const path = require("node:path");
const fs = require("node:fs");
const { spawnSync } = require("node:child_process");

const DOCUMENTS_BASE = "appjB8RyRb8VryrTd";
const DOC_CODES_TABLE = "tblXLYYDEbby2D9nb";

const FIELDS = Object.freeze({
  docCode: {
    text: "fldOL4b6xRuAFp5uM",
    name: "fldzjYXOaiZY41t1s",
    docTypes: "fld8SAunHIhxTshx0",
    templates: "fld6AhzSLWaBC3z9k"
  },
});

const GENERATOR_PATH = path.join(__dirname, "local-docupilot-generator.js");
const PAT_PATH = path.join(__dirname, "pat.txt");
const LOCAL_TEMPLATES_DIR = path.join(__dirname, "templates");
const DEFAULT_CONFIG_PATH = path.join(__dirname, "batch_config.json");

function parseArgs(argv) {
  const result = {};
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (!arg.startsWith("--")) continue;
    const [rawKey, inline] = arg.slice(2).split(/=(.*)/s, 2);
    const key = rawKey.replace(/-([a-z])/g, (_, c) => c.toUpperCase());
    if (inline !== undefined) result[key] = inline;
    else if (argv[i + 1] && !argv[i + 1].startsWith("--")) result[key] = argv[++i];
    else result[key] = true;
  }
  return result;
}

function usage() {
  console.log(`Usage:
  node document-generation/batch-docupilot-generator.js [options]

Modes:
  --mode single                   Generate one document
  --project-key <value>           projectKEY for Single Record mode

  --mode view                     Generate for all records in a view
  --input-view-url <url>          Airtable app/table/view URL to process
  --project-key-field-url <url>   Airtable URL for the projectKEY field

Required in both modes:
  --doc-code <text|record-id>     [[DocCode]] for this generation run

Optional:
  --config <path>                 Config JSON (defaults to batch_config.json)
  --limit <number>                Process only the first N nonblank records
  --format <pdf|html>             Local output format; defaults to pdf
  --dry-run                       Resolve all data without generating/writing
  --strict                        Reject blank document tokens
  --stop-on-error                 Stop after the first failed project
  --help                          Show this help

Environment:
  AIRTABLE_PAT                    Airtable personal access token
  document-generation/pat.txt     Used when no PAT environment variable is set`);
}

function resolvePat() {
  const environmentPat = String(process.env.AIRTABLE_PAT || process.env.AIRTABLE_TOKEN || "").trim();
  if (environmentPat) return { pat: environmentPat, source: "environment" };
  if (!fs.existsSync(PAT_PATH)) return { pat: "", source: PAT_PATH };
  return { pat: fs.readFileSync(PAT_PATH, "utf8").trim(), source: PAT_PATH };
}

function readBatchConfig(configPath = DEFAULT_CONFIG_PATH) {
  const resolvedPath = path.resolve(configPath);
  if (!fs.existsSync(resolvedPath)) return { path: resolvedPath, values: {} };
  let values;
  try { values = JSON.parse(fs.readFileSync(resolvedPath, "utf8").replace(/^\uFEFF/, "")); }
  catch (error) { throw new Error(`Could not parse batch config ${resolvedPath}: ${error.message}`); }
  if (!values || Array.isArray(values) || typeof values !== "object") {
    throw new Error(`Batch config must contain a JSON object: ${resolvedPath}`);
  }
  return { path: resolvedPath, values };
}

function urlFromConfigIds(config, includeField = false) {
  const input = config.input || {};
  const baseId = input.baseId || config.inputBaseId;
  const tableId = input.tableId || config.inputTableId;
  const viewId = input.viewId || config.inputViewId;
  const projectKeyFieldId =
    input.fieldIds?.projectKEY || input.fieldIds?.projectKey || config.projectKeyFieldId;
  if (!baseId || !tableId || !viewId) return "";
  if (includeField && !projectKeyFieldId) return "";
  return `https://airtable.com/${baseId}/${tableId}/${viewId}${includeField ? `/${projectKeyFieldId}` : ""}`;
}

function parseAirtableUrl(value, label) {
  let url;
  try { url = new URL(String(value || "").trim()); }
  catch { throw new Error(`${label} is not a valid URL: ${value || "(blank)"}`); }
  const text = url.pathname;
  const baseId = text.match(/\/(app[a-zA-Z0-9]+)/)?.[1];
  const tableId = text.match(/\/(tbl[a-zA-Z0-9]+)/)?.[1];
  const viewId = text.match(/\/(viw[a-zA-Z0-9]+)/)?.[1];
  const fieldId = text.match(/\/(fld[a-zA-Z0-9]+)(?:\/|$)/)?.[1];
  if (!baseId || !tableId) throw new Error(`${label} must contain app... and tbl... IDs.`);
  return { baseId, tableId, viewId, fieldId };
}

function logRequest(method, url, intention) {
  const resolved = new URL(url);
  console.log("\n[HTTP request]");
  console.log(`  Intention: ${intention}`);
  console.log(`  Method:    ${method}`);
  console.log(`  Domain:    ${resolved.hostname}`);
  console.log(`  Path:      ${decodeURIComponent(resolved.pathname)}`);
}

class AirtableClient {
  constructor(pat) { this.pat = pat; }

  async request(url, options = {}, intention = "Call the Airtable API") {
    const method = options.method || "GET";
    logRequest(method, url, intention);
    const response = await fetch(url, {
      ...options,
      headers: {
        Authorization: `Bearer ${this.pat}`,
        "Content-Type": "application/json",
        ...(options.headers || {})
      }
    });
    const text = await response.text();
    let body;
    try { body = text ? JSON.parse(text) : {}; }
    catch { body = { raw: text }; }
    if (!response.ok) {
      throw new Error(
        `Airtable ${response.status} ${response.statusText} during ${method} ` +
        `${decodeURIComponent(new URL(url).pathname)}: ${JSON.stringify(body)}`
      );
    }
    return body;
  }

  async list(baseId, tableId, { viewId = "", fieldIds = [], intention = "" } = {}) {
    const records = [];
    let offset = "";
    do {
      const params = new URLSearchParams({ pageSize: "100", returnFieldsByFieldId: "true" });
      if (viewId) params.set("view", viewId);
      if (offset) params.set("offset", offset);
      for (const fieldId of fieldIds) params.append("fields[]", fieldId);
      const url = `https://api.airtable.com/v0/${baseId}/${tableId}?${params}`;
      const page = await this.request(
        url,
        {},
        intention || `List records from Airtable base ${baseId}, table ${tableId}`
      );
      records.push(...(page.records || []));
      offset = page.offset || "";
    } while (offset);
    return records;
  }

}

function field(record, fieldId) { return record?.fields?.[fieldId]; }
function links(record, fieldId) {
  const value = field(record, fieldId);
  return Array.isArray(value)
    ? value.map(item => typeof item === "string" ? item : item?.id).filter(Boolean)
    : [];
}
function asText(value) {
  if (value == null) return "";
  if (typeof value === "string") return value.trim();
  if (["number", "boolean"].includes(typeof value)) return String(value);
  if (Array.isArray(value)) return value.map(asText).filter(Boolean).join(", ");
  return asText(value.value ?? value.name ?? value.id ?? "");
}
function comparable(value) { return asText(value).toLowerCase(); }

function findLocalHtmlTemplate(docCode) {
  const key = comparable(docCode);
  if (!key || !fs.existsSync(LOCAL_TEMPLATES_DIR)) return "";
  const filename = fs.readdirSync(LOCAL_TEMPLATES_DIR).find(candidate =>
    path.extname(candidate).toLowerCase() === ".html" &&
    comparable(path.basename(candidate, path.extname(candidate))) === key
  );
  return filename ? path.join(LOCAL_TEMPLATES_DIR, filename) : "";
}

async function resolveBatchClassification(airtable, requestedDocCode) {
  const docCodes = await airtable.list(DOCUMENTS_BASE, DOC_CODES_TABLE, {
    fieldIds: Object.values(FIELDS.docCode),
    intention: `Resolve batch DocCode "${requestedDocCode}" and its linked DocType/template`
  });
  const code = docCodes.find(record =>
    record.id === requestedDocCode ||
    comparable(field(record, FIELDS.docCode.text)) === comparable(requestedDocCode) ||
    comparable(field(record, FIELDS.docCode.name)) === comparable(requestedDocCode)
  );
  if (!code) throw new Error(`DocCode "${requestedDocCode}" was not found.`);

  const docTypeIds = links(code, FIELDS.docCode.docTypes);
  if (!docTypeIds.length) throw new Error(`DocCode ${code.id} has no linked DocType.`);
  const docCodeKey = asText(field(code, FIELDS.docCode.text)) || asText(field(code, FIELDS.docCode.name));
  const localTemplatePath = findLocalHtmlTemplate(docCodeKey);
  if (!localTemplatePath) {
    throw new Error(
      `No local template found for [[DocCode]] ${docCodeKey}. ` +
      `Add ${docCodeKey}.html to ${LOCAL_TEMPLATES_DIR}. No Docupilot request was made.`
    );
  }
  console.log(`Batch will use local HTML template ${localTemplatePath} for [[DocCode]] ${docCodeKey}.`);
  return { code, docTypeId: docTypeIds[0], localTemplatePath };
}

function runProject(projectKey, classification, args) {
  const childArgs = [
    GENERATOR_PATH,
    "--project-key", projectKey,
    "--doc-type", classification.docTypeId,
    "--doc-code", classification.code.id,
    "--non-interactive"
  ];
  if (args.dryRun) childArgs.push("--dry-run");
  if (args.strict) childArgs.push("--strict");
  if (args.format) childArgs.push("--format", args.format);
  return spawnSync(process.execPath, childArgs, {
    cwd: process.cwd(),
    env: process.env,
    stdio: "inherit"
  });
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) { usage(); return; }
  const configResult = readBatchConfig(args.config || DEFAULT_CONFIG_PATH);
  const config = configResult.values;
  console.log(`Using batch config ${configResult.path}.`);
  const resolvedPat = resolvePat();
  const pat = resolvedPat.pat;
  if (!pat) {
    throw new Error(
      `Missing Airtable PAT. Set AIRTABLE_PAT/AIRTABLE_TOKEN or add the token to ${PAT_PATH}.`
    );
  }
  console.log(`Using Airtable PAT from ${resolvedPat.source}.`);
  // Child local-docupilot-generator.js processes read the token from the
  // environment. Never place the PAT in command-line arguments or logs.
  process.env.AIRTABLE_PAT = pat;
  const requestedMode = String(args.mode || config.mode || "view").trim().toLowerCase();
  const mode = requestedMode === "single record" ? "single"
    : requestedMode === "all in view" ? "view"
    : requestedMode;
  if (!["single", "view"].includes(mode)) {
    throw new Error('--mode must be "single" (Single Record) or "view" (All In View).');
  }
  const inputViewUrl =
    args.inputViewUrl || args.inputViewURL ||
    config.inputViewURL || config.inputViewUrl ||
    urlFromConfigIds(config, false);
  const projectKeyFieldUrl =
    args.projectKeyFieldUrl || args.projectKeyFieldURL ||
    config.projectKeyFieldURL || config.projectKeyFieldUrl ||
    urlFromConfigIds(config, true);
  const settings = {
    docCode: args.docCode || config["[[DocCode]]"] || config.docCode,
    format: args.format || config.format || "pdf",
    limit: args.limit !== undefined ? args.limit : config.limit,
    dryRun: args.dryRun !== undefined ? Boolean(args.dryRun) : Boolean(config.dryRun),
    strict: args.strict !== undefined ? Boolean(args.strict) : Boolean(config.strict),
    stopOnError: args.stopOnError !== undefined ? Boolean(args.stopOnError) : Boolean(config.stopOnError)
  };
  if (!["pdf", "html"].includes(String(settings.format).toLowerCase())) {
    throw new Error('--format must be "pdf" or "html".');
  }
  if (!settings.docCode) throw new Error('Missing --doc-code and batch config "[[DocCode]]".');

  const airtable = new AirtableClient(pat);
  const classification = await resolveBatchClassification(airtable, settings.docCode);

  if (mode === "single") {
    const projectKey = asText(args.projectKey || config.projectKEY || config.projectKey);
    if (!projectKey) throw new Error("Single Record mode requires --project-key.");
    console.log("\nGeneration plan:");
    console.log("  Mode:       Single Record");
    console.log(`  projectKEY: ${projectKey}`);
    console.log(`  [[DocCode]]: ${classification.code.id}`);
    console.log(`  Operation:  ${settings.dryRun ? "dry run" : "generate and upload"}`);
    const child = runProject(projectKey, classification, settings);
    if (child.status !== 0) process.exitCode = 1;
    return;
  }

  if (!inputViewUrl) throw new Error("All In View mode requires --input-view-url.");
  if (!projectKeyFieldUrl) throw new Error("All In View mode requires --project-key-field-url.");

  const view = parseAirtableUrl(inputViewUrl, "inputViewURL");
  const projectKeyField = parseAirtableUrl(projectKeyFieldUrl, "projectKeyFieldURL");
  if (!view.viewId) throw new Error("inputViewURL must contain a viw... ID.");
  if (!projectKeyField.fieldId) throw new Error("projectKeyFieldURL must contain a fld... ID.");
  if (view.baseId !== projectKeyField.baseId || view.tableId !== projectKeyField.tableId) {
    throw new Error("inputViewURL and projectKeyFieldURL must reference the same Airtable base and table.");
  }

  let records = await airtable.list(view.baseId, view.tableId, {
    viewId: view.viewId,
    fieldIds: [projectKeyField.fieldId],
    intention: `Load every record visible in input view ${view.viewId} with projectKEY field ${projectKeyField.fieldId}`
  });
  records = records.filter(record => asText(field(record, projectKeyField.fieldId)));
  const limit = settings.limit == null || settings.limit === "" ? 0 : Number(settings.limit);
  if (settings.limit != null && settings.limit !== "" && (!Number.isInteger(limit) || limit < 1)) {
    throw new Error("--limit must be a positive integer.");
  }
  if (limit) records = records.slice(0, limit);

  console.log("\nBatch plan:");
  console.log("  Mode:       All In View");
  console.log(`  View:       ${view.baseId}/${view.tableId}/${view.viewId}`);
  console.log(`  Records:    ${records.length}`);
  console.log(`  [[DocCode]]: ${classification.code.id}`);
  console.log(`  DocType:    ${classification.docTypeId}`);
  console.log(`  Template:   ${classification.localTemplatePath}`);
  console.log(`  Operation:  ${settings.dryRun ? "dry run" : "generate and upload"}`);

  const results = [];
  for (let index = 0; index < records.length; index += 1) {
    const inputRecord = records[index];
    const projectKey = asText(field(inputRecord, projectKeyField.fieldId));
    console.log(`\n${"=".repeat(72)}`);
    console.log(`[${index + 1}/${records.length}] Input record ${inputRecord.id}; projectKEY: ${projectKey}`);
    console.log("=".repeat(72));
    const child = runProject(projectKey, classification, settings);
    const success = child.status === 0;
    results.push({ inputRecordId: inputRecord.id, projectKey, success, exitCode: child.status });
    if (!success && settings.stopOnError) break;
  }

  const succeeded = results.filter(result => result.success).length;
  const failed = results.length - succeeded;
  console.log("\nBatch summary:");
  console.log(`  Attempted: ${results.length}`);
  console.log(`  Succeeded: ${succeeded}`);
  console.log(`  Failed:    ${failed}`);
  for (const result of results.filter(item => !item.success)) {
    console.log(`  FAILED ${result.inputRecordId} | ${result.projectKey} | exit ${result.exitCode}`);
  }
  if (failed) process.exitCode = 1;
}

if (require.main === module) {
  main().catch(error => {
    console.error(`\nError: ${error.message}`);
    process.exitCode = 1;
  });
}

module.exports = {
  parseArgs,
  parseAirtableUrl,
  asText,
  resolvePat,
  readBatchConfig,
  urlFromConfigIds,
  findLocalHtmlTemplate
};
