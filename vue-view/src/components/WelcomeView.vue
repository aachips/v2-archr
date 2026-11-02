<template>
  <div class="welcome">
    <div class="welcome-card">
      <h1>👋 Welcome, {{ auth.displayName }}!</h1>
      <p class="welcome-role">
        You are logged in as a <strong>{{ roleDisplay }}</strong>.
      </p>

      <!-- Role-specific welcome message -->
      <div class="welcome-message">
        <p>{{ welcomeMessage }}</p>
      </div>

      <!-- Under construction banner for roles without a built dashboard -->
      <div v-if="underConstruction" class="status-banner">
        <span class="status-icon">🚧</span>
        <div>
          <p><strong>This area is under construction.</strong></p>
          <p>Your full dashboard is being built right now. Here's what will be available here:</p>
        </div>
      </div>

      <div v-if="futureFeatures.length" class="future-features">
        <h3>Coming soon:</h3>
        <ul>
          <li v-for="feature in futureFeatures" :key="feature">{{ feature }}</li>
        </ul>
      </div>

      <div class="quick-info">
        <h3>What you can do right now:</h3>
        <ul>
          <li v-for="action in currentActions" :key="action">{{ action }}</li>
        </ul>
      </div>

      <div class="debug-info">
        <details>
          <summary>Technical details</summary>
          <table>
            <tr><th>Role</th><td>{{ auth.role }}</td></tr>
            <tr><th>Permission Level</th><td>{{ auth.roleLevel }}</td></tr>
            <tr><th>Email</th><td class="mono">{{ auth.user?.email }}</td></tr>
          </table>
        </details>
      </div>
    </div>
  </div>
</template>

<script>
/**
 * Role-specific welcome messages and feature lists.
 * Each role gets a personalized greeting and a list of what's coming.
 */
const ROLE_WELCOME = {
  volunteer: {
    message: "Thank you for showing up for your neighbors! Your volunteer contributions make this coalition possible.",
    underConstruction: true,
    future: [
      "📋 Available Quests — Browse and claim volunteer tasks in your area",
      "🏆 Reputation & XP — Track your volunteer impact and earn badges",
      "📅 Availability — Set your schedule and skills so coordinators can match you",
      "⏱️ Hour Logging — Log your volunteer hours directly from here",
      "📊 Impact Dashboard — See your total contributions to the coalition",
    ],
    actions: [
      "Check your Profile to review your account details",
      "Click Who Am I? to see your role, permissions, and capabilities",
      "Check back soon for the full volunteer experience!",
    ],
  },
  requestor: {
    message: "Thank you for reaching out. You can use this portal to track your home repair application, upload supporting documents, and stay informed about your case status.",
    underConstruction: true,
    future: [
      "📄 Application Status — Track your home repair application in real time",
      "📎 Document Upload — Upload photos, insurance docs, and supporting materials",
      "💬 Case Updates — Receive notifications when your case status changes",
      "📅 Appointment Info — See scheduled assessment and repair dates",
      "🏠 Repair Progress — Track the progress of repairs on your home",
    ],
    actions: [
      "Check your Profile to review your account details",
      "Click Who Am I? to see your role and permissions",
      "Check back soon for your full application dashboard!",
    ],
  },
  'crew-member': {
    message: "Welcome to the crew! You're part of the team getting work done in the field.",
    underConstruction: true,
    future: [
      "📋 Assigned Tasks — See your daily task assignments",
      "⏱️ Hour Logging — Log your work hours on-site",
      "📅 Schedule — View your upcoming work schedule",
      "📝 Task Updates — Update task status as you complete work",
    ],
    actions: [
      "Check your Profile to review your account details",
      "Check back soon for your task dashboard!",
    ],
  },
  subcontractor: {
    message: "Welcome! You can claim repair tasks, submit quotes, and manage your work from here.",
    underConstruction: false,
    future: [],
    actions: [
      "Go to Marketplace to browse available tasks",
      "Check your Profile to manage your account",
    ],
  },
  assessor: {
    message: "Welcome, Assessor! You can look up cases, conduct assessments, and document repair needs.",
    underConstruction: true,
    future: [
      "🔍 Case Lookup — Search and view assigned cases",
      "📋 Assessment Forms — Complete field assessments",
      "📸 Photo Upload — Document conditions and repair needs",
      "📝 Assessment Reports — Submit your findings",
    ],
    actions: [
      "Check your Profile to review your account details",
      "Click Who Am I? to see your permissions",
      "Check back soon for your assessment dashboard!",
    ],
  },
  'crew-lead': {
    message: "Welcome, Crew Lead! You'll manage field teams and coordinate on-site work.",
    underConstruction: true,
    future: [
      "👥 Team Management — View and manage your crew assignments",
      "📋 Task Queue — Prioritize and distribute tasks to crew members",
      "📅 Scheduling — Plan work days and assign shifts",
      "📊 Progress Reports — Track team completion rates",
    ],
    actions: [
      "Check your Profile to review your account details",
      "Check back soon for your crew management dashboard!",
    ],
  },
  envoy: {
    message: "Welcome, Envoy! You connect the coalition with the community.",
    underConstruction: true,
    future: [
      "📋 Community Cases — Track cases you're advocating for",
      "📞 Contact Log — Record community interactions",
      "📊 Outreach Metrics — Track your community engagement",
    ],
    actions: [
      "Check your Profile to review your account details",
      "Check back soon for your outreach dashboard!",
    ],
  },
  'tle-poc': {
    message: "Welcome! You coordinate tasks, logs, and events across the coalition.",
    underConstruction: true,
    future: [
      "📋 Task Coordination — Track and coordinate tasks",
      "📝 Activity Logs — Review and manage activity logs",
      "📅 Event Planning — Coordinate coalition events",
    ],
    actions: [
      "Check your Profile to review your account details",
      "Check back soon for your coordination dashboard!",
    ],
  },
  'project-manager': {
    message: "Welcome, Project Manager! You oversee projects, teams, and repair workflows.",
    underConstruction: true,
    future: [
      "📊 Project Dashboard — Overview of all active projects",
      "👥 Team Management — Assign and manage staff and crews",
      "📋 Task Workflows — Create and monitor repair task workflows",
      "💰 Budget Tracking — Monitor project finances",
      "📅 Schedule — Coordinate project timelines",
    ],
    actions: [
      "Check your Profile to review your account details",
      "Check back soon for your project management dashboard!",
    ],
  },
  bursar: {
    message: "Welcome, Bursar! You manage finances, reimbursements, and invoices.",
    underConstruction: true,
    future: [
      "💰 Budget Overview — Track funding and expenditures",
      "📄 Reimbursements — Process reimbursement requests",
      "🧾 Invoices — Review and approve subcontractor invoices",
      "📊 Financial Reports — Generate financial summaries",
    ],
    actions: [
      "Check your Profile to review your account details",
      "Check back soon for your financial dashboard!",
    ],
  },
  'org-admin': {
    message: "Welcome, Organization Admin! You have full access to manage your organization's cases, team, and operations.",
    underConstruction: true,
    future: [
      "📊 Org Dashboard — Full overview of your organization",
      "👥 Team Management — Add and manage team members",
      "📋 Case Management — Review and assign cases",
      "📎 Documents — Manage your organization's document bucket",
      "💰 Finance — Oversee budgets and reimbursements",
    ],
    actions: [
      "Check your Profile to review your account details",
      "Check back soon for your admin dashboard!",
    ],
  },
  admin: {
    message: "Welcome, Administrator! You manage your organization's operations and team.",
    underConstruction: true,
    future: [
      "📊 Admin Dashboard — Overview of operations",
      "👥 Team Management — Manage your organization's staff",
      "📋 Case Oversight — Review and manage cases",
      "📎 Document Management — Organize and track documents",
    ],
    actions: [
      "Check your Profile to review your account details",
      "Check back soon for your admin dashboard!",
    ],
  },
  caseworker: {
    message: "Welcome, Caseworker! You work directly with applicants to manage their cases.",
    underConstruction: true,
    future: [
      "📋 My Cases — Cases assigned to you",
      "📞 Applicant Contact — Log interactions with applicants",
      "📝 Case Notes — Add notes and updates to cases",
      "📊 Case Progress — Track your case completion rate",
    ],
    actions: [
      "Check your Profile to review your account details",
      "Check back soon for your casework dashboard!",
    ],
  },
  'super-admin': {
    message: "Welcome, Super Administrator! You manage the entire platform across all organizations.",
    underConstruction: false,
    future: [],
    actions: [
      "Use the Super Admin panel to manage the platform",
      "Check your Profile to review your account details",
    ],
  },
};

export default {
  name: 'WelcomeView',
  computed: {
    auth() {
      return this.$auth;
    },
    roleDisplay() {
      return this.auth?.user?.role_display || 'User';
    },
    roleConfig() {
      const role = this.auth?.user?.role || '';
      return ROLE_WELCOME[role] || {
        message: `Welcome! You are logged in as a ${this.roleDisplay}.`,
        underConstruction: true,
        future: ['More features coming soon!'],
        actions: ['Check your Profile to review your account details'],
      };
    },
    welcomeMessage() {
      return this.roleConfig.message;
    },
    underConstruction() {
      return this.roleConfig.underConstruction;
    },
    futureFeatures() {
      return this.roleConfig.future || [];
    },
    currentActions() {
      return this.roleConfig.actions || [];
    },
  },
};
</script>

<style scoped>
.welcome {
  max-width: 700px;
  margin: 0 auto;
  padding: 1.5rem;
}

.welcome-card {
  background: var(--color-surface, white);
  border: 1px solid var(--color-border, #e2e8f0);
  border-radius: 12px;
  padding: 2rem;
}

.welcome h1 {
  font-size: 1.6rem;
  color: var(--color-text, #1a1a2e);
  margin: 0 0 0.5rem;
}

.welcome-role {
  font-size: 1.1rem;
  color: var(--color-text-secondary, #666);
  margin: 0 0 1.5rem;
}

.welcome-message {
  background: var(--color-surface-alt, #f8fafc);
  border-left: 4px solid var(--color-accent, #2563eb);
  border-radius: 6px;
  padding: 1rem;
  margin-bottom: 1.5rem;
}

.welcome-message p {
  margin: 0;
  color: var(--color-text, #1a1a2e);
  line-height: 1.6;
}

.status-banner {
  background: #fffbeb;
  border: 1px solid #fbbf24;
  border-radius: 8px;
  padding: 1rem;
  margin-bottom: 1.5rem;
  display: flex;
  gap: 0.75rem;
  align-items: flex-start;
}

.status-icon {
  font-size: 1.5rem;
}

.status-banner p {
  margin: 0;
  color: #92400e;
}

.status-banner p + p {
  margin-top: 0.4rem;
}

.future-features,
.quick-info {
  margin-bottom: 1.5rem;
}

.future-features h3,
.quick-info h3 {
  font-size: 1rem;
  color: var(--color-text, #16213e);
  margin: 0 0 0.75rem;
}

.future-features ul,
.quick-info ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

.future-features li,
.quick-info li {
  padding: 0.4rem 0;
  color: var(--color-text, #1a1a2e);
  font-size: 0.9rem;
  border-bottom: 1px solid var(--color-border, #e2e8f0);
}

.future-features li:last-child,
.quick-info li:last-child {
  border-bottom: none;
}

.debug-info {
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid var(--color-border, #e2e8f0);
}

.debug-info details {
  color: var(--color-text-secondary, #666);
  font-size: 0.85rem;
}

.debug-info table {
  width: 100%;
  margin-top: 0.5rem;
  border-collapse: collapse;
}

.debug-info th,
.debug-info td {
  padding: 0.3rem 0.5rem;
  text-align: left;
  border-bottom: 1px solid var(--color-border, #e2e8f0);
  font-size: 0.8rem;
}

.debug-info th {
  color: var(--color-text-secondary, #64748b);
  width: 160px;
}

.mono {
  font-family: ui-monospace, 'Cascadia Code', 'Consolas', monospace;
  font-size: 0.8rem;
}
</style>
