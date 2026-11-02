---
document_name: SUPER_ADMINISTRATOR_ROLE_DEFINITION_v1
document_type: Role Definition
version: 1.0
last_updated: 2026-07-15
author: ARCHR Development Team
audience: System Administrators, Developers, IT Support
complexity_level: Advanced
estimated_reading_minutes: 10
tags: [super-admin, system-administration, onboarding, coalition-management, platform-setup]
---

# Super-Administrator Role Summary

## Who They Are

The Super-Administrator is the system-level administrator responsible for the entire ARCHR platform. Unlike Organization Admins who manage a single partner organization, the Super-Admin has visibility and control across ALL organizations in the coalition. This role is closer to IT Support, System Administrator, or Developer—someone who understands the system architecture and can troubleshoot issues, onboard new organizations, and maintain platform integrity.

**Key Distinction:** Organization Admins manage their organization's cases, staff, and data. Super-Admins manage the PLATFORM itself—the organizations, system configuration, and overall health of the system.

## What They Do (Core Responsibilities)

| Responsibility | Description | Frequency |
|----------------|-------------|-----------|
| **System Onboarding** | Set up new organizations, configure their permissions, create initial admin accounts | As needed |
| **Organization Management** | Add, modify, or archive organizations in the coalition | As needed |
| **User Account Management** | Create, modify, or deactivate system-wide user accounts | As needed |
| **System Configuration** | Configure eligibility rules, document templates, task definitions | Ongoing |
| **Data Integrity** | Ensure data consistency across organizations, manage archival processes | Ongoing |
| **Troubleshooting** | Investigate and resolve system issues reported by users | As needed |
| **Audit & Oversight** | Review system logs, monitor usage, ensure compliance | Monthly |
| **Coalition Governance** | Manage coalition structure, partner agreements, program settings | Quarterly |

## What They Need To See (Dashboard)

| Element | What It Shows |
|---------|---------------|
| **System Health** | Overall platform status, uptime, recent errors |
| **Organization Overview** | All organizations in the coalition with key stats |
| **User Activity** | Active users by organization, last login, permission issues |
| **System Configuration** | Current settings, eligibility rules, document templates |
| **Audit Log** | Recent system-wide changes and access events |
| **Onboarding Queue** | Organizations pending setup, pending approvals |
| **Archived Organizations** | Historical data access for departed partners |

## What They Need To Create/Update

| Action | Description |
|--------|-------------|
| **Add Organization** | Onboard a new partner to the coalition |
| **Archive Organization** | Gracefully remove a partner while preserving data |
| **Create System User** | Add Super-Admin or Developer accounts |
| **Configure Eligibility** | Update system-wide eligibility rules |
| **Manage Templates** | Create or update document templates |
| **View Audit Logs** | Review all system changes |
| **Run System Reports** | Generate coalition-wide reports |
| **System Backup** | Trigger or verify system backups |

## Who They Interact With

| Person | Interaction |
|--------|-------------|
| **Organization Admins** | Setup support, troubleshooting, escalations |
| **Developers** | System changes, bug fixes, deployments |
| **Coalition Leadership** | Strategic changes, new partner approvals |
| **IT Support** | Infrastructure, security, backups |
| **External Vendors** | Document generation, cloud storage, APIs |

## What Would Frustrate Them

| Frustration | Why It Matters |
|-------------|----------------|
| No visibility into system health | Can't prevent or diagnose issues |
| Manual organization setup | Takes too long, prone to errors |
| Can't archive organizations cleanly | Data integrity risk |
| Poor audit trails | Can't investigate issues |
| No bulk operations | Repetitive work |
| No test environment | Risk when making changes |

## What's The Impact?

| If They Do Well | If They Don't |
|-----------------|---------------|
| Organizations onboard smoothly | Delays in getting help to homeowners |
| System runs reliably | Outages disrupt operations |
| Data is secure and consistent | Data integrity issues |
| Coalition scales efficiently | Manual work bottlenecks growth |
| Partners trust the platform | Partners leave the coalition |

## Key Permissions

| Permission | Description |
|------------|-------------|
| **SYSTEM_VIEW** | View all system data |
| **SYSTEM_EDIT** | Edit system configurations |
| **ORGANIZATION_CREATE** | Create new organizations |
| **ORGANIZATION_ARCHIVE** | Archive organizations |
| **USER_IMPERSONATE** | Log in as any user (for support) |
| **AUDIT_VIEW** | View all audit logs |
| **CONFIG_EDIT** | Edit system configuration |
| **TEMPLATE_MANAGE** | Manage document templates |
| **ROLE_EDIT** | Create or modify roles |
| **BACKUP_TRIGGER** | Trigger system backups |

---

## Initial Assumptions to Validate

- [ ] Super-Admin has access to ALL organizations
- [ ] Can view ALL audit logs
- [ ] Can impersonate users for support
- [ ] Can create new organizations
- [ ] Can archive organizations (soft delete)
- [ ] Can configure system-wide settings
- [ ] Can manage all document templates
- [ ] Can trigger backups
- [ ] Can view system health metrics
- [ ] Should have separate production and test environments

---