/*
 * Airtable Scripting Extension: populate the Engine controller base.
 *
 * Run this inside the Engine base, choose engine-base.seed.json, and select
 * whether to create missing records only or upsert existing records.
 */

"use strict";

output.markdown("# Populate Engine controller base");

const seedFile = await input.fileAsync("Choose engine-base.seed.json");

async function readUploadedJson(fileResult) {
  if (fileResult && fileResult.parsedContents !== undefined) {
    return typeof fileResult.parsedContents === "string"
      ? JSON.parse(fileResult.parsedContents)
      : fileResult.parsedContents;
  }

  const uploadedFile = fileResult?.file || fileResult;
  if (uploadedFile && typeof uploadedFile.text === "function") {
    return JSON.parse(await uploadedFile.text());
  }

  throw new Error(
    "Airtable did not return parsed JSON or a readable uploaded File."
  );
}

const seed = await readUploadedJson(seedFile);

if (seed.schema !== "engineBase.seed.v1") {
  throw new Error(`Unsupported seed schema: ${seed.schema || "(missing)"}`);
}

const writeMode = await input.buttonsAsync("How should existing keys be handled?", [
  { label: "Create missing only", value: "createMissing" },
  { label: "Upsert existing", value: "upsert" }
]);

const availableTableNames = new Set(base.tables.map(table => table.name));
const missingTableNames = (seed.tables || [])
  .map(tableSeed => tableSeed.tableName)
  .filter(tableName => !availableTableNames.has(tableName));

if (missingTableNames.length) {
  throw new Error(
    "Create the missing Engine tables before loading this seed: " +
      missingTableNames.join(", ")
  );
}

function chunk(items, size) {
  const groups = [];
  for (let index = 0; index < items.length; index += size) {
    groups.push(items.slice(index, index + size));
  }
  return groups;
}

function hasOwn(object, key) {
  return Object.prototype.hasOwnProperty.call(object, key);
}

function writableValue(field, value) {
  if (value === undefined || value === null) return null;

  if (field.type === "singleSelect") {
    return value && typeof value === "object" && value.name
      ? value
      : { name: String(value) };
  }

  if (field.type === "multipleSelects") {
    const values = Array.isArray(value) ? value : [value];
    return values
      .filter(item => item !== undefined && item !== null && item !== "")
      .map(item =>
        item && typeof item === "object" && item.name
          ? item
          : { name: String(item) }
      );
  }

  if (field.type === "checkbox") return Boolean(value);
  if (field.type === "number" || field.type === "currency" || field.type === "percent") {
    const number = Number(value);
    return Number.isFinite(number) ? number : null;
  }

  return value;
}

function prepareFields(table, record) {
  const fields = {};
  const fieldsByName = new Map(table.fields.map(field => [field.name, field]));

  for (const [fieldName, value] of Object.entries(record)) {
    const field = fieldsByName.get(fieldName);
    if (!field) {
      throw new Error(`Table "${table.name}" is missing field "${fieldName}".`);
    }
    fields[fieldName] = writableValue(field, value);
  }

  return fields;
}

async function processTable(tableSeed) {
  const table = base.getTable(tableSeed.tableId || tableSeed.tableName);
  const primaryField = table.getField(tableSeed.primaryField);
  const query = await table.selectRecordsAsync({ fields: [primaryField] });
  const existingByKey = new Map(
    query.records
      .map(record => [
        record.getCellValueAsString(primaryField).trim(),
        record.id
      ])
      .filter(([key]) => key)
  );

  const creates = [];
  const updates = [];
  let skipped = 0;

  for (const record of tableSeed.records || []) {
    const key = String(record[tableSeed.primaryField] || "").trim();
    if (!key) {
      throw new Error(
        `A ${tableSeed.tableName} seed record is missing ` +
          `"${tableSeed.primaryField}".`
      );
    }

    const existingId = existingByKey.get(key);
    if (existingId && writeMode === "createMissing") {
      skipped += 1;
      continue;
    }

    const fields = prepareFields(table, record);
    if (existingId) {
      updates.push({ id: existingId, fields });
    } else {
      creates.push({ fields });
    }
  }

  for (const batch of chunk(creates, 50)) {
    await table.createRecordsAsync(batch);
  }
  for (const batch of chunk(updates, 50)) {
    await table.updateRecordsAsync(batch);
  }

  return {
    Table: table.name,
    Created: creates.length,
    Updated: updates.length,
    Skipped: skipped
  };
}

const results = [];
for (const tableSeed of seed.tables || []) {
  output.text(`Processing ${tableSeed.tableName}...`);
  results.push(await processTable(tableSeed));
}

output.markdown("## Engine base population complete");
output.table(results);
output.markdown(
  `Seed generated: \`${seed.generatedAt}\`\n\n` +
    `Target base: **${seed.targetBaseName || seed.targetBaseId}**`
);
