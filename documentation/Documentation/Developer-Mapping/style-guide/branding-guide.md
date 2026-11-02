---
document_name: Volunteer Management & Hour Tracking SOP
document_type: Standard Operating Procedure
version: 1.0
last_updated: 2026-09-07
author: ARCHR Development Team
audience: Volunteers, Crew Leads, Admins
complexity_level: Beginner
estimated_reading_minutes: 6
tags: [volunteers, hours, scheduling, recognition, SOP]
visibility: authenticated
---

*System Standards and Visual Logic for Disaster Recovery*

> **About this guide.** This document is the single source of truth for ARCHR's visual identity and front-end conventions. Every color, size, spacing value, and component pattern described here is implemented as a CSS custom property in `css/style.css` (the `:root` block). When the guide and the code disagree, fix one to match the other — don't let them drift. New pages should reference these rules rather than hard-coding values.

---

## Purpose

- **Mission:** Providing urgent, free, or low-cost home repairs for residents in Buncombe and Madison counties affected by Hurricane Helene.
- **Problem:** Streamlining repairs for low-income, uninsured, or underinsured homeowners.
- **Solution:** A centralized online database (the "Marketplace") and a joint application process.
- **Branding Goal:** Ensure visual consistency across the digital "Marketplace" so subcontractors and volunteers can navigate the system efficiently.

---

## 2. Logo Specifications

- **The Rotation Rule:** The primary arrow is set to exactly **31.38°**. This angle must be preserved across all digital and print recreations to maintain the "upward recovery" trajectory.
- **Primary Background:** Always prioritize placing the logo on **Canvas Cream `#FFFAE7`** (exposed as `--color-canvas-cream` and used as the light-theme page background, so the logo always sits on its intended canvas).
- **Usage rules:**
  - *Full Banner* — Mandatory for public intake forms and external documents.
  - *Icon-Only* — Reserved for internal Marketplace dashboards where space is at a premium.

> **Planned work:** A code-based (SVG / CSS) recreation of the logotype is being explored so the lockup can be themed (light/dark) and resolution-independent without shipping a raster.

## 3. Color System

### 3a. Brand Colors

| Token | Value | Use |
|---|---|---|
| `--color-primary` | `#E04E39` | Primary actions, logo lockup color, KPI accents, active-tab marker |
| `--color-primary-dark` | `#C23A26` | Hover state for primary buttons |
| `--color-secondary` | `#2A5C82` | Section accents, secondary actions, info callouts, dashboard hero |
| `--color-canvas-cream` | `#FFFAE7` | Light-theme page background (`--bg-page`) and the canvas behind the logo |

### 3b. Role Identity System

The ARCHR system uses color to create unique "Visual Workspaces." Each role is defined by a primary **Action Color** (and, in roadmapped UI, a corresponding Soft Background Tint) to improve navigation and task focus.

The ARCHR ecosystem uses a tiered access model categorized into roles grouped as:

- **Administrative & Oversight** — Admin, Envoy, Project Manager, Bursar
- **Field & Technical Operations** — Assessor, Crew Lead, Crew Member, Subcontractor
- **Client & Support Services** — Requestor, Caseworker, Volunteer
- **System Entry** — the neutral "Select Role" gateway

| Role | Hex | CSS Token |
|---|---|---|
| Requestor      | `#FF7979` | `--role-requestor` |
| Caseworker     | `#FF7979` | `--role-caseworker` |
| Assessor       | `#219BA4` | `--role-assessor` |
| Subcontractor  | `#AA6709` | `--role-subcontractor` |
| Envoy          | `#FFCC00` | `--role-envoy` |
| Project Manager| `#3366CC` | `--role-project-manager` |
| Crew Lead      | `#FF6600` | `--role-crew-lead` |
| Crew Member    | `#FF9900` | `--role-crew-member` |
| Bursar         | `#00CC00` | `--role-bursar` |
| Volunteer      | `#A3C2FF` | `--role-volunteer` |
| Admin          | `#5415B1` | `--role-admin` |

**The Action Color System.** Each role is assigned a unique primary color for interactive elements like headers, buttons, and iconography. This provides an immediate visual cue of the user's current permissions, allowing multi-role users to identify their active workstation at a glance.

### 3c. Project Lifecycle & Phase Pills

The repair process is divided into six distinct stages. Each stage is represented by a standardized Phase Pill that provides immediate visual status for homeowners, contractors, and administrators.

| Phase | Name | Hex | CSS Token |
|---|---|---|---|
| 0 | Select Project | `#0E232E` | `--phase-0-select` |
| 1 | Intake         | `#5C6D70` | `--phase-1-intake` |
| 2 | Review         | `#A1683A` | `--phase-2-review` |
| 3 | Assign         | `#D4A373` | `--phase-3-assign` |
| 4 | Site Work      | `#1B1B1B` | `--phase-4-site-work` |
| 5 | Complete       | `#00CC66` | `--phase-5-complete` |

### 3d. Semantic Colors

| Token | Value | Use |
|---|---|---|
| `--color-success` | `#2f9e69` | Positive deltas, completion states, KPI "completed" |
| `--color-warning` | `#d99518` | Warnings, attention pills, in-progress KPIs |
| `--color-danger`  | `#c23a26` | Errors, overdue, critical safety flags |
| `--color-info`    | `#1d4665` | Informational callouts, neutral data emphasis |

### 3e. Light & Dark Theme Tokens

The site supports a **manual light/dark toggle** that respects `prefers-color-scheme` on first visit and stores the user's choice in `localStorage`. The tokens below swap between themes; brand, role, phase, and semantic colors stay constant.

| Token | Light | Dark |
|---|---|---|
| `--bg-page`            | `#FFFAE7` (canvas cream) | `#1f1b1c` |
| `--bg-surface`         | `#ffffff`                | `#2a2526` |
| `--bg-surface-alt`     | `#F8F9FA`                | `#332d2e` |
| `--color-text`         | `#333333`                | `#fafafa` |
| `--color-text-muted`   | `#6C757D`                | `#b6acad` |
| `--color-border-strong`| `#DEE2E6`                | `#4a4243` |
| `--color-header-bg`    | `#ffffff`                | `#3b3637` |
| `--color-header-text`  | `#333333`                | `#fafafa` |
| `--color-footer-bg`    | `#333333`                | `#1a1718` |
| `--color-footer-text`  | `#ffffff`                | `#fafafa` |

> **Legacy aliases.** `--color-light`, `--color-dark`, `--color-gray`, and `--color-border` are kept as aliases of the semantic tokens above so existing rules theme automatically. New code should prefer the semantic names.

---

## 4. Typography

| Token | Value | Use |
|---|---|---|
| `--font-display` | `'Poppins', system-ui, …` | Headings (h1–h4), KPI values, large numerics |
| `--font-sans`    | `'Open Sans', system-ui, …` | Body text |

**Type scale** — use the variables, don't hard-code px or rem:

| Token | Size | Suggested use |
|---|---|---|
| `--fs-xs`   | 0.75rem  | Pill labels, micro-badges |
| `--fs-sm`   | 0.875rem | Meta text, footer notes, KPI sub-labels |
| `--fs-base` | 1rem     | Body |
| `--fs-md`   | 1.125rem | Sub-headings, chart-card `<h4>` |
| `--fs-lg`   | 1.25rem  | Lead paragraph |
| `--fs-xl`   | 1.5rem   | Dashboard section titles |
| `--fs-2xl`  | 2rem     | KPI values, dashboard `<h2>` |
| `--fs-3xl`  | 2.5rem   | Hero `<h2>` |

**Line-heights** — `--lh-tight` (`1.3`) for headings, `--lh-base` (`1.6`) for body.

---

## 5. Spacing Scale

A 4px-based scale. Prefer these tokens for any new layout work; avoid arbitrary px values:

| Token | px | Common use |
|---|---|---|
| `--space-1`  | 4px  | Hairline gaps |
| `--space-2`  | 8px  | Inline gaps (icon ↔ label) |
| `--space-3`  | 12px | Tight padding |
| `--space-4`  | 16px | Default padding/margin |
| `--space-5`  | 20px | Container gutter |
| `--space-6`  | 24px | Card padding, section gaps |
| `--space-8`  | 32px | Large vertical rhythm |
| `--space-10` | 40px | Hero padding |
| `--space-12` | 48px | Section breaks |

---

## 6. Geometry

### 6a. Border Radii — the 0.6rem Rule

A uniform `0.6rem` corner radius is applied to every button, card, KPI tile, callout, phase pill, and interactive container. **No sharp 90° corners are permitted on interactive components.**

| Token | Value | Use |
|---|---|---|
| `--radius-sm`   | 0.3rem | Inputs, small chips |
| `--radius-md`   | 0.6rem | **Default** — buttons, cards, KPIs, callouts |
| `--radius-lg`   | 1rem   | Hero, panel banners |
| `--radius-pill` | 999px  | Pills, badges, theme toggle, org badges |
| `--border-radius` | alias of `--radius-md` | Legacy reference, do not remove |

### 6b. The 4.0rem Tap-Target Rule

Primary action tiles and navigational icons are strictly **`4rem × 4rem`** (`--tap-target`) to ensure tap-friendly hits during on-site mobile use. Icons inside use `line-height: 0` to prevent vertical drift during browser rendering.

### 6c. Typography in Components

Labels within Phase Pills, Role Tiles, and KPI tiles use **bold** weight to maintain legibility against saturated or surface-colored backgrounds.

---

## 7. Component Library

All components below live in `css/style.css` and consume the tokens above.

### 7a. Buttons (`.btn`)

- `.btn.btn-primary` — Filled `--color-primary`, white text. The primary call-to-action.
- `.btn.btn-secondary` — Surface fill with `--color-primary` border + text. Secondary actions on light surfaces.
- `.btn.btn-outline` — Transparent with `--color-secondary` border + text. Use on dark/colored sections or for neutral actions like Log Out.
- `.btn.btn-large` — Modifier: increased padding/font size for hero CTAs.

### 7b. Cards (`.card`)

Surface-colored container with a top border-stroke in `--color-primary`. Used for marketing/info tiles on the home page. Hover lifts 5px.

### 7c. KPI Tiles (`.kpi`)

Surface-colored tile with a left border-stroke in a status color. Modifiers: `.kpi-blue`, `.kpi-green`, `.kpi-amber`, `.kpi-gray`. Internal structure: `.kpi-label` (uppercase meta), `.kpi-value` (large display number), `.kpi-sub` (footnote).

### 7d. Chart Cards (`.chart-card`)

Surface-colored panel for embedded `<canvas>` charts. Lay out with `.chart-grid` (auto-fit min 320px) or `.chart-grid.cols-2` (min 420px).

### 7e. Pills / Status Badges (`.pill`)

Pill-shaped inline status chip. Modifiers: `.pill-green`, `.pill-amber`, `.pill-red`, `.pill-blue`. Phase Pills (for project lifecycle) should additionally use the `--phase-<n>` colors per §3c.

### 7f. Site Header & Footer

`.site-header` is sticky, themed via `--color-header-bg` / `--color-header-text`. `.site-footer` lives at the bottom of every page with contact info and a small note, themed via `--color-footer-bg` / `--color-footer-text`.

### 7g. Theme Toggle (`.theme-toggle`)

Circular icon button in the nav bar with a sun/moon swap. Behaviour is implemented in `js/script.js`. Every page **must** include the inline pre-paint script in `<head>` to avoid a flash of the wrong theme:

```html
<script>(function(){try{var t=localStorage.getItem('archr-theme');if(t!=='light'&&t!=='dark'){t=window.matchMedia&&window.matchMedia('(prefers-color-scheme: dark)').matches?'dark':'light';}document.documentElement.setAttribute('data-theme',t);}catch(e){}})();</script>
```

And include `<script src="js/script.js"></script>` before `</body>`.

---

## 8. Layout & Container

- `.container` — `max-width: var(--container-max)` (1200px), horizontal padding `var(--container-gutter)` (20px), centered with `margin: 0 auto`. Every top-level `<main>`, `<header>`, and `<footer>` section uses it.
- Stick to CSS Grid (`auto-fit, minmax(...)`) for tile/card layouts so they reflow without explicit breakpoints.

---

## 9. Responsive Breakpoints

| Breakpoint | Media query | Used for |
|---|---|---|
| ≤ 992px | `@media (max-width: 992px)` | Hero stacks vertically, content flow adjusts |
| ≤ 768px | `@media (max-width: 768px)` | Mobile nav re-stack, button full-width, hero h2 shrinks |
| ≤ 700px | `@media (max-width: 700px)` | Dashboard hero/KPI shrink |

---

## 10. Accessibility

- Use `<button>` for actions, `<a>` for navigation. Always provide visible text or `aria-label`.
- The theme toggle uses `aria-pressed` to convey state.
- Tap targets ≥ 44px; primary action tiles use 4rem (64px) per §6b.
- Preserve `:focus-visible` outlines on every interactive element. The theme toggle uses a colored border on focus.
- Aim for **WCAG AA** text contrast (≥ 4.5:1). White text on `--color-primary` and `--color-secondary` both pass; verify any new role-color backgrounds against intended text color.
- Honor `prefers-color-scheme` on first load; never override a stored user choice automatically.

---


## 11. Automated Triage & Priority Logic

To ensure the most vulnerable homeowners are prioritized, the ARCHR system utilizes an automated triage engine that scans intake data for critical risk factors.

**The Triage Mechanism**

- As applications enter Phase 1 (Intake), the AI scans text fields for qualitative "Red Flags" (e.g., "roof collapse," "exposed wiring," or "no running water").
- The system automatically applies Priority Tags to these records, moving them to the top of the Marketplace dashboard.

**Visual Priority Tags**

- **Safety (Critical)** — Applied to structural, electrical, or habitability hazards. (Pair with `.pill.pill-red` / `--color-danger`.)
- **Energy Saving** — Applied to weatherization needs like insulation or window seals. (Pair with `.pill.pill-amber` / `--color-warning`.)
- **Vulnerable Group** — Flags applications from elderly, disabled, or extremely low-income residents. (Pair with `.pill.pill-blue` / `--color-info`.)

**The Goal**

- The "Robot" reduces administrative friction by pre-sorting the workload.
- This allows Subcontractors to see high-priority "Site Work" immediately and ensures funding is allocated to those in the greatest danger first.

---

## 12. Standardization Status

The following pages **already** consume `css/style.css` and follow this guide:

- `index.html` (Home / Do I Qualify? / Our Partners / Volunteer tabs)
- `dashboard.html` (public Impact Dashboard)
- `dashboard-admin.html`
- `partner-portal.html` (sidebar app shell — replaces the former `dashboard-partner.html` and `softr-rework.html`)

The following pages **do not yet conform** to this system and are scheduled for future alignment. When working on them, prefer extracting their CSS to a partner stylesheet that imports the same `:root` tokens rather than maintaining a parallel design language.

| Page | Current state | Notes |
|---|---|---|
| `discovery_form/discovery-form.html` | Own in-page `<style>`, green-gradient theme, `system-ui` font | Public intake form |
| `view-submissions.php` | Small in-page `<style>` block | Internal admin login + table view |
| `documentation/anchor.html` | Own in-page `<style>`, Inter, soft green/cream | Internal SOP doc |
| `documentation/glossary.html` | No styles attached | Likely needs the main stylesheet linked |
| `intake_code/intake.html` | Own `intake_code/style.css` (self-contained) | Treated as a sub-project; leave for now |

---

## 13. Reference: Live Site (archr.live)

> *Reference values observed on the public live site at **archr.live**. These are not the prototype's tokens — they're recorded here so the prototype's design system can be reconciled against what's already shipped, and so this section can be expanded as more of the live site is audited.*

**Actual colors on website:**

- Header/Footer Background: `#3b3637`
- Header Text: `#fafafa`
- Form Input Box: `#e5e5e5`
- Submit Button Hover: `#625e5f`

*(Section to be expanded with typography, spacing, and component observations from the live site.)*

---

## 14. Contact

For UI/UX design clarifications, brand asset requests, or final interface approvals before deployment, please reach out directly.

**Contact:** Ben Wyatt — bwyatt@ashevillehabitat.org

---

## Appendix: Quick CSS Token Index

The authoritative list lives in `:root` at the top of `css/style.css`. Categories:

- **Brand** — `--color-primary`, `--color-primary-dark`, `--color-secondary`, `--color-canvas-cream`
- **Roles (11)** — `--role-requestor` … `--role-admin` (see §3b)
- **Phases (6)** — `--phase-0-select` … `--phase-5-complete` (see §3c)
- **Semantic** — `--color-success`, `--color-warning`, `--color-danger`, `--color-info`
- **Theme (light/dark swap)** — `--bg-page`, `--bg-surface`, `--bg-surface-alt`, `--color-text`, `--color-text-muted`, `--color-text-inverse`, `--color-border-strong`, `--color-header-bg`, `--color-header-text`, `--color-footer-bg`, `--color-footer-text`
- **Legacy aliases** — `--color-light`, `--color-dark`, `--color-gray`, `--color-border`
- **Typography** — `--font-display`, `--font-sans`, `--fs-xs` … `--fs-3xl`, `--lh-tight`, `--lh-base`
- **Spacing** — `--space-1` … `--space-12`
- **Radii** — `--radius-sm`, `--radius-md`, `--radius-lg`, `--radius-pill`, `--border-radius`
- **Geometry** — `--tap-target` (4rem)
- **Layout** — `--container-max`, `--container-gutter`
- **Effects** — `--shadow-sm`, `--shadow`, `--shadow-lg`, `--transition`
- **Z-index** — `--z-sticky`, `--z-dropdown`, `--z-modal`