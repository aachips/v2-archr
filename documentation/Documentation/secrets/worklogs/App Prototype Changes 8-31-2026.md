
We are branching into two separate prototypes. One is contained within repo/app and is a mostly built out, independently functioning version with minimal dependencies and APIs. But it struggles with connecting with our Airtable base. As we develop it it will turn into a more universal, open source template for groups to start a home repair coalition. This version runs on PostgreSQL.

Then there is the Vue Airtable based prototype. This connects with Airtable and displays information from a dummy database, that we are integrating with our current database. It runs on Vue.js, which allows us to simplify our code immensely. We will be integrating it with Pinia for state management as it develops. Currently it is very simple. It has a Case Search, Case Review, and a broken Help Library and broken Task Rabbit system. 

Over time, we want these two to look almost identical. We want to build the Vue off of inspiration from App as the source of front-end truth. As it develops, we want to make sure we are adding Support Documentation to every feature we incorporate. Right now we are focusing on the incremental development of Vue, while making adjustments in App. As we build Vue, we want to modularize it into smaller reusable components, documented in a Component Library.  

On the Vue, currently, the entire page for Case Review is one Vue Component. We want to modularize that into multiple components. We want to base our source of truth in ../app, where we have much more built out, and a complete front-end. We want to pull from it styling, and adapt functionality to Airtable and Vue. Each .panel card built into case review will be a different component. It's own defined section. This includes, but is not limited to: 

+ A page header, containing multiple components. 
	+ One component is the ARCHR logo with the text ARCHR next to it. (On the app, I altered $brand to just be 'ARCHR' instead of having the role named with it.) Class name of this can be .logo-wordmark
	+ A search bar, where you can access global case search quickly. If you go to the global search page, this will be more of an advanced search page, with filters, and full case display. The class name of this could be .quick-search.
	+ There






For event log to work: Either by - have global mutation observer - watches everything, if changes, make note of it. OR hijack save function and add in new log event. we don't want at the level of granularity of having an event every save. This is where Pinia would come in. Pinia with log in system and user management. Gives list of things did appended to your user account and session. That session has update tied to session. Appended JSON event record. Instead of being pointed at application itself its attached to a session attached to a user. Edits don't care who did it on application. Event ledger doesn't care who changed it. Once it's changed it's new value. If we need to audit, we follow user path. We add a single link to the user per session. Instead of application object owning the event log for changes. That's now owned by user object. Application owns who has edited / interacted with me, but not what was edited. 

For full log of application requires: audit log - document storage, not relational database. Effectively text file that gets written to. Like an error log. If you want to get full list from application. Search key that is applicationID. UserID, SessionID, ApplicationID, and what fields are changed. Can build out list of progress events. In previous, progress events (call it Activity Log) and milestones were 'mingling'. We want a milestone tracker. Progress events right now holds both, we want to kill progress events and make activity log and milestone tracker. Milestone tracker moves you forward, activity log tracks what's done. We will be phasing out the phase number system because submission vs application vs case vs project model effectively does same thing non-linearly. 

Pipeline progress widget still has a use as a milestone tracker. Change to Milestones. Rebuild it exactly as is in Vue and then map how it will be useful and used. 

Application vs case metaphor. Using Github as metaphor. Application is main branch. Case is fork. Case is now my version of it, that case has projects, once complete, merged back to application. 

Break down case-grid of panel cards into vue components

Summary - summarizes data
Overview - Explains Context

overview vs summary 


If it's obviously ineligible, like outside of service area, they are still accessible through the search, but don't come up as suggestions. Unless they are entered by organization or referred by organization specifically. If Ben fills out as a referral for someone in SC, once that submission arrives, it will attach Ben's email '{referrerEmail}' find organization associated with the email domain. 