-- =====================================================
-- ARCHR Document Management Schema
-- Hybrid SQL + Object Storage (S3/Dropbox/Google Cloud)

-- ## Implementation Recommendations
-- 
-- ### Phase 1: Foundation
-- 
-- 1. Set up object storage (Dropbox API, AWS S3, or Google Cloud Storage)
-- 2. Implement the SQL schema above
-- 3. Create basic upload/download endpoints
--     
-- 
-- ### Phase 2: Document Generation
-- 
-- 1. Build PDF generation service (using puppeteer, wkhtmltopdf, or Docmosis)
-- 2. Create contract and certificate templates  
-- 3. Implement signature collection (DocuSign or similar)
--     
-- 
-- ### Phase 3: Automation
-- 
-- 1. Property card integration with county assessor APIs
-- 2. OCR pipeline for income verification documents
-- 3. Auto-categorization of uploaded documents
--     
-- 
-- ### Phase 4: Advanced Features
-- 
-- 1. Full-text search across documents 
-- 2. AI-powered document classification
-- 3. Batch operations for common document types
--     
-- ## Key Considerations
-- 
-- 1. **Security**: All documents should be encrypted at rest and in transit
-- 2. **Backup**: Implement 3-2-1 backup strategy for all documents 
-- 3. **Compliance**: Ensure document retention meets grant requirements (typically 7-10 -- years)  
-- 4. **Performance**: Use thumbnails for image previews, lazy loading for large PDFs--  
-- 5. **Offline Support**: Consider mobile app for field workers to upload photos without  internet
--     
-- This hybrid approach gives you the structure of SQL with the flexibility of object storage, providing a scalable, searchable document management system that integrates with your case management workflow.
-- =====================================================

-- Document categories (taxonomy)
CREATE TABLE document_categories (
    id SERIAL PRIMARY KEY,
    category_code VARCHAR(50) UNIQUE NOT NULL,
    category_name VARCHAR(100) NOT NULL,
    parent_category_id INTEGER REFERENCES document_categories(id),
    storage_path_template TEXT, -- e.g., "/cases/{case_number}/property/"
    requires_encryption BOOLEAN DEFAULT TRUE,
    retention_months INTEGER,
    description TEXT
);

INSERT INTO document_categories (category_code, category_name, storage_path_template, requires_encryption, retention_months) VALUES
    ('APPLICATION', 'Application Documents', '/cases/{case_number}/application/', true, 120), -- 10 years
    ('PROPERTY', 'Property Records', '/cases/{case_number}/property/', true, 120),
    ('INCOME', 'Income Verification', '/cases/{case_number}/income/', true, 84), -- 7 years
    ('ASSESSMENT', 'Property Assessments', '/cases/{case_number}/assessments/', true, 120),
    ('ASSESSMENT_PHOTOS_BEFORE', 'Before Photos', '/cases/{case_number}/assessments/initial/photos/', true, 120),
    ('ASSESSMENT_PHOTOS_DURING', 'During Photos', '/cases/{case_number}/assessments/final/photos/', true, 120),
    ('ASSESSMENT_PHOTOS_AFTER', 'After Photos', '/cases/{case_number}/completion/final_photos/', true, 120),
    ('CONTRACT', 'Repair Contracts', '/cases/{case_number}/contracts/', true, 120),
    ('CHANGE_ORDER', 'Change Orders', '/cases/{case_number}/contracts/', true, 120),
    ('WORK_ORDER', 'Work Orders', '/cases/{case_number}/work_orders/{work_order_number}/', true, 84),
    ('QUOTE', 'Subcontractor Quotes', '/cases/{case_number}/financial/quotes/', true, 36), -- 3 years
    ('INVOICE', 'Invoices', '/cases/{case_number}/financial/invoices/', true, 84),
    ('GRANT', 'Grant Documents', '/cases/{case_number}/financial/grants/', true, 120),
    ('ENV_REVIEW', 'Environmental Review', '/cases/{case_number}/financial/grants/', true, 120),
    ('SHPO', 'SHPO Records', '/cases/{case_number}/financial/grants/', true, 120),
    ('COMPLETION', 'Completion Certificate', '/cases/{case_number}/completion/', true, 120),
    ('COMMUNICATION', 'Communications', '/cases/{case_number}/communications/', true, 36),
    ('TEMPLATE', 'System Templates', '/shared/templates/', false, 9999); -- Permanent

-- Document status tracking
CREATE TABLE document_statuses (
    id SERIAL PRIMARY KEY,
    status_code VARCHAR(50) UNIQUE NOT NULL,
    status_name VARCHAR(100) NOT NULL
);

INSERT INTO document_statuses (status_code, status_name) VALUES
    ('PENDING', 'Pending Upload'),
    ('UPLOADED', 'Uploaded - Pending Processing'),
    ('PROCESSING', 'Processing'),
    ('VERIFIED', 'Verified'),
    ('REJECTED', 'Rejected'),
    ('ARCHIVED', 'Archived'),
    ('DELETED', 'Deleted');

-- Main documents table
CREATE TABLE case_documents (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    category_id INTEGER REFERENCES document_categories(id),
    status_id INTEGER REFERENCES document_statuses(id) DEFAULT 1,
    
    -- File metadata
    file_name VARCHAR(255) NOT NULL,
    file_size_bytes BIGINT,
    file_hash VARCHAR(64), -- SHA-256 for deduplication
    mime_type VARCHAR(100),
    storage_path VARCHAR(1000) NOT NULL, -- Relative path in object storage
    storage_provider VARCHAR(50) DEFAULT 'dropbox', -- dropbox, s3, gcs, local
    storage_bucket VARCHAR(255),
    storage_region VARCHAR(100),
    
    -- Versioning
    version_number INTEGER DEFAULT 1,
    parent_document_id INTEGER REFERENCES case_documents(id), -- For version chains
    
    -- Dynamic metadata (JSON for flexible schema)
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Extracted data (for search/indexing)
    extracted_text TEXT, -- OCR or PDF text extraction
    thumbnail_path VARCHAR(1000), -- For images
    
    -- Tracking
    uploaded_by INTEGER REFERENCES system_users(id),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    verified_by INTEGER REFERENCES system_users(id),
    verified_at TIMESTAMP,
    
    -- Retention
    expires_at TIMESTAMP,
    deleted_at TIMESTAMP,
    
    -- Access control
    access_roles TEXT[], -- Which roles can view this document
    
    notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Document generation templates
CREATE TABLE document_templates (
    id SERIAL PRIMARY KEY,
    template_code VARCHAR(50) UNIQUE NOT NULL,
    template_name VARCHAR(200) NOT NULL,
    category_id INTEGER REFERENCES document_categories(id),
    template_file_path VARCHAR(1000), -- Path to template file (DOCX, PDF form)
    template_type VARCHAR(50), -- contract, certificate, application, change_order
    output_format VARCHAR(20) DEFAULT 'pdf', -- pdf, docx, html
    requires_signature BOOLEAN DEFAULT FALSE,
    signature_fields JSONB, -- Coordinates/field names for signature placement
    version INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Document generation jobs (async PDF generation)
CREATE TABLE document_generation_jobs (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id),
    template_id INTEGER REFERENCES document_templates(id),
    status VARCHAR(20) DEFAULT 'pending', -- pending, processing, completed, failed
    data_source JSONB NOT NULL, -- The data to populate the template
    output_document_id INTEGER REFERENCES case_documents(id),
    error_message TEXT,
    priority INTEGER DEFAULT 5,
    created_by INTEGER REFERENCES system_users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    expires_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP + INTERVAL '7 days'
);

-- Document access logs
CREATE TABLE document_access_log (
    id SERIAL PRIMARY KEY,
    document_id INTEGER REFERENCES case_documents(id) ON DELETE CASCADE,
    accessed_by INTEGER REFERENCES system_users(id),
    access_type VARCHAR(20), -- view, download, print, share
    ip_address INET,
    user_agent TEXT,
    accessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Document share links (temporary access for external parties)
CREATE TABLE document_share_links (
    id SERIAL PRIMARY KEY,
    document_id INTEGER REFERENCES case_documents(id) ON DELETE CASCADE,
    share_token UUID DEFAULT gen_random_uuid() UNIQUE,
    shared_by INTEGER REFERENCES system_users(id),
    recipient_email VARCHAR(255),
    expires_at TIMESTAMP,
    max_accesses INTEGER,
    access_count INTEGER DEFAULT 0,
    requires_auth BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- AUTOMATED DOCUMENT GENERATION FUNCTIONS
-- =====================================================

-- Function to generate property card (simplified - would call external API)
CREATE OR REPLACE FUNCTION generate_property_card(
    p_case_id INTEGER,
    p_parcel_id VARCHAR
)
RETURNS INTEGER AS $$
DECLARE
    v_document_id INTEGER;
    v_case_record RECORD;
    v_property_data JSONB;
BEGIN
    -- Get case information
    SELECT c.*, s.home_address, s.home_city, s.home_zip, s.home_type, s.year_built
    INTO v_case_record
    FROM cases c
    JOIN intake_submissions s ON c.submission_id = s.id
    WHERE c.id = p_case_id;
    
    -- In production, this would call a county assessor API or web scraper
    -- For now, we construct a JSONB object with available data
    v_property_data = jsonb_build_object(
        'parcel_id', p_parcel_id,
        'property_address', v_case_record.home_address,
        'property_city', v_case_record.home_city,
        'property_zip', v_case_record.home_zip,
        'year_built', v_case_record.year_built,
        'property_type', v_case_record.home_type,
        'generated_at', CURRENT_TIMESTAMP,
        'source', 'system_generated'
    );
    
    -- Create a document record
    INSERT INTO case_documents (
        case_id, category_id, status_id, file_name, storage_path, 
        metadata, uploaded_by, access_roles
    ) VALUES (
        p_case_id,
        (SELECT id FROM document_categories WHERE category_code = 'PROPERTY'),
        (SELECT id FROM document_statuses WHERE status_code = 'PENDING'),
        'property_card_' || p_case_id || '_' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '.json',
        '/cases/' || v_case_record.case_number || '/property/property_card.json',
        v_property_data,
        NULL,
        ARRAY['ADMIN', 'CASEWORKER', 'ASSESSOR']
    ) RETURNING id INTO v_document_id;
    
    -- Queue a job to convert to PDF if needed
    -- This would be handled by a separate worker process
    
    RETURN v_document_id;
END;
$$ LANGUAGE plpgsql;

-- Function to generate contract from assessment
CREATE OR REPLACE FUNCTION generate_contract(
    p_case_id INTEGER,
    p_template_version INTEGER DEFAULT 1
)
RETURNS INTEGER AS $$
DECLARE
    v_document_id INTEGER;
    v_case_record RECORD;
    v_assessment RECORD;
    v_contract_data JSONB;
BEGIN
    -- Get case and assessment data
    SELECT c.*, s.applicant_first_name, s.applicant_last_name, s.home_address
    INTO v_case_record
    FROM cases c
    JOIN intake_submissions s ON c.submission_id = s.id
    WHERE c.id = p_case_id;
    
    -- Get approved assessment
    SELECT * INTO v_assessment
    FROM property_assessments
    WHERE case_id = p_case_id
    ORDER BY assessment_date DESC
    LIMIT 1;
    
    -- Build contract data
    v_contract_data = jsonb_build_object(
        'case_number', v_case_record.case_number,
        'applicant_name', v_case_record.applicant_first_name || ' ' || v_case_record.applicant_last_name,
        'property_address', v_case_record.home_address,
        'repair_scope', v_assessment.recommended_repairs,
        'total_estimate', v_assessment.total_estimate,
        'estimated_hours', v_assessment.estimated_hours,
        'start_date', (CURRENT_DATE + INTERVAL '14 days'),
        'completion_target', (CURRENT_DATE + INTERVAL '60 days'),
        'terms_and_conditions', 'Standard repair terms apply...',
        'generated_at', CURRENT_TIMESTAMP,
        'template_version', p_template_version
    );
    
    -- Queue for PDF generation
    INSERT INTO document_generation_jobs (
        case_id, template_id, data_source, created_by
    ) VALUES (
        p_case_id,
        (SELECT id FROM document_templates WHERE template_code = 'REPAIR_CONTRACT' AND is_active = true),
        v_contract_data,
        NULL
    );
    
    -- Create document record (PDF will be linked when generation completes)
    INSERT INTO case_documents (
        case_id, category_id, status_id, file_name, storage_path,
        metadata, access_roles
    ) VALUES (
        p_case_id,
        (SELECT id FROM document_categories WHERE category_code = 'CONTRACT'),
        (SELECT id FROM document_statuses WHERE status_code = 'PENDING'),
        v_case_record.case_number || '_contract_v1.pdf',
        '/cases/' || v_case_record.case_number || '/contracts/' || v_case_record.case_number || '_contract_v1.pdf',
        v_contract_data,
        ARRAY['ADMIN', 'CASEWORKER', 'PROJECT_MANAGER', 'APPLICANT']
    ) RETURNING id INTO v_document_id;
    
    -- Update generation job with document ID
    UPDATE document_generation_jobs 
    SET output_document_id = v_document_id 
    WHERE case_id = p_case_id 
    AND output_document_id IS NULL;
    
    RETURN v_document_id;
END;
$$ LANGUAGE plpgsql;

-- Function to batch upload site photos
CREATE OR REPLACE FUNCTION register_site_photos(
    p_case_id INTEGER,
    p_photos JSONB, -- Array of {file_name, file_data_base64, photo_type, timestamp}
    p_uploaded_by INTEGER
)
RETURNS TABLE(photo_id INTEGER, storage_path VARCHAR) AS $$
DECLARE
    v_photo RECORD;
    v_case_number VARCHAR;
    v_category_id INTEGER;
    v_doc_id INTEGER;
    v_storage_path VARCHAR;
BEGIN
    -- Get case number
    SELECT case_number INTO v_case_number FROM cases WHERE id = p_case_id;
    
    FOR v_photo IN SELECT * FROM jsonb_to_recordset(p_photos) AS x(file_name TEXT, photo_type TEXT, capture_timestamp TIMESTAMP)
    LOOP
        -- Determine category based on photo type
        SELECT id INTO v_category_id FROM document_categories 
        WHERE category_code = CASE v_photo.photo_type
            WHEN 'before' THEN 'ASSESSMENT_PHOTOS_BEFORE'
            WHEN 'during' THEN 'ASSESSMENT_PHOTOS_DURING'
            WHEN 'after' THEN 'ASSESSMENT_PHOTOS_AFTER'
            ELSE 'ASSESSMENT_PHOTOS_BEFORE'
        END;
        
        -- Generate storage path
        v_storage_path := '/cases/' || v_case_number || '/assessments/' || 
            CASE v_photo.photo_type
                WHEN 'before' THEN 'initial/photos/'
                WHEN 'during' THEN 'final/photos/'
                WHEN 'after' THEN 'completion/final_photos/'
            END || 
            v_photo.photo_type || '_' || 
            TO_CHAR(COALESCE(v_photo.capture_timestamp, CURRENT_TIMESTAMP), 'YYYYMMDD_HH24MISS') || 
            '_' || v_photo.file_name;
        
        -- Create document record
        INSERT INTO case_documents (
            case_id, category_id, status_id, file_name, storage_path,
            uploaded_by, mime_type, access_roles, metadata
        ) VALUES (
            p_case_id, v_category_id, 
            (SELECT id FROM document_statuses WHERE status_code = 'PROCESSING'),
            v_photo.file_name, v_storage_path,
            p_uploaded_by, 'image/jpeg',
            ARRAY['ADMIN', 'ASSESSOR', 'CREW_LEAD', 'PROJECT_MANAGER'],
            jsonb_build_object('photo_type', v_photo.photo_type, 'capture_timestamp', v_photo.capture_timestamp)
        ) RETURNING id INTO v_doc_id;
        
        photo_id := v_doc_id;
        storage_path := v_storage_path;
        RETURN NEXT;
    END LOOP;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- DOCUMENT NAMING CONVENTION STANDARDS
-- =====================================================

/*

DOCUMENT NAMING CONVENTION STANDARD v1.0

Format: {case_number}_{document_type}_{version_or_date}_{descriptor}.{extension}

Components:
- case_number: ARCHR-YYYY-XXXXXX (e.g., ARCHR-2024-001234)
- document_type: 2-4 letter code
- version_or_date: v{number} OR YYYYMMDD
- descriptor: Optional human-readable identifier
- extension: pdf, jpg, png, json, docx

Document Type Codes:
- APP = Application
- PROP = Property Card
- DEED = Deed/Title
- TAX = Tax Record
- INC = Income Verification (INC_SS, INC_W2, INC_PAYSTUB)
- ASSESS = Assessment Report
- PH_B = Before Photo
- PH_D = During Photo  
- PH_A = After Photo
- CONT = Contract
- CO = Change Order
- WO = Work Order
- QUOTE = Subcontractor Quote
- INV = Invoice
- GRANT = Grant Document
- ENV = Environmental Review
- SHPO = Historic Preservation
- CERT = Certificate of Completion
- COMM = Communication Log

Examples:
ARCHR-2024-001234_APP_v1.pdf
ARCHR-2024-001234_PROP_20241201.pdf
ARCHR-2024-001234_INC_SS_20241115.pdf
ARCHR-2024-001234_PH_B_20241201_roof_before.jpg
ARCHR-2024-001234_CONT_v1_signed.pdf
ARCHR-2024-001234_WO_001_v1.pdf
ARCHR-2024-001234_CERT_final.pdf

*/

-- Function to validate document naming
CREATE OR REPLACE FUNCTION validate_document_name(p_filename VARCHAR)
RETURNS BOOLEAN AS $$
BEGIN
    -- Check pattern: {case_number}_{doc_type}_{version_or_date}_{optional}.{ext}
    RETURN p_filename ~ '^ARCHR-\d{4}-\d{6}_[A-Z]{2,5}_[v\d+|YYYYMMDD](_[a-z0-9_]+)?\.(pdf|jpg|jpeg|png|json|docx)$';
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- STORAGE PROVIDER CONFIGURATION
-- =====================================================

CREATE TABLE storage_providers (
    id SERIAL PRIMARY KEY,
    provider_name VARCHAR(50) UNIQUE NOT NULL, -- dropbox, s3, gcs, local
    is_default BOOLEAN DEFAULT FALSE,
    configuration JSONB NOT NULL, -- API keys, buckets, regions (encrypted)
    base_url VARCHAR(500),
    max_file_size_bytes BIGINT DEFAULT 104857600, -- 100MB default
    allowed_mime_types TEXT[],
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default provider (example - would be configured per deployment)
INSERT INTO storage_providers (provider_name, is_default, configuration, base_url) VALUES
    ('dropbox', true, '{"app_key":"placeholder","app_secret":"placeholder"}', 'https://www.dropbox.com/');

-- =====================================================
-- VIEWS FOR DOCUMENT DASHBOARD
-- =====================================================

-- Case document inventory view
CREATE VIEW case_document_inventory AS
SELECT 
    c.id as case_id,
    c.case_number,
    dc.category_code,
    dc.category_name,
    COUNT(d.id) as document_count,
    COUNT(CASE WHEN d.status_id = (SELECT id FROM document_statuses WHERE status_code = 'VERIFIED') THEN 1 END) as verified_count,
    COUNT(CASE WHEN d.status_id = (SELECT id FROM document_statuses WHERE status_code = 'PENDING') THEN 1 END) as pending_count,
    MAX(d.uploaded_at) as last_upload,
    -- PostgreSQL requires the ORDER BY expression to appear in the argument
    -- list when DISTINCT is used inside an aggregate. Order by file_name
    -- here; for true recency ordering, query case_documents directly.
    ARRAY_AGG(DISTINCT d.file_name ORDER BY d.file_name) as recent_documents
FROM cases c
CROSS JOIN document_categories dc
LEFT JOIN case_documents d ON c.id = d.case_id AND dc.id = d.category_id
WHERE dc.parent_category_id IS NOT NULL -- Exclude parent categories
GROUP BY c.id, c.case_number, dc.category_code, dc.category_name
ORDER BY c.case_number, dc.category_code;

-- Documents requiring verification
CREATE VIEW pending_verification_documents AS
SELECT 
    d.id,
    c.case_number,
    s.applicant_first_name,
    s.applicant_last_name,
    dc.category_name,
    d.file_name,
    d.uploaded_by,
    u.full_name as uploaded_by_name,
    d.uploaded_at,
    d.extracted_text
FROM case_documents d
JOIN cases c ON d.case_id = c.id
JOIN intake_submissions s ON c.submission_id = s.id
JOIN document_categories dc ON d.category_id = dc.id
LEFT JOIN system_users u ON d.uploaded_by = u.id
WHERE d.status_id = (SELECT id FROM document_statuses WHERE status_code = 'UPLOADED')
    OR d.status_id = (SELECT id FROM document_statuses WHERE status_code = 'PROCESSING')
ORDER BY d.uploaded_at ASC;