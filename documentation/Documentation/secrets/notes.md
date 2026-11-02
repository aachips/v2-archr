The ability for ARCHR to exist independently, as a local affordable home repair foundation, independent of Habitat for Humanity, is incredibly important. Several core functions of ARCHR are governed by Habitat. Volunteers, Donor base, Payroll & Accounting, probably more. Building the ability to absorb these functions into the platform is necessary in the long haul to continue this work and expand this project to other regions. 


Org dashboard: 
One of the widgets being all eligible projects

on app prototype - claim denied by FEMA - still asks how much it is, same with homeowners insurance

zero income affidavit not required fields - fine for testing

on submission still no account credentials created, shows as 'loading..' but we get console error: No credentials in response:

Object { success: true, 
submission_id: 37, 
anchor_id: null, 
case_number: null, 
dashboard_url: "requestor-portal.php", 
credentials: null }
anchor_id: null
case_number: null
credentials: null
dashboard_url: "requestor-portal.php"

```
submission_id: 37
success: true
<prototype>: Object { … }

[intake.js:771:29](http://localhost/archr/repo/app/assets/intake.js "View source in Debugger → http://localhost/archr/repo/app/assets/intake.js:771:29")  

❌ No credentials returned in response! [intake.js:789:29](http://localhost/archr/repo/app/assets/intake.js "View source in Debugger → http://localhost/archr/repo/app/assets/intake.js:789:29")
<anonymous> http://localhost/archr/repo/app/assets/intake.js:789

```
​


On the component library, the only role we are missing for mapping components and api-endpoints is Super-Administrator (see interface/super-admin for additional context). The component library at the moment lives within elemental-integration/components. It exists here in this temporary folder so that relevant files for datamapping and database planning are in one place. Within components/ there is an index file called component-library-assessor-v2.php. This is a deprecated name. It's no longer just for assessor parts. It's for everything. This should change to index.php, or component-library.php, and pull all of the components from the directory it is in, by the category name of the subdirectory. So on the library, after the copy and paste global CSS and JavaScript footer code, there are tabs to select between different role categories. All of the components will load in here, and have their copy paste code/embed text. What is missing is a php shortcode for including that component, that is a single line, that will work on absolute path set by file constant, regardless of where the developer is writing code from in the repository. Actually, the copy and paste global CSS and JavaScript footer code can go underneath the library tabs and contents, as once they are implemented, you won't need to look at them very much.

---

There is no way to apply global CSS to Softr. You can do it at a page level. We can work with and figure that out, however, this is Softr's response to someone asking about and suggesting global CSS as a feature: 

" Hey, actually we are going to improve styling, and yes — that will be something applied globally. Right now, theme settings are also applied globally, but there will be a lot of improvements coming.

What I suggest is this: since all our features are added based on the number of requests, I kindly ask you to submit this as a feature request here: [https://www.softr.io/suggest-feature.](https://www.softr.io/suggest-feature.)"

The issue is that their own /suggest-feature link comes up as a 404. Edit: this is because the link given had a period at the end. This comment was suggested by the developers in May of 2025."

---

Editing organization program lists and criteria

For prospect partner - click link on site to Join as a Partner Organization / Join ARCHR. Explain criteria. Similar to disaster repair intake form. List company name, intended number of users. Their contact information. Short description of why you want to join. First layer of intake. 

Volunteer Application - Done through Habitat site, but let's have one

---

Ben directory changes

+ favicons work best as .ico file extensions. there are free converter tools to turn a png into an .ico
+ I copied everything useful from /design/
+ w9s for subcontractors..
+ I moved the draw.io sketches from sketch library (now deleted) to interface/

---

1. **Complete YAML frontmatter** for all documentation
2. **Game-like volunteer experience** design with quests, XP, and reputation
3. **Full SQL schema** with all necessary tables for the gamification system
4. **User stories** for each major workflow
5. **Technical specifications** for developers
6. **Future roadmap** for phased implementation

---

The system is designed to be both engaging for volunteers and technically robust for your developers, with clear paths for content creators to grow into newsletter and blog roles.

Mobile bar at bottom - Return to Dashboard link
Messages, Tasks, Search, Home/Dashboard

Application -> Case -> Project

Platform is set of systems that handle processes of functions

Method of documenting business logic - management theory - attempts to describe what we talk about - don't ask permission do the shit

Who gets to say who is the person in charge of assigning projects?

Marisa will take the time to do robot work make individual folders go through emails - checking it all off, etc. not a human friendly task

see costing/costingObject.json



cookout july 30 8:30-10AM nextdoor to warehouse

If settlement was denied, it shouldn't ask what the total settlement was or if there is any money remaining.

![[Pasted image 20260725102945.png]]


---

app/test-setup.php
HTTP 200 Final URL: http://127.0.0.1:8080/app/login.php error alert: no success/complete: no form still present: no --- response excerpt ---

app/test-airtable-dual-write.php
PostgreSQL write: OK
Airtable write: OK
Submission ID: 67
Anchor ID:     ANCHOR-20260725-00052
Placecode:     N/A
Project Code:  N/A

Fatal error: Uncaught RuntimeException: Airtable API error (HTTP 401): {"error":{"type":"AUTHENTICATION_REQUIRED","message":"Authentication required"}} in C:\laragon\www\archr\repo\app\lib\database\AirtableDatabase.php:40
Stack trace:
#0 C:\laragon\www\archr\repo\app\lib\database\AirtableDatabase.php(60): AirtableDatabase->request('GET', 'https://api.air...')
#1 C:\laragon\www\archr\repo\app\test-airtable-dual-write.php(78): AirtableDatabase->select('intake_submissi...', Array, Array, 1)
#2 {main}
  thrown in C:\laragon\www\archr\repo\app\lib\database\AirtableDatabase.php on line 40

- As the user types an email, home phone, cell phone, or home address, the form waits 600ms and then calls `api/check-duplicate.php`.
- If a submission in the last 24 hours matches any of those values, a red banner appears at the top of the form:  
    _"A recent submission for this email was already received. To avoid a duplicate, please call **(828) 555-0199** before continuing."_
- The submit endpoint still blocks duplicates at the end, but now the error message also includes the call-in number.
- The call-in number can be changed without editing code by setting the environment variable `ARCHR_CALL_IN_NUMBER`.

The list of account holders on Superadmin is long and hard to work with. How about a search option for the account and an option to view all accounts? Requestor accounts will be created at much higher frequency because any time somebody fills out an application and submits, an account is created. If the requestor account is unused/not logged into for a first time in 30 days, let's delete it. On Organizations, having Delete right next to Edit, even with the safeguards, just doesn't look good. How about on Edit, that's where you can add eligibility rules, and there is a dangerzone option for deleting organization. But without going into edit, that option isn't immediately visible. Also on all of the views, the ARCHR Logo is a broken link. It's noxious on the eyes that it says in the top left corner ARCHR Super Admin and then to the right there is a logo and then it says ARCHR again. Let's just have the logo and name on the top of the side menu. Public site doesn't go to the public site, it just goes to the dashboard home. The point of that link is that you can go to the public site while logged in. The point of a Super Administrator, and also an Organizational Administrator, is that they are able to do anything the other views can do, and access those views. So where it says Super Admin in a blue button on the header, you should be able to click that, and choose another role to view as the Super Admin. Another function of the Super Admin is to process Helpdesk Tickets, which should be an item on the Side Menu with an appropriate icon. When I looked up Gene Belcher which I submitted an application for, nothing came up in Case Search. The one that came up is John Smith, which is pending review. The actual review page isn't styled great and is hard to read. John's address is 247 Riverside Drive, so automatically it should be given the placecode 247RIVER

Super-Admin Delete Organization - 

### How it works

- In the Super-Admin Organizations table, each row now has a **Delete** button.
- Clicking it opens a **Danger Zone** modal that shows:
    - the organization name and code,
    - a count of every associated record (users, assignments, queue entries, claims, etc.),
    - a **Download records before deleting** link that exports everything as JSON,
    - a checkbox acknowledging the action is permanent,
    - a text field that requires typing the organization code exactly.
- The **Delete** button is disabled until the code is typed correctly and the checkbox is checked.
- When confirmed, the server:
    1. exports and saves a JSON archive to `app/backups/organization-deletions/`,
    2. clears/NULLs any cross-org references that would otherwise block deletion,
    3. removes the organization and its cascading records in a transaction.

+ Dangerzone option - delete organization - option to retain/download records, way to delete organizations that are added for testing

+ Case Review - when you click on a case to view the case details, should be a page that displays all of the details of the case. Starting at level 1 permission - office worker with limited details (very case sensitive information out of permission) and 2 / 3 (admin + Superadmin) that can view the entire case. Options to log communications, write tasks, upload and view documents, view contact information, case progress, etc. Can base off of elements in story-of-one.html. On this there is the Job Code, which is the acronyms of the organization claiming the case, and the project code. For example, 10 Webb Hill Road disaster repair claimed by Asheville Area Habitat for Humanity is '[AAHH]-D10WEBB'. Then there is the name or names of the homeowners, the address, status, application date, percent income of AMI, Claim status, if unclaimed, there is an option for level 2 org administrators to be able to claim it on behalf of their organization, or an option to refer a subcontractor, or to edit the application. There is an eligibility table with red flags, green, purple, yellow (robots never determine eligibility, but they will indicate if a condition meets eligibility or not, and what organizations they may qualify for). There's a space for a summary, comments, logged communications, documents, property card, Requests, and progress Events.

+ Case Search: One of the only functional elements in the current platform is an application search. It is one of the first side menu options and first things that come up on the home landing page for Office Workers + Administrative (Permissions level 1 (limited view, relevant to as needed for on the ground work), 2(admin), 3(super-admin)). On the Global Project Search there are filters based on who the case is claimed by: [Asheville Habitat, Community Housing Coalition, Mountain Housing Opportunities, Poder Emma], as well as project status: [Paused, Submitted, Intake Processing, Project Phase, Completed, Phase Unknown, Ineligible/Withdrawn, Unclaimed]

### How it works

- **Permission levels**
    - **Level 1** (office worker / staff): sees limited case details; applicant contact info and internal notes are hidden. PII Restrictive
    - **Level 2** (org admin): sees full details for cases claimed by their own organization; limited view for cases outside it.
    - **Level 3** (super admin): sees full details for every case.
- **Case Search** (`case-search.php`)
    - Filters by text search (case #, applicant, address, project code), project status, and claimed organization (including an **Unclaimed** option).
    - Results table shows case #, job code, project code, applicant, city, claimed org, status, priority, and a **Review** link.
- **Case Review** (`case.php?id=...`)
    - Computes the **job code** as `[ORG-ACRONYM]-ProjectCode`.
    - Shows project code, claim status, eligibility results, repair needs, communications/activity, tasks, documents, and progress/status history.
    - A banner explains when the view is limited.
- ### Key details

- **Super-Admin users**: You can now search by name/username/email and toggle between "Limit to 100" and "View all".
- **Inactive requestor purge**: There is a red **Purge inactive requestor accounts** button in User Management. It removes requestor accounts that have never logged in and are older than 30 days. To make it fully automatic, you would wire a cron to `POST api/run-maintenance.php` with `action=cleanup_requestor_accounts`.
- **Organization delete**: The Delete button is gone from the row actions. It now lives inside the **Edit** panel under a **Danger Zone** section, and eligibility rules are also managed inside Edit.
- **Branding**: The topbar is cleaned up; the ARCHR logo and name live in the sidebar. Public Site now opens the real public homepage.
- **Role switcher**: Clicking the blue **Super Admin / Org Admin** badge opens a dropdown to jump to any other role dashboard.
- **Case Search**: Gene Belcher now appears because the search includes submissions that don't yet have a `cases` row. Clicking Review creates a case on the fly and opens it.
- **247 Riverside Drive**: The placecode generator was already producing `247RIVER`; the problem was that the existing `cases` row didn't copy the project code from the anchor. I synced existing cases and made new submissions create a case with the correct project code, so John Smith's case now shows the proper placecode/job code.
- **Case review styling**: Larger section headings, better definition-list spacing, distinct panel borders, and a clearer header.

-----

Upon submission Submission error: Submission failed (HTTP 200) null [intake.js:862:25](http://localhost/archr/repo/app/assets/intake.js "View source in Debugger → http://localhost/archr/repo/app/assets/intake.js:862:25")

    <anonymous> http://localhost/archr/repo/app/assets/intake.js:862

When you go to www.archr.live you get the public website. When you log in, your dashboard is now the default load-up when you go to the site. The session is for 24 hours, but you can in settings extend it to indefinite, if you are sure your device is secure. This way all you have to do to get to the dashboard indefinitely on that device is go to www.archr.live. The indefinite session length is a Boolean setting in profile settings.