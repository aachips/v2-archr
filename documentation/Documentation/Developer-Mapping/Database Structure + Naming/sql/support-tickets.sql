-- Support Tickets table
-- Stores bug reports and tech support requests submitted from the Vue chat widget.
-- Super Admins manage these via app/helpdesk-tickets.php.

CREATE TABLE IF NOT EXISTS support_tickets (
    id              SERIAL PRIMARY KEY,
    submitted_by    INTEGER REFERENCES system_users(id) ON DELETE SET NULL,
    submitter_name  VARCHAR(128) NOT NULL DEFAULT '',
    submitter_email VARCHAR(256) NOT NULL DEFAULT '',
    category        VARCHAR(32) NOT NULL DEFAULT 'general',
                    -- 'bug', 'feature_request', 'access_issue', 'data_error', 'general'
    subject         VARCHAR(256) NOT NULL DEFAULT '',
    description     TEXT NOT NULL,
    screenshot_url  TEXT,
    status          VARCHAR(20) NOT NULL DEFAULT 'open',
                    -- 'open', 'in_progress', 'resolved', 'closed'
    priority        VARCHAR(10) NOT NULL DEFAULT 'normal',
                    -- 'low', 'normal', 'high', 'critical'
    assigned_to     INTEGER REFERENCES system_users(id) ON DELETE SET NULL,
    resolved_at     TIMESTAMPTZ,
    resolved_by     INTEGER REFERENCES system_users(id) ON DELETE SET NULL,
    resolution_note TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_support_tickets_status ON support_tickets(status);
CREATE INDEX IF NOT EXISTS idx_support_tickets_created ON support_tickets(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_support_tickets_assigned ON support_tickets(assigned_to) WHERE assigned_to IS NOT NULL;
