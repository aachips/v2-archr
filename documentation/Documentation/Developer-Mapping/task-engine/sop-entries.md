# SOP &middot; Good vs. Bad Quick Entries

**Audience:** Anyone with submit access to the Tasks, Logs &amp; Events (TLE) engine.
**Goal:** Keep raw entries fast to type, but easy for a Task Rabbit to parse, route,
and verify without chasing the submitter for context.

---

## The Rabbit&rsquo;s job is parsing, not guessing

Every raw entry is reviewed by a second person (the Task Rabbit) before it counts
toward metrics or hits a case to-do list. A good entry gives the Rabbit enough
context to **categorize** (Task / Event / Communication), **attach to a case**,
and **set a due date or follow-up** without writing back to you.

If the Rabbit has to guess, the entry will either bounce back or get filed
incorrectly &mdash; both slow the case down.

---

## The four-part recipe for a good entry

Every line should answer, in any order:

1. **Case** &mdash; case number or a unique address fragment (`42-CHERRY`, `15 Merrill St`).
2. **What** &mdash; the action, event, or message in plain language.
3. **Who** &mdash; the other party (client name, sub, funder, crew lead).
4. **When** &mdash; explicit date/time when it matters (`Fri 2pm`, `before storm`, `by EOD Dec 20`).

Your initials and the submission timestamp are auto-stamped &mdash; don&rsquo;t retype them.

### One fact per line

Each newline in the Quick Entry box becomes its own raw entry. If you logged
three things, hit Enter twice between them. The Rabbit can still split a single
line into multiple items, but pre-splitting saves them a triage step.

---

## Good entries

```
42-CHERRY roof needs tarping before storm &mdash; 4 sandbags + tarp loaded in van
Called Mrs. Lopez (42-CHERRY) at 2:10pm Fri &mdash; confirmed Thursday assessment 9am
15-MERRILL income docs uploaded (W-2, 2023 1040). Ready for Bursar review.
8-OAKLAND deed verification requested; title company quoted 3 business days
```

**Why these work:**

- Case identifier in the first 1&ndash;3 words.
- Specific verbs (`tarping`, `called`, `uploaded`, `requested`).
- Times and durations are concrete (`2:10pm Fri`, `3 business days`).
- Each line is one item the Rabbit can verify with a single click.

---

## Bad entries (and how to fix them)

| Bad | Why | Fix |
|---|---|---|
| `fix house` | No case, no specifics, no owner. | `42-CHERRY needs roof tarp before Friday storm` |
| `talked to her about the thing` | Vague pronouns, no case, no outcome. | `Called Mrs. Lopez (42-CHERRY) re: roof timeline &mdash; agreed to Thu 9am assessment` |
| `roof tarp called client uploaded photos walkthrough scheduled` | Five entries glued together with no separators. | Hit Enter between each. The Rabbit will split a run-on, but you&rsquo;ll get nudged. |
| `Mike said ok` | Who is Mike? Ok to what? On which case? | `15-MERRILL: Mike (electrician sub) confirmed Wed start for panel upgrade` |
| `urgent!!!` | Urgency without an action or case is noise. | `42-CHERRY URGENT: tarp before 6pm storm tonight; call Lopez first` |

---

## When to use Advanced (Task Rabbit) fields

The collapsed **&ldquo;Add structure now&rdquo;** panel under Quick Entry lets you fill in
Case, Type, Priority, and Assignee yourself. Use it when:

- You already know the case number and want to save the Rabbit a lookup.
- The entry is a scheduled **Event** with a firm time (so it lands on the calendar fast).
- You&rsquo;re assigning to someone specific by initials or role.
- Priority is **P0/Urgent** &mdash; fill the field so the Rabbit triages it first.

Skip the panel if you&rsquo;re in a hurry. A clean one-line raw entry beats a half-filled
advanced form every time.

---

## Communications: log the substance, not the small talk

For phone calls, texts, and emails, the verified Communication record needs:

- **Who** initiated (you / them).
- **Channel** (call, text, email, in-person).
- **Substance** (decision, commitment, or new info).
- **Follow-up** (next action + when, if any).

Skip pleasantries and back-and-forth. One sentence per call is usually enough.

---

## Events: dates that matter

An entry becomes an **Event** when it goes on a calendar. Always include:

- Date and start time.
- Duration or end time if known.
- Location or virtual link.
- Required attendees (names or roles).

The Rabbit will create the calendar entry and attach it to the case.

---

## What happens after you submit

1. Entry lands in the **Unverified** queue, stamped with your initials and ISO datetime.
2. A Task Rabbit opens **Triage &amp; Parse**:
   - Splits the raw text into one or more structured items.
   - Sets type (Task / Event / Communication), case, priority, assignee.
   - May add a verifier note explaining the split.
3. On **Verify &amp; Publish**, parsed items appear in the case to-do list, the
   calendar, or the comms log &mdash; and they begin counting toward metrics.
4. The original raw text is preserved immutably in the ledger for audit.

If your entry is bounced, you&rsquo;ll see it returned in **My Submissions** with a
reason. Edit and resubmit.

---

## Quick reference card

> **Format:** `CASE` + `what` + `who` + `when`
> **One fact per line.** Hit Enter between items.
> **Auto-stamped:** your initials + ISO datetime &mdash; don&rsquo;t retype them.
> **Skip:** pleasantries, urgency without action, vague pronouns.
> **In a hurry?** Submit raw. The Rabbit will parse.
> **Know the structure?** Use the Advanced panel; it may auto-verify.

---

*See also:* [`tle-table.md`](tle-table.md) for the field schema, and
[`tle-poc.html`](Developer-Mapping/task-engine/tle-poc.html) for the working interface this SOP describes.
