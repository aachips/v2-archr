## Data Categories

### 1. Home/Applicant Data (🏠)

|Token|Label|Type|Description|
|---|---|---|---|
|`{{docHomeFullName}}`|Full Name|string|Applicant's full name|
|`{{docHomeFirstName}}`|First Name|string|Applicant's first name|
|`{{docHomeFullAddress}}`|Full Address|string|Complete home address|
|`{{docHomeStreetAddress}}`|Street Address|string|Street address only|
|`{{docHomeCity}}`|City|string|City name|
|`{{docHomeState}}`|State|string|State|
|`{{docHomeZip}}`|Zip|num|ZIP code|
|`{{docHomeCounty}}`|County|string|County name|
|`{{docHomeGIS_PIN}}`|GIS Pinnum|string|GIS property identifier|
|`{{docHomePhone}}`|Home Phone|string|Contact phone|
|`{{docHomeEmail}}`|Email|string|Contact email|
|`{{docHomeHouseholdSize}}`|Household Size|num|Number of household members|
|`{{docHomeAcrePlus}}`|Acreage >1|string|Property size indicator|
|`{{yearBuilt}}`|Year Built|string|Construction year|
|`{{docHomePhotos}}`|Photos|obj|URL to property photos|
|`{{docHomeMap}}`|Map|obj|URL to property map|

**Purpose:** These tokens populate forms requiring applicant and property information.

---

### 2. Organization Data (💜)

|Token|Label|Type|Description|
|---|---|---|---|
|`{{docOrgShort}}`|Org Abbreviation|string|Short org code|
|`{{docOrgLong}}`|Org Full Name|string|Complete organization name|
|`{{docOrgStreetAddress}}`|Street Address|string|Org mailing address|
|`{{docOrgCity}}`|City|string|Org city|
|`{{docOrgState}}`|State|string|Org state|
|`{{docOrgZip}}`|Zip|num|Org ZIP|
|`{{docOrgPhone}}`|Primary Phone|string|Org phone|
|`{{docOrgEmail}}`|Office Email|string|Org email|
|`{{docOrgFax}}`|Fax Number|string|Org fax|
|`{{docOrgTaxId}}`|EIN|string|Org tax ID|
|`{{docOrgProgram}}`|Partner Program|string|Program name|

**Purpose:** Organization data appears on forms, contracts, and grant documents.

**Lookup Structure:**

text

{lookup_docOrg} → Airtable record containing all organization fields
  ├── docOrgShort
  ├── docOrgLong
  ├── docOrgStreetAddress
  ├── docOrgCity
  ├── docOrgState
  ├── docOrgZip
  ├── docOrgPhone
  ├── docOrgProgram
  ├── docFinalNoticeContacOrg
  ├── docOrgFax
  ├── docOrgEmail
  └── docOrgTaxId

---

### 3. Author/Signature Data (💟)

|Token|Label|Type|Description|
|---|---|---|---|
|`{{docAuthor}}`|Author Name|string|Person who created document|
|`{{docAuthorEmail}}`|Author Email|string|Author's email|
|`{{docAuthorTitle}}`|Author Job Title|string|Author's title/role|
|`{{docAuthorPhone}}`|Author Phone|string|Author's phone|
|`{{docAuthorSignature}}`|Signature|obj|Signature image/data|

**Purpose:** Document authorship tracking and signature collection.

---

### 4. Grant/Funding Data (💸)

|Token|Label|Type|Description|
|---|---|---|---|
|`{{grantNumber}}`|Grant ID|string|Grant identifier|
|`{{docGrantRequestAmount}}`|Request Amount|num|Amount requested from grant|
|`{{docGrantCategoryYear}}`|Grant Category Year|string|Fiscal year designation|
|`{{docGrantFY}}`|Fiscal Year|string|Grant fiscal year|

**Purpose:** Grant reporting and funding requests.

---

### 5. Draw/Financial Data

|Token|Label|Type|Description|
|---|---|---|---|
|`{{drawProjTotal}}`|Construction + Admin Cost|num|Total project cost|
|`{{drawConstCost}}`|Construction Cost|num|Construction cost|
|`{{drawAdminCost}}`|Admin Cost|num|5% of construction cost|
|`{{drawNumber}}`|Draw Number|num|Current draw sequence|
|`{{drawCount}}`|Total Draws|num|Total draws by org/funder|
|`{{drawTotal}}`|Draw Amount|num|Amount for current draw|
|`{{drawAllTotals}}`|All Draw Totals|num|Total draws all sources|
|`{{drawFQFY}}`|Fiscal Quarter Year|string|FQ/FY designation|
|`{{drawProject}}`|Project Record|string|Full project object|
|`{{drawScopeSummary}}`|Scope Summary|string|Summary of repairs|

**Purpose:** Financial draw request forms.

---

### 6. Scope/Repair Data (🎯)

|Token|Label|Type|Description|
|---|---|---|---|
|`{{scopeTreeWork}}`|Tree Work|string|Tree removal/trimming|
|`{{scopeDemo}}`|Demolition|string|Demolition work|
|`{{scopeInteriorDoorsTrim}}`|Interior Doors Trim|string|Door/trim work|
|`{{scopeInteriorFloors}}`|Interior Floors|string|Flooring work|
|`{{scopeInteriorWallsCeilings}}`|Walls Ceilings|string|Wall/ceiling work|
|`{{scopeInteriorPaintingFinishing}}`|Interior Painting|string|Painting work|
|`{{scopeRoofGuttersBoxing}}`|Roof Gutters Boxing|string|Roof/gutter work|
|`{{scopeKitchenBath}}`|Kitchen/Bath|string|Kitchen/bath work|
|`{{scopeHVACPlumbingElectricalSystems}}`|HVAC/Plumbing/Electric|string|Systems work|
|`{{scopeSidingPorchesTrim}}`|Siding Porches Trim|string|Exterior finish work|
|`{{scopeWindowsDoorsGlass}}`|Windows/Doors/Glass|string|Window/door work|
|`{{docScopeSummary}}`|Scope Summary|string|Combined scope text|

**Purpose:** Building scope of work documents and assessments.

|Token|Label|Type|Description|
|---|---|---|---|
|`{{taskName}}`|Task Label|string|Name of repair task|
|`{{taskArea}}`|Task Area|string|Location/area of task|
|`{{taskDetails}}`|Task Details|string|Description|
|`{{taskSub}}`|Subcontractor|string|Assigned sub|
|`{{taskBudget}}`|Task Budget|num|Cost of task|