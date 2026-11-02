#!/usr/bin/env node
"use strict";

/**
 * Generate a document from a local HTML template and file it in Airtable.
 *
 * Node 18+ (uses the built-in fetch API). No npm packages are required.
 *
 * Usage:
 *   $env:AIRTABLE_PAT = "pat..."
 *   node .\document-generation\local-docupilot-generator.js --project-key rec...
 *
 * Non-interactive choices may also be supplied:
 *   --doc-type "Project Documents" --doc-code "CDBG-ERR"
 *
 * Use --dry-run to resolve the project, choices, and tokens without writing
 * to Airtable. Use --strict to reject blank tokens.
 */

const fs = require("node:fs");
const path = require("node:path");
const os = require("node:os");
const crypto = require("node:crypto");
const { execFileSync } = require("node:child_process");
const readline = require("node:readline/promises");
const { stdin, stdout } = require("node:process");

const IDS = Object.freeze({
  documentsBase: "appjB8RyRb8VryrTd",
  tables: {
    projects: "tblnQTzWLgRR1Feud",
    bucket: "tbl5nbcbvUJ9kiN7t",
    creators: "tblsr4IynmGisGRkL",
    docTypes: "tbluw1LAOvDdVx3K8",
    docCodes: "tblXLYYDEbby2D9nb",
    templates: "tbliYCjONuEGEcTDV",
    applications: "tblqsqy5c8nOSKWCV"
  },
  projects: {
    key: "fldxSLi2rHWKsGd6m",
    id: "fldbG99xPPbbHBcvm",
    jobCode: "fldKDw2EL34TcDhxf",
    applications: "fldr9SQqzWyjo1U2r"
  },
  applications: {
    name: "fldjRimuMQXdyRadb",
    submissionId: "fldp6EDpjM9zFwENB",
    eligibilityReportId: "fldgfznYt2MNw7XJS"
  },
  docTypes: {
    text: "fldcWdRmekIYhdgXS",
    label: "fldHpj1x6f6Sf5HEl",
    display: "fldvhyUAKBwfVCYhh",
    sort: "fldkfeISRdcnd2bkS",
    templates: "fldka2RV9zT9V89HL"
  },
  docCodes: {
    text: "fldOL4b6xRuAFp5uM",
    name: "fldzjYXOaiZY41t1s",
    sort: "fldl2eHw8FrWZfGSk",
    docTypes: "fld8SAunHIhxTshx0",
    templates: "fld6AhzSLWaBC3z9k"
  },
  templates: {
    name: "fldDNyBstzdonBIXD",
    docTypes: "fld75HfDE917Uhbv9",
    docCodes: "fldMohEEW6LgjSSVz",
    inputJson: "fldYmIFKjIGgbCAjn",
    workspaceId: "fldABTtZUYgHPvaiN",
    templateId: "fldaskvOjNqRveBvJ"
  },
  bucket: {
    name: "fldI3tLgtKRS1ewFm",
    project: "fld7VISEiJJ7y2o6X",
    docType: "fld66heC2YxFECA3m",
    docCode: "fldsqMKfF5fAjSfQU",
    attachment: "fldvczZcstx5roR9l",
    originalFilename: "fldCSkiCHNi7ouZqM",
    fileExtension: "fldG47o3CDLpVRae0",
    fileSizeBytes: "fldsOr5IUZYPtKp0F",
    sourceRoot: "fldVCa9iNARhAXlcf",
    uploadStatus: "fldoE4qH3GUhNj6hJ",
    error: "fldhKXehnxxaUu5FE",
    skipTokens: "fldD34mf1fVmvhzmo"
  },
  creators: {
    createdDocument: "fldlNvcJBEfB2pglb",
    docCode: "fld1WL8TrPg70O4Pq",
    projectKey: "fldHsYtRJzRT1fVfY",
    docCodeText: "fldxdeCFXNkpY0aSv",
    source: "fldp2dKa8GYpx1Gv4"
  },
  sourceBases: {
    submission: "appdJHg317xbe3Sd4",
    eligibility: "appIFBi7Rln8yFhCs"
  },
  rawSubmission: {
    table: "tblOT2m395xlhH5Bm",
    submissionId: "fldol4m4eY8Ahp39h",
    recordId: "fldRAH4CHeUuWamWZ",
    projectKey: "fldjMQIus2sTRLxWj",
    submissionDate: "fld31aunfsOtmCsO8",
    eligibilityReportId: "fldmFXGvOFHSp220D"
  }
});

// The params export lives beside this script. __dirname already resolves to
// the document-generation folder, so do not prepend that folder again.
const CSV_PATH = path.join(__dirname, "All_Fields.csv");
const LOCAL_TEMPLATES_DIR = path.join(__dirname, "templates");

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
  node document-generation/local-docupilot-generator.js --project-key <key> [options]

Options:
  --doc-type <text|record-id>  Skip the DocType prompt
  --doc-code <text|record-id>  Skip the DocCode prompt
  --output-name <filename>     Override the generated filename
  --format <pdf|html>          Local output format; defaults to pdf
  --dry-run                    Read/resolve only; do not generate or write
  --strict                     Fail if any configured token is blank
  --help                       Show this help

Environment:
  AIRTABLE_PAT                 Required Airtable personal access token`);
}

function logRequestAttempt(method, url, intention) {
  const resolved = new URL(url);
  console.log("\n[HTTP request]");
  console.log(`  Intention: ${intention}`);
  console.log(`  Method:    ${method}`);
  console.log(`  Domain:    ${resolved.hostname}`);
  console.log(`  Path:      ${decodeURIComponent(resolved.pathname)}`);
}

class AirtableClient {
  constructor(pat) {
    this.pat = pat;
  }

  async request(url, options = {}, intention = "Call the Airtable API") {
    const method = options.method || "GET";
    logRequestAttempt(method, url, intention);
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
      const requestUrl = new URL(url);
      const modelPath = decodeURIComponent(requestUrl.pathname);
      const permissionHint = response.status === 403
        ? " The PAT was accepted, but this specific base/table/record is inaccessible or its ID is stale."
        : "";
      const error = new Error(
        `Airtable ${response.status} ${response.statusText} during ${method} ${modelPath}: ` +
        `${JSON.stringify(body)}.${permissionHint}`
      );
      error.status = response.status;
      error.modelPath = modelPath;
      error.airtableBody = body;
      throw error;
    }
    return body;
  }

  async list(baseId, tableId, fieldIds = [], intention = "") {
    const records = [];
    let offset = "";
    do {
      const params = new URLSearchParams({ pageSize: "100", returnFieldsByFieldId: "true" });
      for (const fieldId of fieldIds) params.append("fields[]", fieldId);
      if (offset) params.set("offset", offset);
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

  async get(baseId, tableId, recordId, intention = "") {
    try {
      return await this.request(
        `https://api.airtable.com/v0/${baseId}/${tableId}/${recordId}?returnFieldsByFieldId=true`,
        {},
        intention || `Read Airtable record ${recordId} from base ${baseId}, table ${tableId}`
      );
    } catch (error) {
      if (error.status !== 403) throw error;

      // Airtable intentionally uses the same 403 response for an inaccessible
      // model and a missing record. Probe the table to make that distinction.
      const params = new URLSearchParams({ pageSize: "1", returnFieldsByFieldId: "true" });
      try {
        await this.request(
          `https://api.airtable.com/v0/${baseId}/${tableId}?${params}`,
          {},
          `Probe access to Airtable base ${baseId}, table ${tableId} after record ${recordId} was rejected`
        );
      } catch (tableError) {
        if (tableError.status === 403) {
          throw new Error(
            `${error.message}\nSource table probe also failed. The PAT does not have access to ` +
            `base ${baseId}, table ${tableId}, or that base/table ID is stale.`
          );
        }
        throw tableError;
      }

      const missingRecordError = new Error(
        `${error.message}\nThe source table is accessible, so record ${recordId} is stale, deleted, ` +
        `or is not a record ID from ${tableId}.`
      );
      missingRecordError.code = "AIRTABLE_RECORD_NOT_FOUND";
      missingRecordError.baseId = baseId;
      missingRecordError.tableId = tableId;
      missingRecordError.recordId = recordId;
      throw missingRecordError;
    }
  }

  create(baseId, tableId, fields) {
    return this.request(`https://api.airtable.com/v0/${baseId}/${tableId}`, {
      method: "POST",
      body: JSON.stringify({ fields, typecast: true })
    }, `Create a record in Airtable base ${baseId}, table ${tableId}`);
  }

  update(baseId, tableId, recordId, fields) {
    return this.request(`https://api.airtable.com/v0/${baseId}/${tableId}/${recordId}`, {
      method: "PATCH",
      body: JSON.stringify({ fields, typecast: true })
    }, `Update Airtable record ${recordId} in base ${baseId}, table ${tableId}`);
  }

  uploadAttachment(baseId, recordId, fieldId, filename, contentType, buffer) {
    const url = `https://content.airtable.com/v0/${baseId}/${recordId}/${fieldId}/uploadAttachment`;
    return this.request(url, {
      method: "POST",
      body: JSON.stringify({ filename, contentType, file: buffer.toString("base64") })
    }, `Upload attachment "${filename}" to Airtable record ${recordId}, field ${fieldId}`);
  }
}

function parseCsv(text) {
  text = String(text || "").replace(/^\uFEFF/, "");
  const rows = [];
  let row = [], value = "", quoted = false;
  for (let i = 0; i < text.length; i += 1) {
    const c = text[i];
    if (quoted) {
      if (c === '"' && text[i + 1] === '"') { value += '"'; i += 1; }
      else if (c === '"') quoted = false;
      else value += c;
    } else if (c === '"') quoted = true;
    else if (c === ",") { row.push(value); value = ""; }
    else if (c === "\n") { row.push(value.replace(/\r$/, "")); rows.push(row); row = []; value = ""; }
    else value += c;
  }
  if (value || row.length) { row.push(value.replace(/\r$/, "")); rows.push(row); }
  const headers = rows.shift() || [];
  return rows.filter(r => r.some(Boolean)).map(r =>
    Object.fromEntries(headers.map((header, index) => [header, r[index] || ""]))
  );
}

function cleanTokenName(name) {
  return String(name || "").trim().replace(/^\{\{\s*/, "").replace(/\s*\}\}$/, "").trim();
}

function findLocalHtmlTemplate(docCode) {
  const key = comparable(docCode);
  if (!key || !fs.existsSync(LOCAL_TEMPLATES_DIR)) return "";
  const filename = fs.readdirSync(LOCAL_TEMPLATES_DIR).find(candidate =>
    path.extname(candidate).toLowerCase() === ".html" &&
    comparable(path.basename(candidate, path.extname(candidate))) === key
  );
  return filename ? path.join(LOCAL_TEMPLATES_DIR, filename) : "";
}

function extractHtmlTokens(html) {
  const names = new Set();
  for (const match of String(html || "").matchAll(/\{\{\s*([^}]+?)\s*\}\}/g)) {
    const directive = cleanTokenName(match[0]);
    if (directive.startsWith("#if ")) {
      for (const part of directive.slice(4).split(/\s+and\s+/i)) {
        const conditionalToken = part.trim().match(/^([\w.-]+)/)?.[1];
        if (conditionalToken) names.add(conditionalToken);
      }
    } else if (directive && !directive.startsWith("#") && !directive.startsWith("/") && directive !== "else") {
      names.add(directive);
    }
  }
  return [...names];
}

function isTruthyTemplateValue(value) {
  if (typeof value === "boolean") return value;
  if (typeof value === "number") return value !== 0;
  const text = String(value ?? "").trim().toLowerCase();
  return Boolean(text) && !["false", "no", "0", "null", "undefined"].includes(text);
}

function evaluateHtmlCondition(expression, values) {
  let source = String(expression || "").trim();
  if (source.startsWith("(") && source.endsWith(")")) source = source.slice(1, -1).trim();
  return source.split(/\s+and\s+/i).every(part => {
    const comparison = part.trim().match(/^([\w.-]+)\s*(==|!=)\s*["']([^"']*)["']$/);
    if (comparison) {
      const actual = String(values[comparison[1]] ?? "");
      return comparison[2] === "==" ? actual === comparison[3] : actual !== comparison[3];
    }
    return isTruthyTemplateValue(values[part.trim()]);
  });
}

function renderHtmlTemplate(html, values) {
  // Docupilot's exported HTML wraps control tags in hidden dp-tag divs. Strip
  // those wrappers first so excluding a branch cannot leave an unclosed div.
  const source = String(html || "").replace(
    /<div\b[^>]*class=["'][^"']*\bdp-tag\b[^"']*["'][^>]*>\s*(\{\{\s*(?:#if\s+[^}]+|else|\/if)\s*\}\})\s*<\/div>/gi,
    "$1"
  );
  const tokenPattern = /\{\{\s*([^}]+?)\s*\}\}/g;
  const frames = [];
  let rendered = "";
  let cursor = 0;
  let match;
  const isActive = () => frames.every(frame => frame.active);

  while ((match = tokenPattern.exec(source)) !== null) {
    if (isActive()) rendered += source.slice(cursor, match.index);
    const directive = match[1].trim();
    if (directive.startsWith("#if ")) {
      const parentActive = isActive();
      const condition = evaluateHtmlCondition(directive.slice(4), values);
      frames.push({ parentActive, condition, active: parentActive && condition });
    } else if (directive === "else") {
      const frame = frames.at(-1);
      if (!frame) throw new Error("Local HTML template has {{else}} without {{#if}}.");
      frame.active = frame.parentActive && !frame.condition;
    } else if (directive === "/if") {
      if (!frames.length) throw new Error("Local HTML template has {{/if}} without {{#if}}.");
      frames.pop();
    } else if (isActive()) {
      rendered += values[directive] ?? "";
    }
    cursor = tokenPattern.lastIndex;
  }
  if (frames.length) throw new Error("Local HTML template has an unclosed {{#if}} block.");
  rendered += source.slice(cursor);
  return rendered;
}

function unwrap(value) {
  if (Array.isArray(value)) {
    if (!value.length) return "";
    return unwrap(value[0]?.value ?? value[0]);
  }
  if (value && typeof value === "object" && "value" in value) return unwrap(value.value);
  return value;
}

function parseJsonConfig(value) {
  let current = unwrap(value);
  for (let i = 0; i < 10; i += 1) {
    if (current && typeof current === "object" && Array.isArray(current.tokens)) return current;
    if (typeof current === "string") {
      const cleaned = current.trim().replace(/^input\s*:\s*/i, "").replace(/^```(?:json|js)?\s*/i, "").replace(/```$/i, "");
      current = JSON.parse(cleaned);
      continue;
    }
    const wrapper = ["input", "config", "docConfig", "docConfigJson", "payload", "payloadJson", "data", "fields"]
      .find(key => current && current[key] != null);
    if (wrapper) { current = unwrap(current[wrapper]); continue; }
    break;
  }
  return current && typeof current === "object" ? current : {};
}

function asText(value) {
  if (value == null) return "";
  if (typeof value === "string") return value;
  if (["number", "boolean"].includes(typeof value)) return String(value);
  if (Array.isArray(value)) return value.map(asText).filter(Boolean).join(", ");
  return value.name || value.email || value.filename || value.id || JSON.stringify(value);
}

function numberValue(value) {
  if (typeof value === "number") return Number.isFinite(value) ? value : null;
  const cleaned = asText(value).replace(/[$,\s]/g, "").replace(/[^\d.-]/g, "");
  const number = Number(cleaned);
  return cleaned && Number.isFinite(number) ? number : null;
}

function normalizeValue(value, valueType = "string") {
  const type = String(valueType || "string").trim().toLowerCase();
  if (type === "imageurl") {
    const items = Array.isArray(value) ? value : [value];
    return items.find(item => String(item?.type || "").startsWith("image/"))?.url || items[0]?.url || asText(value);
  }
  if (type === "richtext") return Array.isArray(value) ? value.map(asText).filter(Boolean).join("\n") : asText(value);
  if (["num", "number"].includes(type)) return numberValue(value) == null ? "" : String(numberValue(value));
  if (["int", "integer"].includes(type)) return numberValue(value) == null ? "" : String(Math.round(numberValue(value)));
  if (type === "currency") return numberValue(value) == null ? "" : numberValue(value).toLocaleString("en-US", { style: "currency", currency: "USD" });
  if (["boo", "bool", "boolean"].includes(type)) {
    if (typeof value === "boolean") return value ? "Yes" : "No";
    const text = asText(value).trim().toLowerCase();
    if (["true", "yes", "1", "checked"].includes(text)) return "Yes";
    if (["false", "no", "0", "unchecked"].includes(text)) return "No";
    return asText(value);
  }
  if (["date", "datetime"].includes(type)) {
    if (!value) return "";
    const date = new Date(asText(value));
    return Number.isNaN(date.valueOf()) ? asText(value) : date.toLocaleDateString("en-US");
  }
  if (["obj", "object"].includes(type)) return typeof value === "object" ? JSON.stringify(value ?? {}) : asText(value);
  return asText(value);
}

function parseFieldUrl(url) {
  const text = String(url || "");
  const baseId = text.match(/\/(app[a-zA-Z0-9]+)/)?.[1];
  const tableId = text.match(/\/(tbl[a-zA-Z0-9]+)/)?.[1];
  const fieldId = text.match(/\/(fld[a-zA-Z0-9]+)(?:[/?#]|$)/)?.[1];
  return baseId && tableId && fieldId ? { baseId, tableId, fieldId } : null;
}

function field(record, id) { return record?.fields?.[id]; }
function links(record, id) {
  const value = field(record, id);
  return Array.isArray(value) ? value.map(item => typeof item === "string" ? item : item?.id).filter(Boolean) : [];
}
function label(record, ...fieldIds) {
  for (const id of fieldIds) {
    const text = asText(field(record, id)).trim();
    if (text) return text;
  }
  return record.id;
}
function comparable(value) { return String(value || "").trim().toLowerCase(); }

async function choose(records, requested, describe, prompt, rl, nonInteractive = false) {
  if (!records.length) throw new Error(`No choices available for ${prompt}.`);
  if (requested) {
    const match = records.find(record => record.id === requested || comparable(describe(record)) === comparable(requested));
    if (!match) throw new Error(`${prompt} "${requested}" was not found. Choices: ${records.map(describe).join(", ")}`);
    return match;
  }
  if (records.length === 1) return records[0];
  if (nonInteractive) {
    console.warn(`${prompt} has ${records.length} matches; non-interactive mode selected the first: ${describe(records[0])}`);
    return records[0];
  }
  console.log(`\n${prompt}:`);
  records.forEach((record, index) => console.log(`  ${index + 1}. ${describe(record)}`));
  while (true) {
    const answer = Number(await rl.question("Select a number: "));
    if (Number.isInteger(answer) && records[answer - 1]) return records[answer - 1];
  }
}

function mergeTokenDefinitions(configTokens, csvRows, templateName) {
  const csvByName = new Map();
  for (const row of csvRows) {
    const key = cleanTokenName(row.Name);
    if (key) csvByName.set(key, row);
  }
  const merged = [];
  const seen = new Set();
  for (const token of configTokens || []) {
    const key = cleanTokenName(token.tokenName);
    if (!key || seen.has(key)) continue;
    const csv = csvByName.get(key) || {};
    merged.push({
      ...token,
      tokenName: key,
      valueFieldUrl: token.valueFieldUrl || token.fieldURL || csv.fieldURL || "",
      valueType: token.valueType || csv.valueType || "string"
    });
    seen.add(key);
  }
  // Include CSV rows explicitly tagged for this template, even if an old
  // template inputJSON omitted them.
  for (const row of csvRows) {
    const key = cleanTokenName(row.Name);
    const templates = String(row["(🔧) DocuPilot Templates"] || "").split(",").map(v => comparable(v));
    if (!key || seen.has(key) || !templates.includes(comparable(templateName))) continue;
    merged.push({ tokenName: key, valueFieldUrl: row.fieldURL || "", valueType: row.valueType || "string" });
    seen.add(key);
  }
  return merged;
}

function interpolate(template, values) {
  return String(template || "").replace(/\{\{\s*([^}]+?)\s*\}\}/g, (_, key) => values[String(key).trim()] ?? "");
}

function safeFilename(value, fallback = "document.pdf") {
  const cleaned = String(value || fallback).replace(/[<>:"/\\|?*\u0000-\u001f]/g, "-").trim();
  return cleaned || fallback;
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

function renderLocalDocument(html, format = "pdf") {
  const normalizedFormat = String(format || "pdf").toLowerCase();
  if (normalizedFormat === "html") {
    return {
      buffer: Buffer.from(html, "utf8"),
      contentType: "text/html; charset=utf-8",
      extension: ".html"
    };
  }
  if (normalizedFormat !== "pdf") {
    throw new Error(`Unsupported --format ${format}. Expected pdf or html.`);
  }

  const browser = findBrowser();
  if (!browser) {
    throw new Error("Chrome or Edge was not found. Set CHROME_PATH or use --format html.");
  }
  const tempBase = path.join(os.tmpdir(), `archr-document-${crypto.randomUUID()}`);
  const htmlPath = `${tempBase}.html`;
  const pdfPath = `${tempBase}.pdf`;
  try {
    fs.writeFileSync(htmlPath, html, "utf8");
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
    ], { stdio: "ignore" });
    if (!fs.existsSync(pdfPath)) throw new Error("Browser did not create the expected PDF file.");
    return {
      buffer: fs.readFileSync(pdfPath),
      contentType: "application/pdf",
      extension: ".pdf"
    };
  } finally {
    fs.rmSync(htmlPath, { force: true });
    fs.rmSync(pdfPath, { force: true });
  }
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) { usage(); return; }
  const pat = process.env.AIRTABLE_PAT || process.env.AIRTABLE_TOKEN;
  if (!pat) throw new Error("Set AIRTABLE_PAT before running this script.");
  if (!args.projectKey) throw new Error("Missing --project-key. Run with --help for usage.");

  const airtable = new AirtableClient(pat);
  const rl = readline.createInterface({ input: stdin, output: stdout });
  try {
    console.log(`Reading projects from ${IDS.documentsBase}/${IDS.tables.projects}...`);
    const projectFields = [...Object.values(IDS.projects)];
    const projects = await airtable.list(
      IDS.documentsBase,
      IDS.tables.projects,
      projectFields,
      `Find the project matching projectKey "${args.projectKey}"`
    );
    const project = projects.find(record =>
      record.id === args.projectKey ||
      [IDS.projects.key, IDS.projects.id, IDS.projects.jobCode].some(id => comparable(field(record, id)) === comparable(args.projectKey))
    );
    if (!project) throw new Error(`No project matched projectKey "${args.projectKey}".`);
    const canonicalProjectKey = label(project, IDS.projects.key, IDS.projects.id, IDS.projects.jobCode);

    console.log(`Reading document types from ${IDS.documentsBase}/${IDS.tables.docTypes}...`);
    const typeFields = Object.values(IDS.docTypes);
    const allTypes = await airtable.list(
      IDS.documentsBase,
      IDS.tables.docTypes,
      typeFields,
      "Load selectable document types"
    );
    const availableTypes = allTypes
      .sort((a, b) => Number(field(a, IDS.docTypes.sort) || 999) - Number(field(b, IDS.docTypes.sort) || 999));
    const docType = await choose(
      availableTypes, args.docType,
      record => label(record, IDS.docTypes.display, IDS.docTypes.label, IDS.docTypes.text),
      "Document type", rl
    );

    console.log(`Reading document codes from ${IDS.documentsBase}/${IDS.tables.docCodes}...`);
    const codeFields = Object.values(IDS.docCodes);
    const allCodes = await airtable.list(
      IDS.documentsBase,
      IDS.tables.docCodes,
      codeFields,
      "Load document codes for the selected document type"
    );
    const availableCodes = allCodes
      .filter(record => {
        if (!links(record, IDS.docCodes.docTypes).includes(docType.id)) return false;
        const codeKey = label(record, IDS.docCodes.text, IDS.docCodes.name);
        return Boolean(findLocalHtmlTemplate(codeKey));
      })
      .sort((a, b) => Number(field(a, IDS.docCodes.sort) || 999) - Number(field(b, IDS.docCodes.sort) || 999));
    const docCode = await choose(
      availableCodes, args.docCode,
      record => label(record, IDS.docCodes.text, IDS.docCodes.name),
      "Document code", rl
    );

    const docCodeKey = label(docCode, IDS.docCodes.text, IDS.docCodes.name);
    const localTemplatePath = findLocalHtmlTemplate(docCodeKey);
    if (!localTemplatePath) {
      throw new Error(
        `No local template found for [[DocCode]] ${docCodeKey}. ` +
        `Add ${docCodeKey}.html to ${LOCAL_TEMPLATES_DIR}.`
      );
    }
    const localTemplateHtml = fs.readFileSync(localTemplatePath, "utf8");
    const templateName = path.basename(localTemplatePath);
    const config = {};
    const configTokens = extractHtmlTokens(localTemplateHtml).map(tokenName => ({ tokenName }));
    console.log(`Using local HTML template ${localTemplatePath} for [[DocCode]] ${docCodeKey}.`);
    const csvRows = parseCsv(fs.readFileSync(CSV_PATH, "utf8"));
    const tokens = mergeTokenDefinitions(configTokens, csvRows, templateName);
    if (!tokens.length) throw new Error(`Template "${templateName}" has no token definitions.`);

    const applicationLinks = links(project, IDS.projects.applications);
    const applications = await Promise.all(applicationLinks.map(id => airtable.get(
      IDS.documentsBase,
      IDS.tables.applications,
      id,
      `Resolve project application ${id} to its source submission and eligibility-report record IDs`
    )));
    const application = applications.length
      ? await choose(
        applications,
        args.application,
        record => label(record, IDS.applications.name, IDS.applications.submissionId),
        "Project application",
        rl,
        Boolean(args.nonInteractive)
      )
      : null;
    const submissionKey = asText(field(application, IDS.applications.submissionId)).trim();
    const sourceRecordIds = new Map([
      [IDS.sourceBases.eligibility, asText(field(application, IDS.applications.eligibilityReportId)).trim()]
    ]);

    const recordCache = new Map();
    if (submissionKey) {
      const candidates = await airtable.list(
        IDS.sourceBases.submission,
        IDS.rawSubmission.table,
        [
          IDS.rawSubmission.submissionId,
          IDS.rawSubmission.recordId,
          IDS.rawSubmission.projectKey,
          IDS.rawSubmission.submissionDate
        ],
        `Resolve synced submission reference "${submissionKey}" against Raw Submission submissionId or id(rawSub)`
      );
      let matching = candidates.filter(record => {
        const primaryValue = comparable(field(record, IDS.rawSubmission.submissionId));
        const storedRecordId = comparable(field(record, IDS.rawSubmission.recordId));
        return primaryValue === comparable(submissionKey) || storedRecordId === comparable(submissionKey);
      });

      // Older sync rows can contain an obsolete submissionId. Project-key
      // matching remains a recovery path, but it is never treated as a record ID.
      if (!matching.length) {
        console.warn(
          `\nNo Raw Submission has submissionId or id(rawSub) "${submissionKey}". ` +
          `Trying canonical project key ${canonicalProjectKey}...`
        );
        const projectKeys = new Set([
          args.projectKey,
          canonicalProjectKey,
          project.id,
          field(project, IDS.projects.id),
          field(project, IDS.projects.jobCode)
        ].map(comparable).filter(Boolean));
        matching = candidates.filter(record => {
          const rawKeys = field(record, IDS.rawSubmission.projectKey);
          const values = Array.isArray(rawKeys) ? rawKeys : [rawKeys];
          return values.some(value => projectKeys.has(comparable(asText(value))));
        });
      }
      matching.sort((a, b) => {
        const aDate = new Date(asText(field(a, IDS.rawSubmission.submissionDate)) || 0).valueOf();
        const bDate = new Date(asText(field(b, IDS.rawSubmission.submissionDate)) || 0).valueOf();
        return bDate - aDate;
      });

      if (!matching.length) {
        throw new Error(
          `No Raw Submission matched submissionId "${submissionKey}" or project ${canonicalProjectKey}.`
        );
      }
      const resolved = await choose(
        matching,
        args.rawSubmission,
        record => {
          const storedId = asText(field(record, IDS.rawSubmission.recordId)).trim() || record.id;
          const date = asText(field(record, IDS.rawSubmission.submissionDate)) || "unknown date";
          return `${asText(field(record, IDS.rawSubmission.submissionId))} | ${storedId} | ${date}`;
        },
        "Raw Submission",
        rl,
        Boolean(args.nonInteractive)
      );
      const storedRawSubmissionId = asText(field(resolved, IDS.rawSubmission.recordId)).trim();
      const resolvedRawSubmissionId = storedRawSubmissionId || resolved.id;
      if (storedRawSubmissionId && storedRawSubmissionId !== resolved.id) {
        console.warn(
          `Warning: id(rawSub) says ${storedRawSubmissionId}, but Airtable returned ${resolved.id}; ` +
          `using Airtable's authoritative record.id ${resolved.id}.`
        );
      }
      const apiRawSubmissionId = resolved.id;
      console.log(
        `Resolved submissionId "${submissionKey}" to id(rawSub) ` +
        `${resolvedRawSubmissionId} (API record ${apiRawSubmissionId}).`
      );
      sourceRecordIds.set(IDS.sourceBases.submission, apiRawSubmissionId);
      const rawSubmission = await airtable.get(
        IDS.sourceBases.submission,
        IDS.rawSubmission.table,
        apiRawSubmissionId,
        `Load token-source fields from Raw Submission ${apiRawSubmissionId} resolved by submissionId "${submissionKey}"`
      );
      recordCache.set(
        `${IDS.sourceBases.submission}:${IDS.rawSubmission.table}:${apiRawSubmissionId}`,
        rawSubmission
      );
      const currentEligibilityId = asText(field(rawSubmission, IDS.rawSubmission.eligibilityReportId)).trim();
      if (currentEligibilityId) sourceRecordIds.set(IDS.sourceBases.eligibility, currentEligibilityId);
    }

    const values = {}, blankTokens = [], tokenReport = [];
    for (const token of tokens) {
      const key = cleanTokenName(token.tokenName);
      const source = parseFieldUrl(token.valueFieldUrl);
      const recordId = token.recordId || (source ? sourceRecordIds.get(source.baseId) : "");
      let rawValue;
      let reason = "";
      if (!source) reason = "no fieldURL mapping";
      else if (!recordId) reason = `no source record resolver for base ${source.baseId}`;
      else {
        const cacheKey = `${source.baseId}:${source.tableId}:${recordId}`;
        if (!recordCache.has(cacheKey)) {
          recordCache.set(cacheKey, await airtable.get(
            source.baseId,
            source.tableId,
            recordId,
            `Resolve template token "{{${key}}}" from Airtable field ${source.fieldId}`
          ));
        }
        rawValue = field(recordCache.get(cacheKey), source.fieldId);
        if (rawValue == null || rawValue === "") reason = "source field is blank";
      }
      values[key] = normalizeValue(rawValue, token.valueType);
      if (!values[key]) blankTokens.push(key);
      tokenReport.push({ token: key, valueType: token.valueType, status: values[key] ? "resolved" : "blank", reason });
    }

    const outputBase = args.outputName || interpolate(config.outputNameTemplate, values) || `${label(docCode, IDS.docCodes.text, IDS.docCodes.name)} - ${canonicalProjectKey}`;

    console.log("\nResolved generation:");
    console.log(`  Project:  ${canonicalProjectKey} (${project.id})`);
    console.log(`  DocType:  ${label(docType, IDS.docTypes.display, IDS.docTypes.label, IDS.docTypes.text)} (${docType.id})`);
    console.log(`  DocCode:  ${label(docCode, IDS.docCodes.text, IDS.docCodes.name)} (${docCode.id})`);
    console.log(`  Template: ${templateName} (local HTML)`);
    console.log(`  Tokens:   ${tokens.length - blankTokens.length} resolved, ${blankTokens.length} blank`);
    if (blankTokens.length) console.log(`  Blank:    ${blankTokens.join(", ")}`);
    if (args.strict && blankTokens.length) throw new Error("--strict rejected blank template tokens.");
    if (args.dryRun) {
      console.log("\nDry run: no document generation or Airtable writes were made.");
      console.log(JSON.stringify({ generationMode: "local-html", localTemplatePath, values, tokenReport }, null, 2));
      return;
    }

    const generated = renderLocalDocument(
      renderHtmlTemplate(localTemplateHtml, values),
      args.format || "pdf"
    );
    const filenameBase = `${path.basename(outputBase, path.extname(outputBase))}${generated.extension}`;
    const filename = safeFilename(filenameBase);
    const now = new Date().toISOString();
    const bucket = await airtable.create(IDS.documentsBase, IDS.tables.bucket, {
      [IDS.bucket.name]: filename,
      [IDS.bucket.originalFilename]: filename,
      [IDS.bucket.project]: [project.id],
      [IDS.bucket.docType]: [docType.id],
      [IDS.bucket.docCode]: [docCode.id],
      [IDS.bucket.fileExtension]: path.extname(filename).replace(/^\./, ""),
      [IDS.bucket.fileSizeBytes]: String(generated.buffer.length),
      [IDS.bucket.sourceRoot]: "local-html-template",
      [IDS.bucket.uploadStatus]: "uploading",
      // Set this on the initial create, not in a later PATCH. Bucket view
      // automations can otherwise consume/remove the attachment-less record
      // before the direct upload request has a chance to run.
      [IDS.bucket.skipTokens]: true
    });

    try {
      await airtable.uploadAttachment(
        IDS.documentsBase, bucket.id, IDS.bucket.attachment,
        filename, generated.contentType, generated.buffer
      );
      await airtable.update(IDS.documentsBase, IDS.tables.bucket, bucket.id, {
        [IDS.bucket.uploadStatus]: `uploaded ${now}`,
        [IDS.bucket.error]: ""
      });
    } catch (error) {
      await airtable.update(IDS.documentsBase, IDS.tables.bucket, bucket.id, {
        [IDS.bucket.uploadStatus]: "error",
        [IDS.bucket.error]: error.message
      }).catch(() => {});
      throw new Error(`Bucket ${bucket.id} was created, but attachment upload failed: ${error.message}`);
    }

    // The Creator is born with Created [Document] populated. Therefore its
    // document-generation automation formula never enters the automation view.
    const creator = await airtable.create(IDS.documentsBase, IDS.tables.creators, {
      [IDS.creators.projectKey]: canonicalProjectKey,
      [IDS.creators.docCode]: [docCode.id],
      [IDS.creators.docCodeText]: label(docCode, IDS.docCodes.text),
      [IDS.creators.source]: "local-html-template",
      [IDS.creators.createdDocument]: [bucket.id]
    });

    console.log("\nCreated successfully:");
    console.log(`  Bucket:           ${bucket.id}`);
    console.log(`  Document Creator: ${creator.id}`);
    console.log(`  File:             ${filename} (${generated.buffer.length} bytes)`);
  } finally {
    rl.close();
  }
}

if (require.main === module) {
  main().catch(error => {
    console.error(`\nError: ${error.message}`);
    process.exitCode = 1;
  });
}

module.exports = {
  IDS,
  parseArgs,
  parseCsv,
  cleanTokenName,
  parseJsonConfig,
  normalizeValue,
  parseFieldUrl,
  mergeTokenDefinitions,
  findLocalHtmlTemplate,
  extractHtmlTokens,
  renderHtmlTemplate,
  findBrowser,
  renderLocalDocument,
  safeFilename
};
