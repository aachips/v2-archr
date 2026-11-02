When submission submitted -> 4 different systems interacting at once
1) Submission database = SENT
2) Placecodes -> Attempts to locate through GIS name, address, tokens, ...
3) Eligibility Check Triggers - WORKING ON IT
4) On certain intakes, there is an auto-claim layer. If you fill out on the organization's site (Poder, Land of Sky..) will submit already claimed
5) Parsing Repair Request into individual items
6) Document Generation -> Intake Submission Receipt (DOCTYPE INF)
7) Mailhost for Email Receipts

Intake form needs to be customizable for Organization Specific Embed, and with this comes auto-claim for that organization if pass eligibility

Claims interfaces directly with repair needs and is linked to the submission and application, but doesn't interact directly with those meaningfully. Claim is on repair needs. We are not claiming the application and the family and household, just a repair need. 

Checks for existing application and placecode automatically. If not found, one of each is created. Then run Eligibility Checker. Eligibility and Repair Needs Simultaneous. If auto-claim, claim record is created. All requests generated from submission are attached and new case record is created. 

Need GIS check before eligibility. That gets the building value if that exists. Ownership. Specific Neighborhood. Different API call for Buncombe and Madison county, data structured a little different, separate table called GIS_queries shared between Buncombe and Madison. Whole bunch of formulas that collapse that data into one building value, one ownership, type of home, etc. 

With GIS Checking, [GIS_data is the main checker](https://airtable.com/appWAmMNCsnsAgyTW/wflT8YYJ15JmKgLYX/wacBPrtyJC21HnOHU). Have had to rebuild it three times so far from updates and changes to the county site GIS Property Card API. Keep the checks isolated from Buncombe and Madison County. 

JSON fields outputted: 
![[gis-scripts.png]]

Await fetch.data 

![[gisdata.png]]


![[gis-data.png]]

Through the GIS on Buncombe County, it pulls from a pin number. PIN (Parsel Identifcation Number) is pretty standard for state and county GIS systems. 

Possibility of using Just Three Words as a method for a requestor to pull up or identify their application by just having to write down or remember those three words. Zip Code, Birthday, just three words. 

Account for massive tech divide. Most have cell phones by now. Many within communities of service may have not sent an email in the past five years. If ever. 

Requestor Account is useful especially for helpful grandson. Also helpful to automate and update information in a guided interface way. 

Story of Arthur Maynard who lives on Maynard Road -> Eligibility Checking 

Documentation: Tech Divide and Communication Access - 