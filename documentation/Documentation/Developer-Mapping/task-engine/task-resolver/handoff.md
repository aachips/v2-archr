# Progress Event Resolver — Project Handoff

## 1. Project scope

This project is replacing a monolithic Airtable Progress Event resolver with a configuration-driven workflow.

The resolver processes a `◼️Project Event V2` record and attempts to:

1. Identify the related Project, Progress Task, Organization, and Person records.
2. Write those links back to the Event.
3. Determine whether a matching `☑️Project Task Completion` already exists.
4. When no Completion exists, create one.
5. When a Completion already exists, compare the current Event with the Event already linked to that Completion.
6. Reuse or merge existing records whenever the evidence is compatible.
7. Create duplicate Completion and Conflict records only when the evidence cannot safely be reconciled.
8. Preserve detailed debugging state in the `[🤖Event_Resolver]` queue table.

The central architectural pattern is:

```text
Configuration
      ↓
Generic engine
      ↓
Canonical outputs
```

The scripts should contain reusable mechanics, while Airtable-generated JSON configurations specify:

* What to search.
* Where to write.
* Which fields to read.
* How to compare values.
* Which rules produce which decisions.

This keeps the resolver adaptable without hardcoding every Airtable table, field, or decision branch into JavaScript.

---

# 2. Resolver queue and execution model

The `[🤖Event_Resolver]` table acts as:

* Queue handler.
* Current-record cursor.
* Configuration container.
* Debug surface.
* Persistent run log.
* Canonical workflow-state store.

The scripts do not prompt for a resolver record.

Each script:

1. Loads resolver table:

```text
tbloJ5eN46v1Zx7AG
```

2. Loads Active view:

```text
viwT48UlenhQ9OBbh
```

3. Uses the first record returned by that view.

4. Warns in the console if more than one resolver row is present.

The resolver row includes:

* `canonicalContextJSON`
* `step1_config`
* `step2_config`
* `step3_config`
* `step4_config`
* `stepX⁉️_Config`
* Search result/debug fields
* Step markdown-message fields
* Shared JSON run-log field
* Dry Run checkbox
* Current Event reference

---

# 3. Workflow overview

```text
┌─────────────────────────────────────────────┐
│ Context Builder                             │
│                                             │
│ Reads resolver row, Event JSON, configs,    │
│ debug fields, and output fields.            │
│                                             │
│ Writes canonicalContextJSON.                │
└──────────────────────┬──────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────┐
│ Step 1 — Search Resolver                    │
│                                             │
│ Searches:                                   │
│ • 🎯 Sync                                   │
│ • ⚙️ Progress Tasks                         │
│ • 💜 Orgs                                   │
│ • 💟 People                                 │
│                                             │
│ Writes results to context.outputs and       │
│ resolver debug fields.                      │
└──────────────────────┬──────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────┐
│ Step 2 — Generic Field Writer               │
│                                             │
│ Writes resolved record IDs to:              │
│ • Trigger Event linked-record fields        │
│ • Resolver text/debug fields                │
│                                             │
│ Dry Run: resolver writes occur, but         │
│ business-table writes are simulated.        │
└──────────────────────┬──────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────┐
│ Step 3 — Completion Search                  │
│                                             │
│ Searches ☑️Project Task Completion using    │
│ completionSearchKey.                        │
└───────────────┬─────────────────────────────┘
                │
        ┌───────┴────────┐
        │                │
        ▼                ▼
No Completion       Completion found
        │                │
        │                ▼
        │      ┌──────────────────────────────┐
        │      │ Step X — Conflict Workflow  │
        │      │                              │
        │      │ Load existing Completion,   │
        │      │ its linked Event, and the   │
        │      │ current trigger Event.      │
        │      │                              │
        │      │ Build comparison object.    │
        │      │ Evaluate conflict rules.    │
        │      │ Produce decision plan.      │
        │      └──────────────┬───────────────┘
        │                     │
        └──────────────┬──────┘
                       ▼
┌─────────────────────────────────────────────┐
│ Step 4 — Completion Action Executor         │
│                                             │
│ Based on Step 3 / Step X decision:          │
│ • Create new Completion                     │
│ • Reuse existing Completion                 │
│ • Merge compatible data                     │
│ • Create new Completion + Conflict record   │
│ • Halt for manual review                    │
└─────────────────────────────────────────────┘
```

---

# 4. Reporting and persistent state

All scripts follow the same reporting scheme.

## Shared run log

Field ID:

```text
fldFP6ESKhHj5AKSK
```

Shape:

```json
{
  "schema": "eventResolver.runLog.v1",
  "log": [
    {
      "timestamp": "ISO timestamp",
      "step": "step1",
      "status": "complete",
      "resolver": {},
      "summary": {},
      "results": []
    }
  ],
  "updatedAt": "ISO timestamp"
}
```

Every script appends one log entry on success or failure.

The log is not overwritten between steps.

## Step message fields

Each step writes a human-readable Markdown summary to its own message field.

Examples:

```text
# Step 1 Complete

Resolver row: **Julian**

Searches run: **4**

Total matched records: **4**
```

These fields contain the same high-level summary printed by:

```js
output.markdown(markdownMessage);
```

## Console logging

Detailed objects remain available in the Scripting Extension console:

```js
console.log({
    step,
    status,
    results,
    outputs,
    state,
    runLog
});
```

## Canonical context

Each step updates:

```text
canonicalContextJSON
```

This remains the authoritative state passed between scripts.

---

# 5. Core reusable functions

## 5.1 `getPath(object, path)`

Resolves paths such as:

```text
outputs.projectFound
inputs.eventDate
debug.personFound
conflictWorkflow.booleans.orgRecordsConflict
```

Conceptual implementation:

```js
function getPath(object, path) {
    return String(path)
        .split(".")
        .reduce(
            (current, key) =>
                current == null
                    ? undefined
                    : current[key],
            object
        );
}
```

---

## 5.2 `collectValues(value)`

Normalizes possible Airtable/config values into a unique string array.

Supports:

* Scalar strings.
* Comma-, pipe-, semicolon-, or newline-delimited strings.
* JSON arrays stored as text.
* Airtable `{id, name}` objects.
* Arrays of linked-record objects.
* Nested arrays and objects.

Example:

```js
collectValues([
    { id: "recA" },
    { id: "recB" }
]);
```

Returns:

```json
["recA", "recB"]
```

---

## 5.3 `collectRecordIds(value)`

Filters normalized values to Airtable record IDs.

```js
function collectRecordIds(value) {
    return collectValues(value).filter(value =>
        /^rec[A-Za-z0-9]{14}$/.test(value)
    );
}
```

---

## 5.4 `serializeValue(value, fieldType)`

Transforms canonical values into Airtable write formats.

Examples:

```text
multipleRecordLinks
    ["recA", "recB"]
    ↓
    [{ "id": "recA" }, { "id": "recB" }]

singleLineText
    ["recA", "recB"]
    ↓
    "recA,recB"

singleSelect
    "Active"
    ↓
    { "name": "Active" }

checkbox
    truthy value
    ↓
    true
```

---

## 5.5 `applyWriteMode(...)`

Supports destination-specific write behavior:

```text
replace
append
appendUnique
clear
ignoreIfBlank
```

Example contract:

```js
applyWriteMode({
    existingValue,
    incomingValue,
    fieldType,
    mode
});
```

---

## 5.6 `runSearch(searchName, searchConfig, context)`

Generic search engine used by Steps 1 and 3.

### Primary search

Searches:

```text
searchConfig.searchPrimaryFieldId
```

against:

```text
context.inputs[searchConfig.jsonPrimaryKey]
```

### Deep fallback

Only runs when the primary search produces zero records.

It collects values from:

```text
searchConfig.jsonDeepKeys
```

and compares them against:

```text
searchConfig.searchDeepFieldIds
```

### Search output

```json
{
  "searchName": "projectSearch",
  "tableId": "tbl...",
  "tableName": "[🎯 Sync]",
  "matchMethod": "primary",
  "matchCount": 1,
  "recordIds": ["rec..."],
  "primarySearchValues": [],
  "deepSearchValues": []
}
```

---

## 5.7 `normalizeSearchConfigs(stepConfig)`

Accepts both:

```json
[
  {
    "projectSearch": {}
  }
]
```

and:

```json
{
  "projectSearch": {}
}
```

Returns a consistent list:

```json
[
  {
    "searchName": "projectSearch",
    "searchConfig": {}
  }
]
```

---

## 5.8 `normalizeStep2Writes(stepConfig)`

Accepts the current Step 2 configuration and returns a flat list of write instructions.

Preferred structure:

```json
{
  "mode": "replace",
  "fieldWrites": [
    {
      "writeName": "projectWrite",
      "source": "outputs.projectFound",
      "writeTo": []
    }
  ]
}
```

---

## 5.9 `buildWritePlan(...)`

Resolves each source and produces a deterministic plan before writing.

Each planned field write contains:

```json
{
  "writeName": "projectWrite",
  "sourcePath": "outputs.projectFound",
  "sourceValue": ["rec..."],
  "tableId": "tbl...",
  "tableName": "[◼️Project Event V2]",
  "recordId": "rec...",
  "fieldId": "fld...",
  "fieldName": "[🎯 Sync]",
  "fieldType": "multipleRecordLinks",
  "mode": "replace",
  "shouldExecute": false,
  "dryRunSkipped": true,
  "existingValue": [],
  "serializedValue": [
    {
      "id": "rec..."
    }
  ]
}
```

---

## 5.10 `executeWritePlan(plans)`

Groups executable writes by:

```text
tableId + recordId
```

and submits one `updateRecordAsync()` call per destination record.

Dry Run policy:

```text
Resolver-table destination
    → execute

Any other table
    → simulate only
```

Dry Run checkbox:

```text
tbloJ5eN46v1Zx7AG
fld7UnBJIpVWFKr56
```

---

## 5.11 `compareSets(left, right)`

Creates canonical comparisons for linked records and identifier arrays.

Output:

```json
{
  "left": ["A"],
  "right": ["B"],
  "leftCount": 1,
  "rightCount": 1,
  "bothPresent": true,
  "eitherPresent": true,
  "equal": false,
  "conflict": true,
  "overlap": [],
  "hasOverlap": false,
  "leftOnly": ["A"],
  "rightOnly": ["B"],
  "leftMissing": false,
  "rightMissing": false,
  "mergeableMissing": false
}
```

Current semantics:

```text
equal
    Both sets are present and contain the same unique values.

conflict
    Both sets are present and are not equal.

mergeableMissing
    One side is empty and the other is present.
```

---

## 5.12 `compareDates(triggerDate, conflictingDate, windowDays)`

Produces:

```json
{
  "triggerPresent": true,
  "conflictingPresent": true,
  "bothPresent": true,
  "same": false,
  "different": true,
  "deltaDays": 8,
  "windowDays": 30,
  "withinWindow": true,
  "outsideWindow": false,
  "earlierSource": "trigger",
  "earlierDate": "2025-05-15T00:00:00.000Z",
  "laterSource": "conflicting",
  "laterDate": "2025-05-23T00:00:00.000Z",
  "mergeableMissing": false
}
```

---

## 5.13 `compareCrossIdentity(...)`

Compares Person Organization IDs against Organization Directory IDs across both Events.

It produces four comparisons:

```text
trigger.personOrgIds
    vs trigger.orgDirIds

conflicting.personOrgIds
    vs conflicting.orgDirIds

trigger.personOrgIds
    vs conflicting.orgDirIds

conflicting.personOrgIds
    vs trigger.orgDirIds
```

And returns:

```json
{
  "anyPresentConflict": true
}
```

This drives the severe identity-conflict rule.

---

# 6. Step-by-step engines

## Step 1 — Search Resolver

```text
Step 1 config
      ↓
runSearch()
      ↓
context.outputs
```

### Inputs

```text
context.inputs.eventProjectId
context.inputs.eventLookup
context.inputs.partnerOrg
context.inputs.partnerPerson
```

### Outputs

```text
context.outputs.projectFound
context.outputs.taskFound
context.outputs.orgFound
context.outputs.personFound
```

### Resolver mirrors

```text
found🎯Project
found⚙️Tasks
found💜Org
found💟People
```

---

## Step 2 — Generic Field Writer

```text
Step 2 config
      ↓
buildWritePlan()
      ↓
executeWritePlan()
      ↓
business-table fields + resolver debug fields
```

### Source convention

```text
outputs.*
debug.*
inputs.*
```

Example:

```json
{
  "source": "outputs.projectFound"
}
```

The datamap formula can globally replace:

```text
outputs.
```

with:

```text
debug.
```

for test-source behavior.

### Dry Run

When checked:

* Resolver log/debug fields are updated.
* Event links are not changed.
* Simulated Event writes are recorded in the run log and context state.

---

## Step 3 — Completion Search

```text
Step 3 config
      ↓
runSearch()
      ↓
context.outputs.completionFound
```

### Routing output

```json
{
  "shouldRunStep4": true,
  "shouldRunStepX": false
}
```

or:

```json
{
  "shouldRunStep4": false,
  "shouldRunStepX": true
}
```

The previous scripts called this branch `shouldRunStep5`; it should now be renamed to `shouldRunStepX`.

### Important current issue

The supplied canonical context contains blank values for:

```text
inputs.completionKey
inputs.completionSearchKey
```

The supplied Step 3 run therefore searched with no primary search values and found zero records. This must be addressed before production conflict testing.
Possible cause:

* These keys depend on Event linked fields.
* Step 2 was run in Dry Run mode.
* The Event links were therefore not updated.
* Formula/lookup-generated completion keys remained blank.

---

## Step X — Conflict Comparison and Decision Workflow

Step X is logically split into two engines.

### Phase A: comparison builder

```text
Step X field/table config
      ↓
load Completion + Events
      ↓
compareSets() / compareDates()
      ↓
context.conflictWorkflow.comparison
      ↓
context.conflictWorkflow.booleans
```

### Phase B: rule evaluator

```text
Step X rules
      ↓
named boolean lookup
      ↓
matched rules
      ↓
decision plan
```

Example simplified rule:

```json
{
  "key": "orgRecordsConflict",
  "priority": 30,
  "stopOnMatch": true,
  "boolean": "orgRecordsConflict",
  "decision": "createNewAndConflict",
  "actions": [
    "createNewCompletion",
    "createConflictRecord"
  ],
  "reasonCode": "ORG_RECORD_CONFLICT"
}
```

Evaluator:

```js
const passed =
    context.conflictWorkflow.booleans[
        rule.boolean
    ] === true;
```

### Step X does not initially modify business records

It should only output a plan:

```json
{
  "decision": "mergeIntoExisting",
  "reasonCodes": [],
  "actions": [],
  "createNewCompletion": false,
  "createConflictRecord": false
}
```

Step 4 executes that plan.

---

## Step 4 — Completion Action Executor

```text
Step 3 result + Step X decision
      ↓
create/update engine
      ↓
Completion/Event/Conflict writes
```

Possible decisions:

```text
createNew
reuseExisting
mergeIntoExisting
createNewAndConflict
manualReview
```

### No Completion found

Create the configured Completion.

### Existing Completion, no conflict

Reuse it.

### Compatible merge

Update the Event and/or Completion using Step X actions.

### Irreconcilable conflict

Create:

1. A new Completion.
2. A `⁉️Completion Record Conflicts` record linking both Completion records.
3. A summary of the failed conflict resolution.

---

# 7. Conflict rules

Rules should be evaluated in ascending priority order.

Severe rules stop evaluation.

Merge rules may accumulate actions.

## Recommended rule order

```text
10  PersonOrg / OrgDir cross-conflict
20  OrgDir conflict
30  Direct Org-record conflict
35  Completion dates outside allowed window
40  People differ but PersonOrg matches
50  Completion dates differ within allowed window
60  Non-conflicting missing values can be copied
Default: reuse existing Completion
```

## Current named booleans

```json
{
  "hasExistingCompletion": true,
  "hasConflictingEvent": true,
  "multipleCompletionsFound": false,
  "multipleConflictingEvents": false,
  "orgRecordsConflict": false,
  "peopleConflict": true,
  "personOrgIdsEqual": true,
  "peopleConflictSamePersonOrg": true,
  "orgDirIdsConflict": false,
  "personOrgConflictsWithOrgDir": false,
  "completedDatesDiffer": true,
  "datesWithinWindow": true,
  "datesOutsideWindow": false,
  "hasMergeableMissingValues": true
}
```

---

# 8. Latest configuration schemas

## 8.1 Step 1 schema

```json
{
  "step1": [
    {
      "projectSearch": {
        "searchTableId": "tbl4HhGi7F6lKzhfB",
        "searchPrimaryFieldId": "fldnRScSsfp3I8Y1Y",
        "searchDeepFieldIds": [
          "fldnRScSsfp3I8Y1Y",
          "fldhZnK0J8ucktSgY"
        ],
        "jsonPrimaryKey": "eventProjectId",
        "jsonDeepKeys": [
          "eventProjectId",
          "projectRecordId",
          "eventProject"
        ]
      }
    },
    {
      "taskSearch": {
        "searchTableId": "tblECgtClvoenWXJn",
        "searchPrimaryFieldId": "fldULcvgqT3tqLgmc",
        "searchDeepFieldIds": [
          "fldULcvgqT3tqLgmc",
          "fldXFp3GKWTzF9tU2",
          "fldTl4KHW1ZkZ3A35"
        ],
        "jsonPrimaryKey": "eventLookup",
        "jsonDeepKeys": [
          "eventLookup",
          "taskName",
          "phaseTaskId",
          "fromPhaseTaskId"
        ]
      }
    },
    {
      "orgSearch": {
        "searchTableId": "tble3Hu7TwYwsJyKZ",
        "searchPrimaryFieldId": "fldnVR4H3PKBSLaWG",
        "searchDeepFieldIds": [
          "fldnVR4H3PKBSLaWG",
          "fldADXXfYuycCnHiM",
          "fld0DNWpCNmmsLdDq",
          "fldvki6CMV82bevJO",
          "fldtl7zogy0XymkIC",
          "fldvYbLJciY7sKeO9",
          "fldqsHDxgrEAmJBZH",
          "fldN7RRjdkUzxRjf5"
        ],
        "jsonPrimaryKey": "partnerOrg",
        "jsonDeepKeys": [
          "partnerOrg",
          "eventPartner"
        ]
      }
    },
    {
      "personSearch": {
        "searchTableId": "tbljSOvZOrolS2At3",
        "searchPrimaryFieldId": "fldahrTBg0ASw7JyT",
        "searchDeepFieldIds": [
          "fldahrTBg0ASw7JyT",
          "fldGyGzB785pu9oZ2",
          "fldAAWrP6OgSFtW1P",
          "fldNbhakW4CtDAMPE",
          "flda37gZnN996g7jl"
        ],
        "jsonPrimaryKey": "partnerPerson",
        "jsonDeepKeys": [
          "partnerPerson",
          "person"
        ]
      }
    }
  ]
}
```

---

## 8.2 Step 2 schema

```json
{
  "step2": {
    "mode": "replace",
    "fieldWrites": [
      {
        "writeName": "projectWrite",
        "source": "outputs.projectFound",
        "writeTo": [
          {
            "tableId": "tblOhnfdIlabxXOqL",
            "recordId": "_EVENT_REC_ID_",
            "fields": [
              {
                "fieldId": "fldf9H8hS2Qka3Pcr",
                "fieldType": "multipleRecordLinks",
                "mode": "replace"
              }
            ]
          },
          {
            "tableId": "tbloJ5eN46v1Zx7AG",
            "recordId": "_LOG_REC_ID_",
            "fields": [
              {
                "fieldId": "fldFpq2RRrImJ2VKT",
                "fieldType": "singleLineText",
                "mode": "replace"
              }
            ]
          }
        ]
      },
      {
        "writeName": "taskWrite",
        "source": "outputs.taskFound",
        "writeTo": [
          {
            "tableId": "tblOhnfdIlabxXOqL",
            "recordId": "_EVENT_REC_ID_",
            "fields": [
              {
                "fieldId": "fld7nIq32wgLERY6Y",
                "fieldType": "multipleRecordLinks",
                "mode": "replace"
              }
            ]
          },
          {
            "tableId": "tbloJ5eN46v1Zx7AG",
            "recordId": "_LOG_REC_ID_",
            "fields": [
              {
                "fieldId": "fldekXfmgBRNPciQj",
                "fieldType": "singleLineText",
                "mode": "replace"
              }
            ]
          }
        ]
      },
      {
        "writeName": "orgWrite",
        "source": "outputs.orgFound",
        "writeTo": [
          {
            "tableId": "tblOhnfdIlabxXOqL",
            "recordId": "_EVENT_REC_ID_",
            "fields": [
              {
                "fieldId": "fld9xEMyUPJJFjTYL",
                "fieldType": "multipleRecordLinks",
                "mode": "replace"
              }
            ]
          },
          {
            "tableId": "tbloJ5eN46v1Zx7AG",
            "recordId": "_LOG_REC_ID_",
            "fields": [
              {
                "fieldId": "fld9tmYEV7LPs2cs0",
                "fieldType": "singleLineText",
                "mode": "replace"
              }
            ]
          }
        ]
      },
      {
        "writeName": "personWrite",
        "source": "outputs.personFound",
        "writeTo": [
          {
            "tableId": "tblOhnfdIlabxXOqL",
            "recordId": "_EVENT_REC_ID_",
            "fields": [
              {
                "fieldId": "fldELoHodyPNYl1pz",
                "fieldType": "multipleRecordLinks",
                "mode": "replace"
              }
            ]
          },
          {
            "tableId": "tbloJ5eN46v1Zx7AG",
            "recordId": "_LOG_REC_ID_",
            "fields": [
              {
                "fieldId": "flddkg19RMoCgFvEN",
                "fieldType": "singleLineText",
                "mode": "replace"
              }
            ]
          }
        ]
      }
    ]
  }
}
```

---

## 8.3 Step 3 schema

```json
{
  "step3": [
    {
      "completionSearch": {
        "searchTableId": "tbl1mIQg2utmj7Vqt",
        "searchPrimaryFieldId": "fldU5d3NTJYCQJAK0",
        "searchDeepFieldIds": [],
        "jsonPrimaryKey": "completionSearchKey",
        "jsonDeepKeys": []
      }
    }
  ]
}
```

---

## 8.4 Step X comparison schema

```json
{
  "stepX": {
    "workflowName": "completionConflictResolution",
    "existingCompletionSource": "outputs.completionFound",
    "triggerEventSource": "inputs.currentEventRecordId",
    "dateWindowDays": 30,

    "completionTableId": "tbl1mIQg2utmj7Vqt",
    "completionEventLinkFieldId": "fldT3U8DIaHuEoP2a",

    "eventTableId": "tblOhnfdIlabxXOqL",

    "eventFields": {
      "completedDate": {
        "fieldId": "fld...",
        "fieldType": "date"
      },
      "orgRecordIds": {
        "fieldId": "fld9xEMyUPJJFjTYL",
        "fieldType": "multipleRecordLinks"
      },
      "personRecordIds": {
        "fieldId": "fldELoHodyPNYl1pz",
        "fieldType": "multipleRecordLinks"
      },
      "personOrgIds": {
        "fieldId": "fld...",
        "fieldType": "multipleLookupValues"
      },
      "orgDirIds": {
        "fieldId": "fld...",
        "fieldType": "multipleLookupValues"
      }
    },

    "mergeableFields": [
      {
        "key": "orgRecordIds",
        "fieldId": "fld9xEMyUPJJFjTYL",
        "fieldType": "multipleRecordLinks"
      },
      {
        "key": "personRecordIds",
        "fieldId": "fldELoHodyPNYl1pz",
        "fieldType": "multipleRecordLinks"
      }
    ],

    "multipleCompletionPolicy": "manualReview",
    "multipleConflictingEventPolicy": "manualReview",

    "rules": [
      {
        "key": "personOrgConflictsWithOrgDir",
        "priority": 10,
        "stopOnMatch": true,
        "boolean": "personOrgConflictsWithOrgDir",
        "decision": "createNewAndConflict",
        "actions": [
          "createNewCompletion",
          "createConflictRecord"
        ],
        "reasonCode": "PERSON_ORG_ORG_DIR_CONFLICT"
      },
      {
        "key": "orgDirIdsConflict",
        "priority": 20,
        "stopOnMatch": true,
        "boolean": "orgDirIdsConflict",
        "decision": "createNewAndConflict",
        "actions": [
          "createNewCompletion",
          "createConflictRecord"
        ],
        "reasonCode": "ORG_DIR_ID_CONFLICT"
      },
      {
        "key": "orgRecordsConflict",
        "priority": 30,
        "stopOnMatch": true,
        "boolean": "orgRecordsConflict",
        "decision": "createNewAndConflict",
        "actions": [
          "createNewCompletion",
          "createConflictRecord"
        ],
        "reasonCode": "ORG_RECORD_CONFLICT"
      },
      {
        "key": "datesDifferOutsideWindow",
        "priority": 35,
        "stopOnMatch": true,
        "boolean": "datesOutsideWindow",
        "decision": "createNewAndConflict",
        "actions": [
          "createNewCompletion",
          "createConflictRecord"
        ],
        "reasonCode": "DATES_OUTSIDE_WINDOW"
      },
      {
        "key": "peopleConflictSamePersonOrg",
        "priority": 40,
        "stopOnMatch": false,
        "boolean": "peopleConflictSamePersonOrg",
        "decision": "mergeIntoExisting",
        "actions": [
          "appendUniquePeopleToWinningEvent"
        ],
        "reasonCode": "PEOPLE_DIFFER_SAME_ORG"
      },
      {
        "key": "datesDifferWithinWindow",
        "priority": 50,
        "stopOnMatch": false,
        "boolean": "datesWithinWindow",
        "decision": "mergeIntoExisting",
        "actions": [
          "useEarlierCompletedDate"
        ],
        "reasonCode": "DATES_WITHIN_WINDOW"
      },
      {
        "key": "copyNonConflictingMissingValues",
        "priority": 60,
        "stopOnMatch": false,
        "boolean": "hasMergeableMissingValues",
        "decision": "mergeIntoExisting",
        "actions": [
          "copyMissingValuesToTriggerEvent"
        ],
        "reasonCode": "NON_CONFLICTING_VALUES_AVAILABLE"
      }
    ],

    "defaultDecision": {
      "decision": "reuseExisting",
      "actions": [],
      "reasonCode": "NO_CONFLICT"
    }
  }
}
```

---

## 8.5 Step 4 schema

```json
{
  "step4": {
    "mode": "executeDecision",
    "completionSearchSource": "outputs.completionFound",
    "conflictDecisionSource": "conflictWorkflow.ruleEvaluation.decision",

    "createTableId": "tbl1mIQg2utmj7Vqt",

    "createRecord": {
      "fields": [
        {
          "fieldId": "fldvrN5KrY6rFsgRc",
          "fieldType": "singleLineText",
          "source": "inputs.completionKey",
          "mode": "replace"
        },
        {
          "fieldId": "fldU5d3NTJYCQJAK0",
          "fieldType": "singleLineText",
          "source": "inputs.completionSearchKey",
          "mode": "replace"
        },
        {
          "fieldId": "fld5PZvVc1sOfHBv2",
          "fieldType": "singleLineText",
          "source": "inputs.eventProjectId",
          "mode": "replace"
        },
        {
          "fieldId": "fldlB5WykyfFXUoK1",
          "fieldType": "multipleRecordLinks",
          "source": "outputs.projectFound",
          "mode": "replace"
        },
        {
          "fieldId": "fldyNekr5x0sUllmO",
          "fieldType": "multipleRecordLinks",
          "source": "outputs.taskFound",
          "mode": "replace"
        },
        {
          "fieldId": "fldtX1EJ3ez1tVIBl",
          "fieldType": "date",
          "source": "inputs.eventDate",
          "mode": "replace"
        },
        {
          "fieldId": "fldT3U8DIaHuEoP2a",
          "fieldType": "multipleRecordLinks",
          "source": "inputs.currentEventRecordId",
          "mode": "replace"
        },
        {
          "fieldId": "fld8CIhhTNhUFsmhn",
          "fieldType": "singleSelect",
          "value": "Active",
          "mode": "replace"
        }
      ]
    },

    "writeCreatedRecordTo": [
      {
        "tableId": "tbloJ5eN46v1Zx7AG",
        "recordId": "_LOG_REC_ID_",
        "fields": [
          {
            "fieldId": "flds9LlWVCoMFJvak",
            "fieldType": "singleLineText",
            "mode": "replace"
          }
        ]
      }
    ],

    "decisionHandlers": {
      "createNew": {
        "createCompletion": true,
        "createConflictRecord": false
      },
      "reuseExisting": {
        "createCompletion": false,
        "createConflictRecord": false
      },
      "mergeIntoExisting": {
        "createCompletion": false,
        "executeConflictActions": true,
        "createConflictRecord": false
      },
      "createNewAndConflict": {
        "createCompletion": true,
        "executeConflictActions": false,
        "createConflictRecord": true
      },
      "manualReview": {
        "createCompletion": false,
        "createConflictRecord": false,
        "halt": true
      }
    }
  }
}
```

---

# 9. Latest canonical context schema

```json
{
  "schema": "eventResolver.context.v1",

  "meta": {
    "contextId": "context_rec..._timestamp",
    "generatedAt": "ISO timestamp",
    "updatedAt": "ISO timestamp",

    "resolverTableId": "tbloJ5eN46v1Zx7AG",
    "resolverTableName": "[🤖Event_Resolver]",

    "resolverRecordId": "rec...",
    "resolverRecordName": "Julian",

    "currentStep": "Step X",
    "nextStep": "Step 4",
    "resolverMode": "Step",

    "lastCompletedStep": "step3",

    "execution": {
      "dryRun": true,
      "step2StartedAt": "ISO timestamp",
      "step2CompletedAt": "ISO timestamp"
    },

    "configFields": {
      "step1": {
        "fieldId": "fld...",
        "fieldName": "step1_config"
      },
      "step2": {
        "fieldId": "fld...",
        "fieldName": "step2_config"
      },
      "step3": {
        "fieldId": "fld...",
        "fieldName": "step3_config"
      },
      "stepX": {
        "fieldId": "fld...",
        "fieldName": "stepX⁉️_Config"
      },
      "step4": {
        "fieldId": "fld...",
        "fieldName": "step4_config"
      }
    }
  },

  "inputs": {
    "event": {},
    "eventEnvelope": {},

    "currentEventRecordId": "rec...",
    "currentEventRecordIds": ["rec..."],

    "resolverRecordId": "rec...",
    "eventNumber": "70372",

    "eventProjectId": "rec...",
    "eventLookup": ["_APP_PAUSED_"],

    "partnerOrg": ["rec..."],
    "partnerPerson": ["rec..."],

    "eventDate": "2025-05-15T00:00:00.000Z",

    "completionKey": "",
    "completionSearchKey": ""
  },

  "outputs": {
    "projectFound": ["rec..."],
    "taskFound": ["rec..."],
    "orgFound": ["rec..."],
    "personFound": ["rec..."],
    "completionFound": [],
    "createdCompletion": ""
  },

  "debug": {
    "projectFound": ["rec..."],
    "taskFound": ["rec..."],
    "orgFound": ["rec..."],
    "personFound": ["rec..."],
    "completionFound": [],
    "createdCompletion": ""
  },

  "configs": {
    "step1": [],
    "step2": {},
    "step3": [],
    "stepX": {},
    "step4": {}
  },

  "conflictWorkflow": {
    "status": "notRun",

    "comparison": {
      "schema": "eventResolver.conflictComparison.v1",

      "existingCompletionId": "",
      "triggerEventId": "",
      "conflictingEventId": "",

      "inputs": {
        "dateWindowDays": 30,

        "trigger": {
          "eventId": "",
          "completedDate": null,
          "orgRecordIds": [],
          "personRecordIds": [],
          "personOrgIds": [],
          "orgDirIds": []
        },

        "conflicting": {
          "eventId": "",
          "completedDate": null,
          "orgRecordIds": [],
          "personRecordIds": [],
          "personOrgIds": [],
          "orgDirIds": []
        }
      },

      "comparisons": {
        "orgRecords": {},
        "people": {},
        "personOrgIds": {},
        "orgDirIds": {},
        "dates": {},
        "crossIdentity": {},
        "mergeableFields": []
      },

      "booleans": {
        "hasExistingCompletion": false,
        "hasConflictingEvent": false,
        "multipleCompletionsFound": false,
        "multipleConflictingEvents": false,
        "orgRecordsConflict": false,
        "peopleConflict": false,
        "personOrgIdsEqual": false,
        "peopleConflictSamePersonOrg": false,
        "orgDirIdsConflict": false,
        "personOrgConflictsWithOrgDir": false,
        "completedDatesDiffer": false,
        "datesWithinWindow": false,
        "datesOutsideWindow": false,
        "hasMergeableMissingValues": false
      },

      "suggestedValues": {
        "earlierCompletedDate": null,
        "combinedPeople": [],
        "mergeCandidates": []
      }
    },

    "ruleEvaluation": {
      "status": "notRun",
      "matchedRules": [],
      "decision": null
    }
  },

  "references": {
    "tables": [],
    "fields": [],
    "records": [],
    "sources": [],
    "searchOutputs": [],
    "writeNames": [],
    "jsonKeys": [],
    "sourceResolution": []
  },

  "state": {
    "step1": {
      "status": "notRun"
    },

    "step2": {
      "status": "notRun"
    },

    "step3": {
      "status": "notRun"
    },

    "stepX": {
      "status": "notRun"
    },

    "step4": {
      "status": "notRun"
    },

    "errors": [],
    "messages": []
  }
}
```

---

# 10. Immediate next implementation tasks

1. Update the Context Builder to load `stepX⁉️_Config` into:

```text
context.configs.stepX
```

2. Add Step X references to:

```text
context.references.tables
context.references.fields
context.references.sources
```

3. Resolve why these canonical inputs are blank:

```text
inputs.completionKey
inputs.completionSearchKey
```

4. Insert the real Event field IDs for:

```text
completedDate
personOrgIds
orgDirIds
```

5. Run the Step X comparison builder against a test Event where Step 3 returns one existing Completion.

6. Implement the Step X rule evaluator.

7. Update Step 3 routing terminology from:

```text
shouldRunStep5
```

to:

```text
shouldRunStepX
```

8. Expand Step 4 from `createIfNoMatch` into the universal decision executor.

9. Add the `⁉️Completion Record Conflicts` table and field mappings to Step 4 configuration.

10. Keep Dry Run enabled until Step X produces stable comparisons and decisions.
