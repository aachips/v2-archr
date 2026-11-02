<template>
  <div class="applications-list">
    <h2>My Applications</h2>
    <p class="subtitle">
      <span v-if="applications.length === 1">1 application</span>
      <span v-else>{{ applications.length }} applications</span>
      <span v-if="referralCount > 0"> — {{ referralCount }} referred</span>
    </p>

    <div v-if="loading" class="loading-text">Loading your applications…</div>

    <div v-else-if="!applications.length" class="empty-state">
      <p>We don't have any applications on file for this account yet.</p>
    </div>

    <div v-else class="app-list">
      <article
        v-for="app in applications"
        :key="app.id"
        :class="['app-card', app.is_referral ? 'app-card--referral' : '', activeApp === app.id ? 'app-card--active' : '']"
        @click="selectApp(app)"
      >
        <div class="app-card__header">
          <span :class="['app-badge', app.is_referral ? 'app-badge--referral' : 'app-badge--own']">
            <i :class="app.is_referral ? 'fas fa-share-from-square' : 'fas fa-house'"></i>
            {{ app.is_referral ? 'Referred' : 'My Home' }}
          </span>
          <span :class="['pill', statusPill(app.status)]">{{ statusLabel(app.status) }}</span>
        </div>
        <h3 class="app-card__name">{{ app.first_name }} {{ app.last_name }}</h3>
        <p class="app-card__address">{{ app.address || '—' }}<br>{{ app.city }}{{ app.city ? ', ' : '' }}{{ app.state }} {{ app.zip }}</p>
        <div class="app-card__meta">
          <span><i class="fas fa-hashtag"></i> {{ app.case_number || '#' + app.id }}</span>
          <span><i class="far fa-clock"></i> {{ formatDate(app.submitted_at) }}</span>
        </div>
      </article>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ApplicationsListView',
  props: {
    applications: { type: Array, default: () => [] },
    loading: Boolean,
    activeApp: Number,
  },
  computed: {
    referralCount() {
      return this.applications.filter(a => a.is_referral).length;
    },
  },
  methods: {
    selectApp(app) {
      this.$emit('select', app);
    },
    statusLabel(s) {
      return (s || 'pending').replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase());
    },
    statusPill(s) {
      return { open: 'pill-green', pending: 'pill-amber', intake_review: 'pill-blue', pending_review: 'pill-amber' }[s] || 'pill-gray';
    },
    formatDate(d) {
      if (!d) return '—';
      return new Date(d).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
    },
  },
};
</script>

<style scoped>
.applications-list { max-width: 900px; margin: 0 auto; padding: 1.5rem; }
h2 { font-size: 1.4rem; margin: 0 0 0.25rem; }
.subtitle { color: #64748b; margin: 0 0 1.5rem; font-size: 0.9rem; }
.loading-text { text-align: center; color: #94a3b8; padding: 3rem; }
.empty-state { text-align: center; padding: 3rem; color: #94a3b8; }

.app-list { display: flex; flex-direction: column; gap: 0.75rem; }
.app-card {
  background: var(--color-surface, #fff);
  border: 1px solid var(--color-border, #e2e8f0);
  border-radius: 10px;
  padding: 1rem;
  cursor: pointer;
  transition: border-color 0.15s, box-shadow 0.15s;
}
.app-card:hover { border-color: #93c5fd; box-shadow: 0 2px 8px rgba(59,130,246,0.1); }
.app-card--active { border-color: #2563eb; box-shadow: 0 2px 12px rgba(37,99,235,0.15); }
.app-card--referral { border-left: 3px solid #8b5cf6; }

.app-card__header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.5rem; }
.app-badge { font-size: 0.75rem; font-weight: 600; padding: 0.15rem 0.5rem; border-radius: 999px; display: inline-flex; align-items: center; gap: 0.3rem; }
.app-badge--own { background: #dbeafe; color: #1e40af; }
.app-badge--referral { background: #ede9fe; color: #6d28d9; }

.app-card__name { font-size: 1.05rem; margin: 0 0 0.25rem; color: #1e293b; }
.app-card__address { font-size: 0.85rem; color: #64748b; margin: 0 0 0.5rem; line-height: 1.4; }
.app-card__meta { display: flex; gap: 1rem; font-size: 0.8rem; color: #94a3b8; }
.app-card__meta i { margin-right: 0.25rem; }

.pill { display: inline-block; padding: 0.15rem 0.5rem; border-radius: 999px; font-size: 0.75rem; font-weight: 600; }
.pill-green { background: #dcfce7; color: #166534; }
.pill-amber { background: #fef3c7; color: #92400e; }
.pill-blue { background: #dbeafe; color: #1e40af; }
.pill-gray { background: #f1f5f9; color: #475569; }
</style>
