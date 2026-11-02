# Resolver engine-config shape

The runtime contract is `eventResolver.engineConfig.v1`. It is a step envelope
containing one or more generic engines. Each engine contains table setups, and
each setup contains one normalized `table` object.

This deliberately separates three identities:

- `engineId`: the Datamap `genericEngine` record.
- `setupId`: the Datamap `tableConfigSetups` record.
- `table.tableId`: the physical Airtable table.

The keyMap continues to store full canonical construction paths such as
`create.tables.toTable.newRecords.record.toFields.field.writeSource`.
`fieldNameLookupCreator` may collapse those paths to reusable renderer names
such as `tables.table`, `table.writeFields`, and `field.writeSource`. The
runtime schema describes the resulting normalized object, not the formula
implementation used to construct it.

## Create example

```json
{
  "schema": "eventResolver.engineConfig.v1",
  "step": "step4",
  "engines": [
    {
      "engine": "Create",
      "engineId": "rec9OF5vZFTSiCg78",
      "tables": [
        {
          "setupId": "recMmCxZ1pQPmnMvM",
          "label": "Step 4 Create [Completion Record Conflict]",
          "role": "conflictRecord",
          "table": {
            "tableId": "tblfYyLY9k5kAomDJ",
            "writeFields": [
              {
                "field": {
                  "fieldId": "fldBcWQlGTSYTh0CS",
                  "fieldType": "multipleRecordLinks",
                  "writeMode": "replace",
                  "writeSource": {
                    "path": "conflictWorkflow.comparison.existingCompletionId",
                    "transform": "toRecordIdArray",
                    "required": true,
                    "defaultJSON": [],
                    "onMissing": "manualReview"
                  }
                }
              }
            ]
          }
        }
      ]
    }
  ]
}
```

## Search example

```json
{
  "engine": "Search",
  "tables": [
    {
      "setupId": "recBBNOWYRT0W1IIL",
      "role": "completionSearch",
      "table": {
        "tableId": "tbl1mIQg2utmj7Vqt",
        "searchFields": {
          "primaryField": {
            "field": {
              "fieldId": "fldU5d3NTJYCQJAK0",
              "fieldType": "singleLineText"
            }
          },
          "deepFields": [],
          "primaryInputKeys": ["completionSearchKey"],
          "deepInputKeys": [],
          "outputPath": "outputs.completionFound"
        }
      }
    }
  ]
}
```

## Runtime rules

- `writeSource.path` is always a canonical context path.
- `defaultJSON` is stored as parsed JSON, not a JSON-encoded string.
- Exactly one of `writeSource` and `writeValue` is allowed on a write field.
- `recordSource` identifies an existing destination record for Update; Create
  omits it.
- Runtime code may accept the old step-specific configs during migration, but
  new generated configs should use this envelope.
- Formula fragments are build artifacts. Runtime scripts consume parsed
  objects and never execute `_SOURCE_`, `_VALUE_`, or Airtable formula tokens.
