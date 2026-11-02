---
role_name: [ROLE NAME]
session_date: [DATE]
participants: [NAMES]
---
**We are building an upgraded case management platform front-end for the Asheville Regional Coalition for Home Repair (ARCHR). This platform coordinates home repair services across multiple partner organizations serving Western North Carolina communities affected by natural disasters.

  

As a platform, for a coalition of non-profit partnerships, there are different role levels to build for. In order to build for these roles, we need to define them in detail. 

  

For each of the following roles, write a one or two page brief explaining:

  

Who they are. What job titles may they hold? Where do they work from? What is their technical comfort and ability? Who do they interact with?

  

What they need to do: What are their top 3-5 primary responsibilities? What tasks do they do daily, weekly, and on a monthly basis? What information do they need to do their job? What information do they create that others need?

  

What they need to see: When they log in, what should be the FIRST thing they see? What metrics or counts are important to them? What alerts or notifications matter most? What does success look like for them in the platform? What about failure?

  

What they need to create/update: What records do they create? What records do they update? What documents do they generate? What approvals do they give?

  

Who they interact with: Who do they communicate with most often? Who depends on their work? Who do they depend on? What information do they share vs keep private?

  

What would frustrate them: What would make them avoid using the platform? What would slow them down? What would feel like ‘extra work’? What would they want to be automated?

  

Impact: What happens if they do their job well? What happens if they don’t? How does their work affect the client and greater community?

### Instructions for the Session

- Don't overthink - Write your instinctive answers first
    
- Contradictions are fine - we'll resolve them later
    
- Use examples - tell me about a specific day in this person's work
    
- Keep it to one page - bullet points are better than paragraphs
    
- We'll correct - I'll ask clarifying questions after
    

Roles: 

  

Requestor - 

Volunteer - 

Assessor - 

Crew Member - 

Crew Lead - 

Subcontractor - 

Project Manager / Case Manager - 

Bursar - 

Envoy - 

Organization Administrator -**

Can you add dummy data for some applicants, staff, and partner organizations, and replace dynamic or hard coded data with database fields?


With some of the user roles, give them an indefinite log-in session. With notable exception to some admin roles, it is not that security intensive that you need to have them log in again and again. Or at least give the option to remember you indefinitely. From dashboard, option to go back to website. From website when logged in, option to go to dashboard.

Take all the API endpoints, components, and metrics. Work backwards to map out how you will implement and design each and every one of them. 


![[anchor-records-processes.png]]

Goal: Collapse Inputs into singular input table

Date convention
mmddyyyy - display
unix timestamp - programatic

How do crews get assigned?
How much advance notice does a homeowner have before a crew shows up for a work day? What about for volunteers?





+ Intro and tech disclaimer, safety word=potato
+ been on for exactly two months. Been working really fast. Mapping and blueprinting out terrain. implementation will not be as fast and action packed. We've done a lot.
+ First order of business was to do user discovery interviews. Have done six of these. Feedback is fantastic. Ben wanted to be a degree separated from this process in case feedback was personal, so nobody had to feel inhibited giving feedback. They mostly all love working with Ben and have very kind words and high regard for him. But run into problems with platform.
+ 'Can't find information I'm looking for in one place', 'Uploads get lost', 'Can't track financial metrics' (both with reporting metrics, and project level), 'Airtable is difficult to work with', 'Bugs around task buttons, like claiming tasks and reporting communication', 'Communication doesn't get logged, duplicate communication happens, people look like idiots as result'. 
+ Let that feedback shape the process. Outside of sharing technical feedback, interviews are privileged information. 
+ We've been working on a repo, or repository. This is a way of multiple people working on a complex project with many moving parts. The repo is private, but if someone wants to be added in, the invite is there. We keep privileged information off of the repo, so that if any AI program interacts with it, privileged information is not compromised.
+ We took a bunch of ideas, sketches, and technical role information, and made a starting draft of what the dashboard would look like. It's in ten different permission roles each with a different view. There are a lot of duplicate features, and some of our next steps are consolidation. 
+ HTML files are pretty easy to view. Download them and then click and it will open in your browser. 
+ PHP files are a little trickier, as they need a server to communicate to. So I put up a draft on my personal web domain. It's not on search engines, no one will find it unless they know what to look for or directly get sent the link. If it's a problem we can add a layer of password protection. 
+ But here I am developing a code based draft of the ARCHR website and dashboard. You can log in as any of the roles right now with the password '12345'. It's very bare basic.
+ There's also database mapping, which for simplicity, you can go to this link to check out the map of what the next version will look like. This can be done on Airtable or without Airtable. One of our next steps is going through this in more detail and recreating necessary tables in Airtable. 
+ We have demos of other various systems. One of them is metric tracking. I took the list of desired metric trackings for reporting purposes and we have a rough formula for each. These are in confidence intervals, where level 1 is about 70%, and level 2 is much higher. Right now the Calculus of Airtable and the system that currently exists, it runs into problems pulling these metrics accurately. Reporting is a painful process as a result. The system was originally built for supporting mobilizing a volunteer team to get a home repaired. We're making necessary adjustments so that it also just as powerfully supports nonprofit financial tracking. Two months was not enough time to have that up and running.
+ component library

