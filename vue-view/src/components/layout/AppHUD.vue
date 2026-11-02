<!--
  AppHUD — a lightweight, abridged context bar at the top of the content area.
  Shows a welcome message or page-specific context. Will grow in complexity
  over time (notifications, quick actions, status indicators).
-->
<template>
  <div class="hud" :class="`hud--${contextClass}`">
    <span class="hud__icon">{{ icon }}</span>
    <span class="hud__text">
      <strong>{{ title }}</strong>
      <span v-if="subtitle" class="hud__subtitle">{{ subtitle }}</span>
    </span>
  </div>
</template>

<script>
const VIEW_CONTEXT = {
  'whoami':          { icon: '🔍', title: 'Who Am I?', subtitle: 'Your identity, role, and capabilities' },
  'welcome':         { icon: '👋', title: 'Welcome', subtitle: 'Your ARCHR dashboard' },
  'profile':         { icon: '⚙️', title: 'Profile Settings', subtitle: 'Manage your account preferences' },
  'search':          { icon: '🔎', title: 'Case Search', subtitle: 'Search and filter all cases' },
  'marketplace':     { icon: '🏪', title: 'Marketplace', subtitle: 'Browse and claim available work' },
  'tasks':           { icon: '⚡', title: 'Quick Tasks & Events', subtitle: 'Your action items' },
  'documents':       { icon: '📁', title: 'Documents Bucket', subtitle: 'Manage case documents' },
  'activity':        { icon: '📋', title: 'Activity Log', subtitle: 'Recent system activity' },
  'assessor':        { icon: '📋', title: "Today's Assessments", subtitle: 'Your scheduled home visits' },
  'requestor':       { icon: '🏠', title: 'My Application', subtitle: 'Track your repair assistance request' },
  'superadmin-orgs': { icon: '🏢', title: 'My Organizations', subtitle: 'Manage coalition organizations' },
  'superadmin-users':{ icon: '👥', title: 'User Directory', subtitle: 'Manage platform users' },
};

export default {
  name: 'AppHUD',
  props: {
    view: { type: String, default: 'search' },
    userName: { type: String, default: 'User' },
    role: { type: String, default: '' },
  },
  computed: {
    context() {
      return VIEW_CONTEXT[this.view] || { icon: '📄', title: 'ARCHR', subtitle: '' };
    },
    icon() {
      return this.context.icon;
    },
    title() {
      // Show welcome message on whoami/welcome views
      if (this.view === 'welcome') {
        return `Welcome back, ${this.userName}`;
      }
      if (this.view === 'whoami') {
        return `Hello, ${this.userName} — you are logged in as ${this.role ? this.role.replace(/_/g, ' ') : 'a user'}`;
      }
      return this.context.title;
    },
    subtitle() {
      return this.context.subtitle;
    },
    contextClass() {
      return this.view || 'default';
    },
  },
};
</script>

<style scoped>
.hud {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  padding: 0.6rem 1rem;
  background: linear-gradient(135deg, #f0f4ff 0%, #e8f0fe 100%);
  border: 1px solid #c7d2fe;
  border-radius: 8px;
  margin-bottom: 1rem;
  font-size: 0.85rem;
  color: #3730a3;
}

.hud__icon {
  font-size: 1.2rem;
  line-height: 1;
  flex-shrink: 0;
}

.hud__text {
  display: flex;
  flex-direction: column;
  gap: 0.1rem;
}

.hud__text strong {
  font-size: 0.9rem;
  color: #1e293b;
}

.hud__subtitle {
  font-size: 0.8rem;
  color: #64748b;
}
</style>
