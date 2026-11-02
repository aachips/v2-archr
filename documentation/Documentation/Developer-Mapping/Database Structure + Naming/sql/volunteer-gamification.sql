-- =====================================================
-- VOLUNTEER GAMIFICATION SCHEMA
-- Extends existing role-based system
-- =====================================================

-- Volunteer profile (extends system_users)
CREATE TABLE volunteer_profiles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES system_users(id) UNIQUE,
    
    -- Gamification stats
    level INTEGER DEFAULT 1,
    xp INTEGER DEFAULT 0,
    xp_to_next_level INTEGER DEFAULT 100,
    reputation_score INTEGER DEFAULT 0,
    reputation_tier INTEGER DEFAULT 0,
    
    -- Engagement metrics
    total_quests_completed INTEGER DEFAULT 0,
    total_hours_logged DECIMAL(10,2) DEFAULT 0,
    consecutive_weeks_active INTEGER DEFAULT 0,
    last_active_at TIMESTAMP,
    
    -- Settings
    push_notifications_enabled BOOLEAN DEFAULT TRUE,
    email_digest_enabled BOOLEAN DEFAULT TRUE,
    weekly_quest_limit INTEGER DEFAULT 5,
    
    -- Avatar customization
    avatar_choice VARCHAR(50) DEFAULT 'default',
    title_equipped VARCHAR(100), -- "Roof Ranger", "Tool Master", etc.
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Quests table (tasks available to volunteers)
CREATE TABLE quests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quest_number VARCHAR(20) UNIQUE, -- Human-readable: Q-2024-001
    
    -- Core fields
    title VARCHAR(200) NOT NULL,
    description TEXT,
    quest_type VARCHAR(50) NOT NULL, -- repair, delivery, cleanup, training, social
    difficulty INTEGER CHECK (difficulty BETWEEN 1 AND 5),
    
    -- Rewards
    xp_reward INTEGER DEFAULT 10,
    reputation_reward INTEGER DEFAULT 5,
    coin_reward INTEGER DEFAULT 0, -- For future marketplace
    
    -- Requirements
    required_level INTEGER DEFAULT 1,
    required_skills TEXT[],
    required_certifications TEXT[],
    
    -- Capacity
    max_volunteers INTEGER DEFAULT 1,
    current_volunteers INTEGER DEFAULT 0,
    
    -- Location
    location_address TEXT,
    location_lat DECIMAL(10,8),
    location_lng DECIMAL(11,8),
    radius_miles INTEGER DEFAULT 25,
    
    -- Scheduling
    estimated_hours DECIMAL(5,2),
    flexible_timing BOOLEAN DEFAULT TRUE,
    scheduled_start TIMESTAMP,
    scheduled_end TIMESTAMP,
    
    -- Relationships
    parent_quest_id UUID REFERENCES quests(id), -- For epic quests
    case_id INTEGER REFERENCES cases(id),
    work_task_id INTEGER REFERENCES work_tasks(id),
    
    -- Metadata
    quest_giver_id INTEGER REFERENCES system_users(id),
    instructions TEXT,
    safety_notes TEXT,
    materials_needed TEXT[],
    
    -- Status
    status VARCHAR(20) DEFAULT 'available', -- available, in_progress, completed, cancelled, expired
    expires_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_quests_status_expires ON quests (status, expires_at);
CREATE INDEX idx_quests_location       ON quests (location_lat, location_lng);
CREATE INDEX idx_quests_skills         ON quests USING GIN (required_skills);

-- Quest assignments (volunteer claiming)
CREATE TABLE quest_assignments (
    id SERIAL PRIMARY KEY,
    quest_id UUID REFERENCES quests(id) ON DELETE CASCADE,
    volunteer_id INTEGER REFERENCES system_users(id),
    
    -- Status tracking
    status VARCHAR(20) DEFAULT 'assigned', -- assigned, in_progress, completed, abandoned, expired
    
    -- Timing
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    cancelled_at TIMESTAMP,
    
    -- Hours
    hours_logged DECIMAL(5,2),
    hours_verified BOOLEAN DEFAULT FALSE,
    verified_by INTEGER REFERENCES system_users(id),
    verified_at TIMESTAMP,
    
    -- Documentation
    before_photo_urls TEXT[],
    during_photo_urls TEXT[],
    after_photo_urls TEXT[],
    volunteer_notes TEXT,
    
    -- Rewards granted
    xp_awarded INTEGER,
    reputation_awarded INTEGER,
    rewards_claimed BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(quest_id, volunteer_id)
);

CREATE INDEX idx_assignments_volunteer ON quest_assignments (volunteer_id, status);

-- Skills library (controlled vocabulary)
CREATE TABLE skills (
    id SERIAL PRIMARY KEY,
    skill_code VARCHAR(50) UNIQUE NOT NULL,
    skill_name VARCHAR(100) NOT NULL,
    category VARCHAR(50), -- construction, cleanup, admin, social
    description TEXT,
    requires_training BOOLEAN DEFAULT FALSE,
    training_resource_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Pre-populate common skills
INSERT INTO skills (skill_code, skill_name, category, requires_training) VALUES
    ('LADDER_SAFE', 'Ladder Safety', 'construction', true),
    ('ROOF_WORK', 'Roof Work', 'construction', true),
    ('DEMOLITION', 'Demolition', 'construction', false),
    ('CLEANUP', 'Debris Cleanup', 'cleanup', false),
    ('MATERIAL_TRANSPORT', 'Material Transport', 'logistics', false),
    ('PHOTO_DOC', 'Photo Documentation', 'admin', false),
    ('CLIENT_COMM', 'Client Communication', 'social', false),
    ('TOOL_MAINT', 'Tool Maintenance', 'construction', false);

-- Volunteer skills (junction table)
CREATE TABLE volunteer_skills (
    id SERIAL PRIMARY KEY,
    volunteer_id INTEGER REFERENCES system_users(id) ON DELETE CASCADE,
    skill_id INTEGER REFERENCES skills(id) ON DELETE CASCADE,
    proficiency_level INTEGER DEFAULT 1 CHECK (proficiency_level BETWEEN 1 AND 5),
    endorsed_by INTEGER REFERENCES system_users(id),
    endorsed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(volunteer_id, skill_id)
);

-- Badges/achievements
CREATE TABLE badges (
    id SERIAL PRIMARY KEY,
    badge_code VARCHAR(50) UNIQUE NOT NULL,
    badge_name VARCHAR(100) NOT NULL,
    description TEXT,
    icon_url VARCHAR(500),
    criteria_type VARCHAR(50), -- quests_completed, hours_logged, skill_mastery, etc.
    criteria_value INTEGER,
    xp_bonus INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO badges (badge_code, badge_name, description, criteria_type, criteria_value, xp_bonus) VALUES
    ('FIRST_QUEST', 'First Quest', 'Complete your first volunteer task', 'quests_completed', 1, 25),
    ('ROOF_RANGER', 'Roof Ranger', 'Complete 5 roofing tasks', 'skill_quests', 5, 100),
    ('HUNDRED_HOURS', 'Century Club', 'Log 100 volunteer hours', 'hours_logged', 100, 200),
    ('HELPER_HEART', 'Helper Heart', 'Receive 10 positive beneficiary ratings', 'positive_ratings', 10, 50),
    ('MENTOR', 'Community Mentor', 'Help 5 new volunteers complete their first quest', 'mentored_count', 5, 150);

-- Volunteer badge assignments
CREATE TABLE volunteer_badges (
    id SERIAL PRIMARY KEY,
    volunteer_id INTEGER REFERENCES system_users(id) ON DELETE CASCADE,
    badge_id INTEGER REFERENCES badges(id) ON DELETE CASCADE,
    awarded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    awarded_by INTEGER REFERENCES system_users(id), -- system or admin
    UNIQUE(volunteer_id, badge_id)
);

-- Content library (blog posts, newsletters, updates)
CREATE TABLE volunteer_content (
    id SERIAL PRIMARY KEY,
    content_id VARCHAR(50) UNIQUE NOT NULL, -- e.g., FLD-2024-001
    title VARCHAR(300) NOT NULL,
    content TEXT, -- Markdown format
    content_html TEXT, -- Rendered HTML
    
    -- Metadata (YAML frontmatter equivalent)
    yaml_frontmatter JSONB DEFAULT '{}'::jsonb,
    
    -- Categorization
    content_type VARCHAR(50) NOT NULL, -- field_notes, spotlight, training, alert, impact_story
    tags TEXT[],
    
    -- Authorship
    author_id INTEGER REFERENCES system_users(id),
    author_name VARCHAR(100),
    reviewed_by INTEGER REFERENCES system_users(id),
    reviewed_at TIMESTAMP,
    
    -- Engagement
    view_count INTEGER DEFAULT 0,
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    
    -- Gamification
    read_xp_reward INTEGER DEFAULT 10,
    
    -- Publishing
    status VARCHAR(20) DEFAULT 'draft', -- draft, published, archived
    published_at TIMESTAMP,
    pinned_until TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_content_published ON volunteer_content (status, published_at DESC);
CREATE INDEX idx_content_tags      ON volunteer_content USING GIN (tags);

-- Content read tracking (for XP rewards)
CREATE TABLE content_reads (
    id SERIAL PRIMARY KEY,
    content_id INTEGER REFERENCES volunteer_content(id) ON DELETE CASCADE,
    volunteer_id INTEGER REFERENCES system_users(id) ON DELETE CASCADE,
    read_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    xp_awarded BOOLEAN DEFAULT FALSE,
    UNIQUE(content_id, volunteer_id)
);

-- Weekly digests (auto-generated or manual)
CREATE TABLE weekly_digests (
    id SERIAL PRIMARY KEY,
    digest_week DATE NOT NULL, -- Monday of that week
    title VARCHAR(200),
    summary TEXT,
    featured_content_ids INTEGER[], -- References to volunteer_content
    sent_at TIMESTAMP,
    created_by INTEGER REFERENCES system_users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(digest_week)
);

-- Beneficiary feedback (extends earlier table)
CREATE TABLE beneficiary_feedback (
    id SERIAL PRIMARY KEY,
    quest_id UUID REFERENCES quests(id),
    volunteer_id INTEGER REFERENCES system_users(id),
    beneficiary_id INTEGER REFERENCES intake_submissions(id),
    
    -- Ratings
    quality_rating INTEGER CHECK (quality_rating BETWEEN 1 AND 5),
    kindness_rating INTEGER CHECK (kindness_rating BETWEEN 1 AND 5),
    would_recommend BOOLEAN,
    
    -- Text
    comments TEXT,
    thank_you_note TEXT,
    
    -- Photo evidence
    photo_urls TEXT[],
    
    -- Impact
    reputation_delta INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_feedback_volunteer ON beneficiary_feedback (volunteer_id, created_at DESC);

-- Function to award XP and check level-ups
CREATE OR REPLACE FUNCTION award_quest_completion(
    p_assignment_id INTEGER,
    p_hours_logged DECIMAL,
    p_photos TEXT[]
)
RETURNS JSONB AS $$
DECLARE
    v_assignment RECORD;
    v_quest RECORD;
    v_volunteer RECORD;
    v_new_xp INTEGER;
    v_new_level INTEGER;
    v_xp_needed INTEGER;
    v_new_reputation INTEGER;
    v_new_total_hours DECIMAL;
BEGIN
    -- Get assignment and quest details
    SELECT * INTO v_assignment FROM quest_assignments WHERE id = p_assignment_id;
    SELECT * INTO v_quest FROM quests WHERE id = v_assignment.quest_id;
    SELECT * INTO v_volunteer FROM volunteer_profiles WHERE user_id = v_assignment.volunteer_id;
    
    -- Update assignment
    UPDATE quest_assignments SET
        status = 'completed',
        completed_at = NOW(),
        hours_logged = p_hours_logged,
        before_photo_urls = p_photos[1:array_length(p_photos, 1)/3],
        during_photo_urls = p_photos[array_length(p_photos, 1)/3+1:2*array_length(p_photos, 1)/3],
        after_photo_urls = p_photos[2*array_length(p_photos, 1)/3+1:array_length(p_photos, 1)],
        xp_awarded = v_quest.xp_reward,
        reputation_awarded = v_quest.reputation_reward,
        rewards_claimed = TRUE
    WHERE id = p_assignment_id;
    
    -- Update volunteer stats
    v_new_xp := v_volunteer.xp + v_quest.xp_reward;
    v_new_reputation := v_volunteer.reputation_score + v_quest.reputation_reward;
    v_new_total_hours := v_volunteer.total_hours_logged + p_hours_logged;
    
    -- Check level-up
    v_new_level := v_volunteer.level;
    v_xp_needed := v_volunteer.xp_to_next_level;
    
    WHILE v_new_xp >= v_xp_needed LOOP
        v_new_level := v_new_level + 1;
        v_new_xp := v_new_xp - v_xp_needed;
        v_xp_needed := 100 * v_new_level; -- Simple formula: next level needs 100 * level
    END LOOP;
    
    UPDATE volunteer_profiles SET
        xp = v_new_xp,
        level = v_new_level,
        xp_to_next_level = v_xp_needed,
        reputation_score = v_new_reputation,
        total_hours_logged = v_new_total_hours,
        total_quests_completed = total_quests_completed + 1,
        last_active_at = NOW(),
        updated_at = NOW()
    WHERE user_id = v_assignment.volunteer_id;
    
    -- Check for badge awards (simplified - would call separate function)
    
    RETURN jsonb_build_object(
        'success', true,
        'xp_gained', v_quest.xp_reward,
        'reputation_gained', v_quest.reputation_reward,
        'new_level', v_new_level,
        'level_up', (v_new_level > v_volunteer.level),
        'total_xp', v_new_xp,
        'next_level_xp', v_xp_needed
    );
END;
$$ LANGUAGE plpgsql;