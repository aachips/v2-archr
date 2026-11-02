---
document_name: Airtable Base IDs Quick Reference
document_type: Technical Reference
version: 1.0
last_updated: 2026-08-01
author: ARCHR Development Team
audience: Developers, Admins
complexity_level: Beginner
estimated_reading_minutes: 2
tags: [airtable, base-id, reference]
---

These are the core bases in Airtable and the BaseIDs. 

+ The format of these are 'app' and then 14 random characters.
+ TableIDs are 'tbl' and then 14 random characters.
+ Records are 'rec' and then 14 random chracters.
+ Field IDs are 'fld' and 14 random characters.

This is the basic structure on how to format an API call. You can get to *any* record from appID/tableID/recordID through airtable.com/

🟦[D] ARCHR Project Documents	appjB8RyRb8VryrTd
🟦[D](v1-2) ANCHOR Records	appWAmMNCsnsAgyTW
🟦[D] (v2) ARCHR Directory	appfCMatXfknvXNkc
🟦[D] ARCHR Multi Axis Task Library	appfhuefuekoCvL3J
🟦(📗) Fillout Results	appdJHg317xbe3Sd4
🟦[P] ARCHR Eligibility	appIFBi7Rln8yFhCs
🟦[P] ARCHR Progress Tracker	appjHNCJFj14C30X3
🟦ARCHR Partner Programs	appAmaLnsO0BTkKAk
🟦[D] ARCHR Repair Requests	appBq2Z1a9dssVVbL

Example URL: https://airtable.com/appjB8RyRb8VryrTd/tblqsqy5c8nOSKWCV/viwn7LNBcHbGBJ7Wa/fldVrqd4lf1ZHeLIV
Dissected: https://airtable.com/{baseID}/{tableID}/{viewID}/{fieldID/recordID}

Big Four Tables on Airtable:

+ ANCHOR
+ Progress Track Ledger
+ Fillout Result
+ ARCHR Eligibility