---
document_name: Application Review & Case Management SOP
document_type: Standard Operating Procedure
version: 1.0
last_updated: 2026-09-07
author: ARCHR Development Team
audience: Admins, Caseworkers, Organizational Administrators
complexity_level: Intermediate
estimated_reading_minutes: 10
tags: [case-management, application-review, assignment, SOP]
visibility: authenticated
---

# Application Review & Case Management

> **Who this is for:** Caseworkers, Admins, and Organizational Administrators who review incoming applications and turn them into active cases.

## Why This Matters

This is where applications become cases. It's the bridge between "someone asked for help" and "we're actually helping them." Mess this up and you get bottlenecks, dropped applicants, and the kind of frustration that makes partners pull out of the coalition. Get it right and the whole system flows smoothly.

**If you didn't review it, it doesn't exist.** Every application needs eyes on it before it becomes a case.

---

## Step 1: Check the Pending Applications Queue

Your dashboard should show you a list of unclaimed applications. These are submissions from applicants that haven't been picked up by any organization yet.

**What to look for:**
- **Submission date** — older applications first (FIFO, unless urgency dictates otherwise)
- **Urgency flags** — "Unable to stay in home," "No potable water," "Open to elements" — these jump the queue
- **Completeness** — does the application have basic contact info, address, and household details?

> **Tip:** An incomplete application is still worth reviewing. Sometimes missing info just means the applicant didn't know what to enter. You can fill gaps during first contact.

---

## Step 2: Review Applicant Information

Open the application and check for:

| Item | Why It Matters |
|------|----------------|
| **Home address / Placecode** | Confirms they're in your service area |
| **Contact information** | Phone, email — at least one must be valid |
| **Home ownership** | Must own the property to qualify for most programs |
| **Household size & income** | Determines eligibility tier |
| **Repair needs listed** | Tells you what kind of work they need |
| **Damage cause** | Hurricane Helene-related? Different funding paths apply |
| **Eligibility flags** | Green = likely eligible, Yellow = needs review, Red = potential disqualifier |

**Remember our philosophy:** Assume eligibility until proven otherwise. The system flags issues for *human review* — it never auto-denies. A yellow or red flag means "look closer," not "reject."

---

## Step 3: Eligibility Check

The system runs automatic eligibility checks based on:
- **Geography** — is the property in your service area?
- **Income** — does household income fall within program guidelines?
- **Home ownership** — does the applicant own the property?
- **Damage cause** — is the damage related to a covered event?

**What the flags mean:**

| Flag Color | Meaning | Action |
|------------|---------|--------|
| 🟢 Green | Meets standard criteria | Proceed normally |
| 🟡 Yellow | Something needs review | Look at the flagged item, decide if it's a real issue |
| 🔴 Red | Potential disqualifier | Review carefully — this needs a human decision with documented reasoning |

> **Important:** A red flag does NOT mean auto-denial. It means a human needs to review the situation and check boxes explaining the decision. We don't let algorithms turn people away.

---

## Step 4: Claim the Application (Create a Case)

Once you've reviewed the application and decided your organization can help:

1. **Click "Claim"** on the application record
2. **Select the repair needs** your organization will handle (you might not handle all of them)
3. **Add a claim note** — something brief like "Roof assessment scheduled for 9/15"
4. **Confirm**

**What happens next:**
- A **Case** is created, linked to the original Application
- The **90-day progress clock** starts — you now have 90 days to show progress, or the claim expires and another org can pick it up
- The application status updates to show it's been claimed
- Other organizations can see that these repair needs are taken (but can still claim unclaimed needs)

> **The 90-day rule exists for a reason.** It prevents applications from sitting in limbo. Any progress event — a task, a communication, a document upload — resets the clock. So keep the case moving.

---

## Step 5: Set Initial Case Status and Assign Staff

After claiming:

1. **Set the case status** — typically starts at "New" or "Intake Review"
2. **Assign a caseworker** — the primary point of contact for this household
3. **Log the first progress event** — "Case claimed by [Org], assigned to [Caseworker]"

**Best practice:** Make first contact within 48 hours of claiming. Applicants who submit and then hear nothing get anxious, and anxious applicants call other organizations, which creates duplicate work and confusion.

---

## Step 6: When to Accept vs. Pass on an Application

**Accept when:**
- The repair need matches your organization's capabilities
- You have capacity to handle it in a reasonable timeframe
- The applicant is in your service area

**Pass (don't claim) when:**
- The repair need is outside your scope (e.g., you do roofs, they need electrical)
- You're at capacity and can't start work within 90 days
- The applicant is outside your geographic service area

**If you pass, log why.** A quick note like "Electrical repair outside our scope — referred to [Other Org]" helps the next organization that looks at this application.

---

## Common Scenarios

### Scenario 1: Two Organizations, One Application
An application has roof damage AND plumbing damage. Habitat claims the roof. CHC claims the plumbing. Two cases, one application. This is normal and expected. The Application layer is shared; each Case has its own timeline and progress.

### Scenario 2: Application Has Been Claimed but Nothing Is Happening
Check the 90-day clock. If no progress events have been logged, the claim may be about to expire. You can reach out to the claiming organization or wait for the claim to expire and then claim it yourself.

### Scenario 3: Applicant Submitted Twice
The system deduplicates submissions into a single Application. If the same household submits multiple times (forgot to upload docs, changed their mind, etc.), all submissions roll into one Application record. Check the submission history to see the full picture.

---

## Quick Reference

| Action | Where | Who |
|--------|-------|-----|
| View pending applications | Case Search / Dashboard | Admin, Caseworker |
| Review eligibility flags | Application detail view | Admin, Caseworker |
| Claim repair needs | Application detail → "Claim" button | Admin, Caseworker |
| Assign caseworker | Case detail → Staff assignment | Admin |
| Set case status | Case detail → Status dropdown | Admin, Caseworker |
| Log progress event | Any case action auto-logs; manual via "Log Event" | Everyone |

---

**Remember:** Every application is a person who needs help. The faster you review, the faster they get it.
