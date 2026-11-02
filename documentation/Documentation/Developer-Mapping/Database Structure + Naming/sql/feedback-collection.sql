-- Beneficiary feedback form
CREATE TABLE volunteer_feedback (
    id SERIAL PRIMARY KEY,
    quest_id UUID REFERENCES quests(id),
    volunteer_id INTEGER REFERENCES system_users(id),
    beneficiary_id INTEGER REFERENCES intake_submissions(id),
    
    -- Rating categories (1-5 stars)
    quality_rating INTEGER CHECK (quality_rating BETWEEN 1 AND 5),
    timeliness_rating INTEGER CHECK (timeliness_rating BETWEEN 1 AND 5),
    professionalism_rating INTEGER CHECK (professionalism_rating BETWEEN 1 AND 5),
    
    -- Text feedback
    comments TEXT,
    would_recommend BOOLEAN,
    
    -- Photo evidence (optional)
    photo_urls TEXT[],
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Calculated reputation delta
    reputation_delta INTEGER,
    
    UNIQUE(quest_id, volunteer_id, beneficiary_id)
);