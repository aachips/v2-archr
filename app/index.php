<?php
declare(strict_types=1);
require __DIR__ . '/lib/auth.php';
require __DIR__ . '/lib/layout.php';

$isAuthenticated = archr_is_authenticated();
$forcePublic = !empty($_GET['public']);

if ($isAuthenticated && !$forcePublic) {
    header('Location: dashboard.php');
    exit;
}

if ($forcePublic) {
    $isAuthenticated = false;
}

archr_render_header('Welcome', 'home');
?>
<main class="page-wrap">
    <section class="panel">
        <h1>ARCHR application portal</h1>
        <p>
            Asheville Regional Coalition for Home Repair &mdash; a working demo
            of the intake form and role-based dashboards.
        </p>
        <?php if (!$isAuthenticated): ?>
            <p style="text-align: center; margin: 2rem 0;">
                <a href="intake.php" class="btn primary" style="margin-right: 1rem;">
                    <i class="fas fa-clipboard-list" aria-hidden="true"></i> Start Intake Form
                </a>
                <a href="login.php" class="btn secondary">
                    <i class="fas fa-sign-in-alt" aria-hidden="true"></i> Log In to Dashboard
                </a>
            </p>
        <?php else: ?>
            <p style="text-align: center; margin: 2rem 0;">
                <a href="intake.php" class="btn primary" style="margin-right: 1rem;">
                    <i class="fas fa-clipboard-list" aria-hidden="true"></i> Start Intake Form
                </a>
                <a href="logout.php" class="btn secondary">
                    <i class="fas fa-sign-out-alt" aria-hidden="true"></i> Logout
                </a>
            </p>
        <?php endif; ?>
    </section>

    <section class="panel" id="portals" aria-labelledby="portals-h">
        <h2 id="portals-h">Role portals</h2>
        <?php if (!$isAuthenticated): ?>
            <p>Working prototypes of each role-specific dashboard.
               <strong><a href="login.php">Log in</a></strong> to access any role portal.
               They share a common scaffold (<code>lib/portal-layout.php</code>,
               <code>assets/portal.css</code>) and render against fixture data
               from <code>lib/sample-data.php</code>.</p>
            <p style="text-align: center; margin: 2rem 0;">
                <a href="login.php" class="btn primary" style="font-size: 1.1rem; padding: 0.875rem 2rem;">
                    <i class="fas fa-sign-in-alt" aria-hidden="true"></i> Log In to Access Dashboards
                </a>
            </p>
        <?php else: ?>
            <p>Working prototypes of each role-specific dashboard. They share a
               common scaffold (<code>lib/portal-layout.php</code>,
               <code>assets/portal.css</code>) and render against fixture data
               from <code>lib/sample-data.php</code>.</p>
        <?php endif; ?>
        <ul class="portal-hub">
            <?php
            $portals = [
                ['assessor.php',         'Assessor',         'fa-tape',                'Field assessments, verifications, schedule'],
                ['bursar.php',           'Bursar',           'fa-coins',               'Funding queue, reimbursements, audit'],
                ['crew-lead.php',        'Crew Lead',        'fa-helmet-safety',       'On-site task updates, daily logs, sign-off'],
                ['crew-member.php',      'Crew Member',      'fa-user-hard-hat',       'Today\'s tasks, photo upload, hours'],
                ['subcontractor.php',    'Subcontractor',    'fa-hard-hat',            'Bids, work orders, invoices'],
                ['envoy.php',            'Envoy',            'fa-handshake',           'Applicant outreach + intake support'],
                ['project-manager.php',  'Project Manager',  'fa-diagram-project',     'Pipeline, schedule, reports'],
                ['requestor-portal.php', 'Requestor',        'fa-house-user',          'Applicant-facing private dashboard'],
                ['volunteer.php',        'Volunteer',        'fa-hand-holding-heart',  'Shifts, opportunities, hours log'],
                ['org-admin.php',        'Org Admin',        'fa-user-shield',         'Org-level admin: tasks, comms, scheduling'],
                ['tle-poc.php',          'Tasks/Logs/Events','fa-list-check',          'Cross-role tasks, logs &amp; events POC'],
            ];
            foreach ($portals as [$href, $label, $icon, $desc]):
                $link = $isAuthenticated ? $href : 'login.php';
            ?>
                <li>
                    <a href="<?= e($link) ?>">
                        <i class="fas <?= e($icon) ?>" aria-hidden="true"></i>
                        <span class="portal-hub-name"><?= e($label) ?></span>
                        <span class="portal-hub-desc"><?= $desc /* inline html ok: trusted */ ?></span>
                    </a>
                </li>
            <?php endforeach; ?>
        </ul>
    </section>
</main>
<?php archr_render_footer(); ?>
