---
title: Editing Applicant Contact Info (Name, Phone, Email)
visibility: authenticated
---

# Editing Applicant Contact Info

## When this comes up

The contact details on a case sometimes belong to the wrong person — most
often a **referrer or neighbor** who filled out the intake form on behalf of
the person actually needing help. You usually find out through a
communication log (e.g. a caseworker called the number and reached the
referrer, not the applicant).

## The rule: never edit the raw submission

Submissions (`intake_submissions`) are the **preserved, as-received** form
data. Corrections belong on the **application** — the editable working copy
created from the submission for intake and eligibility work. Cases hang off
the application, so a correction on the application is reflected on every
case for that household.

```
submission (raw, never edited)  ->  application (edit here)  ->  case(s) -> project(s)
```

## How to make the correction

1. Open the case from the **Case List** (filterable by organization) and
   click through to **Case Review**.
2. Under **Applicant**, click **Edit contact info**.
3. Update first name, last name, email, and/or phone, then **Save**.

What happens behind the scenes (implemented in the Vue demo and mirrored in
`app/`):

- If an **application** already exists for the submission, only its
  `applicant_first_name` / `applicant_last_name` / `applicant_email` /
  `applicant_phone` fields are updated.
- If none exists yet, one is **created as a copy of the submission** first
  (same behavior as `deduplicate_submissions` in
  `sql/application-lifecycle.sql`), then your edit is applied.
- The raw submission row is left untouched either way.
- The Case Review shows an **edited** flag once an application backs the
  contact fields, so staff can tell corrected data from raw intake data.

## Follow-ups

- If the phone number on file belongs to a referrer, add a communication
  log entry noting whose number it was and how the correct one was obtained.
- If the *address* is wrong (not just contact info), that's a bigger change —
  the placecode and deduplication are keyed off the address; escalate to an
  org admin rather than editing in place.
