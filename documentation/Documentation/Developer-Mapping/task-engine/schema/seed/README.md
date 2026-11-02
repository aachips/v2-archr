# Engine Base Seed

`engine-base.seed.json` is generated from the existing resolver configuration
exports, Progress Task lists, and costing JSON Schemas. It is safe to rerun
because every target table uses a deterministic primary key.

## Populate Airtable

1. Open the Scripting Extension in the `Engine` base
   (`appDRNp3jByjHVBc9`).
2. Paste in `populate-engine-base.js`.
3. Run it and choose `engine-base.seed.json`.
4. Choose `Create missing only` for the first load. Use `Upsert existing` after
   regenerating the seed from updated source lists.

The seed populates configuration/policy tables and the flattened
`costing-input`, `costing-common`, and `costing-snapshot` schema contracts.
Project Events, costing transactions and snapshots, resolver runs, event
intents, run logs, and task completions remain runtime-owned.

The `Progress-Tasks` records are treated as milestone policies. Office
subtasks are loaded as reusable `Requirements` plus normalized
`Milestone-Requirements` mappings. `Requirement-State` is runtime-owned and
keeps one mutable record per `scopeKey|requirementKey`; it is not an
append-only ledger.

Before loading a seed that includes Office requirements, create tables 18-20
from the parent schema directory. The loader now checks for all required
tables before writing anything and reports missing names up front.

## Costing engine

The costing seed adds a three-step controller flow:

1. Validate sparse, idempotent cost input.
2. Resolve current reporting cost using `act > est > robo` precedence while
   retaining every observation.
3. Publish a resolved snapshot centered on `projectKey`.

Each captured costing schema field is also registered in `Field-Configs` and
`JSON-Key-Map`, so nested contract paths can be selected and mapped by the
controller layer.

## Task source precedence

The generator merges the existing exports copied into `source/` in this order:

1. `[⚙️Progress Tasks].csv` supplies the canonical 85-row task list, event
   lookups, and phase-task numbers.
2. `(⚙️Progress) Tasks .csv` enriches the 82 matching tasks with task IDs,
   descriptions, phase data, task codes, task types, and document metadata.
3. `⚙️Progress Tasks-⚙️Progress Tasks CSV.csv` supplies responsible roles.
4. `[⚙️Progress Tasks]-Grid 3.csv` supplies source record IDs and explicit
   `Triggers Completion Of` / `Assume Complete If` relationships.
5. `office-subtasks.csv` is a normalized copy of the Office Subtasks export.
   It supplies requirement definitions, child requirement relationships,
   milestone mappings, categories, and system interactions.

The historical `Clam` label in Grid 3 is matched to the canonical `Claim`
record through its `_CLAIM_` event lookup.

## Regenerate

From the repository root:

```powershell
node elemental-integration/task-engine/schema/seed/generate-engine-seed.js
```

Use `--task-source "path"` only when regenerating from a different directory
that contains the four normalized source filenames.
