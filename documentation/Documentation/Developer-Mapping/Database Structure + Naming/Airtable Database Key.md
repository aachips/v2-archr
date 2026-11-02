# Index TLDR

Here is a index with:
 1) the table schemas relating to cases in the PSQL/Dummy Database 
 2) the transcribed schema of the fields in the live Airtable table Cases 
 3) what vue demo needs to work 

## PSQL

This is the PSQL schema also replicated in Dummy Database. Some of the necessary fields to pull from aren't in case related tables, but in tables related to submission intake and application. 

```
    cases
        submission_id
        case_number
        status_id
        assigned_caseworker
        assigned_project_manager
        assigned_assessor_id
        intake_completed_at
        assessment_scheduled_at
        assessment_completed_at
        approved_at
        work_started_at
        work_completed_at
        total_budget
        total_actual_cost
        notes
        internal_notes
        created_at
        updated_at
        created_by
        updated_by
    case_funding
        case_id
        funding_source_id
        allocated_amount
        spent_amount
        allocated_at
        allocated_by
        notes
    case_claims
        case_id
        claimed_by_org_id
        expires_at
        is_locked
    case_documents
        case_id
        category_id
        status_id
        file_name
        file_size_bytes
        file_hash
        mime_type
        storage_path
        storage_provider
        storage_bucket
        storage_region
        version_number
        parent_document_id
        metadata
        extracted_text
        thumbnail_path
        uploaded_by
        uploaded_at
        verified_by
        verified_at
        expires_at
        deleted_at
        access_roles
        notes
        created_at
        updated_at
```
## Airtable - ⚓💼Cases (Cases)

These are the Airtable fields, transcribed manually, from Cases. I am not fully sure that naming the table on the Vue environmental variables will work because of the emojis. They need to be named as is, and may need to be without spaces, or emojis. We may be able to rig up an interpretation key between the Airtable and the PSQL schema key. Using the field ID may work, but is not developer friendly in the least. That's what the interpretation layer would be for. 

+ Label - primary field - fld44TlA7nxdbWJfP
+ ACTIVE_🪝claimId - fldPZtgakjzxG4ZEN
+ ARCHR_PARTNER_PROGRAMS - fldJDhcZowrFO4rZu - 
+ city_tag - Multiple select - fldKeiMleFhnvc5Ki - Where is case place located?
+ Count (⚓🎯ARCHR Anchor Projects) - fld3xbJ7wqPiV5SRW
+ Created - created time - fldl6CXXPTRmZ0wPO
+ id(⚓💼Case) - Formula - fldTN4L2QNLGSRTdi
+ id(👤Application) - Lookup - fldqeWVXXUKngn7mc
+ id(👤Application) (from ⚓🎯ARCHR Anchor Projects) - Lookup - fldgjnrlm7VJ8mlZs
+ ids(💼🎯caseProjects) - Rollup - fldH0pzdR0KDEC3rD
+ 💸Draw Request Number (from ⚓🎯ARCHR Anchor Projects) - Lookup - fldUHs09aw2Xiu3Bo
+ 💸Draw Request Org (from ⚓🎯ARCHR Anchor Projects) - Lookup - fldgBbs5cntMudRD7
+ 💸drawORG (from ⚓🎯ARCHR Anchor Projects) - Lookup - fldGQeIY4VDVPQLvC
+ 💼Case Closed - Formula - fldUfhj7gbTXwMfVA
+ 💼Case Opened Date - Date - fldBFVdeE9wEUXZE3
+ 💼caseJSON - Formula - fldYz27CIAs4qwg01
+ 💼→🎯openProjectId - Lookup - fldCvMdAWDP2Zo2Ks
+ 💼→🪝→⚒️🤖clamedRoboNeedIds - Lookup - fldZ3HVuvBReqkUnH
+ 💼→🪝→⚓⚒️clamedAnchorNeedIds - Lookup - fldkROGPkcpRvKdDZ
+ 📍City - Rollup - fldgEUFZ3vUj7UHFr
+ 📚id(rawSub) - Rollup - fldEKlRNNhZ4eBssy
+ 📚💼⚒️🎯JSON - Formula - fldd9ehtxIv6LPKNR
+ 🪝claimIds - Lookup - fldJiMxOb0PkQI7ro
+ 🪝Claims - Link to another record - fld0h5FP5SkSkkoiw
+ 🪝→⚒️countClaimNeeds - Rollup - fldOmL09bHwlXZ7eG
+ 🪝→⚓💜orgId - Lookup - fldrl9p8lNolhD0Fv - Not sure how different from dirOrgID
+ 🪝→💜dirOrgId - Lookup - fldYnDjFpD7sx731L - Airtable Record ID for synced claimed organization on given case
+ 🪝→💜orgLogo - Lookup - fld4YlwiwXIUUyJBZ - Organization logo in proper file and image size located at a directory for partner organization logos
+ 🪝→💜orgShort - Rollup - flddUDfivMrhLpYoX - Abbreviated name of Organization [AAHH, CHC, PODER, etc.]

## Vue Index - 

The field names in quotes need to match with Airtable items in Cases. This is all that is missing from the Vue demo booting up:

// Identity
  caseNumber: "caseNumber", // TODO: confirm. Falls back to projectCode/placecode/record id
  projectCode: "projectCode", // TODO: confirm field name
  placecode: "placecode", // TODO: confirm field name

  // Applicant
  firstName: "applicantFirstName", // TODO: confirm field name
  lastName: "applicantLastName", // TODO: confirm field name
  email: "contactEmail", // TODO: confirm field name
  phone: "cellPhone", // TODO: confirm field name
  address: "homeAddress", // TODO: confirm field name
  city: "homeCity", // TODO: confirm field name
  state: "homeState", // TODO: confirm field name
  zip: "homeZip", // TODO: confirm field name

  // Case state
  status: "status", // TODO: confirm field name
  organization: "organization", // TODO: linked Directory record id(dirOrg) or lookup/text
  submittedAt: "submittedAt", // TODO: confirm field name

  // Household & property
  householdSize: "householdSize", // TODO: confirm field name
  annualIncome: "grossAnnualIncome", // TODO: confirm field name
  homeType: "homeType", // TODO: confirm field name
  yearBuilt: "yearBuilt", // TODO: confirm field name

  // Needs
  repairNeeds: "repairNeeds", // confirmed in "Airtable Database Key.md" (fldI04HqsKogQDM6w)
  urgentIssues: "urgentIssues", // TODO: confirm field name (multi-select or linked)
  additionalDetails: "additionalRepairDetails" // TODO: confirm field name




## 
<table>
    
    <tr>
        <th>Airtable Item</th>
        <th>Airtable Field ID</th>
        <th>JSON Key</th>
	    <th>Vue Variable</th>
	    <th>PSQL Column</th>
        <th>Field Description</th>
    </tr>
    <tr>
        <td>⚒️→⚓Repair Needs</td>
        <td>appWAmMNCsnsAgyTW/tblpifj7kf5aYDsJE/fldI04HqsKogQDM6w</td>
        <td>JSON Key</td>
        <td></td>
        <td></td>
    </tr>
</table>


Repair Needs (from...) | {{anchor.cases.repairNeeds}} | {{}}

I'm having trouble linking and integrating Airtable to Vue in the demo. There are deeper database issues. Many of these table fields are written with emojis, and aren't reader friendly. With spaces and emojis, there would likely be encoding issues naming the fields for referencing. We don't want to alter or change the live database. If something goes wrong, I don't want to get blamed. Right now I want to convert five applications over to the dummy database. The date listed is the start date. I want each of these cases to be written into the PSQL database, making up the extra 

[CHC]-2639BEECHG	X2639BE	2639BEECHG	(📚) FILLOUT_RESULTS_TABLE		Madison	2639 Beech Glen Rd, Mars Hill, NC 28754, USA	(📚)  J. English		Mars Hill			


[AAHH]-146MAPLEAV	[AAHH]-D146MAP	146MAPLEAV	(🗃️) DONOR_PERFECT, (🟥) ARCHR_EMERGENCY, (💸) DRAW, (📚) FILLOUT_RESULTS_TABLE		Buncombe	146 Maple Ave, Candler, NC 28715, USA	(🟥) A. JOHNSON	11/14/2024	1 checked out of 1	Candler	


[AAHH]-1106OLDUSH	[AAHH]-D1106OL	1106OLDUSH	(🗃️) DONOR_PERFECT, (🟥) ARCHR_EMERGENCY, (👷) DSW_UPDATES, (📚) FILLOUT_RESULTS_TABLE		Buncombe	1106 Old US Hwy 70, Black Mountain, NC 28711, USA	(🟥) R.  Wilson 	11/8/2024	0 checked out of 1	Black Mountain	

[AAHH]-136MURDOCK	[AAHH]-D136MUR	136MURDOCK	(🗃️) DONOR_PERFECT, (🟥) ARCHR_EMERGENCY, (👷) DSW_UPDATES, (💸) DRAW, (📚) FILLOUT_RESULTS_TABLE		Buncombe	136 Murdock Ave, Asheville, NC 28801, USA	(🟥) r. foster	11/24/2024	1 checked out of 1	Asheville	

[AAHH]-207ROCKHIL	[AAHH]-D207ROC	207ROCKHIL	(🗃️) DONOR_PERFECT, (📄) NRI COMBINED, (🟥) ARCHR_EMERGENCY, (📄+) NRI+, (📚) FILLOUT_RESULTS_TABLE		Buncombe	207 Rock Hill Rd, Asheville, NC 28803, USA	(🟥) Atkins  A.  ,A. Atkins	11/3/2024	Asheville	