<?php
declare(strict_types=1);

/**
 * State Mutator — updates the cases table milestone timestamp columns
 * when the Event Resolver determines a milestone is complete.
 *
 * This is the "write" side of the resolver. The resolver evaluates,
 * the mutator persists the result.
 */

/**
 * Update milestone timestamp columns on the cases table.
 *
 * For each milestone that is now complete and has a designated column,
 * set that column to NOW() if it isn't already set.
 *
 * This is idempotent — safe to call repeatedly.
 *
 * @param PDO   $pdo
 * @param int   $caseId
 * @param array $milestones The evaluated milestone array from archr_resolve()
 */
function archr_mutate(PDO $pdo, int $caseId, array $milestones): void {
    foreach ($milestones as $m) {
        if (!$m['completed']) {
            continue;
        }

        // Find the milestone definition to get the column name
        $defs = archr_milestone_definitions();
        $column = null;
        foreach ($defs as $def) {
            if ($def['code'] === $m['code']) {
                $column = $def['column'];
                break;
            }
        }

        if ($column === null) {
            continue; // No column to update for this milestone
        }

        // Check if already set (don't overwrite existing timestamp)
        $stmt = $pdo->prepare("SELECT {$column} FROM cases WHERE id = :id");
        $stmt->execute([':id' => $caseId]);
        $existing = $stmt->fetchColumn();

        if (!empty($existing)) {
            continue; // Already stamped
        }

        // Stamp the column with the current timestamp
        $stmt = $pdo->prepare("UPDATE cases SET {$column} = CURRENT_TIMESTAMP WHERE id = :id");
        $stmt->execute([':id' => $caseId]);
    }
}
