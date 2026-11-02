/************************************************************
Resolver Config Schema Validator

Purpose:
- Select one [🤖Event_Resolver] row.
- Parse config JSON fields.
- Validate referenced tables exist.
- Validate referenced fields exist on the referenced tables.
- Validate field types match declared fieldType.
- Optionally validate referenced recordIds exist.

Run from Airtable Scripting Extension.
************************************************************/

const CONFIG = {
    resolverTableNameOrId: "[🤖Event_Resolver]",

    configFieldNames: [
        "step1_config",
        "step2_config",
        "step3_config",
        "stepX⁉️_Config",
        "step4_config",
    ],

    validateRecordIds: true,
};

function safeJsonParse(text) {
    try {
        return {
            ok: true,
            value: JSON.parse(text),
            error: "",
        };
    } catch (err) {
        return {
            ok: false,
            value: null,
            error: err.message,
        };
    }
}

function getTableSafe(tableId) {
    try {
        return {
            ok: true,
            table: base.getTable(tableId),
            error: "",
        };
    } catch (err) {
        return {
            ok: false,
            table: null,
            error: err.message,
        };
    }
}

function getFieldSafe(table, fieldId) {
    if (!table) {
        return {
            ok: false,
            field: null,
            error: "No table loaded",
        };
    }

    const field = table.fields.find(f => f.id === fieldId);

    if (!field) {
        return {
            ok: false,
            field: null,
            error: `Field not found on table ${table.name}: ${fieldId}`,
        };
    }

    return {
        ok: true,
        field,
        error: "",
    };
}

async function recordExistsSafe(table, recordId) {
    if (!CONFIG.validateRecordIds) return true;
    if (!table || !recordId || !String(recordId).startsWith("rec")) return null;

    try {
        const record = await table.selectRecordAsync(recordId);
        return Boolean(record);
    } catch {
        return false;
    }
}

function asArray(value) {
    return Array.isArray(value) ? value : [];
}

function normalizeWriteFieldConfigs(fields) {
    const normalized = [];

    for (const fieldWrapper of asArray(fields)) {
        if (
            !fieldWrapper ||
            typeof fieldWrapper !== "object"
        ) {
            continue;
        }

        if (fieldWrapper.fieldId) {
            normalized.push(fieldWrapper);
            continue;
        }

        for (const fieldConfig of Object.values(fieldWrapper)) {
            if (
                fieldConfig &&
                typeof fieldConfig === "object"
            ) {
                normalized.push({
                    ...fieldConfig,
                    fieldType:
                        fieldConfig.fieldType ||
                        fieldConfig.type,
                });
            }
        }
    }

    return normalized;
}

function pushCheck(checks, check) {
    checks.push({
        status: check.status || "UNKNOWN",
        sourceConfig: check.sourceConfig || "",
        path: check.path || "",
        kind: check.kind || "",
        tableId: check.tableId || "",
        tableName: check.tableName || "",
        fieldId: check.fieldId || "",
        fieldName: check.fieldName || "",
        expectedType: check.expectedType || "",
        actualType: check.actualType || "",
        recordId: check.recordId || "",
        message: check.message || "",
    });
}

function collectSearchChecks(configName, searchName, searchConfig, checks) {
    const tableId = searchConfig.searchTableId;
    const tableResult = getTableSafe(tableId);

    pushCheck(checks, {
        status: tableResult.ok ? "PASS" : "FAIL",
        sourceConfig: configName,
        path: `${searchName}.searchTableId`,
        kind: "table",
        tableId,
        tableName: tableResult.table?.name || "",
        message: tableResult.ok ? "Table exists" : tableResult.error,
    });

    if (!tableResult.ok) return;

    const table = tableResult.table;

    const primaryFieldId = searchConfig.searchPrimaryFieldId;
    const primaryFieldResult = getFieldSafe(table, primaryFieldId);

    pushCheck(checks, {
        status: primaryFieldResult.ok ? "PASS" : "FAIL",
        sourceConfig: configName,
        path: `${searchName}.searchPrimaryFieldId`,
        kind: "field",
        tableId,
        tableName: table.name,
        fieldId: primaryFieldId,
        fieldName: primaryFieldResult.field?.name || "",
        actualType: primaryFieldResult.field?.type || "",
        message: primaryFieldResult.ok ? "Primary search field exists on search table" : primaryFieldResult.error,
    });

    for (const fieldId of asArray(searchConfig.searchDeepFieldIds)) {
        const deepFieldResult = getFieldSafe(table, fieldId);

        pushCheck(checks, {
            status: deepFieldResult.ok ? "PASS" : "FAIL",
            sourceConfig: configName,
            path: `${searchName}.searchDeepFieldIds[]`,
            kind: "field",
            tableId,
            tableName: table.name,
            fieldId,
            fieldName: deepFieldResult.field?.name || "",
            actualType: deepFieldResult.field?.type || "",
            message: deepFieldResult.ok ? "Deep search field exists on search table" : deepFieldResult.error,
        });
    }
}

async function collectWriteChecks(configName, writeName, writeConfig, checks) {
    for (const destination of asArray(writeConfig.writeTo)) {
        const tableId = destination.tableId;
        const tableResult = getTableSafe(tableId);

        pushCheck(checks, {
            status: tableResult.ok ? "PASS" : "FAIL",
            sourceConfig: configName,
            path: `${writeName}.writeTo[].tableId`,
            kind: "table",
            tableId,
            tableName: tableResult.table?.name || "",
            message: tableResult.ok ? "Destination table exists" : tableResult.error,
        });

        if (!tableResult.ok) continue;

        const table = tableResult.table;

        if (destination.recordId) {
            const exists = await recordExistsSafe(table, destination.recordId);

            pushCheck(checks, {
                status: exists === true ? "PASS" : exists === false ? "FAIL" : "SKIP",
                sourceConfig: configName,
                path: `${writeName}.writeTo[].recordId`,
                kind: "record",
                tableId,
                tableName: table.name,
                recordId: destination.recordId,
                message:
                    exists === true
                        ? "Record exists"
                        : exists === false
                            ? "Record not found on destination table"
                            : "Record validation skipped",
            });
        }

        for (const fieldConfig of normalizeWriteFieldConfigs(destination.fields)) {
            const fieldId = fieldConfig.fieldId;
            const expectedType = fieldConfig.fieldType || fieldConfig.type;
            const fieldResult = getFieldSafe(table, fieldId);
            const actualType = fieldResult.field?.type || "";

            pushCheck(checks, {
                status:
                    fieldResult.ok && (!expectedType || expectedType === actualType)
                        ? "PASS"
                        : "FAIL",
                sourceConfig: configName,
                path: `${writeName}.writeTo[].fields[]`,
                kind: "field",
                tableId,
                tableName: table.name,
                fieldId,
                fieldName: fieldResult.field?.name || "",
                expectedType,
                actualType,
                message:
                    !fieldResult.ok
                        ? fieldResult.error
                        : expectedType && expectedType !== actualType
                            ? `Type mismatch. Expected ${expectedType}, got ${actualType}`
                            : "Field exists on destination table and type matches",
            });
        }
    }
}

function collectStepXChecks(configName, stepX, checks) {
    if (!stepX || typeof stepX !== "object") return;

    const completionTableResult = getTableSafe(stepX.completionTableId);

    pushCheck(checks, {
        status: completionTableResult.ok ? "PASS" : "FAIL",
        sourceConfig: configName,
        path: "stepX.completionTableId",
        kind: "table",
        tableId: stepX.completionTableId,
        tableName: completionTableResult.table?.name || "",
        message: completionTableResult.ok ? "Completion table exists" : completionTableResult.error,
    });

    if (completionTableResult.ok && stepX.completionEventLinkFieldId) {
        const fieldResult = getFieldSafe(
            completionTableResult.table,
            stepX.completionEventLinkFieldId
        );

        pushCheck(checks, {
            status: fieldResult.ok ? "PASS" : "FAIL",
            sourceConfig: configName,
            path: "stepX.completionEventLinkFieldId",
            kind: "field",
            tableId: stepX.completionTableId,
            tableName: completionTableResult.table.name,
            fieldId: stepX.completionEventLinkFieldId,
            fieldName: fieldResult.field?.name || "",
            actualType: fieldResult.field?.type || "",
            message: fieldResult.ok ? "Completion event-link field exists" : fieldResult.error,
        });
    }

    const eventTableResult = getTableSafe(stepX.eventTableId);

    pushCheck(checks, {
        status: eventTableResult.ok ? "PASS" : "FAIL",
        sourceConfig: configName,
        path: "stepX.eventTableId",
        kind: "table",
        tableId: stepX.eventTableId,
        tableName: eventTableResult.table?.name || "",
        message: eventTableResult.ok ? "Event table exists" : eventTableResult.error,
    });

    if (!eventTableResult.ok) return;

    for (const [key, fieldConfig] of Object.entries(stepX.eventFields || {})) {
        const fieldResult = getFieldSafe(eventTableResult.table, fieldConfig.fieldId);
        const actualType = fieldResult.field?.type || "";
        const expectedType = fieldConfig.fieldType;

        pushCheck(checks, {
            status:
                fieldResult.ok && (!expectedType || expectedType === actualType)
                    ? "PASS"
                    : "FAIL",
            sourceConfig: configName,
            path: `stepX.eventFields.${key}`,
            kind: "field",
            tableId: stepX.eventTableId,
            tableName: eventTableResult.table.name,
            fieldId: fieldConfig.fieldId,
            fieldName: fieldResult.field?.name || "",
            expectedType,
            actualType,
            message:
                !fieldResult.ok
                    ? fieldResult.error
                    : expectedType && expectedType !== actualType
                        ? `Type mismatch. Expected ${expectedType}, got ${actualType}`
                        : "Step X event field exists and type matches",
        });
    }
}

async function collectStep4Checks(configName, step4, checks) {
    const createTableId = step4.createTableId;
    const tableResult = getTableSafe(createTableId);

    pushCheck(checks, {
        status: tableResult.ok ? "PASS" : "FAIL",
        sourceConfig: configName,
        path: "step4.createTableId",
        kind: "table",
        tableId: createTableId,
        tableName: tableResult.table?.name || "",
        message: tableResult.ok ? "Create table exists" : tableResult.error,
    });

    if (tableResult.ok) {
        const table = tableResult.table;

        for (const fieldConfig of asArray(step4.createRecord?.fields)) {
            const fieldId = fieldConfig.fieldId;
            const expectedType = fieldConfig.fieldType;
            const fieldResult = getFieldSafe(table, fieldId);
            const actualType = fieldResult.field?.type || "";

            pushCheck(checks, {
                status:
                    fieldResult.ok && (!expectedType || expectedType === actualType)
                        ? "PASS"
                        : "FAIL",
                sourceConfig: configName,
                path: "step4.createRecord.fields[]",
                kind: "field",
                tableId: createTableId,
                tableName: table.name,
                fieldId,
                fieldName: fieldResult.field?.name || "",
                expectedType,
                actualType,
                message:
                    !fieldResult.ok
                        ? fieldResult.error
                        : expectedType && expectedType !== actualType
                            ? `Type mismatch. Expected ${expectedType}, got ${actualType}`
                            : "Create field exists on create table and type matches",
            });
        }
    }

    for (const writeBlock of asArray(step4.writeCreatedRecordTo)) {
        await collectWriteChecks(
            configName,
            "step4.writeCreatedRecordTo",
            { writeTo: [writeBlock] },
            checks
        );
    }
}

async function collectChecksFromParsedConfig(configName, parsed, checks) {
    if (parsed.step1) {
        for (const item of asArray(parsed.step1)) {
            for (const [searchName, searchConfig] of Object.entries(item)) {
                collectSearchChecks(configName, searchName, searchConfig, checks);
            }
        }
    }

    if (parsed.step2?.fieldWrites) {
        for (const writeConfig of asArray(parsed.step2.fieldWrites)) {
            await collectWriteChecks(
                configName,
                writeConfig.writeName || "unnamedWrite",
                writeConfig,
                checks
            );
        }
    }

    if (parsed.step2?.writeList) {
        for (const destination of asArray(parsed.step2.writeList)) {
            await collectWriteChecks(
                configName,
                destination.writeName ||
                    destination.table ||
                    destination.tableId ||
                    "unnamedDestination",
                { writeTo: [destination] },
                checks
            );
        }
    }

    if (parsed.step3) {
        for (const item of asArray(parsed.step3)) {
            for (const [searchName, searchConfig] of Object.entries(item)) {
                collectSearchChecks(configName, searchName, searchConfig, checks);
            }
        }
    }

    if (parsed.stepX) {
        collectStepXChecks(configName, parsed.stepX, checks);
    }

    if (parsed.step4) {
        await collectStep4Checks(configName, parsed.step4, checks);
    }

    if (
        parsed.searchTableId &&
        parsed.searchPrimaryFieldId
    ) {
        collectSearchChecks(configName, "standaloneSearchConfig", parsed, checks);
    }

    if (
        parsed.writeName &&
        parsed.writeTo
    ) {
        await collectWriteChecks(configName, parsed.writeName, parsed, checks);
    }

    if (
        parsed.createTableId ||
        parsed.createRecord ||
        parsed.writeCreatedRecordTo
    ) {
        await collectStep4Checks(configName, parsed, checks);
    }
}

/************************************************************
Main
************************************************************/

const resolverTable = base.getTable(CONFIG.resolverTableNameOrId);
const resolverRecord = await input.recordAsync(
    "Choose the resolver row to validate",
    resolverTable
);

if (!resolverRecord) {
    output.markdown("No resolver row selected.");
    return;
}

const checks = [];
const parseResults = [];

for (const fieldName of CONFIG.configFieldNames) {
    const field = resolverTable.fields.find(f => f.name === fieldName);
    if (!field) continue;

    const raw = resolverRecord.getCellValueAsString(field).trim();
    if (!raw) continue;

    const parsed = safeJsonParse(raw);

    parseResults.push({
        fieldName,
        ok: parsed.ok,
        error: parsed.error,
    });

    if (!parsed.ok) {
        pushCheck(checks, {
            status: "FAIL",
            sourceConfig: fieldName,
            path: "JSON.parse",
            kind: "json",
            message: parsed.error,
        });
        continue;
    }

    await collectChecksFromParsedConfig(fieldName, parsed.value, checks);
}

const failures = checks.filter(c => c.status === "FAIL");
const passes = checks.filter(c => c.status === "PASS");
const skipped = checks.filter(c => c.status === "SKIP");

output.markdown(`
# Resolver Config Validation

Resolver row: **${resolverRecord.name}**

Parsed config fields: **${parseResults.filter(r => r.ok).length}**  
JSON parse failures: **${parseResults.filter(r => !r.ok).length}**

Checks passed: **${passes.length}**  
Checks failed: **${failures.length}**  
Checks skipped: **${skipped.length}**
`);

if (parseResults.some(r => !r.ok)) {
    output.markdown(`## JSON Parse Failures`);

    output.table(
        parseResults
            .filter(r => !r.ok)
            .map(r => ({
                configField: r.fieldName,
                error: r.error,
            }))
    );
}

if (failures.length) {
    output.markdown(`## Failures`);

    output.table(
        failures.map(c => ({
            sourceConfig: c.sourceConfig,
            path: c.path,
            kind: c.kind,
            tableId: c.tableId,
            tableName: c.tableName,
            fieldId: c.fieldId,
            fieldName: c.fieldName,
            expectedType: c.expectedType,
            actualType: c.actualType,
            recordId: c.recordId,
            message: c.message,
        }))
    );
}

output.markdown(`## All Checks`);

output.table(
    checks.map(c => ({
        status: c.status,
        sourceConfig: c.sourceConfig,
        path: c.path,
        kind: c.kind,
        tableId: c.tableId,
        tableName: c.tableName,
        fieldId: c.fieldId,
        fieldName: c.fieldName,
        expectedType: c.expectedType,
        actualType: c.actualType,
        recordId: c.recordId,
        message: c.message,
    }))
);
