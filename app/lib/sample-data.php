<?php
declare(strict_types=1);

require_once __DIR__ . '/db.php';

/* Sample data functions for role-portal pages.
   NOW USING LIVE DATABASE DATA from PostgreSQL.
   Falls back to sample data if database query fails. */

function archr_sample_assessor(): array {
    try {
        $db = archr_db();

        // Get the first assessor user (in a real app, this would be from the session)
        $users = $db->select('system_users', [], ['id', 'full_name', 'email'], 1);
        $user = $users[0] ?? null;

        if (!$user) {
            throw new Exception("No user found");
        }

        // Get user's name and create initials
        $name_parts = explode(' ', $user['full_name']);
        $initials = '';
        foreach ($name_parts as $part) {
            if (!empty($part)) {
                $initials .= strtoupper($part[0]);
            }
        }

        // Get organization (would come from user_role_assignments in real app)
        $orgs = $db->select('coalition_organizations', [], ['organization_name'], 1);
        $org_name = $orgs[0]['organization_name'] ?? 'Habitat for Humanity';

        // Get intake submissions (applications) for assessment counts
        $submissions = $db->select('intake_submissions', ['submission_status' => 'under_review'], ['id', 'applicant_first_name', 'applicant_last_name', 'home_address'], 10);
        $submission_count = count($submissions);

        return [
            'user' => [
                'name'     => $user['full_name'],
                'initials' => $initials ?: 'U',
                'org'      => $org_name,
                'territory'=> 'Buncombe County',
            ],
            'today_summary' => [
                'scheduled'  => $submission_count,
                'in_progress'=> 1,
                'drive_min'  => 45,
                'last_sync'  => date('g:i A'),
            ],
            'last_assessment' => [
                'address'     => !empty($submissions) ? ($submissions[0]['home_address'] ?? 'N/A') : '42 Cherry St, Asheville',
                'next_step'   => 'Upload photos from assessment',
                'holding_on'  => 'Waiting for client to sign waiver',
                'status_pill' => ['amber', 'fa-clock', 'Awaiting signature'],
            ],
        'week' => [
            ['name'=>'Mon','num'=>9, 'count'=>1,'today'=>false],
            ['name'=>'Tue','num'=>10,'count'=>0,'today'=>false],
            ['name'=>'Wed','num'=>11,'count'=>1,'today'=>false],
            ['name'=>'Thu','num'=>12,'count'=>3,'today'=>true],
            ['name'=>'Fri','num'=>13,'count'=>0,'today'=>false],
            ['name'=>'Sat','num'=>14,'count'=>1,'today'=>false],
            ['name'=>'Sun','num'=>15,'count'=>0,'today'=>false],
        ],
        'today' => [
            ['time'=>'9:00 AM','addr'=>'42 Cherry St, Asheville','hours'=>'2.0','miles'=>'2.3','status'=>'in_progress','status_label'=>'In progress','action_label'=>'Resume','action_icon'=>'fa-play'],
            ['time'=>'11:00 AM','addr'=>'15 Merrill Ave, Asheville','hours'=>'1.5','miles'=>'4.1','status'=>'scheduled','status_label'=>'Scheduled','action_label'=>'Directions','action_icon'=>'fa-route'],
            ['time'=>'2:30 PM','addr'=>'8 Oakland Rd, Asheville','hours'=>'1.0','miles'=>'5.7','status'=>'scheduled','status_label'=>'Scheduled','action_label'=>'Call','action_icon'=>'fa-phone'],
        ],
            'previous' => array_map(function($sub) {
                return [
                    'date' => date('M j', strtotime($sub['submitted_at'] ?? 'now')),
                    'addr' => $sub['home_address'] ?? 'N/A',
                    'client' => ($sub['applicant_first_name'] ?? '') . ' ' . ($sub['applicant_last_name'] ?? ''),
                    'photos' => 0,
                    'state' => $sub['submission_status'] ?? 'draft'
                ];
            }, array_slice($submissions, 0, 3)),
            'messages' => [
                ['from'=>'Sarah Williams','kind'=>'Client','body'=>'Please call when you arrive — the gate code changed.','meta'=>'15 Merrill Ave · 22 min ago','system'=>false],
                ['from'=>'System','kind'=>'Assignment','body'=>'New assessment assigned.','meta'=>'Today, ' . date('g:i A'),'system'=>true],
            ],
        ];
    } catch (Exception $e) {
        // Fallback to hardcoded data if database fails
        error_log("Database error in archr_sample_assessor: " . $e->getMessage());
        return [
            'user' => [
                'name'     => 'Maria Garcia',
                'initials' => 'MG',
                'org'      => 'Habitat for Humanity',
                'territory'=> 'Buncombe County',
            ],
            'today_summary' => [
                'scheduled'  => 3,
                'in_progress'=> 1,
                'drive_min'  => 45,
                'last_sync'  => '9:14 AM',
            ],
            'last_assessment' => [
                'address'     => '42 Cherry St, Asheville',
                'next_step'   => 'Upload photos from assessment',
                'holding_on'  => 'Waiting for client to sign waiver',
                'status_pill' => ['amber', 'fa-clock', 'Awaiting signature'],
            ],
            'week' => [
                ['name'=>'Mon','num'=>9, 'count'=>1,'today'=>false],
                ['name'=>'Tue','num'=>10,'count'=>0,'today'=>false],
                ['name'=>'Wed','num'=>11,'count'=>1,'today'=>false],
                ['name'=>'Thu','num'=>12,'count'=>3,'today'=>true],
                ['name'=>'Fri','num'=>13,'count'=>0,'today'=>false],
                ['name'=>'Sat','num'=>14,'count'=>1,'today'=>false],
                ['name'=>'Sun','num'=>15,'count'=>0,'today'=>false],
            ],
            'today' => [
                ['time'=>'9:00 AM','addr'=>'42 Cherry St, Asheville','hours'=>'2.0','miles'=>'2.3','status'=>'in_progress','status_label'=>'In progress','action_label'=>'Resume','action_icon'=>'fa-play'],
                ['time'=>'11:00 AM','addr'=>'15 Merrill Ave, Asheville','hours'=>'1.5','miles'=>'4.1','status'=>'scheduled','status_label'=>'Scheduled','action_label'=>'Directions','action_icon'=>'fa-route'],
            ],
            'previous' => [
                ['date'=>'Dec 10','addr'=>'8 Oakland Rd, Asheville','client'=>'James Thornton','photos'=>14,'state'=>'completed'],
                ['date'=>'Dec 9', 'addr'=>'19 Riverside Dr, Asheville','client'=>'Maria Delgado','photos'=>11,'state'=>'completed'],
            ],
            'messages' => [
                ['from'=>'Sarah Williams','kind'=>'Client','body'=>'Please call when you arrive — the gate code changed.','meta'=>'15 Merrill Ave · 22 min ago','system'=>false],
            ],
        ];
    }
}

function archr_sample_bursar(): array {
    return [
        'user' => ['name'=>'Morgan Reyes','initials'=>'MR','org'=>'Habitat for Humanity'],
        'kpis' => [
            ['label'=>'Total Approved','value'=>'$2,400,000','sub'=>'Across 48 active cases','link_label'=>'Details','href'=>'#cases','tone'=>'approved'],
            ['label'=>'Pending Reimbursement','value'=>'$350,000','sub'=>'14 invoices awaiting review','link_label'=>'Process queue','href'=>'#reimbursements','tone'=>'pending'],
            ['label'=>'Reimbursed to Date','value'=>'$1,850,000','sub'=>'77% of approved funds','link_label'=>'Export report','href'=>'#reports','tone'=>'paid'],
            ['label'=>'On Hold','value'=>'$125,000','sub'=>'5 cases pending docs or approval','link_label'=>'Investigate','href'=>'#cases','tone'=>'hold'],
        ],
        'funding' => [
            ['case_id'=>'C-1042','org'=>'Habitat — Buncombe','approved'=>120000,'spent'=>92000,'pending'=>18000,'status'=>'In Repair'],
            ['case_id'=>'C-1043','org'=>'Mountain Housing','approved'=>85000,'spent'=>14000,'pending'=>0,'status'=>'Site Prep'],
            ['case_id'=>'C-1044','org'=>'Helene Recovery Fund','approved'=>240000,'spent'=>0,'pending'=>0,'status'=>'Awaiting Award'],
            ['case_id'=>'C-1045','org'=>'Habitat — Buncombe','approved'=>62000,'spent'=>62000,'pending'=>0,'status'=>'Closeout'],
        ],
        'reimbursements' => [
            ['vendor'=>'Asheville Roofing','case_id'=>'C-1042','amount'=>14200,'status'=>'Pending','days'=>3],
            ['vendor'=>'Habitat ReStore','case_id'=>'C-1043','amount'=>2380,'status'=>'Pending','days'=>1],
            ['vendor'=>'Bluestone Electric','case_id'=>'C-1040','amount'=>8540,'status'=>'On Hold','days'=>9],
        ],
    ];
}

function archr_sample_crew_lead(): array {
    return [
        'user' => ['name'=>'Jordan Lee','initials'=>'JL','org'=>'Habitat for Humanity'],
        'stats'=> [
            ['label'=>'Active Jobs','value'=>'4','sub'=>'2 due this week'],
            ['label'=>'Volunteer Hours','value'=>'186','sub'=>'past 30 days'],
            ['label'=>'Open Tasks','value'=>'23','sub'=>'across all jobs'],
            ['label'=>'Safety Score','value'=>'98%','sub'=>'no incidents 60 days'],
        ],
        'current_job' => [
            'addr' => '42 Cherry St, Asheville',
            'phase'=> 'Roof tear-off',
            'crew' => ['Pat','Sam','Drew','Lou','Kim'],
            'tasks_done' => 8,
            'tasks_total'=> 14,
        ],
        'upcoming' => [
            ['date'=>'Wed Dec 11','addr'=>'15 Merrill Ave','crew_needed'=>5,'phase'=>'Demo'],
            ['date'=>'Sat Dec 14','addr'=>'8 Oakland Rd','crew_needed'=>4,'phase'=>'Framing'],
        ],
    ];
}

function archr_sample_crew_member(): array {
    return [
        'user' => ['name'=>'Sam Rivera','initials'=>'SR','org'=>'Habitat for Humanity'],
        'next_shift' => ['date'=>'Tomorrow · 8:00 AM','addr'=>'42 Cherry St, Asheville','role'=>'Crew Member','lead'=>'Jordan Lee'],
        'tasks' => [
            ['title'=>'Roof tear-off — section B','status'=>'todo'],
            ['title'=>'Haul debris to dumpster','status'=>'todo'],
            ['title'=>'Tarp section A overnight','status'=>'done'],
        ],
        'streak' => ['days'=>12,'hours_month'=>34],
    ];
}

function archr_sample_envoy(): array {
    return [
        'user' => ['name'=>'Dr. Eileen Bailey','initials'=>'EB','org'=>'ARCHR Coalition'],
        'coalition_kpis' => [
            ['label'=>'Partner Orgs','value'=>'12','sub'=>'+1 this quarter'],
            ['label'=>'Active Cases','value'=>'214','sub'=>'across coalition'],
            ['label'=>'Funds Deployed','value'=>'$4.1M','sub'=>'this fiscal year'],
            ['label'=>'Avg Cycle Time','value'=>'37 days','sub'=>'intake → repair'],
        ],
    ];
}

function archr_sample_project_manager(): array {
    return [
        'user' => ['name'=>'Alex Chen','initials'=>'AC','org'=>'Habitat for Humanity'],
        'kpis' => [
            ['label'=>'Active Projects','value'=>'9','sub'=>'3 in repair'],
            ['label'=>'Awaiting Estimate','value'=>'4','sub'=>'>5 days old'],
            ['label'=>'Crews Deployed','value'=>'3','sub'=>'this week'],
            ['label'=>'Budget Utilization','value'=>'68%','sub'=>'of $1.2M'],
        ],
    ];
}

function archr_sample_subcontractor(): array {
    return [
        'user' => ['name'=>'Bluestone Electric','initials'=>'BE','org'=>'Vendor portal'],
        'jobs' => [
            ['case_id'=>'C-1042','addr'=>'42 Cherry St','scope'=>'Panel upgrade','status'=>'Quoted','due'=>'Dec 18'],
            ['case_id'=>'C-1040','addr'=>'12 Oak Ridge','scope'=>'Outlet repair','status'=>'In progress','due'=>'Dec 12'],
        ],
    ];
}
