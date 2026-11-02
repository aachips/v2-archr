/************************************************************
ARCHR Datamap — finalize resolver wiring

Run in Airtable's Script Extension inside the Datamap base.

This idempotent script:
- completes the conflicting-completion field configuration used by
  BIND-SX-005;
- adds the LINKED canonicalKeyStatus choice when necessary;
- marks mappings LINKED only when they have exactly one canonicalPath;
- links the Conflict Create setup to the canonical
  create.tables.toTable.newRecords... keyMap hierarchy.

It does not delete the two blank keyMap rows or the obsolete text
columns on tableConfigSetups. It also does not materialize includeKeys
or renderer output; materialize-conflict-table-renderer.js handles the
short-path renderer after these canonical keyMap links exist.

All changes are previewed and require confirmation. Conflicting values
are skipped and reported.
************************************************************/

const CONFIG = {
    tables: {
        mappings: "tblEqe4un7Bq7BJyc",
        fieldConfigs: "tbl1ezkDBeOuDebAq",
        tableConfigs: "tblJ6qDeQoYKObg13",
        keyMap: "tbl7mjYmTYjonvw8k",
    },
    fields: {
        mappings: {
            bindingId: "fld0xYUcMyx4c9kao",
            canonicalPath: "fldFFjSE7V0QKCb9H",
            canonicalStatus: "fld51rJPzXYKY4BXY",
        },
        fieldConfigs: {
            name: "fldZyewizc3jIntUd",
            fieldLink: "fldCbU88vE6097mDa",
            tableConfig: "fld83jpMiTZvYFwWI",
            keyMap: "fldDW741PFZVE0fzQ",
            writeMode: "fldJekGTjjAfpVtSJ",
            sourceOrValue: "fldOX3bdCQv0gzuEy",
        },
        tableConfigs: {
            keyMap: "fldiZ2o1KFu67IYl9",
            includeKeys: "fldNJBoKNO0WfLPyB",
            resolverConfig: "fld3fLgRjBSgiR70h",
            output: "fldLwOw9I1f7jmVQw",
        },
        keyMap: {
            jsonKey: "fldJyhq9UrXiltttm",
            parent: "fldX7qPa6eF2FlH61",
        },
    },
    records: {
        conflictFieldConfig: "recMGlrMnZeyzcBga",
        conflictPhysicalField: "recjtWZ75KVgNfHCm",
        conflictSetup: "recMmCxZ1pQPmnMvM",
    },
};

const CONFLICT_FIELD_EXPECTATION = {
    name: "conflictingCompletionId",
    writeMode: "replace",
    sourceOrValue: "source",
};

// The Create engine supplies the `create` root. The table setup owns
// the concrete table/new-record branch and field config structure.
const CONFLICT_CREATE_KEY_PATHS = [
    "create.tables",
    "create.tables.toTable",
    "create.tables.toTable.tableId",
    "create.tables.toTable.newRecords",
    "create.tables.toTable.newRecords.record",
    "create.tables.toTable.newRecords.record.toFields",
    "create.tables.toTable.newRecords.record.toFields.field",
    "create.tables.toTable.newRecords.record.toFields.field.fieldId",
    "create.tables.toTable.newRecords.record.toFields.field.fieldType",
    "create.tables.toTable.newRecords.record.toFields.field.writeMode",
    "create.tables.toTable.newRecords.record.toFields.field.writeSource",
    "create.tables.toTable.newRecords.record.toFields.field.writeValue",
];

const report = {
    planned: [],
    already: [],
    failed: [],
    informational: [],
    applied: [],
};

function add(bucket, operation, target, detail) {
    report[bucket].push({ operation, target, detail });
}

function getField(table, idOrName) {
    return table.fields.find(
        field => field.id === idOrName || field.name === idOrName
    ) || null;
}

function linkIds(value) {
    return Array.isArray(value)
        ? value.map(item => typeof item === "string" ? item : item?.id).filter(Boolean)
        : [];
}

function sameIds(left, right) {
    return JSON.stringify([...new Set(left)].sort()) ===
        JSON.stringify([...new Set(right)].sort());
}

function mergeUpdate(updates, recordId, fields) {
    let update = updates.find(item => item.id === recordId);
    if (!update) {
        update = { id: recordId, fields: {} };
        updates.push(update);
    }
    Object.assign(update.fields, fields);
}

function planScalar(fields, fieldId, current, expected, operation, target) {
    if (current === expected) {
        add("already", operation, target, expected);
        return;
    }
    if (current) {
        add("failed", operation, target, `conflicting value “${current}”; expected “${expected}”`);
        return;
    }
    fields[fieldId] = expected;
    add("planned", operation, target, `${current || "blank"} → ${expected}`);
}

async function updateInChunks(table, updates) {
    for (let index = 0; index < updates.length; index += 50) {
        await table.updateRecordsAsync(updates.slice(index, index + 50));
    }
}

async function main() {
    output.markdown("# Finalize Datamap resolver wiring");

    const mappings = base.getTable(CONFIG.tables.mappings);
    const fieldConfigs = base.getTable(CONFIG.tables.fieldConfigs);
    const tableConfigs = base.getTable(CONFIG.tables.tableConfigs);
    const keyMap = base.getTable(CONFIG.tables.keyMap);

    const mf = CONFIG.fields.mappings;
    const ff = CONFIG.fields.fieldConfigs;
    const tf = CONFIG.fields.tableConfigs;
    const kf = CONFIG.fields.keyMap;

    const statusField = getField(mappings, mf.canonicalStatus);
    if (!statusField || statusField.type !== "singleSelect") {
        throw new Error("canonicalKeyStatus is missing or is not a single select. No changes were made.");
    }

    const linkedChoiceExists = (statusField.options?.choices || [])
        .some(choice => choice.name === "LINKED");
    if (!linkedChoiceExists) {
        if (typeof statusField.updateOptionsAsync !== "function") {
            add(
                "failed",
                "canonicalKeyStatus schema",
                statusField.id,
                "LINKED choice is absent and this Airtable runtime cannot update field options"
            );
        } else {
            add("planned", "canonicalKeyStatus schema", statusField.id, "add LINKED choice");
        }
    } else {
        add("already", "canonicalKeyStatus schema", statusField.id, "LINKED choice exists");
    }

    const [mappingQuery, fieldConfigQuery, tableConfigQuery, keyMapQuery] =
        await Promise.all([
            mappings.selectRecordsAsync({
                fields: [mf.bindingId, mf.canonicalPath, mf.canonicalStatus],
            }),
            fieldConfigs.selectRecordsAsync({
                fields: [
                    ff.name,
                    ff.fieldLink,
                    ff.tableConfig,
                    ff.keyMap,
                    ff.writeMode,
                    ff.sourceOrValue,
                ],
            }),
            tableConfigs.selectRecordsAsync({
                fields: [tf.keyMap, tf.includeKeys, tf.resolverConfig, tf.output],
            }),
            keyMap.selectRecordsAsync({ fields: [kf.jsonKey, kf.parent] }),
        ]);

    const mappingUpdates = [];
    for (const record of mappingQuery.records) {
        const bindingId = record.getCellValueAsString(mf.bindingId).trim() || record.id;
        const canonicalIds = linkIds(record.getCellValue(mf.canonicalPath));
        const currentStatus = record.getCellValueAsString(mf.canonicalStatus).trim();

        if (canonicalIds.length !== 1) {
            add(
                "failed",
                "canonical status",
                bindingId,
                `expected exactly one canonicalPath; found ${canonicalIds.length}`
            );
            continue;
        }
        if (currentStatus === "LINKED") {
            add("already", "canonical status", bindingId, "LINKED");
        } else if (!currentStatus || currentStatus === "MISSING_KEYMAP_ROW") {
            mergeUpdate(mappingUpdates, record.id, {
                [mf.canonicalStatus]: { name: "LINKED" },
            });
            add("planned", "canonical status", bindingId, `${currentStatus || "blank"} → LINKED`);
        } else {
            add(
                "failed",
                "canonical status",
                bindingId,
                `conflicting status “${currentStatus}”`
            );
        }
    }

    const fieldConfigUpdates = [];
    const conflictField = fieldConfigQuery.getRecord(CONFIG.records.conflictFieldConfig);
    if (!conflictField) {
        add("failed", "conflict field config", CONFIG.records.conflictFieldConfig, "record missing");
    } else {
        const physicalLinks = linkIds(conflictField.getCellValue(ff.fieldLink));
        const setupLinks = linkIds(conflictField.getCellValue(ff.tableConfig));
        if (!sameIds(physicalLinks, [CONFIG.records.conflictPhysicalField])) {
            add(
                "failed",
                "conflict field config",
                conflictField.id,
                `physical field links are ${physicalLinks.join(", ") || "blank"}`
            );
        } else if (!setupLinks.includes(CONFIG.records.conflictSetup)) {
            add(
                "failed",
                "conflict field config",
                conflictField.id,
                "not linked to the promoted Conflict Create setup"
            );
        } else {
            const fields = {};
            planScalar(
                fields,
                ff.name,
                conflictField.getCellValueAsString(ff.name).trim(),
                CONFLICT_FIELD_EXPECTATION.name,
                "conflict field Name",
                conflictField.id
            );

            const currentMode = conflictField.getCellValueAsString(ff.writeMode).trim();
            if (currentMode === CONFLICT_FIELD_EXPECTATION.writeMode) {
                add("already", "conflict field writeMode", conflictField.id, currentMode);
            } else if (!currentMode) {
                fields[ff.writeMode] = { name: CONFLICT_FIELD_EXPECTATION.writeMode };
                add("planned", "conflict field writeMode", conflictField.id, "blank → replace");
            } else {
                add("failed", "conflict field writeMode", conflictField.id, `conflicting value “${currentMode}”`);
            }

            const currentSource = conflictField.getCellValueAsString(ff.sourceOrValue).trim();
            if (currentSource === CONFLICT_FIELD_EXPECTATION.sourceOrValue) {
                add("already", "conflict field source/value", conflictField.id, currentSource);
            } else if (!currentSource || currentSource === "value") {
                fields[ff.sourceOrValue] = { name: CONFLICT_FIELD_EXPECTATION.sourceOrValue };
                add("planned", "conflict field source/value", conflictField.id, `${currentSource || "blank"} → source`);
            } else {
                add("failed", "conflict field source/value", conflictField.id, `conflicting value “${currentSource}”`);
            }

            if (Object.keys(fields).length) {
                fieldConfigUpdates.push({ id: conflictField.id, fields });
            }
        }
    }

    const keyMapByPath = new Map();
    for (const record of keyMapQuery.records) {
        const path = record.getCellValueAsString(kf.jsonKey).trim();
        if (!path) continue;
        if (keyMapByPath.has(path)) {
            add("failed", "keyMap lookup", path, "duplicate json_key");
        } else {
            keyMapByPath.set(path, record);
        }
    }

    const requiredKeyRecords = [];
    for (const path of CONFLICT_CREATE_KEY_PATHS) {
        const record = keyMapByPath.get(path);
        if (!record) {
            add("failed", "Conflict Create keyMap", path, "keyMap record missing");
        } else {
            requiredKeyRecords.push(record);
        }
    }

    const tableConfigUpdates = [];
    const conflictSetup = tableConfigQuery.getRecord(CONFIG.records.conflictSetup);
    if (!conflictSetup) {
        add("failed", "Conflict Create setup", CONFIG.records.conflictSetup, "record missing");
    } else if (requiredKeyRecords.length === CONFLICT_CREATE_KEY_PATHS.length) {
        const expectedIds = requiredKeyRecords.map(record => record.id);
        const currentIds = linkIds(conflictSetup.getCellValue(tf.keyMap));
        if (sameIds(currentIds, expectedIds)) {
            add("already", "Conflict Create keyMap", conflictSetup.id, `${expectedIds.length} canonical links`);
        } else if (!currentIds.length) {
            tableConfigUpdates.push({
                id: conflictSetup.id,
                fields: {
                    [tf.keyMap]: expectedIds.map(id => ({ id })),
                },
            });
            add("planned", "Conflict Create keyMap", conflictSetup.id, `link ${expectedIds.length} canonical paths`);
        } else {
            add(
                "failed",
                "Conflict Create keyMap",
                conflictSetup.id,
                `conflicting existing links: ${currentIds.join(", ")}`
            );
        }

        const includeKeys = conflictSetup.getCellValue(tf.includeKeys) || [];
        const resolverConfig = conflictSetup.getCellValueAsString(tf.resolverConfig).trim();
        const renderedOutput = conflictSetup.getCellValueAsString(tf.output).trim();
        add(
            "informational",
            "legacy config renderer",
            conflictSetup.id,
            `includeKeys=${includeKeys.length}, ResolverConfigSetup=${resolverConfig ? "set" : "blank"}, ` +
            `output=${renderedOutput ? "set" : "blank"}; materialized separately from canonical keyMap wiring`
        );
    }

    add(
        "informational",
        "blank keyMap cleanup",
        "recJplOVpqyV5QxzS / recWZ1brOwKThYdC1",
        "not deleted by this script"
    );
    add(
        "informational",
        "obsolete tableConfig columns",
        "producerFieldConfig / consumerFieldConfig",
        "not deleted by this script"
    );

    output.markdown("## Planned changes");
    output.table(report.planned);
    output.markdown("## Already complete");
    output.table(report.already);
    output.markdown("## Skipped / failed");
    output.table(report.failed);
    output.markdown("## Informational");
    output.table(report.informational);

    const updateCount = mappingUpdates.length + fieldConfigUpdates.length +
        tableConfigUpdates.length;
    const schemaCount = linkedChoiceExists ? 0 : 1;
    if (!updateCount && !schemaCount) {
        output.markdown("No changes are required.");
        return;
    }

    const action = await input.buttonsAsync(
        `Apply ${schemaCount} schema change(s) and ${updateCount} record update(s)?`,
        [
            { label: "Apply finalization", value: "apply" },
            { label: "Report only", value: "report" },
        ]
    );
    if (action !== "apply") {
        output.markdown("Report-only run complete. No changes were made.");
        return;
    }

    if (!linkedChoiceExists) {
        try {
            await statusField.updateOptionsAsync({
                choices: [
                    ...(statusField.options?.choices || []),
                    { name: "LINKED", color: "greenBright" },
                ],
            });
            add("applied", "schema field options", statusField.id, "added LINKED");
        } catch (error) {
            add("failed", "schema field options", statusField.id, error.message);
            output.markdown("## Applied");
            output.table(report.applied);
            output.markdown("## Final failures");
            output.table(report.failed);
            throw new Error("Could not add the LINKED select choice; mapping status updates were not attempted.");
        }
    }

    for (const [table, updates] of [
        [mappings, mappingUpdates],
        [fieldConfigs, fieldConfigUpdates],
        [tableConfigs, tableConfigUpdates],
    ]) {
        if (!updates.length) continue;
        try {
            await updateInChunks(table, updates);
            add("applied", "updated records", table.name, `${updates.length} record(s)`);
        } catch (error) {
            add("failed", "updated records", table.name, error.message);
        }
    }

    output.markdown("## Applied");
    output.table(report.applied);
    output.markdown("## Final failures");
    output.table(report.failed);
}

await main();
