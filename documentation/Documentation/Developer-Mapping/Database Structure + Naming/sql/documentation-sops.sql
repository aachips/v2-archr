-- =====================================================
-- ARCHR Help Documentation Library Schema
-- Open Source SOP & User Guide Management System
-- =====================================================

-- Documentation categories (high-level organization)
CREATE TABLE help_categories (
    id SERIAL PRIMARY KEY,
    category_code VARCHAR(50) UNIQUE NOT NULL,
    category_name VARCHAR(100) NOT NULL,
    parent_category_id INTEGER REFERENCES help_categories(id),
    display_order INTEGER DEFAULT 0,
    icon_class VARCHAR(100), -- CSS icon class
    is_active BOOLEAN DEFAULT TRUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Root categories
INSERT INTO help_categories (category_code, category_name, display_order, description) VALUES
    ('GETTING_STARTED', 'Getting Started', 1, 'First-time user guides and account setup'),
    ('APPLICANTS', 'For Applicants & Homeowners', 2, 'How to apply for home repair assistance'),
    ('CASEWORKERS', 'For Caseworkers', 3, 'Managing applications and client communication'),
    ('ASSESSORS', 'For Assessors', 4, 'Conducting home assessments and estimates'),
    ('PROJECT_MANAGEMENT', 'For Project Managers & Crew', 5, 'Managing repair projects and work orders'),
    ('FINANCE', 'For Finance Staff', 6, 'Budgeting, invoicing, and grant compliance'),
    ('VOLUNTEERS', 'For Volunteers', 7, 'Task assignments and hour tracking'),
    ('ADMIN', 'For Administrators', 8, 'System configuration and user management'),
    ('TROUBLESHOOTING', 'Troubleshooting & FAQ', 9, 'Common issues and solutions'),
    ('DEVELOPER', 'For Developers', 10, 'API documentation and system architecture');

-- Document types (doc_type field)
CREATE TABLE help_document_types (
    id SERIAL PRIMARY KEY,
    type_code VARCHAR(50) UNIQUE NOT NULL,
    type_name VARCHAR(100) NOT NULL,
    icon_class VARCHAR(100),
    is_interactive BOOLEAN DEFAULT FALSE, -- Is this a tutorial/walkthrough?
    requires_authentication BOOLEAN DEFAULT TRUE,
    description TEXT
);

INSERT INTO help_document_types (type_code, type_name, icon_class, description) VALUES
    ('SOP', 'Standard Operating Procedure', 'fa-file-alt', 'Step-by-step process documentation'),
    ('GUIDE', 'User Guide', 'fa-book', 'Comprehensive feature guide'),
    ('FAQ', 'Frequently Asked Questions', 'fa-question-circle', 'Common questions and answers'),
    ('TUTORIAL', 'Interactive Tutorial', 'fa-graduation-cap', 'Walkthrough with screenshots/video'),
    ('CHECKLIST', 'Checklist', 'fa-check-square', 'Task-based verification list'),
    ('REFERENCE', 'Quick Reference', 'fa-table', 'One-page cheat sheet or lookup table'),
    ('VIDEO', 'Video Tutorial', 'fa-video', 'Recorded training session'),
    ('TEMPLATE', 'Template', 'fa-file', 'Form, letter, or document template'),
    ('POLICY', 'Policy Document', 'fa-gavel', 'Organizational policy and compliance'),
    ('RELEASE_NOTES', 'Release Notes', 'fa-code-branch', 'System update documentation');

-- Main help documents table
CREATE TABLE help_documents (
    id SERIAL PRIMARY KEY,
    document_id VARCHAR(50) UNIQUE NOT NULL, -- Human-readable ID, e.g., "SOP-001"
    doc_type_id INTEGER REFERENCES help_document_types(id),
    category_id INTEGER REFERENCES help_categories(id),
    
    -- Core metadata
    title VARCHAR(500) NOT NULL,
    subtitle VARCHAR(500),
    version VARCHAR(20) DEFAULT '1.0',
    
    -- Content storage
    content TEXT, -- Markdown or HTML content (for SEO/display)
    content_format VARCHAR(20) DEFAULT 'markdown', -- markdown, html, plain
    file_path VARCHAR(1000), -- Path to PDF or other binary file (optional)
    
    -- For multi-language support
    language VARCHAR(5) DEFAULT 'en', -- en, es, etc.
    original_document_id INTEGER REFERENCES help_documents(id), -- For translations
    
    -- Authorship & ownership
    author VARCHAR(200),
    author_email VARCHAR(255),
    owner_role_id INTEGER REFERENCES roles(id), -- Which role owns this document
    reviewer_id INTEGER REFERENCES system_users(id),
    reviewer_notes TEXT,
    
    -- Target audience (which roles should see this)
    target_roles TEXT[], -- Array of role codes (e.g., {'ADMIN', 'CASEWORKER'})
    
    -- SEO and discovery
    tags TEXT[], -- Array of keywords for search
    search_keywords TEXT[], -- Additional search terms
    
    -- Estimated reading time
    estimated_minutes INTEGER,
    
    -- Related documents
    related_documents INTEGER[], -- Array of help_document IDs
    
    -- Prerequisites (other docs to read first)
    prerequisite_documents INTEGER[], -- Array of help_document IDs
    
    -- Status and lifecycle
    status VARCHAR(20) DEFAULT 'draft', -- draft, review, published, archived, deprecated
    is_featured BOOLEAN DEFAULT FALSE, -- Show on help homepage
    is_required BOOLEAN DEFAULT FALSE, -- Required reading for certain roles
    
    -- Metrics (for analytics)
    view_count INTEGER DEFAULT 0,
    helpful_count INTEGER DEFAULT 0,
    not_helpful_count INTEGER DEFAULT 0,
    last_viewed_at TIMESTAMP,
    
    -- Scheduling
    publish_at TIMESTAMP,
    expires_at TIMESTAMP, -- For time-sensitive content
    review_required_by DATE, -- Date when document needs review
    
    -- Version control
    previous_version_id INTEGER REFERENCES help_documents(id),
    change_notes TEXT,
    
    -- Tracking
    created_by INTEGER REFERENCES system_users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by INTEGER REFERENCES system_users(id),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP,
    reviewed_by INTEGER REFERENCES system_users(id),
    archived_at TIMESTAMP,
    archived_by INTEGER REFERENCES system_users(id),
    
    -- Custom fields (flexible metadata)
    custom_fields JSONB DEFAULT '{}'::jsonb,
    
    -- Notes field (as requested)
    notes TEXT,
    
    CONSTRAINT valid_status CHECK (status IN ('draft', 'review', 'published', 'archived', 'deprecated'))
);

-- TODO: full-text search index.
-- PostgreSQL rejects this expression because the implicit text->regconfig
-- conversion in to_tsvector('english', ...) is STABLE, not IMMUTABLE, and
-- index expressions must be IMMUTABLE. To restore search acceleration:
--   1. Define an IMMUTABLE wrapper, e.g.
--        CREATE FUNCTION help_docs_search_tsv(...)
--          RETURNS tsvector AS $$
--          SELECT to_tsvector('pg_catalog.english'::regconfig, ...);
--        $$ LANGUAGE SQL IMMUTABLE;
--   2. CREATE INDEX ... ON help_documents USING GIN (help_docs_search_tsv(...));
-- Or add a STORED generated column populated by the wrapper and GIN-index that.

-- Document attachments (screenshots, diagrams, supplementary files)
CREATE TABLE help_document_attachments (
    id SERIAL PRIMARY KEY,
    document_id INTEGER REFERENCES help_documents(id) ON DELETE CASCADE,
    attachment_type VARCHAR(50), -- screenshot, diagram, video, audio, dataset
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(1000) NOT NULL,
    file_size_bytes BIGINT,
    mime_type VARCHAR(100),
    alt_text VARCHAR(500), -- For accessibility
    caption TEXT,
    display_order INTEGER DEFAULT 0,
    uploaded_by INTEGER REFERENCES system_users(id),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Document versions history
CREATE TABLE help_document_versions (
    id SERIAL PRIMARY KEY,
    document_id INTEGER REFERENCES help_documents(id) ON DELETE CASCADE,
    version_number VARCHAR(20) NOT NULL,
    title VARCHAR(500),
    content TEXT,
    change_notes TEXT,
    created_by INTEGER REFERENCES system_users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_current BOOLEAN DEFAULT FALSE
);

-- User feedback on documents
CREATE TABLE help_document_feedback (
    id SERIAL PRIMARY KEY,
    document_id INTEGER REFERENCES help_documents(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES system_users(id),
    is_helpful BOOLEAN,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User progress tracking (for required docs or training)
CREATE TABLE help_user_progress (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES system_users(id) ON DELETE CASCADE,
    document_id INTEGER REFERENCES help_documents(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'not_started', -- not_started, in_progress, completed
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    last_position INTEGER, -- For long docs, scroll position
    notes TEXT,
    UNIQUE(user_id, document_id)
);

-- Search queries log (for analytics)
CREATE TABLE help_search_log (
    id SERIAL PRIMARY KEY,
    search_term VARCHAR(500),
    user_id INTEGER REFERENCES system_users(id),
    result_count INTEGER,
    clicked_document_id INTEGER REFERENCES help_documents(id),
    search_type VARCHAR(20), -- quick, advanced, facet
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Document reviews and approval workflow
CREATE TABLE help_document_reviews (
    id SERIAL PRIMARY KEY,
    document_id INTEGER REFERENCES help_documents(id) ON DELETE CASCADE,
    reviewer_id INTEGER REFERENCES system_users(id),
    review_status VARCHAR(20), -- pending, approved, changes_requested, rejected
    comments TEXT,
    requested_changes TEXT,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Function to increment view count
CREATE OR REPLACE FUNCTION increment_help_view(p_document_id INTEGER)
RETURNS void AS $$
BEGIN
    UPDATE help_documents 
    SET view_count = view_count + 1,
        last_viewed_at = CURRENT_TIMESTAMP
    WHERE id = p_document_id;
END;
$$ LANGUAGE plpgsql;

-- Function to record feedback
CREATE OR REPLACE FUNCTION record_help_feedback(
    p_document_id INTEGER,
    p_user_id INTEGER,
    p_is_helpful BOOLEAN,
    p_rating INTEGER DEFAULT NULL,
    p_comment TEXT DEFAULT NULL
)
RETURNS void AS $$
BEGIN
    INSERT INTO help_document_feedback (document_id, user_id, is_helpful, rating, comment)
    VALUES (p_document_id, p_user_id, p_is_helpful, p_rating, p_comment);
    
    -- Update aggregate counts on document
    UPDATE help_documents 
    SET helpful_count = (
        SELECT COUNT(*) FROM help_document_feedback 
        WHERE document_id = p_document_id AND is_helpful = true
    ),
    not_helpful_count = (
        SELECT COUNT(*) FROM help_document_feedback 
        WHERE document_id = p_document_id AND is_helpful = false
    )
    WHERE id = p_document_id;
END;
$$ LANGUAGE plpgsql;

-- Function to get documents by role
CREATE OR REPLACE FUNCTION get_docs_for_role(p_role_code VARCHAR)
RETURNS TABLE(
    id INTEGER,
    title VARCHAR,
    category_name VARCHAR,
    doc_type_name VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        hd.id,
        hd.title,
        hc.category_name,
        hdt.type_name
    FROM help_documents hd
    JOIN help_categories hc ON hd.category_id = hc.id
    JOIN help_document_types hdt ON hd.doc_type_id = hdt.id
    WHERE hd.status = 'published'
        AND (hd.target_roles IS NULL OR p_role_code = ANY(hd.target_roles))
    ORDER BY hc.display_order, hd.title;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- VIEWS FOR DOCUMENTATION DASHBOARD
-- =====================================================

-- Help center overview
CREATE VIEW help_center_overview AS
SELECT 
    hc.category_name,
    COUNT(hd.id) as total_documents,
    COUNT(CASE WHEN hd.status = 'published' THEN 1 END) as published_count,
    COUNT(CASE WHEN hd.status = 'draft' THEN 1 END) as draft_count,
    COUNT(CASE WHEN hd.status = 'review' THEN 1 END) as review_count,
    MAX(hd.updated_at) as last_updated,
    SUM(hd.view_count) as total_views,
    ROUND(AVG(CASE
        WHEN (hd.helpful_count + hd.not_helpful_count) > 0
        THEN (hd.helpful_count::numeric / (hd.helpful_count + hd.not_helpful_count)) * 100
        ELSE NULL
    END), 1) as helpful_percentage
FROM help_categories hc
LEFT JOIN help_documents hd ON hc.id = hd.category_id
WHERE hc.is_active = true
GROUP BY hc.id, hc.category_name, hc.display_order
ORDER BY hc.display_order;

-- Recently updated documents
CREATE VIEW recently_updated_docs AS
SELECT 
    hd.id,
    hd.document_id,
    hd.title,
    hdt.type_name,
    hc.category_name,
    hd.version,
    hd.updated_at,
    u.full_name as updated_by_name,
    hd.change_notes
FROM help_documents hd
JOIN help_document_types hdt ON hd.doc_type_id = hdt.id
JOIN help_categories hc ON hd.category_id = hc.id
LEFT JOIN system_users u ON hd.updated_by = u.id
WHERE hd.status = 'published'
ORDER BY hd.updated_at DESC
LIMIT 20;

-- Documents needing review
CREATE VIEW documents_needing_review AS
SELECT 
    hd.id,
    hd.document_id,
    hd.title,
    hd.version,
    hd.review_required_by,
    hd.updated_at,
    (CURRENT_DATE - hd.review_required_by) as days_overdue
FROM help_documents hd
WHERE hd.status = 'published'
    AND hd.review_required_by IS NOT NULL
    AND hd.review_required_by < CURRENT_DATE + INTERVAL '30 days'
ORDER BY hd.review_required_by ASC;

-- =====================================================
-- SAMPLE QUERIES FOR DOCUMENTATION MANAGEMENT
-- =====================================================

/*

-- Get all SOPs for Caseworkers
SELECT * FROM help_documents 
WHERE doc_type_id = (SELECT id FROM help_document_types WHERE type_code = 'SOP')
AND 'CASEWORKER' = ANY(target_roles)
AND status = 'published';

-- Search documentation
SELECT id, title, ts_rank_cd(search_vector, query) as rank
FROM help_documents, 
     to_tsquery('english', 'application & review') query
WHERE query @@ search_vector
ORDER BY rank DESC
LIMIT 20;

-- Get user's incomplete required reading
SELECT hd.* 
FROM help_documents hd
LEFT JOIN help_user_progress ha ON hd.id = ha.document_id AND ha.user_id = 123
WHERE hd.is_required = true
    AND hd.status = 'published'
    AND (ha.status IS NULL OR ha.status != 'completed')
    AND (hd.target_roles IS NULL OR 'CASEWORKER' = ANY(hd.target_roles));

-- Most helpful documents this month
SELECT 
    hd.title,
    hd.view_count,
    hd.helpful_count,
    ROUND((hd.helpful_count::float / NULLIF(hd.helpful_count + hd.not_helpful_count, 0)) * 100, 1) as helpful_pct
FROM help_documents hd
WHERE hd.status = 'published'
    AND hd.updated_at > CURRENT_DATE - INTERVAL '30 days'
ORDER BY helpful_pct DESC
LIMIT 10;

-- Export documentation for offline distribution (e.g., for disaster deployment)
COPY (
    SELECT 
        hd.document_id,
        hd.title,
        hd.version,
        hd.content,
        hc.category_name,
        hdt.type_name,
        hd.tags,
        hd.estimated_minutes
    FROM help_documents hd
    JOIN help_categories hc ON hd.category_id = hc.id
    JOIN help_document_types hdt ON hd.doc_type_id = hdt.id
    WHERE hd.status = 'published'
    ORDER BY hc.display_order, hd.title
) TO '/tmp/help_docs_export.csv' CSV HEADER;

*/

-- =====================================================
-- TRIGGERS FOR AUTO-UPDATING TIMESTAMPS
-- =====================================================

CREATE OR REPLACE FUNCTION update_help_doc_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_help_doc_timestamp
    BEFORE UPDATE ON help_documents
    FOR EACH ROW
    EXECUTE PROCEDURE update_help_doc_timestamp();

-- Trigger to version documents on update
CREATE OR REPLACE FUNCTION version_help_document()
RETURNS TRIGGER AS $$
BEGIN
    -- Store old version if content changed significantly
    IF OLD.content IS DISTINCT FROM NEW.content OR OLD.title IS DISTINCT FROM NEW.title THEN
        INSERT INTO help_document_versions (
            document_id, version_number, title, content, change_notes, 
            created_by, created_at, is_current
        ) VALUES (
            OLD.id, OLD.version, OLD.title, OLD.content, OLD.change_notes,
            OLD.updated_by, OLD.updated_at, false
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_version_help_document
    BEFORE UPDATE ON help_documents
    FOR EACH ROW
    EXECUTE PROCEDURE version_help_document();