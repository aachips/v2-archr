// ---------------------------------------------------------------------------
// Documents a case is expected to collect over its pipeline. DocsList renders
// one row per entry: a Download button when the document is on file, an
// Upload button when it is not.
// Demo list — the canonical document categories/templates live in
// app/lib/case-documents.php; port from there when the dummy base gains a
// documents table (see src/components/case-review/README.md).
// ---------------------------------------------------------------------------

export const REQUIRED_DOCUMENTS = [
  { key: "proof_of_ownership", label: "Proof of ownership (deed or tax record)" },
  { key: "income_verification", label: "Income verification" },
  { key: "government_id", label: "Government-issued ID" },
  { key: "insurance_declaration", label: "Insurance declaration page" },
  { key: "assessment_report", label: "Home assessment report" },
  { key: "signed_contract", label: "Signed repair contract" },
  { key: "completion_certificate", label: "Completion certificate" }
];