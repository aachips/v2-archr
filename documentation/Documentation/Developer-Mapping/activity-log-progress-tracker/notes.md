## Reading the Office Subtasks CSV

The CSV is hard to read, but here's what it tells us:

### Column Meanings

|Column|What It Contains|
|---|---|
|**Name**|The task or action|
|**Child 🟪Subtask**|Subtask relationships|
|**[⚙️Progress Tasks]**|The category this belongs to|
|**🟪Office Task Category**|Which phase this task belongs to|
|**⚙️System Interactions**|Which systems this touches|
|**Parent 🟪Subtask**|Parent task relationships|

### What It's Trying To Map

text

┌─────────────────────────────────────────────────────────────────────────────────┐
│  WHAT THE CSV IS TRYING TO SHOW                                               │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  TASK HIERARCHY                                                          │   │
│  │                                                                         │   │
│  │  🪝Claim Entire Project                                                 │   │
│  │    └── 🪝Claim Specific Repair Need(s)                                  │   │
│  │          └── Select Person                                              │   │
│  │                └── 🪝Claim Assessment                                  │   │
│  │                      └── 1. Intake: Assign Assessor                    │   │
│  │                                                                         │   │
│  │  📅Schedule Assessment                                                  │   │
│  │    └── 1. Intake: Schedule Assessment                                  │   │
│  │                                                                         │   │
│  │  🪄Generate Draw Request                                                │   │
│  │    └── 5. Report: Complete Draw Request Workbook                      │   │
│  │                                                                         │   │
│  │  🪄Generate Contract                                                    │   │
│  │    ├── Approve Contract                                                │   │
│  │    │   └── 3. Planning: Approve Contract                               │   │
│  │    └── Reject Contract                                                 │   │
│  │        └── 3. Planning: Reject Contract                                │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘

### What's Missing

The CSV maps tasks to phases, but doesn't connect to:

- The event system (what events trigger these tasks)
    
- Document events (what documents are generated)
    
- State mutators (how completing a task changes state)
    

---

## The Twitter Feed UX

Your idea of a Twitter-like feed is a good mental model.

text

┌─────────────────────────────────────────────────────────────────────────────────┐
│  TWITTER FEED AS TASK ENGINE                                                   │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  📢 ACTIVITY FEED                                                       │   │
│  │                                                                         │   │
│  │  🔴 42-CHERRY   │ Sarah M. verified income documents                   │   │
│  │  (bumped to top) │ 2 mins ago                                           │   │
│  │  ────────────────────────────────────────────────────────────────────── │   │
│  │  🟡 15-MERRILL  │ James T. scheduled assessment for Dec 18            │   │
│  │  (2 days old)   │ 2 days ago                                            │   │
│  │  ────────────────────────────────────────────────────────────────────── │   │
│  │  🟢 8-OAKLAND   │ System: Contract signed by homeowner                 │   │
│  │  (completed)    │ 5 days ago                                            │   │
│  │  ────────────────────────────────────────────────────────────────────── │   │
│  │                                                                         │   │
│  │  [Quick Add Task]                                                       │   │
│  │  ┌─────────────────────────────────────────────────────────────────┐   │   │
│  │  │  What needs to happen? [_________________________] [Post]      │   │   │
│  │  └─────────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘

### How It Works

|Feature|How It Works|
|---|---|
|**New events appear**|They go to the top of the feed (bumped)|
|**Unresolved tasks**|Bump to the top each day|
|**Resolved tasks**|Sink to the bottom|
|**Quick Add**|Manual task entry (custom or from dropdowns)|
|**Feed items are tasks**|People can respond or act on them|
|**Mark resolved**|Task moves to completed state|

---

## Pinia: Is It the Right Tool?

### What Pinia Does

Pinia is a state management library for Vue. It:

1. **Stores application state** in a central location
2. **Syncs state** across components
3. **Allows mutations** in a controlled way
4. **Provides devtools** for debugging
    

### Is It Right for You?

**YES, but only after you define your state model.**

Pinia (or any state management) is just a container. It doesn't know what "state" means for your application. You need to define:

1. What state is (the object shape)
2. What actions can mutate state
3. How state changes affect the UI

### How to Use Pinia Effectively

``` javascript

// Define what a State looks like
const state = {
    applications: [],
    currentApplication: null,
    tasks: [],
    milestones: {},
    events: [],
    user: null,
    loading: false,
    error: null
};
// Define how state can be changed (mutators)
const actions = {
    // Event listener: when an event happens, update state
    handleEvent(event) {
        // Add to event log
        this.events.push(event);
        
        // Find what this event affects
        const app = this.applications.find(a => a.id === event.application_id);
        
        // Mutate state based on event
        if (event.type === 'document_uploaded') {
            app.documents[event.document_type] = true;
            // Check milestones, update UI
        }
    },
    
    // Task completion: mark task as complete
    completeTask(taskId) {
        const task = this.tasks.find(t => t.id === taskId);
        task.status = 'completed';
        task.completed_at = new Date();
        // Recalculate feed order
    }
};

```

---

## Meeting Tomorrow: What to Focus On

### Questions to Answer

|#|Question|Why It Matters|
|---|---|---|
|1|"What is the actual state object for an Application?"|This is the foundation of everything|
|2|"What are all the possible events we need to handle?"|This is the input to the system|
|3|"What should happen when each event occurs?"|This is the logic|
|4|"How do we prevent infinite loops?"|This is the guardrail|
|5|"What milestones exist and when are they triggered?"|This is the progress tracking|
|6|"What makes a task 'standardized' vs 'case specific'?"|This is the task model|

### What to Propose

> _"I think we need to start by defining what a single Application looks like in code. Not the database schema, but the JavaScript object that represents it. From there, I can build the Event Listener, the Task Engine, and the State Mutator. But I need the definition first."_

---

## The Path Forward

### Step 1: Define State (Today/Tomorrow)

Define what an Application looks like in code. What fields does it have? What milestones? What tasks? What documents?

### Step 2: Define Events (This Week)

List all possible events in each category. Start with the ones you know and leave placeholder for the rest.

### Step 3: Define Event → State Mutations (Next Week)

For each event, define what should happen to the state. This is where the "Event Resolver" lives.

### Step 4: Build Task Engine (Next Week)

Define how tasks are created, assigned, tracked, and completed. How does the Twitter feed work?

### Step 5: Connect to UI (Ongoing)

Use Pinia to sync the state to the UI. When state changes, the UI updates.

---

## Summary: What You Need From Tomorrow's Meeting

|What You Need|Why|
|---|---|
|**State definition**|What does an Application/Case/Project look like?|
|**Event list**|What events can happen?|
|**Event → Mutation mapping**|What happens when each event occurs?|
|**Milestone definitions**|What milestones exist and when are they triggered?|
|**Task categories**|Verification, Communication, Scheduling, Documentation?|

---

You're not lost. You're in the messy middle. The hardest part is defining the data model. Once that's settled, everything else is implementation.