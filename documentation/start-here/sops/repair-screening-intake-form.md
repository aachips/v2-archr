---
document_name: Home Repair Services Screening Form — Field Reference & SOP
document_type: Standard Operating Procedure
version: 1.0
last_updated: 2026-08-01
author: ARCHR Development Team
audience: Envoys, Caseworkers, Admins, Assessors
complexity_level: Intermediate
estimated_reading_minutes: 15
tags: [intake, screening, form, fields, SOP]
---

# ARCHR Home Repair Services Screening Form — SOP & Field Reference

> **Status:** Draft for proofreading. Eligibility impact notes below are placeholders authored to scaffold the Standard Operating Procedure (SOP). Each entry should be reviewed and corrected by an ARCHR program lead before this document is treated as authoritative.

This document describes the multi-page intake form implemented in `archr-intake.html` and `archr-intake.js`. Its purpose is to:

1. Give intake staff and partner organizations a single reference for what is being collected, why, and how each answer affects eligibility routing.
2. Provide developers a stable map of field `name` and `id` attributes so downstream integrations (CRM, eligibility engine, reporting) bind to the correct values.
3. Serve as the seed document for a formal Standard Operating Procedure once content has been reviewed.

---

## 1. Purpose of the form

The ARCHR (Asheville Regional Coalition for Home Repair) screening form is the **first-touch intake** used to determine which partner organization is best positioned to serve a homeowner requesting repairs. It is **not** an application — it is a routing and pre-qualification tool. Submissions are shared with the partner network:

- Asheville Habitat for Humanity
- Community Action Opportunities
- PODER Emma
- Asheville Buncombe Community Land Trust
- Mountain Housing Opportunities
- Community Housing Coalition of Madison County

A completed screening yields a record that can be triaged for:

- **Eligibility** (ownership, residency duration, income tier, household composition).
- **Urgency** (life-safety conditions that justify expedited dispatch).
- **Funding stream** (Helene-related work routed through disaster funds; non-disaster routed through standard repair, accessibility, or weatherization funds).
- **Documentation status** (income proof method, signature capture, zero-income affidavit).

---

## 2. Document conventions

| Convention | Meaning |
| --- | --- |
| `name="fieldName"` | Submitted form key. Arrays use `name="thing[]"` (multi-select checkboxes). |
| `id="fieldName"` | DOM identifier; matches the corresponding `<label for>`. |
| `data-show-if="name=value"` | Entire page is **skipped** when the condition is not met. |
| `data-show-when-value="name=value"` | Sub-block within a page is hidden until the condition is met. |
| `data-show-when-checked="value"` | Sub-block is hidden until a checkbox with that value is checked. |
| **Eligibility impact** | Plain-language note on how the answer feeds routing or qualification. Authored as a placeholder — verify before publication. |

All `name`/`id` pairs are unique across the form. Repeated fields use the `[]` suffix (e.g. `preferredContact[]`, `repairNeed[]`).

---

## 3. Form flow at a glance

```
1. Welcome / Referral question
2. About this form + Data confidentiality consent
3. Referrer details ............... [shown only if isReferral=yes]
4. Primary contact information
5. Home address & household
6. Repair request list + urgent conditions (staff-facing wording)
7. Home repair requests (applicant-facing wording)
8. Request details (per-issue follow-up questions)
9. Hurricane Helene relation question
10. FEMA claim ................... [shown only if heleneRelated=yes]
11. Homeowner's insurance claim
12. Income information + applicant signature
13. Zero income affidavit ........ [shown only if haveIncome=no]
14. Submission confirmation
```

The progress bar reflects only the **visible** pages, so referrals, Helene branches, and zero-income paths produce different bar increments.

---

## 4. Page-by-page reference

### Page 1 — Welcome & referral routing

`id="page-welcome"` · `data-page="welcome"`

| Question (label) | `name` / `id` | Type | Eligibility impact |
| --- | --- | --- | --- |
| Are you submitting this on behalf of someone else as a referral? | `isReferral` | radio (`yes` / `no`) | Drives whether Page 3 (referrer details) is shown. A `yes` answer flags the record as third-party-submitted, which staff use to know who to contact first about clarifying questions. |

---

### Page 2 — About this form & data confidentiality

`id="page-intro"` · `data-page="intro"`

| Question (label) | `name` / `id` | Type | Eligibility impact |
| --- | --- | --- | --- |
| I agree to the data sharing terms above. | `consentAgree` | checkbox (`yes`) | Required gate for record sharing across ARCHR partners. Records without consent should not be distributed beyond the receiving organization. |

---

### Page 3 — Referrer details *(conditional: `isReferral=yes`)*

`id="page-referrer"` · `data-page="referrer"` · `data-show-if="isReferral=yes"`

| Question | `name` / `id` | Type | Eligibility impact |
| --- | --- | --- | --- |
| Your name | `referrerName` | text | Identifies the submitter for follow-up; not part of applicant eligibility. |
| Your organization | `referrerOrganization` | text | Used to track which partner agencies refer the most cases (program reporting). |
| Your email | `referrerEmail` | email | Channel for clarification questions during triage. |
| Referral notes | `referrerNotes` | textarea | Free-text context the intake reviewer uses to prioritize outreach (e.g., "client is hearing-impaired, please call daughter first"). |

---

### Page 4 — Primary contact information

`id="page-contact"` · `data-page="contact"`

| Question | `name` / `id` | Type | Eligibility impact |
| --- | --- | --- | --- |
| Primary applicant first name | `applicantFirstName` | text | Identity record key. Used to deduplicate against prior applications across partner CRMs. |
| Primary applicant last name | `applicantLastName` | text | Identity record key. |
| Primary applicant date of birth | `applicantDob` | date | Used to verify age-related criteria (e.g., 62+ programs, child-in-household calculations). |
| Check if primary applicant DOB unknown | `applicantDobUnknown` | checkbox (`yes`) | Allows referral records to proceed without DOB; flagged for follow-up at home visit. |
| Preferred contact method | `preferredContact[]` | checkboxes (`phone`, `text`, `email`, `other`) | Determines outbound channel for scheduling the home visit. Records missing a working channel are routed to a manual queue. |
| Home phone | `homePhone` | tel | Primary call-back number. |
| Cell phone | `cellPhone` | tel | Alternate call-back, also used for `text` channel. |
| Email address | `contactEmail` | email | Used for `email_link` income document upload and digital correspondence. |
| Other contact method | `otherContactMethod` | text | Free-text fallback (e.g., "call neighbor at 555-…"). Triggers manual review. |
| Contact notes | `contactNotes` | textarea | Time-of-day preferences, language preferences, or accessibility notes for outreach staff. |

---


### Page 5 — Home address & household composition

`id="page-address"` · `data-page="address"`

**Home address block**

| Question | `name` / `id` | Type | Eligibility impact |
| --- | --- | --- | --- |
| Home address | `homeAddress` | text | Used to confirm the property is inside an ARCHR partner service area. Out-of-area submissions are forwarded to the closest regional partner. |
| City | `homeCity` | text | Service-area lookup. |
| State / Province | `homeState` | text | Service-area lookup; non-NC addresses are returned with a referral list. |
| Zip / Postal code | `homeZip` | text | Service-area lookup and funding-stream eligibility (some grants are zip-restricted). |
| Is this your primary residence? | `isPrimaryResidence` | radio (`yes` / `no`) | Most ARCHR programs require the work be performed on the applicant's primary residence. A `no` answer routes the case to manual review for possible secondary-property programs. |
| Do you receive mail at a different address? | `receivesDifferentMail` | radio (`yes` / `no`) | Reveals the mailing address sub-block. Ensures award letters and document requests reach the applicant. |

**Mailing address sub-block** *(shown when `receivesDifferentMail=yes`)*

| Question | `name` / `id` | Type | Eligibility impact |
| --- | --- | --- | --- |
| Address | `mailAddress` | text | Mailing destination for award letters and document requests. |
| City | `mailCity` | text | Mailing destination. |
| State / Province | `mailState` | text | Mailing destination. |
| Zip / Postal | `mailZip` | text | Mailing destination. |

**About your home**

| Question | `name` / `id` | Type | Eligibility impact |
| --- | --- | --- | --- |
| Type of home | `homeType` | select (`traditional`, `modular`, `mobile`, `other`) | Determines which scope of work is feasible. `mobile` triggers the "Do you own the lot?" sub-question because many programs require lot ownership for mobile-home repairs. |
| Year built | `yearBuilt` | number | Pre-1978 homes trigger lead-paint disclosure requirements. Very old construction may affect grant eligibility (some weatherization grants exclude pre-1900 structures). |
| When did you move into this address? | `moveInDate` | date | Cross-checks the "lived at least 1 year" question and is used for tenancy verification. |
| Do you own your home? | `ownsHome` | radio (`yes` / `no`) | **Hard gate.** ARCHR partners primarily serve homeowners. `no` answers should be routed to renter-focused services. |
| Do you own the lot your mobile home is on? *(if `homeType=mobile`)* | `ownsLot` | radio (`yes` / `no`) | Mobile homes on rented lots are generally ineligible for major structural work; routed to mobile-home-park-specific programs if available. |
| Home owner's insurance provider (optional) | `insuranceProvider` | text | Informational; cross-referenced with insurance claim answers on Page 11. |
| Have you lived in your home for at least 1 year? | `livedOneYear` | radio (`yes` / `no`) | Some grants require minimum tenancy duration. `no` answers do not disqualify outright but limit available funding streams. |

**Household composition**

| Question | `name` / `id` | Type | Eligibility impact |
| --- | --- | --- | --- |
| How many people live in your home full time? | `householdSize` | number | Combined with income to compute Area Median Income (AMI) tier. Drives income-based eligibility. |
| Of those, how many are over 18 years old? | `householdAdults` | number | Used for income-aggregation rules — adults' income is generally counted; minor children's income is not. |
| Select any that are part of this household | `householdAttributes[]` | checkboxes | Each value flags priority categories used by partner agencies. See below. |

`householdAttributes[]` value reference:

| Value | Plain meaning | Common eligibility impact |
| --- | --- | --- |
| `single_parent` | Single-parent household | Priority weighting in family-focused funding streams. |
| `child_under_5` | Child under 5 in home | Triggers lead-paint and indoor-air-quality priority. |
| `person_over_62` | Resident aged 62+ | Unlocks senior-focused grants (e.g., aging-in-place modifications). |
| `person_with_disability` | Resident with disability | Unlocks accessibility-focused funding; pairs with `accessibility` repair category. |
| `snap_wic` | Household receives SNAP/EBT or WIC | Acts as a categorical income proxy; can short-circuit some income documentation. |
| `veteran` | US Armed Forces Veteran in home | Unlocks veteran-targeted programs (e.g., VA-paired weatherization). |

---

### Page 6 — Repair request list & urgent conditions (intake staff view)

`id="page-repair-list"` · `data-page="repair-list"`

| Question | `name` / `id` | Type | Eligibility impact |
| --- | --- | --- | --- |
| Repair need (dynamic rows) | `repairNeed[]` | text | Free-text scope items. Used by the assessor to plan the home visit checklist. |
| Priority (per row) | `repairPriority[]` | number | Applicant-identified rank. Helps the assessor sequence work when budget is constrained. |
| Enter any additional repair need details | `additionalRepairDetails` | textarea | Catch-all for context that doesn't fit the row structure. |
| Check any that apply (urgent conditions) | `urgentConditions[]` | checkboxes | Triage flags. Any checked value should escalate the record to the rapid-response queue. |

`urgentConditions[]` and `repairCategory[]` value reference *(both lists share the same value set; Page 6 uses staff-facing wording, Page 7 uses applicant-facing first-person wording so a record can be triaged either way without re-mapping)*:

| Value | Plain meaning | Urgency / routing |
| --- | --- | --- |
| `unable_to_stay` | Home is uninhabitable | **Life-safety.** Emergency housing referral in parallel with repair triage. |
| `no_hvac` | No functional heating/cooling | Seasonal weatherization priority; winter and summer thresholds escalate severity. |
| `no_potable_water` | No drinkable water | **Life-safety.** Same-week dispatch target. |
| `no_bathroom` | Bathroom unusable | High priority; health-code implications. |
| `no_kitchen` | Kitchen unusable | High priority; impacts ability to prepare food safely. |
| `open_to_elements` | Envelope breach (roof, walls, windows) | High priority; secondary damage accumulates quickly. |
| `no_entry` | Cannot enter/exit home safely | **Life-safety.** Accessibility ramp or emergency entry repair. |
| `accessibility` | Mobility / ADA need | Routes to accessibility-funded programs. |
| `other_issue` | Issue not enumerated | Manual triage. |
| `eviction_risk` | At risk of eviction | Routes to housing-stability partners in parallel with repair scope. |

---

### Page 7 — Home repair requests (applicant view)

`id="page-repair-categories"` · `data-page="repair-categories"`

| Question | `name` / `id` | Type | Eligibility impact |
| --- | --- | --- | --- |
| Please check all boxes that apply to your home | `repairCategory[]` | checkboxes | Drives which sub-blocks appear on Page 8. Each checked value reveals a targeted follow-up question. See value table under Page 6. |

---


### Page 8 — Request details (conditional sub-blocks)

`id="page-request-details"` · `data-page="request-details"`

Each sub-block below is hidden until its matching `repairCategory[]` value is checked on Page 7 (`data-show-when-checked="<value>"`).

| Sub-block (trigger) | Question | `name` / `id` | Type | Eligibility impact |
| --- | --- | --- | --- | --- |
| `unable_to_stay` | Please describe the issue as best as you can | `detailsUnableToStay` | textarea | Narrative used to confirm uninhabitability and to dispatch emergency housing referrals. |
| `no_hvac` | Please describe the issue as best as you can | `detailsHvac` | textarea | Used to scope repair vs. full replacement of HVAC system. |
| `no_hvac` | How do you heat your home? | `heatingSource[]` | checkboxes (`woodstove`, `gas_propane`, `electric`, `kerosene`) | Identifies fuel type for weatherization grants and safety follow-ups (e.g., kerosene heaters trigger CO-detector outreach). |
| `no_potable_water` | Please select source of water | `waterSource` | select (`municipal`, `well`) | `well` routes to well-rehabilitation programs; `municipal` routes to service-line / plumbing repair. |
| `no_potable_water` | Please describe the issue as best as you can | `detailsWater` | textarea | Scope detail for plumbing assessor. |
| `no_bathroom` | Please describe the issue as best as you can | `detailsBathroom` | textarea | Scope detail. |
| `no_kitchen` | Please describe the issue as best as you can | `detailsKitchen` | textarea | Scope detail. |
| `open_to_elements` | Please describe the issue as best as you can | `detailsElements` | textarea | Scope detail; used to triage tarp/board-up needs. |
| `no_entry` | Please describe the issue as best as you can | `detailsEntry` | textarea | Scope detail; informs whether ramp, stair, or door work is needed. |
| `accessibility` | Please describe your accessibility need | `detailsAccessibility` | textarea | Used to match the case with accessibility-funded programs and certified ADA contractors. |
| `other_issue` | Please describe the issue | `detailsOther` | textarea | Manual triage notes. |
| `eviction_risk` | Please describe your situation | `detailsEviction` | textarea | Forwarded to housing-stability partners alongside repair triage. |

---

### Page 9 — Hurricane Helene relation

`id="page-helene"` · `data-page="helene"`

| Question | `name` / `id` | Type | Eligibility impact |
| --- | --- | --- | --- |
| Was this issue caused by Tropical Storm Helene? | `heleneRelated` | radio (`yes` / `no`) | **Funding-stream gate.** `yes` opens disaster-recovery funds (FEMA, state disaster grants) and reveals Page 10. `no` skips the FEMA page and routes the case through standard repair funding. |

---

### Page 10 — FEMA *(conditional: `heleneRelated=yes`)*

`id="page-fema"` · `data-page="fema"` · `data-show-if="heleneRelated=yes"`

| Question | `name` / `id` | Type | Eligibility impact |
| --- | --- | --- | --- |
| Have you filed a claim with FEMA for repairs listed? | `femaClaim` | radio (`yes` / `no`) | Determines duplication-of-benefits (DOB) check. `no` does not disqualify; some applicants are eligible to file with assistance. |
| What was the outcome of the FEMA claim? *(if `femaClaim=yes`)* | `femaOutcome` | select (`denied`, `settled`, `other`) | `denied` flags the case for appeal-assistance referral. `settled` triggers DOB calculation. |
| What was total FEMA settlement amount? *(if `femaClaim=yes`)* | `femaSettlementAmount` | number ($) | Used to deduct already-funded scope from ARCHR award (DOB rule). |
| Is there any remaining $ from the FEMA settlement amount paid? *(if `femaClaim=yes`)* | `femaRemaining` | radio (`yes` / `no`) | Determines whether unspent disaster funds must be applied first before ARCHR funds. |
| What is the total amount remaining from the FEMA settlement amount? *(if `femaRemaining=yes`)* | `femaRemainingAmount` | number ($) | Exact unspent balance; subtracted from ARCHR award ceiling. |

---

### Page 11 — Homeowner's insurance

`id="page-insurance"` · `data-page="insurance"`

| Question | `name` / `id` | Type | Eligibility impact |
| --- | --- | --- | --- |
| Have you filed a claim with your homeowner's insurance for repairs you listed? | `insuranceClaim` | radio (`yes` / `no`) | DOB check parallel to FEMA. `no` is fine and common. |
| What was the outcome of the homeowner's insurance claim? *(if `insuranceClaim=yes`)* | `insuranceOutcome` | select (`denied`, `settled`, `other`) | `denied` flags for advocacy referral. `settled` triggers DOB calculation. |
| What was the total homeowner's insurance settlement amount? *(if `insuranceClaim=yes`)* | `insuranceSettlementAmount` | number ($) | Deducted from ARCHR scope per DOB rule. |
| Is there any remaining $ from the homeowner's insurance settlement amount paid? *(if `insuranceClaim=yes`)* | `insuranceRemaining` | radio (`yes` / `no`) | Determines whether unspent insurance funds must be applied first. |
| What is the total amount remaining from the homeowner's insurance settlement amount? *(if `insuranceRemaining=yes`)* | `insuranceRemainingAmount` | number ($) | Exact unspent balance; subtracted from ARCHR award ceiling. |

---

### Page 12 — Income information & applicant signature

`id="page-income"` · `data-page="income"`

| Question | `name` / `id` | Type | Eligibility impact |
| --- | --- | --- | --- |
| Do you receive income? | `haveIncome` | radio (`yes` / `no`) | **Branch point.** `yes` reveals income capture controls. `no` reveals Page 13 (Zero Income Affidavit). |
| How would you like to record your income? *(if `haveIncome=yes`)* | `incomeMethod` | radio (`gross`, `calculator`) | Determines capture mechanism. `gross` shows a single annual-income field; `calculator` opens the modal-driven per-source workflow. |
| Please enter gross annual income *(if `incomeMethod=gross`)* | `grossAnnualIncome` | number ($) | Compared against AMI bands for the household size to determine eligibility tier. |
| How do you want to add income documents? *(if `haveIncome=yes`)* | `incomeDocsMethod` | radio (`upload_now`, `email_link`, `in_person`) | Determines documentation workflow. `email_link` triggers automated outbound email; `in_person` flags assessor to collect at home visit. |
| Enter signature | `applicantSignature` | hidden (PNG data URL from `<canvas>`) | Applicant attestation to the accuracy of the submission. Required for record to be considered complete. |

**Income calculator modal** *(opened when `incomeMethod=calculator`)*

| Question | `name` / `id` | Type | Eligibility impact |
| --- | --- | --- | --- |
| Whose income are you adding? | `calcWhose` | radio (`mine`, `other`) | Tags the record so reviewers know which household member each source belongs to. |
| Source of income | `calcSource` | select (`work`, `self_employment`, `social_security`, `disability`, `retirement`, `other`) | Determines which documentation types are acceptable (e.g., `work` → pay stubs/W-2; `social_security` → benefits award letter). |
| How often is $ received? | `calcFrequency` | select (`weekly`, `biweekly`, `monthly`, `annually`, `other`) | Used to annualize the amount for AMI comparison. |
| Amount | `calcAmount` | number ($) | Per-occurrence dollar amount (pre-tax). |

Each saved entry is appended to the `#income-records` table on Page 12; the table is read by the reviewer to compute total annualized household income.

---

### Page 13 — Zero Income Affidavit *(conditional: `haveIncome=no`)*

`id="page-zero-income"` · `data-page="zero-income"` · `data-show-if="haveIncome=no"`

| Question | `name` / `id` | Type | Eligibility impact |
| --- | --- | --- | --- |
| First name | `zeroIncomeFirstName` | text | Identifies the affiant (must match the applicant or an adult household member). |
| Last name | `zeroIncomeLastName` | text | Identifies the affiant. |
| Address | `zeroIncomeAddress` | text | Property address attested to. |
| Signature | `zeroIncomeSignature` | hidden (PNG data URL from `<canvas>`) | Sworn signature under penalty of perjury. Required for the affidavit to be accepted in lieu of income documentation. |
| I certify the statement above is true. | `zeroIncomeAgree` | checkbox (`yes`) | Explicit attestation checkbox; must be checked for the affidavit to be considered valid. |

The affidavit text enumerates ten income sources the affiant must certify they do not receive. Submission of a valid affidavit places the applicant in the lowest AMI tier and unlocks zero-income-specific programs.

---

### Page 14 — Submission confirmation

`id="page-submitted"` · `data-page="submitted"`

Read-only summary of contact info echoed back to the applicant via `data-summary` bindings (`preferredContact[]`, `homePhone`, `cellPhone`, `contactEmail`, `otherContactMethod`, `contactNotes`). Includes outbound link to the ARCHR website. No fields captured on this page.

---


## 5. System & language fields (not applicant-visible)

| `name` / `id` | Purpose |
| --- | --- |
| `language` | Hidden input set to `eng` or `esp` based on the active language toggle. Stored with the submission so partner staff know which language to use for outbound communication. |

---

## 6. Eligibility decision summary (draft)

This table summarizes how the most consequential fields feed the eligibility decision. **Verify with program leads before publishing.**

| Decision | Driving fields | Outcome |
| --- | --- | --- |
| Service-area check | `homeAddress`, `homeCity`, `homeState`, `homeZip` | Routes to the nearest partner; out-of-area submissions are forwarded with a referral letter. |
| Ownership gate | `ownsHome`, `ownsLot` (mobile only) | Renters are routed to renter-focused services; non-lot-owning mobile-home residents have a restricted program list. |
| Tenancy duration | `livedOneYear`, `moveInDate` | Filters out programs with minimum-tenancy requirements. |
| AMI tier | `householdSize`, `householdAdults`, `grossAnnualIncome` or sum of calculator entries, `zeroIncomeAgree` | Determines which income-restricted programs the applicant qualifies for. |
| Categorical priority | `householdAttributes[]` | Adds qualifying flags (senior, disability, veteran, families with young children, SNAP/WIC). |
| Urgency triage | `urgentConditions[]`, `repairCategory[]` | Life-safety values escalate to rapid-response queue. |
| Funding-stream selection | `heleneRelated`, `femaClaim`, `femaOutcome`, `insuranceClaim`, `insuranceOutcome` | Disaster-recovery vs. standard funding; DOB deductions against any settled claim amounts. |
| Documentation path | `incomeDocsMethod`, `applicantSignature`, `zeroIncomeSignature`, `consentAgree` | Determines how proof is collected and whether the record can be shared across partners. |

---

## 7. Suggested staff workflow (SOP draft)

1. **Receive submission.** Verify `consentAgree=yes`. If missing, hold the record and contact the applicant for verbal consent before sharing with partners.
2. **Service-area triage.** Look up `homeZip` against the partner coverage map. If outside ARCHR's footprint, send the standard out-of-area referral and close the record.
3. **Ownership check.** If `ownsHome=no` (or `homeType=mobile` with `ownsLot=no`), route to the appropriate alternate program and close the ARCHR record.
4. **Urgency review.** Scan `urgentConditions[]` and `repairCategory[]`. Any life-safety flag (`unable_to_stay`, `no_potable_water`, `no_entry`) is escalated to the rapid-response queue within one business day.
5. **Funding-stream assignment.** If `heleneRelated=yes`, evaluate FEMA fields for DOB; if `insuranceClaim=yes`, evaluate insurance fields for DOB. Compute remaining ARCHR award ceiling.
6. **Income verification.** Confirm income capture (gross or calculator entries) is present. If `haveIncome=no`, verify the Zero Income Affidavit is signed (`zeroIncomeSignature` non-empty) and `zeroIncomeAgree=yes`.
7. **Document collection.** Initiate the workflow indicated by `incomeDocsMethod` (in-app upload, email link, or in-person at assessment).
8. **Partner assignment.** Match the applicant's categorical flags and AMI tier against the partner specialization matrix. Assign primary partner; if multiple partners qualify, follow the round-robin or capacity-based rule of the current intake cycle.
9. **Outreach.** Use `preferredContact[]` in order, with `contactNotes` taken into account. Schedule the home assessment visit.
10. **Record closure.** Once a partner accepts the case, mark the screening record `assigned`. If no partner can serve, send the applicant a written explanation with referral resources.

---

## 8. Notes for proofreading

- All eligibility-impact statements above are **placeholder language** written from the structure of the form. They should be reviewed against:
  - The current funding-source eligibility manuals for each ARCHR partner.
  - The duplication-of-benefits (DOB) policy used for Helene recovery work.
  - HUD AMI tables in effect for the program year.
  - Any updates to the zero-income affidavit language required by your funders.
- The `req` markers (`<span class="req">*</span>`) in the HTML are visual indicators only; HTML5 `required` validation is intentionally **not** enforced in the current draft so the form can be navigated end-to-end for review without filling in fields.
- The progress bar reflects only **visible** pages, so referral, Helene, and zero-income branches produce different denominators. This is expected.
- The English/Spanish language toggle uses the `translations.esp` dictionary in `archr-intake.js`. Strings not yet translated will display in English; the dictionary should be extended as new copy is added.

---

## 9. Files in this project

| File | Purpose |
| --- | --- |
| `archr-intake.html` | Markup for all 14 pages, app-shell layout, language toggle, progress bar, signature canvases, and embedded CSS. |
| `archr-intake.js` | Page navigation, conditional visibility, dynamic rows, signature pad initialization, language switcher, and the EN/ES translation dictionary. |
| `README.md` | This document. |
