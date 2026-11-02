This is the ⁉️Config Setup conversation: 

Expected stepX⁉️_Config shape

The field and table IDs below are placeholders until you insert your actual IDs:

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
    "multipleConflictingEventPolicy": "manualReview"
  }
}

ACTUAL stepX⁉️_Config shape