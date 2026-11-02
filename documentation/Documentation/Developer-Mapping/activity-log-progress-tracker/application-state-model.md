## The State Model You Need

Before you can use Pinia (or any state management), you need to define **what state looks like**.

### Application State Model (Simplified)

javascript

// What state looks like for an Application
const applicationState = {
    // Core identity
    id: "app_42CHERRY",
    placecode: "42-CHERRY",
    
    // Status
    status: "active", // new | active | concluded | terminated | withdrawn | expired
    phase: 2, // 0-5 (Submission, Intake, Processing, Planning, Project, Completion)
    
    // Milestones
    milestones: {
        // Each milestone has a unique code
        M1: { completed: true, at: "2026-09-01" }, // Application Submitted
        M2: { completed: true, at: "2026-09-02" }, // Eligibility Checked
        M3: { completed: true, at: "2026-09-03" }, // Claimed by Organization
        M4: { completed: false }, // Assessor Assigned
        M5: { completed: false }, // Assessment Scheduled
        M6: { completed: false }, // Assessment Completed
        // ... etc
    },
    
    // Required documents
    documents: {
        income_verified: false,
        ownership_verified: false,
        assessment_completed: false,
        contract_signed: false,
    },
    
    // Tasks
    tasks: [
        // Array of task objects
    ],
    
    // Claims
    claims: [
        // Array of organization claims
    ],
    
    // Projects
    projects: [
        // Array of project objects
    ]
};

### Milestone Definitions

javascript

// What milestones look like
const milestoneDefinitions = {
    M1: {
        id: "M1",
        name: "Application Submitted",
        phase: 0,
        order: 1,
        trigger: "submission_created",
        description: "First submission for this placecode"
    },
    M2: {
        id: "M2",
        name: "Eligibility Checked",
        phase: 0,
        order: 2,
        trigger: "eligibility_report_generated",
        description: "Eligibility check completed"
    },
    M3: {
        id: "M3",
        name: "Claimed by Organization",
        phase: 1,
        order: 1,
        trigger: "case_created",
        description: "An organization claimed the application"
    },
    // ... more milestones
};