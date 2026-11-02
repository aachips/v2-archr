#!/usr/bin/env node
"use strict";

/**
 * Render one local HTML template for every record in an Airtable view.
 * Each view record is used as --record-id unless --record-id-field-url points
 * to a field containing a different rec... ID.
 */

const fs = require("node:fs");
const path = require("node:path");
const { spawnSync } = require("node:child_process");

const GENERATOR_PATH = path.join(__dirname, "local-airtable-template-generator.js");
const PAT_PATH = path.join(__dirname, "PAT.txt");
const DEFAULT_CONFIG_PATH = path.join(__dirname, "batch_local_template_config.json");

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
  node document-generation/batch-local-airtable-template-generator.js [options]

Required (CLI or batch_local_template_config.json):
  --input-view-url <url>          Exact Airtable view to process
  --template <path>               Local HTML template

Optional:
  --record-id-field-url <url>     Field containing each source rec... ID;
                                  defaults to the view record's own ID
  --output-name-field-url <url>   Field used for output filenames
  --params <path>                 Params CSV; defaults to All_Fields.csv
  --docupilot-config <path>       Optional token/output-name config passed to renderer
  --record-map <json|path>        Constant record map passed to every render
  --output <directory>            Defaults to generated-batch beside this script
  --format <both|pdf|html>        Defaults to both
  --limit <number>                Process only the first N records
  --strict                        Reject blank or unresolved tokens
  --dry-run                       Fetch values and write token reports only
  --stop-on-error                 Stop after the first failed record
  --config <path>                 Batch config path
  --help                          Show this help

PAT lookup:
  AIRTABLE_PAT, AIRTABLE_TOKEN, then document-generation/PAT.txt`);
}

function readConfig(configPath) {
  const resolvedPath = path.resolve(configPath || DEFAULT_CONFIG_PATH);
  if (!fs.existsSync(resolvedPath)) return { path: resolvedPath, values: {} };
  try {
    const values = JSON.parse(fs.readFileSync(resolvedPath, "utf8").replace(/^\uFEFF/, ""));
    if (!values || Array.isArray(values) || typeof values !== "object") throw new Error("root must be an object");
    return { path: resolvedPath, values };
  } catch (error) {
    throw new Error(`Could not parse batch config ${resolvedPath}: ${error.message}`);
  }
}

function resolvePathSetting(cliValue, configValue, configPath) {
  if (cliValue) return path.resolve(String(cliValue));
  if (!configValue) return "";
  return path.resolve(path.dirname(configPath), String(configValue));
}

function resolveRecordMapSetting(cliValue, configValue, configPath) {
  const value = cliValue || configValue || "";
  if (!value || String(value).trim().startsWith("{")) return value;
  return cliValue ? path.resolve(String(value)) : path.resolve(path.dirname(configPath), String(value));
}

function resolvePat() {
  const environmentPat = String(process.env.AIRTABLE_PAT || process.env.AIRTABLE_TOKEN || "").trim();
  if (environmentPat) return { pat: environmentPat, source: "environment" };
  if (fs.existsSync(PAT_PATH)) return { pat: fs.readFileSync(PAT_PATH, "utf8").trim(), source: PAT_PATH };
  return { pat: "", source: PAT_PATH };
}

function parseAirtableUrl(value, label) {
  let url;
  try { url = new URL(String(value || "").trim()); }
  catch { throw new Error(`${label} is not a valid URL: ${value || "(blank)"}`); }
  const pathname = url.pathname;
  const baseId = pathname.match(/\/(app[a-zA-Z0-9]+)/)?.[1];
  const tableId = pathname.match(/\/(tbl[a-zA-Z0-9]+)/)?.[1];
  const viewId = pathname.match(/\/(viw[a-zA-Z0-9]+)/)?.[1];
  const fieldId = pathname.match(/\/(fld[a-zA-Z0-9]+)(?:\/|$)/)?.[1];
  if (!baseId || !tableId) throw new Error(`${label} must contain app... and tbl... IDs.`);
  return { baseId, tableId, viewId, fieldId };
}

function inputUrlFromConfig(config, fieldName = "") {
  const input = config.input || {};
  const baseId = input.baseId || config.inputBaseId;
  const tableId = input.tableId || config.inputTableId;
  const viewId = input.viewId || config.inputViewId;
  const fieldId = input.fieldIds?.[fieldName];
  if (!baseId || !tableId || !viewId || (fieldName && !fieldId)) return "";
  return `https://airtable.com/${baseId}/${tableId}/${viewId}${fieldId ? `/${fieldId}` : ""}`;
}

function asText(value) {
  if (value == null) return "";
  if (typeof value === "string") return value.trim();
  if (["number", "boolean"].includes(typeof value)) return String(value);
  if (Array.isArray(value)) return value.map(asText).filter(Boolean).join(", ");
  return asText(value.value ?? value.name ?? value.id ?? "");
}

function safeStem(value, fallback) {
  const cleaned = String(value || "")
    .replace(/[<>:"/\\|?*\u0000-\u001F]/g, "_")
    .replace(/[. ]+$/g, "")
    .trim();
  return cleaned || fallback;
}

function logRequest(method, url, intention) {
  const resolved = new URL(url);
  console.log("\n[HTTP request]");
  console.log(`  Intention: ${intention}`);
  console.log(`  Method:    ${method}`);
  console.log(`  Domain:    ${resolved.hostname}`);
  console.log(`  Path:      ${decodeURIComponent(resolved.pathname)}`);
}

async function listViewRecords(pat, view, fieldIds) {
  const records = [];
  let offset = "";
  do {
    const query = new URLSearchParams({ pageSize: "100", view: view.viewId, returnFieldsByFieldId: "true" });
    if (offset) query.set("offset", offset);
    for (const fieldId of fieldIds) query.append("fields[]", fieldId);
    const url = `https://api.airtable.com/v0/${view.baseId}/${view.tableId}?${query}`;
    logRequest("GET", url, `Load records from exact input view ${view.viewId}`);
    const response = await fetch(url, { headers: { Authorization: `Bearer ${pat}` } });
    const text = await response.text();
    let body;
    try { body = text ? JSON.parse(text) : {}; } catch { body = { raw: text }; }
    if (!response.ok) {
      throw new Error(`Airtable ${response.status} ${response.statusText}: ${JSON.stringify(body)}`);
    }
    records.push(...(body.records || []));
    offset = body.offset || "";
  } while (offset);
  return records;
}

function assertSameInputTable(reference, candidate, label) {
  if (!candidate) return;
  if (!candidate.fieldId) throw new Error(`${label} must contain a fld... ID.`);
  if (reference.baseId !== candidate.baseId || reference.tableId !== candidate.tableId) {
    throw new Error(`${label} must reference the same base and table as inputViewURL.`);
  }
}

function runRecord(recordId, outputName, settings) {
  const outputFile = path.join(settings.output, `${safeStem(outputName, recordId)}.html`);
  const childArgs = [
    GENERATOR_PATH,
    "--template", settings.template,
    "--record-id", recordId,
    "--output", outputFile,
    "--format", settings.format
  ];
  if (settings.params) childArgs.push("--params", settings.params);
  if (settings.docupilotConfig) childArgs.push("--config", settings.docupilotConfig);
  if (settings.recordMap) childArgs.push("--record-map", settings.recordMap);
  if (settings.strict) childArgs.push("--strict");
  if (settings.dryRun) childArgs.push("--dry-run");
  return spawnSync(process.execPath, childArgs, {
    cwd: process.cwd(),
    env: process.env,
    stdio: "inherit"
  });
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) { usage(); return; }
  const loaded = readConfig(args.config || DEFAULT_CONFIG_PATH);
  const config = loaded.values;
  console.log(`Using batch config ${loaded.path}.`);

  const resolvedPat = resolvePat();
  if (!resolvedPat.pat) throw new Error(`Missing Airtable PAT. Set AIRTABLE_PAT/AIRTABLE_TOKEN or add ${PAT_PATH}.`);
  console.log(`Using Airtable PAT from ${resolvedPat.source}.`);
  process.env.AIRTABLE_PAT = resolvedPat.pat;

  const inputViewUrl = args.inputViewUrl || config.inputViewURL || config.inputViewUrl || inputUrlFromConfig(config);
  const recordIdFieldUrl = args.recordIdFieldUrl || config.recordIdFieldURL || config.recordIdFieldUrl || inputUrlFromConfig(config, "recordId");
  const outputNameFieldUrl = args.outputNameFieldUrl || config.outputNameFieldURL || config.outputNameFieldUrl || inputUrlFromConfig(config, "outputName");
  const settings = {
    template: resolvePathSetting(args.template, config.template, loaded.path),
    params: resolvePathSetting(args.params, config.params, loaded.path),
    docupilotConfig: resolvePathSetting(args.docupilotConfig, config.docupilotConfig, loaded.path),
    recordMap: resolveRecordMapSetting(args.recordMap, config.recordMap, loaded.path),
    output: resolvePathSetting(args.output, config.output || "generated-batch", loaded.path),
    format: String(args.format || config.format || "both").toLowerCase(),
    limit: args.limit !== undefined ? args.limit : config.limit,
    strict: args.strict !== undefined ? Boolean(args.strict) : Boolean(config.strict),
    dryRun: args.dryRun !== undefined ? Boolean(args.dryRun) : Boolean(config.dryRun),
    stopOnError: args.stopOnError !== undefined ? Boolean(args.stopOnError) : Boolean(config.stopOnError)
  };
  if (!inputViewUrl) throw new Error("Missing --input-view-url or input IDs in batch config.");
  if (!args.template && !config.template) throw new Error("Missing --template or config template.");
  if (!fs.existsSync(settings.template)) throw new Error(`Template not found: ${settings.template}`);
  if (!["both", "pdf", "html"].includes(settings.format)) throw new Error("--format must be both, pdf, or html.");

  const view = parseAirtableUrl(inputViewUrl, "inputViewURL");
  if (!view.viewId) throw new Error("inputViewURL must contain a viw... ID.");
  const recordIdField = recordIdFieldUrl ? parseAirtableUrl(recordIdFieldUrl, "recordIdFieldURL") : null;
  const outputNameField = outputNameFieldUrl ? parseAirtableUrl(outputNameFieldUrl, "outputNameFieldURL") : null;
  assertSameInputTable(view, recordIdField, "recordIdFieldURL");
  assertSameInputTable(view, outputNameField, "outputNameFieldURL");

  const fieldIds = [...new Set([recordIdField?.fieldId, outputNameField?.fieldId].filter(Boolean))];
  let records = await listViewRecords(resolvedPat.pat, view, fieldIds);
  if (recordIdField) records = records.filter(record => asText(record.fields?.[recordIdField.fieldId]));
  const limit = settings.limit == null || settings.limit === "" ? 0 : Number(settings.limit);
  if (settings.limit != null && settings.limit !== "" && (!Number.isInteger(limit) || limit < 1)) {
    throw new Error("--limit must be a positive integer.");
  }
  if (limit) records = records.slice(0, limit);

  console.log("\nBatch plan:");
  console.log(`  View:       ${view.baseId}/${view.tableId}/${view.viewId}`);
  console.log(`  Records:    ${records.length}`);
  console.log(`  Record ID:  ${recordIdField ? recordIdField.fieldId : "view record ID"}`);
  console.log(`  Template:   ${settings.template}`);
  console.log(`  Output:     ${settings.output}`);
  console.log(`  Format:     ${settings.format}`);
  console.log(`  Operation:  ${settings.dryRun ? "dry run" : "render files"}`);

  fs.mkdirSync(settings.output, { recursive: true });
  const results = [];
  for (let index = 0; index < records.length; index += 1) {
    const record = records[index];
    const sourceRecordId = recordIdField ? asText(record.fields?.[recordIdField.fieldId]) : record.id;
    const outputName = outputNameField ? asText(record.fields?.[outputNameField.fieldId]) : sourceRecordId;
    console.log(`\n${"=".repeat(72)}`);
    console.log(`[${index + 1}/${records.length}] ${record.id} -> source ${sourceRecordId}`);
    console.log("=".repeat(72));
    const child = runRecord(sourceRecordId, outputName, settings);
    const success = child.status === 0;
    results.push({ inputRecordId: record.id, sourceRecordId, success, exitCode: child.status });
    if (!success && settings.stopOnError) break;
  }

  const succeeded = results.filter(result => result.success).length;
  const failed = results.length - succeeded;
  console.log("\nBatch summary:");
  console.log(`  Attempted: ${results.length}`);
  console.log(`  Succeeded: ${succeeded}`);
  console.log(`  Failed:    ${failed}`);
  for (const result of results.filter(item => !item.success)) {
    console.log(`  FAILED ${result.inputRecordId} -> ${result.sourceRecordId} | exit ${result.exitCode}`);
  }
  if (failed) process.exitCode = 1;
}

if (require.main === module) {
  main().catch(error => {
    console.error(`\nError: ${error.message}`);
    process.exitCode = 1;
  });
}

module.exports = { parseArgs, parseAirtableUrl, inputUrlFromConfig, asText, safeStem, resolvePathSetting };
