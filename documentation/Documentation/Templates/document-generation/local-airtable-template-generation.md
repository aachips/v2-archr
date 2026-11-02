# Local Airtable Template Generation

This renderer follows the existing Docupilot token methodology without sending
the document to Docupilot:

1. Create or export an HTML template containing tokens such as
   `{{applicantName}}`.
2. The renderer finds those token names in `All_Fields.csv`.
3. Each matching parameter supplies its Airtable field URL and value type.
4. The renderer fetches the source record through the Airtable API.
5. Values are normalized using the same string, number, currency, integer,
   Boolean, date, rich-text, and image rules used by the local Docupilot tool.
6. Tokens and conditional blocks are replaced locally.
7. The result is written as HTML and/or printed to PDF with local Chrome or Edge.

## Template Syntax

Plain replacement:

```html
<p>Applicant: {{applicantName}}</p>
```

Conditional content:

```html
{{#if ownsHome}}
<p>The applicant owns the home.</p>
{{else}}
<p>Home ownership was not confirmed.</p>
{{/if}}
```

Conditions support truthy tokens, `==`, `!=`, and multiple conditions joined by
`and`, matching the existing local Docupilot renderer. Values used only in a
condition are still loaded from Airtable.

## Run One Record

```powershell
$env:AIRTABLE_PAT = "pat..."

node .\document-generation\local-airtable-template-generator.js `
  --template ".\document-generation\templates\INF.html" `
  --record-id "recXXXXXXXXXXXXXX" `
  --output ".\document-generation\output" `
  --format both
```

The output directory receives:

- The rendered HTML document.
- The printable PDF document.
- A `.tokens.json` report showing which values resolved, remained blank, or
  lacked configuration.

Use `--strict` to stop generation whenever any template token is unresolved or
blank. Use `--dry-run` to fetch values and create only the token report.

On Windows, `run-local-airtable-template.bat` provides the same workflow through
interactive prompts. Command-line arguments can also be passed straight through
to the launcher.

## Run Every Record In A View

`run-batch-local-airtable-template.bat` renders the template once for every
record visible in an exact Airtable view. By default, each view record's own
`rec...` ID is supplied to the renderer. If the source ID is stored in another
field, provide that field URL as `recordIdFieldURL`.

Reusable view, field, template, output, and format settings live in
`batch_local_template_config.json`. Double-click the batch launcher and press
Enter at its first prompt to run that config, or enter values interactively.

```powershell
node .\document-generation\batch-local-airtable-template-generator.js `
  --input-view-url "https://airtable.com/appXXX/tblXXX/viwXXX" `
  --template ".\document-generation\templates\INF.html" `
  --record-id-field-url "https://airtable.com/appXXX/tblXXX/viwXXX/fldXXX" `
  --output ".\document-generation\generated-batch" `
  --format both
```

## Tokens From Multiple Bases

Docupilot normally applies one trigger record ID to every token. When synced
records have different IDs in different bases, pass a record map:

```json
{
  "appdJHg317xbe3Sd4": "recSubmissionRecord",
  "appIFBi7Rln8yFhCs": "recEligibilityReport"
}
```

Then run:

```powershell
node .\document-generation\local-airtable-template-generator.js `
  --template ".\document-generation\templates\INF.html" `
  --record-id "recDefaultRecord" `
  --record-map ".\record-map.json"
```

A map entry keyed as `app...:tbl...` takes precedence over an entry keyed only
by `app...`. A token-level `recordId` in an optional Docupilot config takes
precedence over both.

## Optional Docupilot Config

Pass `--config` to use a JSON file containing the familiar Docupilot structure:

```json
{
  "outputNameTemplate": "Eligibility Report - {{applicantName}}",
  "tokens": [
    {
      "tokenName": "{{applicantName}}",
      "valueFieldUrl": "https://airtable.com/appXXX/tblXXX/viwXXX/fldXXX",
      "valueType": "string"
    }
  ]
}
```

Config token definitions override matching rows from `All_Fields.csv`; tokens
not present in the config still fall back to the parameter export.
