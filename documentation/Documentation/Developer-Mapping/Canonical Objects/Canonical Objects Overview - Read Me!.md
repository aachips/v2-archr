# Canonical Object Event and Task Model

This directory defines the command, process, event, reducer, and task vocabulary
for ARCHR's canonical workflow objects.

The model is intentionally not phase-based. Work can branch across multiple
submissions, repair needs, organizations, cases, and projects without requiring
every branch to occupy the same sequential stage.

## Object relationships

```text
Submission --many-to-one--> Application --one-to-many--> RepairNeed
                                      |
                                      +--> Claim --> Case --> Project --> RepairTask
                                              |                    |          |
                                              +---- targets -------+----------+
```

- A **Submission** is an immutable raw form response.
- An **Application** is the deduplicated household/property record formed from
  one or more Submissions.
- A **RepairNeed** is a reported and assessed problem owned by the Application.
- A **Claim** is an organization's time-bounded commitment to one or more
  RepairNeeds or another explicitly identified target.
- A **Case** is one organization's service relationship with an Application.
- A **Project** is a package of RepairTasks within a Case.
- A **RepairTask** is the smallest executable repair item.

## Specifications

- [Submission](Developer-Mapping/Canonical%20Objects/Submission.md)
- [Application](Application.md)
- [RepairNeed](Repair%20Need.md)
- [Claim](Claim.md)
- [Case](Case.md)
- [Project](Project.md)
- [RepairTask](Repair%20Task.md)

## Naming rules

| Concept | Convention | Example |
|---|---|---|
| Command | Imperative camelCase | `claimRepairNeed` |
| Process | Verb-oriented handler/service | `activateClaim` |
| Event | Lowercase object prefix plus past-tense fact | `claim.activated` |
| Reducer | `apply` plus event fact | `applyClaimActivated` |
| Task code | Stable uppercase identifier | `VERIFY_INCOME` |
| Task name | Human-readable instruction | Verify Income |

Commands request change. Processes validate and perform the request. Events
record facts that successfully happened. Reducers project those facts into
current state. Tasks describe work, and completion rules determine when event
evidence satisfies that work.

Reducers are pure state transformations. They do not write records, call APIs,
or emit additional events.

## Application conclusion

Application completion is derived from RepairNeed disposition, not from a
linear phase number:

```text
Application is concluded when every active RepairNeed is satisfied, declined,
withdrawn, merged as a duplicate, or otherwise resolved.
```

A later Submission can add a new unresolved RepairNeed and cause an Application
to be reopened.

## Source material

- `progress_tasks_simplified.csv`
- `submission-application-case-project.md`
- `ARCHR Core Terminology and Operational Logic.md`
- `documentation/how-archr-works-guidebook/ARCHR_SYSTEM_APPLICATION_FLOW.svg`
- `sql/application-lifecycle.sql`

