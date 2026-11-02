┌─────────────────────────────────────────────────────────────────────────────────┐
│                    DOCUMENT GENERATION DATA FLOW                               │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  1. TEMPLATE DEFINITION                                                        │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  A template contains placeholders like {{docHomeFullName}}             │   │
│  │  These placeholders are mapped to Airtable fields                      │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                   │                                             │
│                                   ▼                                             │
│  2. FIELD LOOKUP                                                                │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  Each placeholder has metadata:                                        │   │
│  │  • Name (e.g., {{docHomeFullName}})                                    │   │
│  │  • Data type (string, num, date, obj, array, boo, imageUrl)          │   │
│  │  • Source table (Home, Org, Author, Grant, Date, Draw, Scope)         │   │
│  │  • Airtable field URL (where the data lives)                          │   │
│  │  • Used in which templates                                            │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                   │                                             │
│                                   ▼                                             │
│  3. DATA SOURCE MAPPING                                                         │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  Values can be:                                                         │   │
│  │  • Direct field values ({{docHomeFirstName}})                         │   │
│  │  • Lookups from other records ({lookup_docOrg})                       │   │
│  │  • Arrays ({{repairTask}}, {{cdbgPhotos}})                             │   │
│  │  • Objects ({{docAuthorSignature}})                                    │   │
│  │  • Calculated values ({{drawProjTotal}})                              │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘