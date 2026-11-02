-- Claiming a task (prevents double-booking)
CREATE OR REPLACE FUNCTION claim_quest(
    p_quest_id UUID,
    p_volunteer_id UUID
)
RETURNS JSONB AS $$
DECLARE
    v_current_count INTEGER;
    v_max_volunteers INTEGER;
    v_result JSONB;
BEGIN
    -- Lock the quest row to prevent race conditions
    SELECT max_volunteers, current_volunteers 
    INTO v_max_volunteers, v_current_count
    FROM quests WHERE id = p_quest_id FOR UPDATE;
    
    -- Check availability
    IF v_current_count >= v_max_volunteers THEN
        RETURN jsonb_build_object('success', false, 'error', 'Quest is full');
    END IF;
    
    -- Check volunteer hasn't already claimed
    IF EXISTS (SELECT 1 FROM quest_assignments 
               WHERE quest_id = p_quest_id AND volunteer_id = p_volunteer_id) THEN
        RETURN jsonb_build_object('success', false, 'error', 'Already claimed');
    END IF;
    
    -- Assign the quest
    INSERT INTO quest_assignments (quest_id, volunteer_id, assigned_at, status)
    VALUES (p_quest_id, p_volunteer_id, NOW(), 'assigned');
    
    -- Update current count
    UPDATE quests 
    SET current_volunteers = current_volunteers + 1
    WHERE id = p_quest_id;
    
    RETURN jsonb_build_object('success', true, 'message', 'Quest claimed!');
END;
$$ LANGUAGE plpgsql;