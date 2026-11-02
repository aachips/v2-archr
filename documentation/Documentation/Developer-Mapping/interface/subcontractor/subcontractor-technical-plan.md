  "document_name": "SUBCONTRACTOR_ROLE_TECHNICAL_BLUEPRINT_v1",
  "document_type": "Technical Specification",
  "version": "1.0",
  "last_updated": "2024-12-18",
  "author": "ARCHR Development Team",
  "contributors": "Product Owner, UX Designer, Database Architect",
  "status": "Draft for Review",
  "review_date": "2024-12-23",
  "audience": "Developers, UX/UI Designers, Subcontractor Role Stakeholders",
  "complexity_level": "Advanced",
  "estimated_reading_minutes": 25,
  "tags": ["subcontractor", "trade", "task-management", "job-claiming", "invoicing"]

---


### Component 1: Accepted Tasks List

**Purpose:** Show all tasks this subcontractor has claimed and is working on

|Column|Data Source|Display|
|---|---|---|
|Job Code|`work_tasks.job_code`|Placecode (e.g., 42-CHERRY)|
|Subtasks|`work_tasks.subtasks`|X/Y complete (e.g., 3/5)|
|Todo Tasks|`work_tasks.todo_list`|Remaining tasks list|
|Status|`work_tasks.status`|Visual indicator|
|Action|-|Update Status button|

**JSON Component Definition:**



### Component 2: Suggested Tasks List

**Purpose:** Show available tasks matching this subcontractor's trade

|Column|Data Source|Display|
|---|---|---|
|Job Code|`work_tasks.job_code`|Placecode|
|Subtasks|`work_tasks.subtasks`|X/Y complete (usually 0)|
|Type|`work_tasks.task_type`|Trade category|
|Est. Hours|`work_tasks.estimated_hours`|Duration estimate|
|Action|-|Claim Task button|


# SUBCONTRACTOR ROLE DEFINITION

## Who Are They?

| Attribute | Description |
|-----------|-------------|
| **Job Title** | Electrician / Plumber / Roofer / Specialty Trade |
| **Department** | External Contractor |
| **Technical Comfort** | Low to Medium |
| **Work Location** | Field (job sites) |
| **Client Interaction** | Direct - works in client homes |

## What They Need To Do

| Priority | Task | Frequency |
|----------|------|-----------|
| **P0** | Claim available tasks | As needed |
| **P0** | Update task status | Daily during active jobs |
| **P1** | Submit quotes | Per job |
| **P1** | Submit invoices | Per job |
| **P1** | Upload after photos | Per job |
| **P2** | Set work dates | Per job |
| **P2** | Communicate with PM | As needed |

## What They Need To See (Dashboard)

| Element | What It Shows |
|---------|---------------|
| **Accepted Tasks** | Their current active jobs |
| **Suggested Tasks** | Available tasks matching their trade |
| **Messages** | Unread communications |
| **Task Details** | Full task information when viewing |

## What They Need To Create/Update

| Action | Description |
|--------|-------------|
| **Claim Task** | Accept an available task |
| **Update Status** | Progress tracking |
| **Set Dates** | Estimate, start, finish dates |
| **Send Quote** | Submit cost estimate |
| **Submit Invoice** | Request payment |
| **Upload Photos** | After completion documentation |
| **Alert Sub Accepted** | Notify system of acceptance |

## Who They Interact With

| Person | Interaction |
|--------|-------------|
| **Project Manager** | Primary ARCHR contact |
| **Bursar** | For invoice questions |
| **Client** | On-site work coordination |
| **Assessor** | Handoff of scope |

## What Would Frustrate Them

| Frustration | Why It Matters |
|-------------|----------------|
| Too many clicks to claim | Will miss opportunities |
| Unclear scope of work | Bad estimates, rework |
| Slow payment | Won't work with us again |
| No mobile access | Work in field, not office |
| Duplicate coordination | Time wasted |
| Can't find task details | Confusion on site |

## What's The Impact?

| If They Do Well | If They Don't |
|-----------------|---------------|
| Quality repairs completed | Poor quality work |
| On time, on budget | Delays and cost overruns |
| Will return for more work | Lose good subcontractors |
| Good reputation for ARCHR | Bad reputation in community |

---

## Initial Assumptions to Validate

- [ ] Work independently, not ARCHR employees
- [ ] Focused on their trade only
- [ ] Need to see only relevant tasks
- [ ] Mobile-first is essential
- [ ] Quote/invoice workflow is critical
- [ ] Photos are proof of completion
- [ ] Need clear expectations to avoid disputes
- [ ] Payment speed matters greatly

---