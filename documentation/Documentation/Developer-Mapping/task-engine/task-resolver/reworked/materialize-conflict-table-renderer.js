/************************************************************
ARCHR Datamap — materialize the Conflict Create table renderer

Run in Airtable's Script Extension inside the Datamap base.

The keyMap stores canonical paths, while fieldNameLookupCreator maps
those paths to shorter renderer paths. This script completes the
tableConfigSetups side of that design for the Conflict Create setup:

- reads the linked fieldConfigSetup `field` formula fragments;
- validates and wraps each fragment as a `{ "field": ... }` array item;
- replaces unresolved `_SOURCE_` / `_VALUE_` templates with explicit
  canonical source contracts and literal defaults;
- writes those items into the writable `writeFields` materialization;
- enables the short includeKeys used by calcTable:
    tables.table
    table.tableId
    table.writeFields

The existing calcTable and tables.table formulas then render the table
fragment. Script Extension cannot convert the writeFields text column
into a computed formula/rollup field, so this script is intentionally a
safe, rerunnable materializer. Rerun it after changing linked fields.

It previews all changes, does not delete records or fields, and aborts
before writing if any linked field fragment is invalid.
************************************************************/

const CONFIG = {
    tables: {
        fieldConfigs: "tbl1ezkDBeOuDebAq",
        tableConfigs: "tblJ6qDeQoYKObg13",
    },
    fields: {
        fieldConfigs: {
            primary: "fldHyHexyhEMlBTyz",
            name: "fldZyewizc3jIntUd",
            renderedField: "fldH6CSxUK1u7I6Ye",
            physicalFieldId: "fldd6d2I9OCwsevcW",
        },
        tableConfigs: {
            fieldConfigs: "fldadfKxUaDd9xHqK",
            includeKeys: "fldNJBoKNO0WfLPyB",
            mapKeys: "fldqg5Bl7AyoUPEGm",
            tableId: "fldUyAIhL5j0bA41U",
            writeFields: "fldAAIHEod3skQZNs",
            fieldsConfigRollup: "fldtTq4Tvnqtu3gRL",
            calcTable: "fldMAooEmGFosCHsX",
            tablesTable: "fldTZAQTQ6V3BafOp",
        },
    },
    records: {
        conflictSetup: "recMmCxZ1pQPmnMvM",
    },
};

const REQUIRED_INCLUDE_KEYS = [
    "tables.table",
    "table.tableId",
    "table.writeFields",
];

// `writeSource` is deliberately an object. It keeps the canonical context
// path together with the transform and parsed JSON fallback that the Create
// executor needs. Literal fields use `writeValue` instead.
//
// These are keyed by physical Airtable field ID so a renamed fieldConfigSetup
// record cannot silently receive another field's source contract.
const FIELD_VALUE_SPECS = {
    fldBcWQlGTSYTh0CS: {
        kind: "source",
        path: "conflictWorkflow.comparison.existingCompletionId",
        transform: "toRecordIdArray",
        required: true,
        defaultJSON: [],
        onMissing: "manualReview",
    },
    fldDi0exDVgCoC1UD: {
        kind: "source",
        path: "inputs.completionKey",
        transform: "identity",
        required: false,
        defaultJSON: "Completion record conflict",
        onMissing: "useDefault",
    },
    fld2bzmZhOQJshYfH: {
        kind: "value",
        value: "Created automatically by Event Resolver",
    },
    fldAbOi8QWJucJNbO: {
        kind: "value",
        value: "Todo",
    },
    fld9GX6ngCwkmVXq9: {
        kind: "source",
        path: "conflictWorkflow.comparison.triggerEventId",
        transform: "toRecordIdArray",
        required: true,
        defaultJSON: [],
        onMissing: "manualReview",
    },
    fldUCNmfrmEwZ3lH0: {
        kind: "source",
        path: "conflictWorkflow.comparison.conflictingEventId",
        transform: "toRecordIdArray",
        required: true,
        defaultJSON: [],
        onMissing: "manualReview",
    },
    fldf2YNKjf98QeVsG: {
        kind: "source",
        path: "outputs.createdCompletion",
        transform: "toRecordIdArray",
        required: true,
        defaultJSON: [],
        onMissing: "manualReview",
    },
    fldgsFO3PE0bg5liT: {
        kind: "source",
        path: "conflictWorkflow.ruleEvaluation.decision",
        transform: "identity",
        required: true,
        defaultJSON: "manualReview",
        onMissing: "useDefault",
    },
    fldujvVSXUZqNQcss: {
        kind: "source",
        path: "conflictWorkflow.ruleEvaluation.reasonCodes",
        transform: "JSON.stringify",
        required: false,
        defaultJSON: [],
        onMissing: "useDefault",
    },
    flda5Y0JlsqDcZiNJ: {
        kind: "source",
        path: "conflictWorkflow.comparison",
        transform: "JSON.stringify",
        required: false,
        defaultJSON: {},
        onMissing: "useDefault",
    },
};

const report = {
    planned: [],
    already: [],
    failed: [],
    applied: [],
};

function add(bucket, operation, target, detail) {
    report[bucket].push({ operation, target, detail });
}

function linkIds(value) {
    return Array.isArray(value)
        ? value.map(item => typeof item === "string" ? item : item?.id).filter(Boolean)
        : [];
}

function selectNames(value) {
    return Array.isArray(value)
        ? value.map(item => typeof item === "string" ? item : item?.name).filter(Boolean)
        : [];
}

function sameStrings(left, right) {
    return JSON.stringify([...new Set(left)].sort()) ===
        JSON.stringify([...new Set(right)].sort());
}

function parseFieldFragment(fragment, recordId) {
    const text = String(fragment || "").trim();
    if (!text) {
        throw new Error(`${recordId}: rendered field fragment is blank`);
    }

    let wrapper;
    try {
        wrapper = JSON.parse(`{${text}}`);
    } catch (error) {
        throw new Error(`${recordId}: rendered field fragment is invalid JSON: ${error.message}`);
    }

    if (
        !wrapper ||
        typeof wrapper !== "object" ||
        Array.isArray(wrapper) ||
        !wrapper.field ||
        typeof wrapper.field !== "object" ||
        Array.isArray(wrapper.field)
    ) {
        throw new Error(`${recordId}: expected a single { "field": {...} } fragment`);
    }
    if (!/^fld[A-Za-z0-9]+$/.test(String(wrapper.field.fieldId || ""))) {
        throw new Error(`${recordId}: rendered field.fieldId is missing or invalid`);
    }

    return wrapper;
}

function parseMaterializedFields(value) {
    const text = String(value || "").trim();
    if (!text) return [];
    const parsed = JSON.parse(`[${text}]`);
    if (!Array.isArray(parsed) || parsed.some(item => !item?.field?.fieldId)) {
        throw new Error("writeFields is not a list of { field: { fieldId } } objects");
    }
    return parsed;
}

function applyValueSpec(wrapper, recordId) {
    const spec = FIELD_VALUE_SPECS[wrapper.field.fieldId];
    if (!spec) {
        throw new Error(
            `${recordId}: no source/default specification exists for ${wrapper.field.fieldId}`
        );
    }

    if (spec.kind === "value") {
        delete wrapper.field.writeSource;
        wrapper.field.writeValue = spec.value;
        return spec;
    }

    delete wrapper.field.writeValue;
    wrapper.field.writeSource = {
        path: spec.path,
        transform: spec.transform,
        required: spec.required,
        defaultJSON: spec.defaultJSON,
        onMissing: spec.onMissing,
    };
    return spec;
}

async function main() {
    output.markdown("# Materialize Conflict Create table renderer");

    const fieldConfigs = base.getTable(CONFIG.tables.fieldConfigs);
    const tableConfigs = base.getTable(CONFIG.tables.tableConfigs);
    const ff = CONFIG.fields.fieldConfigs;
    const tf = CONFIG.fields.tableConfigs;

    const [fieldQuery, tableQuery] = await Promise.all([
        fieldConfigs.selectRecordsAsync({
            fields: [ff.primary, ff.name, ff.renderedField, ff.physicalFieldId],
        }),
        tableConfigs.selectRecordsAsync({
            fields: [
                tf.fieldConfigs,
                tf.includeKeys,
                tf.mapKeys,
                tf.tableId,
                tf.writeFields,
                tf.fieldsConfigRollup,
                tf.calcTable,
                tf.tablesTable,
            ],
        }),
    ]);

    const setup = tableQuery.getRecord(CONFIG.records.conflictSetup);
    if (!setup) {
        throw new Error(`Conflict setup ${CONFIG.records.conflictSetup} was not found. No changes were made.`);
    }

    const linkedFieldIds = linkIds(setup.getCellValue(tf.fieldConfigs));
    if (!linkedFieldIds.length) {
        throw new Error("Conflict setup has no linked field configurations. No changes were made.");
    }

    const fieldById = new Map(fieldQuery.records.map(record => [record.id, record]));
    const renderedItems = [];
    const renderedPreview = [];

    for (const recordId of linkedFieldIds) {
        const record = fieldById.get(recordId);
        if (!record) {
            add("failed", "field materialization", recordId, "linked fieldConfig record not found");
            continue;
        }

        try {
            const wrapper = parseFieldFragment(
                record.getCellValueAsString(ff.renderedField),
                record.id
            );
            const physicalIds = record.getCellValue(ff.physicalFieldId);
            const physicalId = Array.isArray(physicalIds)
                ? String(physicalIds[0] || "")
                : String(physicalIds || "");

            if (physicalId && wrapper.field.fieldId !== physicalId) {
                throw new Error(
                    `${record.id}: rendered fieldId ${wrapper.field.fieldId} does not match lookup ${physicalId}`
                );
            }

            const valueSpec = applyValueSpec(wrapper, record.id);

            renderedItems.push(wrapper);
            renderedPreview.push({
                order: renderedItems.length,
                fieldConfig: record.id,
                name: record.getCellValueAsString(ff.name) ||
                    record.getCellValueAsString(ff.primary),
                fieldId: wrapper.field.fieldId,
                fieldType: wrapper.field.fieldType || "",
                writeMode: wrapper.field.writeMode || "",
                valueKind: valueSpec.kind,
                sourceOrValue: valueSpec.kind === "source"
                    ? valueSpec.path
                    : JSON.stringify(valueSpec.value),
                defaultJSON: valueSpec.kind === "source"
                    ? JSON.stringify(valueSpec.defaultJSON)
                    : "",
            });
        } catch (error) {
            add("failed", "field materialization", record.id, error.message);
        }
    }

    output.markdown("## Field materialization preview");
    output.table(renderedPreview);

    if (report.failed.length || renderedItems.length !== linkedFieldIds.length) {
        output.markdown("## Blocking failures");
        output.table(report.failed);
        throw new Error("One or more field fragments are invalid. No records were changed.");
    }

    // Store array contents rather than the outer brackets because calcTable
    // supplies `"writeFields":[ ... ]` around this materialized value.
    const materializedWriteFields = renderedItems
        .map(item => JSON.stringify(item))
        .join(",");

    const mapKeys = setup.getCellValue(tf.mapKeys);
    const mapKeyNames = Array.isArray(mapKeys)
        ? mapKeys.map(value => typeof value === "string" ? value : value?.name).filter(Boolean)
        : [];
    const missingMapKeys = REQUIRED_INCLUDE_KEYS.filter(name => !mapKeyNames.includes(name));
    if (missingMapKeys.length) {
        add(
            "failed",
            "short-path mapKeys",
            setup.id,
            `canonical keyMap links do not produce: ${missingMapKeys.join(", ")}`
        );
    } else {
        add("already", "short-path mapKeys", setup.id, REQUIRED_INCLUDE_KEYS.join(", "));
    }

    const includeField = tableConfigs.fields.find(field => field.id === tf.includeKeys);
    const availableChoices = new Set(
        (includeField?.options?.choices || []).map(choice => choice.name)
    );
    const missingChoices = REQUIRED_INCLUDE_KEYS.filter(name => !availableChoices.has(name));
    if (missingChoices.length) {
        add(
            "failed",
            "includeKeys schema",
            tf.includeKeys,
            `missing choices: ${missingChoices.join(", ")}`
        );
    }

    let currentMaterialized = null;
    const currentWriteFields = setup.getCellValueAsString(tf.writeFields).trim();
    try {
        currentMaterialized = parseMaterializedFields(currentWriteFields);
    } catch (error) {
        add("failed", "writeFields materialization", setup.id, error.message);
    }

    const currentIncludeKeys = selectNames(setup.getCellValue(tf.includeKeys));
    const desiredIncludeKeys = [
        ...currentIncludeKeys,
        ...REQUIRED_INCLUDE_KEYS.filter(name => !currentIncludeKeys.includes(name)),
    ];

    const updates = {};
    if (
        currentMaterialized &&
        JSON.stringify(currentMaterialized) === JSON.stringify(renderedItems)
    ) {
        add("already", "writeFields materialization", setup.id, `${renderedItems.length} field item(s)`);
    } else if (currentMaterialized) {
        updates[tf.writeFields] = materializedWriteFields;
        add(
            "planned",
            "writeFields materialization",
            setup.id,
            `${currentMaterialized.length} existing → ${renderedItems.length} current field item(s)`
        );
    }

    if (sameStrings(currentIncludeKeys, desiredIncludeKeys)) {
        add("already", "includeKeys", setup.id, REQUIRED_INCLUDE_KEYS.join(", "));
    } else {
        updates[tf.includeKeys] = desiredIncludeKeys.map(name => ({ name }));
        add(
            "planned",
            "includeKeys",
            setup.id,
            `add ${desiredIncludeKeys.filter(name => !currentIncludeKeys.includes(name)).join(", ")}`
        );
    }

    // Validate the exact JSON fragment calcTable is expected to produce.
    const tableIds = setup.getCellValue(tf.tableId);
    const tableId = Array.isArray(tableIds)
        ? String(tableIds[0] || "")
        : String(tableIds || "");
    if (!/^tbl[A-Za-z0-9]+$/.test(tableId)) {
        add("failed", "table renderer", setup.id, `invalid tableId lookup: ${tableId || "blank"}`);
    }

    const expectedTableFragment = {
        table: {
            tableId,
            writeFields: renderedItems,
        },
    };
    output.markdown("## Expected tables.table fragment after recalculation");
    output.inspect(expectedTableFragment);

    output.markdown("## Planned changes");
    output.table(report.planned);
    output.markdown("## Already complete");
    output.table(report.already);
    output.markdown("## Blocking failures");
    output.table(report.failed);

    if (report.failed.length) {
        throw new Error("Resolve the failures above. No records were changed.");
    }
    if (!Object.keys(updates).length) {
        output.markdown("No materialization changes are required.");
        return;
    }

    const action = await input.buttonsAsync(
        `Materialize ${renderedItems.length} fields and update the Conflict renderer?`,
        [
            { label: "Apply materialization", value: "apply" },
            { label: "Report only", value: "report" },
        ]
    );
    if (action !== "apply") {
        output.markdown("Report-only run complete. No records were changed.");
        return;
    }

    await tableConfigs.updateRecordAsync(setup.id, updates);
    add("applied", "updated record", setup.id, Object.keys(updates).join(", "));

    // Fetch again so the Script Extension report shows Airtable's formula
    // recalculation instead of only our locally predicted fragment.
    const refreshedQuery = await tableConfigs.selectRecordsAsync({
        fields: [tf.writeFields, tf.includeKeys, tf.calcTable, tf.tablesTable],
    });
    const refreshed = refreshedQuery.getRecord(setup.id);
    const recalculatedTableFragment = refreshed
        .getCellValueAsString(tf.tablesTable)
        .trim();
    try {
        const parsedTableFragment = JSON.parse(`{${recalculatedTableFragment}}`);
        const actualFields = parsedTableFragment?.table?.writeFields;
        if (
            parsedTableFragment?.table?.tableId !== tableId ||
            !Array.isArray(actualFields) ||
            actualFields.length !== renderedItems.length
        ) {
            throw new Error(
                `expected tableId ${tableId} and ${renderedItems.length} writeFields`
            );
        }
        add(
            "applied",
            "validated tables.table",
            setup.id,
            `${actualFields.length} rendered field item(s)`
        );
    } catch (error) {
        add(
            "failed",
            "validate tables.table",
            setup.id,
            `${error.message}; rendered fragment: ${recalculatedTableFragment || "blank"}`
        );
    }

    output.markdown("## Applied");
    output.table(report.applied);
    output.markdown("## Recalculated renderer fields");
    output.table([{
        writeFields: refreshed.getCellValueAsString(tf.writeFields),
        includeKeys: selectNames(refreshed.getCellValue(tf.includeKeys)).join(", "),
        calcTable: refreshed.getCellValueAsString(tf.calcTable),
        tablesTable: recalculatedTableFragment,
    }]);
    output.markdown("## Final validation failures");
    output.table(report.failed);
}

await main();
