/************************************************************
ARCHR Datamap — repair resolver record links

Run in Airtable's Script Extension inside the Datamap base.

Behavior:
- previews high-confidence link repairs;
- applies changes only after confirmation;
- preserves unrelated links;
- never deletes records;
- skips ambiguous/conflicting repairs;
- reports missing records, fields, and unresolved links.

Safe to rerun: already-correct links are reported and skipped.
************************************************************/

const CONFIG = {
    tables: {
        fieldConfigs: "tbl1ezkDBeOuDebAq",
        tableConfigs: "tblJ6qDeQoYKObg13",
        mappings: "tblEqe4un7Bq7BJyc",
        keyMap: "tbl7mjYmTYjonvw8k",
    },
    fields: {
        fieldConfigs: {
            tableConfig: "fld83jpMiTZvYFwWI",
        },
        tableConfigs: {
            table: "fldKEdBK9ZS9GryWx",
            base: "fldL0RCsTWUBQqpK5",
            genericEngine: "fld0Ve6xXkny4HDRv",
        },
        mappings: {
            bindingId: "fld0xYUcMyx4c9kao",
            consumerSetup: "fldFBFvOgYAUA9q1b",
        },
        keyMap: {
            jsonKey: "fldJyhq9UrXiltttm",
            parentKey: "fldX7qPa6eF2FlH61",
        },
    },
    knownCompleteSetups: {
        // These existing setups are used only as authoritative sources for
        // the Progress Tracker base and concrete table-record links.
        eventUpdate: "recPe1V644CAnRoRd",
        resolverUpdateLog: "recxKoGtvKmisqWD6",
        completionCreate: "rec20KXmUQfLALrbV",
        // The earlier conflict setup was removed. Its replacement is the
        // promoted setup that now owns the Conflict table/base/field links.
        conflictCreate: "recMmCxZ1pQPmnMvM",
    },
};

const FIELD_CONFIG_RELINKS = [
    // Step 3 Update Log
    ["recEVQMh73CSodUQe", "rec4b8Zgfw7Ja2NcO", "recligsn7TSdUs0Hu"],
    ["recT80j6HKz0N6Kgb", "rec4b8Zgfw7Ja2NcO", "recligsn7TSdUs0Hu"],

    // Step X Update Log
    ["recFGhGGyyDshYoJF", "rec1p0ZJgCNK9jsok", "recVgCs0xzNGWOWPM"],
    ["rechFjtNTsdG3w1IG", "rec1p0ZJgCNK9jsok", "recVgCs0xzNGWOWPM"],
    ["recLRVE6eWuUQgL2b", "rec1p0ZJgCNK9jsok", "recVgCs0xzNGWOWPM"],
    ["recYEei4NlgAtc8hM", "rec1p0ZJgCNK9jsok", "recVgCs0xzNGWOWPM"],

    // Step 4 Merge Event
    ["recWDcq47r9Ow4wN6", "recjrvuLCkLCngm1K", "rec20zFzKrPzkwVRb"],
    ["rec3BXL3rQyAaYrDs", "recjrvuLCkLCngm1K", "rec20zFzKrPzkwVRb"],

    // Step 4 Update Log
    ["recEAzzFkf4xU9Ylw", "recwwiQmEGmJx3cau", "recNbHQq4koXcsZS9"],
    ["recU2RruGhTtnPYhC", "recwwiQmEGmJx3cau", "recNbHQq4koXcsZS9"],

];

const STEP4_EVENT_UPDATE_FIELD_CONFIGS = [
    "rechVQa6IrrCGaVOE", // Project
    "recFeFXZkQHWMjyDF", // Task
    "recELVdBC9TnDHk2l", // Organizations
    "recNhpy05IrR6wTtq", // People
];

const PARTIAL_SETUP_TARGETS = [
    ["recligsn7TSdUs0Hu", "resolver"], // Step 3 Update Log
    ["recVgCs0xzNGWOWPM", "resolver"], // Step X Update Log
    ["rec20zFzKrPzkwVRb", "event"],    // Step 4 Merge Event
    ["recMNuHYKQWCmwa07", "event"],    // Step 4 Update Event
    ["recNbHQq4koXcsZS9", "resolver"], // Step 4 Update Log
];

const results = {
    planned: [],
    alreadyCorrect: [],
    failed: [],
    informational: [],
};

function report(bucket, operation, recordId, detail) {
    results[bucket].push({ operation, recordId, detail });
}

function linkIds(value) {
    if (!Array.isArray(value)) return [];
    return value
        .map(item => typeof item === "string" ? item : item?.id)
        .filter(Boolean);
}

function unique(values) {
    return [...new Set(values.filter(Boolean))];
}

function getField(table, idOrName) {
    return table.fields.find(
        field => field.id === idOrName || field.name === idOrName
    ) || null;
}

function getRecord(recordMap, recordId, operation) {
    const record = recordMap.get(recordId);
    if (!record) {
        report("failed", operation, recordId, "record not found");
        return null;
    }
    return record;
}

function makeState(tableKey, record, fieldId) {
    return {
        key: `${tableKey}:${record.id}:${fieldId}`,
        tableKey,
        recordId: record.id,
        fieldId,
        original: linkIds(record.getCellValue(fieldId)),
        current: linkIds(record.getCellValue(fieldId)),
    };
}

function getState(states, tableKey, record, fieldId) {
    const key = `${tableKey}:${record.id}:${fieldId}`;
    if (!states.has(key)) states.set(key, makeState(tableKey, record, fieldId));
    return states.get(key);
}

function replaceLink(states, tableKey, record, fieldId, fromId, toId, operation) {
    const state = getState(states, tableKey, record, fieldId);
    const hasFrom = state.current.includes(fromId);
    const hasTo = state.current.includes(toId);

    if (!hasFrom && hasTo) {
        report("alreadyCorrect", operation, record.id, `already linked to ${toId}`);
        return;
    }
    if (!hasFrom && !hasTo) {
        report(
            "failed",
            operation,
            record.id,
            `expected source link ${fromId}; current links: ${state.current.join(", ") || "none"}`
        );
        return;
    }

    state.current = unique([
        ...state.current.filter(id => id !== fromId),
        toId,
    ]);
    report("planned", operation, record.id, `${fromId} → ${toId}`);
}

function addLink(states, tableKey, record, fieldId, toId, operation) {
    const state = getState(states, tableKey, record, fieldId);
    if (state.current.includes(toId)) {
        report("alreadyCorrect", operation, record.id, `already linked to ${toId}`);
        return;
    }
    state.current = unique([...state.current, toId]);
    report("planned", operation, record.id, `add ${toId}`);
}

function removeLink(states, tableKey, record, fieldId, fromId, operation) {
    const state = getState(states, tableKey, record, fieldId);
    if (!state.current.includes(fromId)) {
        report("alreadyCorrect", operation, record.id, `${fromId} is not linked`);
        return;
    }
    state.current = state.current.filter(id => id !== fromId);
    report("planned", operation, record.id, `remove ${fromId}`);
}

function ensureSingleLink(states, tableKey, record, fieldId, toId, operation) {
    const state = getState(states, tableKey, record, fieldId);
    if (state.current.length === 1 && state.current[0] === toId) {
        report("alreadyCorrect", operation, record.id, `already linked to ${toId}`);
        return;
    }
    if (state.current.length > 0) {
        report(
            "failed",
            operation,
            record.id,
            `conflicting current links: ${state.current.join(", ")}; expected ${toId}`
        );
        return;
    }
    state.current = [toId];
    report("planned", operation, record.id, `set ${toId}`);
}

function stateChanged(state) {
    return JSON.stringify([...state.original].sort()) !==
        JSON.stringify([...state.current].sort());
}

async function updateInChunks(table, updates) {
    for (let index = 0; index < updates.length; index += 50) {
        await table.updateRecordsAsync(updates.slice(index, index + 50));
    }
}

async function main() {
    output.markdown("# Datamap record-link repair");

    const fieldConfigsTable = base.getTable(CONFIG.tables.fieldConfigs);
    const tableConfigsTable = base.getTable(CONFIG.tables.tableConfigs);
    const mappingsTable = base.getTable(CONFIG.tables.mappings);
    const keyMapTable = base.getTable(CONFIG.tables.keyMap);

    const requiredFields = [
        [fieldConfigsTable, CONFIG.fields.fieldConfigs.tableConfig],
        [tableConfigsTable, CONFIG.fields.tableConfigs.table],
        [tableConfigsTable, CONFIG.fields.tableConfigs.base],
        [tableConfigsTable, CONFIG.fields.tableConfigs.genericEngine],
        [mappingsTable, CONFIG.fields.mappings.bindingId],
        [mappingsTable, CONFIG.fields.mappings.consumerSetup],
        [keyMapTable, CONFIG.fields.keyMap.jsonKey],
        [keyMapTable, CONFIG.fields.keyMap.parentKey],
    ];

    for (const [table, fieldId] of requiredFields) {
        if (!getField(table, fieldId)) {
            report("failed", "schema validation", table.id, `field ${fieldId} not found`);
        }
    }

    // These two intended binding fields were absent in the last snapshot.
    for (const name of ["producerFieldConfig", "consumerFieldConfig"]) {
        if (!getField(mappingsTable, name)) {
            report(
                "failed",
                "binding schema",
                mappingsTable.id,
                `missing field ${name}; field-level bindings cannot be repaired`
            );
        }
    }

    if (results.failed.some(item => item.operation === "schema validation")) {
        output.table(results.failed);
        throw new Error("Required Datamap fields are missing. No records were changed.");
    }

    const [fieldConfigQuery, tableConfigQuery, mappingQuery, keyMapQuery] =
        await Promise.all([
            fieldConfigsTable.selectRecordsAsync({
                fields: [CONFIG.fields.fieldConfigs.tableConfig],
            }),
            tableConfigsTable.selectRecordsAsync({
                fields: [
                    CONFIG.fields.tableConfigs.table,
                    CONFIG.fields.tableConfigs.base,
                    CONFIG.fields.tableConfigs.genericEngine,
                ],
            }),
            mappingsTable.selectRecordsAsync({
                fields: [
                    CONFIG.fields.mappings.bindingId,
                    CONFIG.fields.mappings.consumerSetup,
                ],
            }),
            keyMapTable.selectRecordsAsync({
                fields: [
                    CONFIG.fields.keyMap.jsonKey,
                    CONFIG.fields.keyMap.parentKey,
                ],
            }),
        ]);

    const fieldConfigRecords = new Map(
        fieldConfigQuery.records.map(record => [record.id, record])
    );
    const tableConfigRecords = new Map(
        tableConfigQuery.records.map(record => [record.id, record])
    );
    const keyMapRecords = new Map(
        keyMapQuery.records.map(record => [record.id, record])
    );
    const mappingRecordsByBindingId = new Map();
    for (const record of mappingQuery.records) {
        const bindingId = record
            .getCellValueAsString(CONFIG.fields.mappings.bindingId)
            .trim();
        if (!bindingId) continue;
        if (mappingRecordsByBindingId.has(bindingId)) {
            report("failed", "mapping lookup", bindingId, "duplicate bindingId");
        } else {
            mappingRecordsByBindingId.set(bindingId, record);
        }
    }

    const states = new Map();
    const fcLinkField = CONFIG.fields.fieldConfigs.tableConfig;
    const tcTableField = CONFIG.fields.tableConfigs.table;
    const tcBaseField = CONFIG.fields.tableConfigs.base;
    const tcEngineField = CONFIG.fields.tableConfigs.genericEngine;

    // Derive authoritative table/base links from known-good setup records.
    const eventSource = getRecord(
        tableConfigRecords,
        CONFIG.knownCompleteSetups.eventUpdate,
        "derive Event setup links"
    );
    const resolverSource = getRecord(
        tableConfigRecords,
        CONFIG.knownCompleteSetups.resolverUpdateLog,
        "derive Resolver setup links"
    );
    const conflictSource = getRecord(
        tableConfigRecords,
        CONFIG.knownCompleteSetups.conflictCreate,
        "derive Conflict setup links"
    );
    const completionCreateSource = getRecord(
        tableConfigRecords,
        CONFIG.knownCompleteSetups.completionCreate,
        "derive Create engine link"
    );

    const authoritative = {};
    for (const [key, record] of [
        ["event", eventSource],
        ["resolver", resolverSource],
        ["conflict", conflictSource],
    ]) {
        if (!record) continue;
        const tableIds = linkIds(record.getCellValue(tcTableField));
        const baseIds = linkIds(record.getCellValue(tcBaseField));
        if (tableIds.length !== 1 || baseIds.length !== 1) {
            report(
                "failed",
                "derive authoritative links",
                record.id,
                `expected one table and one base; found tables=${tableIds.join(",") || "none"}, ` +
                `bases=${baseIds.join(",") || "none"}`
            );
        } else {
            authoritative[key] = { tableId: tableIds[0], baseId: baseIds[0] };
        }
    }

    // The promoted Conflict setup retained its table/base/field links, but
    // deleting the old setup also removed Create-engine membership.
    if (conflictSource && completionCreateSource) {
        const createEngineIds = linkIds(
            completionCreateSource.getCellValue(tcEngineField)
        );
        if (createEngineIds.length !== 1) {
            report(
                "failed",
                "repair Conflict Create engine link",
                completionCreateSource.id,
                `expected one Create engine link; found ${createEngineIds.join(", ") || "none"}`
            );
        } else {
            ensureSingleLink(
                states,
                "tableConfigs",
                conflictSource,
                tcEngineField,
                createEngineIds[0],
                "repair Conflict Create engine link"
            );
        }
    }

    // Move imported field configs off the five auto-created blank setups.
    for (const [recordId, fromSetupId, toSetupId] of FIELD_CONFIG_RELINKS) {
        const record = getRecord(fieldConfigRecords, recordId, "fieldConfig tableConfig relink");
        if (!record || !tableConfigRecords.has(toSetupId)) {
            if (record && !tableConfigRecords.has(toSetupId)) {
                report("failed", "fieldConfig tableConfig relink", recordId, `target ${toSetupId} not found`);
            }
            continue;
        }
        replaceLink(
            states,
            "fieldConfigs",
            record,
            fcLinkField,
            fromSetupId,
            toSetupId,
            "fieldConfig tableConfig relink"
        );
    }

    // Reuse Step 2 Event write-field configs for the Step 4 Event update.
    const step4EventUpdateId = "recMNuHYKQWCmwa07";
    if (!tableConfigRecords.has(step4EventUpdateId)) {
        report("failed", "Step 4 Event field links", step4EventUpdateId, "target setup not found");
    } else {
        for (const recordId of STEP4_EVENT_UPDATE_FIELD_CONFIGS) {
            const record = getRecord(fieldConfigRecords, recordId, "Step 4 Event field links");
            if (!record) continue;
            addLink(
                states,
                "fieldConfigs",
                record,
                fcLinkField,
                step4EventUpdateId,
                "Step 4 Event field links"
            );
        }
    }

    // Remove the resolver contextJSON config from conflict-record creation.
    const wrongConflictContextConfig = fieldConfigRecords.get(
        "recHDw63Dvmk0xylj"
    );
    if (wrongConflictContextConfig) {
        removeLink(
            states,
            "fieldConfigs",
            wrongConflictContextConfig,
            fcLinkField,
            CONFIG.knownCompleteSetups.conflictCreate,
            "remove wrong conflict context link"
        );
    } else {
        report(
            "alreadyCorrect",
            "remove wrong conflict context link",
            "recHDw63Dvmk0xylj",
            "obsolete config record is absent"
        );
    }

    // One of the duplicate People merge configs has now been removed. Link
    // the survivor only when the ambiguity is actually resolved.
    const peopleMergeCandidates = [
        "recbdgUxugXh7aUut",
        "recrS1pydNPh7wCvN",
    ].filter(id => fieldConfigRecords.has(id));
    if (peopleMergeCandidates.length === 1) {
        addLink(
            states,
            "fieldConfigs",
            fieldConfigRecords.get(peopleMergeCandidates[0]),
            fcLinkField,
            "rec20zFzKrPzkwVRb",
            "link surviving People merge config"
        );
        report(
            "informational",
            "People merge metadata",
            peopleMergeCandidates[0],
            "after linking, populate its semantic Name and mergeable/write-mode fields"
        );
    } else {
        report(
            "failed",
            "ambiguous People merge config",
            peopleMergeCandidates.join(" / ") || "none",
            peopleMergeCandidates.length > 1
                ? "both duplicate configs still exist; choose one"
                : "neither People merge config exists"
        );
    }

    // Complete the missing table/base links on the five intended setups.
    for (const [setupId, authoritativeKey] of PARTIAL_SETUP_TARGETS) {
        const record = getRecord(tableConfigRecords, setupId, "complete table setup links");
        const target = authoritative[authoritativeKey];
        if (!record || !target) {
            if (record && !target) {
                report("failed", "complete table setup links", setupId, `no authoritative ${authoritativeKey} links`);
            }
            continue;
        }
        ensureSingleLink(
            states,
            "tableConfigs",
            record,
            tcTableField,
            target.tableId,
            "complete table setup table link"
        );
        ensureSingleLink(
            states,
            "tableConfigs",
            record,
            tcBaseField,
            target.baseId,
            "complete table setup base link"
        );
    }

    // Retarget combined People output to the Step 4 Event merge setup.
    const peopleBinding = mappingRecordsByBindingId.get("BIND-SX-003");
    if (!peopleBinding) {
        report("failed", "binding consumer relink", "BIND-SX-003", "binding not found");
    } else if (!tableConfigRecords.has("rec20zFzKrPzkwVRb")) {
        report("failed", "binding consumer relink", peopleBinding.id, "Event merge setup not found");
    } else {
        const mappingField = CONFIG.fields.mappings.consumerSetup;
        const state = getState(states, "mappings", peopleBinding, mappingField);
        if (state.current.includes("recjVjZnkJ3l3D5nk")) {
            replaceLink(
                states,
                "mappings",
                peopleBinding,
                mappingField,
                "recjVjZnkJ3l3D5nk",
                "rec20zFzKrPzkwVRb",
                "binding consumer relink"
            );
        } else if (state.current.includes("rec20zFzKrPzkwVRb")) {
            report("alreadyCorrect", "binding consumer relink", peopleBinding.id, "already targets Event merge");
        } else {
            report(
                "failed",
                "binding consumer relink",
                peopleBinding.id,
                `unexpected consumer links: ${state.current.join(", ") || "none"}`
            );
        }
    }

    // Ensure conflict creation now targets the promoted replacement setup.
    const conflictBinding = mappingRecordsByBindingId.get("BIND-SX-005");
    if (!conflictBinding || !conflictSource) {
        report(
            "failed",
            "conflict binding consumer link",
            conflictBinding?.id || "BIND-SX-005",
            "binding or promoted Conflict setup not found"
        );
    } else {
        ensureSingleLink(
            states,
            "mappings",
            conflictBinding,
            CONFIG.fields.mappings.consumerSetup,
            conflictSource.id,
            "conflict binding consumer link"
        );
        report(
            "informational",
            "conflict binding consumer step",
            conflictBinding.id,
            "consumerStep is still Step X; change this scalar value to Step 4"
        );
    }

    // Repair the one high-confidence canonical parent link whose parent exists.
    const keyMapByPath = new Map();
    for (const record of keyMapQuery.records) {
        const key = record.getCellValueAsString(CONFIG.fields.keyMap.jsonKey).trim();
        if (key) keyMapByPath.set(key, record);
    }
    const existingCompletion = keyMapByPath.get(
        "conflictWorkflow.comparison.existingCompletionId"
    );
    const comparisonParent = keyMapByPath.get("conflictWorkflow.comparison");
    if (!existingCompletion || !comparisonParent) {
        report(
            "failed",
            "keyMap parent relink",
            existingCompletion?.id || "conflictWorkflow.comparison.existingCompletionId",
            `child or parent missing; parent found=${Boolean(comparisonParent)}`
        );
    } else {
        ensureSingleLink(
            states,
            "keyMap",
            existingCompletion,
            CONFIG.fields.keyMap.parentKey,
            comparisonParent.id,
            "keyMap parent relink"
        );
    }

    const suggestedValuesParent = keyMapByPath.get(
        "conflictWorkflow.comparison.suggestedValues"
    );
    if (!suggestedValuesParent) {
        report(
            "failed",
            "keyMap parent relink",
            "conflictWorkflow.comparison.suggestedValues",
            "parent keyMap record is missing; three child links were skipped"
        );
    }

    const formerOrphanIds = [
        "rec4b8Zgfw7Ja2NcO",
        "rec1p0ZJgCNK9jsok",
        "recjrvuLCkLCngm1K",
        "recwwiQmEGmJx3cau",
        "recaJ31SFE52IHtQk",
    ];
    const remainingOrphanIds = formerOrphanIds.filter(id =>
        tableConfigRecords.has(id)
    );
    if (remainingOrphanIds.length) {
        report(
            "informational",
            "orphan cleanup",
            remainingOrphanIds.join(", "),
            "former setup records still exist; this script does not delete them"
        );
    } else {
        report(
            "alreadyCorrect",
            "orphan cleanup",
            "tableConfigSetups",
            "all five former orphan/obsolete setup records are absent"
        );
    }
    report(
        "informational",
        "non-link cleanup",
        CONFIG.knownCompleteSetups.conflictCreate,
        "set step=4 and populate keyMap/includeKeys/config output; its manual Label is already Step 4"
    );

    const changedStates = [...states.values()].filter(stateChanged);
    output.markdown("## Planned link changes");
    output.table(results.planned);
    output.markdown("## Already correct");
    output.table(results.alreadyCorrect);
    output.markdown("## Skipped / failed");
    output.table(results.failed);
    output.markdown("## Informational");
    output.table(results.informational);

    if (!changedStates.length) {
        output.markdown("No link changes are required.");
        return;
    }

    const action = await input.buttonsAsync(
        `Apply ${changedStates.length} record-field link update(s)?`,
        [
            { label: "Apply repairs", value: "apply" },
            { label: "Report only", value: "report" },
        ]
    );

    if (action !== "apply") {
        output.markdown("Report-only run complete. No records were changed.");
        return;
    }

    const tableByKey = {
        fieldConfigs: fieldConfigsTable,
        tableConfigs: tableConfigsTable,
        mappings: mappingsTable,
        keyMap: keyMapTable,
    };
    const updatesByTable = new Map();

    for (const state of changedStates) {
        if (!updatesByTable.has(state.tableKey)) {
            updatesByTable.set(state.tableKey, new Map());
        }
        const records = updatesByTable.get(state.tableKey);
        if (!records.has(state.recordId)) {
            records.set(state.recordId, { id: state.recordId, fields: {} });
        }
        records.get(state.recordId).fields[state.fieldId] =
            state.current.map(id => ({ id }));
    }

    const applied = [];
    for (const [tableKey, records] of updatesByTable) {
        const updates = [...records.values()];
        try {
            await updateInChunks(tableByKey[tableKey], updates);
            applied.push({ table: tableByKey[tableKey].name, records: updates.length });
        } catch (error) {
            report(
                "informational",
                "batch fallback",
                tableByKey[tableKey].name,
                `batch failed (${error.message}); retrying records individually`
            );

            let appliedCount = 0;
            for (const update of updates) {
                try {
                    await tableByKey[tableKey].updateRecordAsync(
                        update.id,
                        update.fields
                    );
                    appliedCount += 1;
                } catch (recordError) {
                    report(
                        "failed",
                        "apply record links",
                        update.id,
                        `${tableByKey[tableKey].name}: ${recordError.message}`
                    );
                }
            }
            applied.push({
                table: tableByKey[tableKey].name,
                records: appliedCount,
            });
        }
    }

    output.markdown("## Applied");
    output.table(applied);
    output.markdown("## Final skipped / failed report");
    output.table(results.failed);
}

await main();
