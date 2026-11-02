# Engine Base Controller Schemas

These files are table-ready sample objects for
`js/airtable_scripts/schema_tools/create_table_from_json.js`. Create one
Airtable table from each `*.table.json` file. The script creates fields from
the sample object; it does not insert the sample as a record.

The model was derived from:

- `task-resolver/schema/*.schema.json`
- `task-resolver/reworked/datamap-*-export.csv`
- `task-resolver/stepX_conflict_rules (1).csv`
- `js/airtable_scripts/progress_events`
- the Project Event V2, Progress Tasks, Project Task Completion, and
  Event Resolver tables in `task-resolver/Progress_Tracker_base.json`

## Layers

### Shared configuration

1. `01-systems` - controller system registry.
2. `02-sources` - external Airtable base/table registry.
3. `03-engines` - reusable mechanics such as Search, Update, Compare, and
   Create.
4. `04-engine-steps` - ordered system workflow.
5. `05-table-configs` - binds a step/engine to a physical table.
6. `06-field-configs` - maps semantic JSON paths to Airtable fields.
7. `07-json-key-map` - canonical dotted-path registry.
8. `08-conflict-rules` - ordered Step X decision rules.
9. `09-config-releases` - versioned runtime configuration envelopes.

### Runtime orchestration

10. `10-project-events` - normalized Project Event v2 queue/envelope.
11. `11-resolver-runs` - one controller execution/cursor.
12. `12-run-log-entries` - append-only per-step execution log.
13. `13-event-intents` - queued/generated events, including autocomplete.

### Progress Task v2

14. `14-progress-tasks` - canonical milestone policy records. The physical
    `Progress-Tasks` name is retained for compatibility.
15. `15-task-dependencies` - `triggersCompletionOf` and
    `assumeCompleteIf` edges.
16. `16-completion-rules` - event/evidence rules that satisfy tasks.
17. `17-task-completions` - append-only, deterministic milestone completion
    ledger.
18. `18-requirements` - reusable requirement definitions derived from Office
    subtasks.
19. `19-milestone-requirements` - milestone-to-requirement mappings, including
    nested child requirements.
20. `20-requirement-state` - one mutable state record per project/scope and
    requirement.

Milestones retain stronger event/evidence validation and append-only
completion history. Requirements are deliberately lighter: their current
state is updated in place under the deterministic key
`scopeKey|requirementKey`.

## Relationship convention

Airtable linked-record fields cannot link across bases. The Engine base
therefore uses stable text keys (`systemKey`, `sourceKey`, `engineKey`,
`phaseTaskId`, and similar) as its portable relationship layer. Keep the
external Airtable IDs in the source/config records. If all controller tables
live in the same Engine base, the key fields may later be supplemented with
native linked-record fields.

## Recommended creation order

Create the tables in numeric order. The JSON samples use safe placeholder IDs
and contain no live credentials. Replace placeholder base/table/field IDs with
environment-specific values through source, table-config, and field-config
records rather than changing runtime scripts.

JSON-valued columns are deliberately stored as `multilineText`. This preserves
the resolver's existing configuration envelopes while the normalized records
remain queryable and shareable.

## Populate the Engine base

The reconciled controller records and idempotent Airtable loader are in
[`seed/`](Developer-Mapping/task-engine/schema/seed/README.md). Runtime-owned tables are intentionally left empty
until events and resolver executions begin.
