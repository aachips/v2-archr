<template>
  <div class="volunteer-welcome">
    <!-- Welcome Hero -->
    <section class="welcome-hero">
      <h2>Welcome, {{ auth.displayName }}!</h2>
      <p class="hero-lead">Thank you for showing up for your neighbors. Your volunteer contributions make this coalition possible.</p>
      <div class="hero-meta">
        <span class="role-badge"><i class="fas fa-hand-holding-heart"></i> Volunteer</span>
      </div>
    </section>

    <!-- Quick Stats -->
    <section class="quick-stats" v-if="profile">
      <div class="stat-card">
        <span class="stat-value">{{ profile.hoursLogged ?? '—' }}</span>
        <span class="stat-label">Hours Logged</span>
      </div>
      <div class="stat-card">
        <span class="stat-value">{{ profile.xp ?? 0 }}</span>
        <span class="stat-label">XP Points</span>
      </div>
      <div class="stat-card">
        <span class="stat-value">Level {{ profile.level ?? 1 }}</span>
        <span class="stat-label">Volunteer Level</span>
      </div>
      <div class="stat-card">
        <span class="stat-value">{{ profile.questsCompleted ?? 0 }}</span>
        <span class="stat-label">Tasks Completed</span>
      </div>
    </section>

    <!-- What You Can Do -->
    <section class="what-you-can-do">
      <h3>What You Can Do</h3>
      <ul>
        <li>Browse and claim volunteer opportunities in your area</li>
        <li>Log your volunteer hours with photo documentation</li>
        <li>Track your XP, reputation, and level progression</li>
        <li>Complete safety orientations and skill trainings</li>
        <li>Share stories and field notes with the community</li>
      </ul>
    </section>

    <!-- Expandable: Role Details (Who Am I? merged here) -->
    <details class="role-details">
      <summary>
        <h3><i class="fas fa-circle-info"></i> Role Details — Who Am I?</h3>
      </summary>

      <div class="role-detail-content">
        <!-- Identity -->
        <div class="detail-card">
          <h4>Your Identity</h4>
          <div class="info-grid">
            <span class="info-label">Name</span><span class="info-value">{{ auth.displayName }}</span>
            <span class="info-label">Email</span><span class="info-value mono">{{ auth.user?.email || '—' }}</span>
            <span class="info-label">Role</span><span class="info-value"><span class="badge volunteer-badge">Volunteer</span></span>
            <span class="info-label">Permission Level</span><span class="info-value"><span class="badge level-badge">Level {{ auth.roleLevel ?? 1 }}</span></span>
          </div>
        </div>

        <!-- Capabilities -->
        <div class="detail-card">
          <h4>Your Capabilities</h4>
          <div class="cap-grid">
            <div class="cap-item yes" v-for="cap in volunteerCaps" :key="cap">
              <span class="cap-icon">&#9989;</span>
              <span class="cap-label">{{ cap }}</span>
            </div>
          </div>
        </div>

        <!-- Boundaries -->
        <div class="detail-card boundaries-card">
          <h4><i class="fas fa-shield-halved"></i> Role Boundaries</h4>
          <p>As a Volunteer, your access is intentionally limited to protect applicant privacy:</p>
          <ul class="boundary-list">
            <li class="can"><strong>You can:</strong> view shifts you've signed up for, log your hours, browse open opportunities cards, see your own XP and reputation</li>
            <li class="cannot"><strong>You cannot:</strong> view applicant case files, see financial details, access other volunteers' private data, manage organizational settings</li>
          </ul>
        </div>

        <!-- Progression Path -->
        <div class="detail-card">
          <h4>Volunteer Progression Path</h4>
          <div class="progression-steps">
            <div class="prog-step" v-for="step in progressionSteps" :key="step.level">
              <span class="prog-dot" :class="{ completed: (profile?.level ?? 1) >= step.level }">{{ step.level }}</span>
              <div class="prog-body">
                <strong>{{ step.title }}</strong>
                <small>{{ step.desc }}</small>
              </div>
            </div>
          </div>
        </div>
      </div>
    </details>
  </div>
</template>

<script>
export default {
  name: 'VolunteerWelcome',
  data() {
    return {
      volunteerCaps: [
        'View assigned tasks',
        'Log volunteer hours',
        'Browse open opportunities',
        'Upload completion photos',
        'View own XP and reputation',
        'Complete safety orientations',
        'Share field stories',
      ],
      progressionSteps: [
        { level: 1, title: 'New Volunteer', desc: 'Complete orientation, claim your first shift' },
        { level: 2, title: 'Active Volunteer', desc: '100 XP — Regular contributor' },
        { level: 3, title: 'Experienced Volunteer', desc: '300 XP — Trusted on diverse crews' },
        { level: 4, title: 'Field Volunteer', desc: '500 XP — Mentoring newcomers' },
        { level: 5, title: 'Crew Member', desc: '1000 XP — Eligible for crew lead pathway' },
      ],
    };
  },
  computed: {
    auth() {
      return this.$auth;
    },
    profile() {
      // Placeholder — will be wired to backend volunteer_profiles once API is connected
      return this.$auth.user?.volunteer_profile || null;
    },
  },
};
</script>

<style scoped>
.volunteer-welcome {
  max-width: 800px;
  margin: 0 auto;
  padding: 1.5rem;
}

/* Hero */
.welcome-hero {
  background: linear-gradient(135deg, var(--color-accent, #2563eb), #7c3aed);
  color: #fff;
  border-radius: 12px;
  padding: 2rem;
  margin-bottom: 1.5rem;
}

.welcome-hero h2 {
  font-size: 1.6rem;
  margin: 0 0 0.5rem;
}

.hero-lead {
  font-size: 1rem;
  opacity: 0.9;
  margin: 0 0 1rem;
  max-width: 55ch;
}

.hero-meta {
  display: flex;
  gap: 0.75rem;
}

.role-badge {
  background: rgba(255, 255, 255, 0.2);
  padding: 0.35rem 0.75rem;
  border-radius: 999px;
  font-size: 0.85rem;
  font-weight: 600;
  border: 1px solid rgba(255, 255, 255, 0.3);
}

/* Quick stats */
.quick-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.stat-card {
  background: var(--color-surface, #fff);
  border: 1px solid var(--color-border, #e2e8f0);
  border-radius: 10px;
  padding: 1rem;
  text-align: center;
  border-top: 3px solid var(--color-accent, #2563eb);
}

.stat-value {
  display: block;
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--color-text, #1a1a2e);
  font-family: var(--font-display, 'Poppins', sans-serif);
}

.stat-label {
  display: block;
  font-size: 0.8rem;
  color: var(--color-text-secondary, #64748b);
  margin-top: 0.25rem;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

/* What you can do */
.what-you-can-do {
  background: var(--color-surface, #fff);
  border: 1px solid var(--color-border, #e2e8f0);
  border-radius: 10px;
  padding: 1.25rem;
  margin-bottom: 1.5rem;
}

.what-you-can-do h3 {
  font-size: 1rem;
  color: var(--color-text, #16213e);
  margin: 0 0 0.75rem;
}

.what-you-can-do ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

.what-you-can-do li {
  padding: 0.5rem 0;
  border-bottom: 1px solid var(--color-border, #e2e8f0);
  font-size: 0.9rem;
  color: var(--color-text, #1a1a2e);
}

.what-you-can-do li:last-child {
  border-bottom: none;
}

.what-you-can-do li::before {
  content: '\2713';
  color: var(--color-success, #22c55e);
  margin-right: 0.5rem;
  font-weight: 700;
}

/* Expandable role details */
.role-details {
  border: 1px solid var(--color-border, #e2e8f0);
  border-radius: 10px;
  background: var(--color-surface, #fff);
  margin-bottom: 1rem;
}

.role-details summary {
  cursor: pointer;
  padding: 1rem 1.25rem;
  list-style: none;
  display: flex;
  align-items: center;
}

.role-details summary::-webkit-details-marker {
  display: none;
}

.role-details summary h3 {
  font-size: 1rem;
  color: var(--color-accent, #2563eb);
  margin: 0;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.role-details summary h3 i {
  font-size: 0.9rem;
}

.role-details[open] summary {
  border-bottom: 1px solid var(--color-border, #e2e8f0);
}

.role-detail-content {
  padding: 1.25rem;
}

/* Detail cards */
.detail-card {
  background: var(--color-surface-alt, #f8fafc);
  border: 1px solid var(--color-border, #e2e8f0);
  border-radius: 8px;
  padding: 1rem;
  margin-bottom: 1rem;
}

.detail-card:last-child {
  margin-bottom: 0;
}

.detail-card h4 {
  font-size: 0.9rem;
  color: var(--color-text, #16213e);
  margin: 0 0 0.75rem;
  padding-bottom: 0.5rem;
  border-bottom: 2px solid var(--color-border, #e2e8f0);
}

/* Info grid */
.info-grid {
  display: grid;
  grid-template-columns: 130px 1fr;
  gap: 0.35rem 0.75rem;
  font-size: 0.85rem;
}

.info-label {
  color: var(--color-text-secondary, #64748b);
  font-weight: 500;
}

.info-value {
  color: var(--color-text, #1a1a2e);
}

.mono {
  font-family: ui-monospace, 'Cascadia Code', 'Consolas', monospace;
  font-size: 0.8rem;
}

.badge {
  display: inline-block;
  padding: 0.15rem 0.5rem;
  border-radius: 999px;
  font-size: 0.75rem;
  font-weight: 600;
}

.volunteer-badge {
  background: #dbeafe;
  color: #1e40af;
}

.level-badge {
  background: #e0e7ff;
  color: #3730a3;
}

/* Capabilities */
.cap-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 0.35rem;
}

.cap-item {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  padding: 0.3rem 0.5rem;
  border-radius: 6px;
  font-size: 0.8rem;
}

.cap-item.yes {
  background: #f0fdf4;
  border-left: 3px solid #22c55e;
}

.cap-icon {
  font-size: 0.85rem;
}

/* Boundaries */
.boundaries-card {
  border-left: 4px solid var(--color-accent, #2563eb);
}

.boundary-list {
  list-style: none;
  padding: 0;
  margin: 0.5rem 0 0;
}

.boundary-list li {
  padding: 0.5rem 0.75rem;
  border-radius: 6px;
  margin-bottom: 0.35rem;
  font-size: 0.85rem;
  line-height: 1.5;
}

.boundary-list li.can {
  background: #f0fdf4;
  border-left: 3px solid #22c55e;
}

.boundary-list li.cannot {
  background: #fef2f2;
  border-left: 3px solid #ef4444;
}

/* Progression */
.progression-steps {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.prog-step {
  display: flex;
  align-items: flex-start;
  gap: 0.75rem;
}

.prog-dot {
  flex-shrink: 0;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: var(--color-border, #e2e8f0);
  color: var(--color-text-secondary, #64748b);
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 0.85rem;
  border: 2px solid var(--color-border, #e2e8f0);
}

.prog-dot.completed {
  background: var(--color-accent, #2563eb);
  color: #fff;
  border-color: var(--color-accent, #2563eb);
}

.prog-body {
  display: flex;
  flex-direction: column;
  padding-top: 0.3rem;
}

.prog-body strong {
  font-size: 0.9rem;
  color: var(--color-text, #1a1a2e);
}

.prog-body small {
  font-size: 0.8rem;
  color: var(--color-text-secondary, #64748b);
}
</style>
