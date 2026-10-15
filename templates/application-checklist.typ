// ============================================================
// APPLICATION DATA CHECKLIST — ARCHR User Testing
// ============================================================
// Use this to verify application data against Airtable/Softr.
// Loads data from JSON if available, otherwise shows blank fields.
//
// Usage:
//   typst compile application-checklist.typ            ← blank checklist
//   typst compile application-checklist.typ --input "data=sample-application.json"  ← populated

#let data-path = sys.inputs.at("data", default: "")
#let data = if data-path != "" { json(data-path) } else { none }

#set page(
  paper: "us-letter",
  margin: (top: 0.85in, bottom: 0.75in, left: 0.85in, right: 0.85in),
  numbering: "1",
  header: [
    #set text(size: 8pt, fill: luma(120))
    #grid(
      columns: (auto, 1fr, 1fr),
      align: (left, center, right),
      [
        #box(
          baseline: 0pt,
          stack(
            direction: ltr,
            spacing: 5pt,
            align(bottom + horizon, image("img/archr-logo.svg", width: 20pt)),
            text(size: 13pt, weight: "black", fill: rgb("#1d4665"))[ARCHR],
          ),
        )
      ],
      [],
      [
        #text(weight: "bold")[Application Data Checklist]
        #h(4pt)
        · Page #counter(page)
      ],
    )
    #v(2pt)
    #line(length: 100%, stroke: 0.5pt + luma(200))
  ],
  footer: [
    #set text(size: 8pt, fill: luma(120))
    #line(length: 100%, stroke: 0.5pt + luma(200))
    #v(2pt)
    #grid(
      columns: (1fr, 1fr),
      align: (left, right),
      [Case Number: #if data != none { data.case_number } else { "________________________" }],
      [Generated: #if data != none { data.generated_date } else { datetime.today().display("[month] [day], [year]") }],
    )
  ],
)

#set text(font: ("Arial", "Calibri"), size: 10pt, lang: "en")
#set par(justify: false, leading: 0.6em)

// ── Checkbox helper ──
#let cb() = rect(width: 10pt, height: 10pt, stroke: 1pt, fill: white)

// ── Section helper ──
#let section(num, title) = {
  v(10pt)
  text(size: 12pt, weight: "bold", fill: rgb("#2A5C82"))[#num. #title]
  v(4pt)
  line(length: 100%, stroke: 1pt + rgb("#2A5C82"))
  v(6pt)
}

// ── Data helper: reads from JSON if available, else returns default ──
#let d(path, default: "________________________") = {
  if data == none { default }
  else {
    let parts = path.split(".")
    let val = data
    for part in parts {
      val = val.at(part, default: default)
    }
    if val == none { default } else { val }
  }
}

// ── Yes/No checkbox from boolean ──
#let yn(path) = {
  let v = d(path, default: false)
  if v == true { [#cb() Yes  #cb() No] }
  else { [#cb() Yes  #cb() No] }
}

// ============================================================
// CASE INFO
// ============================================================

#align(center)[
  #text(size: 20pt, weight: "bold", fill: rgb("#2A5C82"))[Application Data Checklist]
  #v(4pt)
  #text(size: 11pt, fill: luma(80))[Canonical Field Reference for User Testing]
]

#v(14pt)

#block(
  fill: luma(248),
  inset: 12pt,
  radius: 4pt,
  stroke: (left: 3pt + rgb("#2A5C82")),
)[
  *Application ID / Record* \
  #d("case_number") \
  \
  *Date of This Review:* \
  #d("generated_date") \
  \
  *Reviewer Name:* \
  #h(200pt) \
  \
  *Data Source(s) Checked:*  #cb() Airtable   #cb() Softr   #cb() PostgreSQL   #cb() Paper File
]

// ============================================================
// 1. APPLICANT INFORMATION
// ============================================================

#section("1", "Applicant Information")

#table(
  columns: (3.5cm, 1fr, 1.2cm),
  stroke: (bottom: 0.3pt + luma(200)),
  inset: (x: 4pt, y: 4pt),
  align: (left, left, center),
  fill: (x, y) => if y == 0 { luma(244) },
  table.header([*Field*], [*Value*], [*OK?*]),

  [*First Name*], [#d("applicant.first_name")], [#cb()],
  [*Last Name*], [#d("applicant.last_name")], [#cb()],
  [*Date of Birth*], [#d("applicant.dob")], [#cb()],
  [*Email*], [#d("applicant.email")], [#cb()],
  [*Home Phone*], [#d("applicant.home_phone")], [#cb()],
  [*Cell Phone*], [#d("applicant.cell_phone")], [#cb()],
  [*Preferred Contact Method*], [#d("applicant.preferred_contact")], [#cb()],
  [*Contact Notes*], [#d("applicant.contact_notes")], [#cb()],
  [*Primary Spoken Language*], [#d("applicant.spoken_language")], [#cb()],
)

// ============================================================
// 2. PROPERTY INFORMATION
// ============================================================

#section("2", "Property Information")

#table(
  columns: (3.5cm, 1fr, 1.2cm),
  stroke: (bottom: 0.3pt + luma(200)),
  inset: (x: 4pt, y: 4pt),
  align: (left, left, center),
  fill: (x, y) => if y == 0 { luma(244) },
  table.header([*Field*], [*Value*], [*OK?*]),

  [*Street Address*], [#d("property.street")], [#cb()],
  [*Unit*], [#d("property.unit")], [#cb()],
  [*City / Town*], [#d("property.city")], [#cb()],
  [*State / Province*], [#d("property.state")], [#cb()],
  [*ZIP / Postal Code*], [#d("property.zip")], [#cb()],
  [*Placecode*], [#d("property.placecode")], [#cb()],
  [*Primary Residence?*], [#cb() Yes  #cb() No], [#cb()],
  [*Lived in Home 1+ Year?*], [#cb() Yes  #cb() No], [#cb()],
  [*Move-In Date*], [#d("property.move_in_date")], [#cb()],
  [*Home Type*], [#d("property.home_type")], [#cb()],
  [*Other Home Type*], [#d("property.other_home_type")], [#cb()],
  [*Year Built*], [#d("property.year_built")], [#cb()],
  [*Applicant Owns Home?*], [#cb() Yes  #cb() No], [#cb()],
  [*Applicant Owns Lot?*], [#cb() Yes  #cb() No], [#cb()],
  [*Homeowner Insurance Provider*], [#d("property.insurance_provider")], [#cb()],
  [*GIS / Parcel ID*], [#d("property.gis_parcel_id")], [#cb()],
  [*Legacy Neighborhood?*], [#cb() Yes  #cb() No  Name: #d("property.legacy_neighborhood_name")], [#cb()],
)

// ============================================================
// 3. HOUSEHOLD
// ============================================================

#section("3", "Household Composition")

#table(
  columns: (3.5cm, 1fr, 1.2cm),
  stroke: (bottom: 0.3pt + luma(200)),
  inset: (x: 4pt, y: 4pt),
  align: (left, left, center),
  fill: (x, y) => if y == 0 { luma(244) },
  table.header([*Field*], [*Value*], [*OK?*]),

  [*Household Size*], [#d("household.size")], [#cb()],
  [*Number of Adults*], [#d("household.adults")], [#cb()],
  [*Household Members*], [#h(100pt)], [#cb()],
)

#v(6pt)
*List all household members:*
#table(
  columns: (3cm, 2cm, 1fr),
  stroke: 0.3pt + luma(200),
  inset: (x: 4pt, y: 3pt),
  align: (left, left, left),
  fill: (x, y) => if y == 0 { luma(244) },
  table.header([*Name*], [*Age*], [*Relationship*]),
  [#h(80pt)], [#h(40pt)], [#h(80pt)],
  [#h(80pt)], [#h(40pt)], [#h(80pt)],
  [#h(80pt)], [#h(40pt)], [#h(80pt)],
  [#h(80pt)], [#h(40pt)], [#h(80pt)],
)

// ============================================================
// 4. INCOME & ELIGIBILITY
// ============================================================

#section("4", "Income & Eligibility")

#table(
  columns: (3.5cm, 1fr, 1.2cm),
  stroke: (bottom: 0.3pt + luma(200)),
  inset: (x: 4pt, y: 4pt),
  align: (left, left, center),
  fill: (x, y) => if y == 0 { luma(244) },
  table.header([*Field*], [*Value*], [*OK?*]),

  [*Gross Annual Income*], [#d("income.gross_annual")], [#cb()],
  [*Gross Monthly Income*], [#d("income.gross_monthly")], [#cb()],
  [*Income Sources*], [#d("income.sources")], [#cb()],
  [*Proof of Income Provided?*], [#cb() Yes  #cb() No], [#cb()],
  [*POI Types*], [#d("income.proof_types")], [#cb()],
  [*Zero Income Agreed?*], [#cb() Yes  #cb() No], [#cb()],
  [*AMI %*], [#d("income.ami_percent")], [#cb()],
  [*AMI Year*], [#d("income.ami_year")], [#cb()],
  [*AMI Group*], [#d("income.ami_group")], [#cb()],
  [*Eligibility Preset*], [#d("income.eligibility_preset")], [#cb()],
)

// ============================================================
// 5. REPAIR NEEDS & URGENCY
// ============================================================

#section("5", "Repair Needs & Urgency")

#table(
  columns: (3.5cm, 1fr, 1.2cm),
  stroke: (bottom: 0.3pt + luma(200)),
  inset: (x: 4pt, y: 4pt),
  align: (left, left, center),
  fill: (x, y) => if y == 0 { luma(244) },
  table.header([*Field*], [*Value*], [*OK?*]),

  [*Repair Requests (from form)*], [#d("repairs.requests")], [#cb()],
  [*Additional Repair Details*], [#d("repairs.additional_details")], [#cb()],
  [*Triage Score*], [#d("repairs.triage_score")], [#cb()],
)

#v(8pt)
*Emergency / Urgent Conditions:*

#table(
  columns: (1fr, 1fr),
  stroke: none,
  inset: (x: 0pt, y: 2pt),
  align: (left, left),
  [#cb() Unable to Stay],  [#cb() No HVAC],
  [#cb() No Potable Water], [#cb() No Bathroom),
  [#cb() No Kitchen],       [#cb() Open to Elements],
  [#cb() No Entry/Exit],    [#cb() Accessibility Issue],
  [#cb() Other Issue],      [#cb() Eviction Risk],
)

#v(6pt)
*Describe urgent condition:*
#h(100pt)

// ============================================================
// 6. DISASTER & INSURANCE
// ============================================================

#section("6", "Disaster & Insurance History")

#table(
  columns: (3.5cm, 1fr, 1.2cm),
  stroke: (bottom: 0.3pt + luma(200)),
  inset: (x: 4pt, y: 4pt),
  align: (left, left, center),
  fill: (x, y) => if y == 0 { luma(244) },
  table.header([*Field*], [*Value*], [*OK?*]),

  [*Helene-Related?*], [#cb() Yes  #cb() No], [#cb()],
  [*Date of Loss*], [#d("disaster.date_of_loss")], [#cb()],
  [*Insurance Claim Filed?*], [#cb() Yes  #cb() No], [#cb()],
  [*Insurance Provider*], [#d("disaster.insurance_provider")], [#cb()],
  [*Insurance Settlement Amount*], [#d("disaster.insurance_settlement")], [#cb()],
  [*FEMA Claim Filed?*], [#cb() Yes  #cb() No], [#cb()],
  [*FEMA Settlement Amount*], [#d("disaster.fema_settlement")], [#cb()],
)

// ============================================================
// 7. REFERRAL & CONSENT
// ============================================================

#section("7", "Referral & Consent")

#table(
  columns: (3.5cm, 1fr, 1.2cm),
  stroke: (bottom: 0.3pt + luma(200)),
  inset: (x: 4pt, y: 4pt),
  align: (left, left, center),
  fill: (x, y) => if y == 0 { luma(244) },
  table.header([*Field*], [*Value*], [*OK?*]),

  [*Is Referral?*], [#cb() Yes  #cb() No], [#cb()],
  [*Referrer Name*], [#d("referral.referrer_name")], [#cb()],
  [*Referrer Organization*], [#d("referral.referrer_organization")], [#cb()],
  [*Referrer Email*], [#d("referral.referrer_email")], [#cb()],
  [*Referrer Notes*], [#d("referral.referrer_notes")], [#cb()],
  [*Consent Agreed?*], [#cb() Yes  #cb() No], [#cb()],
)

// ============================================================
// 8. WORKFLOW STATUS
// ============================================================

#section("8", "Workflow Status")

#table(
  columns: (3.5cm, 1fr, 1.2cm),
  stroke: (bottom: 0.3pt + luma(200)),
  inset: (x: 4pt, y: 4pt),
  align: (left, left, center),
  fill: (x, y) => if y == 0 { luma(244) },
  table.header([*Field*], [*Value*], [*OK?*]),

  [*Workflow Status*], [#d("workflow.status")], [#cb()],
  [*Case Status*], [#d("workflow.case_status")], [#cb()],
  [*Organization*], [#d("workflow.organization")], [#cb()],
  [*Submission Date*], [#d("workflow.submission_date")], [#cb()],
  [*Date Claimed*], [#d("workflow.date_claimed")], [#cb()],
  [*Claimed By*], [#d("workflow.claimed_by")], [#cb()],
  [*Date SOW Created*], [#d("workflow.date_sow_created")], [#cb()],
)

// ============================================================
// 9. DATA QUALITY NOTES
// ============================================================

#section("9", "Data Quality Notes")

#v(4pt)
*Discrepancies between Airtable, Softr, and/or paper records:*

#v(6pt)
#rect(inset: 8pt, height: 80pt, stroke: 0.5pt + luma(200), radius: 3pt)[
  #v(-2pt)
]

#v(10pt)
*Missing fields or incomplete information:*

#v(6pt)
#rect(inset: 8pt, height: 50pt, stroke: 0.5pt + luma(200), radius: 3pt)[
  #v(-2pt)
]

#v(10pt)
*Notes / Follow-up Actions:*

#v(6pt)
#rect(inset: 8pt, height: 50pt, stroke: 0.5pt + luma(200), radius: 3pt)[
  #v(-2pt)
]

// ── End of checklist ──
#v(16pt)
#align(center)[
  #text(size: 8pt, fill: luma(150))[
    ARCHR Application Data Checklist · Canonical Field Reference · #datetime.today().display("[month] [day], [year]")
  ]
]
