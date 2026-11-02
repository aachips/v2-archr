# Task Resolver Datamap Structural Norms

This folder defines the resolver as configuration data rather than as hardcoded step scripts. The four CSV exports form a small relational model:

- `datamap-engines-export.csv` defines generic engines.
- `datamap-keyMap-export.csv` defines the JSON tree each engine reads or writes.
- `datamap-tables-export.csv` binds engine configurations to Airtable tables.
- `datamap-fields-export.csv` binds Airtable fields to specific JSON paths in the key map.

The step scripts should eventually become generic runners that consume this model.

## Core Relationship

The intended relationship is:

```text
Engine
  -> keyMap JSON paths
  -> tableConfigSetups
  -> table rows
  -> field rows
  -> generated config JSON
  -> generic step-js engine
```

In practice:

- An engine declares the family of JSON keys it cares about.
- A keyMap row declares where one JSON key sits in the output tree.
- A table row selects a concrete Airtable table for one engine setup.
- A field row supplies concrete Airtable field metadata for one or more keyMap paths.

## Engines

`datamap-engines-export.csv` has one row per generic behavior.

Current engines:

- `Event JSON`: builds or interprets inbound event JSON.
- `Search`: searches configured tables using primary and deep fields.
- `Update`: writes resolved values back to business tables.
- `Update Log`: writes/debugs resolver-state data back to the resolver table.
- `Compare`: loads candidate records and builds comparison inputs.
- `Merge`: applies merge rules to compatible records.
- `Create`: creates new records such as completions or conflict records.

Important columns:

- `Name`: canonical engine name.
- `Description`: human-readable purpose.
- `tableConfigSetups`: comma-separated table setup rows served by the engine.
- `eventJSONkeys`: comma-separated keyMap paths used by the engine.
- `schemaInputJSON` / `schemaOutputJSON`: intended future homes for formal input/output schema.

Norms:

- Step scripts should dispatch by engine behavior, not by table label.
- A new resolver behavior should usually mean a new engine row only if the operation is mechanically different.
- Engine rows list required key paths; they should not duplicate concrete field IDs.

## Key Map

`datamap-keyMap-export.csv` is the JSON-shape registry.

Important columns:

- `json_key`: full dotted JSON path.
- `jsonDepth`: path depth.
- `lowestKey`: final path segment.
- `genericEngine`: engine or engines that consume the path.
- `parentKey`: parent JSON path.
- `childKey`: comma-separated child JSON paths.
- `object`: marks paths rendered as objects.
- `array`: marks paths rendered as arrays.
- `rolledUpOn`: says where the value is assembled from.
- `fieldConfig_eventJSONkey`: field config rows that feed this path.
- `renderFormula`: Airtable-side formula fragment used to render JSON.
- `ifThenFieldName`: helper path/name used by render formulas.

Norms:

- `json_key` is the stable contract. Scripts should target paths, not Airtable formula names.
- `parentKey` and `childKey` define tree structure; scripts can use them to assemble nested JSON.
- `object` and `array` are structural flags. A row should not be treated as scalar if either flag is checked.
- `rolledUpOn` identifies the source layer:
  - `engine`: engine supplies or requires this shape.
  - `table_config`: table rows assemble this part.
  - `eventJSON`: inbound event data supplies this value.
  - `output_JSON`: prior resolver output supplies this value.
  - Mixed values such as `eventJSON & engine` mean the path is structurally owned by the engine but populated partly from event data.
- `fieldConfig_eventJSONkey` links a keyMap row back to one or more field configuration rows.

## Tables

`datamap-tables-export.csv` is table setup data. Each row is a concrete table configuration for one step/engine/table combination.

Important columns:

- `tableResolver`: setup label, usually shaped as `Step N Engine [Table Label]`.
- `search.tables.table`: table ID fragment for search/update/create setup.
- `search.searchFields.primaryField`: rendered primary search field list.
- `search.searchFields.deepFields`: rendered deep search field list.
- `write.tables.records.fields`: rendered write field list.
- `create.tables.table`: create table fragment.
- `merge.table.rules`: merge rule fragment.

Norms:

- `tableResolver` is the human-readable setup identity.
- Table rows should not own individual field facts; they aggregate field rows.
- A table setup can exist even if only one engine column is populated.
- Empty arrays such as `[]` mean the engine path is intentionally present but has no configured children.
- Blank cells mean that path is not relevant to that table setup.

Examples:

- `Step 1 Search [People]` rows bind the `Search` engine to a searchable table.
- `Step 2 Update [Project Event V2]` binds the `Update` engine to the event table.
- `Step 2 Update Log [Event_Resolver]` binds the `Update Log` engine to the resolver table.
- `Step x Compare [Project Task Completion]` binds the `Compare` engine to completion/event comparison inputs.

## Fields

`datamap-fields-export.csv` is the concrete field registry. This is where keyMap paths become Airtable field IDs and field types.

Important columns:

- `tableconfigSetup`: setup grouping, typically table label plus group.
- `group`: field purpose, such as `search_primaryField`, `write_eventTable`, or `compare_eventFields`.
- `Table`: Airtable table label. The exported header currently includes a green-dot table prefix.
- `tableConfig`: one or more table setup labels that consume this field.
- `keyMap`: comma-separated keyMap paths populated by this field row.
- `eventField`: canonical comparison/event field name where applicable.
- `field.fieldId`: Airtable field ID.
- `field.fieldType`: Airtable field type.
- `field.fieldLabel`: Airtable field label.
- `field.writeMode`: write behavior such as `replace`.
- `field.writeSource`: source path/token for writes.
- `field.writeValue`: literal value for writes.
- `field.mergeable`: merge flag for comparison/merge workflows.
- `writeFields.field`, `create.fields.field`, `eventFields.field`: rendered fragments or category anchors.
- `completion.*`: completion-specific semantic keys.

Norms:

- `field.fieldId`, `field.fieldType`, and `field.fieldLabel` are the field identity triple.
- `keyMap` can contain multiple paths when the same field participates in several semantic roles.
- Canonical keyMap paths are normalized through `fieldNameLookupCreator` before rendering. `includeKeys` therefore uses shorter, reusable paths such as `fields.field`, `field.fieldId`, and `field.writeSource`, while keyMap retains the full engine path.
- Formula fields such as `calcField` may test only the final segment (`fieldId`, `writeMode`, and so on) inside those short include paths. This is intentional and lets one field renderer serve Create, Update, Compare, and Merge paths.
- `group` says how to interpret the field row:
  - `search_primaryField`: primary field searched by Search.
  - `search_deepField`: fallback/deep field searched by Search.
  - `write_eventTable`: business/event table field written by Update.
  - `write_logTable`: resolver/log table field written by Update Log.
  - `create_createRecord`: field written when Create creates a record.
  - `compare_eventFields`: field read by Compare from event records.
  - `step4.writeCreatedRecordTo`: field updated after a create succeeds.
- `eventField` is the stable semantic name for compare inputs, such as `orgRecordIds`, `personRecordIds`, or `completedDate`.
- Scripts should use `field.fieldId` for Airtable API calls, `field.fieldType` for serialization, and semantic columns such as `eventField` or `completion.*` for meaning.

## Current Engine Shapes

### Search

Key root:

```text
search
```

Important paths:

```text
search.terms.primaryTerm
search.terms.deepTerms
search.tables
search.tables.table
search.tables.table.searchFields
search.tables.table.searchFields.primaryField
search.tables.table.searchFields.deepFields
search.tables.table.deepFields.fieldId
search.results
```

Field groups:

```text
search_primaryField
search_deepField
```

Structural norm:

- One table setup row identifies the search table.
- One primary field row should map to `search.tables.table.searchFields.primaryField`.
- Zero or more deep field rows map to `search.tables.table.deepFields.fieldId`.
- Completion search also maps semantic completion paths such as `completion.completionSearchKey`.

### Update / Update Log

Key root:

```text
write
```

Important paths:

```text
write.tables
write.tables.table
write.tables.table.records
write.tables.table.records.record
write.tables.table.records.record.writeFields
write.tables.table.records.record.writeFields.field
write.tables.table.records.record.writeFields.field.fieldId
write.tables.table.records.record.writeFields.field.fieldType
write.tables.table.records.record.writeFields.field.writeMode
write.tables.table.records.record.writeFields.field.writeValue
write.tables.table.records.record.writeFields.field.writeSource
```

Field groups:

```text
write_eventTable
write_logTable
step4.writeCreatedRecordTo
```

Structural norm:

- Update is table-centered.
- A table row identifies the target table.
- Field rows identify the fields to write.
- Record identity should come from runtime context unless explicitly configured.
- `writeValue` is literal data.
- `writeSource` is a context/output path or token.
- Step scripts should resolve all field values first, then batch writes by table.

### Create

Key root:

```text
create
```

Important paths:

```text
create.tables
create.tables.toTable
create.tables.toTable.tableId
create.tables.toTable.newRecords
create.tables.toTable.newRecords.record
create.tables.toTable.newRecords.record.toFields
create.tables.toTable.newRecords.record.toFields.field
create.tables.toTable.newRecords.record.toFields.field.fieldId
create.tables.toTable.newRecords.record.toFields.field.fieldType
create.tables.toTable.newRecords.record.toFields.field.writeMode
create.tables.toTable.newRecords.record.toFields.field.writeValue
create.tables.toTable.newRecords.record.toFields.field.writeSource
```

Field group:

```text
create_createRecord
create.conflict
```

Structural norm:

- Create mirrors Update's field structure but produces new records instead of updating existing records.
- `toTable` identifies the destination table, `newRecords` is the record array, and `toFields` is the field array for each new record.
- Create fields use the same identity triple and value/source split as Update.
- Completion-specific semantic columns can mark fields such as completion key, search key, completion date, or created record ID.
- Older generated configs may still expose `create.tables.table.writeFields...` or a top-level `createRecord`; readers may accept those during migration, but new Datamap rows should use the canonical paths above.

### Compare

Key root:

```text
compare
```

Important paths:

```text
compare.event
compare.event.eventFields
compare.event.eventFields.field
compare.event.eventFields.field.fieldId
compare.event.eventFields.field.fieldType
compare.event.eventFields.field.writeMode
compare.event.eventFields.field.mergeable
compare.candidates
compare.candidates.orgs
compare.candidates.people
compare.candidates.dates
```

Field group:

```text
compare_eventFields
```

Structural norm:

- Compare reads configured fields from the trigger event and candidate/conflicting event.
- `eventField` gives each field a stable semantic key.
- `field.mergeable` marks fields that can be merged rather than treated as hard conflicts.
- Candidate data is output-driven; event field config is table/field-driven.

### Merge

Key root:

```text
merge
```

Important paths:

```text
merge.tables
merge.tables.table
merge.tables.table.rules
merge.tables.table.rules.rule
merge.tables.table.fields
merge.tables.table.fields.field
merge.tables.table.fields.field.fieldId
merge.tables.table.fields.field.fieldType
merge.tables.table.fields.field.mergeRule
```

Structural norm:

- Merge should consume Compare output plus configured rules.
- Merge field configs should identify fields, types, mergeability, and merge rules.
- The current keyMap includes `mergable`; prefer normalizing to `mergeable` in scripts while accepting both spellings.

### Update Log

Key root:

```text
log
```

Important paths:

```text
log.schema
log.inputs
log.configs
log.outputs
log.references
log.debug
log.conflictWorkflow
log.state
log.meta
```

Structural norm:

- Update Log writes resolver-observable state.
- It should use the same write engine mechanics as Update where possible.
- Log payloads are usually assembled from runtime output JSON rather than field rows.

## Naming Norms

- Engine names are title case: `Search`, `Update`, `Create`, `Compare`, `Merge`, `Update Log`.
- JSON paths are dotted and lower camel case where possible.
- Concrete Airtable metadata lives under `field.*`.
- Semantic field names live in purpose-specific columns such as `eventField` and `completion.*`.
- Table setup labels include step, engine/action, and table label.
- Field setup labels include table label and group.

## Script Rework Implications

The canonical generated runtime envelope is defined by
`schema/engine-config.schema.json` as `eventResolver.engineConfig.v1`.
The older `step1` through `step4` schema files remain migration inputs; runtime
normalizers may accept them, but new Datamap generation should emit the engine
envelope documented in `ENGINE_CONFIG_SHAPE.md`.

The step scripts should move toward these layers:

1. Load datamap exports or generated datamap JSON.
2. Select engine setup rows for the current step.
3. Use keyMap to understand expected JSON shape.
4. Use table rows to identify Airtable tables.
5. Use field rows to build field-level plans.
6. Resolve source values from canonical context/output JSON.
7. Execute generic engine behavior.
8. Write normalized outputs back to canonical context and log.

Practical script targets:

- `step1.js` and `step3.js` should become Search-engine invocations over configured table setups.
- `step2.js` should become Update/Update Log invocations over table-centered write configs.
- `stepX.js` should become Compare plus Merge-rule evaluation.
- `step4.js` should become Create/Update/Merge executor based on Step 3 and Step X decisions.
- `contextBuilder.js` should assemble canonical context and load datamap-generated configs rather than hand-coded step field names.

## Data Quality Notes

Observed cleanup items before script rework:

- Some key paths contain trailing spaces, such as `compare.candidates.org.eventOrg `.
- `merge.tables.table.fields.field.mergable` should be normalized to `mergeable`.
- Some table-rendered JSON fragments appear incomplete or formula-oriented rather than directly parseable JSON.
- Some search primary field fragments render as `[{}]`, so field rows should be treated as the source of truth for field IDs.
- `field.writeSource` and `field.writeValue` are often blank in the current export; scripts should tolerate blanks but validation should flag fields that need runtime values.
