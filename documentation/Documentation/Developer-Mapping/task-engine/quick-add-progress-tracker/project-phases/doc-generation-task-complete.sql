-- When task is completed, trigger document generation
CREATE OR REPLACE FUNCTION generate_document_on_task_complete()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if this task type requires document generation
    IF NEW.snapshot->>'task_type' = 'ASSESS' THEN
        -- Generate assessment report
        PERFORM generate_assessment_report(NEW.case_id);
    ELSIF NEW.snapshot->>'task_type' = 'SCOPE' THEN
        -- Generate scope document
        PERFORM generate_scope_document(NEW.case_id);
    ELSIF NEW.snapshot->>'task_type' = 'START' THEN
        -- Generate work order
        PERFORM generate_work_order(NEW.case_id);
    ELSIF NEW.snapshot->>'task_type' = 'COMPLETE' THEN
        -- Generate final documents
        PERFORM generate_completion_documents(NEW.case_id);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_document_generation
    AFTER INSERT ON progress_ledger
    FOR EACH ROW
    WHEN (NEW.event_type = 'task_completed')
    EXECUTE FUNCTION generate_document_on_task_complete();