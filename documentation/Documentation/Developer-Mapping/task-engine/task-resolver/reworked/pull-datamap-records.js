#!/usr/bin/env node

/**
 * Pull complete, read-only snapshots of selected Airtable datamap tables.
 *
 * Requirements:
 *   - Node 18+ (uses the built-in fetch API)
 *   - AIRTABLE_PAT with record-read and base-schema-read access
 *
 * Usage (PowerShell):
 *   $env:AIRTABLE_PAT = "pat..."
 *   node pull-datamap-records.js --base app... --tables "Engines,tblFields:viwFiltered"
 *
 * A JSON config file may be used instead:
 *   node pull-datamap-records.js --config datamap-pull.config.json
 *
 * Config shape:
 *   {
 *     "baseId": "app...",
 *     "tables": [
 *       "KeyMap",
 *       "https://airtable.com/app.../tbl.../viw...",
 *       { "tblFields...": "viwFiltered..." },
 *       { "table": "Fields", "view": "Missing fields" }
 *     ],
 *     "outputDir": "./datamap-records"
 *   }
 *
 * Output:
 *   <outputDir>/manifest.json
 *   <outputDir>/<table-name>--<table-id>[--<view-id>].json
 *
 * Table snapshots contain schema metadata plus each record's fields keyed both
 * by stable field ID and by current field name. No Airtable writes are made.
 */

"use strict";

const fs = require("fs");
const path = require("path");

const DATA_API_ROOT = "https://api.airtable.com/v0";
const META_API_ROOT = "https://api.airtable.com/v0/meta/bases";
const DEFAULT_OUTPUT_DIR = path.join(__dirname, "datamap-records");
const MAX_ATTEMPTS = 6;

const args = parseArgs(process.argv.slice(2));

if (args.help) {
  printHelp();
  process.exit(0);
}

main().catch((error) => {
  console.error("\nDatamap export failed:");
  console.error(error.stack || error.message || error);
  process.exit(1);
});

async function main() {
  const config = loadConfig(args);
  const pat = process.env.AIRTABLE_PAT;

  if (!pat) {
    throw new Error("AIRTABLE_PAT is not set. Keep the PAT in the environment, not in the config file.");
  }

  validateConfig(config);
  fs.mkdirSync(config.outputDir, { recursive: true });

  console.log(`Loading schema for ${config.baseId}...`);
  const schema = await fetchBaseSchema(config.baseId, pat);
  const selections = resolveTables(schema.tables, config.tables);
  const snapshots = [];

  for (const selection of selections) {
    const { table, view } = selection;
    const viewLabel = view ? ` through ${view.name} (${view.id})` : "";
    console.log(`Pulling ${table.name} (${table.id})${viewLabel}...`);
    const recordsByFieldId = await fetchAllRecords(
      config.baseId,
      table.id,
      pat,
      view?.id
    );
    const snapshot = buildTableSnapshot(
      config.baseId,
      table,
      recordsByFieldId,
      view
    );
    const viewSuffix = view ? `--${view.id}` : "";
    const fileName = `${safeFileName(table.name)}--${table.id}${viewSuffix}.json`;
    const filePath = path.join(config.outputDir, fileName);

    writeJson(filePath, snapshot);
    snapshots.push({
      tableId: table.id,
      tableName: table.name,
      viewId: view?.id || null,
      viewName: view?.name || null,
      recordCount: snapshot.recordCount,
      file: fileName,
    });

    console.log(`  ${snapshot.recordCount} records -> ${fileName}`);
  }

  const manifest = {
    schema: "archr.airtableDatamapSnapshotManifest.v1",
    exportedAt: new Date().toISOString(),
    baseId: config.baseId,
    tableCount: snapshots.length,
    totalRecordCount: snapshots.reduce((sum, table) => sum + table.recordCount, 0),
    tables: snapshots,
  };

  writeJson(path.join(config.outputDir, "manifest.json"), manifest);
  console.log(`\nDone: ${manifest.totalRecordCount} records from ${manifest.tableCount} tables.`);
  console.log(`Manifest: ${path.join(config.outputDir, "manifest.json")}`);
}

function loadConfig(cliArgs) {
  let fileConfig = {};

  if (cliArgs.config) {
    const configPath = path.resolve(cliArgs.config);
    fileConfig = JSON.parse(fs.readFileSync(configPath, "utf8").replace(/^\uFEFF/, ""));
  }

  const tables = cliArgs.tables
    ? splitTableList(cliArgs.tables)
    : normalizeTableList(fileConfig.tables);
  const urlBaseIds = [...new Set(tables.map(table => table.baseId).filter(Boolean))];
  const baseId = cliArgs.base || fileConfig.baseId || urlBaseIds[0];
  const configuredOutput = cliArgs.out || fileConfig.outputDir;

  return {
    baseId,
    tables,
    outputDir: configuredOutput ? path.resolve(configuredOutput) : DEFAULT_OUTPUT_DIR,
  };
}

function validateConfig(config) {
  if (!/^app[A-Za-z0-9]+$/.test(config.baseId || "")) {
    throw new Error("Provide a valid Airtable base ID with --base or config.baseId.");
  }

  if (!Array.isArray(config.tables) || config.tables.length === 0) {
    throw new Error("Provide at least one table name or ID with --tables or config.tables.");
  }

  const mismatchedBaseIds = [...new Set(
    config.tables
      .map(table => table.baseId)
      .filter(baseId => baseId && baseId !== config.baseId)
  )];

  if (mismatchedBaseIds.length) {
    throw new Error(
      `Airtable view URL base ID does not match ${config.baseId}: ` +
      mismatchedBaseIds.join(", ")
    );
  }
}

async function fetchBaseSchema(baseId, pat) {
  const url = `${META_API_ROOT}/${encodeURIComponent(baseId)}/tables`;
  const response = await fetchWithRetries(url, {
    headers: airtableHeaders(pat),
  });

  if (!response.ok) {
    throw await airtableError("schema", response);
  }

  const body = await response.json();
  if (!Array.isArray(body.tables)) {
    throw new Error("Airtable schema response did not contain tables[].");
  }

  return body;
}

async function fetchAllRecords(baseId, tableId, pat, viewId = null) {
  const records = [];
  let offset = null;

  do {
    const url = new URL(`${DATA_API_ROOT}/${encodeURIComponent(baseId)}/${encodeURIComponent(tableId)}`);
    url.searchParams.set("pageSize", "100");
    url.searchParams.set("returnFieldsByFieldId", "true");
    if (viewId) url.searchParams.set("view", viewId);
    if (offset) url.searchParams.set("offset", offset);

    const response = await fetchWithRetries(url, {
      headers: airtableHeaders(pat),
    });

    if (!response.ok) {
      throw await airtableError(`records for ${tableId}`, response);
    }

    const body = await response.json();
    if (!Array.isArray(body.records)) {
      throw new Error(`Airtable response for ${tableId} did not contain records[].`);
    }

    records.push(...body.records);
    offset = body.offset || null;
  } while (offset);

  return records;
}

function resolveTables(schemaTables, requestedTables) {
  const selected = [];
  const seen = new Set();

  for (const request of requestedTables) {
    const value = String(request.table).trim();
    const exactId = schemaTables.find((table) => table.id === value);
    const exactName = schemaTables.find((table) => table.name === value);
    const insensitiveMatches = schemaTables.filter(
      (table) => table.name.toLocaleLowerCase() === value.toLocaleLowerCase()
    );
    const match = exactId || exactName || (insensitiveMatches.length === 1 ? insensitiveMatches[0] : null);

    if (!match) {
      const available = schemaTables.map((table) => `${table.name} (${table.id})`).join(", ");
      throw new Error(`Table not found: ${value}\nAvailable tables: ${available}`);
    }

    const view = resolveView(match, request.view);
    const selectionKey = `${match.id}:${view?.id || "ALL"}`;

    if (!seen.has(selectionKey)) {
      selected.push({ table: match, view });
      seen.add(selectionKey);
    }
  }

  return selected;
}

function resolveView(table, requestedView) {
  if (!requestedView) return null;

  const value = String(requestedView).trim();
  const views = table.views || [];
  const exactId = views.find((view) => view.id === value);
  const exactName = views.find((view) => view.name === value);
  const insensitiveMatches = views.filter(
    (view) => view.name.toLocaleLowerCase() === value.toLocaleLowerCase()
  );
  const match = exactId || exactName || (insensitiveMatches.length === 1 ? insensitiveMatches[0] : null);

  if (!match) {
    const available = views.map((view) => `${view.name} (${view.id})`).join(", ");
    throw new Error(
      `View not found on ${table.name} (${table.id}): ${value}\n` +
      `Available views: ${available || "none"}`
    );
  }

  return match;
}

function buildTableSnapshot(baseId, table, recordsByFieldId, view = null) {
  const fields = (table.fields || []).map((field) => ({
    id: field.id,
    name: field.name,
    type: field.type,
    description: field.description || null,
    options: field.options || null,
  }));
  const fieldNamesById = new Map(fields.map((field) => [field.id, field.name]));

  const records = recordsByFieldId.map((record) => {
    const fieldsById = record.fields || {};
    const fieldsByName = {};

    for (const [fieldId, value] of Object.entries(fieldsById)) {
      fieldsByName[fieldNamesById.get(fieldId) || fieldId] = value;
    }

    return {
      id: record.id,
      createdTime: record.createdTime,
      fieldsById,
      fieldsByName,
    };
  });

  return {
    schema: "archr.airtableDatamapTableSnapshot.v1",
    exportedAt: new Date().toISOString(),
    baseId,
    table: {
      id: table.id,
      name: table.name,
      description: table.description || null,
      primaryFieldId: table.primaryFieldId,
      fields,
      views: table.views || [],
    },
    filter: view
      ? {
          type: "view",
          viewId: view.id,
          viewName: view.name,
        }
      : {
          type: "allRecords",
          viewId: null,
          viewName: null,
        },
    recordCount: records.length,
    records,
  };
}

async function fetchWithRetries(url, options) {
  let lastResponse;

  for (let attempt = 1; attempt <= MAX_ATTEMPTS; attempt += 1) {
    lastResponse = await fetch(url, options);
    if (lastResponse.ok) return lastResponse;

    const retryable = [429, 500, 502, 503, 504].includes(lastResponse.status);
    if (!retryable || attempt === MAX_ATTEMPTS) return lastResponse;

    const retryAfter = Number(lastResponse.headers.get("retry-after") || 0);
    const waitMs = retryAfter > 0 ? retryAfter * 1000 : Math.min(8000, 500 * 2 ** (attempt - 1));
    console.warn(`  Airtable returned ${lastResponse.status}; retrying in ${waitMs}ms...`);
    await sleep(waitMs);
  }

  return lastResponse;
}

async function airtableError(resource, response) {
  let detail = "";
  try {
    detail = await response.text();
  } catch {
    // The status and resource still provide a useful error if the body cannot be read.
  }

  return new Error(
    `Could not fetch ${resource}: ${response.status} ${response.statusText}${detail ? `\n${detail}` : ""}`
  );
}

function airtableHeaders(pat) {
  return {
    Authorization: `Bearer ${pat}`,
    Accept: "application/json",
  };
}

function parseArgs(argv) {
  const parsed = {
    help: argv.includes("--help") || argv.includes("-h"),
  };

  for (let index = 0; index < argv.length; index += 1) {
    const value = argv[index];
    const next = argv[index + 1];

    if (["--config", "--base", "--tables", "--out"].includes(value)) {
      if (!next || next.startsWith("--")) throw new Error(`${value} requires a value.`);
      parsed[value.slice(2)] = next;
      index += 1;
    }
  }

  return parsed;
}

function splitTableList(value) {
  return String(value)
    .split(",")
    .map((part) => part.trim())
    .filter(Boolean)
    .map(parseTableViewString);
}

function normalizeTableList(value) {
  if (Array.isArray(value)) {
    return value.flatMap(normalizeTableEntry);
  }

  if (value && typeof value === "object") {
    return Object.entries(value).map(([table, view]) => ({
      table: String(table).trim(),
      view: normalizeOptionalString(view),
      baseId: null,
    }));
  }

  if (typeof value === "string") return splitTableList(value);
  return [];
}

function normalizeTableEntry(value) {
  if (typeof value === "string") {
    return [parseTableViewString(value)];
  }

  if (!value || typeof value !== "object" || Array.isArray(value)) {
    throw new Error(`Invalid table selection: ${JSON.stringify(value)}`);
  }

  if (Object.prototype.hasOwnProperty.call(value, "table")) {
    return [{
      table: String(value.table || "").trim(),
      view: normalizeOptionalString(value.view),
      baseId: normalizeOptionalString(value.baseId),
    }];
  }

  if (Object.prototype.hasOwnProperty.call(value, "url")) {
    return [parseTableViewString(value.url)];
  }

  const entries = Object.entries(value);
  if (entries.length === 0) {
    throw new Error("A table-to-view mapping cannot be empty.");
  }

  return entries.map(([table, view]) => ({
    table: String(table).trim(),
    view: normalizeOptionalString(view),
    baseId: null,
  }));
}

function parseTableViewString(value) {
  const trimmed = String(value).trim();
  const parsedUrl = parseAirtableViewUrl(trimmed);

  if (parsedUrl) return parsedUrl;

  const match = trimmed.match(/^(.*):(viw[A-Za-z0-9]+)$/);

  if (!match) {
    return { table: trimmed, view: null, baseId: null };
  }

  return {
    table: match[1].trim(),
    view: match[2],
    baseId: null,
  };
}

function parseAirtableViewUrl(value) {
  if (!/^https?:\/\//i.test(value)) return null;

  let url;
  try {
    url = new URL(value);
  } catch {
    throw new Error(`Invalid URL in table selection: ${value}`);
  }

  if (!/(^|\.)airtable\.com$/i.test(url.hostname)) {
    throw new Error(`Expected an airtable.com view URL, received: ${value}`);
  }

  const segments = url.pathname.split("/").filter(Boolean);
  const baseId = segments.find(segment => /^app[A-Za-z0-9]+$/.test(segment));
  const table = segments.find(segment => /^tbl[A-Za-z0-9]+$/.test(segment));
  const view = segments.find(segment => /^viw[A-Za-z0-9]+$/.test(segment));

  if (!baseId || !table || !view) {
    throw new Error(
      "Airtable URL must contain app..., tbl..., and viw... path segments: " +
      value
    );
  }

  return { baseId, table, view };
}

function normalizeOptionalString(value) {
  if (value === null || value === undefined || value === "") return null;
  return String(value).trim() || null;
}

function safeFileName(value) {
  const cleaned = String(value)
    .normalize("NFKD")
    // Keep exported filenames portable across Windows, shells, ZIP tools, and
    // downstream scripts. Airtable table names may contain decorative emoji
    // (for example, "🔹Fields"), but the table's original name remains in the
    // snapshot and manifest metadata.
    .replace(/[^\x00-\x7F]/g, "")
    .replace(/[<>:"/\\|?*\u0000-\u001F]/g, "-")
    .replace(/\s+/g, "-")
    .replace(/-+/g, "-")
    .replace(/^[.-]+|[.-]+$/g, "")
    .slice(0, 100);

  return cleaned || "table";
}

function writeJson(filePath, value) {
  // Recheck the parent at the point of use. This also makes writeJson safe if
  // it is reused later with a nested output path.
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, `${JSON.stringify(value, null, 2)}\n`, "utf8");
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function printHelp() {
  console.log(`
Pull all records from selected Airtable datamap tables.

Usage:
  node pull-datamap-records.js --base app... --tables "Table A,tbl...:viw..." [--out path]
  node pull-datamap-records.js --tables "https://airtable.com/app.../tbl.../viw..."
  node pull-datamap-records.js --config config.json [--out path]

Options:
  --base     Airtable base ID
  --tables   Comma-separated names, IDs, tbl:viw pairs, or Airtable view URLs
  --config   JSON file containing baseId, tables, and optional outputDir
  --out      Override the output directory
  --help     Show this help

Environment:
  AIRTABLE_PAT   Required Airtable personal access token
`);
}
