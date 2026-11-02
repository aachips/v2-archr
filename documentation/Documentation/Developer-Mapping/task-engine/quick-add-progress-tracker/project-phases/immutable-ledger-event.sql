-- On each Quick Add submission:
INSERT INTO progress_ledger (
    case_id,
    event_by,
    event_by_role,
    event_category,
    event_type,
    entity_type,
    entity_id,
    snapshot,
    change_reason
) VALUES (
    'ARCHR-2024-001234',
    456, -- user_id
    'ASSESSOR',
    'task',
    'task_completed',
    'assessment',
    'ASSESS_001',
    jsonb_build_object(
        'task_type', 'ASSESS',
        'date', '2024-12-20',
        'notes', 'Assessment completed. Roof needs full replacement.',
        'documents', ARRAY['/path/to/report.pdf'],
        'phase', 2
    ),
    'Quick Add: Assessment completed'
);