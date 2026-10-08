<?php declare(strict_types=1);
/**
 * Dashboard route map for the single-entry-point controller.
 *
 * Each route resolves to a legacy role portal file. Over time these files will
 * be refactored into views under app/views/dashboard/.
 */

function archr_dashboard_routes(): array {
    return [
        'super-admin'     => 'super-admin.php',
        'super_admin'     => 'super-admin.php',
        'requestor'       => 'requestor-portal.php',
        'assessor'        => 'assessor.php',
        'bursar'          => 'bursar.php',
        'caseworker'      => 'case-search.php',
        'crew-lead'       => 'crew-lead.php',
        'crew lead'       => 'crew-lead.php',
        'crew-member'     => 'crew-member.php',
        'crew member'     => 'crew-member.php',
        'subcontractor'   => 'subcontractor.php',
        'envoy'           => 'envoy.php',
        'project-manager' => 'project-manager.php',
        'project manager' => 'project-manager.php',
        'volunteer'       => 'volunteer.php',
        'org-admin'       => 'org-admin.php',
        'org admin'       => 'org-admin.php',
        'admin'           => 'org-admin.php',
        'tle-poc'         => 'tle-poc.php',
    ];
}

function archr_dashboard_target(string $role, string $view = ''): ?string {
    $routes = archr_dashboard_routes();
    $key = trim(strtolower(str_replace('_', '-', $view ?: $role)));
    return $routes[$key] ?? null;
}
