/************************************************************
Resolver Step 2 — Configured Field Writer

Resolver selection:
- First record in Active view:
  tbloJ5eN46v1Zx7AG / viwT48UlenhQ9OBbh

Dry-run checkbox:
- tbloJ5eN46v1Zx7AG / fld7UnBJIpVWFKr56

Dry-run meaning:
- Resolver-table writes execute.
- Business-table writes are simulated.

Writes:
- Configured fields
- context.state.step2
- fldFP6ESKhHj5AKSK persistent JSON run log
- 🤖Step 2 Message markdown summary
- canonicalContextJSON
************************************************************/

const CONFIG = {
    resolverTableId: "tbloJ5eN46v1Zx7AG",
    activeViewId: "viwT48UlenhQ9OBbh",

    contextFieldNameOrId: "canonicalContextJSON",

    runLogFieldId: "fldFP6ESKhHj5AKSK",

    // Replace with a field ID later if desired.
    stepMessageFieldNameOrId: "🤖Step 2 Message",

    dryRunFieldId: "fld7UnBJIpVWFKr56",

    prettyPrintSpaces: 2,
};

/************************************************************
General helpers
************************************************************/

function isBlank(value) {
    return (
        value === undefined ||
        value === null ||
        value === "" ||
        (typeof value === "string" && value.trim() === "") ||
        (Array.isArray(value) && value.length === 0)
    );
}

function safeStringify(value, spaces = 2) {
    try {
        return JSON.stringify(value, null, spaces);
    } catch (error) {
        return `[Unable to stringify: ${error.message}]`;
    }
}

function getFieldFlexible(table, fieldToken) {
    if (!fieldToken) return null;

    return (
        table.fields.find(
            field =>
                field.id === fieldToken ||
                field.name === fieldToken
        ) || null
    );
}

function requiredField(table, fieldToken, label) {
    const field = getFieldFlexible(table, fieldToken);

    if (!field) {
        throw new Error(
            `${label} not found on ${table.name}: ${fieldToken}`
        );
    }

    return field;
}

function getPath(object, path) {
    if (!path) return undefined;

    return String(path)
        .split(".")
        .reduce((current, key) => {
            if (
                current === undefined ||
                current === null
            ) {
                return undefined;
            }

            return current[key];
        }, object);
}

function normalizeValueTokenPath(token) {
    if (typeof token !== "string") return "";

    const dottedMatch = token
        .trim()
        .match(/^_([A-Za-z]+)\.([^_]+)_$/);

    if (dottedMatch) {
        const namespaceMap = {
            output: "outputs",
            outputs: "outputs",
            input: "inputs",
            inputs: "inputs",
            debug: "debug",
            state: "state",
            meta: "meta",
            conflict: "conflictWorkflow",
            conflictWorkflow: "conflictWorkflow",
        };

        const namespace =
            namespaceMap[dottedMatch[1]] ||
            dottedMatch[1];

        return `${namespace}.${dottedMatch[2]}`;
    }

    const shorthandMatch = token
        .trim()
        .match(/^_([A-Za-z][A-Za-z0-9]*)$/);

    if (!shorthandMatch) return "";

    return `outputs.${shorthandMatch[1]}`;
}

function resolveConfiguredValue({
    writeConfig,
    fieldConfig,
    context,
}) {
    const sourceContract =
        fieldConfig.writeSource ||
        (
            fieldConfig.source &&
            typeof fieldConfig.source === "object"
                ? fieldConfig.source
                : null
        );

    if (sourceContract) {
        const sourcePath = sourceContract.path;
        let sourceValue = getPath(context, sourcePath);

        if (isBlank(sourceValue)) {
            const onMissing = sourceContract.onMissing ||
                (sourceContract.required ? "error" : "continue");

            if (onMissing === "useDefault") {
                sourceValue = sourceContract.defaultJSON;
            } else if (onMissing === "error" || onMissing === "manualReview") {
                throw new Error(
                    `${writeConfig.writeName} field ${fieldConfig.fieldId} ` +
                    `cannot resolve ${sourcePath} (${onMissing}).`
                );
            } else {
                sourceValue = undefined;
            }
        }

        return {
            sourcePath,
            sourceValue: applySourceTransform(
                sourceValue,
                sourceContract.transform || "identity"
            ),
            valueKind: "sourceContract",
            skipWrite: sourceValue === undefined,
        };
    }

    const fieldSourcePath =
        fieldConfig.source ||
        normalizeValueTokenPath(fieldConfig.value);

    if (fieldSourcePath) {
        return {
            sourcePath: fieldSourcePath,
            sourceValue: getPath(
                context,
                fieldSourcePath
            ),
            valueKind:
                fieldConfig.source
                    ? "fieldSource"
                    : "valueToken",
        };
    }

    if (
        Object.prototype.hasOwnProperty.call(
            fieldConfig,
            "value"
        )
    ) {
        return {
            sourcePath: "",
            sourceValue: fieldConfig.value,
            valueKind: "literal",
        };
    }

    if (writeConfig.source) {
        return {
            sourcePath: writeConfig.source,
            sourceValue: getPath(
                context,
                writeConfig.source
            ),
            valueKind: "writeSource",
        };
    }

    throw new Error(
        `${writeConfig.writeName} field ${fieldConfig.fieldId} is missing value or source.`
    );
}

function applySourceTransform(value, transform) {
    if (value === undefined) return undefined;

    switch (transform) {
        case "firstRecordId":
            return collectRecordIds(value)[0] || "";

        case "uniqueRecordIds":
        case "toRecordIdArray":
            return unique(collectRecordIds(value));

        case "ISODate": {
            if (isBlank(value)) return value;
            const date = new Date(value);
            if (Number.isNaN(date.getTime())) {
                throw new Error(`Cannot convert ${value} to an ISO date.`);
            }
            return date.toISOString();
        }

        case "JSON.stringify":
            return JSON.stringify(value);

        case "identity":
        default:
            return value;
    }
}

function unique(values) {
    return [...new Set((values || []).filter(Boolean))];
}

function normalizeFieldConfigs(fields) {
    const normalized = [];

    for (const fieldWrapper of fields || []) {
        if (
            !fieldWrapper ||
            typeof fieldWrapper !== "object"
        ) {
            continue;
        }

        if (fieldWrapper.fieldId) {
            normalized.push({
                ...fieldWrapper,
                mode: fieldWrapper.mode || fieldWrapper.writeMode,
                ...(
                    Object.prototype.hasOwnProperty.call(fieldWrapper, "writeValue")
                        ? { value: fieldWrapper.writeValue }
                        : {}
                ),
            });
            continue;
        }

        for (
            const [category, fieldConfig] of
            Object.entries(fieldWrapper)
        ) {
            if (
                !fieldConfig ||
                typeof fieldConfig !== "object"
            ) {
                continue;
            }

            const normalizedField = {
                category,
                ...fieldConfig,
                fieldType:
                    fieldConfig.fieldType ||
                    fieldConfig.type,
                mode:
                    fieldConfig.mode ||
                    fieldConfig.writeMode,
            };
            if (
                Object.prototype.hasOwnProperty.call(
                    fieldConfig,
                    "writeValue"
                )
            ) {
                normalizedField.value = fieldConfig.writeValue;
            }
            normalized.push(normalizedField);
        }
    }

    return normalized;
}

function resolveDestinationRecordId(
    destination,
    context,
    resolverTable
) {
    if (destination.recordSource) {
        const contract = typeof destination.recordSource === "string"
            ? { path: destination.recordSource }
            : destination.recordSource;
        const resolved = getPath(context, contract.path);
        return Array.isArray(resolved) ? resolved[0] || "" : resolved || "";
    }

    if (destination.recordId) {
        return destination.recordId;
    }

    if (destination.table === "eventTable") {
        return context.inputs?.currentEventRecordId;
    }

    if (
        destination.table === "logTable" ||
        destination.tableId === resolverTable.id
    ) {
        return (
            context.inputs?.resolverRecordId ||
            context.meta?.resolverRecordId
        );
    }

    return "";
}

function ensureWorkflowState(context) {
    context.state ||= {};

    for (const stepName of [
        "step1",
        "step2",
        "step3",
        "stepX",
        "step4",
    ]) {
        context.state[stepName] ||= {
            status: "notRun",
        };
    }

    context.state.errors ||= [];
    context.state.messages ||= [];
}

/************************************************************
Persistent run log helpers
************************************************************/

function parseRunLog(rawValue) {
    const emptyLog = {
        schema: "eventResolver.runLog.v1",
        log: [],
    };

    const text = String(rawValue || "").trim();

    if (!text) return emptyLog;

    try {
        const parsed = JSON.parse(text);

        if (Array.isArray(parsed)) {
            return {
                schema: "eventResolver.runLog.v1",
                log: parsed,
            };
        }

        if (
            parsed &&
            typeof parsed === "object" &&
            Array.isArray(parsed.log)
        ) {
            return {
                ...parsed,
                schema:
                    parsed.schema ||
                    "eventResolver.runLog.v1",
                log: parsed.log,
            };
        }

        return emptyLog;
    } catch {
        return emptyLog;
    }
}

function appendRunLog(runLog, entry) {
    runLog.schema = "eventResolver.runLog.v1";
    runLog.log ||= [];
    runLog.log.push(entry);
    runLog.updatedAt = new Date().toISOString();

    return runLog;
}

/************************************************************
Markdown summary
************************************************************/

function buildStep2Markdown({
    resolverRecord,
    activeRecordCount,
    dryRun,
    writes,
    writePlan,
    performedWrites,
    skippedWrites,
    executions,
    status,
    errorMessage = "",
}) {
    if (status === "error") {
        return [
            "# Step 2 Error",
            "",
            `Resolver row: **${resolverRecord.name}**`,
            "",
            `Resolver record: \`${resolverRecord.id}\``,
            "",
            `Active records: **${activeRecordCount}**`,
            "",
            `Dry run: **${dryRun}**`,
            "",
            `Error: **${errorMessage}**`,
        ].join("\n");
    }

    return [
        "# Step 2 Complete",
        "",
        `Resolver row: **${resolverRecord.name}**`,
        "",
        `Resolver record: \`${resolverRecord.id}\``,
        "",
        `Active records: **${activeRecordCount}**`,
        "",
        `Dry run: **${dryRun}**`,
        "",
        `Write groups: **${writes.length}**`,
        "",
        `Writes planned: **${writePlan.length}**`,
        "",
        `Writes performed: **${performedWrites.length}**`,
        "",
        `Business-table writes simulated: **${skippedWrites.length}**`,
        "",
        `Destinations updated: **${executions.length}**`,
    ].join("\n");
}

/************************************************************
Source/value normalization
************************************************************/

function collectRecordIds(value) {
    const results = [];

    function collect(item) {
        if (isBlank(item)) return;

        if (Array.isArray(item)) {
            for (const child of item) {
                collect(child);
            }

            return;
        }

        if (typeof item === "object") {
            if (item.id) {
                collect(item.id);
            }

            return;
        }

        const text = String(item).trim();
        if (!text) return;

        try {
            const parsed = JSON.parse(text);

            if (
                Array.isArray(parsed) ||
                (parsed && typeof parsed === "object")
            ) {
                collect(parsed);
                return;
            }
        } catch {}

        text
            .replace(/^\[|\]$/g, "")
            .split(/[,;\n|]+/)
            .map(part =>
                part.replace(/^"|"$/g, "").trim()
            )
            .filter(Boolean)
            .forEach(part => {
                if (
                    /^rec[A-Za-z0-9]{14}$/.test(part)
                ) {
                    results.push(part);
                }
            });
    }

    collect(value);

    return unique(results);
}

function normalizeArray(value) {
    if (isBlank(value)) return [];

    return Array.isArray(value)
        ? value.filter(item => !isBlank(item))
        : [value];
}

function serializeValue(value, fieldType) {
    switch (fieldType) {
        case "multipleRecordLinks":
            return collectRecordIds(value)
                .map(id => ({ id }));

        case "singleSelect":
            if (isBlank(value)) return null;

            if (
                typeof value === "object" &&
                value !== null &&
                value.name
            ) {
                return {
                    name: String(value.name),
                };
            }

            return {
                name: String(value),
            };

        case "multipleSelects":
            return normalizeArray(value).map(item => {
                if (
                    typeof item === "object" &&
                    item !== null &&
                    item.name
                ) {
                    return {
                        name: String(item.name),
                    };
                }

                return {
                    name: String(item),
                };
            });

        case "checkbox":
            return Boolean(value);

        case "number":
        case "currency":
        case "percent":
        case "duration":
            return isBlank(value)
                ? null
                : Number(value);

        case "date":
        case "dateTime":
            return isBlank(value)
                ? null
                : value;

        case "singleLineText":
        case "multilineText":
        case "email":
        case "url":
        case "phoneNumber": {
            const recordIds =
                collectRecordIds(value);

            if (recordIds.length) {
                return recordIds.join(",");
            }

            if (Array.isArray(value)) {
                return value
                    .map(item =>
                        typeof item === "object"
                            ? safeStringify(item, 0)
                            : String(item)
                    )
                    .join(",");
            }

            if (
                typeof value === "object" &&
                value !== null
            ) {
                if (value.id) {
                    return String(value.id);
                }

                if (value.name) {
                    return String(value.name);
                }

                return safeStringify(value, 0);
            }

            return isBlank(value)
                ? ""
                : String(value);
        }

        default:
            return value;
    }
}

/************************************************************
Write modes
************************************************************/

function mergeUnique(
    existingValue,
    incomingValue,
    fieldType
) {
    if (fieldType === "multipleRecordLinks") {
        return unique([
            ...collectRecordIds(existingValue),
            ...collectRecordIds(incomingValue),
        ]).map(id => ({ id }));
    }

    const combined = [
        ...normalizeArray(existingValue),
        ...normalizeArray(incomingValue),
    ].filter(item => !isBlank(item));

    const map = new Map();

    for (const item of combined) {
        const key =
            typeof item === "object"
                ? safeStringify(item, 0)
                : `${typeof item}:${String(item)}`;

        map.set(key, item);
    }

    return [...map.values()];
}

function clearValueForType(fieldType) {
    switch (fieldType) {
        case "multipleRecordLinks":
        case "multipleSelects":
            return [];

        case "checkbox":
            return false;

        default:
            return null;
    }
}

function applyWriteMode({
    existingValue,
    incomingValue,
    fieldType,
    mode,
}) {
    switch (mode) {
        case "clear":
            return clearValueForType(fieldType);

        case "ignoreIfBlank":
            if (isBlank(incomingValue)) {
                return existingValue;
            }

            return serializeValue(
                incomingValue,
                fieldType
            );

        case "appendUnique":
            return mergeUnique(
                existingValue,
                incomingValue,
                fieldType
            );

        case "append":
            if (
                fieldType === "multipleRecordLinks"
            ) {
                return [
                    ...collectRecordIds(existingValue),
                    ...collectRecordIds(incomingValue),
                ].map(id => ({ id }));
            }

            return [
                ...normalizeArray(existingValue),
                ...normalizeArray(incomingValue),
            ];

        case "replace":
        default:
            return serializeValue(
                incomingValue,
                fieldType
            );
    }
}

/************************************************************
Step 2 normalization
************************************************************/

function normalizeStep2Writes(step2Config) {
    const writes = [];

    if (
        step2Config?.schema === "eventResolver.engineConfig.v1" &&
        Array.isArray(step2Config.engines)
    ) {
        for (const engine of step2Config.engines) {
            if (!["Update", "Update Log"].includes(engine?.engine)) continue;

            for (const setup of engine.tables || []) {
                const table = setup?.table;
                if (!table?.tableId) continue;

                const destination = {
                    table: setup.role || engine.engine,
                    tableId: table.tableId,
                    recordId: table.recordId,
                    recordSource: table.recordSource,
                    fields: normalizeFieldConfigs(table.writeFields || []),
                };

                writes.push({
                    wrapperName: setup.role || setup.setupId,
                    writeName: setup.label || setup.role || setup.setupId,
                    writeTo: [destination],
                });
            }
        }

        return writes;
    }

    if (
        step2Config &&
        Array.isArray(step2Config.writeList)
    ) {
        for (
            const destination of
            step2Config.writeList
        ) {
            if (
                !destination ||
                typeof destination !== "object"
            ) {
                continue;
            }

            writes.push({
                wrapperName:
                    destination.table ||
                    destination.tableId ||
                    "unnamedDestination",
                writeName:
                    destination.writeName ||
                    destination.table ||
                    destination.tableId ||
                    "unnamedDestination",
                writeTo: [
                    {
                        ...destination,
                        fields: normalizeFieldConfigs(
                            destination.fields
                        ),
                    },
                ],
            });
        }

        return writes;
    }

    if (Array.isArray(step2Config)) {
        for (const wrapper of step2Config) {
            if (
                !wrapper ||
                typeof wrapper !== "object"
            ) {
                continue;
            }

            for (
                const [wrapperName, writeConfig] of
                Object.entries(wrapper)
            ) {
                if (
                    !writeConfig ||
                    typeof writeConfig !== "object"
                ) {
                    continue;
                }

                writes.push({
                    wrapperName,
                    writeName:
                        writeConfig.writeName ||
                        wrapperName,
                    ...writeConfig,
                    writeTo:
                        (writeConfig.writeTo || []).map(
                            destination => ({
                                ...destination,
                                fields: normalizeFieldConfigs(
                                    destination.fields
                                ),
                            })
                        ),
                });
            }
        }

        return writes;
    }

    if (
        step2Config &&
        Array.isArray(step2Config.fieldWrites)
    ) {
        for (
            const writeConfig of
            step2Config.fieldWrites
        ) {
            writes.push({
                wrapperName:
                    writeConfig.writeName ||
                    "unnamedWrite",
                ...writeConfig,
                writeTo:
                    (writeConfig.writeTo || []).map(
                        destination => ({
                            ...destination,
                            fields: normalizeFieldConfigs(
                                destination.fields
                            ),
                        })
                    ),
            });
        }

        return writes;
    }

    if (
        step2Config &&
        typeof step2Config === "object"
    ) {
        for (
            const [wrapperName, writeConfig] of
            Object.entries(step2Config)
        ) {
            if (
                !writeConfig ||
                typeof writeConfig !== "object"
            ) {
                continue;
            }

            writes.push({
                wrapperName,
                writeName:
                    writeConfig.writeName ||
                    wrapperName,
                ...writeConfig,
                writeTo:
                    (writeConfig.writeTo || []).map(
                        destination => ({
                            ...destination,
                            fields: normalizeFieldConfigs(
                                destination.fields
                            ),
                        })
                    ),
            });
        }
    }

    return writes;
}

/************************************************************
Write planning
************************************************************/

async function buildWritePlan(
    writes,
    context,
    resolverTable,
    isDryRun
) {
    const plans = [];

    for (const writeConfig of writes) {
        for (
            const destination of
            writeConfig.writeTo || []
        ) {
            const table = base.getTable(
                destination.tableId
            );

            const recordId =
                resolveDestinationRecordId(
                    destination,
                    context,
                    resolverTable
                );

            if (!recordId) {
                throw new Error(
                    `${writeConfig.writeName} destination is missing recordId.`
                );
            }

            const isResolverDestination =
                table.id === resolverTable.id;

            const shouldExecute =
                !isDryRun ||
                isResolverDestination;

            const record =
                await table.selectRecordAsync(
                    recordId
                );

            if (!record) {
                throw new Error(
                    `Destination record not found: ${table.name}/${recordId}`
                );
            }

            for (
                const fieldConfig of
                destination.fields || []
            ) {
                const field = table.fields.find(
                    candidate =>
                        candidate.id ===
                        fieldConfig.fieldId
                );

                if (!field) {
                    throw new Error(
                        `Field ${fieldConfig.fieldId} not found on ${table.name}.`
                    );
                }

                if (
                    fieldConfig.fieldType &&
                    field.type !==
                    fieldConfig.fieldType
                ) {
                    throw new Error(
                        `Field type mismatch for ${table.name}.${field.name}. ` +
                        `Config says ${fieldConfig.fieldType}; Airtable says ${field.type}.`
                    );
                }

                const existingValue =
                    record.getCellValue(field);

                const {
                    sourcePath,
                    sourceValue,
                    valueKind,
                    skipWrite,
                } = resolveConfiguredValue({
                    writeConfig,
                    fieldConfig,
                    context,
                });

                if (skipWrite) continue;

                const serializedValue =
                    applyWriteMode({
                        existingValue,
                        incomingValue:
                            sourceValue,
                        fieldType:
                            fieldConfig.fieldType ||
                            field.type,
                        mode:
                            fieldConfig.mode ||
                            "replace",
                    });

                plans.push({
                    writeName:
                        writeConfig.writeName,

                    sourcePath,
                    sourceValue,
                    valueKind,

                    tableId: table.id,
                    tableName: table.name,
                    recordId,

                    fieldId: field.id,
                    fieldName: field.name,

                    fieldType:
                        fieldConfig.fieldType ||
                        field.type,

                    mode:
                        fieldConfig.mode ||
                        "replace",

                    isResolverDestination,
                    shouldExecute,

                    dryRunSkipped:
                        isDryRun &&
                        !isResolverDestination,

                    existingValue,
                    serializedValue,
                });
            }
        }
    }

    return plans;
}

/************************************************************
Execute write plan
************************************************************/

async function executeWritePlan(plans) {
    const tables = new Map();

    for (const plan of plans) {
        if (!plan.shouldExecute) continue;

        if (!tables.has(plan.tableId)) {
            tables.set(plan.tableId, {
                tableId: plan.tableId,
                tableName: plan.tableName,
                records: new Map(),
            });
        }

        const tableGroup =
            tables.get(plan.tableId);

        if (!tableGroup.records.has(plan.recordId)) {
            tableGroup.records.set(plan.recordId, {
                id: plan.recordId,
                fields: {},
            });
        }

        tableGroup.records.get(plan.recordId).fields[
            plan.fieldId
        ] = plan.serializedValue;
    }

    const executions = [];

    for (const tableGroup of tables.values()) {
        const table = base.getTable(
            tableGroup.tableId
        );

        const records = [
            ...tableGroup.records.values(),
        ];

        for (let index = 0; index < records.length; index += 50) {
            const batch = records.slice(
                index,
                index + 50
            );

            await table.updateRecordsAsync(batch);
        }

        executions.push({
            tableId: tableGroup.tableId,
            tableName: table.name,
            recordCount: records.length,
            recordIds:
                records.map(record => record.id),
            fieldIds: unique(
                records.flatMap(record =>
                    Object.keys(record.fields)
                )
            ),
        });
    }

    return executions;
}

/************************************************************
Resolver selection
************************************************************/

const resolverTable = base.getTable(
    CONFIG.resolverTableId
);

const activeView = resolverTable.views.find(
    view => view.id === CONFIG.activeViewId
);

if (!activeView) {
    throw new Error(
        `Active resolver view not found: ${CONFIG.activeViewId}`
    );
}

const activeQuery =
    await activeView.selectRecordsAsync();

const resolverRecord =
    activeQuery.records[0];

if (!resolverRecord) {
    throw new Error(
        `No resolver records found in Active view ${CONFIG.activeViewId}.`
    );
}

if (activeQuery.records.length > 1) {
    console.warn(
        `Active view contains ${activeQuery.records.length} records. ` +
        `Using first record: ${resolverRecord.id}`
    );
}

/************************************************************
Load fields and context
************************************************************/

const contextField = requiredField(
    resolverTable,
    CONFIG.contextFieldNameOrId,
    "Canonical context field"
);

const runLogField = requiredField(
    resolverTable,
    CONFIG.runLogFieldId,
    "Run log field"
);

const stepMessageField = requiredField(
    resolverTable,
    CONFIG.stepMessageFieldNameOrId,
    "Step 2 message field"
);

const dryRunField = requiredField(
    resolverTable,
    CONFIG.dryRunFieldId,
    "Dry Run checkbox field"
);

const isDryRun =
    resolverRecord.getCellValue(
        dryRunField
    ) === true;

const rawContext = resolverRecord
    .getCellValueAsString(contextField)
    .trim();

if (!rawContext) {
    throw new Error(
        `${contextField.name} is blank. Run the Context Builder first.`
    );
}

let context;

try {
    context = JSON.parse(rawContext);
} catch (error) {
    throw new Error(
        `${contextField.name} contains invalid JSON: ${error.message}`
    );
}

const runLog = parseRunLog(
    resolverRecord.getCellValueAsString(
        runLogField
    )
);

if (!context.configs?.step2) {
    throw new Error(
        "context.configs.step2 is missing."
    );
}

context.outputs ||= {};
context.debug ||= {};
ensureWorkflowState(context);
context.meta ||= {};
context.meta.execution ||= {};

const writes = normalizeStep2Writes(
    context.configs.step2
);

if (!writes.length) {
    throw new Error(
        "No Step 2 write configurations were found."
    );
}

const startedAt =
    new Date().toISOString();

let writePlan = [];
let executions = [];

try {
    context.meta.execution.dryRun =
        isDryRun;

    context.meta.execution.step2StartedAt =
        startedAt;

    writePlan = await buildWritePlan(
        writes,
        context,
        resolverTable,
        isDryRun
    );

    executions = await executeWritePlan(
        writePlan
    );

    const performedWrites =
        writePlan.filter(
            plan => plan.shouldExecute
        );

    const skippedWrites =
        writePlan.filter(
            plan => plan.dryRunSkipped
        );

    const completedAt =
        new Date().toISOString();

    context.state.step2 = {
        status: "complete",
        dryRun: isDryRun,
        startedAt,
        completedAt,

        writeGroups: writes.length,
        writesPlanned: writePlan.length,
        writesPerformed:
            performedWrites.length,
        writesSkipped:
            skippedWrites.length,
        destinationsUpdated:
            executions.length,

        performed:
            performedWrites.map(plan => ({
                writeName: plan.writeName,
                sourcePath: plan.sourcePath,
                valueKind: plan.valueKind,
                tableId: plan.tableId,
                tableName: plan.tableName,
                recordId: plan.recordId,
                fieldId: plan.fieldId,
                fieldName: plan.fieldName,
                fieldType: plan.fieldType,
                mode: plan.mode,
                value:
                    plan.serializedValue,
            })),

        skipped:
            skippedWrites.map(plan => ({
                writeName: plan.writeName,
                sourcePath: plan.sourcePath,
                valueKind: plan.valueKind,
                tableId: plan.tableId,
                tableName: plan.tableName,
                recordId: plan.recordId,
                fieldId: plan.fieldId,
                fieldName: plan.fieldName,
                fieldType: plan.fieldType,
                mode: plan.mode,
                simulatedValue:
                    plan.serializedValue,
                reason:
                    "Dry run: destination is not the resolver table.",
            })),
    };

    context.state.messages.push({
        step: "step2",
        level: "info",
        timestamp: completedAt,
        message:
            isDryRun
                ? `Step 2 dry run completed. ${skippedWrites.length} business-table writes simulated.`
                : `Step 2 completed. ${performedWrites.length} writes performed.`,
    });

    context.meta.updatedAt = completedAt;
    context.meta.lastCompletedStep = "step2";

    context.meta.execution.step2CompletedAt =
        completedAt;

    appendRunLog(runLog, {
        timestamp: completedAt,
        step: "step2",
        status: "complete",
        dryRun: isDryRun,

        resolver: {
            tableId: resolverTable.id,
            viewId: activeView.id,
            recordId: resolverRecord.id,
            recordName: resolverRecord.name,
            activeRecordCount:
                activeQuery.records.length,
        },

        summary: {
            writeGroups: writes.length,
            writesPlanned:
                writePlan.length,
            writesPerformed:
                performedWrites.length,
            writesSkipped:
                skippedWrites.length,
            destinationsUpdated:
                executions.length,
        },

        performedWrites:
            performedWrites.map(plan => ({
                writeName: plan.writeName,
                sourcePath: plan.sourcePath,
                valueKind: plan.valueKind,
                sourceValue: plan.sourceValue,
                tableId: plan.tableId,
                tableName: plan.tableName,
                recordId: plan.recordId,
                fieldId: plan.fieldId,
                fieldName: plan.fieldName,
                fieldType: plan.fieldType,
                mode: plan.mode,
                value:
                    plan.serializedValue,
            })),

        skippedWrites:
            skippedWrites.map(plan => ({
                writeName: plan.writeName,
                sourcePath: plan.sourcePath,
                valueKind: plan.valueKind,
                sourceValue: plan.sourceValue,
                tableId: plan.tableId,
                tableName: plan.tableName,
                recordId: plan.recordId,
                fieldId: plan.fieldId,
                fieldName: plan.fieldName,
                fieldType: plan.fieldType,
                mode: plan.mode,
                simulatedValue:
                    plan.serializedValue,
                reason:
                    "Dry run: business-table write skipped.",
            })),

        executions,
    });

    const markdownMessage =
        buildStep2Markdown({
            resolverRecord,
            activeRecordCount:
                activeQuery.records.length,
            dryRun: isDryRun,
            writes,
            writePlan,
            performedWrites,
            skippedWrites,
            executions,
            status: "complete",
        });

    await resolverTable.updateRecordAsync(
        resolverRecord.id,
        {
            [contextField.id]:
                safeStringify(
                    context,
                    CONFIG.prettyPrintSpaces
                ),

            [runLogField.id]:
                safeStringify(
                    runLog,
                    CONFIG.prettyPrintSpaces
                ),

            [stepMessageField.id]:
                markdownMessage,
        }
    );

    output.markdown(markdownMessage);

    output.table(
        writePlan.map(plan => ({
            status:
                plan.shouldExecute
                    ? "WRITTEN"
                    : "SIMULATED",

            writeName:
                plan.writeName,

            source:
                plan.sourcePath,

            valueKind:
                plan.valueKind,

            table:
                plan.tableName,

            recordId:
                plan.recordId,

            field:
                plan.fieldName,

            fieldType:
                plan.fieldType,

            mode:
                plan.mode,

            value:
                safeStringify(
                    plan.serializedValue,
                    0
                ),
        }))
    );

    console.log({
        step: "step2",
        status: "complete",
        resolverRecordId:
            resolverRecord.id,
        activeRecordCount:
            activeQuery.records.length,
        dryRun: isDryRun,
        writes,
        writePlan,
        executions,
        state: context.state.step2,
        runLog,
    });
} catch (error) {
    const failedAt =
        new Date().toISOString();

    context.state.step2 = {
        status: "error",
        dryRun: isDryRun,
        startedAt,
        failedAt,
        message: error.message,
    };

    context.state.errors.push({
        step: "step2",
        timestamp: failedAt,
        message: error.message,
        stack: error.stack || "",
    });

    context.state.messages.push({
        step: "step2",
        level: "error",
        timestamp: failedAt,
        message: error.message,
    });

    context.meta.updatedAt = failedAt;

    appendRunLog(runLog, {
        timestamp: failedAt,
        step: "step2",
        status: "error",
        dryRun: isDryRun,

        resolver: {
            tableId: resolverTable.id,
            viewId: activeView.id,
            recordId: resolverRecord.id,
            recordName: resolverRecord.name,
            activeRecordCount:
                activeQuery.records.length,
        },

        error: {
            message: error.message,
            stack: error.stack || "",
        },

        partialWritePlan:
            writePlan,

        partialExecutions:
            executions,
    });

    const markdownMessage =
        buildStep2Markdown({
            resolverRecord,
            activeRecordCount:
                activeQuery.records.length,
            dryRun: isDryRun,
            writes,
            writePlan,
            performedWrites: [],
            skippedWrites: [],
            executions,
            status: "error",
            errorMessage: error.message,
        });

    await resolverTable.updateRecordAsync(
        resolverRecord.id,
        {
            [contextField.id]:
                safeStringify(
                    context,
                    CONFIG.prettyPrintSpaces
                ),

            [runLogField.id]:
                safeStringify(
                    runLog,
                    CONFIG.prettyPrintSpaces
                ),

            [stepMessageField.id]:
                markdownMessage,
        }
    );

    output.markdown(markdownMessage);

    console.log({
        step: "step2",
        status: "error",
        resolverRecordId:
            resolverRecord.id,
        dryRun: isDryRun,
        error,
        writePlan,
        executions,
        runLog,
    });

    throw error;
}
