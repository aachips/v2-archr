Over the last few months, we've been documenting what works, what doesn't, and what needs to change. We've conducted one-on-one interviews with users across the coalition. We've mapped out the six phases of a repair project. We've started designing a new system that will make all of our work easier—whether you're a tech person or technology challenged.

That's what this meeting is about: hearing from you about what's working, what's not, and what you need from the system.

# ARCHR Platform

## My First 100 Days

A progress update & developer log
April Chips · Software / Platform Specialist

![[img/archr-logo.png]]

---

# Where We Started

**Listen first. Build second.**

- No assumptions — interviewed the people who use the system every day
- Discovery form + 1-on-1 interviews (`interview-feedback/discovery-form.html`)
- Every pain point written down before a single feature was planned

*(screenshot: discovery form)*

---

# What You Told Us — Pain Points

- "Can't find information I'm looking for in one place"
- "Uploads get lost"
- "Can't track financial metrics" — reporting *and* project-level
- "Airtable is difficult to work with"
- Bugs around task buttons (claiming tasks, reporting communication)
- "Communication doesn't get logged, duplicate communication happens, people look like idiots as a result"
- "No training or orientation on the platform. No help documents."
- Volunteers: "Everything has been more chaotic and less predictable since the storm"

→ `interview-feedback/feedback.md`

---

# What's Already Working

Worth keeping and building on:

- ✅ **Case Search** works great — Placecode system for tracking cases works great
- ✅ **Anchor Record** deduplication and merging
- ✅ **DSW Tracking Sheet** integration
- ✅ **Intake is solid** - though sometimes we are losing track of new submissions

---

# SQL Schema Mapping

From scattered Airtable bases → one coherent PostgreSQL schema

- 26 SQL migration files consolidated into a **master schema**
- DBML ERD renderable at dbdiagram.io — every table, every relationship
- Intake, role-based access, partner orgs, document storage, finance, metrics
- Reconciliation notes where definitions overlapped

If you want to see what this looks like mapped out, can do so at https://dbdiagram.io/d/ARCHR-Schema-6a2953529340ecc06568fc78

![[img/dbdiagramdemo.png]]

→ `sql/master-schema.dbml` · `sql/_master.sql`

---

# Interface Rough Draft → Component Library

Mapped the whole frontend before building it:

- Role briefs for every user type (`interface/prompt.md`)
- Site map + dashboard wireframes
- **102 component JSON files across 11 roles**
- **~250+ API endpoints documented**
- Buttons, lists, forms, cards — each with context, confirmations, reversibility

Explore at : aachips.co/archr/component-library.php

→ `elemental-integration/COMPONENT_MAPPING_COMPLETE.md`

---

# The 11 Roles

Assessor · Project Manager · Crew Lead · Crew Member · Bursar · Subcontractor · Volunteer · Envoy · Org Admin · Requestor · Super Admin

Each with its own dashboard, its own components, its own API surface.

---

# Project Phases — Task Engine Backbone

**Home Repair Project Lifecycle: 6 phases · 80+ progress tasks**

Pre-Screen (P0) → Intake (P1) → Processing (P2) → Planning (P3) → Project (P4) → Completion (P5)

Possible exits: Paused · Withdrawn · Ineligible

→ `elemental-integration/task-engine/quick-add-progress-tracker/project-phases/`

---

# Task Engine — "If It Happened, Log It"

- **Quick Add:** two clicks, 30 seconds — case + description, done
- Works from the field; paste notes in when back online
- **Task Rabbit peer review** turns quick entries into real, metric-counted tasks
- Immutable ledger: every log is permanent
- SOP written in plain language for the whole org

→ `documentation/if-it-happened-log-it.md`

---

# Metric Tracking — Built for Reporting

Designed backwards from the reports we owe each month / quarter:

- **Past week:** total apps, assessments assigned/completed, avg triage score, household size, income + county breakdown, issue type pie
- **All time:** jobs total / in progress / completed / withdrawn, avg + high/low job cost
- **Org-specific:** per-partner jobs and assessment stats

![[img/archr-metric-tracking-rough-draft-guide.png]]

→ `elemental-integration/metric-tracking/` · `sql/metric-tracking.sql`

---

# Document Generation System

A working pipeline for the paper trail:

- Full **case folder directory** mapped per home repair (property card → certificate of completion)
- CDBG forms: SHPO, CENST, ERR, IDIS, Lead Statement
- Batch generation via Docupilot + local Airtable template generators
- Task → document mapping: finishing a phase generates its docs

![[img/contract creator data map.svg]]

→ `elemental-integration/document-generation/`

---

# The Overhaul Prototype — Live Demo

A working rebuild you can click through today:

- **Login system with role-based dashboards** (demo password: `12345`)
- All 11 roles log into their own portal
- Working intake, case search, review queues, TLE proof-of-concept
- Admin accounts can be created on request
- Honest label: demo auth, not production security (yet)

*(screenshots: login page → role dashboards)*

→ `app/` · `app/login.php`

---

# Demo Flow

1. `app/index.php` — landing page
2. Log in as `assessor` / `bursar` / `volunteer` … (`12345`)
3. Role dashboard → tasks, queues, quick-add
4. Logout → switch role → repeat

*(add screenshots here)*

---

# What's Next

- Real authentication (hashed passwords, user database, CSRF, rate limits)
- Wire role dashboards to live data — PostgreSQL/Airtable dual-write in progress
- Component library → production frontend
- Metric dashboards wired to monthly/quarterly reports
- More interviews, more feedback, more iteration

---

# Your Turn

Tell me what you want to see:

- RSVP + pick the demos you care about
- Vote on the pain point that hurts most
- Ask the questions you want answered live

→ **`what-could-be.html`** — 3 minutes, shapes the whole meeting

---

# Thank You

Every log entry, every interview, every frustrated email made this better.

**If it happened, log it. If it hurts, tell me.**

April Chips · april@aachips.co
