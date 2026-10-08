<section class="portal-page active" data-page-title="System Dashboard">
    <p class="login-banner" role="status">
        <i class="fas fa-shield-halved"></i>
        <span>You are logged in as a Super-Administrator. Changes made here affect every organization in the coalition.</span>
    </p>

    <section class="dash-hero" aria-labelledby="sa-welcome">
        <div>
            <h2 id="sa-welcome">System Dashboard</h2>
            <p>Manage coalition organizations, system accounts, and platform configuration.</p>
        </div>
    </section>

    <section class="dash-section active" aria-label="Coalition overview">
        <h3 class="dash-section-title"><i class="fas fa-chart-pie"></i> Coalition Overview</h3>
        <div class="kpi-grid">
            <div class="kpi"><span class="kpi-label">Organizations</span><span class="kpi-value"><?= e((string)$counts['org_count']) ?></span></div>
            <div class="kpi kpi-blue"><span class="kpi-label">System Users</span><span class="kpi-value"><?= e((string)$counts['user_count']) ?></span></div>
            <div class="kpi kpi-amber"><span class="kpi-label">Submissions</span><span class="kpi-value"><?= e((string)$counts['submission_count']) ?></span></div>
            <div class="kpi kpi-green"><span class="kpi-label">Cases</span><span class="kpi-value"><?= e((string)$counts['case_count']) ?></span></div>
        </div>
    </section>

    <section class="dash-section" id="organizations" aria-label="Organizations">
        <h3 class="dash-section-title"><i class="fas fa-building"></i> Organizations</h3>
        <table class="data-table">
            <thead>
                <tr><th>Code</th><th>Name</th><th>Funding</th><th>Max Active</th><th>Auto Claim</th><th>Status</th><th>Actions</th></tr>
            </thead>
            <tbody>
                <?php foreach ($orgs as $o): ?>
                    <tr>
                        <td><?= e($o['organization_code']) ?></td>
                        <td>
                            <?= e($o['organization_name']) ?>
                            <?php if (!empty($o['description'])): ?><br><small><?= e($o['description']) ?></small><?php endif; ?>
                        </td>
                        <td><?= $o['funding_limit'] !== null ? '$' . number_format((float)$o['funding_limit'], 2) : '—' ?></td>
                        <td><?= e((string)($o['max_active_applications'] ?? '—')) ?></td>
                        <td><?= ($o['auto_claim_enabled'] ?? false) ? 'Yes' : 'No' ?></td>
                        <td><span class="pill <?= $o['is_active'] ? 'pill-green' : 'pill-amber' ?>"><?= $o['is_active'] ? 'Active' : 'Inactive' ?></span></td>
                        <td>
                            <button type="button" class="btn small" data-toggle="org-edit-<?= (int)$o['id'] ?>">Edit</button>
                        </td>
                    </tr>
                    <tr class="edit-row" id="org-edit-<?= (int)$o['id'] ?>" hidden>
                        <td colspan="7">
                            <form class="inline-form" action="api/super-admin.php" method="post" data-sa-form data-no-reset>
                                <input type="hidden" name="action" value="update_organization">
                                <input type="hidden" name="organization_id" value="<?= (int)$o['id'] ?>">
                                <div class="field"><label>Name</label><input type="text" name="organization_name" value="<?= e($o['organization_name']) ?>" required></div>
                                <div class="field"><label>Contact Email</label><input type="email" name="contact_email" value="<?= e($o['contact_email'] ?? '') ?>"></div>
                                <div class="field"><label>Phone</label><input type="tel" name="contact_phone" value="<?= e($o['contact_phone'] ?? '') ?>"></div>
                                <div class="field"><label>Description</label><input type="text" name="description" value="<?= e($o['description'] ?? '') ?>"></div>
                                <div class="field"><label>Funding Limit</label><input type="number" step="0.01" name="funding_limit" value="<?= e($o['funding_limit'] ?? '') ?>"></div>
                                <div class="field"><label>Max Active Apps</label><input type="number" name="max_active_applications" value="<?= e($o['max_active_applications'] ?? '') ?>"></div>
                                <div class="field"><label>Notification Email</label><input type="email" name="notification_email" value="<?= e($o['notification_email'] ?? '') ?>"></div>
                                <div class="field" style="flex-direction:row;align-items:center;gap:0.5rem;"><label><input type="checkbox" name="auto_claim_enabled" <?= ($o['auto_claim_enabled'] ?? false) ? 'checked' : '' ?>> Auto-claim</label></div>
                                <div class="field" style="flex-direction:row;align-items:center;gap:0.5rem;"><label><input type="checkbox" name="is_active" <?= $o['is_active'] ? 'checked' : '' ?>> Active</label></div>
                                <button class="btn btn-primary" type="submit">Save</button>
                            </form>

                            <hr class="edit-divider">
                            <h4>Eligibility rules for <?= e($o['organization_name']) ?></h4>

                            <!-- Bulk Preset Loader -->
                            <form class="preset-form" action="api/super-admin.php" method="post" data-sa-form style="display:flex;gap:0.5rem;align-items:flex-end;margin-bottom:0.75rem;padding:0.6rem 0.75rem;background:#f0f7ff;border:1px solid #bfdbfe;border-radius:6px;">
                                <div style="flex:1;">
                                    <label style="font-size:0.75rem;font-weight:600;color:#1e40af;display:block;margin-bottom:0.2rem;">Load Preset</label>
                                    <select name="preset" id="preset-<?= (int)$o['id'] ?>" style="width:100%;padding:0.3rem 0.5rem;border:1px solid #d1d5db;border-radius:4px;font-size:0.85rem;">
                                        <option value="">— Select a preset —</option>
                                        <option value="habitat_for_humanity">Asheville Habitat for Humanity (10 rules)</option>
                                        <option value="community_housing_coalition">Community Housing Coalition (8 rules)</option>
                                        <option value="poder_emma">PODER Emma — Disaster (8 rules)</option>
                                    </select>
                                </div>
                                <input type="hidden" name="action" value="bulk_eligibility_preset">
                                <input type="hidden" name="organization_id" value="<?= (int)$o['id'] ?>">
                                <button type="submit" class="btn btn-primary" id="preset-btn-<?= (int)$o['id'] ?>" style="white-space:nowrap;">Load Preset</button>
                            </form>
                            <table class="data-table small">
                                <thead>
                                    <tr><th>Criteria</th><th>Operator</th><th>Value</th><th>Priority</th><th>Active</th><th></th></tr>
                                </thead>
                                <tbody>
                                    <?php
                                    $orgRules = array_filter($eligibilityRules, fn($r) => (int)$r['organization_id'] === (int)$o['id']);
                                    ?>
                                    <?php if ($orgRules): ?>
                                        <?php foreach ($orgRules as $r): ?>
                                            <tr>
                                                <td><?= e($r['type_name']) ?></td>
                                                <td><?= e($r['rule_operator']) ?></td>
                                                <td><?= e($r['rule_value']) ?></td>
                                                <td><?= (int)$r['priority'] ?></td>
                                                <td><span class="pill <?= $r['is_active'] ? 'pill-green' : 'pill-amber' ?>"><?= $r['is_active'] ? 'Yes' : 'No' ?></span></td>
                                                <td>
                                                    <form action="api/super-admin.php" method="post" class="row-form" data-sa-form>
                                                        <input type="hidden" name="action" value="delete_eligibility_rule">
                                                        <input type="hidden" name="rule_id" value="<?= (int)$r['id'] ?>">
                                                        <button class="btn small" type="submit">Delete</button>
                                                    </form>
                                                </td>
                                            </tr>
                                        <?php endforeach; ?>
                                    <?php else: ?>
                                        <tr><td colspan="6" class="muted">No rules for this organization.</td></tr>
                                    <?php endif; ?>
                                </tbody>
                            </table>
                            <form class="inline-form" action="api/super-admin.php" method="post" data-sa-form>
                                <input type="hidden" name="action" value="create_eligibility_rule">
                                <input type="hidden" name="organization_id" value="<?= (int)$o['id'] ?>">
                                <div class="field"><label>Criteria</label>
                                    <select name="criteria_type_id" required>
                                        <option value="">— Select —</option>
                                        <?php foreach ($criteriaTypes as $ct): ?>
                                            <option value="<?= (int)$ct['id'] ?>"><?= e($ct['type_name']) ?></option>
                                        <?php endforeach; ?>
                                    </select>
                                </div>
                                <div class="field"><label>Operator</label>
                                    <select name="rule_operator">
                                        <option value="equals">equals</option>
                                        <option value="not_equals">not_equals</option>
                                        <option value="greater_than">greater_than</option>
                                        <option value="less_than">less_than</option>
                                        <option value="between">between</option>
                                        <option value="in_list">in_list</option>
                                    </select>
                                </div>
                                <div class="field"><label>Value</label><input type="text" name="rule_value" required></div>
                                <div class="field"><label>Priority</label><input type="number" name="priority" value="0"></div>
                                <button class="btn btn-primary" type="submit">Add Rule</button>
                            </form>

                            <hr class="edit-divider">
                            <div class="danger-zone-inline">
                                <h4><i class="fas fa-triangle-exclamation" aria-hidden="true"></i> Danger Zone</h4>
                                <p>Deleting this organization will remove its users, eligibility rules, funding sources, assignments, queue entries, and case claims. A server-side backup is saved automatically.</p>
                                <button type="button" class="btn btn-danger" data-delete-org="<?= (int)$o['id'] ?>" data-org-code="<?= e($o['organization_code']) ?>" data-org-name="<?= e($o['organization_name']) ?>">Delete this organization</button>
                            </div>
                        </td>
                    </tr>
                <?php endforeach; ?>
            </tbody>
        </table>

        <h4 style="margin-top:2rem;">Add Organization</h4>
        <form class="inline-form" action="api/super-admin.php" method="post" data-sa-form>
            <input type="hidden" name="action" value="create_organization">
            <div class="field"><label>Code</label><input type="text" name="organization_code" required maxlength="20"></div>
            <div class="field"><label>Name</label><input type="text" name="organization_name" required></div>
            <div class="field"><label>Contact Email</label><input type="email" name="contact_email"></div>
            <div class="field"><label>Phone</label><input type="tel" name="contact_phone"></div>
            <div class="field"><label>Description</label><input type="text" name="description"></div>
            <div class="field"><label>Funding Limit</label><input type="number" step="0.01" name="funding_limit"></div>
            <div class="field"><label>Max Active Apps</label><input type="number" name="max_active_applications"></div>
            <div class="field"><label>Notification Email</label><input type="email" name="notification_email"></div>
            <div class="field" style="flex-direction:row;align-items:center;gap:0.5rem;"><label><input type="checkbox" name="auto_claim_enabled"> Auto-claim</label></div>
            <button class="btn btn-primary" type="submit">Add Organization</button>
        </form>
    </section>

    <section class="dash-section" id="users" aria-label="User management">
        <h3 class="dash-section-title"><i class="fas fa-users"></i> User Management</h3>
        <div class="user-tools">
            <form class="inline-form" method="get" action="super-admin.php" style="margin-bottom:1rem;">
                <input type="hidden" name="tab" value="users">
                <div class="field"><label>Search accounts</label><input type="search" name="user_q" value="<?= e($userSearch) ?>" placeholder="Name, username, email"></div>
                <button class="btn" type="submit">Search</button>
                <?php if (!$viewAllUsers): ?>
                    <a href="super-admin.php?tab=users&user_view_all=1<?= $userSearch !== '' ? '&user_q=' . urlencode($userSearch) : '' ?>" class="btn btn-secondary">View all</a>
                <?php else: ?>
                    <a href="super-admin.php?tab=users<?= $userSearch !== '' ? '&user_q=' . urlencode($userSearch) : '' ?>" class="btn btn-secondary">Limit to 100</a>
                <?php endif; ?>
            </form>
            <form action="api/run-maintenance.php" method="post" class="row-form" data-sa-form>
                <input type="hidden" name="action" value="cleanup_requestor_accounts">
                <button class="btn small btn-danger" type="submit">Purge inactive requestor accounts</button>
            </form>
        </div>
        <table class="data-table">
            <thead><tr><th>Name</th><th>Username</th><th>Email</th><th>Roles</th><th>Active</th><th>Actions</th></tr></thead>
            <tbody>
                <?php foreach ($users as $u): ?>
                    <tr>
                        <td><?= e($u['full_name']) ?></td>
                        <td><?= e($u['username']) ?></td>
                        <td><?= e($u['email']) ?></td>
                        <td><?= e($u['roles'] ?: '—') ?></td>
                        <td><span class="pill <?= $u['is_active'] ? 'pill-green' : 'pill-amber' ?>"><?= $u['is_active'] ? 'Yes' : 'No' ?></span></td>
                        <td>
                            <form action="api/super-admin.php" method="post" class="row-form" data-sa-form>
                                <input type="hidden" name="action" value="reset_password">
                                <input type="hidden" name="user_id" value="<?= (int)$u['id'] ?>">
                                <button class="btn small" type="submit">Reset Password</button>
                            </form>
                        </td>
                    </tr>
                <?php endforeach; ?>
            </tbody>
        </table>

        <h4 style="margin-top:2rem;">Create User</h4>
        <form class="inline-form" action="api/super-admin.php" method="post" data-sa-form>
            <input type="hidden" name="action" value="create_user">
            <div class="field"><label>Full Name</label><input type="text" name="full_name" required></div>
            <div class="field"><label>Username</label><input type="text" name="username" required></div>
            <div class="field"><label>Email</label><input type="email" name="email" required></div>
            <div class="field"><label>Phone</label><input type="tel" name="phone"></div>
            <div class="field"><label>Role</label>
                <select name="role_id" required>
                    <option value="">— Select —</option>
                    <?php foreach ($roles as $r): ?>
                        <option value="<?= (int)$r['id'] ?>"><?= e($r['role_name']) ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="field"><label>Organization</label>
                <select name="organization_id" required>
                    <option value="">— Select —</option>
                    <?php foreach ($orgs as $o): ?>
                        <option value="<?= (int)$o['id'] ?>"><?= e($o['organization_name']) ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            <button class="btn btn-primary" type="submit">Create User</button>
        </form>
    </section>

</section>

<!-- One-time credentials modal (create user / reset password) -->
<div class="modal-overlay" id="credentials-modal" role="dialog" aria-modal="true" aria-labelledby="credentials-modal-title" hidden>
    <div class="modal-box">
        <div class="modal-header">
            <h3 id="credentials-modal-title" style="color: var(--color-text);"><i class="fas fa-key" aria-hidden="true"></i> Account credentials</h3>
        </div>
        <div class="modal-body">
            <p>The account is ready. Share these credentials with the user through a direct channel (phone or in person) &mdash; they are <strong>shown only once</strong> and are not emailed.</p>
            <ul class="danger-list">
                <li><span>Username</span><span class="count" id="credentials-username"></span></li>
                <li><span>Temporary password</span><span class="count" id="credentials-password"></span></li>
            </ul>
            <p class="muted">If these credentials are lost, you can reset the password again from User Management.</p>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-secondary" id="credentials-copy"><i class="fas fa-copy" aria-hidden="true"></i> Copy</button>
            <button type="button" class="btn btn-primary" id="credentials-close">Done</button>
        </div>
    </div>
</div>

    <!-- ── Helpdesk Tickets ── -->
    <section class="dash-section" id="helpdesk-tickets" aria-label="Helpdesk Tickets">
        <h3 class="dash-section-title"><i class="fas fa-headset"></i> Helpdesk Tickets</h3>
        <?php if (empty($tickets)): ?>
            <p class="muted">No support tickets yet. They'll appear here when users submit requests via the chat widget.</p>
        <?php else: ?>
        <div style="overflow-x:auto;">
        <table class="data-table">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Category</th>
                    <th>Subject</th>
                    <th>Submitter</th>
                    <th>Priority</th>
                    <th>Assigned</th>
                    <th>Status</th>
                    <th>Created</th>
                </tr>
            </thead>
            <tbody>
            <?php foreach ($tickets as $t): ?>
                <tr>
                    <td><?= (int)$t['id'] ?></td>
                    <td><?= $catLabels[$t['category']] ?? e($t['category']) ?></td>
                    <td>
                        <?= e($t['subject']) ?>
                        <details style="margin-top:0.35rem;">
                            <summary style="cursor:pointer;color:#3b82f6;font-size:0.8rem;">Details</summary>
                            <pre style="white-space:pre-wrap;margin:0.35rem 0;font-size:0.8rem;"><?= e($t['description']) ?></pre>
                            <?php if ($t['resolution_note']): ?>
                                <p style="margin-top:0.35rem;"><strong>Resolution:</strong> <?= e($t['resolution_note']) ?></p>
                            <?php endif; ?>
                        </details>
                    </td>
                    <td>
                        <?= e($t['submitter_display_name'] ?: $t['submitter_name']) ?><br>
                        <small style="color:#6b7280;"><?= e($t['submitter_email']) ?></small>
                    </td>
                    <td>
                        <span style="display:inline-block;width:8px;height:8px;border-radius:50%;background:<?= $priorityColors[$t['priority']] ?? '#6b7280' ?>;margin-right:0.35rem;"></span>
                        <?= e(ucfirst($t['priority'])) ?>
                    </td>
                    <td><?= $t['assigned_name'] ?: '<span style="color:#9ca3af;">Unassigned</span>' ?></td>
                    <td>
                        <?php
                            $cls = match($t['status']) {
                                'open' => 'pill-green',
                                'in_progress' => 'pill-amber',
                                'resolved' => 'pill-blue',
                                'closed' => '',
                                default => 'pill-green',
                            };
                        ?>
                        <span class="pill <?= $cls ?>"><?= e(ucfirst(str_replace('_',' ', $t['status']))) ?></span>
                    </td>
                    <td><?= date('M j, Y', strtotime($t['created_at'])) ?></td>
                </tr>
                <tr>
                    <td colspan="8" style="padding-bottom:0.75rem;">
                        <form method="post" action="api/super-admin.php" style="display:flex;gap:0.5rem;align-items:center;flex-wrap:wrap;">
                            <input type="hidden" name="action" value="assign_ticket">
                            <input type="hidden" name="ticket_id" value="<?= (int)$t['id'] ?>">
                            <select name="assigned_to" style="padding:0.25rem;font-size:0.8rem;border:1px solid #d1d5db;border-radius:4px;">
                                <option value="">— assign —</option>
                                <?php foreach ($allUsers as $u): ?>
                                    <option value="<?= (int)$u['id'] ?>" <?= (int)$t['assigned_to'] === (int)$u['id'] ? 'selected' : '' ?>>
                                        <?= e($u['full_name']) ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                            <button type="submit" class="btn small">Assign</button>
                        </form>
                        <?php if ($t['status'] !== 'resolved' && $t['status'] !== 'closed'): ?>
                        <form method="post" action="api/super-admin.php" style="display:flex;gap:0.5rem;align-items:center;margin-top:0.35rem;flex-wrap:wrap;">
                            <input type="hidden" name="action" value="resolve_ticket">
                            <input type="hidden" name="ticket_id" value="<?= (int)$t['id'] ?>">
                            <input type="text" name="resolution_note" placeholder="Resolution note…" style="flex:1;min-width:12rem;padding:0.25rem;font-size:0.8rem;border:1px solid #d1d5db;border-radius:4px;">
                            <button type="submit" class="btn small btn-primary">Resolve</button>
                        </form>
                        <?php endif; ?>
                    </td>
                </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
        </div>
        <?php endif; ?>
    </section>

    <!-- ── Security: Flagged Login Attempts ── -->
    <section class="dash-section" id="security-logins" aria-label="Security - Login Attempts">
        <h3 class="dash-section-title"><i class="fas fa-shield-halved"></i> Security — Flagged Login Attempts</h3>
        <?php if (empty($loginAttempts)): ?>
            <p class="muted">No flagged login attempts in the last 24 hours.</p>
        <?php else: ?>
        <div style="overflow-x:auto;">
        <table class="data-table">
            <thead>
                <tr>
                    <th>IP Address</th>
                    <th>Attempts</th>
                    <th>Targeted Emails</th>
                    <th>First Attempt</th>
                    <th>Last Attempt</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <?php foreach ($loginAttempts as $la): ?>
                <?php
                    $attemptCount = (int)$la['attempt_count'];
                    $pillClass = $attemptCount >= 10 ? 'pill-red' : ($attemptCount >= 5 ? 'pill-amber' : 'pill-blue');
                ?>
                <tr>
                    <td><code><?= e($la['ip_address']) ?></code></td>
                    <td><span class="pill <?= $pillClass ?>"><?= $attemptCount ?></span></td>
                    <td style="max-width:250px;word-break:break-word;"><?= e($la['targeted_emails']) ?></td>
                    <td><?= date('M j, H:i', strtotime($la['first_attempt'])) ?></td>
                    <td><?= date('M j, H:i', strtotime($la['last_attempt'])) ?></td>
                    <td>
                        <form method="post" action="api/super-admin.php" style="display:inline-flex;gap:0.35rem;align-items:center;">
                            <input type="hidden" name="action" value="block_ip">
                            <input type="hidden" name="ip_address" value="<?= e($la['ip_address']) ?>">
                            <input type="text" name="reason" placeholder="Reason (optional)" style="padding:0.2rem 0.4rem;font-size:0.75rem;border:1px solid #d1d5db;border-radius:4px;width:140px;">
                            <select name="expires_at" style="padding:0.2rem;font-size:0.75rem;border:1px solid #d1d5db;border-radius:4px;">
                                <option value="">Permanent</option>
                                <option value="<?= date('Y-m-d H:i:s', strtotime('+1 day')) ?>">1 Day</option>
                                <option value="<?= date('Y-m-d H:i:s', strtotime('+7 days')) ?>">7 Days</option>
                                <option value="<?= date('Y-m-d H:i:s', strtotime('+30 days')) ?>">30 Days</option>
                            </select>
                            <button type="submit" class="btn small" style="background:#dc2626;" onclick="return confirm('Block IP <?= e($la['ip_address']) ?>?')">Block</button>
                        </form>
                    </td>
                </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
        </div>
        <?php endif; ?>
    </section>

    <!-- ── Security: Blocked IPs ── -->
    <section class="dash-section" id="security-blocked" aria-label="Security - Blocked IPs">
        <h3 class="dash-section-title"><i class="fas fa-ban"></i> Blocked IP Addresses</h3>
        <?php if (empty($blockedIps)): ?>
            <p class="muted">No IP addresses are currently blocked.</p>
        <?php else: ?>
        <div style="overflow-x:auto;">
        <table class="data-table">
            <thead>
                <tr>
                    <th>IP Address</th>
                    <th>Blocked At</th>
                    <th>Reason</th>
                    <th>Expires</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <?php foreach ($blockedIps as $bi): ?>
                <tr>
                    <td><code><?= e($bi['ip_address']) ?></code></td>
                    <td><?= date('M j, Y H:i', strtotime($bi['blocked_at'])) ?></td>
                    <td style="max-width:200px;"><?= e($bi['reason'] ?: '—') ?></td>
                    <td><?= $bi['expires_at'] ? date('M j, Y H:i', strtotime($bi['expires_at'])) : '<em>Never</em>' ?></td>
                    <td>
                        <span class="pill <?= $bi['is_active'] ? 'pill-red' : 'pill-blue' ?>">
                            <?= $bi['is_active'] ? 'Blocked' : 'Unblocked' ?>
                        </span>
                    </td>
                    <td>
                        <?php if ($bi['is_active']): ?>
                        <form method="post" action="api/super-admin.php" style="display:inline;">
                            <input type="hidden" name="action" value="unblock_ip">
                            <input type="hidden" name="ip_address" value="<?= e($bi['ip_address']) ?>">
                            <button type="submit" class="btn small">Unblock</button>
                        </form>
                        <?php else: ?>
                        <span class="muted">—</span>
                        <?php endif; ?>
                    </td>
                </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
        </div>
        <?php endif; ?>
    </section>

<script>
(function () {
    const credModal = document.getElementById('credentials-modal');
    const credUser = document.getElementById('credentials-username');
    const credPass = document.getElementById('credentials-password');
    const credCopy = document.getElementById('credentials-copy');
    const credClose = document.getElementById('credentials-close');

    function showCredentials(username, password) {
        credUser.textContent = username || '(unknown)';
        credPass.textContent = password;
        credModal.hidden = false;
        void credModal.offsetWidth;
        credModal.classList.add('open');
    }

    function closeCredentials() {
        credModal.classList.remove('open');
        setTimeout(() => { credModal.hidden = true; location.reload(); }, 200);
    }

    credClose.addEventListener('click', closeCredentials);
    credModal.addEventListener('click', (e) => { if (e.target === credModal) closeCredentials(); });
    credCopy.addEventListener('click', async () => {
        const text = 'Username: ' + credUser.textContent + '\nTemporary password: ' + credPass.textContent;
        try {
            await navigator.clipboard.writeText(text);
            credCopy.textContent = 'Copied';
        } catch (err) {
            window.prompt('Copy the credentials:', text);
        }
    });

    document.querySelectorAll('[data-sa-form]').forEach(form => {
        form.addEventListener('submit', async e => {
            e.preventDefault();
            // NB: these forms contain <input name="action">, which shadows the
            // form's `action` IDL attribute (form.action returns the ELEMENT).
            // getAttribute() reliably returns the URL string.
            const res = await fetch(form.getAttribute('action'), { method: 'POST', body: new FormData(form) });
            const json = await res.json().catch(() => ({}));
            if (json.success) {
                if (json.created !== undefined) {
                    alert(`Loaded ${json.created} eligibility rules from preset "${json.preset}".`);
                    location.reload();
                } else if (json.temporary_password) {
                    // Show the one-time credentials instead of reloading blindly.
                    showCredentials(json.username || '', json.temporary_password);
                } else {
                    location.reload();
                }
            } else {
                alert(json.error || 'Request failed.');
            }
        });
    });
})();

document.querySelectorAll('[data-toggle]').forEach(btn => {
    btn.addEventListener('click', () => {
        const target = document.getElementById(btn.dataset.toggle);
        if (target) target.hidden = !target.hidden;
    });
});
</script>

<!-- Danger-zone organization delete modal -->
<div class="modal-overlay" id="org-delete-modal" role="dialog" aria-modal="true" aria-labelledby="org-delete-title" hidden>
    <div class="modal-box">
        <div class="modal-header">
            <h3 id="org-delete-title"><i class="fas fa-triangle-exclamation" aria-hidden="true"></i> Danger Zone</h3>
        </div>
        <div class="modal-body">
            <p>You are about to permanently delete <strong id="org-delete-name"></strong> (<code id="org-delete-code"></code>).</p>
            <p>This will remove the organization, its staff users, eligibility rules, funding sources, assignments, queue entries, and case claims. A server-side backup is still saved automatically.</p>
            <ul class="danger-list" id="org-delete-counts"></ul>
            <a class="btn btn-secondary" id="org-delete-download" href="#" download>
                <i class="fas fa-download" aria-hidden="true"></i> Download records before deleting
            </a>
            <label class="danger-ack">
                <input type="checkbox" id="org-delete-ack">
                <span>I have downloaded or do not need the retention archive, and I understand this action cannot be undone.</span>
            </label>
            <div class="danger-confirm">
                <label for="org-delete-confirm">To confirm, type the organization code: <code id="org-delete-target"></code></label>
                <input type="text" id="org-delete-confirm" autocomplete="off" aria-label="Type organization code to confirm deletion">
            </div>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-secondary" id="org-delete-cancel">Cancel</button>
            <button type="button" class="btn btn-danger" id="org-delete-submit" disabled>Delete this organization</button>
        </div>
    </div>
</div>

<script>
(function() {
    const modal = document.getElementById('org-delete-modal');
    const nameEl = document.getElementById('org-delete-name');
    const codeEl = document.getElementById('org-delete-code');
    const targetEl = document.getElementById('org-delete-target');
    const countsEl = document.getElementById('org-delete-counts');
    const downloadEl = document.getElementById('org-delete-download');
    const ackEl = document.getElementById('org-delete-ack');
    const confirmEl = document.getElementById('org-delete-confirm');
    const submitBtn = document.getElementById('org-delete-submit');
    const cancelBtn = document.getElementById('org-delete-cancel');
    let currentOrgId = 0;
    let targetCode = '';

    function openModal() {
        modal.hidden = false;
        // force reflow so the opacity transition fires
        void modal.offsetWidth;
        modal.classList.add('open');
        confirmEl.focus();
    }

    function closeModal() {
        modal.classList.remove('open');
        setTimeout(() => { modal.hidden = true; }, 200);
        currentOrgId = 0;
        targetCode = '';
        ackEl.checked = false;
        confirmEl.value = '';
        confirmEl.classList.remove('error');
        updateSubmit();
    }

    function updateSubmit() {
        const confirmed = confirmEl.value.trim() === targetCode && targetCode !== '';
        confirmEl.classList.toggle('error', confirmEl.value.trim() !== '' && !confirmed);
        submitBtn.disabled = !(ackEl.checked && confirmed);
    }

    document.querySelectorAll('[data-delete-org]').forEach(btn => {
        btn.addEventListener('click', async () => {
            const orgId = parseInt(btn.dataset.deleteOrg, 10);
            const code = btn.dataset.orgCode || '';
            const name = btn.dataset.orgName || '';
            currentOrgId = orgId;
            targetCode = code;

            nameEl.textContent = name;
            codeEl.textContent = code;
            targetEl.textContent = code;
            downloadEl.href = `api/export-organization.php?organization_id=${orgId}`;
            countsEl.innerHTML = '<li>Loading associated records…</li>';

            openModal();

            try {
                const form = new FormData();
                form.append('action', 'prepare_delete_organization');
                form.append('organization_id', String(orgId));
                const res = await fetch('api/super-admin.php', { method: 'POST', body: form });
                const json = await res.json().catch(() => ({}));
                if (json.success && json.counts) {
                    const labels = {
                        organization_users: 'Organization users',
                        user_role_assignments: 'System role assignments',
                        organization_eligibility_rules: 'Eligibility rules',
                        eligibility_results: 'Eligibility results',
                        organization_metrics: 'Metrics records',
                        funding_sources: 'Funding sources',
                        application_assignments: 'Application assignments',
                        review_queue: 'Review queue entries',
                        case_claims: 'Claimed cases',
                        reimbursement_requests: 'Reimbursement requests',
                        bursar_action_audit: 'Bursar audit entries',
                    };
                    countsEl.innerHTML = Object.entries(json.counts)
                        .map(([key, count]) => `<li><span>${labels[key] || key}</span><span class="count">${Number(count).toLocaleString()}</span></li>`)
                        .join('');
                } else {
                    countsEl.innerHTML = `<li class="count">${json.error || 'Could not load counts.'}</li>`;
                }
            } catch (err) {
                countsEl.innerHTML = '<li class="count">Could not load counts.</li>';
            }
        });
    });

    ackEl.addEventListener('change', updateSubmit);
    confirmEl.addEventListener('input', updateSubmit);

    cancelBtn.addEventListener('click', closeModal);
    modal.addEventListener('click', (e) => {
        if (e.target === modal) closeModal();
    });

    submitBtn.addEventListener('click', async () => {
        if (submitBtn.disabled) return;
        submitBtn.disabled = true;
        submitBtn.textContent = 'Deleting…';
        try {
            const form = new FormData();
            form.append('action', 'delete_organization');
            form.append('organization_id', String(currentOrgId));
            form.append('confirmation', confirmEl.value.trim());
            form.append('acknowledge', ackEl.checked ? '1' : '0');
            const res = await fetch('api/super-admin.php', { method: 'POST', body: form });
            const json = await res.json().catch(() => ({}));
            if (json.success) {
                location.reload();
            } else {
                alert(json.error || 'Deletion failed.');
                submitBtn.disabled = false;
                submitBtn.textContent = 'Delete this organization';
            }
        } catch (err) {
            alert('Could not reach the server.');
            submitBtn.disabled = false;
            submitBtn.textContent = 'Delete this organization';
        }
    });
})();
</script>
