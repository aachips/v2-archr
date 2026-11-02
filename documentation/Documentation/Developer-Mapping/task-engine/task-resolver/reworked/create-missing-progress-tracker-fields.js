/************************************************************
ARCHR Progress Tracker — create missing resolver/conflict fields

Run this in Airtable's Script Extension inside the
[P] ARCHR Progress Tracker base.

This script:
- creates only writable field types;
- never updates or deletes an existing field;
- reuses an existing exact-name field when its type is correct;
- stops on same-name/type conflicts;
- prints placeholder_field_id replacements when complete.

Do not run this as an Automation "Run a script" action. Schema
creation is intended for the interactive Script Extension.
************************************************************/

const CONFIG = {
    tables: {
        resolver: "tbloJ5eN46v1Zx7AG",
        conflict: "tblfYyLY9k5kAomDJ",
        event: "tblOhnfdIlabxXOqL",
        completion: "tbl1mIQg2utmj7Vqt",
    },

    fields: [
        {
            placeholder: "TODO_RESOLVER_STEP_X_STATUS_FIELD_ID",
            table: "resolver",
            name: "⁉️Step X Status",
            type: "singleSelect",
            options: {
                choices: [
                    { name: "notRun", color: "grayLight2" },
                    { name: "running", color: "blueLight2" },
                    { name: "complete", color: "greenLight2" },
                    { name: "manualReview", color: "yellowLight2" },
                    { name: "error", color: "redLight2" },
                ],
            },
        },
        {
            placeholder: "TODO_RESOLVER_MATCHED_RULES_FIELD_ID",
            table: "resolver",
            name: "⁉️Matched Rules JSON",
            type: "multilineText",
        },
        {
            placeholder: "TODO_RESOLVER_CONFLICT_REASON_CODES_FIELD_ID",
            table: "resolver",
            name: "⁉️Conflict Reason Codes JSON",
            type: "multilineText",
        },
        {
            placeholder: "TODO_CONFLICT_TRIGGER_EVENT_FIELD_ID",
            table: "conflict",
            name: "Trigger [◼️Project Event V2]",
            type: "multipleRecordLinks",
            linkedTable: "event",
        },
        {
            placeholder: "TODO_CONFLICT_REASON_CODES_FIELD_ID",
            table: "conflict",
            name: "Conflict Reason Codes JSON",
            type: "multilineText",
        },
        {
            placeholder: "TODO_CONFLICT_NEW_COMPLETION_FIELD_ID",
            table: "conflict",
            name: "New [☑️Project Task Completion]",
            type: "multipleRecordLinks",
            linkedTable: "completion",
        },
        {
            placeholder: "TODO_CONFLICT_DECISION_FIELD_ID",
            table: "conflict",
            name: "Conflict Decision",
            type: "singleSelect",
            options: {
                choices: [
                    { name: "createNew", color: "blueLight2" },
                    { name: "reuseExisting", color: "greenLight2" },
                    { name: "mergeIntoExisting", color: "cyanLight2" },
                    { name: "createNewAndConflict", color: "orangeLight2" },
                    { name: "manualReview", color: "yellowLight2" },
                ],
            },
        },
        {
            placeholder: "TODO_CONFLICT_CONTEXT_JSON_FIELD_ID",
            table: "conflict",
            name: "Comparison Context JSON",
            type: "multilineText",
        },
        {
            placeholder: "TODO_CONFLICT_CONFLICTING_EVENT_FIELD_ID",
            table: "conflict",
            name: "Conflicting [◼️Project Event V2]",
            type: "multipleRecordLinks",
            linkedTable: "event",
        },
    ],
};

const CREATABLE_WRITABLE_TYPES = new Set([
    "singleLineText",
    "multilineText",
    "richText",
    "singleSelect",
    "multipleSelects",
    "multipleRecordLinks",
    "checkbox",
    "number",
    "date",
    "dateTime",
    "email",
    "url",
    "phoneNumber",
]);

function normalizeName(value) {
    return String(value || "").trim().toLocaleLowerCase();
}

function getExistingField(table, name) {
    const normalized = normalizeName(name);
    return table.fields.find(
        field => normalizeName(field.name) === normalized
    ) || null;
}

function getCreateOptions(definition, tables) {
    if (definition.type === "multipleRecordLinks") {
        if (!definition.linkedTable) {
            throw new Error(
                `${definition.placeholder} is missing linkedTable.`
            );
        }

        return {
            // Only linkedTableId is supplied. Airtable creates the inverse
            // link automatically; inverse-link options are not writable here.
            linkedTableId: tables[definition.linkedTable].id,
        };
    }

    return definition.options;
}

function validateExistingField(field, definition, tables) {
    const problems = [];

    if (field.type !== definition.type) {
        problems.push(
            `expected type ${definition.type}, found ${field.type}`
        );
    }

    if (
        definition.type === "multipleRecordLinks" &&
        field.options?.linkedTableId !== tables[definition.linkedTable].id
    ) {
        problems.push(
            `expected linked table ${tables[definition.linkedTable].id}, ` +
            `found ${field.options?.linkedTableId || "none"}`
        );
    }

    return problems;
}

async function main() {
    const tables = {};

    for (const [key, tableId] of Object.entries(CONFIG.tables)) {
        tables[key] = base.getTable(tableId);
    }

    const duplicatePlaceholders = CONFIG.fields
        .map(field => field.placeholder)
        .filter((value, index, values) => values.indexOf(value) !== index);

    if (duplicatePlaceholders.length) {
        throw new Error(
            `Duplicate placeholders: ${duplicatePlaceholders.join(", ")}`
        );
    }

    const plan = [];
    const conflicts = [];

    for (const definition of CONFIG.fields) {
        if (!CREATABLE_WRITABLE_TYPES.has(definition.type)) {
            conflicts.push({
                placeholder: definition.placeholder,
                field: definition.name,
                problem: `unsupported type ${definition.type}`,
            });
            continue;
        }

        const table = tables[definition.table];
        const existing = getExistingField(table, definition.name);

        if (existing) {
            const problems = validateExistingField(
                existing,
                definition,
                tables
            );

            if (problems.length) {
                conflicts.push({
                    placeholder: definition.placeholder,
                    field: `${table.name}.${existing.name}`,
                    problem: problems.join("; "),
                });
            }

            plan.push({
                placeholder: definition.placeholder,
                table: table.name,
                field: definition.name,
                type: definition.type,
                action: problems.length ? "TYPE CONFLICT" : "reuse",
                fieldId: problems.length ? "" : existing.id,
            });
        } else {
            plan.push({
                placeholder: definition.placeholder,
                table: table.name,
                field: definition.name,
                type: definition.type,
                action: "create",
                fieldId: "",
            });
        }
    }

    output.markdown("# Missing Progress Tracker fields");
    output.table(plan);

    if (conflicts.length) {
        output.markdown("## Blocking conflicts");
        output.table(conflicts);
        throw new Error(
            "Resolve the field conflicts above before creating fields. " +
            "No fields were created."
        );
    }

    const toCreate = plan.filter(item => item.action === "create");

    if (toCreate.length) {
        const answer = await input.buttonsAsync(
            `Create ${toCreate.length} missing field(s)?`,
            [
                { label: "Create fields", value: "create" },
                { label: "Cancel", value: "cancel" },
            ]
        );

        if (answer !== "create") {
            output.markdown("Cancelled. No fields were created.");
            return;
        }
    }

    const results = [];

    for (const definition of CONFIG.fields) {
        const table = tables[definition.table];
        const existing = getExistingField(table, definition.name);
        let fieldId = existing?.id || "";
        let action = "reused";

        if (!fieldId) {
            const options = getCreateOptions(definition, tables);

            fieldId = await table.createFieldAsync(
                definition.name,
                definition.type,
                options
            );
            action = "created";
        }

        results.push({
            placeholder: definition.placeholder,
            fieldId,
            table: table.name,
            field: definition.name,
            type: definition.type,
            action,
        });
    }

    output.markdown("## Placeholder replacements");
    output.table(results);

    const replacements = Object.fromEntries(
        results.map(result => [result.placeholder, result.fieldId])
    );

    output.markdown("## JSON mapping");
    output.markdown(
        "```json\n" + JSON.stringify(replacements, null, 2) + "\n```"
    );

    output.markdown("## CSV replacement rows");
    output.text(
        [
            "placeholder_field_id,fieldId",
            ...results.map(result =>
                `${result.placeholder},${result.fieldId}`
            ),
        ].join("\n")
    );
}

await main();

