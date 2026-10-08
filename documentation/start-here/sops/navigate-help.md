---
document_name: How to Use This Help Library
document_type: User Guide
version: 1.0
last_updated: 2026-09-07
author: ARCHR Development Team
audience: All Platform Users
complexity_level: Beginner
estimated_reading_minutes: 3
tags: [help, navigation, documentation, user-guide]
---

# How to Use the ARCHR Help Library

> **Who this is for:** Everyone. If you're using the platform, this help system is for you.

## What This Is

The ARCHR Help Library is a collection of guides, SOPs, and reference documents built into the platform. It's organized by topic and role, so you can find what you need without wading through irrelevant material.

**Think of it as the platform's instruction manual.** Except one you can search, and the index updates itself.

---

## How to Get Here

- From anywhere in the app, click **Help** in the navigation
- Or go directly to `help.php`
- If you're not logged in, you can still see public documents (marked with a 🔓 icon)

---

## How It's Organized

### By Category

| Category | Who It's For | What You'll Find |
|----------|-------------|------------------|
| **Start Here** | Everyone | Welcome, overview, orientation |
| **ARCHR 101** | Everyone | How the system works, eligibility, funding |
| **Setting Up** | New coalitions | How to start a regional home repair program |
| **Technical Guides** | All users | Account setup, intake process, privacy |
| **SOPs** | Logged-in users | Step-by-step procedures for every role |
| **Roles & Access** | Logged-in users | Who can do what, permission levels |
| **Funding & Costs** | Everyone | Where the money comes from and how it flows |
| **Platform Anatomy** | Admins, Developers | Technical architecture, data flow |
| **For Developers** | Admins, Developers | Schema, code, deployment |
| **Coalition Feedback** | Logged-in users | Partner input, pain points, improvement plans |

### By Visibility

| Visibility | Who Can See It | Icon |
|-----------|---------------|------|
| **Public** | Anyone, even without an account | 🔓 |
| **Authenticated** | Any logged-in user | 🔐 |
| **Restricted** | Specific roles only | 🔒 |

---

## How to Find What You Need

### 1. Browse by Category

The left sidebar shows all categories and the documents in each. Click a category to expand it, then click a document title to read it.

### 2. Search

Use the search box at the top of the sidebar. Type any keyword — role name, topic, feature — and matching documents appear.

### 3. Prev/Next Navigation

At the bottom of each document, you'll find links to the previous and next documents in the same category. Great for reading through a whole section.

### 4. Cross-References

Documents link to related documents. If you're reading about assessments and need to know about document types, there's probably a link.

---

## How to Read These Documents

### SOPs (Standard Operating Procedures)

SOPs follow a consistent format:
1. **Who this is for** — the target audience
2. **Why this matters** — the context and stakes
3. **Step-by-step instructions** — numbered or bulleted procedures
4. **Quick reference** — a table of actions, locations, and who does them
5. **Common scenarios** — real-world examples and edge cases

### Technical Guides

These go deeper into how things work under the hood. They may include:
- Database diagrams
- Code snippets
- Architecture explanations
- Deployment instructions

### User Guides

These explain how to use specific features. They tend to be shorter and more task-oriented.

---

## Troubleshooting & FAQ

### "I Forgot My Password"
Contact your organization's Admin or the Super Admin. There is no self-service password reset yet — we're building it.

### "I Can't See a Case I Know Exists"
Check your permissions. Cases are scoped to your organization unless you're an Admin or Super Admin. If you should have access but don't, contact your Admin.

### "The System Says I Don't Have Permission"
Your role determines what you can see and do. If you need different permissions, ask your Admin to adjust your role.

### "Email Notifications Aren't Arriving"
Check your spam folder. If they're not there, contact the Super Admin — the notification system may need attention.

### "How Do I Request a New Feature or Report a Bug?"
Contact the Super Admin. Bug reports and feature requests are tracked and prioritized by the development team.

### "The System Is Down"
If the platform is unavailable, contact your organization's Admin or the Super Admin. They'll have the most current status and estimated resolution time.

---

## How This Library Is Built

The help library is generated from markdown files in the `documentation/start-here/` directory. Each file needs a YAML frontmatter block at the top to be included. The generator (`app/generate-help-docs.php`) scans for files with frontmatter, converts them to HTML, and builds the navigation index.

**If you want to contribute documentation:** Write it in markdown with the standard frontmatter format, place it in the appropriate subfolder of `documentation/start-here/`, and ask an Admin to regenerate the library.

---

**Remember:** If you can't find what you're looking for here, ask your Admin. If they can't help, the Super Admin is the next escalation point.
