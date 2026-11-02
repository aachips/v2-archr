 + Turned the Vue View Case Review into components. This includes page components such as the Header items, and Sidebar.
 + Cleaned up App Dashboard Header. Removed some unnecessary items cluttering limited real estate. 
+ Added a .lang-toggle button, next to the .theme-toggle. Doesn't Work. We'd like to have a .php in lib called language-translate.php, and have all of the rendered text in different parts of the site on the front-end with the English, Spanish, and possibly other languages spoken commonly in region. Potential third language would be Ukrainian.
+ Added a avatar-dropdown menu for the user profile or log out option, on the portal-avatar. It doesn't work. It has only been made to look a certain way on the portal-layout. It doesn't drop down a list. When it drops a list it should list for Profile Settings, and Logout
+ On case-search.php, each list item under applications found can only be accessed by clicking the Review button at the end of the list item. The entire list item line should function as a link going to case.php?submission-id="$submsision_id"


### Panel Card Components in Case Review
 In Case Review. Each card is build as a different component and defined section. Each card must be defined so that the objects they inherit are intentional and usable in completely separate interfaces and pages. They are as follows:
 
+  Applicant Info (.applicant-info)
+ Urgent Action Notice (.urgent-action)
+ Summary Head (.summary-head)
+ Case List (.case-list)
+ Pipeline Progress / Milestone Tracker (.pipeline-progress)
+ Documents List (.docs-list -- If the document exists, show download button, if not exists, show upload button)
+ Case Summary (.summary-case)
+ Funding Summary (.summary-funding)
  Applicant Summary (.summary-applicant)
+ Eligibility Summary (.summary-eligibility)
+ Needs Summary (.summary-needs)
+ Tasks Summary (.summary-tasks) - Include Quick Tasks Modal Button
+ Documents Overview (.overview-documents)
+ Danger Zone (.danger-zone)

.summary-case .summary-funding .summary-applicant .summary-eligibility .summary-needs .summary-tasks (add quick tasks modal button) .overview-documents .danger-zone

