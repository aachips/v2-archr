/************************************************************
Resolver Step 1 — Search Runner

Resolver selection:
- First record in Active view:
  tbloJ5eN46v1Zx7AG / viwT48UlenhQ9OBbh

Reads:
- canonicalContextJSON
- context.configs.step1

Writes:
- context.outputs.*
- visible found* resolver fields
- context.state.step1
- fldFP6ESKhHj5AKSK persistent JSON run log
- fldF6nFTS9TKNZSTl markdown Step 1 message
- canonicalContextJSON
************************************************************/

const CONFIG = {
    resolverTableId: "tbloJ5eN46v1Zx7AG",
    activeViewId: "viwT48UlenhQ9OBbh",

    contextFieldNameOrId: "canonicalContextJSON",

    runLogFieldId: "fldFP6ESKhHj5AKSK",
    stepMessageFieldId: "fldF6nFTS9TKNZSTl",

    outputFields: {
        projectFound: "found🎯Project",
        taskFound: "found⚙️Tasks",
        orgFound: "found💜Org",
        personFound: "found💟People",
    },

    searchOutputMap: {
        projectSearch: "projectFound",
        taskSearch: "taskFound",
        orgSearch: "orgFound",
        personSearch: "personFound",
        completionSearch: "completionFound",
    },

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
            if (current === undefined || current === null) {
                return undefined;
            }

            return current[key];
        }, object);
}

function unique(values) {
    return [...new Set((values || []).filter(Boolean))];
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

function buildStep1Markdown({
    resolverRecord,
    activeRecordCount,
    results,
    status,
    errorMessage = "",
}) {
    if (status === "error") {
        return [
            "# Step 1 Error",
            "",
            `Resolver row: **${resolverRecord.name}**`,
            "",
            `Resolver record: \`${resolverRecord.id}\``,
            "",
            `Active records: **${activeRecordCount}**`,
            "",
            `Error: **${errorMessage}**`,
        ].join("\n");
    }

    const totalMatches = results.reduce(
        (sum, result) => sum + result.matchCount,
        0
    );

    const detailLines = results.map(result =>
        `- **${result.searchName}**: ${result.matchCount} match(es) via ${result.matchMethod}`
    );

    return [
        "# Step 1 Complete",
        "",
        `Resolver row: **${resolverRecord.name}**`,
        "",
        `Resolver record: \`${resolverRecord.id}\``,
        "",
        `Active records: **${activeRecordCount}**`,
        "",
        `Searches run: **${results.length}**`,
        "",
        `Total matched records: **${totalMatches}**`,
        "",
        ...detailLines,
    ].join("\n");
}

/************************************************************
Search-value helpers
************************************************************/

function normalizeValue(value) {
    return String(value ?? "")
        .trim()
        .replace(/\s+/g, " ")
        .toUpperCase();
}

function collectValueCandidates(value) {
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
                results.push(String(item.id).trim());
            }

            if (item.name) {
                results.push(String(item.name).trim());
            }

            if (!item.id && !item.name) {
                for (const child of Object.values(item)) {
                    collect(child);
                }
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
            .forEach(part => results.push(part));
    }

    collect(value);

    return unique(results);
}

function getRecordFieldCandidates(record, field) {
    return unique([
        ...collectValueCandidates(
            record.getCellValue(field)
        ),
        ...collectValueCandidates(
            record.getCellValueAsString(field)
        ),
    ]);
}

function getInputCandidates(context, jsonKey) {
    if (!jsonKey) return [];

    const directValue = context.inputs?.[jsonKey];

    if (!isBlank(directValue)) {
        return collectValueCandidates(directValue);
    }

    const pathValue = getPath(
        context.inputs,
        jsonKey
    );

    if (!isBlank(pathValue)) {
        return collectValueCandidates(pathValue);
    }

    const eventValue = getPath(
        context.inputs?.event || {},
        jsonKey
    );

    return collectValueCandidates(eventValue);
}

/************************************************************
Search execution
************************************************************/

function getFieldById(table, fieldId, label) {
    const field = table.fields.find(
        candidate => candidate.id === fieldId
    );

    if (!field) {
        throw new Error(
            `${label} not found on ${table.name}: ${fieldId}`
        );
    }

    return field;
}

function uniqueFields(fields) {
    const map = new Map();

    for (const field of fields) {
        if (field?.id) {
            map.set(field.id, field);
        }
    }

    return [...map.values()];
}

async function runSearch(
    searchName,
    searchConfig,
    context
) {
    const table = base.getTable(
        searchConfig.searchTableId
    );

    const primaryField = getFieldById(
        table,
        searchConfig.searchPrimaryFieldId,
        `${searchName}.searchPrimaryFieldId`
    );

    const deepFieldIds = Array.isArray(
        searchConfig.searchDeepFieldIds
    )
        ? searchConfig.searchDeepFieldIds
        : [];

    const deepFields = deepFieldIds.map(
        (fieldId, index) =>
            getFieldById(
                table,
                fieldId,
                `${searchName}.searchDeepFieldIds[${index}]`
            )
    );

    const query = await table.selectRecordsAsync({
        fields: uniqueFields([
            primaryField,
            ...deepFields,
        ]),
    });

    const primarySearchValues =
        getInputCandidates(
            context,
            searchConfig.jsonPrimaryKey
        );

    const primarySearchSet = new Set(
        primarySearchValues.map(normalizeValue)
    );

    let foundRecords = [];

    if (primarySearchSet.size) {
        for (const record of query.records) {
            const recordValues =
                getRecordFieldCandidates(
                    record,
                    primaryField
                );

            const matched = recordValues.some(value =>
                primarySearchSet.has(
                    normalizeValue(value)
                )
            );

            if (matched) {
                foundRecords.push(record);
            }
        }
    }

    let matchMethod = foundRecords.length
        ? "primary"
        : "none";

    let deepSearchValues = [];

    if (
        !foundRecords.length &&
        deepFields.length
    ) {
        const deepKeys = Array.isArray(
            searchConfig.jsonDeepKeys
        )
            ? searchConfig.jsonDeepKeys
            : [];

        deepSearchValues = unique(
            deepKeys.flatMap(key =>
                getInputCandidates(context, key)
            )
        );

        const deepSearchSet = new Set(
            deepSearchValues.map(normalizeValue)
        );

        if (deepSearchSet.size) {
            for (const record of query.records) {
                const matched = deepFields.some(field => {
                    const recordValues =
                        getRecordFieldCandidates(
                            record,
                            field
                        );

                    return recordValues.some(value =>
                        deepSearchSet.has(
                            normalizeValue(value)
                        )
                    );
                });

                if (matched) {
                    foundRecords.push(record);
                }
            }
        }

        if (foundRecords.length) {
            matchMethod = "deep";
        }
    }

    const recordIds = unique(
        foundRecords.map(record => record.id)
    );

    return {
        searchName,
        tableId: table.id,
        tableName: table.name,
        primaryFieldId: primaryField.id,
        deepFieldIds:
            deepFields.map(field => field.id),
        jsonPrimaryKey:
            searchConfig.jsonPrimaryKey || "",
        jsonDeepKeys:
            searchConfig.jsonDeepKeys || [],
        matchMethod,
        matchCount: recordIds.length,
        recordIds,
        primarySearchValues,
        deepSearchValues,
    };
}

/************************************************************
Step config normalization
************************************************************/

function normalizeSearchConfigs(stepConfig) {
    const searches = [];

    if (
        stepConfig?.schema === "eventResolver.engineConfig.v1" &&
        Array.isArray(stepConfig.engines)
    ) {
        for (const engine of stepConfig.engines) {
            if (engine?.engine !== "Search") continue;

            for (const setup of engine.tables || []) {
                const table = setup?.table;
                const searchFields = table?.searchFields;
                const primaryField = searchFields?.primaryField?.field;
                if (!table?.tableId || !primaryField?.fieldId) continue;

                const deepFields = (searchFields.deepFields || [])
                    .map(wrapper => wrapper?.field)
                    .filter(field => field?.fieldId);
                const outputPath = searchFields.outputPath || "";
                const fallbackName = outputPath
                    .split(".")
                    .filter(Boolean)
                    .pop() || `search_${setup.setupId}`;

                searches.push({
                    searchName: setup.role || fallbackName,
                    searchConfig: {
                        searchTableId: table.tableId,
                        searchPrimaryFieldId: primaryField.fieldId,
                        searchDeepFieldIds: deepFields.map(field => field.fieldId),
                        jsonPrimaryKey: (searchFields.primaryInputKeys || [])[0] || "",
                        jsonDeepKeys: searchFields.deepInputKeys || [],
                        outputPath,
                    },
                });
            }
        }

        return searches;
    }

    if (Array.isArray(stepConfig)) {
        for (const wrapper of stepConfig) {
            if (
                !wrapper ||
                typeof wrapper !== "object"
            ) {
                continue;
            }

            for (
                const [searchName, searchConfig] of
                Object.entries(wrapper)
            ) {
                searches.push({
                    searchName,
                    searchConfig,
                });
            }
        }

        return searches;
    }

    if (
        stepConfig &&
        typeof stepConfig === "object"
    ) {
        for (
            const [searchName, searchConfig] of
            Object.entries(stepConfig)
        ) {
            searches.push({
                searchName,
                searchConfig,
            });
        }
    }

    return searches;
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
    CONFIG.stepMessageFieldId,
    "Step 1 message field"
);

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

if (!context.configs?.step1) {
    throw new Error(
        "context.configs.step1 is missing."
    );
}

context.outputs ||= {};
context.debug ||= {};
ensureWorkflowState(context);
context.meta ||= {};

const searches = normalizeSearchConfigs(
    context.configs.step1
);

if (!searches.length) {
    throw new Error(
        "No Step 1 search configurations were found."
    );
}

const startedAt = new Date().toISOString();
const results = [];

try {
    for (const {
        searchName,
        searchConfig,
    } of searches) {
        const outputKey =
            searchConfig.outputKey ||
            searchConfig.outputPath
                ?.replace(/^outputs\./, "") ||
            CONFIG.searchOutputMap[searchName];

        if (!outputKey) {
            throw new Error(
                `No output mapping exists for ${searchName}.`
            );
        }

        const result = await runSearch(
            searchName,
            searchConfig,
            context
        );

        context.outputs[outputKey] =
            result.recordIds;

        context.debug[outputKey] =
            result.recordIds;

        results.push({
            ...result,
            outputKey,
        });
    }

    const completedAt =
        new Date().toISOString();

    const totalMatches = results.reduce(
        (sum, result) =>
            sum + result.matchCount,
        0
    );

    context.state.step1 = {
        status: "complete",
        startedAt,
        completedAt,
        searchesRun: results.length,
        totalMatches,
        results: results.map(result => ({
            searchName: result.searchName,
            outputKey: result.outputKey,
            tableId: result.tableId,
            tableName: result.tableName,
            matchMethod: result.matchMethod,
            matchCount: result.matchCount,
            recordIds: result.recordIds,
        })),
    };

    context.state.messages.push({
        step: "step1",
        level: "info",
        timestamp: completedAt,
        message:
            `Step 1 completed with ${results.length} searches.`,
    });

    context.meta.updatedAt = completedAt;
    context.meta.lastCompletedStep = "step1";

    const logEntry = {
        timestamp: completedAt,
        step: "step1",
        status: "complete",

        resolver: {
            tableId: resolverTable.id,
            viewId: activeView.id,
            recordId: resolverRecord.id,
            recordName: resolverRecord.name,
            activeRecordCount:
                activeQuery.records.length,
        },

        summary: {
            searchesRun: results.length,
            totalMatches,
        },

        results: results.map(result => ({
            searchName: result.searchName,
            outputKey: result.outputKey,
            tableId: result.tableId,
            tableName: result.tableName,
            primaryFieldId:
                result.primaryFieldId,
            deepFieldIds:
                result.deepFieldIds,
            jsonPrimaryKey:
                result.jsonPrimaryKey,
            jsonDeepKeys:
                result.jsonDeepKeys,
            matchMethod:
                result.matchMethod,
            matchCount:
                result.matchCount,
            recordIds:
                result.recordIds,
            primarySearchValues:
                result.primarySearchValues,
            deepSearchValues:
                result.deepSearchValues,
        })),

        outputs: {
            projectFound:
                context.outputs.projectFound || [],
            taskFound:
                context.outputs.taskFound || [],
            orgFound:
                context.outputs.orgFound || [],
            personFound:
                context.outputs.personFound || [],
        },
    };

    appendRunLog(runLog, logEntry);

    const markdownMessage =
        buildStep1Markdown({
            resolverRecord,
            activeRecordCount:
                activeQuery.records.length,
            results,
            status: "complete",
        });

    const updateFields = {
        [contextField.id]: safeStringify(
            context,
            CONFIG.prettyPrintSpaces
        ),

        [runLogField.id]: safeStringify(
            runLog,
            CONFIG.prettyPrintSpaces
        ),

        [stepMessageField.id]:
            markdownMessage,
    };

    for (
        const [outputKey, fieldToken] of
        Object.entries(CONFIG.outputFields)
    ) {
        const field = getFieldFlexible(
            resolverTable,
            fieldToken
        );

        if (!field) continue;

        const recordIds =
            context.outputs[outputKey] || [];

        if (field.type === "multipleRecordLinks") {
            updateFields[field.id] =
                recordIds.map(id => ({ id }));
        } else {
            updateFields[field.id] =
                recordIds.join(",");
        }
    }

    await resolverTable.updateRecordAsync(
        resolverRecord.id,
        updateFields
    );

    output.markdown(markdownMessage);

    output.table(
        results.map(result => ({
            searchName: result.searchName,
            outputKey: result.outputKey,
            tableName: result.tableName,
            matchMethod: result.matchMethod,
            matchCount: result.matchCount,
            recordIds:
                result.recordIds.join(", "),
            primarySearchValues:
                result.primarySearchValues.join(", "),
            deepSearchValues:
                result.deepSearchValues.join(", "),
        }))
    );

    console.log({
        step: "step1",
        status: "complete",
        resolverRecordId:
            resolverRecord.id,
        activeRecordCount:
            activeQuery.records.length,
        results,
        outputs: context.outputs,
        state: context.state.step1,
        runLog,
    });
} catch (error) {
    const failedAt =
        new Date().toISOString();

    context.state.step1 = {
        status: "error",
        startedAt,
        failedAt,
        message: error.message,
    };

    context.state.errors.push({
        step: "step1",
        timestamp: failedAt,
        message: error.message,
        stack: error.stack || "",
    });

    context.state.messages.push({
        step: "step1",
        level: "error",
        timestamp: failedAt,
        message: error.message,
    });

    context.meta.updatedAt = failedAt;

    appendRunLog(runLog, {
        timestamp: failedAt,
        step: "step1",
        status: "error",

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

        partialResults: results,

        outputs: {
            projectFound:
                context.outputs.projectFound || [],
            taskFound:
                context.outputs.taskFound || [],
            orgFound:
                context.outputs.orgFound || [],
            personFound:
                context.outputs.personFound || [],
        },
    });

    const markdownMessage =
        buildStep1Markdown({
            resolverRecord,
            activeRecordCount:
                activeQuery.records.length,
            results,
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
        step: "step1",
        status: "error",
        resolverRecordId:
            resolverRecord.id,
        error,
        partialResults: results,
        outputs: context.outputs,
        runLog,
    });

    throw error;
}
