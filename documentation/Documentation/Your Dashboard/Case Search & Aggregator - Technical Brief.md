---
document_name: CASE_SEARCH_AGGREGATOR_TECHNICAL_BRIEF
document_type: Technical Specification
version: 1.0
last_updated: 2026-08-07
author: ARCHR Development Team
status: Ready for Implementation
target_completion: Mid-September 2026
---

---

## Executive Summary

The Case Search & Aggregator is a unified interface for finding, viewing, and exporting case records across the ARCHR platform. It replaces the current unreliable Airtable-based search with a dedicated front-end that abstracts the database complexity and provides role-appropriate data visibility.

**Priority:** Highest — Reliable case retrieval is the primary user pain point.

**Timeline:** 5 weeks to MVP.

---

## User Needs

|User Pain Point|How This Feature Addresses It|
|---|---|
|"I can't find cases reliably"|Consistent, fast search with multiple search strategies|
|"I have to use too many filters"|Smart search that works with partial inputs|
|"I don't know which view to use"|One search interface, role-appropriate results|
|"I need to export data"|Built-in CSV/Excel export with aggregator|
|"I can't see what I'm supposed to see"|Role-based visibility (Level 0-3)|

---

## Feature Overview

### Two Entry Points

|Entry Point|Location|Purpose|
|---|---|---|
|**Quick Search**|Header of every dashboard (Level 1-3)|Fast lookup by case number, address, or name|
|**Case Search Page**|Navigation menu → "Case Search"|Full search with filters + aggregator export|

### Core Capabilities

|Capability|Description|
|---|---|
|**Search by**|Placecode (exact or partial), homeowner name, township, ZIP code, organization, progress phase|
|**Filter by**|Organization (claimed/unclaimed), progress phase, date range, status|
|**View results**|Table view with sortable columns|
|**Export results**|CSV or Excel export of filtered results|
|**Role-based visibility**|Data redaction based on user permission level|

---

## Role-Based Visibility (Permission Levels)

|Level|Role|Data Visibility|
|---|---|---|
|**0**|Volunteer, Requestor, Crew Member|Feature fully disabled|
|**1**|Office Worker (Caseworker, Assessor, Subcontractor)|Most sensitive information redacted (SSN, full financials)|
|**2**|Organizational Admin (Admin, Project Manager, Bursar, Crew Lead)|Full case data, except contact info redacted if case not claimed by their organization|
|**3**|Super-Administrator|Everything—full access to all data|

### Data Redaction Rules

|Data Type|Level 1|Level 2|Level 3|
|---|---|---|---|
|Case number|✅ Visible|✅ Visible|✅ Visible|
|Homeowner name|✅ Visible|✅ Visible|✅ Visible|
|Address|✅ Visible|✅ Visible|✅ Visible|
|Contact phone|❌ Redacted|⚠️ Org-only|✅ Visible|
|Contact email|❌ Redacted|⚠️ Org-only|✅ Visible|
|Income data|⚠️ Summarized|✅ Visible|✅ Visible|
|Funding details|⚠️ Summarized|✅ Visible|✅ Visible|
|Internal notes|❌ Hidden|❌ Hidden|✅ Visible|
|SSN/ID numbers|❌ Redacted|❌ Redacted|✅ Visible|

---

## Search Interface Specifications

### Quick Search (Header)

text

┌─────────────────────────────────────────────────────────────────────────────────┐
│  [🔍] Search by case number, address, or name...                     [Search]  │
└─────────────────────────────────────────────────────────────────────────────────┘

|Element|Specification|
|---|---|
|**Input**|Free-text field; accepts case number, placecode, address fragment, or name fragment|
|**Search trigger**|Enter key OR click Search button|
|**Results**|Direct navigation to case detail view (if single result) OR results table|
|**Placeholder**|"Search by case number, address, or name..."|
|**Available to**|Level 1, 2, 3|

### Advanced Search Page

text

┌─────────────────────────────────────────────────────────────────────────────────┐
│  🔎 Case Search                                                                 │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  Search Term: [________________________________________________] [🔍 Search]    │
│                                                                                  │
│  Filters:                                                                        │
│  ┌─────────────────────────────────────────────────────────────────────────────┐│
│  │ Organization: [All Organizations ▼]   Status: [All Statuses ▼]             ││
│  │ Phase: [All Phases ▼]                 Date Range: [Start] — [End]          ││
│  │ ZIP Code: [____________]              Claimed: [All ▼]                     ││
│  └─────────────────────────────────────────────────────────────────────────────┘│
│                                                                                  │
│  Results: (24 found)                                          [Export CSV]      │
│  ┌─────────────────────────────────────────────────────────────────────────────┐│
│  │ Case # │ Homeowner │ Address     │ Org │ Status │ Phase │ Last Updated     ││
│  ├────────┼───────────┼─────────────┼─────┼────────┼───────┼──────────────────┤│
│  │ 001234 │ J. Smith  │ 42 Cherry St│ HFH │ Active │ Phase3│ Dec 15, 2024     ││
│  │ 001189 │ S. Williams│15 Merrill  │ CHC │ Active │ Phase2│ Dec 14, 2024     ││
│  │ 001103 │ J. Thornton│8 Oakland  │ MHO │ Closed │ Phase6│ Dec 10, 2024     ││
│  └─────────────────────────────────────────────────────────────────────────────┘│
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘

### Search Fields

|Field|Type|Source|Level|
|---|---|---|---|
|**Search Term**|Free text|Case number, name, address|All (1-3)|
|**Organization**|Dropdown|`coalition_organizations`|All (1-3)|
|**Status**|Dropdown|`case_statuses`|All (1-3)|
|**Phase**|Dropdown|6 phases (0-5)|All (1-3)|
|**Date Range**|Date picker|`submitted_at`|All (1-3)|
|**ZIP Code**|Text|`home_zip`|All (1-3)|
|**Claimed**|Dropdown|All / Claimed / Unclaimed|All (1-3)|

### Result Columns

|Column|Level 1|Level 2|Level 3|
|---|---|---|---|
|Case Number|✅|✅|✅|
|Homeowner|✅|✅|✅|
|Address|✅|✅|✅|
|Phone|❌|⚠️|✅|
|Organization|✅|✅|✅|
|Status|✅|✅|✅|
|Phase|✅|✅|✅|
|Last Updated|✅|✅|✅|
|Contact Info|❌|⚠️|✅|
|Funding Summary|⚠️|✅|✅|

---

## Export/Aggregator Feature

### Specifications

|Element|Description|
|---|---|
|**Export Format**|CSV (default), Excel (.xlsx) optional|
|**Export Scope**|All currently displayed/filtered results|
|**Data Included**|All visible data for the user's permission level|
|**Trigger**|Button: "Export Results"|
|**Filename**|`cases_export_YYYY-MM-DD.csv`|

### Export Fields (Level 2+)

|Field|Description|
|---|---|
|`case_number`|Unique case identifier|
|`applicant_first_name`|First name|
|`applicant_last_name`|Last name|
|`home_address`|Full address|
|`home_city`|City|
|`home_zip`|ZIP code|
|`assigned_organization`|Organization handling case|
|`case_status`|Current status|
|`phase`|Current phase (0-5)|
|`submitted_at`|Date submitted|
|`funding_approved`|Total approved funding|
|`funding_spent`|Amount spent to date|
|`funding_remaining`|Remaining balance|
|`last_updated`|Last status change|

---

## Technical Implementation

### Database Integration (Three-Tier Plan)

text

┌──────────────────────────────────────────────────────────┐
│                    DATABASE INTEGRATION PATH                                    │
├──────────────────────────────────────────────────────────┤
│                                                                                                          │
│  TIER 1: PostgreSQL on Webhost (Current Block)                            │
│  ┌────────────────────────────────  ────────────────────┐   │
│  │  • PostgreSQL running (old version)                                       │   │
│  │  • Need pgcrypto enabled for user authentication                 │   │
│  │  • CPanel permissions issue blocking schema upload             │   │
│  │  • Workaround needed: pgcrypto via alternative method        │   │
│  └──────────────────────────────────────────────────────┘   │
│                                   │                                             │
│                                   ▼                                             │
│  TIER 2: Airtable Dummy Database (Bridge)                                      │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  • Connect to Airtable test base                                               │   │
│  │  • Test search functionality with dummy data                          │   │
│  │  • Validate field mappings and search logic                            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                   │                                             │
│                                   ▼                                             │
│  TIER 3: Live Airtable (Production)                                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Connect to production Airtable base                                 │   │
│  │  • Consistent field naming across Airtable and front-end       │   │
│  │  • Deploy to production                                                │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘

### Search Implementation

sql

-- Simplified search query (PostgreSQL)
SELECT 
    s.case_number,
    s.applicant_first_name,
    s.applicant_last_name,
    s.home_address,
    s.home_city,
    s.home_zip,
    s.assigned_organization,
    s.submission_status,
    s.submitted_at,
    c.total_budget AS funding_approved,
    c.total_actual_cost AS funding_spent,
    (c.total_budget - c.total_actual_cost) AS funding_remaining
FROM intake_submissions s
LEFT JOIN cases c ON s.id = c.submission_id
WHERE 
    s.case_number ILIKE '%' || :search_term || '%'
    OR s.applicant_first_name ILIKE '%' || :search_term || '%'
    OR s.applicant_last_name ILIKE '%' || :search_term || '%'
    OR s.home_address ILIKE '%' || :search_term || '%'
    OR s.home_zip = :search_term
    AND (:organization IS NULL OR s.assigned_organization = :organization)
    AND (:status IS NULL OR s.submission_status = :status)
    AND (:phase IS NULL OR s.current_phase = :phase)
    AND (:zip IS NULL OR s.home_zip = :zip)
ORDER BY s.submitted_at DESC
LIMIT 100;

### Airtable Field Mapping

|Front-End Label|Airtable Field|Notes|
|---|---|---|
|Case Number|`case_number`|Text|
|First Name|`app_first_name`|Text|
|Last Name|`app_last_name`|Text|
|Address|`home_address`|Text|
|City|`home_city`|Text|
|ZIP|`home_zip`|Text|
|Organization|`assigned_organization`|Linked record|
|Status|`submission_status`|Single select|
|Phase|`current_phase`|Number (0-5)|
|Submitted|`submitted_at`|Date|
|Funding Approved|`funding_approved`|Currency|
|Funding Spent|`funding_spent`|Currency|

---

## User Permissions in the Search

php

// Simplified permission check
function getSearchResults($searchTerm, $filters, $userLevel, $userOrg) {
    $results = queryDatabase($searchTerm, $filters);
    
    foreach ($results as &$case) {
        switch ($userLevel) {
            case 1:
                // Office Worker: Redact sensitive fields
                $case->phone = '***';
                $case->email = '***';
                $case->income = '***';
                break;
            case 2:
                // Org Admin: Redact contact if not their org
                if ($case->assigned_organization !== $userOrg) {
                    $case->phone = '***';
                    $case->email = '***';
                }
                break;
            case 3:
                // Super-Admin: Full visibility
                break;
        }
    }
    
    return $results;
}

---

## User Support Documentation

### 1. Quick Start Guide (1 page)

> _"How to find a case in 3 clicks"_

### 2. Search Tips

- You can search by partial case number (e.g., "1234" finds "ARCHR-2024-001234")
- You can search by street name (e.g., "Cherry" finds "42 Cherry St")
- Use filters to narrow down results by organization, status, or phase
- The "Export" button downloads all visible results as CSV

### 3. Role-Based Visibility Guide

> _"What can you see at your permission level?"_

- Level 1: You can see case details but sensitive information is redacted
- Level 2: You can see full case details for cases claimed by your organization
- Level 3: You can see everything

---

## Success Criteria

### By Mid-September

- □ PostgreSQL connection working on webhost
- □ Search connected to Airtable dummy data
- □ Search connected to live Airtable
- □ Quick search in header (Level 1-3)
- □ Advanced search page with filters
- □ Role-based visibility implemented
- □ Export to CSV working
- □ Three support documents published
- □ 5 user testers have validated functionality
---

## Timeline (5 Weeks)

|Week|Focus|Milestones|
|---|---|---|
|**Week 1**|PostgreSQL webhost|Fix pgcrypto/permissions; test connection|
|**Week 2**|Airtable dummy integration|Connect search to dummy data; test search logic|
|**Week 3**|Live Airtable integration|Field mapping; test with real data|
|**Week 4**|UI polish + permissions|Quick search, advanced search, role-based visibility|
|**Week 5**|Export + docs|CSV export; support documents; user testing|

---

## Risk Assessment

|Risk|Impact|Mitigation|
|---|---|---|
|PostgreSQL permissions remain blocked|High|Use Airtable direct connection as fallback|
|Field mapping inconsistencies|Medium|Document all fields; test thoroughly|
|Performance with large dataset|Medium|Implement pagination; limit results|
|Role-based visibility bugs|High|Test with each role level|
|User testing participation|Medium|Proactively reach out to potential testers|

---

## Next Steps

1. **Unblock PostgreSQL on webhost** — This is the critical path item
2. **Set up Airtable dummy base** — Copy of production structure
3. **Build search prototype** — Connected to dummy data
4. **Schedule user testing** — Recruit 5 testers by end of Week 3
5. **Deploy** — Mid-September target