

The Project Manager should have the following abilities built into their dashboard:

+ In regards to processing Requestor claims, they need to be able to Claim Jobs, Update Information, and Take Case Notes. They should be able to Schedule Assessments, Sign off on Schedules, and Schedule Job Starts.
+ For internal coalition, they need to be able to Update Task and Job Status, and  Update Estimated and Actual Costs of Jobs. This also can include time appraisals for how long a job will take with a current crew and volunteer size. 
+ For a Partner, or for the Parent Organization, the Project Manager is able to Create a Contract, Assign Crew, and Create a Task Workflow. When a Job is Claimed, that has to be an Alert. Same with when a Crew is assigned. Same with Volunteer Slot Managers being alerted to relevant changes. PMs can Schedule a Crew Start.
+ For Subcontractors, a PM can Suggest Tasks to Subcontractors, Upload Quotes and Estimate Documents. They can Alert the Sub suggested of changes and updates. They can Schedule a Subcontractor Quote and Schedule a Subcontractor to start on a job.
+ For Volunteers, the PM can Set Volunteer Slots, and Set the Required Volunteer Experience Level. They can Alert Capable Volunteers of Available Tasks, and Schedule Volunteer Groups. 

On the Landing Page for {projectManager}, the necessary displays are as such:

+ There is a count for {unclaimedJobs} with buttons for Claim, Subcontractors, Workflows, and Work Crews. 
+ There is a count for {acceptedJobs} with buttons for View, Volunteers, and Contracts.
+ There is a list for [Alerts] with {latestEvents} and a button for :/eventDetails
+ There is a list for [messages] with {latestMessages} and a button for :/messageDetails.
+ There is a Table List for Ongoing Work with three columns for Crew, Job, and Next Up. In Crew, there is listed {workCrew}[], with each corresponding to Job ({ongoingJobs} and Time Remaining: {daysRemaining}), and Next Up ({crewLead}[].nextUp{startDate}). There is a count for count:{readyJobs}, and an action button for Schedule.



One of the core features that exists and provides the most utility has not been added to the landing pages for Administrative roles, mainly because it exists and we don't need to build it from scratch. But it's the Global Case Search. Normally this is the first thing that comes up on Organization Admin, Project Manager, Bursar, and Envoy.