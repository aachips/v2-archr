# Live Progress Tracker Implementation Plan

This plan describes how to move the live Progress Tracker base from the current hand-shaped resolver scripts toward the new datamap-driven resolver schema.

The implementation target is the 1-3, Step X, 4 workflow:

1. Step 1: search and resolve project, task, org, and person.
2. Step 2: write resolved values by table using `writeList`.
3. Step 3: search for an existing completion.
4. Step X: compare, merge, or route conflicts when an existing completion is found.
5. Step 4: create, update, merge, or conflict-log the final completion outcome.

## Operating Principles

- The live base should not receive business-table writes until config generation, validation, and dry-run checks pass.
- The datamap tables are the source of truth for engine, table, key, and field structure.
- The existing scripts remain the migration baseline and rollback reference.
- The eventJSON and canonical context schema remain the runtime contract.
- Step scripts should become thin wrappers around generic engine behavior.
- Field values should be resolved before writes are sent to Airtable.
- Writes should be grouped by table, with one write batch per target table.

## Source Of Truth

The live implementation should preserve the structural responsibilities documented in `STRUCTURAL_NORMS.md`:

- `datamap-engines-export.csv` defines operation families: Search, Update, Update Log, Compare, Merge, and Create.
- `datamap-keyMap-export.csv` defines stable JSON paths.
- `datamap-tables-export.csv` binds engine setups to concrete Airtable tables.
- `datamap-fields-export.csv` binds field IDs, field types, field labels, and semantic roles to keyMap paths.
- `schema/canonical-context.schema.json` defines the resolver runtime shape.
- `schema/step*-config.schema.json` files define generated config contracts.

The live base should mirror these tables directly, then generate script config JSON from them.

## Phase 0: Baseline And Backup

Before changing live behavior:

- Export the current resolver table, datamap tables, field map, table map, engine map, and base schema.
- Save the current working versions of `contextBuilder.js`, `step1.js`, `step2.js`, and `step3.js`.
- Save at least one resolver row that has successfully run through Step 3 in dry-run mode.
- Save its canonical context JSON, eventJSON, run log, and all step config fields.
- Confirm the active dry-run field, resolver status field, message fields, and current resolver view.
- Identify which automations currently call each script.

Exit gate:

- A rollback copy exists for every script and config field that will be changed.
- One known-good dry-run resolver row is available as a regression fixture.

## Phase 1: Normalize Live Datamap Rows

Clean the live datamap before generating configs:

- Trim whitespace in `json_key`, especially paths such as `compare.candidates.org.eventOrg`.
- Normalize `mergable` to `mergeable`, while scripts temporarily accept both spellings.
- Ensure engine names are stable: `Search`, `Update`, `Update Log`, `Compare`, `Merge`, `Create`.
- Ensure `tableResolver` labels are unique and match the intended step and engine.
- Ensure each field row has `field.fieldId`, `field.fieldType`, and `field.fieldLabel`.
- Ensure every field row used by a step has a valid `keyMap` path.
- Fill or intentionally document blank `field.writeSource` and `field.writeValue` cells.
- Treat field rows as the source of truth when rendered table fragments are incomplete.

Exit gate:

- Datamap validation can identify all Step 1, Step 2, Step 3, Step X, and Step 4 setup rows.
- Every configured Airtable field ID and table ID exists in the live base.

## Phase 2: Generate Config JSON From Datamap

Create a generator that reads the live datamap rows and emits the config fields consumed by the scripts.

Generated configs:

- `step1_Config`: Search config for project, task, org, and person.
- `step2_Config`: table-centered write config using `writeList`.
- `step3_Config`: Search config for completion lookup.
- `stepX_Config`: Compare and Merge config for existing completion workflows.
- `step4_Config`: Create, merge, and conflict-write config for final action.

Step 2 target shape:

```json
{
  "step2": {
    "writeList": [
      {
        "table": "eventTable",
        "tableId": "tbl...",
        "fields": [
          {
            "person": {
              "fieldId": "fld...",
              "type": "multipleRecordLinks",
              "value": "_personFound",
              "mode": "replace"
            }
          }
        ]
      },
      {
        "table": "logTable",
        "tableId": "tbl...",
        "fields": [
          {
            "person": {
              "fieldId": "fld...",
              "type": "multipleRecordLinks",
              "value": "_personFound",
              "mode": "replace"
            }
          }
        ]
      }
    ]
  }
}
```

Generation rules:

- `write_eventTable` field rows generate `eventTable` write fields.
- `write_logTable` field rows generate `logTable` write fields.
- `field.fieldId` maps to `fieldId`.
- `field.fieldType` maps to `type`.
- `field.writeMode` maps to `mode`, defaulting to `replace` only when the table design says replacement is intended.
- `field.writeSource` maps to `value` when it is a runtime token such as `_personFound`.
- `field.writeValue` maps to `value` when the value is literal.
- Runtime record IDs should usually stay out of generated field configs and come from canonical context.

Exit gate:

- All generated JSON parses.
- Generated JSON validates against the schema files in `task-engine/task-resolver/schema`.

## Phase 3: Add Live Preflight Validation

Extend the validator to run before scripts perform live writes.

Validation checks:

- Table IDs exist.
- Field IDs exist on their declared table.
- Field types match expected serializer behavior.
- `keyMap` paths used by field rows exist.
- Search configs have primary fields where required.
- Step 2 `writeList` destinations have table IDs and at least one field.
- Step X has completion table, event table, event link field, event fields, mergeable fields, and default decision.
- Token values resolve against canonical context, such as `_personFound`, `_orgFound`, `outputs.personFound`, or `inputs.currentEventRecordId`.
- Required eventJSON inputs exist: event record ID, event project ID, event date, completion key, and completion search key.

Exit gate:

- Validation blocks unsafe live writes with a clear resolver message.
- Dry-run can continue after validation and write the validation report to the resolver log.

## Phase 4: Rework Context Builder

Update `contextBuilder.js` so it is the single canonical context assembler.

Required behavior:

- Load Step 1, Step 2, Step 3, Step X, and Step 4 generated configs.
- Preserve the canonical `inputs`, `outputs`, `references`, `debug`, `state`, and `meta` layout.
- Preserve eventJSON aliases currently required by the scripts.
- Add datamap references or generated config references to `context.references`.
- Normalize token names and path references consistently.
- Record config field names in `context.meta.configFields`.

Important runtime inputs:

- `inputs.currentEventRecordId`
- `inputs.currentEventRecordIds`
- `inputs.resolverRecordId`
- `inputs.eventProjectId`
- `inputs.eventDate`
- `inputs.completionKey`
- `inputs.completionSearchKey`

Exit gate:

- The known-good dry-run resolver row produces a canonical context that validates against `canonical-context.schema.json`.
- The Step 3 dry-run still exposes enough completion lookup data for Step X.

## Phase 5: Extract Generic Engine Helpers

Move repeated script behavior into reusable Airtable-compatible helpers.

Shared helpers:

- `getPath` and `setPath` for context paths.
- token resolution for `_personFound`, `_orgFound`, `_taskFound`, `_projectFound`, and dotted context paths.
- Airtable field serialization by field type.
- config normalization for `type` versus `fieldType`.
- table and field lookup by ID.
- record ID source resolution.
- chunked `updateRecordsAsync` and `createRecordsAsync` calls.
- dry-run reporting with the same payload shape as live writes.

Engine helpers:

- Search runner for Step 1 and Step 3.
- Update runner for Step 2 and Update Log.
- Compare runner for Step X.
- Merge decision runner for Step X.
- Create runner for Step 4.

Exit gate:

- Step wrappers can call generic helpers without duplicating table traversal and token resolution logic.

## Phase 6: Script Migration Order

Migrate scripts in this order:

1. `contextBuilder.js`
2. `step1.js`
3. `step2.js`
4. `step3.js`
5. `stepX.js`
6. `step4.js`

Reasoning:

- Context must stabilize before step outputs are meaningful.
- Step 1 and Step 3 are both Search engine cases.
- Step 2 establishes the table-centered write behavior.
- Step X depends on Step 3 completion outputs.
- Step 4 depends on Step X decisions and Step 2 write mechanics.

Exit gate:

- Each script can run in dry-run mode independently from the Script Extension before being attached to automation.

## Phase 7: Live Dry-Run Sequence

Use one controlled resolver row.

Dry-run sequence:

1. Run Context Builder.
2. Run Step 1 and compare project, task, org, and person outputs to the old script output.
3. Run Step 2 with business writes simulated and resolver/log writes allowed only if needed for debugging.
4. Run Step 3 and confirm completion lookup behavior.
5. Run Step X only on rows where Step 3 found an existing completion.
6. Run Step 4 in simulation mode first.
7. Run one controlled Step 4 create after all prior outputs match expectations.

Exit gate:

- The run log clearly shows resolved values, write payloads, skipped writes, and next-step routing.

## Phase 8: Acceptance Scenarios

Test these live-base branches before cutover:

- No completion found: Step 4 creates a new completion.
- One compatible completion found: Step X chooses `reuseExisting`.
- One mergeable completion found: Step X chooses `mergeIntoExisting`.
- One conflicting completion found: Step X chooses `createNewAndConflict` or `manualReview`.
- Multiple completions found: Step X follows the configured multiple-completion policy.
- Missing completion search key: validation stops before Step 3 or Step X can produce misleading output.
- Missing linked event record: validation stops before any business-table write.

Exit gate:

- Every branch has a saved resolver row with expected outputs and run log.

## Phase 9: Cutover

Cutover should be gradual:

- Keep old script copies and old config field values in backup fields.
- Enable the new scripts for one resolver workflow at a time.
- Start with dry-run enabled.
- Monitor resolver status, run log, and message fields.
- Enable live writes only after Script Extension runs match expected output.
- Move automations to the new scripts only after manual runs pass.

Exit gate:

- New scripts have handled at least one clean create path and one existing-completion path in the live base.

## Rollback Plan

If a live issue appears:

- Disable resolver automations.
- Re-enable dry-run.
- Restore previous script/config copies.
- Use the run log to identify which resolver rows ran under the new scripts.
- Separate resolver/log writes from business-table writes when assessing cleanup.
- Restore previous automation script bodies only after confirming no queue rows are mid-run.

Rollback is easiest while Step 2 business writes remain simulated, so live write enablement should be the final cutover step.

## Implementation Deliverables

- Datamap cleanup checklist for the live base.
- Config generator for Step 1, Step 2, Step 3, Step X, and Step 4.
- Validator updates for datamap rows and generated config JSON.
- Reworked `contextBuilder.js`.
- Reworked `step1.js`, `step2.js`, and `step3.js`.
- New `stepX.js`.
- New `step4.js`.
- Dry-run fixture resolver rows and expected output snapshots.
- Rollback copies of current scripts and config values.

## Immediate Next Work

1. Build the config generator against the exported `reworked/*.csv` files.
2. Compare generated config JSON against the current config fields in the live base export.
3. Extend validation to report datamap cleanup issues before script execution.
4. Use the known-good Step 3 dry-run resolver row as the first regression fixture.
5. Rework scripts only after generated configs and validation are stable.

