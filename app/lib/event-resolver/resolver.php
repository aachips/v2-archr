<?php
declare(strict_types=1);

/**
 * Event Resolver — core resolve function.
 *
 * Reads progress_events for a case, evaluates milestone rules, updates
 * milestone timestamp columns on the cases table, and returns the
 * current state.
 *
 * Usage:
 *   require_once __DIR__ . '/lib/event-resolver/resolver.php';
 *   $result = archr_resolve($pdo, $caseId);
 */

require_once __DIR__ . '/milestones.php';
require_once __DIR__ . '/mutator.php';

/**
 * Resolve the current state of an application/case.
 *
 * @param PDO $pdo
 * @param int $caseId
 * @return array {
 *   phase: int,
 *   phase_name: string,
 *   exit: ?string,
 *   exit_label: ?string,
 *   milestones: array<array{code: string, name: string, phase: int, completed: bool, at: ?string}>,
 *   next_actions: array<string>,
 *   blocked: bool,
 * }
 */
function archr_resolve(PDO $pdo, int $caseId): array {
    // 1. Load the case row
    $stmt = $pdo->prepare("SELECT * FROM cases WHERE id = :id LIMIT 1");
    $stmt->execute([':id' => $caseId]);
    $case = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$case) {
        return [
            'phase' => 0,
            'phase_name' => 'Unknown',
            'exit' => 'not_found',
            'exit_label' => 'Case not found',
            'milestones' => [],
            'next_actions' => [],
            'blocked' => true,
        ];
    }

    // 2. Evaluate every milestone
    $definitions = archr_milestone_definitions();
    $milestones = [];
    $completedPhase = 0;

    foreach ($definitions as $def) {
        $isComplete = $def['evaluate']($pdo, $caseId);
        $milestones[] = [
            'code'      => $def['code'],
            'name'      => $def['name'],
            'phase'     => $def['phase'],
            'completed' => $isComplete,
            'at'        => $isComplete && $def['column'] && !empty($case[$def['column']])
                ? (string) $case[$def['column']]
                : null,
        ];

        if ($isComplete) {
            $completedPhase = max($completedPhase, $def['phase']);
        }
    }

    // 3. Mutate: update milestone timestamp columns on the cases table
    archr_mutate($pdo, $caseId, $milestones);

    // 4. Compute current phase (use existing archr_case_phase if available)
    $phaseInfo = function_exists('archr_case_phase')
        ? archr_case_phase($case)
        : ['number' => $completedPhase, 'exit' => null, 'exit_label' => null];

    // 5. Determine next actions (first incomplete milestone's next steps)
    $phaseDefs = archr_case_phases();
    $nextActions = [];
    $blocked = false;

    foreach ($milestones as $m) {
        if (!$m['completed']) {
            // This is the next incomplete milestone
            $phaseDef = $phaseDefs[$m['phase']] ?? [];
            $nextActions = $phaseDef['next_steps'] ?? [];
            $blocked = false;
            break;
        }
    }

    // If all milestones complete and no exit
    if (empty($nextActions) && $phaseInfo['exit'] === null) {
        $nextActions = ['Project complete — close out and archive'];
    }

    // Check for exit/terminal states
    if ($phaseInfo['exit']) {
        $blocked = true;
        $nextActions = [$phaseInfo['exit_label'] ?? 'Case exited'];
    }

    return [
        'phase'      => (int) $phaseInfo['number'],
        'phase_name' => ($phaseDefs[(int) $phaseInfo['number']] ?? ['name' => 'Unknown'])['name'],
        'exit'       => $phaseInfo['exit'],
        'exit_label' => $phaseInfo['exit_label'],
        'milestones' => $milestones,
        'next_actions' => $nextActions,
        'blocked'    => $blocked,
    ];
}
