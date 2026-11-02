# Local document templates

Place one HTML template here for each `[[DocCode]]`:

```text
<DocCode>.html
```

For example, `INF.html` is selected when `[[DocCode]]` is `INF`.

Use `{{tokenName}}` placeholders. Token values are fetched from Airtable using
the matching rows in `../All_Fields.csv`, then replaced locally. Conditional
blocks such as `{{#if tokenName}}...{{else}}...{{/if}}` are also supported.

No Docupilot request is made. The default output is a locally rendered PDF;
use `--format html` when an HTML output is preferred.
