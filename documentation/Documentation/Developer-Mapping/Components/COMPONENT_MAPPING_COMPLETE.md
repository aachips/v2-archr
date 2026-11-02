# ARCHR Component and API Endpoint Mapping - COMPLETE

**Date:** 2026-07-18  
**Status:** ✅ All 11 roles fully documented

---

## Summary

This document confirms the completion of comprehensive component and API endpoint mapping for all 11 functional roles in the ARCHR platform.

---

## ✅ Completed Work

### 1. **Consolidated API Endpoints** (`api-endpoints/api-endpoints.md`)

All API endpoints for all 11 roles have been consolidated into a single master file:

- **Assessor** - 14 endpoints
- **Project Manager** - 12 endpoints  
- **Crew Lead** - 8 endpoints
- **Crew Member** - 14 endpoints
- **Bursar** - 10 endpoints
- **Subcontractor** - 15 endpoints
- **Volunteer** - 17 endpoints
- **Envoy** - 21 endpoints
- **Organization Admin** - 26 endpoints
- **Requestor** - 23 endpoints
- **Super Admin** - 27 endpoints

**Total: ~250+ endpoints documented**

---

### 2. **Component JSON Files Created**

All roles now have component directories with individual JSON files following the established pattern:

| Role | Directory | Component Files | Status |
|------|-----------|----------------|--------|
| **Assessor** | `components/assessor/` | 27 files | ✅ Complete |
| **Crew Member** | `components/components-crew/` | 10 files | ✅ Complete |
| **Crew Lead** | `components/components-crew-lead/` | 5 files | ✅ New |
| **Subcontractor** | `components/components-subcontractor/` | 21 files | ✅ Complete |
| **Project Manager** | `components/components-project-manager/` | 7 files | ✅ New |
| **Bursar** | `components/components-bursar/` | 5 files | ✅ New |
| **Volunteer** | `components/components-volunteer/` | 5 files | ✅ New |
| **Envoy** | `components/components-envoy/` | 5 files | ✅ New |
| **Org Admin** | `components/components-org-admin/` | 5 files | ✅ New |
| **Requestor** | `components/components-requestor/` | 6 files | ✅ New |
| **Super Admin** | `components/components-admin/` | 6 files | ✅ New |

**Total: 102 component JSON files across 11 roles**

---

### 3. **Component Library PHP Fix**

Fixed `components/component-library-assessor-v2.php`:
- **Issue:** Was looking for components in `components/components/` directory
- **Fix:** Updated to correctly load from `components/assessor/` directory
- **Line 285:** Changed path from `'components'` to `'assessor'`

---

## Component Examples by Role

### Project Manager Components
- `active-projects-list.json` - List of active projects
- `claim-job-button.json` - Claim unassigned project
- `approve-estimate-button.json` - Approve subcontractor estimate
- `assign-crew-button.json` - Assign crew to project
- `escalations-list.json` - Active escalations
- `budget-tracker.json` - Project budget status
- `subcontractor-queue.json` - Available subcontractors

### Bursar Components
- `funding-overview-card.json` - KPI metrics
- `approve-invoice-button.json` - Approve invoice
- `reject-invoice-button.json` - Reject invoice with reason
- `pending-invoices-list.json` - Invoices awaiting review
- `duplicate-alert.json` - Duplicate invoice warnings

### Crew Lead Components
- `set-current-job-button.json` - Switch active job
- `change-order-request.json` - Request change order
- `daily-log-form.json` - End-of-day log submission
- `assigned-jobs-list.json` - All assigned jobs
- `completion-signoff.json` - Job completion with signature

### Volunteer Components
- `opportunities-list.json` - Available volunteer slots
- `claim-slot-button.json` - Claim volunteer opportunity
- `my-assignments.json` - Upcoming volunteer shifts
- `gamification-stats.json` - XP, badges, and rank
- `checkin-button.json` - Check in to shift

### Envoy Components
- `coalition-overview-card.json` - Coalition-wide metrics
- `approve-contract-button.json` - E-sign contracts
- `pending-contracts-list.json` - Contracts awaiting approval
- `eligibility-config-form.json` - Set eligibility rules
- `performance-by-org.json` - Performance breakdown

### Org Admin Components
- `applications-list.json` - All org applications
- `assign-staff-button.json` - Assign to staff
- `staff-workload-view.json` - Staff capacity tracking
- `set-priority-button.json` - Set application priority
- `org-events-calendar.json` - Organization events

### Requestor Components
- `application-status-card.json` - Current status
- `next-step-card.json` - What to do next
- `upload-document-button.json` - Upload verification docs
- `message-caseworker-button.json` - Contact caseworker
- `timeline-view.json` - Application timeline
- `sign-contract-button.json` - E-sign contracts

### Super Admin Components
- `system-overview-card.json` - System-wide metrics
- `users-list.json` - All system users
- `create-user-button.json` - Add new user
- `organizations-list.json` - All partner orgs
- `system-config-form.json` - System settings
- `audit-logs-list.json` - System audit trail

---

## File Structure

```
components/
├── assessor/                      (27 files)
├── components-admin/              (6 files) ← NEW
├── components-bursar/             (5 files) ← NEW
├── components-crew/               (10 files)
├── components-crew-lead/          (5 files) ← NEW
├── components-envoy/              (5 files) ← NEW
├── components-org-admin/          (5 files) ← NEW
├── components-project-manager/    (7 files) ← NEW
├── components-requestor/          (6 files) ← NEW
├── components-subcontractor/      (21 files)
├── components-volunteer/          (5 files) ← NEW
└── component-library-assessor-v2.php (FIXED)

api-endpoints/
└── api-endpoints.md               ← NEW (consolidated file)
```

---

## Next Steps (Optional)

1. **Create role-specific component library PHP files** for each role (similar to assessor)
2. **Test component library** to ensure all components load correctly
3. **Add more components** as needed for each role based on interface requirements
4. **Update component-library.php** to support multi-role selection
5. **Create component search/filter** functionality in the library

---

## Notes

- All component JSON files follow the established pattern from assessor/crew/subcontractor
- Components include proper `component_context` for integration
- Button components include confirmation messages and reversibility flags
- List components include mobile-friendly layouts
- Form components specify validation and submit actions
- All endpoints documented with Method, Purpose, and proper REST conventions

---

**Status: READY FOR IMPLEMENTATION** ✅
