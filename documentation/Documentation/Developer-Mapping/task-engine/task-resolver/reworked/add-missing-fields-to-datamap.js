/************************************************************
ARCHR Datamap — catalog newly created Project Tracker fields

Run this in Airtable's Script Extension inside the Datamap base.

Before running, copy the JSON mapping printed by
create-missing-progress-tracker-fields.js. This script prompts for
that mapping, creates only missing 🔹Fields records, and links all 15
matching fieldConfigSetup records to them. Nine configurations are
matched through placeholder_field_id; six pre-existing fields are
matched by their stable fieldConfigSetup record IDs.

It does not create schema fields and does not update/delete existing
catalog records. Same-ID or same-table/name inconsistencies abort the
run before any writes.
************************************************************/

const CONFIG = {
    tables: {
        fields: "tblAuRVBCx2I7xh3W",
        tables: "tblyAyQUfVfNxBKmx",
        fieldConfigs: "tbl1ezkDBeOuDebAq",
    },

    columns: {
        fields: {
            fieldId: "flddpELFcdVTqy7ZJ",
            fieldName: "fld1rIz5SQJiyOTwc",
            tableLink: "fld6QhuYyjGSGXmiS",
            fieldTypeLink: "fldpeivT8WC4XSmgC",
            fieldTypeName: "fldSWo1AzAr58l2f6",
        },
        tables: {
            tableId: "fldYs7F58hoyJUGLI",
        },
        fieldConfigs: {
            placeholder: "fldp4qX8eFQaha78W",
            fieldLink: "fldCbU88vE6097mDa",
        },
    },

    definitions: [
        {
            fieldId: "fldst3w3sshXzPZXd",
            configRecordId: "recT80j6HKz0N6Kgb",
            configName: "step3Message",
            tableId: "tbloJ5eN46v1Zx7AG",
            name: "🤖Step 3 Message",
            type: "richText",
        },
        {
            fieldId: "fldl3soLBiwJRILWQ",
            configRecordId: "recFGhGGyyDshYoJF",
            configName: "conflictDecision",
            tableId: "tbloJ5eN46v1Zx7AG",
            name: "⁉️Conflict Decision",
            type: "richText",
        },
        {
            fieldId: "fldYqYA06pSlVUaG0",
            configRecordId: "recEAzzFkf4xU9Ylw",
            configName: "step4Message",
            tableId: "tbloJ5eN46v1Zx7AG",
            name: "🤖Step 4 Message",
            type: "richText",
        },
        {
            fieldId: "fldFP6ESKhHj5AKSK",
            configRecordId: "recU2RruGhTtnPYhC",
            configName: "resolverMessage",
            tableId: "tbloJ5eN46v1Zx7AG",
            name: "🤖Resolver_Message",
            type: "multilineText",
        },
        {
            fieldId: "fldDi0exDVgCoC1UD",
            configRecordId: "recdVyvjMqTkXOQ95",
            configName: "conflictName",
            tableId: "tblfYyLY9k5kAomDJ",
            name: "Name",
            type: "singleLineText",
        },
        {
            fieldId: "fldAbOi8QWJucJNbO",
            configRecordId: "recI4BGelU3gdWghV",
            configName: "conflictStatus",
            tableId: "tblfYyLY9k5kAomDJ",
            name: "Status",
            type: "singleSelect",
        },
        {
            placeholder: "TODO_RESOLVER_STEP_X_STATUS_FIELD_ID",
            tableId: "tbloJ5eN46v1Zx7AG",
            name: "⁉️Step X Status",
            type: "singleSelect",
        },
        {
            placeholder: "TODO_RESOLVER_MATCHED_RULES_FIELD_ID",
            tableId: "tbloJ5eN46v1Zx7AG",
            name: "⁉️Matched Rules JSON",
            type: "multilineText",
        },
        {
            placeholder: "TODO_RESOLVER_CONFLICT_REASON_CODES_FIELD_ID",
            tableId: "tbloJ5eN46v1Zx7AG",
            name: "⁉️Conflict Reason Codes JSON",
            type: "multilineText",
        },
        {
            placeholder: "TODO_CONFLICT_TRIGGER_EVENT_FIELD_ID",
            tableId: "tblfYyLY9k5kAomDJ",
            name: "Trigger [◼️Project Event V2]",
            type: "multipleRecordLinks",
        },
        {
            placeholder: "TODO_CONFLICT_REASON_CODES_FIELD_ID",
            tableId: "tblfYyLY9k5kAomDJ",
            name: "Conflict Reason Codes JSON",
            type: "multilineText",
        },
        {
            placeholder: "TODO_CONFLICT_NEW_COMPLETION_FIELD_ID",
            tableId: "tblfYyLY9k5kAomDJ",
            name: "New [☑️Project Task Completion]",
            type: "multipleRecordLinks",
        },
        {
            placeholder: "TODO_CONFLICT_DECISION_FIELD_ID",
            tableId: "tblfYyLY9k5kAomDJ",
            name: "Conflict Decision",
            type: "singleSelect",
        },
        {
            placeholder: "TODO_CONFLICT_CONTEXT_JSON_FIELD_ID",
            tableId: "tblfYyLY9k5kAomDJ",
            name: "Comparison Context JSON",
            type: "multilineText",
        },
        {
            placeholder: "TODO_CONFLICT_CONFLICTING_EVENT_FIELD_ID",
            tableId: "tblfYyLY9k5kAomDJ",
            name: "Conflicting [◼️Project Event V2]",
            type: "multipleRecordLinks",
        },
    ],
};

function normalize(value) {
    return String(value ?? "").trim().toLocaleLowerCase();
}

function linkedRecordIds(value) {
    return Array.isArray(value)
        ? value.map(item => typeof item === "string" ? item : item?.id).filter(Boolean)
        : [];
}

function stringValues(value) {
    if (Array.isArray(value)) {
        return value
            .map(item => typeof item === "string" ? item : item?.name)
            .filter(Boolean);
    }
    return value === null || value === undefined ? [] : [String(value)];
}

function parseFieldIdMapping(raw) {
    const cleaned = String(raw || "")
        .trim()
        .replace(/^```(?:json|csv)?\s*/i, "")
        .replace(/\s*```$/, "")
        .trim();

    if (!cleaned) return {};

    if (cleaned.startsWith("{")) {
        return JSON.parse(cleaned);
    }

    const mapping = {};
    for (const line of cleaned.split(/\r?\n/)) {
        const [placeholder, fieldId] = line.split(",").map(value => value.trim());
        if (!placeholder || normalize(placeholder) === "placeholder_field_id") continue;
        mapping[placeholder] = fieldId;
    }
    return mapping;
}

function findUnique(records, predicate, description, problems) {
    const matches = records.filter(predicate);
    if (matches.length !== 1) {
        problems.push(`${description}: expected 1 record, found ${matches.length}`);
        return null;
    }
    return matches[0];
}

async function main() {
    const fieldsTable = base.getTable(CONFIG.tables.fields);
    const tablesTable = base.getTable(CONFIG.tables.tables);
    const fieldConfigsTable = base.getTable(CONFIG.tables.fieldConfigs);
    const fc = CONFIG.columns.fields;
    const tc = CONFIG.columns.tables;
    const cc = CONFIG.columns.fieldConfigs;

    output.markdown("# Add missing Project Tracker fields to Datamap");
    output.markdown(
        "Paste the JSON mapping printed by the Project Tracker field-creation script. " +
        "CSV rows with `placeholder_field_id,fieldId` are also accepted."
    );

    const rawMapping = await input.textAsync("Placeholder → fld… mapping");
    let fieldIds;
    try {
        fieldIds = parseFieldIdMapping(rawMapping);
    } catch (error) {
        throw new Error(`Could not parse the supplied mapping: ${error.message}`);
    }

    const problems = [];
    const suppliedIds = new Set();

    for (const definition of CONFIG.definitions) {
        const fieldId = String(
            definition.fieldId || fieldIds[definition.placeholder] || ""
        ).trim();
        if (!/^fld[A-Za-z0-9]+$/.test(fieldId)) {
            problems.push(`${definition.placeholder || definition.configName}: missing or invalid fld… ID`);
        } else if (suppliedIds.has(fieldId)) {
            problems.push(`${definition.placeholder || definition.configName}: duplicate field ID ${fieldId}`);
        } else {
            suppliedIds.add(fieldId);
        }
        definition.fieldId = fieldId;
    }

    if (problems.length) {
        output.table(problems.map(problem => ({ problem })));
        throw new Error("The supplied field-ID mapping is incomplete or invalid. No records were changed.");
    }

    const [fieldQuery, tableQuery, configQuery] = await Promise.all([
        fieldsTable.selectRecordsAsync({
            fields: [
                fc.fieldId,
                fc.fieldName,
                fc.tableLink,
                fc.fieldTypeLink,
                fc.fieldTypeName,
            ],
        }),
        tablesTable.selectRecordsAsync({ fields: [tc.tableId] }),
        fieldConfigsTable.selectRecordsAsync({
            fields: [cc.placeholder, cc.fieldLink],
        }),
    ]);

    const fieldRecords = [...fieldQuery.records];
    const tableRecords = [...tableQuery.records];
    const configRecords = [...configQuery.records];
    const tableRecordByPhysicalId = new Map();
    const typeRecordByName = new Map();

    for (const definition of CONFIG.definitions) {
        if (tableRecordByPhysicalId.has(definition.tableId)) continue;
        const record = findUnique(
            tableRecords,
            item => item.getCellValueAsString(tc.tableId).trim() === definition.tableId,
            `🔷Tables record for ${definition.tableId}`,
            problems
        );
        if (record) tableRecordByPhysicalId.set(definition.tableId, record.id);
    }

    for (const requiredType of new Set(CONFIG.definitions.map(item => item.type))) {
        const candidateIds = new Set();
        for (const record of fieldRecords) {
            const typeNames = stringValues(record.getCellValue(fc.fieldTypeName));
            if (!typeNames.some(name => normalize(name) === normalize(requiredType))) continue;
            for (const id of linkedRecordIds(record.getCellValue(fc.fieldTypeLink))) {
                candidateIds.add(id);
            }
        }

        if (candidateIds.size !== 1) {
            problems.push(
                `Field-type record for ${requiredType}: expected 1 linked ID, found ${candidateIds.size}`
            );
        } else {
            typeRecordByName.set(requiredType, [...candidateIds][0]);
        }
    }

    const plan = [];
    const configRecordByKey = new Map();

    for (const definition of CONFIG.definitions) {
        const configKey = definition.placeholder || definition.configRecordId;
        const tableRecordId = tableRecordByPhysicalId.get(definition.tableId);
        const exactIdMatches = fieldRecords.filter(
            record => record.getCellValueAsString(fc.fieldId).trim() === definition.fieldId
        );
        const sameNameAndTable = fieldRecords.filter(record => {
            const namesMatch = normalize(record.getCellValueAsString(fc.fieldName)) === normalize(definition.name);
            const tableIds = linkedRecordIds(record.getCellValue(fc.tableLink));
            return namesMatch && tableRecordId && tableIds.includes(tableRecordId);
        });

        let existing = null;
        if (exactIdMatches.length > 1) {
            problems.push(`${definition.fieldId}: duplicate 🔹Fields records (${exactIdMatches.length})`);
        } else if (exactIdMatches.length === 1) {
            existing = exactIdMatches[0];
            const existingName = existing.getCellValueAsString(fc.fieldName);
            const existingTables = linkedRecordIds(existing.getCellValue(fc.tableLink));
            if (normalize(existingName) !== normalize(definition.name)) {
                problems.push(`${definition.fieldId}: existing name is “${existingName}”, expected “${definition.name}”`);
            }
            if (!tableRecordId || !existingTables.includes(tableRecordId)) {
                problems.push(`${definition.fieldId}: existing record is linked to the wrong 🔷Table`);
            }
        } else if (sameNameAndTable.length) {
            problems.push(
                `${definition.tableId}.${definition.name}: same-name catalog record exists with a different field ID`
            );
        }

        const configRecord = findUnique(
            configRecords,
            record => definition.placeholder
                ? record.getCellValueAsString(cc.placeholder).trim() === definition.placeholder
                : record.id === definition.configRecordId,
            `fieldConfigSetup record for ${definition.placeholder || definition.configName}`,
            problems
        );
        if (configRecord) {
            configRecordByKey.set(configKey, configRecord);
            const currentLinks = linkedRecordIds(configRecord.getCellValue(cc.fieldLink));
            if (currentLinks.length && (!existing || !currentLinks.includes(existing.id))) {
                problems.push(
                    `${definition.placeholder || definition.configName}: ` +
                    "fieldConfigSetup is already linked to another 🔹Field"
                );
            }
        }

        plan.push({
            configKey,
            configuration: definition.placeholder || definition.configName,
            fieldId: definition.fieldId,
            tableId: definition.tableId,
            field: definition.name,
            type: definition.type,
            action: existing ? "reuse + link config" : "create + link config",
            fieldRecordId: existing?.id || "",
        });
    }

    output.markdown("## Planned changes");
    output.table(plan);

    if (problems.length) {
        output.markdown("## Blocking conflicts");
        output.table(problems.map(problem => ({ problem })));
        throw new Error("Resolve the conflicts above. No records were changed.");
    }

    const toCreate = plan.filter(item => !item.fieldRecordId);
    const answer = await input.buttonsAsync(
        `Create ${toCreate.length} 🔹Fields record(s) and wire ${plan.length} field configuration(s)?`,
        [
            { label: "Create and wire", value: "run" },
            { label: "Cancel", value: "cancel" },
        ]
    );

    if (answer !== "run") {
        output.markdown("Cancelled. No records were changed.");
        return;
    }

    if (toCreate.length) {
        const createdIds = await fieldsTable.createRecordsAsync(
            toCreate.map(item => ({
                fields: {
                    [fc.fieldId]: item.fieldId,
                    [fc.fieldName]: item.field,
                    [fc.tableLink]: [{ id: tableRecordByPhysicalId.get(item.tableId) }],
                    [fc.fieldTypeLink]: [{ id: typeRecordByName.get(item.type) }],
                },
            }))
        );
        toCreate.forEach((item, index) => {
            item.fieldRecordId = createdIds[index];
        });
    }

    await fieldConfigsTable.updateRecordsAsync(
        plan.map(item => ({
            id: configRecordByKey.get(item.configKey).id,
            fields: {
                [cc.fieldLink]: [{ id: item.fieldRecordId }],
            },
        }))
    );

    output.markdown("## Completed");
    output.table(plan.map(item => ({
        configuration: item.configuration,
        fieldId: item.fieldId,
        fieldRecordId: item.fieldRecordId,
        result: toCreate.includes(item) ? "created + linked" : "reused + linked",
    })));
}

await main();
