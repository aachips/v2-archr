# ARCHR Volunteer Role — Documentation

## Overview

The **Volunteer** role represents community members who contribute their time and effort to ARCHR home repair projects. Volunteers are vetted and approved by an Administrative role before receiving dashboard access.

**Brand color:** `#A3C2FF` (light blue)

## Lifecycle

```
Applicant → (Intake Form) → Pending Review → (Admin Approval) → Active Volunteer → Dashboard Access
```

1. **Application** — A person fills out the Volunteer Intake Form (multi-step Vue component), providing their motivation, skills, availability, and contact details.
2. **Vetting** — An Admin reviews the application, verifies the applicant, and creates a volunteer account.
3. **Activation** — The volunteer receives credentials and can log into the Volunteer Dashboard.
4. **Engagement** — The volunteer browses opportunities, claims shifts, logs hours, and builds reputation/XP.

## Database Schema

### `volunteer_profiles`

The main profile table for active volunteers:

| Column | Type | Default | Notes |
|--------|------|---------|-------|
| `id` | integer | auto | Primary key |
| `user_id` | integer | nullable | FK → `users.id` |
| `level` | integer | 1 | Volunteer level (1–5) |
| `xp` | integer | 0 | Experience points |
| `xp_to_next_level` | integer | 100 | XP needed for next level |
| `reputation_score` | integer | 0 | Reputation meter (0–1000) |
| `reputation_tier` | integer | 0 | Tier classification |
| `total_quests_completed` | integer | 0 | Tasks/shifts completed |
| `total_hours_logged` | numeric(10,2) | 0 | Lifetime hours |
| `consecutive_weeks_active` | integer | 0 | Streak tracking |
| `last_active_at` | timestamp | nullable | Last activity |
| `push_notifications_enabled` | boolean | true | Push notification preference |
| `email_digest_enabled` | boolean | true | Email digest preference |
| `weekly_quest_limit` | integer | 5 | Max tasks per week |
| `avatar_choice` | varchar(50) | 'default' | Avatar selection |
| `title_equipped` | varchar(100) | nullable | Display title |

### `volunteer_skills`

Skills a volunteer has claimed, with proficiency and endorsement:

| Column | Type | Default | Notes |
|--------|------|---------|-------|
| `id` | integer | auto | Primary key |
| `volunteer_id` | integer | | FK → `volunteer_profiles.id` |
| `skill_id` | integer | | FK → `skills.id` |
| `proficiency_level` | integer | 1 | 1–5 scale (CHECK constraint) |
| `endorsed_by` | integer | nullable | FK → `users.id` (endorser) |
| `endorsed_at` | timestamp | nullable | When endorsed |

### `volunteer_hours`

Logged hours per shift/task:

| Column | Type | Default | Notes |
|--------|------|---------|-------|
| `id` | integer | auto | Primary key |
| `user_id` | integer | nullable | FK → `users.id` |
| `work_order_id` | integer | nullable | FK → `work_orders.id` |
| `date` | date | | Date of work |
| `hours` | numeric(5,2) | | Hours worked |
| `task_description` | text | | What was done |
| `verified_by` | integer | nullable | FK → `users.id` (verifier) |
| `verified_at` | timestamp | nullable | When verified |

### `volunteer_badges`

Achievement badges awarded to volunteers.

### `volunteer_content`

Stories, field notes, and photos shared by volunteers (requires admin review before publishing).

### `volunteer_feedback`

Feedback given by or about volunteers, linked to quests and beneficiaries.

## Volunteer Progression

| Level | Title | XP Required | Description |
|-------|-------|-------------|-------------|
| 1 | New Volunteer | 0 | Just completed orientation |
| 2 | Active Volunteer | 100 | Regular contributor |
| 3 | Experienced Volunteer | 300 | Trusted on diverse crews |
| 4 | Field Volunteer | 500 | Mentoring newcomers |
| 5 | Crew Member | 1000 | Eligible for crew lead pathway |

## Capabilities

Volunteers have the following permissions (via the level capability system + role overrides):

- **View assigned tasks** — See shifts and tasks they've claimed
- **Log volunteer hours** — Submit hour logs with descriptions
- **Browse open opportunities** — See available quests/tasks open to their role
- **Upload completion photos** — Attach before/during/after photos to completed tasks
- **View own XP and reputation** — See their progression stats
- **Complete safety orientations** — Access required training modules
- **Share field stories** — Submit stories for the content library (admin-reviewed)

### Boundaries (what Volunteers CANNOT do)

- View applicant case files or personal information
- See financial details, budgets, or funding data
- Access other volunteers' private data
- Manage organizational settings or users
- Change case statuses or assign staff
- Approve expenses or manage documents

## Frontend Components

### `VolunteerWelcome.vue`

The merged "Welcome + Who Am I?" view. Displays:
- Welcome hero with volunteer identity
- Quick stats (hours, XP, level, tasks completed)
- "What You Can Do" action list
- Expandable "Role Details" section containing:
  - Identity proof
  - Capabilities list
  - Role boundaries
  - Progression path visualization

### `VolunteerIntakeForm.vue`

Multi-step application form (5 steps):
1. **Welcome & Motivation** — Why volunteer, how they heard about ARCHR
2. **Personal Information** — Name, email, phone, location
3. **Skills & Availability** — Experience checkboxes, schedule availability, tools/transport
4. **Preferences** — Work interest type, physical accommodations, referral source
5. **Review & Submit** — Summary + volunteer agreement checkbox

**Backend integration:** The form currently logs to console. Wire to `POST /api/volunteer-intake` when the endpoint is created (see `app/lib/intake-save.php` for the pattern used by the home repair intake).

### Sidebar Navigation (Volunteer Role)

| Item | View | Description |
|------|------|-------------|
| Welcome | `volunteer-welcome` | Merged welcome + role details |
| Apply | `volunteer-intake` | Volunteer intake form (for new applicants) |
| Profile | `profile` | Account settings |

## Backend Files

| File | Purpose |
|------|---------|
| `app/volunteer.php` | PHP entry point using portal-layout renderer |
| `app/partials/volunteer-body.php` | PHP dashboard markup (legacy, superseded by Vue components) |
| `app/help-content/volunteer-mgmt.php` | Help content for volunteers |
| `app/templates/volunteer.php` | Template source for volunteer-body partial |

## Intake Form → Account Flow (Planned)

The intake form submission should create a record in a `volunteer_applications` table (not yet created):

```sql
CREATE TABLE volunteer_applications (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    location VARCHAR(255),
    motivation TEXT,
    hear_about VARCHAR(50),
    skills TEXT[],           -- Array of selected skills
    availability TEXT[],     -- Array of time slots
    has_tools BOOLEAN DEFAULT FALSE,
    tools_notes TEXT,
    interest_type VARCHAR(50),
    physical_limits TEXT,
    referral_name VARCHAR(255),
    status VARCHAR(50) DEFAULT 'pending',  -- pending, approved, rejected
    reviewed_by INTEGER REFERENCES users(id),
    reviewed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

When an Admin approves:
1. A `users` record is created (if not already existing)
2. A `volunteer_profiles` record is created linked to that user
3. The volunteer receives login credentials

## Design Notes & Feedback

From volunteer feedback (Austin Brown, 2025):
- **Predictability matters:** Volunteers want to know where they'll be sent before committing
- **Communication is key:** More notice = better experience
- **Boundary awareness:** Homeowners should be given advance notice before repair crews arrive
- **Professional distance:** Discourage fraternizing with staff on systems and time

## Related Documentation

- `documentation/Developer-Mapping/interface/volunteer/` — Original design artifacts (user stories, HTML/PHP drafts, feedback notes)
- `archr-export.sql` — Full database schema including all volunteer tables
- `app/lib/permissions.php` — Permission level capabilities and menu registry
