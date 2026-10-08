<?php
/**
 * Common dashboard home component for all roles.
 * Displays: welcome message, alerts, case search, and quick task box.
 * 
 * Expected variables:
 * @var string $userName User's display name
 * @var string $roleLabel Role label (e.g., "Assessor", "Project Manager")
 * @var array $stats Key-value pairs of statistics to display
 * @var array $alerts Array of alert items
 * @var string $apiEndpoint API endpoint for this role's data
 */

$userName = $userName ?? 'User';
$roleLabel = $roleLabel ?? 'Team Member';
$stats = $stats ?? [];
$alerts = $alerts ?? [];
?>

<section class="portal-page active" id="dashboardHomePage" data-page-title="Dashboard">
    
    <!-- Welcome Message -->
    <div class="dash-hero">
        <div>
            <h2>Welcome back, <?= e(explode(' ', $userName)[0]) ?></h2>
            <p class="dash-hero-subtitle">
                <?= e(date('l, F j, Y')) ?> &middot; <?= e($roleLabel) ?> Dashboard
            </p>
        </div>
        <div class="dash-hero-meta">
            <?php if (!empty($stats)): 
                $firstStat = array_values($stats)[0];
                $firstStatLabel = array_keys($stats)[0];
            ?>
                <span class="hero-count-label"><?= e(ucwords(str_replace('_', ' ', $firstStatLabel))) ?></span>
                <span class="hero-count"><?= e((string)$firstStat) ?></span>
            <?php endif; ?>
        </div>
    </div>

    <!-- Alerts Section -->
    <?php if (!empty($alerts)): ?>
    <section class="dash-section" aria-labelledby="alerts-h">
        <div class="section-header-row">
            <h3 class="dash-section-title" id="alerts-h">
                <i class="fas fa-bell"></i> Upcoming Jobs & Alerts
            </h3>
            <a href="#alerts" class="see-all-link">View all &rarr;</a>
        </div>
        <article class="panel">
            <ul class="alert-list">
                <?php foreach (array_slice($alerts, 0, 5) as $alert): ?>
                    <li class="alert-row <?= isset($alert['severity']) && $alert['severity'] === 'high' ? 'is-danger' : '' ?>">
                        <span class="alert-dot" aria-hidden="true">
                            <i class="fas <?= e($alert['icon'] ?? 'fa-circle-info') ?>"></i>
                        </span>
                        <div>
                            <div class="alert-title"><?= e($alert['title'] ?? 'Alert') ?></div>
                            <div class="alert-detail"><?= e($alert['message'] ?? '') ?></div>
                        </div>
                        <?php if (isset($alert['display_time'])): ?>
                            <span class="alert-time"><?= e($alert['display_time']) ?></span>
                        <?php endif; ?>
                    </li>
                <?php endforeach; ?>
            </ul>
        </article>
    </section>
    <?php endif; ?>

    <!-- Case Search -->
    <section class="case-search" aria-labelledby="case-search-h">
        <h3 class="dash-section-title" id="case-search-h">
            <i class="fas fa-magnifying-glass"></i> Case Search
        </h3>
        <article class="panel">
            <div class="case-search-row">
                <span class="case-search-icon" aria-hidden="true">
                    <i class="fas fa-magnifying-glass"></i>
                </span>
                <input type="search" class="case-search-input" id="globalCaseSearch"
                    placeholder="Search by case #, address, applicant name, or phone"
                    aria-label="Global case search">
                <button type="button" class="btn btn-primary btn-sm" id="globalCaseSearchBtn">
                    <i class="fas fa-arrow-right"></i> Search
                </button>
            </div>
            <div class="case-search-filters" role="group" aria-label="Quick filters">
                <button type="button" class="case-search-filter is-active">All cases</button>
                <button type="button" class="case-search-filter">My cases</button>
                <button type="button" class="case-search-filter">Recent</button>
                <button type="button" class="case-search-filter">Urgent</button>
            </div>
        </article>
    </section>

    <!-- Quick Task Box -->
    <section class="dash-section" aria-labelledby="quick-task-h">
        <h3 class="dash-section-title" id="quick-task-h">
            <i class="fas fa-bolt"></i> Quick Task
        </h3>
        <article class="panel">
            <p style="margin-bottom: var(--space-3); color: var(--color-text-muted);">
                Quickly log a task, event, or note. This will be added to the task rabbit queue for processing.
            </p>
            <form id="quickTaskForm" class="quick-task-form">
                <div class="form-group">
                    <label for="quickTaskType" class="form-label">Type</label>
                    <select id="quickTaskType" name="task_type" class="form-input" required>
                        <option value="">Select type...</option>
                        <option value="task">Task</option>
                        <option value="event">Event</option>
                        <option value="log">Log Entry</option>
                        <option value="note">Note</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="quickTaskText" class="form-label">Description</label>
                    <textarea id="quickTaskText" name="task_text" class="form-input" 
                        rows="4" placeholder="Enter task details..." required></textarea>
                </div>
                <div class="form-group" style="margin-bottom: 0;">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-paper-plane"></i> Submit to Queue
                    </button>
                    <button type="reset" class="btn btn-secondary">
                        <i class="fas fa-xmark"></i> Clear
                    </button>
                </div>
            </form>
        </article>
    </section>

    <!-- Role-specific notice -->
    <p class="role-notice">
        <i class="fas fa-circle-info"></i>
        <span>
            <strong>Dashboard Home:</strong>
            This is your default landing page. Use the sidebar menu to access specific features
            and tools for your role. Quick actions and recent alerts are shown above for convenience.
        </span>
    </p>

</section>

<style>
.dash-hero-subtitle {
    color: var(--color-text-muted, #666);
    font-size: var(--fs-sm, 0.875rem);
}

.case-search-row {
    display: flex;
    gap: var(--space-2, 0.5rem);
    align-items: center;
    margin-bottom: var(--space-3, 1rem);
}

.case-search-icon {
    color: var(--color-text-muted, #666);
    font-size: var(--fs-lg, 1.125rem);
}

.case-search-input {
    flex: 1;
    padding: var(--space-2, 0.5rem) var(--space-3, 1rem);
    border: 1px solid var(--color-border, #ddd);
    border-radius: var(--radius-md, 0.375rem);
    font-size: var(--fs-base, 1rem);
}

.case-search-filters {
    display: flex;
    gap: var(--space-2, 0.5rem);
    flex-wrap: wrap;
}

.case-search-filter {
    padding: var(--space-1, 0.25rem) var(--space-3, 1rem);
    background: var(--color-bg-secondary, #f5f5f5);
    border: 1px solid var(--color-border, #ddd);
    border-radius: var(--radius-full, 9999px);
    cursor: pointer;
    font-size: var(--fs-sm, 0.875rem);
    transition: all 0.2s;
}

.case-search-filter:hover {
    background: var(--color-bg-hover, #e5e5e5);
}

.case-search-filter.is-active {
    background: var(--color-primary, #3b82f6);
    color: white;
    border-color: var(--color-primary, #3b82f6);
}

.quick-task-form .form-group {
    margin-bottom: var(--space-4, 1.5rem);
}

.quick-task-form .form-label {
    display: block;
    margin-bottom: var(--space-2, 0.5rem);
    font-weight: 600;
    font-size: var(--fs-sm, 0.875rem);
}

.quick-task-form .form-input {
    width: 100%;
    padding: var(--space-2, 0.5rem) var(--space-3, 1rem);
    border: 1px solid var(--color-border, #ddd);
    border-radius: var(--radius-md, 0.375rem);
    font-size: var(--fs-base, 1rem);
    font-family: inherit;
}

.quick-task-form select.form-input {
    cursor: pointer;
}

.quick-task-form textarea.form-input {
    resize: vertical;
    min-height: 100px;
}

.alert-time {
    font-size: var(--fs-xs, 0.75rem);
    color: var(--color-text-muted, #666);
    white-space: nowrap;
}
</style>

<script>
// Quick task form handler
document.getElementById('quickTaskForm')?.addEventListener('submit', async function(e) {
    e.preventDefault();
    const formData = new FormData(this);
    try {
        const response = await fetch('api/tasks/quick-add.php', {
            method: 'POST',
            body: formData
        });
        const result = await response.json();
        if (result.success) {
            alert('Task added to queue successfully!');
            this.reset();
        } else {
            alert('Error: ' + (result.message || 'Failed to add task'));
        }
    } catch (error) {
        alert('Error submitting task: ' + error.message);
    }
});

// Case search handler
document.getElementById('globalCaseSearchBtn')?.addEventListener('click', async function() {
    const query = document.getElementById('globalCaseSearch')?.value;
    const activeFilter = document.querySelector('.case-search-filter.is-active');
    const filter = activeFilter?.textContent.toLowerCase().replace(' ', '_') || 'all';

    if (!query || query.trim() === '') {
        alert('Please enter a search term');
        return;
    }

    try {
        const response = await fetch(`api/cases/search.php?q=${encodeURIComponent(query)}&filter=${filter}`);
        const result = await response.json();

        if (result.success) {
            console.log('Search results:', result.data);
            // TODO: Display results in a modal or results panel
            alert(`Found ${result.count} case(s)`);
        } else {
            alert('Search failed: ' + (result.message || 'Unknown error'));
        }
    } catch (error) {
        alert('Search error: ' + error.message);
    }
});

// Filter button toggles
document.querySelectorAll('.case-search-filter').forEach(btn => {
    btn.addEventListener('click', function() {
        document.querySelectorAll('.case-search-filter').forEach(b => b.classList.remove('is-active'));
        this.classList.add('is-active');
    });
});
</script>
