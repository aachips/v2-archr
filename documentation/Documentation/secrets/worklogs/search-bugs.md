On Claim Case pop up the Claiming organization dropdown is broken. It doesn't display any organizations nor does it expand downward enough pixels to show any organizations if any are listed.

Please remove the dummy Partner Organizations such as: API Test Org, API Org 1784991130... just leave five real cohesive organizations such as: Asheville Habitat, Mountain Housing, Community Action, Community Housing Coalition, Land of Sky.

Please ensure that side menus are consistent. The only live roles of interest right now are Admin(Org), Super-Admin, and Requestor. The side menu for Org Admin can be listed as: Overview - Home, Applications, Case Search, Documents Bucket, Team Accounts, Metrics, Quick Task, and Help. The Help button links to the public site's help library at app/help.php. Latest Events and Messages is not going to be up and running any time soon, and we can eliminate those from view. Case Overview on the Dashboard home for Org Admin has a broken flex display on the CSS. The main inconsistency I notice is when I go to Case Search page, the side menu is just Dashboard and Case Search. At a later time, the Quick Task will have a feed that displays on the Dashboard Home, that different Team Members can respond, flag, or mark as logged or completed.. 

When we generated those submissions, we didn't create requestor accounts. We do not need 50 of those. But maybe 2-3 to experiment with. We can also go through the User Management on SuperAdmin and purge the api tester accounts with names like API User or API Super Admin. Super Admins can do any of the actions that Organizational Admins can do. So having the Admin Side Menu listed right underneath the current side menu options for Super Admin would be great. Having the option to delete an account right on the interface, but having it be a modal pop up danger action, would be helpful. Having to manually enter a randomly generated chain of characters as a safety precaution to prevent accidental deleting. Minor styling issue but, the tables and sections in Super Admin blend into the page main background and it could be better styled/delinneated from the background. Coalition Overview for example, does this great with the card boxes tracking coalition metric numbers. Right under that, nothing else has that helpful styling. If we are making a Requestor account from the Super Admin interface, having the option to plug in the Case Anchor ID to match that account with that given case would be helpful.

![[tempacc2.png]]


---




SOFTR

+ Filters don't work right now. Sometimes they do.
+ Default listed cases happen to be the oldest. Ones from almost after the storm. Almost always the same.
+ Claimed by with acronyms may make sense for some users but is generally bad accessibility practice. 
+ No Help Docs. 
+ Project status filters - two 'ineligible/withdrawn', overly technically worded filter names. Some of those should be under claimed by filters. 
+ Different permission level views: level 1 - PII redacted. Level 2 / toggle setting done by admin
+ Doesn't give number of search results

Prototype: 
+ Unclaimed cases do not give option to claim even though feature is built. 
+ Add in Cross Origin Support for Softr in Partials

Project Search vs Place Search
Checkbox for unclaimed Projects

### Application Status: 

+ Active - Default status, if none of the others. 
+ New - Submitted in the last 14 days. 
+ Concluded - All repairs completed. 
+ Terminated - When applicant fails to follow up, or is deemed ineligible. Checkbox items of why we are deeming ineligible. 
+ Withdrawn - We talked to homeowner, said someone else already did it, or no longer need repair help. 
+ Expired - After six months, even if you submit income verification, we need to do new application. 

### 90 Day Progress Cooldown

One of our former partner organizations - first interaction would be to claim assessment. Once you claim assessment, it's your organizations' responsibility to upload and verify income documents, take before pictures, and write an assessment report. At some point, a bunch of applications were claimed and not followed up on. They stayed in application limbo. Someone who is no longer interacting was responsible for following up. When we put in new claim system, added a timer on it. If no actions happen within 90 days, the claim expires. Claim is tied to Org ID. Any progress events are also tied to Org ID as source. If within 90 days, no progress tasks tied with your Org ID, claim expires. Resets everytime new progress tasks. Still shows that there was an interaction. Expired tag means someone was working on it but now they aren't




Application - contains everything. 
Case is Organization Specific - What we will work on, how I have interacted with this application. 
Project - Repairs being performed on the ground. 


### Financial Costing Engine

Costing Input. Takes every dollar amount -> Adds to a handful of types. Generated. Estimated. Or Reported 'Actual'. Those are three types of main types of costs. Rank is the hierarchy generated -> estimated -> actual reported. 

#### Costing Rankings
Generated - Task Library Robo Shit - Like using a roofing calculator. 
Estimated - Post-Assessment Project Manager Input a/o Subcontractor Input
Actual - Actual invoices and timesheets and material receipts

#### Types of Cost
Labor
Materials
Subcontractor

Like Event Tracker. Cost Engine would get an input. Resolve most up to date highest rank. Output project cost. 

In the case mgmt side -> Bursar could select which funding source for each case. So we can have up to date picture of remaining funds. 



Out of the 1,000 applications in the history of this, approximately 60 are ineligible due to income. We have spent, possibly hundreds of thousands of dollars in administrative labor and verification, to disqualify about .6% from receiving repairs. Do we keep pumping money into not helping people get home repairs, or just use that money to repair peoples homes? 

One answer is with funding sources. They dictate requirements. Without that, we are locked to most restrictive qualifications. We are collecting extra documentation and performing additional admin work for less restrictive funding sources. (and taking too much damn time to do it)


