// ============================================================
// SCOPE OF WORK — ARCHR Home Repair Contract
// ============================================================
// Loads data from JSON if provided.
//
// Usage:
//   typst compile scope-of-work.typ                           ← template with placeholders
//   typst compile scope-of-work.typ --input "data=data/sample-application.json"  ← populated

#let data-path = sys.inputs.at("data", default: "")
#let data = if data-path != "" { json(data-path) } else: none

// ── Placeholder helper ──
#let placeholder(label, path: none) = {
  if data != none and path != none {
    text(fill: rgb("#2A5C82"), weight: "bold")[#d(path)]
  } else {
    text(fill: rgb("#2A5C82"), weight: "bold")[(#label)]
  }
}

// ── Data helper ──
#let d(path, default: "") = {
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

// ── Currency formatter ──
#let money(val) = {
  if data == none { val }
  else {
    let n = calc.floor(val)
    "$#n.insert(0, sep: ",")"
  }
}

#set page(
  paper: "us-letter",
  margin: (top: 1in, bottom: 1in, left: 0.9in, right: 0.9in),
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
        #text(weight: "bold")[Scope of Work]
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
      [Contract ID: #d("case_number", default: "________________________")],
      [Generated: #d("generated_date", default: datetime.today().display("[month] [day], [year]"))],
    )
  ],
)

#set text(font: ("Arial", "Calibri", "Times New Roman"), size: 10.5pt, lang: "en")
#set par(justify: true, leading: 0.65em)



// ── Optional: load JSON data if present ──
// #let data = json("case-data.json")
// Then replace #placeholder("X") with #data.x

// ============================================================
// TITLE
// ============================================================

#align(center)[
  #text(size: 22pt, weight: "bold", fill: rgb("#E04E39"))[Scope of Work]
  #v(4pt)
  #text(size: 13pt, fill: luma(80))[Home Repair Contract]
  #v(2pt)
  #text(size: 10pt, fill: luma(120))[Asheville Regional Coalition for Home Repair]
]

#v(20pt)

// ============================================================
// PARTIES
// ============================================================

#block(
  fill: luma(248),
  inset: 14pt,
  radius: 4pt,
  stroke: (left: 3pt + rgb("#2A5C82")),
)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 20pt,
    [
      *Homeowner*
      #v(4pt)
      #placeholder("APPLICANT FULL NAME")
      \
      #placeholder("STREET ADDRESS")
      \
      #placeholder("CITY, STATE ZIP")
      \
      #placeholder("PHONE")
    ],
    [
      *Organization*
      #v(4pt)
      #placeholder("ORGANIZATION NAME")
      \
      #placeholder("ORG STREET ADDRESS")
      \
      #placeholder("ORG CITY, STATE ZIP")
      \
      #placeholder("ORG CONTACT")
    ],
  )
]

#v(18pt)

// ============================================================
// 1. PROJECT SUMMARY
// ============================================================

#text(size: 13pt, weight: "bold", fill: rgb("#2A5C82"))[1. Project Summary]

#v(6pt)

#placeholder("Brief description of the project and the disaster-related damage it addresses.")

#v(14pt)

// ============================================================
// 2. PROPERTY INFORMATION
// ============================================================

#text(size: 13pt, weight: "bold", fill: rgb("#2A5C82"))[2. Property Information]

#v(6pt)

#table(
  columns: (auto, 1fr),
  stroke: none,
  inset: (x: 0pt, y: 5pt),
  align: (left, left),
  [*Property Address:*], [#placeholder("STREET, CITY, STATE ZIP")],
  [*Unit:*], [#placeholder("UNIT NUMBER")],
  [*Year Built:*], [#placeholder("YEAR BUILT")],
  [*Home Type:*], [#placeholder("TYPE OF HOME")],
  [*Parcel / GIS ID:*], [#placeholder("PARCEL ID")],
  [*Legacy Neighborhood:*], [#placeholder("YES / NO — NAME")],
)

#v(14pt)

// ============================================================
// 3. SCOPE OF WORK
// ============================================================

#text(size: 13pt, weight: "bold", fill: rgb("#2A5C82"))[3. Scope of Work]

#v(6pt)

The following repairs are approved for this project. Each line item represents a discrete repair task, its location within the home, and the approved cost.

#v(8pt)

// ── Replace this table body with your real repair tasks ──
// If loading from JSON: #for task in data.repair_tasks [ ... ]

#table(
  columns: (auto, 1fr, auto, auto),
  stroke: 0.5pt + luma(200),
  inset: 7pt,
  align: (center, left, left, right),
  fill: (x, y) => if y == 0 { luma(240) },
  table.header(
    [*Num*], [*Repair Task*], [*Location*], [*Cost*],
  ),
  [1], [Roof replacement — tear off and install new shingles], [Roof], [\$ 8,500.00],
  [2], [Replace damaged drywall and repaint], [Living Room], [\$ 2,300.00],
  [3], [Install new HVAC condenser and reconnect], [Exterior], [\$ 4,200.00],
  [4], [Well shock-chlorination and water testing], [Property], [\$ 850.00],
  table.hline(stroke: 1pt + luma(150)),
  [], [], [*Total Approved*], [*\$ 15,850.00*],
)

#v(14pt)

// ============================================================
// 4. TIMELINE
// ============================================================

#text(size: 13pt, weight: "bold", fill: rgb("#2A5C82"))[4. Timeline]

#v(6pt)

#table(
  columns: (auto, 1fr),
  stroke: none,
  inset: (x: 0pt, y: 5pt),
  [*Estimated Start:*], [#placeholder("START DATE")],
  [*Estimated Completion:*], [#placeholder("COMPLETION DATE")],
  [*Estimated Duration:*], [#placeholder("DURATION IN DAYS")],
)

#v(14pt)

// ============================================================
// 5. FUNDING
// ============================================================

#text(size: 13pt, weight: "bold", fill: rgb("#2A5C82"))[5. Funding]

#v(6pt)

#placeholder("This project is funded through the following sources. Total approved funding shall not exceed \$50,000 per household for disaster-related repairs.")

#v(6pt)

#table(
  columns: (1fr, auto),
  stroke: 0.5pt + luma(200),
  inset: 7pt,
  align: (left, right),
  fill: (x, y) => if y == 0 { luma(240) },
  table.header([*Funding Source*], [*Amount*]),
  [#placeholder("NCORR Helene Recovery Grant")], [\$ 8,000.00],
  [#placeholder("Coalition Match")], [\$ 4,000.00],
  [In-kind Volunteer Labor], [\$ 3,850.00],
  table.hline(stroke: 1pt + luma(150)),
  [*Total*], [*\$ 15,850.00*],
)

#v(14pt)

// ============================================================
// 6. TERMS & CONDITIONS
// ============================================================

#text(size: 13pt, weight: "bold", fill: rgb("#2A5C82"))[6. Terms & Conditions]

#v(6pt)

#set enum(numbering: "6.1")
+ The Homeowner agrees to provide reasonable access to the property during scheduled work hours.
+ Any change in scope must be documented and approved through a formal change order.
+ The Organization is not responsible for pre-existing conditions not identified in the assessment.
+ Work performed is limited to the scope described in Section 3.
+ This contract is binding upon signature by both parties.

#v(20pt)

// ============================================================
// SIGNATURES
// ============================================================

#text(size: 13pt, weight: "bold", fill: rgb("#2A5C82"))[Signatures]

#v(14pt)

#grid(
  columns: (1fr, 1fr),
  gutter: 30pt,
  [
    #line(length: 100%, stroke: 0.5pt)
    #v(4pt)
    #text(size: 9pt)[*Homeowner Signature*]
    #v(2pt)
    #text(size: 9pt, fill: luma(120))[Date: ____________________]
  ],
  [
    #line(length: 100%, stroke: 0.5pt)
    #v(4pt)
    #text(size: 9pt)[*Authorized Representative*]
    #v(2pt)
    #text(size: 9pt, fill: luma(120))[Date: ____________________]
  ],
)

#v(24pt)

#align(center)[
  #text(size: 8pt, fill: luma(150))[
    This document was generated by the ARCHR platform. \
    All names, addresses, and amounts in this template are placeholders for testing purposes.
  ]
]