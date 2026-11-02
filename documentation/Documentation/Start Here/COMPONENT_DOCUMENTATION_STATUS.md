---
document_name: Component Documentation Status Tracker
document_type: Status Report
version: 1.0
last_updated: 2026-08-01
author: ARCHR Development Team
audience: Developers, Admins
complexity_level: Intermediate
estimated_reading_minutes: 5
tags: [components, documentation, status, tracking]
visibility: ["admin", "super-admin"]
---

# Component Documentation Status

## Overview

This document tracks the status of component documentation across all roles. Each role should have component JSON files that match the pattern established in the best-documented roles.

---

## ✅ Completed API Endpoint Documentation

All roles now have comprehensive API endpoint documentation in `interface/api-endpoints/`:

- ✅ **Assessor** (`assessor-api-endpoints.md`) - 75 endpoints documented
- ✅ **Project Manager** (`pm-api-endpoints.md`) - 115 endpoints documented
- ✅ **Crew Lead & Member** (`crew-api-endpoints.md`) - 113 endpoints documented
- ✅ **Bursar** (`bursar-api-endpoints.md`) - 73 endpoints documented
- ✅ **Volunteer** (`volunteer-api-endpoints.md`) - 60 endpoints documented
- ✅ **Envoy** (`envoy-api-endpoints.md`) - 53 endpoints documented
- ✅ **Org Admin** (`org-admin-api-endpoints.md`) - 86 endpoints documented
- ✅ **Requestor** (`requestor-api-endpoints.md`) - 48 endpoints documented
- ✅ **Subcontractor** (`api-endpoints-subcontractor.md`) - Already existed

**Total: ~600+ API endpoints documented**

---

## Component JSON Documentation Status

### ✅ Well-Documented (Has component_context)

**Assessor** (`components/components-assessor/`)
- 24 component JSON files
- All have proper structure
- Good use of `component_context` in button components
- Examples: `assess-button.json`, `doc-verification.json`, `verify-income-button.json`

**Subcontractor** (`components/components-subcontractor/`)
- 20 component JSON files
- Consistent `component_context` pattern
- Button components well-defined
- Examples: `claim-task-button.json`, `submit-invoice-button.json`

**Crew** (`components/components-crew/`)
- 10 component JSON files
- Good mobile-first documentation
- Examples: `safety-talk.json`, `upload-photos.json`, `volunteer-management.json`

### ⏳ Partially Documented (Needs Enhancement)

**Bursar** (`interface/bursar/`)
- Has `bursar-components.json` (comprehensive role documentation)
- Has 2 component files in `interface/bursar/components/`
- **TODO**: Create individual button components with `component_context` in `components/components-bursar/`

### ❌ Not Yet Documented

**Project Manager** (`components/components-project-manager/`)
- **TODO**: Create directory and component files
- Key components needed:
  - Claim job button
  - Approve estimate button
  - Assign crew button
  - Escalation buttons
  - Project status components
  - Budget tracking components

**Crew Lead** (`components/components-crew-lead/`)
- **TODO**: Create directory and component files
- Key components needed:
  - Set current job button
  - Update task status button
  - Change order request button
  - Daily log component
  - Safety talk component
  - Completion sign-off button

**Volunteer** (`components/components-volunteer/`)
- **TODO**: Create directory and component files
- Key components needed:
  - Claim slot button
  - Sign in/out buttons
  - Available opportunities list
  - Assignment cards
  - Experience/gamification components

**Envoy** (`components/components-envoy/`)
- **TODO**: Create directory and component files
- Key components needed:
  - New applications list
  - Assign application button
  - Contact applicant button
  - Outreach event components
  - Follow-up task components

**Org Admin** (`components/components-org-admin/`)
- **TODO**: Create directory and component files
- Key components needed:
  - User management buttons
  - Settings components
  - Organization management
  - System configuration components

**Requestor** (`components/components-requestor/`)
- **TODO**: Create directory and component files
- Key components needed:
  - Application status component
  - Document upload button
  - Message caseworker button
  - Timeline component
  - Eligibility results display

---

## Component Standards

### Button Component Template with `component_context`

```json
{
  "component_name": "Button Name",
  "component_role": "role_name",
  "component_id": "btn_unique_id",
  "component_class": ".btn.btn-primary",
  "component_context": {
    "taskId": "rec[taskIdentifier]",
    "target": "data.field",
    "target_key": "{variable}.{field}",
    "action": "ACTION.TYPE",
    "buttonText": "Button Label",
    "webhookSlug": "[webhookIdentifier]",
    "confirm": "Confirmation message?",
    "successMessage": "Success message!",
    "reversible": "yes/no"
  }
}
```

### List Component Template

```json
{
  "component_name": "List Name",
  "component_id": "cmp_list_id",
  "component_type": "list",
  "data_sources": {
    "items": "table_name where condition"
  },
  "list_item_actions": [
    {
      "label": "Action Label",
      "action": "navigate/phone/email/etc",
      "target": "/path/{param}"
    }
  ],
  "sort_order": "field ASC/DESC",
  "mobile_layout": "cards/list/table"
}
```

---

## Next Steps

1. **Create component directories** for missing roles
2. **Document button components** with `component_context` following assessor/subcontractor patterns
3. **Document list/display components** for each role's main views
4. **Standardize existing components** to match best practices
5. **Cross-reference with API endpoints** to ensure consistency

---

## Reference Files

**Best Examples:**
- `components/components-assessor/doc-verification.json` - Button with full context
- `components/components-subcontractor/claim-task-button.json` - Clean button pattern
- `components/components-assessor/todays-assessments.json` - List component
- `interface/bursar/bursar-components.json` - Comprehensive role documentation

**Templates:**
- `components/template.json` - Basic template
- `components/example.json` - Component type reference

---

## Component Types Available

`BUTTON`, `LIST`, `LIST_ITEM`, `DETAILS`, `TABLE`, `ALERT`, `TOOL_TIP`, `INBOX`, `INBOX_MESSAGE`, `FORM`, `CONFIRM_PROMPT`, `METRIC_NUM`, `METRIC_LINE`, `METRIC_PIE`, `PROGRESS_BAR`, `PROGRESS_TASKS`, `PROJECT_TASKS`, `VERIFICATION_TASKS`, `GRID`, `GRID_ITEM`, `PROJECT_SUMMARY`, `DOCUMENT_DISPLAY`, `CALENDAR`, `CALENDAR_EVENT`, `ORGANIZATION`, `PARTNER_PROGRAM`, `PERSON`, `REPORT`, `ROLE`, `HEADS_UP_DISPLAY`
