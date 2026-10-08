---
document_name: Current Platforms and The Great Code Migration
document_type: Technical Overview
version: 1.0
last_updated: 2026-07-10
author: ARCHR Development Team
audience: Developers, System Administrators, Technical Leads
complexity_level: Advanced
estimated_reading_minutes: 5-7 minutes
tags: [migration, platforms, softr, airtable, fillout, postgresql]
---
### Outline

**1. The Current Stack (SaaS-Based)**

|Platform|Purpose|Why We Started There|
|---|---|---|
|**Softr**|Frontend UI|Quick setup, no code, visual builder|
|**Airtable**|Database|Flexible schema, easy to modify|
|**Fillout**|Forms|Conditional logic, integrations|
|**Dropbox**|Document Storage|Simple file management|

**2. Why We're Migrating**

|Issue|Impact|
|---|---|
|**Airtable Limits**|50,000 row limit per base, API rate limits|
|**No True Immutability**|Can't audit history properly|
|**Limited Role-Based Permissions**|Complex access control is hard|
|**No Native Ledger**|Progress tracking is built manually|
|**Integration Complexity**|Multiple platforms = multiple points of failure|
|**Cost**|SaaS costs scale with usage|
|**Vendor Lock-in**|Hard to move to other platforms|

**3. The Target Stack (Code-Based)**

|Component|Technology|Why|
|---|---|---|
|**Frontend**|HTML5, CSS, JavaScript|No dependency, works everywhere|
|**Backend**|PHP 8.1|Widely supported, good for APIs|
|**Database**|PostgreSQL|Full SQL, JSON support, row-level security|
|**Document Generation**|PHP libraries|PDF, DOCX generation|
|**Document Storage**|Dropbox/Z-Drive/S3|Flexible cloud storage|
|**Forms**|Fillout (phasing out) → Custom HTML/JS|Full control, no vendor lock|
|**UI**|Softr (phasing out) → Custom|Full control, mobile-first|

**4. Migration Phases**

|Phase|Timeline|What Happens|
|---|---|---|
|**Phase 1: Database**|Complete|PostgreSQL schema designed and implemented|
|**Phase 2: Backend API**|In Progress|PHP API endpoints built|
|**Phase 3: Document System**|In Progress|Document generation + bucket integration|
|**Phase 4: Task Engine**|In Progress|Immutable ledger, Quick Add|
|**Phase 5: Frontend**|Not Started|Custom HTML/CSS/JS interfaces|
|**Phase 6: Migration**|Not Started|Data migration from Airtable to PostgreSQL|

**5. What Data is Moving**

|Source|Target|Priority|
|---|---|---|
|Intake Submissions|`intake_submissions`|High|
|Case Data|`cases`|High|
|Financial Records|`invoices`, `funding_sources`|High|
|Documents|Document Bucket|High|
|User Accounts|`system_users`|High|
|Assessments|`property_assessments`|Medium|
|Communications|`case_communications`|Medium|
|Volunteer Records|`volunteer_profiles`|Medium|

**6. What Stays the Same**

- The folder structure (document-storage.md)
    
- Document naming convention
    
- Role definitions and permissions
    
- The six-phase workflow
    
- Eligibility criteria
    

**7. What Gets Better**

- **Performance**: Faster queries, real-time updates
    
- **Audit Trail**: Complete, immutable history
    
- **Flexibility**: Can modify any part of the system
    
- **Cost**: No per-user/per-record fees
    
- **Control**: Full ownership of data and code
    
- **Scalability**: No row limits, unlimited growth
    

**8. Migration Timeline**

- **Current State**: Softr + Airtable + Fillout
    
- **Q2-Q3 2026**: Backend migration complete
    
- **Q4 2026**: Frontend migration begins
    
- **Q1 2027**: Full migration complete
    
- **Q2 2027**: Sunset SaaS platforms
    

**9. How Developers Can Prepare**

- Learn PostgreSQL (the target database)
    
- Understand the schema mappings
    
- Review the API documentation
    
- Get familiar with the codebase (GitHub)
    
- Test with the staging environment