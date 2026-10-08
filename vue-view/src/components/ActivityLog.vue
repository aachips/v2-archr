<!--
  ActivityLog — Activity Log / Audit Trail viewer.
  Mirrors app/audit-log.php + partials/audit-log-body.php.

  Features:
  - Filter panel (user, category, action, source, dates, search)
  - Data table with expandable details
  - Chain verification banner
  - Pagination (limit/offset)
-->
<template>
  <div class="activity-log">
    <h2 class="activity-log__title">
      <i class="fas fa-clock-rotate-left"></i> Activity Log
      <button type="button" class="btn btn--sm btn--refresh" @click="load" :disabled="loading" title="Refresh">
        <i :class="loading ? 'fas fa-spinner fa-spin' : 'fas fa-arrows-rotate'"></i>
      </button>
    </h2>

    <!-- Chain verification banner -->
    <div v-if="chainStatus" :class="['chain-banner', chainStatus.ok ? 'chain-banner--ok' : 'chain-banner--error']">
      <i :class="chainStatus.ok ? 'fas fa-circle-info' : 'fas fa-triangle-exclamation'"></i>
      <span v-if="chainStatus.ok">Chain integrity verified — {{ chainStatus.checked }} entries checked.</span>
      <span v-else>Chain broken at entry #{{ chainStatus.first_bad_id }} — {{ chainStatus.error }}</span>
    </div>

    <!-- Filters -->
    <div class="activity-log__filters">
      <div class="filter-row">
        <label>
          User
          <select v-model="filters.userId" @change="applyFilters">
            <option :value="null">All users</option>
            <option v-for="u in meta.users" :key="u.id" :value="u.id">{{ u.full_name }}</option>
          </select>
        </label>
        <label>
          Category
          <select v-model="filters.category" @change="applyFilters">
            <option :value="null">All categories</option>
            <option v-for="c in meta.categories" :key="c" :value="c">{{ c }}</option>
          </select>
        </label>
        <label>
          Action
          <select v-model="filters.action" @change="applyFilters">
            <option :value="null">All actions</option>
            <option v-for="a in meta.actions" :key="a" :value="a">{{ a }}</option>
          </select>
        </label>
        <label>
          Source
          <select v-model="filters.source" @change="applyFilters">
            <option :value="null">All sources</option>
            <option v-for="s in meta.sources" :key="s" :value="s">{{ s }}</option>
          </select>
        </label>
      </div>
      <div class="filter-row">
        <label>
          Application ID
          <input type="number" v-model.number="filters.applicationId" @change="applyFilters" placeholder="Any" />
        </label>
        <label>
          Case ID
          <input type="number" v-model.number="filters.caseId" @change="applyFilters" placeholder="Any" />
        </label>
        <label>
          Since
          <input type="date" v-model="filters.since" @change="applyFilters" />
        </label>
        <label>
          Until
          <input type="date" v-model="filters.until" @change="applyFilters" />
        </label>
        <label class="filter-search">
          <i class="fas fa-magnifying-glass"></i>
          <input type="search" v-model.trim="filters.search" placeholder="Search summary…"
                 @input="debounceSearch" />
        </label>
        <button type="button" class="btn btn--secondary" @click="resetFilters">Reset</button>
      </div>
    </div>

    <!-- Loading / Error -->
    <p v-if="loading" class="activity-log__loading">
      <i class="fas fa-spinner fa-spin"></i> Loading activity log…
    </p>
    <p v-else-if="error" class="activity-log__error">
      {{ error }}
      <button type="button" class="btn btn--secondary btn--sm" @click="load">Retry</button>
    </p>

    <!-- Data table -->
    <table v-else-if="entries.length" class="activity-table">
      <thead>
        <tr>
          <th>When</th>
          <th>Who</th>
          <th>What</th>
          <th>Household</th>
          <th>Source</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        <template v-for="(entry, idx) in entries">
          <tr :key="entry.id">
            <td class="col-when">{{ formatDate(entry.created_at) }}</td>
            <td class="col-who">
              {{ entry.user_name }}
              <span v-if="entry.ip_address" class="muted" :title="'IP: ' + entry.ip_address">
                <i class="fas fa-network-wired"></i>
              </span>
            </td>
            <td class="col-what">
              <span :class="['cat-pill', 'cat-pill--' + entry.category]">{{ entry.category }}</span>
              <strong>{{ entry.action }}</strong>
              <span class="muted">{{ entry.summary }}</span>
            </td>
            <td class="col-household">{{ entry.household_label || '—' }}</td>
            <td class="col-source">{{ entry.source }}</td>
            <td class="col-expand">
              <button type="button" class="btn-expand" @click="toggleDetail(idx)"
                      :aria-expanded="expandedIdx === idx">
                <i :class="expandedIdx === idx ? 'fas fa-chevron-up' : 'fas fa-chevron-down'"></i>
              </button>
            </td>
          </tr>
          <tr v-if="expandedIdx === idx" :key="'detail-' + entry.id" class="detail-row">
            <td colspan="6">
              <div class="detail-panel">
                <!-- Field-level changes (from activity_detail) -->
                <div v-if="entry.detail_rows && entry.detail_rows.length" class="detail-changes">
                  <h4 class="detail-changes__title">Changes</h4>
                  <div v-for="(d, di) in entry.detail_rows" :key="di" class="detail-change">
                    <strong>{{ d.field_name }}</strong>
                    <span class="detail-change__old">{{ d.old_value || '(empty)' }}</span>
                    <span class="detail-change__arrow">→</span>
                    <span class="detail-change__new">{{ d.new_value || '(empty)' }}</span>
                  </div>
                </div>

                <dl class="detail-grid">
                  <div><dt>ID</dt><dd><code>{{ entry.id }}</code></dd></div>
                  <div><dt>Application</dt><dd>{{ entry.application_id || '—' }}</dd></div>
                  <div><dt>Case ID</dt><dd>{{ entry.case_id || '—' }}</dd></div>
                  <div><dt>Category</dt><dd>{{ entry.category }}</dd></div>
                  <div><dt>Action</dt><dd>{{ entry.action }}</dd></div>
                  <div><dt>Source</dt><dd>{{ entry.source || '—' }}</dd></div>
                </dl>
                <details v-if="entry.details && Object.keys(entry.details).length">
                  <summary>Full Details (JSON)</summary>
                  <pre class="json-block">{{ JSON.stringify(entry.details, null, 2) }}</pre>
                </details>
              </div>
            </td>
          </tr>
        </template>
      </tbody>
    </table>

    <p v-else class="activity-log__empty">No activity log entries match the current filters.</p>

    <!-- Pagination -->
    <div v-if="entries.length >= filters.limit" class="activity-log__pagination">
      <button type="button" class="btn btn--secondary" :disabled="filters.offset === 0"
              @click="loadMore(-filters.limit)">
        &larr; Newer
      </button>
      <span class="pagination-info">Showing {{ filters.offset + 1 }}–{{ filters.offset + entries.length }}</span>
      <button type="button" class="btn btn--secondary" @click="loadMore(filters.limit)">
        Older &rarr;
      </button>
    </div>
  </div>
</template>

<script>
import { fetchActivityLog, verifyChain } from "../services/activityLogService";

export default {
  name: "ActivityLog",
  data() {
    return {
      entries: [],
      meta: { categories: [], actions: [], sources: [], users: [] },
      loading: false,
      error: "",
      expandedIdx: null,
      chainStatus: null,
      filters: {
        userId: null,
        applicationId: null,
        caseId: null,
        category: null,
        action: null,
        source: null,
        since: "",
        until: "",
        search: "",
        limit: 100,
        offset: 0,
      },
      searchTimer: null,
    };
  },
  created() {
    this.load();
    this.verifyChainIntegrity();
  },
  methods: {
    load() {
      this.loading = true;
      this.error = "";
      fetchActivityLog(this.filters)
        .then(({ entries, meta }) => {
          this.entries = entries;
          this.meta = meta;
          this.loading = false;
        })
        .catch(err => {
          this.error = "Couldn't load activity log: " + (err.message || String(err));
          this.loading = false;
        });
    },
    loadMore(delta) {
      this.filters.offset = Math.max(0, this.filters.offset + delta);
      this.expandedIdx = null;
      this.load();
    },
    applyFilters() {
      this.filters.offset = 0;
      this.expandedIdx = null;
      this.load();
    },
    debounceSearch() {
      clearTimeout(this.searchTimer);
      this.searchTimer = setTimeout(() => this.applyFilters(), 300);
    },
    resetFilters() {
      this.filters = {
        userId: null, applicationId: null, caseId: null,
        category: null, action: null, source: null,
        since: "", until: "", search: "", limit: 100, offset: 0,
      };
      this.expandedIdx = null;
      this.load();
    },
    toggleDetail(idx) {
      this.expandedIdx = this.expandedIdx === idx ? null : idx;
    },
    verifyChainIntegrity() {
      verifyChain()
        .then(result => { this.chainStatus = result; })
        .catch(() => { this.chainStatus = null; });
    },
    formatDate(ts) {
      if (!ts) return "—";
      const d = new Date(ts);
      return d.toLocaleDateString() + " " + d.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
    },
  },
};
</script>

<style scoped>
.activity-log { padding: 1rem; }
.activity-log__title { font-size: 1.25rem; margin: 0 0 1rem; display: flex; align-items: center; gap: 0.5rem; }
.activity-log__title i { color: var(--color-primary, #1c7a5c); }

.activity-log__filters { background: #f8f8f8; padding: 0.75rem; border-radius: 4px; margin-bottom: 1rem; }
.filter-row { display: flex; gap: 0.75rem; flex-wrap: wrap; align-items: flex-end; margin-bottom: 0.5rem; }
.filter-row:last-child { margin-bottom: 0; }
.filter-row label { display: flex; flex-direction: column; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.04em; color: #666; }
.filter-row select, .filter-row input[type="date"] { padding: 0.3rem 0.5rem; border: 1px solid #ccc; border-radius: 3px; font-size: 0.85rem; }
.filter-search { position: relative; flex: 1; min-width: 200px; }
.filter-search i { position: absolute; left: 0.5rem; top: 50%; transform: translateY(-50%); color: #999; font-size: 0.8rem; }
.filter-search input { padding-left: 1.75rem; width: 100%; box-sizing: border-box; padding: 0.3rem 0.5rem 0.3rem 1.75rem; border: 1px solid #ccc; border-radius: 3px; font-size: 0.85rem; }

.activity-log__loading, .activity-log__error, .activity-log__empty { text-align: center; padding: 2rem; color: #666; }
.activity-log__error { color: #c62828; }

.activity-table { width: 100%; border-collapse: collapse; font-size: 0.85rem; }
.activity-table thead th { text-align: left; font-size: 0.7rem; text-transform: uppercase; letter-spacing: 0.05em; color: #888; font-weight: 600; padding: 0.5rem; border-bottom: 2px solid #ddd; }
.activity-table tbody td { padding: 0.5rem; border-bottom: 1px solid #eee; vertical-align: top; }
.activity-table tbody tr:hover { background: #f8f8f8; }

.cat-pill { display: inline-block; padding: 0.1rem 0.4rem; border-radius: 3px; font-size: 0.7rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.04em; margin-right: 0.3rem; }
.cat-pill--client { background: #e3f2fd; color: #1565c0; }
.cat-pill--application { background: #e8f5e9; color: #2e7d32; }
.cat-pill--case { background: #fff3e0; color: #e65100; }
.cat-pill--project { background: #f3e5f5; color: #7b1fa2; }
.cat-pill--task { background: #e0f7fa; color: #00838f; }
.cat-pill--document { background: #fce4ec; color: #c62828; }
.cat-pill--communication { background: #fff8e1; color: #f57f17; }
.cat-pill--user { background: #ede7f6; color: #4527a0; }
.cat-pill--system { background: #f5f5f5; color: #616161; }

.col-when { white-space: nowrap; width: 120px; }
.col-who { width: 120px; }
.col-source { width: 60px; }
.col-expand { width: 30px; }
.btn-expand { background: none; border: none; cursor: pointer; padding: 0.25rem; color: #999; }
.btn-expand:hover { color: #333; }
.muted { color: #999; font-size: 0.8rem; }

.detail-row td { background: #fafafa; padding: 0.75rem 1rem; }
.detail-panel { font-size: 0.8rem; }
.detail-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 0.5rem 1.5rem; margin-bottom: 0.75rem; }
.detail-grid dt { font-weight: 600; color: #666; font-size: 0.7rem; text-transform: uppercase; }
.detail-grid dd { margin: 0; font-family: monospace; font-size: 0.8rem; }
.json-block { background: #f5f5f5; padding: 0.75rem; border-radius: 4px; overflow-x: auto; font-size: 0.75rem; max-height: 300px; overflow-y: auto; }

.detail-changes { margin-bottom: 0.75rem; }
.detail-changes__title { font-size: 0.8rem; font-weight: 600; color: #333; margin: 0 0 0.4rem; }
.detail-change { display: flex; align-items: center; gap: 0.4rem; padding: 0.25rem 0.5rem; background: #fff; border: 1px solid #e0e0e0; border-radius: 4px; margin-bottom: 0.25rem; font-size: 0.8rem; font-family: monospace; }
.detail-change__old { color: #c62828; text-decoration: line-through; }
.detail-change__arrow { color: #999; }
.detail-change__new { color: #2e7d32; font-weight: 600; }

.activity-log__pagination { display: flex; justify-content: center; align-items: center; gap: 1rem; padding: 1rem 0; }
.pagination-info { font-size: 0.8rem; color: #666; }

.btn { padding: 0.4rem 0.75rem; border: 1px solid #ccc; border-radius: 3px; background: #fff; cursor: pointer; font-size: 0.8rem; }
.btn--secondary { background: #f5f5f5; }
.btn--sm { padding: 0.2rem 0.5rem; font-size: 0.75rem; }
.btn:disabled { opacity: 0.5; cursor: default; }
.btn--refresh { background: none; border: none; padding: 0.2rem; font-size: 0.85rem; color: #666; cursor: pointer; }
.btn--refresh:hover { color: #333; }
</style>
