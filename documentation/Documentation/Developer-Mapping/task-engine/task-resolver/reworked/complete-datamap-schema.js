/************************************************************
ARCHR Datamap — complete resolver binding/keyMap schema

Run in Airtable's Script Extension inside the Datamap base.

This idempotent script:
- creates producerFieldConfig and consumerFieldConfig on
  stepJSONMappings as links to fieldConfigSetup;
- creates the missing Compare eventDate field configuration;
- populates the 4 producer and 18 consumer field-config links;
- creates conflictWorkflow.comparison.suggestedValues;
- repairs its three child parent links and keyMap value types;
- completes the surviving People merge metadata;
- sets BIND-SX-005.consumerStep and Conflict setup step to 4.

It never deletes records. Conflicting existing values are skipped and
reported. Schema and record changes require confirmation.
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
            consumerStep: "fldWvVgOI1P6FFxIi",
            canonicalStatus: "fld51rJPzXYKY4BXY",
        },
        fieldConfigs: {
            primary: "fldHyHexyhEMlBTyz",
            group: "fldnjiwHEYCLJv7M2",
            name: "fldZyewizc3jIntUd",
            eventField: "fldkkmhGTa8J2Tw5J",
            fieldLink: "fldCbU88vE6097mDa",
            tableConfig: "fld83jpMiTZvYFwWI",
            keyMap: "fldDW741PFZVE0fzQ",
            includeKeys: "fldMPAn4vrRQ0wn9C",
            writeMode: "fldJekGTjjAfpVtSJ",
            sourceOrValue: "fldOX3bdCQv0gzuEy",
            writeValue: "fldgPC7JeePGjn47L",
            isMergeable: "fld3Wy6ii9zGS9sPC",
            mergeableText: "fldvaCRTdwSpr03xZ",
        },
        tableConfigs: {
            step: "fldV0KBpa1ZzJPir6",
        },
        keyMap: {
            jsonKey: "fldJyhq9UrXiltttm",
            valueType: "fldsjuPngKqAU5nB1",
            parent: "fldX7qPa6eF2FlH61",
        },
    },
    records: {
        compareSetup: "recMiPQd171ofOmk0",
        compareTemplate: "recXu4TxEhNleGROC",
        eventDateField: "recLSC2Rswsuey9Bz",
        peopleMerge: "recbdgUxugXh7aUut",
        conflictSetup: "recMmCxZ1pQPmnMvM",
    },
};

const FIELD_BINDINGS = [
    ["BIND-CTX-003", null, "recHHbUj1wlyzTsmN"],
    ["BIND-CTX-006", null, "reclqwbyJgT0exXwe"],
    ["BIND-CTX-007", null, "$COMPARE_DATE"],
    ["BIND-CTX-008", null, "recWaBCfHwh8hkFBw"],
    ["BIND-CTX-009", null, "rec7yvjRil2hiPULy"],
    ["BIND-CTX-010", null, "recLa2h6Wylk6Yj9u"],
    ["BIND-CTX-011", null, "rec5Rm0WytIwIbC86"],
    ["BIND-S1-001", null, "rechVQa6IrrCGaVOE"],
    ["BIND-S1-002", null, "rece1zbS08gKRYtAA"],
    ["BIND-S1-003", null, "recFeFXZkQHWMjyDF"],
    ["BIND-S1-004", null, "recOBscPHbKJkLSHB"],
    ["BIND-S1-005", null, "recELVdBC9TnDHk2l"],
    ["BIND-S1-006", null, "recNhpy05IrR6wTtq"],
    ["BIND-S3-001", "recLa2h6Wylk6Yj9u", null],
    ["BIND-S3-002", "recLa2h6Wylk6Yj9u", null],
    ["BIND-SX-002", "$COMPARE_DATE", "recyNGKWTyv6WnaGa"],
    ["BIND-SX-003", "recXu4TxEhNleGROC", "recbdgUxugXh7aUut"],
    ["BIND-SX-005", null, "recMGlrMnZeyzcBga"],
    ["BIND-S4-001", null, "rec328IM0rztMtHNh"],
    ["BIND-S4-002", null, "rec77lzABVvqSaurr"],
];

const COMPARE_DATE_LABEL =
    "🟡compare.eventFields🟡 | 🟢🔷[◼️Project Event V2]🔹(📅 ) eventDate";

const report = {
    planned: [],
    already: [],
    failed: [],
    applied: [],
    remaining: [],
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

function validateLinkField(field, linkedTableId, name) {
    if (!field) return;
    if (
        field.type !== "multipleRecordLinks" ||
        field.options?.linkedTableId !== linkedTableId
    ) {
        throw new Error(
            `${name} exists but is not a link to ${linkedTableId}. ` +
            "No changes were made."
        );
    }
}

async function updateInChunks(table, updates) {
    for (let index = 0; index < updates.length; index += 50) {
        await table.updateRecordsAsync(updates.slice(index, index + 50));
    }
}

async function main() {
    output.markdown("# Complete Datamap resolver schema");

    const mappings = base.getTable(CONFIG.tables.mappings);
    const fieldConfigs = base.getTable(CONFIG.tables.fieldConfigs);
    const tableConfigs = base.getTable(CONFIG.tables.tableConfigs);
    const keyMap = base.getTable(CONFIG.tables.keyMap);

    let producerField = getField(mappings, "producerFieldConfig");
    let consumerField = getField(mappings, "consumerFieldConfig");
    validateLinkField(producerField, fieldConfigs.id, "producerFieldConfig");
    validateLinkField(consumerField, fieldConfigs.id, "consumerFieldConfig");

    if (!producerField) {
        add("planned", "create schema field", "producerFieldConfig", "link to fieldConfigSetup");
    } else {
        add("already", "schema field", producerField.id, "producerFieldConfig is valid");
    }
    if (!consumerField) {
        add("planned", "create schema field", "consumerFieldConfig", "link to fieldConfigSetup");
    } else {
        add("already", "schema field", consumerField.id, "consumerFieldConfig is valid");
    }

    const initialAction = await input.buttonsAsync(
        "Inspect/create missing schema records and prepare all remaining updates?",
        [
            { label: "Continue", value: "continue" },
            { label: "Cancel", value: "cancel" },
        ]
    );
    if (initialAction !== "continue") return;

    if (!producerField) {
        const id = await mappings.createFieldAsync(
            "producerFieldConfig",
            "multipleRecordLinks",
            { linkedTableId: fieldConfigs.id }
        );
        producerField = getField(mappings, id) || { id };
        add("applied", "created schema field", id, "producerFieldConfig");
    }
    if (!consumerField) {
        const id = await mappings.createFieldAsync(
            "consumerFieldConfig",
            "multipleRecordLinks",
            { linkedTableId: fieldConfigs.id }
        );
        consumerField = getField(mappings, id) || { id };
        add("applied", "created schema field", id, "consumerFieldConfig");
    }

    const ff = CONFIG.fields.fieldConfigs;
    const kf = CONFIG.fields.keyMap;
    const [fieldConfigQuery, keyMapQuery] = await Promise.all([
        fieldConfigs.selectRecordsAsync({
            fields: [
                ff.primary,
                ff.group,
                ff.name,
                ff.eventField,
                ff.fieldLink,
                ff.tableConfig,
                ff.keyMap,
                ff.includeKeys,
                ff.writeMode,
                ff.sourceOrValue,
                ff.writeValue,
                ff.isMergeable,
                ff.mergeableText,
            ],
        }),
        keyMap.selectRecordsAsync({ fields: [kf.jsonKey, kf.valueType, kf.parent] }),
    ]);
    const fieldConfigById = new Map(
        fieldConfigQuery.records.map(record => [record.id, record])
    );
    const keyMapByPath = new Map();
    for (const record of keyMapQuery.records) {
        const path = record.getCellValueAsString(kf.jsonKey).trim();
        if (path) {
            if (keyMapByPath.has(path)) {
                add("failed", "keyMap lookup", path, "duplicate json_key");
            } else {
                keyMapByPath.set(path, record);
            }
        }
    }

    // Create/reuse the Compare eventDate field configuration.
    let compareDateMatches = fieldConfigQuery.records.filter(
        record => record.getCellValueAsString(ff.primary) === COMPARE_DATE_LABEL
    );
    let compareDateId = null;
    if (compareDateMatches.length > 1) {
        add("failed", "Compare date config", COMPARE_DATE_LABEL, "duplicate records");
    } else if (compareDateMatches.length === 1) {
        compareDateId = compareDateMatches[0].id;
        add("already", "Compare date config", compareDateId, "record exists");
    } else {
        const template = fieldConfigById.get(CONFIG.records.compareTemplate);
        if (!template) {
            add("failed", "Compare date config", CONFIG.records.compareTemplate, "template missing");
        } else {
            compareDateId = await fieldConfigs.createRecordAsync({
                [ff.group]: { name: "compare.eventFields" },
                [ff.name]: "completedDate",
                [ff.eventField]: "completedDate",
                [ff.fieldLink]: [{ id: CONFIG.records.eventDateField }],
                [ff.tableConfig]: [{ id: CONFIG.records.compareSetup }],
                [ff.keyMap]: linkIds(template.getCellValue(ff.keyMap)).map(id => ({ id })),
                [ff.includeKeys]: [
                    "field.fieldId",
                    "field.fieldType",
                    "field.writeMode",
                    "field.mergeable",
                    "fields.field",
                ].map(name => ({ name })),
                [ff.sourceOrValue]: { name: "source" },
                [ff.writeValue]: { name: "_VALUE_" },
                [ff.isMergeable]: true,
                [ff.mergeableText]: "true",
            });
            add("applied", "created Compare date config", compareDateId, COMPARE_DATE_LABEL);
        }
    }

    // Create/reuse the missing suggestedValues keyMap parent.
    const comparison = keyMapByPath.get("conflictWorkflow.comparison");
    let suggestedValues = keyMapByPath.get(
        "conflictWorkflow.comparison.suggestedValues"
    );
    if (!comparison) {
        add("failed", "keyMap parent", "conflictWorkflow.comparison", "record missing");
    } else if (!suggestedValues) {
        const id = await keyMap.createRecordAsync({
            [kf.jsonKey]: "conflictWorkflow.comparison.suggestedValues",
            [kf.valueType]: { name: "object" },
            [kf.parent]: [{ id: comparison.id }],
        });
        suggestedValues = { id };
        add("applied", "created keyMap parent", id, "conflictWorkflow.comparison.suggestedValues");
    } else {
        add("already", "keyMap parent", suggestedValues.id, "suggestedValues exists");
    }

    if (!compareDateId || !suggestedValues) {
        output.markdown("## Applied before blocker");
        output.table(report.applied);
        output.markdown("## Blocking failures");
        output.table(report.failed);
        throw new Error("Required schema records could not be resolved; dependent updates were skipped.");
    }

    // Refresh queries after schema/record creation.
    const [mappingQuery, refreshedFieldConfigs, refreshedKeyMap, tableConfigQuery] =
        await Promise.all([
            mappings.selectRecordsAsync({
                fields: [
                    CONFIG.fields.mappings.bindingId,
                    CONFIG.fields.mappings.consumerStep,
                    producerField.id,
                    consumerField.id,
                ],
            }),
            fieldConfigs.selectRecordsAsync({
                fields: [
                    ff.name,
                    ff.eventField,
                    ff.keyMap,
                    ff.writeMode,
                    ff.isMergeable,
                    ff.mergeableText,
                ],
            }),
            keyMap.selectRecordsAsync({ fields: [kf.jsonKey, kf.valueType, kf.parent] }),
            tableConfigs.selectRecordsAsync({ fields: [CONFIG.fields.tableConfigs.step] }),
        ]);

    const mappingByBinding = new Map();
    for (const record of mappingQuery.records) {
        const bindingId = record
            .getCellValueAsString(CONFIG.fields.mappings.bindingId)
            .trim();
        if (bindingId) mappingByBinding.set(bindingId, record);
    }
    const currentFieldConfigIds = new Set(
        refreshedFieldConfigs.records.map(record => record.id)
    );
    const mappingUpdates = [];

    for (const [bindingId, producerRaw, consumerRaw] of FIELD_BINDINGS) {
        const record = mappingByBinding.get(bindingId);
        if (!record) {
            add("failed", "field binding", bindingId, "mapping record missing");
            continue;
        }
        const producerId = producerRaw === "$COMPARE_DATE" ? compareDateId : producerRaw;
        const consumerId = consumerRaw === "$COMPARE_DATE" ? compareDateId : consumerRaw;
        const fields = {};

        for (const [side, fieldId, expectedId] of [
            ["producer", producerField.id, producerId],
            ["consumer", consumerField.id, consumerId],
        ]) {
            if (!expectedId) continue;
            if (!currentFieldConfigIds.has(expectedId)) {
                add("failed", `${side} field binding`, bindingId, `fieldConfig ${expectedId} missing`);
                continue;
            }
            const current = linkIds(record.getCellValue(fieldId));
            if (sameIds(current, [expectedId])) {
                add("already", `${side} field binding`, bindingId, expectedId);
            } else if (current.length) {
                add(
                    "failed",
                    `${side} field binding`,
                    bindingId,
                    `conflicting links ${current.join(", ")}; expected ${expectedId}`
                );
            } else {
                fields[fieldId] = [{ id: expectedId }];
                add("planned", `${side} field binding`, bindingId, expectedId);
            }
        }
        if (Object.keys(fields).length) mappingUpdates.push({ id: record.id, fields });
    }

    // Scalar correction for conflict binding.
    const conflictBinding = mappingByBinding.get("BIND-SX-005");
    if (conflictBinding) {
        const fieldId = CONFIG.fields.mappings.consumerStep;
        const current = conflictBinding.getCellValueAsString(fieldId);
        if (current === "Step 4") {
            add("already", "consumerStep", "BIND-SX-005", "Step 4");
        } else {
            const update = mappingUpdates.find(item => item.id === conflictBinding.id) ||
                { id: conflictBinding.id, fields: {} };
            update.fields[fieldId] = { name: "Step 4" };
            if (!mappingUpdates.includes(update)) mappingUpdates.push(update);
            add("planned", "consumerStep", "BIND-SX-005", `${current || "blank"} → Step 4`);
        }
    }

    const refreshedKeyMapByPath = new Map();
    for (const record of refreshedKeyMap.records) {
        const path = record.getCellValueAsString(kf.jsonKey).trim();
        if (path) refreshedKeyMapByPath.set(path, record);
    }
    const keyMapUpdates = [];
    const keyMapExpectations = [
        ["conflictWorkflow", null, "object"],
        ["conflictWorkflow.comparison.suggestedValues", "conflictWorkflow.comparison", "object"],
        ["conflictWorkflow.comparison.suggestedValues.combinedPeople", "conflictWorkflow.comparison.suggestedValues", "array"],
        ["conflictWorkflow.comparison.suggestedValues.earlierCompletedDate", "conflictWorkflow.comparison.suggestedValues", "string"],
        ["conflictWorkflow.comparison.suggestedValues.mergeCandidates", "conflictWorkflow.comparison.suggestedValues", "array"],
    ];
    for (const [path, parentPath, valueType] of keyMapExpectations) {
        const record = refreshedKeyMapByPath.get(path);
        const parent = parentPath ? refreshedKeyMapByPath.get(parentPath) : null;
        if (!record || (parentPath && !parent)) {
            add("failed", "keyMap structure", path, "record or parent missing");
            continue;
        }
        const fields = {};
        const currentType = record.getCellValueAsString(kf.valueType);
        if (currentType !== valueType) fields[kf.valueType] = { name: valueType };
        if (parent) {
            const currentParent = linkIds(record.getCellValue(kf.parent));
            if (sameIds(currentParent, [parent.id])) {
                // already correct
            } else if (currentParent.length) {
                add("failed", "keyMap parent", path, `conflicting parent ${currentParent.join(", ")}`);
                continue;
            } else {
                fields[kf.parent] = [{ id: parent.id }];
            }
        }
        if (Object.keys(fields).length) {
            keyMapUpdates.push({ id: record.id, fields });
            add("planned", "keyMap structure", path, "parent/type normalization");
        } else {
            add("already", "keyMap structure", path, "parent/type correct");
        }
    }

    const fieldConfigUpdates = [];
    const peopleMerge = refreshedFieldConfigs.getRecord(CONFIG.records.peopleMerge);
    if (!peopleMerge) {
        add("failed", "People merge metadata", CONFIG.records.peopleMerge, "record missing");
    } else {
        const fields = {};
        if (peopleMerge.getCellValueAsString(ff.name) !== "personRecordIds") {
            fields[ff.name] = "personRecordIds";
        }
        if (peopleMerge.getCellValueAsString(ff.eventField) !== "personRecordIds") {
            fields[ff.eventField] = "personRecordIds";
        }
        if (peopleMerge.getCellValueAsString(ff.writeMode) !== '"appendUnique"') {
            fields[ff.writeMode] = { name: '"appendUnique"' };
        }
        if (peopleMerge.getCellValue(ff.isMergeable) !== true) {
            fields[ff.isMergeable] = true;
        }
        if (peopleMerge.getCellValueAsString(ff.mergeableText) !== "true") {
            fields[ff.mergeableText] = "true";
        }
        // Match the four-key Merge field structure used by Organizations.
        const mergeFieldTypeKey = "recU0130ympBLRqez";
        const currentKeys = linkIds(peopleMerge.getCellValue(ff.keyMap));
        if (!currentKeys.includes(mergeFieldTypeKey)) {
            fields[ff.keyMap] = [...currentKeys, mergeFieldTypeKey].map(id => ({ id }));
        }
        if (Object.keys(fields).length) {
            fieldConfigUpdates.push({ id: peopleMerge.id, fields });
            add("planned", "People merge metadata", peopleMerge.id, "name/mode/mergeable/keyMap");
        } else {
            add("already", "People merge metadata", peopleMerge.id, "complete");
        }
    }

    const tableConfigUpdates = [];
    const conflictSetup = tableConfigQuery.getRecord(CONFIG.records.conflictSetup);
    if (!conflictSetup) {
        add("failed", "Conflict setup step", CONFIG.records.conflictSetup, "record missing");
    } else if (
        conflictSetup.getCellValueAsString(CONFIG.fields.tableConfigs.step) !== "4"
    ) {
        tableConfigUpdates.push({
            id: conflictSetup.id,
            fields: { [CONFIG.fields.tableConfigs.step]: "4" },
        });
        add("planned", "Conflict setup step", conflictSetup.id, "set step=4");
    } else {
        add("already", "Conflict setup step", conflictSetup.id, "step=4");
    }

    add(
        "remaining",
        "Conflict setup config rendering",
        CONFIG.records.conflictSetup,
        "keyMap/includeKeys/config-output still require a path-dialect decision; not guessed by this script"
    );
    add(
        "remaining",
        "canonicalKeyStatus",
        CONFIG.tables.mappings,
        "only MISSING_KEYMAP_ROW exists as a select choice; add a LINKED choice before normalizing statuses"
    );

    output.markdown("## Planned record updates");
    output.table(report.planned);
    output.markdown("## Already complete");
    output.table(report.already);
    output.markdown("## Skipped / failed");
    output.table(report.failed);
    output.markdown("## Intentionally remaining");
    output.table(report.remaining);

    const updateCount = mappingUpdates.length + keyMapUpdates.length +
        fieldConfigUpdates.length + tableConfigUpdates.length;
    if (!updateCount) {
        output.markdown("No record updates are required.");
        return;
    }

    const action = await input.buttonsAsync(
        `Apply ${updateCount} record update(s)?`,
        [
            { label: "Apply updates", value: "apply" },
            { label: "Report only", value: "report" },
        ]
    );
    if (action !== "apply") return;

    for (const [table, updates] of [
        [mappings, mappingUpdates],
        [keyMap, keyMapUpdates],
        [fieldConfigs, fieldConfigUpdates],
        [tableConfigs, tableConfigUpdates],
    ]) {
        if (!updates.length) continue;
        try {
            await updateInChunks(table, updates);
            add("applied", "updated records", table.name, `${updates.length} record(s)`);
        } catch (error) {
            add("failed", "update records", table.name, error.message);
        }
    }

    output.markdown("## Applied");
    output.table(report.applied);
    output.markdown("## Final failures");
    output.table(report.failed);
}

await main();
