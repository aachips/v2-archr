document_name: VOLUNTEER_EXPERIENCE_SOP_v1
document_type: Standard Operating Procedure
version: 1.0
last_updated: 2024-12-09
author: ARCHR Development Team
contributors: Product Team, Volunteer Coordinators
status: Draft
review_date: 2025-01-15
audience: Volunteers, Crew Leads, Project Managers, System Administrators
complexity_level: Beginner to Intermediate
estimated_reading_minutes: 15
tags: [volunteers, gamification, task-management, quests, reputation]
---

# Volunteer Experience Standard Operating Procedure
## Game-Like Digital Participation Platform for ARCHR Coalition

### Document Purpose

This SOP defines the volunteer-facing interface of the ARCHR platform, designed as an engaging, game-like experience that encourages participation, skill development, and community building. Unlike traditional corporate portals, this system treats volunteer activities as "quests," contributions as "achievements," and community feedback as "reputation."

---

## Table of Contents

1. [Core Philosophy & Design Principles](#core-philosophy)
2. [Volunteer Interface Overview](#interface-overview)
3. [Quest System (Task Library)](#quest-system)
4. [Communication & Content Features](#communication-features)
5. [Hour Tracking & Photo Documentation](#hour-tracking)
6. [Task Claiming System](#task-claiming)
7. [Reputation & Trust Credit System](#reputation-system)
8. [Technical Requirements & Data Schema](#technical-requirements)
9. [User Stories & Workflows](#user-stories)
10. [Future Roadmap](#roadmap)

---

## Core Philosophy & Design Principles {#core-philosophy}

### Design Tenets

| Principle | Description | Implementation |
|-----------|-------------|----------------|
| **Joyful Participation** | Volunteers should feel rewarded, not monitored | XP points, badges, level-ups |
| **Clear Progression** | Visible path from novice to expert | Skill trees, role advancement |
| **Social Connection** | Community matters more than tasks | Team quests, helper ratings |
| **Low Friction** | Mobile-first, minimal clicks | One-tap task claiming, quick photo uploads |
| **Meaningful Impact** | Show how work helps real people | Before/after photos, thank-you messages |

### Role Definition

**Volunteer** - An unpaid participant who contributes time, skills, or labor to ARCHR repair projects. Volunteers may:
- Claim and complete individual tasks
- Join team-based projects
- Earn reputation through quality work
- Advance to specialized roles (Crew Member, Envoy, etc.)

---

## Volunteer Interface Overview {#interface-overview}

### Dashboard Layout



### Navigation Elements

| Element | Description | Gamification |
|---------|-------------|--------------|
| **Quest Log** | Task library with filters | "Adventure Journal" |
| **XP Bar** | Experience points toward next level | Level unlocks new abilities |
| **Reputation Meter** | Trust score (0-1000) | "Community Standing" |
| **Notification Bell** | Updates, messages, achievements | "Town Crier" |
| **Profile Avatar** | Customizable character | Unlockable accessories |
| **Help Center** | SOPs, tutorials, FAQs | "Training Grounds" |

---

## Quest System (Task Library) {#quest-system}

### Task Hierarchy

EPIC QUEST (Project Level)  
├── Main Storyline: Complete house repair  
│ ├── SIDE QUEST: Roof tarping (2 hrs)  
│ ├── SIDE QUEST: Debris removal (1 hr)  
│ ├── SIDE QUEST: Material transport (30 min)  
│ └── BOSS QUEST: Quality inspection (requires Crew Lead)  
│  
DAILY QUESTS (Repeatable)  
├── Morning Briefing (5 XP) - Check notifications  
├── Photo Upload (10 XP) - Share before/after shots  
├── Buddy System (15 XP) - Help another volunteer  
└── Feedback Friday (20 XP) - Rate completed tasks

text

### Quest Properties
| Property | Type | Description | Example |
|----------|------|-------------|---------|
| **quest_id** | UUID | Unique identifier | `qst_abc123` |
| **title** | String | Display name | "Roof Tarping at Cherry St" |
| **description** | Text | Instructions, tools needed | "Bring ladder, tarp, hammer" |
| **quest_type** | Enum | category | `repair`, `delivery`, `cleanup`, `training`, `social` |
| **difficulty** | 1-5 | Estimated complexity | 2 (Moderate) |
| **xp_reward** | Integer | Experience points | 50 |
| **reputation_reward** | Integer | Trust credit points | 10 |
| **estimated_hours** | Decimal | Time expectation | 2.0 |
| **required_skills** | Array | Skill tags | `[ladder_safety, roofing]` |
| **required_level** | Integer | Minimum volunteer level | 3 |
| **max_volunteers** | Integer | Team size limit | 3 |
| **current_volunteers** | Integer | Already claimed | 1 |
| **quest_giver** | String | Who posted | "Project Manager: Jamie" |
| **location** | String | Address | "42 Cherry St, Asheville" |
| **status** | Enum | `available`, `in_progress`, `completed`, `expired` |
| **expires_at** | Timestamp | Auto-remove after date | 2024-12-15 |
| **parent_quest_id** | UUID | For multi-step quests | `qst_abc122` (epic) |
### Quest Filters & Discovery
```sql
-- Volunteers see quests based on:
-- 1. Their skill level (required_level <= volunteer_level)
-- 2. Geographic proximity (within 25 miles)
-- 3. Time availability (not expired)
-- 4. Skill matching (any required_skills in their skill set)
-- 5. Team capacity (max_volunteers > current_volunteers)
SELECT * FROM quests q
WHERE q.status = 'available'
  AND q.required_level <= (SELECT level FROM volunteer_profiles WHERE user_id = $1)
  AND q.expires_at > NOW()
  AND (
    SELECT COUNT(*) FROM UNNEST(q.required_skills) skill
    WHERE skill = ANY(SELECT skill FROM volunteer_skills WHERE user_id = $1)
  ) > 0
ORDER BY q.recommendation_score DESC;