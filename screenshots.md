We have about fifty screenshots from the Softr ARCHR Landing Site. I am going to attempt to catalog them in descriptive text, so that we can better organize and rebuild them in code.

## workspace-home
This is an attempt at a homepage for the platform user when they log in or go to the platform. It's not the most intuitive or user friendly, but there are three categories. There is Marketplace -- Browse Eligible Applications, Search Repair needs, Projects, Applications, Documents. There is Process Documents -- Verify Proof of Income, Verify Property Ownership, Upload Documents, Edit Program Required Docs, Cases, Repair Needs. Then there is a category for 'My Profile' which half could be a dropdown from the avatar on the top right -- ARCHR Alerts Inbox, My Outbox, Funding Allocations, Completed Projects, Claims, Organization Profile. At the very top there is a welcome message for the user, which you can customize in the user settings.

### ARCHR Marketplace
'Here's all the new and unclaimed repair needs and submission details.'

#### Marketplace Applications
This is where the new and unprocessed submissions come in. Or where the ones with necessary/urgent action get staged. There is a search feature at the top under the title 'Marketplace Applications'. Each list item has the following dynamic data: On the top line, the date of the submission, the applicant name (LAST, F.I.), the place code, a button for Edit (opens in new tab) a button for claim, a '...' button for more options, and a '^' to collapse or expand that Application Preview. There is a triage score listed, and a list/list preview of repair needs. The marketplace application preview is it's own component.   

#### Marketplace Browse Needs
This is like the Application Marketplace, but for specific repair needs. An application can have multiple cases each with unique repair needs. At this stage, individual repair needs are claimable by an organization or subcontractor. Plumbing repair needs may get condensed and digested into a regular email send out to all of the Plumbing subcontractors for them to claim before someone else does. You can filter these repair needs by trade and triage score. This is a very similar component to the one discussed futher down in this document under Edit Application -> Parent/Child Repair Requests. They could probably both use the same component.

#### Marketplace Browse By
On the Marketplace, you have a welcome message, and then four flexed iconographed options to: Browse by Applications, Browse by Repair Needs, Browse by Trade, Browse by Triage, each with an action button to 'View List' or with a descriptive icon for the button text. Underneath Browse by there a space with javascript tabs to view: your claims, unclaimed repair needs, and claimed by my organization.

##### Your Claims 
Here you can view all of the cases and repair projects you/your organization has claimed. You can hide applications if necessary, or search through your claims. In each claim list item there is a place for an image placeholder/preview image of that repair need/application. There is the application information as submission date | Applicant name (LAST, F.I.) | Placecode. There is next to that column item on the row, one with the date of the claim, and claim status, and claim organization. Then there are two buttons on the right, one to 'Release Claim', and another to 'Renew Timer' for the 90 day expiration inactivity timer. 

##### Unclaimed Repair Needs

This is a filterable and searchable table display list with the following columns; Repair Need, Trade, Triage Score, Application, Date Received, and a button to 'Claim Need'. Another demo of showing unclaimed repair needs shows the Trade | Description. With a space for Triage Categories, and a Claim Button.

#### Repair Need Review
This is a page you can view to see specifics for a Repair Need. The title of the main section is Repair Need Review. The need is described as it is in other spaces with the Trade | description | Claimed by (if claimed). You ahve the option to mark need met, or edit repair need. You can see which case this repair need is attached to. Then there is a section for Claims where you can see who has claimed this Repair Need, and you have the option to renew or release this claim.

##### Your Cases

A space for Cases tied to your {user_field}. There is a search and export option on top right. There's filters for where it is pulling these projects from, area, and project type/status. Each case listed has the title with the organization claim, the application date, and the applicant name. There's an option in the top right of each case box for 'Open' and 'Toolbox' There's a list for repair needs for this case with triage scores. And a '^' expand collapse for each case list item box.

##### Claimed by my org

#### My Referrals
This is a page where you can view your Referral Inbox and Outbox. All the referrals you send and receive will appear here. They are searchable, and have the fields for 'Request Text', 'Scope of Work', and a button to Open the Application.


### Process Documents
'Upload, verify, send, or delete files'



### My Profile
'See messages, referrals, meeting notes'

### application-preview

This is a preview card component for a home repair application. When you are viewing search results, or simply a list of all the applications, this is a format it may show as. On the top right of this card are three buttons: Review (open in new tab), Comment (Pop up modal), and a '...' for more options. Under that aligned left are the: **Jobcode**: [Org initials]-[Placecode]
**Name**: First-Name . Last-Name
**Address**: Full Postal Address

### case-list

This is a list of Cases, that would likely go on a page titled 'View and Search Cases'. At the top is the title 'Cases' with subtext 'All Cases related to' with filters below. On the top right there is a search bar, an 'Add Record' Button, and an Export button. Below the filters are a handful of cases listed by row in a neat horizontal rectangular button the entire width of the component list. Each are listed with the abbreviations of the organization that claimed that case in square brackets, the name of the requestor [last name, first name] and a Job code further to the right (**Jobcode**: [Org initials]-[Placecode]). There is a 'see more' button under the visible cases listed.

### case-review

This is the page on the Softr where you view the details of a case. We have a working application review page on our Vue and PHP prototypes. But we don't have a case review page built yet. They are similar but different. I want to detail this one so that missing elements can be accounted for. One thing that comes up is a preview photo of the home, or repair area, with a caption of the photo name and date. I think this really is helpful for making the application or home repair case more real and tangible. I'd imagine if you click on the photo, it would open a modal with an enlarged version of the photo, but the preview is maybe only a few hundred pixels in either height or width. I'm guessing 150x250. We have display for the Jobcode, the Requestor name, the Address, the Status of the Case, the date of the Application, the percent the Requestor is of the Average Median Income(AMI), the Claim Status, the Preferred Contact Method (text, phone, email, in person..), phone number, contact preference time, contact note, referral Organization, and an option to download the contact. There's a button at the bottom of this top half for Claims, another for Refer to DSW (which is the 3rd party we have do assessments now), a button for 'Edit Application' and a '...' button for more options. This is the first/top half of the page for case review. 

The second half is a dynamic javascript tabbed information viewing, with the tabs being: Eligibility Summary, Comments, Logged Communications, Documents, Property Card, Requests, and Progress Events. There is enough context and information in the rest of the codebase to put those components together.

#### refer-project
This is a modal where you can refer a project for a partner or subcontractor. 'Refer Project' 'Use this form to create a referral record for {record_details_field}' 'Referral type(required)' - 'Refer project to Partner' or 'Request Subcontractor Quote'. Dropdown option for either 'Select Subcontractor', or for 'Referral To' based on referral type response.

#### case-toolbox

This component is not developed enough to the point where I can safely extrapolate or describe what is going on. 

### Document Actions
There are a bunch of different needed ways for the coalition user to interact and edit documents. two basic ones are 'Download', and 'Send File' Other ones listed below:

#### change-Document-folder

This is a widget for moving a document into another folder. There are several components like this for different document functions. This let's you move a file from one place to another within the ARCHR Project Root Directory.

#### edit-document-type

This is another one of the document adjustment functions you can do. Documents are categorized in different types. You might have eligibility verification, or estimate, or contract, or scope of work, or pictures. Different document types live in different subdirectories in the project folder for each application. And those files need to be findable in those spaces. So edit-document-type, and change-document-folder, may have overlap in their function.

#### edit-file-links

This is another one of the document adjustment functions. I'm not fully clear how this is supposed to work. All of these document functions have a weird to operate front end design, made by a person who isn't a front end designer. But here you can modify what Project, Place Code, Document Folder, and Document type the document is. So if the document is maybe relevant to a separate place code or application, you can adjust it here. 

#### edit-placecode-link

This is another of the document adjustment functions. If the placecode is wrong, you can adjust it here. There is a searchable list with all of the place codes. Each list item has the current place code, with the full address and applicant name listed below, with a list of links to all projects associated with that placecode. There is an Edit button on each list item so you can make adjustments. There is another one for edit-project-link, which is the same idea, but can relate to any project, which there may be multiple projects under a single placecode.

#### claim-details

This is a page which shows a Claim. In this example, there is a green background translucent rectangle indicating it is claimed, with the organization's logo of who claimed it, on the date they claimed it. After 90 days of inactivity this claim expires. And in this case, the claim happened on 5/13/2026 and there hasn't been activity logged. So if it's expired, that rectangle could be a different color for expired. There is a button to Release the claim right under. and if the case isn't claimed, there is an option to 'Claim {record_details_field} for {user_field}'. This would likely open a warning modal explaining what will happen if they claim the case, and give a confirmation method that won't be accidentally hit. There is a claim history under all of that with the organization logo, the claim date, the expire date, and the release date, along with the name of the coalition worker who claimed the case. 

For confirming claim release, the warning question is, "Are you sure you want to release {user_field}'s claim to {record_details_field}?" "{record_details_field} will no longer appear in your [my applicants] list and another [organization] will be able to add their [claim] to the project."

#### Document-review
For each document, the platform / coalition user should be able to view the associated metadata for the document as a full display. This should be available on a button from the application review page where you are viewing the list of documents. This button could be labeled details, or given an intuitive icon.

### edit-application

Here, an organization admin (level 2+ or level 1 with configured permissions) can edit the details on a home repair application. You have the Project Code at the top, and then there is a dynamic JS tabbed information space with the five tabs being: Applicant Info, Home Info, Household Info, Income Info, Repair Requests. Applicant Info - Applicant Name, Primary Language, Date of Birth, Contact Information, then an edit button under. Home Information - Full Address, unit, Legacy Neighborhood, Township, GIS_OWNER, Project Count. Repair Requests -- There are styled row list items for each request, with the option to list parent requests, and include child requests (programmatic language, not parent and child family language). 

An example parent request may be 'Carpentry | Rental Cabin completely destroyed by creek damage' with child requests being the sub repairs within that parent request. There are the options to edit the Request, or Delete the Request as buttons on the right. If the Repair Request is claimed, it will have a Claimed string of words at the end of the description. For example: Drywall | Replace ceiling and sheetrock materials. Sheetrock replacement required | Claimed by: Asheville Area Habitat for Humanity. There is a list of Repair categories elsewhere in a database table. The ones listed as examples are Carpentry, Drywall, Roofing, Gutters & Stormwater, and Other. There is a 'see more' button centered at the bottom of this repair request list. Some households have a long list of home repairs needed, and there is an option to search the repairs at the top of this list. On the modal for add-repair-need, there is two textarea form inputs, one for Repair Need (required) and another for notes. 

Household info - Household size (example 1 adult 2 children), Household Demographic Groups, Record Count. There is a button to edit the household details. For each inhabitant there is a people records that has the name, date of birth, applicant/household member status, and if they receive income. You have the option to Edit or Delete each person. And at the top there is a search and ability to add a person. On income info, there is the gross annual income listed, with household income summary - applicant name, income, income source, and verified document type. There is a list on the right with income by person and source. So if there are multiple people in the household who earn income, it is aggregated here. Each list item has the name, the income amount, the income source, and the payment frequency. You can edit income or delete the income source. You could have multiple listings for the same person and income source. You can filter the list by person or by income source. 

