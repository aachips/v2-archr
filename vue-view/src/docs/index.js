// ---------------------------------------------------------------------------
// Demo help-library content. Mirrors the app/ help system
// (app/help.php + documentation/ markdown tree), but self-contained:
// docs the demo needs are COPIED here as string modules (no loaders, no
// cross-directory paths). Add a doc by copying the markdown into `body`
// and adding an entry — category groups it in the sidebar.
// ---------------------------------------------------------------------------

export const DOC_LIBRARY = [
  {
    slug: "about-this-demo",
    title: "About This Demo",
    category: "Start Here",
    body: [
      "# About This Demo",
      "",
      "A minimal Vue + Airtable proof of concept for the ARCHR case workflow.",
      "",
      "## Views",
      "",
      "- **Global Case Search** — every case, filterable by organization, with",
      "  text search on case number, applicant name, and city.",
      "- **Case Review** — open a case to see its core fields and edit the",
      "  applicant's contact info.",
      "- **Help Library** — this page. Copies of the docs that matter for the",
      "  features being built, kept next to the demo code.",
      "- **Quick Tasks & Events** — log a communication, assessment event,",
      "  progress task, or note against a case.",
      "",
      "## Data rules",
      "",
      "Submissions are raw and never edited. Corrections live on the",
      "application (the editable working copy), which cases hang off of.",
      "See SOPs > Editing Applicant Contact Info."
    ].join("\n")
  },
  {
    slug: "editing-applicant-contact-info",
    title: "Editing Applicant Contact Info (Name, Phone, Email)",
    category: "SOPs",
    // Copy of documentation/start-here/sops/editing-applicant-contact-info.md
    body: [
      "# Editing Applicant Contact Info",
      "",
      "## When this comes up",
      "",
      "The contact details on a case sometimes belong to the wrong person —",
      "most often a referrer or neighbor who filled out the intake form on",
      "behalf of the person actually needing help. You usually find out through",
      "a communication log (e.g. a caseworker called the number and reached the",
      "referrer, not the applicant).",
      "",
      "## The rule: never edit the raw submission",
      "",
      "Submissions are the preserved, as-received form data. Corrections belong",
      "on the application — the editable working copy created from the",
      "submission for intake and eligibility work. Cases hang off the",
      "application, so a correction on the application shows on every case for",
      "that household.",
      "",
      "    submission (raw, never edited) -> application (edit here) -> case(s)",
      "",
      "## How to make the correction",
      "",
      "1. Open the case from Global Case Search and go to Case Review.",
      "2. Under Applicant, click **Edit contact info**.",
      "3. Update first name, last name, email, and/or phone, then Save.",
      "",
      "Behind the scenes:",
      "",
      "- If an application already exists for the submission, only its",
      "  applicant name/email/phone fields are updated.",
      "- If none exists yet, one is created as a copy of the submission first,",
      "  then your edit is applied.",
      "- The raw submission is left untouched either way.",
      "- Case Review shows an **edited** flag once an application backs the",
      "  contact fields.",
      "",
      "## Follow-ups",
      "",
      "- If the phone number belonged to a referrer, log a communication event",
      "  (Quick Tasks & Events) noting whose number it was and how the correct",
      "  one was obtained.",
      "- If the address is wrong (not just contact info), escalate to an org",
      "  admin — placecodes and deduplication key off the address."
    ].join("\n")
  }
];
