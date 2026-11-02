/************************************************************
Resolver Canonical Context Builder

Run from:
Airtable Scripting Extension

Purpose:
- Select one [🤖Event_Resolver] record.
- Parse Step 1-3, Step X, and Step 4 configuration JSON.
- Parse the current event JSON.
- Build a canonical context object with:
    context.inputs
    context.outputs
    context.debug
    context.configs
    context.references
    context.meta
- Write that object to canonicalContextJSON.

This script does NOT:
- Perform searches.
- Update linked fields.
- Create completion records.
- Execute resolver steps.

It only prepares the shared context that later step scripts read.
************************************************************/

const CONFIG = {
    resolverTableNameOrId: "[🤖Event_Resolver]",

    // Add this as a Long text field.
    contextFieldNameOrId: "canonicalContextJSON",

    configFields: {
        step1: "step1_config",
        step2: "step2_config",
        step3: "step3_config",
        stepX: "stepX⁉️_Config",
        step4: "step4_config",
    },

    resolverFields: {
        currentEventLink: "[◼️Project Event V2]",
        currentEventIdLookup: "Current◼️Event",
        eventJSON: "◼️eventJSON",
        eventNumber: "◼️eventNumber",

        foundProject: "found🎯Project",
        foundTasks: "found⚙️Tasks",
        foundOrg: "found💜Org",
        foundPeople: "found💟People",
        foundCompletion: "found☑️Completion",
        createdCompletion: "created☑️Completion",

        step: "Step",
        nextStep: "Next_Step",
        resolverMode: "🤖Resolver_Mode",
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
        throw new Error(`Unable to stringify context: ${error.message}`);
    }
}

function parseJsonStrict(value, label) {
    if (
        typeof value === "object" &&
        value !== null &&
        !Array.isArray(value)
    ) {
        return value;
    }

    const text = String(value || "").trim();

    if (!text) {
        throw new Error(`${label} is blank.`);
    }

    try {
        return JSON.parse(text);
    } catch (error) {
        throw new Error(`${label} contains invalid JSON: ${error.message}`);
    }
}

function parseJsonOptional(value, fallback = {}) {
    if (isBlank(value)) return fallback;

    if (typeof value === "object" && value !== null) {
        return value;
    }

    try {
        return JSON.parse(String(value).trim());
    } catch {
        return fallback;
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

function getCellValue(table, record, fieldToken) {
    const field = getFieldFlexible(table, fieldToken);
    if (!field) return null;

    try {
        return record.getCellValue(field);
    } catch {
        return null;
    }
}

function getCellString(table, record, fieldToken) {
    const field = getFieldFlexible(table, fieldToken);
    if (!field) return "";

    try {
        return record.getCellValueAsString(field).trim();
    } catch {
        return "";
    }
}

function getLinkedRecordIds(value) {
    if (!Array.isArray(value)) return [];

    return value
        .map(item => item && item.id)
        .filter(Boolean);
}

function unique(values) {
    return [...new Set((values || []).filter(Boolean))];
}

function uniqueObjects(values, keyBuilder) {
    const map = new Map();

    for (const value of values || []) {
        map.set(keyBuilder(value), value);
    }

    return [...map.values()];
}

function splitLoose(value) {
    if (isBlank(value)) return [];

    if (Array.isArray(value)) {
        return value.flatMap(splitLoose).filter(Boolean);
    }

    if (typeof value === "object") {
        if (value.id) return [String(value.id).trim()];
        if (value.name) return [String(value.name).trim()];

        return [safeStringify(value, 0)];
    }

    const text = String(value).trim();
    if (!text) return [];

    try {
        const parsed = JSON.parse(text);

        if (Array.isArray(parsed)) {
            return parsed.flatMap(splitLoose).filter(Boolean);
        }
    } catch {}

    return text
        .replace(/^\[|\]$/g, "")
        .split(/[,;\n|]+/)
        .map(item => item.replace(/^"|"$/g, "").trim())
        .filter(Boolean);
}

function normalizeRecordIdOutput(value) {
    return unique(
        splitLoose(value).filter(item =>
            /^rec[A-Za-z0-9]{14}$/.test(item)
        )
    );
}

/************************************************************
Nested-path helpers
************************************************************/

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

function setPath(object, path, value) {
    const parts = String(path).split(".");
    const last = parts.pop();

    let cursor = object;

    for (const part of parts) {
        if (
            !cursor[part] ||
            typeof cursor[part] !== "object" ||
            Array.isArray(cursor[part])
        ) {
            cursor[part] = {};
        }

        cursor = cursor[part];
    }

    cursor[last] = value;
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

/************************************************************
Event JSON flattening

Creates direct input keys for every named property found anywhere
inside the event JSON.

Example source:
{
    "eventJSON": {
        "eventProjectId": "abc",
        "eventPartner": {
            "partnerOrg": ["org1"]
        }
    }
}

Produces:
inputs.eventProjectId = "abc"
inputs.partnerOrg = ["org1"]

The original nested JSON remains available at:
inputs.event
************************************************************/

function mergeInputValue(existing, incoming) {
    if (existing === undefined) return incoming;

    const existingValues = Array.isArray(existing)
        ? existing
        : [existing];

    const incomingValues = Array.isArray(incoming)
        ? incoming
        : [incoming];

    const combined = [
        ...existingValues,
        ...incomingValues,
    ].filter(value => !isBlank(value));

    const uniqueMap = new Map();

    for (const value of combined) {
        const key =
            typeof value === "object"
                ? safeStringify(value, 0)
                : `${typeof value}:${String(value)}`;

        uniqueMap.set(key, value);
    }

    const results = [...uniqueMap.values()];

    return results.length === 1
        ? results[0]
        : results;
}

function buildLeafKeyIndex(value, target = {}) {
    if (value === null || value === undefined) {
        return target;
    }

    if (Array.isArray(value)) {
        for (const item of value) {
            if (item && typeof item === "object") {
                buildLeafKeyIndex(item, target);
            }
        }

        return target;
    }

    if (typeof value !== "object") {
        return target;
    }

    for (const [key, childValue] of Object.entries(value)) {
        if (!isBlank(childValue)) {
            target[key] = mergeInputValue(
                target[key],
                childValue
            );
        }

        if (
            childValue &&
            typeof childValue === "object"
        ) {
            buildLeafKeyIndex(childValue, target);
        }
    }

    return target;
}

/************************************************************
Config parsing
************************************************************/

function readConfigField(
    resolverTable,
    resolverRecord,
    configFieldToken,
    stepName,
    options = {}
) {
    const field = getFieldFlexible(
        resolverTable,
        configFieldToken
    );

    if (!field) {
        throw new Error(
            `${stepName} config field not found: ${configFieldToken}`
        );
    }

    const raw = resolverRecord
        .getCellValueAsString(field)
        .trim();

    if (!raw && options.optional) {
        return {
            fieldId: field.id,
            fieldName: field.name,
            raw,
            parsed: options.fallback ?? {},
        };
    }

    const parsed = parseJsonStrict(
        raw,
        `${stepName} config`
    );

    return {
        fieldId: field.id,
        fieldName: field.name,
        raw,
        parsed,
    };
}

/************************************************************
Config reference collector

This gives later scripts a canonical map of everything referenced
by the currently loaded configurations.
************************************************************/

function createEmptyReferences() {
    return {
        tables: [],
        fields: [],
        records: [],
        sources: [],
        searchOutputs: [],
        writeNames: [],
        jsonKeys: [],
    };
}

function addTableReference(
    references,
    tableId,
    usage,
    configPath
) {
    if (!tableId) return;

    references.tables.push({
        tableId,
        usage,
        configPath,
    });
}

function addFieldReference(
    references,
    tableId,
    fieldId,
    expectedType,
    usage,
    configPath
) {
    if (!fieldId) return;

    references.fields.push({
        tableId: tableId || "",
        fieldId,
        expectedType: expectedType || "",
        usage,
        configPath,
    });
}

function addRecordReference(
    references,
    tableId,
    recordId,
    usage,
    configPath
) {
    if (!recordId) return;

    references.records.push({
        tableId: tableId || "",
        recordId,
        usage,
        configPath,
    });
}

function addSourceReference(
    references,
    source,
    usage,
    configPath
) {
    if (!source) return;

    references.sources.push({
        source,
        namespace: String(source).split(".")[0] || "",
        usage,
        configPath,
    });
}

function normalizeWriteFieldConfigs(fields) {
    const normalized = [];

    for (const fieldWrapper of fields || []) {
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

            normalized.push({
                category,
                ...fieldConfig,
                fieldType:
                    fieldConfig.fieldType ||
                    fieldConfig.type,
            });
        }
    }

    return normalized;
}

function collectSearchReferences(
    references,
    stepName,
    stepArray
) {
    for (const wrapper of Array.isArray(stepArray) ? stepArray : []) {
        for (const [searchName, searchConfig] of Object.entries(wrapper)) {
            const rootPath = `${stepName}.${searchName}`;
            const tableId = searchConfig.searchTableId;

            addTableReference(
                references,
                tableId,
                "search",
                `${rootPath}.searchTableId`
            );

            addFieldReference(
                references,
                tableId,
                searchConfig.searchPrimaryFieldId,
                "",
                "primarySearch",
                `${rootPath}.searchPrimaryFieldId`
            );

            for (
                const fieldId of
                searchConfig.searchDeepFieldIds || []
            ) {
                addFieldReference(
                    references,
                    tableId,
                    fieldId,
                    "",
                    "deepSearch",
                    `${rootPath}.searchDeepFieldIds[]`
                );
            }

            if (searchConfig.jsonPrimaryKey) {
                references.jsonKeys.push({
                    key: searchConfig.jsonPrimaryKey,
                    usage: "primarySearch",
                    configPath: `${rootPath}.jsonPrimaryKey`,
                });
            }

            for (
                const jsonKey of
                searchConfig.jsonDeepKeys || []
            ) {
                references.jsonKeys.push({
                    key: jsonKey,
                    usage: "deepSearch",
                    configPath: `${rootPath}.jsonDeepKeys[]`,
                });
            }

            const outputMap = {
                projectSearch: "outputs.projectFound",
                taskSearch: "outputs.taskFound",
                orgSearch: "outputs.orgFound",
                personSearch: "outputs.personFound",
                completionSearch: "outputs.completionFound",
            };

            references.searchOutputs.push({
                searchName,
                outputPath:
                    searchConfig.outputPath ||
                    searchConfig.outputKey ||
                    outputMap[searchName] ||
                    `outputs.${searchName}Found`,
                configPath: rootPath,
            });
        }
    }
}

function collectWriteConfigReferences(
    references,
    writeConfig,
    rootPath
) {
    if (!writeConfig || typeof writeConfig !== "object") {
        return;
    }

    if (writeConfig.writeName) {
        references.writeNames.push({
            writeName: writeConfig.writeName,
            configPath: `${rootPath}.writeName`,
        });
    }

    if (writeConfig.source) {
        addSourceReference(
            references,
            writeConfig.source,
            "fieldWrite",
            `${rootPath}.source`
        );
    }

    for (
        const destination of
        writeConfig.writeTo || []
    ) {
        addTableReference(
            references,
            destination.tableId,
            "write",
            `${rootPath}.writeTo[].tableId`
        );

        addRecordReference(
            references,
            destination.tableId,
            destination.recordId,
            "write",
            `${rootPath}.writeTo[].recordId`
        );

        for (
            const fieldConfig of
            normalizeWriteFieldConfigs(
                destination.fields
            )
        ) {
            addFieldReference(
                references,
                destination.tableId,
                fieldConfig.fieldId,
                fieldConfig.fieldType,
                "write",
                `${rootPath}.writeTo[].fields[]`
            );

            if (fieldConfig.source) {
                addSourceReference(
                    references,
                    fieldConfig.source,
                    "fieldWrite",
                    `${rootPath}.writeTo[].fields[].source`
                );
            }

            const valueSource =
                normalizeValueTokenPath(fieldConfig.value);

            if (valueSource) {
                addSourceReference(
                    references,
                    valueSource,
                    "fieldWrite",
                    `${rootPath}.writeTo[].fields[].value`
                );
            }
        }
    }
}

function collectStep2References(
    references,
    step2
) {
    if (Array.isArray(step2?.writeList)) {
        for (const destination of step2.writeList) {
            collectWriteConfigReferences(
                references,
                {
                    writeName:
                        destination.writeName ||
                        destination.table ||
                        destination.tableId ||
                        "unnamedDestination",
                    writeTo: [destination],
                },
                `step2.writeList.${destination.table || destination.tableId || "unnamed"}`
            );
        }

        return;
    }

    if (Array.isArray(step2)) {
        for (const wrapper of step2) {
            for (const [wrapperName, writeConfig] of Object.entries(wrapper)) {
                collectWriteConfigReferences(
                    references,
                    writeConfig,
                    `step2.${wrapperName}`
                );
            }
        }

        return;
    }

    for (
        const writeConfig of
        step2?.fieldWrites || []
    ) {
        collectWriteConfigReferences(
            references,
            writeConfig,
            `step2.fieldWrites.${writeConfig.writeName || "unnamed"}`
        );
    }
}

function collectStepXReferences(
    references,
    stepX
) {
    if (!stepX || typeof stepX !== "object") return;

    addSourceReference(
        references,
        stepX.existingCompletionSource,
        "conflictExistingCompletion",
        "stepX.existingCompletionSource"
    );

    addSourceReference(
        references,
        stepX.triggerEventSource,
        "conflictTriggerEvent",
        "stepX.triggerEventSource"
    );

    addTableReference(
        references,
        stepX.completionTableId,
        "conflictCompletion",
        "stepX.completionTableId"
    );

    addFieldReference(
        references,
        stepX.completionTableId,
        stepX.completionEventLinkFieldId,
        "",
        "conflictCompletionEventLink",
        "stepX.completionEventLinkFieldId"
    );

    addTableReference(
        references,
        stepX.eventTableId,
        "conflictEvent",
        "stepX.eventTableId"
    );

    for (
        const [key, fieldConfig] of
        Object.entries(stepX.eventFields || {})
    ) {
        addFieldReference(
            references,
            stepX.eventTableId,
            fieldConfig.fieldId,
            fieldConfig.fieldType,
            "conflictEventField",
            `stepX.eventFields.${key}`
        );
    }

    for (
        const fieldConfig of
        stepX.mergeableFields || []
    ) {
        addFieldReference(
            references,
            stepX.eventTableId,
            fieldConfig.fieldId,
            fieldConfig.fieldType,
            "conflictMergeableField",
            `stepX.mergeableFields.${fieldConfig.key || "unnamed"}`
        );
    }
}

function collectStep4References(
    references,
    step4
) {
    if (!step4 || typeof step4 !== "object") return;

    addSourceReference(
        references,
        step4.completionSearchSource,
        "completionExistenceCheck",
        "step4.completionSearchSource"
    );

    addTableReference(
        references,
        step4.createTableId,
        "create",
        "step4.createTableId"
    );

    for (
        const fieldConfig of
        step4.createRecord?.fields || []
    ) {
        addFieldReference(
            references,
            step4.createTableId,
            fieldConfig.fieldId,
            fieldConfig.fieldType,
            "create",
            "step4.createRecord.fields[]"
        );

        if (fieldConfig.source) {
            addSourceReference(
                references,
                fieldConfig.source,
                "create",
                "step4.createRecord.fields[].source"
            );
        }
    }

    if (step4.writeCreatedRecordTo) {
        collectWriteConfigReferences(
            references,
            {
                writeName: "writeCreatedCompletion",
                source: "outputs.createdCompletion",
                writeTo: step4.writeCreatedRecordTo,
            },
            "step4.writeCreatedRecordTo"
        );
    }
}

function dedupeReferences(references) {
    references.tables = uniqueObjects(
        references.tables,
        item =>
            `${item.tableId}|${item.usage}|${item.configPath}`
    );

    references.fields = uniqueObjects(
        references.fields,
        item =>
            [
                item.tableId,
                item.fieldId,
                item.expectedType,
                item.usage,
                item.configPath,
            ].join("|")
    );

    references.records = uniqueObjects(
        references.records,
        item =>
            `${item.tableId}|${item.recordId}|${item.configPath}`
    );

    references.sources = uniqueObjects(
        references.sources,
        item =>
            `${item.source}|${item.usage}|${item.configPath}`
    );

    references.searchOutputs = uniqueObjects(
        references.searchOutputs,
        item =>
            `${item.searchName}|${item.outputPath}|${item.configPath}`
    );

    references.writeNames = uniqueObjects(
        references.writeNames,
        item =>
            `${item.writeName}|${item.configPath}`
    );

    references.jsonKeys = uniqueObjects(
        references.jsonKeys,
        item =>
            `${item.key}|${item.usage}|${item.configPath}`
    );

    return references;
}

/************************************************************
Output/debug namespaces
************************************************************/

function readResolverOutput(
    resolverTable,
    resolverRecord,
    fieldToken
) {
    const rawValue = getCellValue(
        resolverTable,
        resolverRecord,
        fieldToken
    );

    const stringValue = getCellString(
        resolverTable,
        resolverRecord,
        fieldToken
    );

    const recordIds = unique([
        ...getLinkedRecordIds(rawValue),
        ...normalizeRecordIdOutput(stringValue),
    ]);

    return recordIds;
}

function buildOutputs(
    resolverTable,
    resolverRecord
) {
    return {
        projectFound: readResolverOutput(
            resolverTable,
            resolverRecord,
            CONFIG.resolverFields.foundProject
        ),

        taskFound: readResolverOutput(
            resolverTable,
            resolverRecord,
            CONFIG.resolverFields.foundTasks
        ),

        orgFound: readResolverOutput(
            resolverTable,
            resolverRecord,
            CONFIG.resolverFields.foundOrg
        ),

        personFound: readResolverOutput(
            resolverTable,
            resolverRecord,
            CONFIG.resolverFields.foundPeople
        ),

        completionFound: readResolverOutput(
            resolverTable,
            resolverRecord,
            CONFIG.resolverFields.foundCompletion
        ),

        createdCompletion: readResolverOutput(
            resolverTable,
            resolverRecord,
            CONFIG.resolverFields.createdCompletion
        )[0] || "",
    };
}

/************************************************************
Input namespace
************************************************************/

function unwrapEventJson(parsedEventJson) {
    if (
        parsedEventJson &&
        typeof parsedEventJson === "object" &&
        parsedEventJson.eventJSON &&
        typeof parsedEventJson.eventJSON === "object"
    ) {
        return parsedEventJson.eventJSON;
    }

    return parsedEventJson;
}

function findFirstValue(object, candidatePaths) {
    for (const path of candidatePaths) {
        const value = getPath(object, path);

        if (!isBlank(value)) {
            return value;
        }
    }

    return undefined;
}

function buildInputs({
    resolverTable,
    resolverRecord,
    parsedEventJson,
    currentEventRecordIds,
}) {
    const event = unwrapEventJson(parsedEventJson);
    const flattened = buildLeafKeyIndex(event, {});

    const inputs = {
        event,
        eventEnvelope: parsedEventJson,

        ...flattened,

        currentEventRecordId:
            currentEventRecordIds[0] || "",

        currentEventRecordIds,

        resolverRecordId: resolverRecord.id,

        eventNumber: getCellString(
            resolverTable,
            resolverRecord,
            CONFIG.resolverFields.eventNumber
        ),
    };

    // Canonical aliases used by later configs.
    inputs.eventProjectId =
        findFirstValue(inputs, [
            "eventProjectId",
            "eventProject",
            "event.eventProjectId",
            "event.eventProject",
        ]) || "";

    inputs.eventDate =
        findFirstValue(inputs, [
            "eventDate",
            "completedDate",
            "event.eventDate",
        ]) || "";

    inputs.completionKey =
        findFirstValue(inputs, [
            "completionKey",
            "event.completionKey",
        ]) || "";

    inputs.completionSearchKey =
        findFirstValue(inputs, [
            "completionSearchKey",
            "searchCompletionKey",
            "search☑️Key",
            "event.completionSearchKey",
        ]) || "";

    return inputs;
}

function collectCanonicalEngineReferences(
    references,
    config,
    stepName
) {
    if (
        config?.schema !== "eventResolver.engineConfig.v1" ||
        !Array.isArray(config.engines)
    ) {
        return false;
    }

    for (const engine of config.engines) {
        for (const setup of engine?.tables || []) {
            const table = setup?.table;
            if (!table?.tableId) continue;

            const rootPath =
                `${stepName}.engines.${engine.engine}.${setup.setupId}`;
            addTableReference(
                references,
                table.tableId,
                engine.engine,
                `${rootPath}.table.tableId`
            );

            if (table.recordId) {
                addRecordReference(
                    references,
                    table.tableId,
                    table.recordId,
                    engine.engine,
                    `${rootPath}.table.recordId`
                );
            }
            if (table.recordSource?.path) {
                addSourceReference(
                    references,
                    table.recordSource.path,
                    "recordSource",
                    `${rootPath}.table.recordSource.path`
                );
            }

            const searchFields = table.searchFields;
            if (searchFields) {
                const primary = searchFields.primaryField?.field;
                if (primary?.fieldId) {
                    addFieldReference(
                        references,
                        table.tableId,
                        primary.fieldId,
                        primary.fieldType,
                        "primarySearch",
                        `${rootPath}.table.searchFields.primaryField`
                    );
                }
                for (const wrapper of searchFields.deepFields || []) {
                    const field = wrapper?.field;
                    if (!field?.fieldId) continue;
                    addFieldReference(
                        references,
                        table.tableId,
                        field.fieldId,
                        field.fieldType,
                        "deepSearch",
                        `${rootPath}.table.searchFields.deepFields[]`
                    );
                }
                for (const key of searchFields.primaryInputKeys || []) {
                    references.jsonKeys.push({
                        key,
                        usage: "primarySearch",
                        configPath: `${rootPath}.table.searchFields.primaryInputKeys[]`,
                    });
                }
                for (const key of searchFields.deepInputKeys || []) {
                    references.jsonKeys.push({
                        key,
                        usage: "deepSearch",
                        configPath: `${rootPath}.table.searchFields.deepInputKeys[]`,
                    });
                }
                references.searchOutputs.push({
                    searchName: setup.role || setup.setupId,
                    outputPath: searchFields.outputPath,
                    configPath: `${rootPath}.table.searchFields`,
                });
            }

            for (
                const [fieldListName, fieldList] of
                [
                    ["writeFields", table.writeFields],
                    ["mergeFields", table.mergeFields],
                ]
            ) {
                for (const wrapper of fieldList || []) {
                    const field = wrapper?.field;
                    if (!field?.fieldId) continue;
                    addFieldReference(
                        references,
                        table.tableId,
                        field.fieldId,
                        field.fieldType,
                        engine.engine,
                        `${rootPath}.table.${fieldListName}[]`
                    );
                    if (field.writeSource?.path) {
                        addSourceReference(
                            references,
                            field.writeSource.path,
                            "fieldWrite",
                            `${rootPath}.table.${fieldListName}[].field.writeSource.path`
                        );
                    }
                }
            }
        }
    }

    return true;
}

function createInitialConflictWorkflow(stepXConfig = {}) {
    return {
        status: "notRun",

        comparison: {
            schema: "eventResolver.conflictComparison.v1",

            existingCompletionId: "",
            triggerEventId: "",
            conflictingEventId: "",

            inputs: {
                dateWindowDays:
                    stepXConfig.dateWindowDays ?? 30,

                trigger: {
                    eventId: "",
                    completedDate: null,
                    orgRecordIds: [],
                    personRecordIds: [],
                    personOrgIds: [],
                    orgDirIds: [],
                },

                conflicting: {
                    eventId: "",
                    completedDate: null,
                    orgRecordIds: [],
                    personRecordIds: [],
                    personOrgIds: [],
                    orgDirIds: [],
                },
            },

            comparisons: {
                orgRecords: {},
                people: {},
                personOrgIds: {},
                orgDirIds: {},
                dates: {},
                crossIdentity: {},
                mergeableFields: [],
            },

            booleans: {
                hasExistingCompletion: false,
                hasConflictingEvent: false,
                multipleCompletionsFound: false,
                multipleConflictingEvents: false,
                orgRecordsConflict: false,
                peopleConflict: false,
                personOrgIdsEqual: false,
                peopleConflictSamePersonOrg: false,
                orgDirIdsConflict: false,
                personOrgConflictsWithOrgDir: false,
                completedDatesDiffer: false,
                datesWithinWindow: false,
                datesOutsideWindow: false,
                hasMergeableMissingValues: false,
            },

            suggestedValues: {
                earlierCompletedDate: null,
                combinedPeople: [],
                mergeCandidates: [],
            },
        },

        ruleEvaluation: {
            status: "notRun",
            matchedRules: [],
            decision: null,
        },
    };
}

/************************************************************
Main
************************************************************/

const resolverTable = base.getTable(
    CONFIG.resolverTableNameOrId
);

const resolverRecord = await input.recordAsync(
    "Choose the resolver row",
    resolverTable
);

if (!resolverRecord) {
    output.markdown("No resolver row selected.");
    return;
}

const contextField = getFieldFlexible(
    resolverTable,
    CONFIG.contextFieldNameOrId
);

if (!contextField) {
    throw new Error(
        `Add a Long text field named "${CONFIG.contextFieldNameOrId}" ` +
        `to ${resolverTable.name}, or update CONFIG.contextFieldNameOrId.`
    );
}

/************************************************************
Load configurations
************************************************************/

const configReads = {};

for (
    const [stepName, fieldToken] of
    Object.entries(CONFIG.configFields)
) {
    configReads[stepName] = readConfigField(
        resolverTable,
        resolverRecord,
        fieldToken,
        stepName,
        {
            optional: stepName === "stepX",
            fallback: {},
        }
    );
}

const configs = {
    step1:
        configReads.step1.parsed.step1 ??
        configReads.step1.parsed,

    step2:
        configReads.step2.parsed.step2 ??
        configReads.step2.parsed,

    step3:
        configReads.step3.parsed.step3 ??
        configReads.step3.parsed,

    stepX:
        configReads.stepX.parsed.stepX ??
        configReads.stepX.parsed,

    step4:
        configReads.step4.parsed.step4 ??
        configReads.step4.parsed,
};

/************************************************************
Load current event
************************************************************/

const currentEventRaw = getCellValue(
    resolverTable,
    resolverRecord,
    CONFIG.resolverFields.currentEventLink
);

const currentEventLookupRaw = getCellString(
    resolverTable,
    resolverRecord,
    CONFIG.resolverFields.currentEventIdLookup
);

const currentEventRecordIds = unique([
    ...getLinkedRecordIds(currentEventRaw),
    ...normalizeRecordIdOutput(currentEventLookupRaw),
]);

const eventJsonRaw = getCellString(
    resolverTable,
    resolverRecord,
    CONFIG.resolverFields.eventJSON
);

const parsedEventJson = parseJsonOptional(
    eventJsonRaw,
    {}
);

/************************************************************
Build namespaces
************************************************************/

const inputs = buildInputs({
    resolverTable,
    resolverRecord,
    parsedEventJson,
    currentEventRecordIds,
});

const outputs = buildOutputs(
    resolverTable,
    resolverRecord
);

// Debug starts as a snapshot of the resolver's visible result fields.
// Later you can populate debug differently if desired.
const debug = JSON.parse(JSON.stringify(outputs));

/************************************************************
Build config-reference map
************************************************************/

let references = createEmptyReferences();

if (!collectCanonicalEngineReferences(references, configs.step1, "step1")) {
    collectSearchReferences(references, "step1", configs.step1);
}
if (!collectCanonicalEngineReferences(references, configs.step2, "step2")) {
    collectStep2References(references, configs.step2);
}
if (!collectCanonicalEngineReferences(references, configs.step3, "step3")) {
    collectSearchReferences(references, "step3", configs.step3);
}
if (!collectCanonicalEngineReferences(references, configs.stepX, "stepX")) {
    collectStepXReferences(references, configs.stepX);
}
if (!collectCanonicalEngineReferences(references, configs.step4, "step4")) {
    collectStep4References(references, configs.step4);
}

references = dedupeReferences(references);

/************************************************************
Check source paths against initial context
************************************************************/

const preflightContext = {
    inputs,
    outputs,
    debug,
    configs,
};

const sourceResolution = references.sources.map(reference => {
    const value = getPath(
        preflightContext,
        reference.source
    );

    return {
        ...reference,
        currentlyResolvable: value !== undefined,
        currentlyBlank: isBlank(value),
        currentValue: value === undefined ? null : value,
    };
});

/************************************************************
Build canonical context
************************************************************/

const context = {
    schema: "eventResolver.context.v1",

    meta: {
        contextId:
            `context_${resolverRecord.id}_${Date.now()}`,

        generatedAt:
            new Date().toISOString(),

        resolverTableId:
            resolverTable.id,

        resolverTableName:
            resolverTable.name,

        resolverRecordId:
            resolverRecord.id,

        resolverRecordName:
            resolverRecord.name,

        currentStep:
            getCellString(
                resolverTable,
                resolverRecord,
                CONFIG.resolverFields.step
            ),

        nextStep:
            getCellString(
                resolverTable,
                resolverRecord,
                CONFIG.resolverFields.nextStep
            ),

        resolverMode:
            getCellString(
                resolverTable,
                resolverRecord,
                CONFIG.resolverFields.resolverMode
            ),

        configFields: Object.fromEntries(
            Object.entries(configReads).map(
                ([stepName, read]) => [
                    stepName,
                    {
                        fieldId: read.fieldId,
                        fieldName: read.fieldName,
                    },
                ]
            )
        ),
    },

    inputs,

    outputs,

    debug,

    configs,

    conflictWorkflow:
        createInitialConflictWorkflow(configs.stepX),

    references: {
        ...references,
        sourceResolution,
    },

    state: {
        step1: {
            status: "notRun",
        },

        step2: {
            status: "notRun",
        },

        step3: {
            status: "notRun",
        },

        stepX: {
            status: "notRun",
        },

        step4: {
            status: "notRun",
        },

        errors: [],
        messages: [],
    },
};

/************************************************************
Write canonical context
************************************************************/

const contextJSON = safeStringify(
    context,
    CONFIG.prettyPrintSpaces
);

await resolverTable.updateRecordAsync(
    resolverRecord.id,
    {
        [contextField.id]: contextJSON,
    }
);

/************************************************************
Display summary
************************************************************/

const unresolvedSources =
    sourceResolution.filter(
        item => !item.currentlyResolvable
    );

const blankSources =
    sourceResolution.filter(
        item =>
            item.currentlyResolvable &&
            item.currentlyBlank
    );

output.markdown(`
# Canonical Context Built

Resolver row: **${resolverRecord.name}**

Context schema: **${context.schema}**

Config steps loaded: **${Object.keys(configs).length}**

Input keys indexed: **${Object.keys(inputs).length}**

Referenced tables: **${references.tables.length}**

Referenced fields: **${references.fields.length}**

Referenced records: **${references.records.length}**

Referenced sources: **${references.sources.length}**

Unresolved source paths: **${unresolvedSources.length}**

Currently blank source paths: **${blankSources.length}**

Written to: **${contextField.name}**
`);

if (unresolvedSources.length) {
    output.markdown("## Unresolved Source Paths");

    output.table(
        unresolvedSources.map(item => ({
            source: item.source,
            namespace: item.namespace,
            usage: item.usage,
            configPath: item.configPath,
        }))
    );
}

if (blankSources.length) {
    output.markdown("## Currently Blank Source Paths");

    output.table(
        blankSources.map(item => ({
            source: item.source,
            usage: item.usage,
            configPath: item.configPath,
        }))
    );
}

output.markdown("## Initial Outputs");

output.table([
    {
        output: "projectFound",
        value: safeStringify(outputs.projectFound, 0),
    },
    {
        output: "taskFound",
        value: safeStringify(outputs.taskFound, 0),
    },
    {
        output: "orgFound",
        value: safeStringify(outputs.orgFound, 0),
    },
    {
        output: "personFound",
        value: safeStringify(outputs.personFound, 0),
    },
    {
        output: "completionFound",
        value: safeStringify(outputs.completionFound, 0),
    },
    {
        output: "createdCompletion",
        value: outputs.createdCompletion,
    },
]);

console.log(context);
