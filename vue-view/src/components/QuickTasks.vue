<!--
  QuickTasks — Task Engine (Vue port of app/tle-poc.php)
  -------------------------------------------------------
  Two-phase task capture:
    Phase 1 — Quick Entry: type one or more lines, hit submit → Unverified queue
    Phase 2 — Task Rabbit: review, parse, categorize, verify

  Also shows the verified entries table and the case event log.
  Writes go to the `progress_events` table in the dummy base (append-only).
-->
<template>
  <section class="tasks">
    <!-- ============ QUICK ENTRY ============ -->
    <section class="quick-entry">
      <div class="quick-entry__head">
        <h2><svg class="qe-icon" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M13 2L3 14h8l-1 8 10-12h-8l1-8z"/></svg> Quick Entry</h2>
        <span class="quick-entry__stamp" id="stampWhen">Auto-stamped on submit</span>
      </div>

      <form class="quick-entry__form" @submit.prevent="onSubmit">
        <textarea
          v-model="rawText"
          class="quick-entry__textarea"
          placeholder="Type one or more entries. Each new line is a separate entry.&#10;&#10;e.g.&#10;42-CHERRY roof needs tarping before storm&#10;Called Mrs. Lopez at 2:10pm — confirmed Thursday assessment&#10;Photos uploaded to 15-MERRILL"
          aria-label="What needs to be done, what happened, or what was said?"
        ></textarea>

        <div class="quick-entry__helper">
          <span><svg class="info-icon" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/></svg> Each new line becomes its own entry. A Task Rabbit will parse, categorize, and verify before it counts toward metrics.</span>
        </div>

        <!-- Advanced fields (hidden by default) -->
        <div class="quick-entry__advanced">
          <button type="button" class="adv-toggle" @click="showAdvanced = !showAdvanced">
            <svg :class="['chevron', { open: showAdvanced }]" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M8.59 16.59L13.17 12 8.59 7.41 10 6l6 6-6 6z"/></svg>
            Add structure now (skip if you're in a hurry)
          </button>

          <div v-show="showAdvanced" class="adv-fields">
            <label class="adv-field">
              Case
              <input v-model="adv.case" type="text" placeholder="Placecode or case #" />
            </label>
            <label class="adv-field">
              Type
              <select v-model="adv.type">
                <option value="">Let Rabbit decide</option>
                <option value="progress_task">Task</option>
                <option value="comm_logged">Communication</option>
                <option value="assessment_event">Event</option>
                <option value="note">Note</option>
              </select>
            </label>
            <label class="adv-field">
              Priority
              <select v-model="adv.priority">
                <option value="">Default</option>
                <option value="p0">P0 · Urgent</option>
                <option value="p1">P1 · High</option>
                <option value="p2">P2 · Normal</option>
                <option value="p3">P3 · Low</option>
              </select>
            </label>
          </div>
        </div>

        <div class="quick-entry__actions">
          <button type="button" class="btn btn-clear" @click="clearForm">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M3 6h18M8 6V4h8v2m-7 5v6m4-6v6M5 6l1 14h12l1-14"/></svg>
            Clear
          </button>
          <button type="submit" class="btn btn-primary" :disabled="saving || !rawText.trim()">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M22 2L11 13M22 2l-7 20-4-9-9-4z"/></svg>
            Submit to Unverified
          </button>
        </div>
      </form>
    </section>

    <!-- ============ TABS ============ -->
    <div class="tle-tabs" role="tablist">
      <button
        v-for="tab in tabs"
        :key="tab.key"
        type="button"
        :class="['tle-tab', { active: activeTab === tab.key }]"
        @click="activeTab = tab.key"
      >
        <span v-html="tab.icon"></span>
        {{ tab.label }}
        <span v-if="tab.count" class="tab-count">{{ tab.count }}</span>
      </button>
    </div>

    <!-- ============ UNVERIFIED QUEUE ============ -->
    <section v-show="activeTab === 'unverified'" class="tle-view is-active">
      <div class="review-banner">
        <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/></svg>
        <span><strong>Task Rabbit role:</strong> A second pair of eyes parses each raw entry, decides whether it's a task, event, communication, or several of those together, fills missing fields, then verifies.</span>
      </div>

      <ul v-if="unverified.length" class="unverified-list">
        <li v-for="entry in unverified" :key="entry.id" class="unverified-card">
          <div class="unverified-card__head">
            <span class="submitter">
              <span class="avatar">{{ initials(entry.submittedBy) }}</span>
              {{ entry.submittedBy }}
            </span>
            <span class="stamp">
              <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M12 2C6.5 2 2 6.5 2 12s4.5 10 10 10 10-4.5 10-10S17.5 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm.5-13H11v6l5.2 3.2.8-1.3-4.5-2.7V7z"/></svg>
              {{ formatDate(entry.submittedAt) }}
            </span>
            <span class="raw-tag">Unverified</span>
          </div>
          <div class="unverified-card__body">{{ entry.rawText }}</div>
          <div class="unverified-card__foot">
            <div class="quick-verify-row">
              <button
                v-for="t in ['progress_task', 'comm_logged', 'assessment_event']"
                :key="t"
                type="button"
                :class="['qv-chip', { on: entry.suggestedTypes && entry.suggestedTypes.includes(t) }]"
                @click="toggleSuggested(entry, t)"
              >
                {{ typeShortLabel(t) }}
              </button>
            </div>
            <div class="verify-actions">
              <button type="button" class="btn btn-sm btn-secondary" @click="triageEntry(entry)">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14,2 14,8 20,8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
                Triage &amp; Parse
              </button>
              <button type="button" class="btn btn-sm btn-primary" @click="verifyEntry(entry)">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22,4 12,14.01 9,11.01"/></svg>
                Verify
              </button>
            </div>
          </div>
        </li>
      </ul>
      <p v-else class="tle-empty">No unverified entries.</p>
    </section>

    <!-- ============ TRIAGE MODAL ============ -->
    <div v-if="triageOpen && triageRaw" class="modal__backdrop" @click.self="closeTriage">
      <div class="modal" role="dialog" aria-label="Triage &amp; Parse entry">
        <div class="modal__head">
          <h2>Triage &amp; Parse</h2>
          <button type="button" class="modal__close" @click="closeTriage">&times;</button>
        </div>

        <div class="modal__raw">
          <span class="modal__raw-label">Raw entry</span>
          <p class="modal__raw-text">{{ triageRaw.rawText }}</p>
        </div>

        <form @submit.prevent="saveTriage">
          <!-- Split into multiple entries -->
          <div class="triage-lines">
            <label v-for="(line, idx) in triageLines" :key="idx" class="triage-line">
              <span class="triage-line-label">Line {{ idx + 1 }}</span>
              <textarea
                v-model="triageLines[idx].text"
                rows="2"
                :placeholder="idx === 0 ? 'Description...' : 'Split into separate entry...'"
              ></textarea>
              <button
                v-if="triageLines.length > 1"
                type="button"
                class="triage-remove"
                @click="removeTriageLine(idx)"
                title="Remove this line"
              >&times;</button>
            </label>
            <button type="button" class="triage-add-line" @click="addTriageLine">
              + Split into another entry
            </button>
          </div>

          <div class="triage-fields">
            <label class="triage-field">
              Case / Placecode
              <input
                v-model.trim="triageCase"
                type="text"
                placeholder="e.g. 305OLDHA or case #"
                list="caseSuggestions"
              />
              <datalist id="caseSuggestions">
                <option v-for="c in cases" :key="c.id" :value="derivePlacecode(c) || c.caseNumber">
                  {{ c.applicantName || '' }}
                </option>
              </datalist>
            </label>

            <label class="triage-field">
              Type
              <select v-model="triageType">
                <option value="">— Select —</option>
                <option value="progress_task">Task</option>
                <option value="comm_logged">Communication</option>
                <option value="assessment_event">Assessment Event</option>
                <option value="note">Note</option>
              </select>
            </label>

            <label class="triage-field">
              Priority
              <select v-model="triagePriority">
                <option value="">Default</option>
                <option value="p0">P0 · Urgent</option>
                <option value="p1">P1 · High</option>
                <option value="p2">P2 · Normal</option>
                <option value="p3">P3 · Low</option>
              </select>
            </label>
          </div>

          <div class="modal__actions">
            <button type="button" class="btn btn-clear" @click="closeTriage">Cancel</button>
            <button type="submit" class="btn btn-primary" :disabled="saving || !triageType">
              Verify &amp; Save
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- ============ ALL VERIFIED ============ -->
    <section v-show="activeTab === 'verified'" class="tle-view">
      <div v-if="verified.length" class="table-wrap">
        <table class="verified-table">
          <thead>
            <tr>
              <th>Case</th>
              <th>Type</th>
              <th>Entry</th>
              <th>Submitted</th>
              <th>Verified by</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="e in verified" :key="e.id">
              <td><span class="case-tag">{{ e.caseRef || '—' }}</span></td>
              <td><span :class="['type-pill', 'is-' + typeClass(e.type)]">{{ typeLabel(e.type) }}</span></td>
              <td>{{ e.description }}</td>
              <td>{{ e.submittedBy }} · {{ formatDate(e.submittedAt) }}</td>
              <td>{{ e.verifiedBy || '—' }}</td>
              <td><span :class="['status-pill', 'is-' + statusClass(e.status)]">{{ e.status }}</span></td>
            </tr>
          </tbody>
        </table>
      </div>
      <p v-else class="tle-empty">No verified entries yet.</p>
    </section>

    <!-- ============ CASE EVENT LOG ============ -->
    <section v-show="activeTab === 'log'" class="tle-view">
      <div class="case-picker-bar">
        <label>
          Case
          <select v-model="selectedCaseId">
            <option value="" disabled>Choose a case…</option>
            <option v-for="c in cases" :key="c.id" :value="c.id">
              {{ derivePlacecode(c) || c.caseNumber }} — {{ c.applicantName || 'Unknown' }}
            </option>
          </select>
        </label>
      </div>

      <p v-if="eventsLoading" class="tle-empty">Loading events…</p>
      <p v-else-if="!selectedCase" class="tle-empty">Pick a case to see its event log.</p>
      <p v-else-if="events.length === 0" class="tle-empty">
        No events yet for this case.
      </p>
      <ul v-else class="event-log">
        <li v-for="e in events" :key="e.id" class="event-item">
          <span :class="['event-type', 'is-' + typeClass(e.type)]">{{ typeLabel(e.type) }}</span>
          <span class="event-desc">{{ e.description }}</span>
          <span class="event-date">{{ formatDateTime(e.performedAt) }}</span>
        </li>
      </ul>
    </section>
  </section>
</template>

<script>
import { fetchCaseEvents } from '../services/caseService';

const TYPE_LABELS = {
  comm_logged: 'Communication',
  assessment_event: 'Assessment Event',
  progress_task: 'Task',
  note: 'Note',
};

const TYPE_SHORT = {
  comm_logged: 'Comm',
  assessment_event: 'Event',
  progress_task: 'Task',
  note: 'Note',
};

const ICON_SVG = {
  unverified: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>',
  verified: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2"/><rect x="9" y="3" width="6" height="4" rx="1"/></svg>',
  log: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14,2 14,8 20,8"/></svg>',
};

const UNVERIFIED_KEY = 'archr:unverified';
const VERIFIED_KEY = 'archr:verified';

export default {
  name: 'QuickTasks',
  props: {
    cases: { type: Array, default: () => [] },
  },
  data() {
    return {
      // Quick Entry
      rawText: '',
      showAdvanced: false,
      adv: { case: '', type: '', priority: '' },
      saving: false,

      // Tabs
      activeTab: 'unverified',
      tabs: [
        { key: 'unverified', label: 'Unverified', icon: ICON_SVG.unverified, count: 0 },
        { key: 'verified',   label: 'All Verified', icon: ICON_SVG.verified, count: 0 },
        { key: 'log',        label: 'Case Event Log', icon: ICON_SVG.log },
      ],

      // Data (stored in localStorage for POC; move to DB when ready)
      unverified: [],
      verified: [],

      // Triage modal
      triageOpen: false,
      triageRaw: null,
      triageLines: [],
      triageCase: '',
      triageType: '',
      triagePriority: '',

      // Event log
      selectedCaseId: '',
      events: [],
      eventsLoading: false,
    };
  },

  computed: {
    selectedCase() {
      return this.cases.find(c => c.id === this.selectedCaseId) || null;
    },
  },

  watch: {
    selectedCaseId() { this.loadEvents(); },
    unverified: { handler() { this.saveUnverified(); this.updateCounts(); }, deep: true },
    verified:   { handler() { this.saveVerified();   this.updateCounts(); }, deep: true },
  },

  created() {
    this.loadUnverified();
    this.loadVerified();
    this.updateCounts();
  },

  methods: {
    // --- Quick Entry ---
    onSubmit() {
      const text = this.rawText.trim();
      if (!text) return;

      const lines = text.split('\n').map(l => l.trim()).filter(Boolean);
      for (const line of lines) {
        this.unverified.unshift({
          id: 'u-' + Date.now() + '-' + Math.random().toString(36).slice(2, 6),
          rawText: line,
          submittedBy: this.$auth.displayName || 'You',
          submittedAt: new Date().toISOString(),
          caseRef: this.adv.case || null,
          suggestedTypes: this.adv.type ? [this.adv.type] : [],
          priority: this.adv.priority || null,
        });
      }

      this.rawText = '';
      this.adv = { case: '', type: '', priority: '' };
    },

    clearForm() {
      this.rawText = '';
      this.adv = { case: '', type: '', priority: '' };
    },

    // --- Verification ---
    toggleSuggested(entry, type) {
      if (!entry.suggestedTypes) entry.suggestedTypes = [];
      const idx = entry.suggestedTypes.indexOf(type);
      if (idx >= 0) entry.suggestedTypes.splice(idx, 1);
      else entry.suggestedTypes.push(type);
    },

    // --- Triage modal ---
    triageEntry(entry) {
      this.triageRaw = entry;
      this.triageLines = entry.rawText.split('\n').map(text => ({ text: text.trim() })).filter(l => l.text);
      this.triageCase = entry.caseRef || '';
      this.triageType = entry.suggestedTypes && entry.suggestedTypes.length === 1 ? entry.suggestedTypes[0] : '';
      this.triagePriority = entry.priority || '';
      this.triageOpen = true;
    },

    closeTriage() {
      this.triageOpen = false;
      this.triageRaw = null;
      this.triageLines = [];
      this.triageCase = '';
      this.triageType = '';
      this.triagePriority = '';
    },

    addTriageLine() {
      this.triageLines.push({ text: '' });
    },

    removeTriageLine(idx) {
      if (this.triageLines.length > 1) {
        this.triageLines.splice(idx, 1);
      }
    },

    saveTriage() {
      if (!this.triageRaw || !this.triageType) return;

      const lines = this.triageLines
        .map(l => l.text.trim())
        .filter(Boolean);

      for (const line of lines) {
        const verified = {
          id: 'v-' + Date.now() + '-' + Math.random().toString(36).slice(2, 6),
          type: this.triageType,
          description: line,
          submittedBy: this.triageRaw.submittedBy,
          submittedAt: this.triageRaw.submittedAt,
          verifiedBy: this.$auth.displayName || 'You',
          verifiedAt: new Date().toISOString(),
          caseRef: this.triageCase || null,
          status: 'Active',
          priority: this.triagePriority || null,
        };
        this.verified.unshift(verified);
      }

      this.unverified = this.unverified.filter(e => e.id !== this.triageRaw.id);
      this.closeTriage();
    },

    verifyEntry(entry) {
      const types = entry.suggestedTypes && entry.suggestedTypes.length
        ? entry.suggestedTypes
        : ['note'];

      for (const type of types) {
        const verified = {
          id: 'v-' + Date.now() + '-' + Math.random().toString(36).slice(2, 6),
          type,
          description: entry.rawText,
          submittedBy: entry.submittedBy,
          submittedAt: entry.submittedAt,
          verifiedBy: this.$auth.displayName || 'You',
          verifiedAt: new Date().toISOString(),
          caseRef: entry.caseRef || null,
          status: 'Active',
          priority: entry.priority,
        };
        this.verified.unshift(verified);
      }

      this.unverified = this.unverified.filter(e => e.id !== entry.id);
    },

    // --- Persistence (localStorage for POC) ---
    saveUnverified() {
      try { localStorage.setItem(UNVERIFIED_KEY, JSON.stringify(this.unverified)); } catch (_) { /* ignore */ }
    },
    loadUnverified() {
      try {
        const saved = JSON.parse(localStorage.getItem(UNVERIFIED_KEY));
        if (Array.isArray(saved)) this.unverified = saved;
      } catch (_) { /* ignore */ }
    },
    saveVerified() {
      try { localStorage.setItem(VERIFIED_KEY, JSON.stringify(this.verified)); } catch (_) { /* ignore */ }
    },
    loadVerified() {
      try {
        const saved = JSON.parse(localStorage.getItem(VERIFIED_KEY));
        if (Array.isArray(saved)) this.verified = saved;
      } catch (_) { /* ignore */ }
    },
    updateCounts() {
      const unv = this.tabs.find(t => t.key === 'unverified');
      const ver = this.tabs.find(t => t.key === 'verified');
      if (unv) unv.count = this.unverified.length;
      if (ver) ver.count = this.verified.length;
    },

    // --- Event log ---
    loadEvents() {
      if (!this.selectedCase) { this.events = []; return; }
      this.eventsLoading = true;
      fetchCaseEvents(this.selectedCase)
        .then(events => { this.events = events; })
        .catch(() => { this.events = []; })
        .then(() => { this.eventsLoading = false; });
    },

    // --- Helpers ---
    derivePlacecode(c) {
      if (c.placecode && c.placecode.trim()) return c.placecode;
      const addr = (c.address || '').trim();
      if (!addr) return '';
      const upper = addr.toUpperCase();
      let cleaned = upper.replace(/\b(?:APT|UNIT|SUITE|STE|#)\s*\w+\b/g, '');
      const numMatch = cleaned.match(/^([0-9]+(?:-[0-9]+)?)/);
      const number = numMatch ? numMatch[1] : '';
      let street = cleaned.replace(/^[0-9]+(?:-[0-9]+)?\s*/, '');
      street = street.replace(/\b(?:NORTH|SOUTH|EAST|WEST|NORTHEAST|NORTHWEST|SOUTHEAST|SOUTHWEST|NE|NW|SE|SW|N|S|E|W)\b/g, '');
      street = street.replace(/[^A-Z]/g, '');
      const lettersNeeded = Math.max(0, 8 - number.length);
      return (number + street.substring(0, lettersNeeded)).substring(0, 8) || '';
    },

    typeLabel(type) { return TYPE_LABELS[type] || 'Note'; },
    typeShortLabel(type) { return TYPE_SHORT[type] || 'Note'; },
    typeClass(type) {
      if (type === 'comm_logged') return 'comm';
      if (type === 'assessment_event') return 'event';
      if (type === 'progress_task') return 'task';
      return 'note';
    },
    statusClass(status) {
      if (status === 'Active') return 'active';
      if (status === 'In Progress') return 'progress';
      if (status === 'Closed' || status === 'Complete') return 'done';
      return 'active';
    },
    formatDate(iso) {
      if (!iso) return '';
      return new Date(iso).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
    },
    formatDateTime(iso) {
      if (!iso) return '';
      return new Date(iso).toLocaleString();
    },
    initials(name) {
      if (!name) return '?';
      return name.split(' ').map(w => w[0]).join('').toUpperCase().slice(0, 2);
    },
  },
};
</script>

<style scoped>
.tasks {
  max-width: 900px;
}

/* ---- Quick Entry ---- */
.quick-entry {
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 1.25rem;
  margin-bottom: 1.5rem;
  box-shadow: 0 1px 3px rgba(0,0,0,0.04);
}

.quick-entry__head {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
}

.quick-entry__head h2 {
  font-size: 1.1rem;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 0.4rem;
}

.qe-icon {
  width: 20px;
  height: 20px;
  color: #f59e0b;
}

.quick-entry__stamp {
  margin-left: auto;
  font-size: 0.8rem;
  color: #9ca3af;
}

.quick-entry__textarea {
  width: 100%;
  min-height: 8rem;
  padding: 0.65rem 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font: inherit;
  font-size: 0.9rem;
  resize: vertical;
  line-height: 1.5;
}

.quick-entry__textarea:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.15);
}

.quick-entry__helper {
  display: flex;
  align-items: center;
  gap: 0.35rem;
  font-size: 0.8rem;
  color: #6b7280;
  margin-top: 0.4rem;
}

.info-icon {
  width: 14px;
  height: 14px;
  color: #9ca3af;
  flex-shrink: 0;
}

/* Advanced toggle */
.quick-entry__advanced { margin-top: 0.75rem; }

.adv-toggle {
  display: flex;
  align-items: center;
  gap: 0.35rem;
  background: none;
  border: none;
  color: #3b82f6;
  font-size: 0.85rem;
  cursor: pointer;
  padding: 0.25rem 0;
}

.chevron {
  width: 16px;
  height: 16px;
  transition: transform 0.15s;
}

.chevron.open { transform: rotate(90deg); }

.adv-fields {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
  margin-top: 0.5rem;
}

.adv-field {
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
  font-size: 0.8rem;
  font-weight: 500;
  color: #374151;
}

.adv-field input,
.adv-field select {
  padding: 0.35rem 0.5rem;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  font-size: 0.85rem;
}

/* Actions */
.quick-entry__actions {
  display: flex;
  gap: 0.5rem;
  margin-top: 0.75rem;
}

.btn {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  padding: 0.5rem 1rem;
  border: 1px solid transparent;
  border-radius: 6px;
  font-size: 0.875rem;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.15s, border-color 0.15s;
}

.btn svg { width: 16px; height: 16px; }

.btn-clear {
  background: #fff;
  border-color: #d1d5db;
  color: #374151;
}

.btn-clear:hover { background: #f9fafb; }

.btn-primary {
  background: #1a56db;
  color: #fff;
}

.btn-primary:hover:not(:disabled) { background: #1e40af; }
.btn-primary:disabled { opacity: 0.5; cursor: not-allowed; }

.btn-secondary {
  background: #fff;
  border-color: #d1d5db;
  color: #374151;
}

.btn-secondary:hover { background: #f9fafb; }

.btn-sm {
  padding: 0.3rem 0.6rem;
  font-size: 0.8rem;
}

.btn-sm svg { width: 14px; height: 14px; }

/* ---- Tabs ---- */
.tle-tabs {
  display: flex;
  gap: 0;
  border-bottom: 2px solid #e5e7eb;
  margin-bottom: 1rem;
}

.tle-tab {
  display: flex;
  align-items: center;
  gap: 0.35rem;
  padding: 0.6rem 1rem;
  border: none;
  background: none;
  font: inherit;
  font-size: 0.875rem;
  color: #6b7280;
  cursor: pointer;
  border-bottom: 2px solid transparent;
  margin-bottom: -2px;
}

.tle-tab:hover { color: #374151; }

.tle-tab.active {
  color: #1a56db;
  border-bottom-color: #1a56db;
  font-weight: 600;
}

.tle-tab svg { width: 16px; height: 16px; }

.tab-count {
  background: #e5e7eb;
  color: #374151;
  font-size: 0.75rem;
  font-weight: 600;
  padding: 0.1rem 0.4rem;
  border-radius: 999px;
}

/* ---- Unverified queue ---- */
.review-banner {
  display: flex;
  align-items: flex-start;
  gap: 0.5rem;
  padding: 0.75rem;
  background: #eff6ff;
  border: 1px solid #bfdbfe;
  border-radius: 6px;
  font-size: 0.85rem;
  color: #1e40af;
  margin-bottom: 1rem;
}

.review-banner svg {
  width: 18px;
  height: 18px;
  flex-shrink: 0;
  margin-top: 1px;
}

.unverified-list {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.unverified-card {
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 1rem;
}

.unverified-card__head {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 0.5rem;
}

.avatar {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background: #e0e7ff;
  color: #3730a3;
  font-size: 0.7rem;
  font-weight: 700;
}

.submitter {
  display: flex;
  align-items: center;
  gap: 0.35rem;
  font-weight: 500;
  font-size: 0.875rem;
}

.stamp {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  font-size: 0.8rem;
  color: #6b7280;
}

.stamp svg { width: 14px; height: 14px; }

.raw-tag {
  margin-left: auto;
  padding: 0.15rem 0.5rem;
  border-radius: 999px;
  background: #fef3c7;
  color: #92400e;
  font-size: 0.75rem;
  font-weight: 600;
}

.unverified-card__body {
  font-size: 0.9rem;
  line-height: 1.5;
  color: #1f2937;
  margin-bottom: 0.75rem;
  white-space: pre-wrap;
}

.unverified-card__foot {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.quick-verify-row {
  display: flex;
  gap: 0.35rem;
}

.qv-chip {
  padding: 0.2rem 0.5rem;
  border: 1px solid #d1d5db;
  border-radius: 999px;
  background: #fff;
  font-size: 0.75rem;
  cursor: pointer;
  color: #6b7280;
  transition: all 0.15s;
}

.qv-chip.on {
  background: #dbeafe;
  border-color: #93c5fd;
  color: #1d4ed8;
  font-weight: 600;
}

.verify-actions {
  display: flex;
  gap: 0.5rem;
}

/* ---- Verified table ---- */
.table-wrap {
  overflow-x: auto;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
}

.verified-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.85rem;
}

.verified-table th {
  text-align: left;
  padding: 0.6rem 0.75rem;
  font-weight: 600;
  color: #374151;
  font-size: 0.75rem;
  text-transform: uppercase;
  letter-spacing: 0.025em;
  background: #f3f4f6;
  border-bottom: 2px solid #d1d5db;
  white-space: nowrap;
}

.verified-table td {
  padding: 0.5rem 0.75rem;
  border-bottom: 1px solid #f3f4f6;
  vertical-align: top;
}

.verified-table tbody tr:last-child td { border-bottom: none; }

.case-tag {
  font-family: ui-monospace, monospace;
  font-weight: 600;
  color: #1a56db;
}

.type-pill {
  display: inline-block;
  padding: 0.1rem 0.4rem;
  border-radius: 999px;
  font-size: 0.7rem;
  font-weight: 600;
  white-space: nowrap;
}

.type-pill.is-task { background: #dcfce7; color: #166534; }
.type-pill.is-comm { background: #dbeafe; color: #1d4ed8; }
.type-pill.is-event { background: #fef3c7; color: #92400e; }
.type-pill.is-note { background: #f3f4f6; color: #374151; }

.status-pill {
  display: inline-block;
  padding: 0.1rem 0.4rem;
  border-radius: 999px;
  font-size: 0.7rem;
  font-weight: 600;
}

.status-pill.is-active   { background: #dbeafe; color: #1d4ed8; }
.status-pill.is-progress { background: #fef3c7; color: #92400e; }
.status-pill.is-done     { background: #dcfce7; color: #166534; }

/* ---- Case picker / event log ---- */
.case-picker-bar {
  margin-bottom: 1rem;
}

.case-picker-bar label {
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
  font-size: 0.8rem;
  font-weight: 500;
  color: #374151;
}

.case-picker-bar select {
  padding: 0.4rem 0.6rem;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  min-width: 20rem;
  font-size: 0.875rem;
}

.event-log {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}

.event-item {
  display: flex;
  align-items: baseline;
  gap: 0.75rem;
  padding: 0.55rem 0.75rem;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
}

.event-type {
  flex: 0 0 8rem;
  padding: 0.1rem 0.4rem;
  border-radius: 999px;
  font-size: 0.75rem;
  font-weight: 600;
  text-align: center;
}

.event-type.is-task  { background: #dcfce7; color: #166534; }
.event-type.is-comm  { background: #dbeafe; color: #1d4ed8; }
.event-type.is-event { background: #fef3c7; color: #92400e; }
.event-type.is-note  { background: #f3f4f6; color: #374151; }

.event-desc { flex: 1; }
.event-date { color: #6b7280; font-size: 0.8rem; white-space: nowrap; }

.tle-empty {
  color: #6b7280;
  font-style: italic;
  padding: 1.5rem 0;
  text-align: center;
}

/* ---- Triage Modal ---- */
.modal__backdrop {
  position: fixed;
  inset: 0;
  background: rgba(17, 24, 39, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 100;
}

.modal {
  width: min(42rem, 92vw);
  max-height: 85vh;
  overflow-y: auto;
  padding: 1.5rem;
  border-radius: 10px;
  background: #fff;
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.12);
}

.modal__head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 1rem;
}

.modal__head h2 {
  font-size: 1.15rem;
  margin: 0;
}

.modal__close {
  background: none;
  border: none;
  font-size: 1.5rem;
  color: #6b7280;
  cursor: pointer;
  line-height: 1;
  padding: 0.2rem;
}

.modal__close:hover { color: #1f2937; }

.modal__raw {
  margin-bottom: 1rem;
  padding: 0.75rem;
  background: #fef3c7;
  border: 1px solid #fde68a;
  border-radius: 6px;
}

.modal__raw-label {
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  color: #92400e;
}

.modal__raw-text {
  margin: 0.35rem 0 0;
  font-size: 0.9rem;
  line-height: 1.5;
  color: #1f2937;
  white-space: pre-wrap;
}

/* Triage lines */
.triage-lines { margin-bottom: 1rem; }

.triage-line {
  display: block;
  position: relative;
  margin-bottom: 0.5rem;
}

.triage-line-label {
  display: block;
  font-size: 0.75rem;
  font-weight: 600;
  color: #6b7280;
  margin-bottom: 0.2rem;
}

.triage-line textarea {
  width: 100%;
  padding: 0.4rem 0.5rem;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  font: inherit;
  font-size: 0.85rem;
  resize: vertical;
}

.triage-line textarea:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.12);
}

.triage-remove {
  position: absolute;
  right: 0.35rem;
  top: 1.4rem;
  background: none;
  border: none;
  color: #ef4444;
  font-size: 1.1rem;
  cursor: pointer;
  padding: 0.15rem 0.3rem;
  line-height: 1;
}

.triage-remove:hover { color: #b91c1c; }

.triage-add-line {
  background: none;
  border: 1px dashed #d1d5db;
  border-radius: 4px;
  color: #3b82f6;
  font-size: 0.8rem;
  padding: 0.35rem 0.6rem;
  cursor: pointer;
  width: 100%;
}

.triage-add-line:hover {
  background: #f0f7ff;
  border-color: #93c5fd;
}

/* Triage fields */
.triage-fields {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
  margin-bottom: 1rem;
}

.triage-field {
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
  font-size: 0.8rem;
  font-weight: 500;
  color: #374151;
}

.triage-field input,
.triage-field select {
  padding: 0.35rem 0.5rem;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  font-size: 0.85rem;
}

.triage-field input:focus,
.triage-field select:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.12);
}

.modal__actions {
  display: flex;
  gap: 0.5rem;
  justify-content: flex-end;
}

@media (max-width: 992px) {
  .quick-entry {
    padding: 1rem;
  }

  .adv-fields {
    flex-direction: column;
    gap: 0.5rem;
  }

  .adv-field input,
  .adv-field select {
    width: 100%;
  }

  .quick-entry__actions {
    flex-direction: column;
  }

  .quick-entry__actions .btn {
    width: 100%;
    justify-content: center;
  }

  .tle-tabs {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
  }

  .tle-tab {
    padding: 0.5rem 0.75rem;
    font-size: 0.8rem;
    white-space: nowrap;
  }

  .review-banner {
    font-size: 0.8rem;
  }

  .unverified-card {
    padding: 0.75rem;
  }

  .unverified-card__head {
    flex-wrap: wrap;
    gap: 0.4rem;
  }

  .triage-fields {
    flex-direction: column;
  }

  .triage-field input,
  .triage-field select {
    width: 100%;
  }

  .modal {
    width: min(42rem, 96vw);
    padding: 1rem;
  }

  .case-picker-bar select {
    min-width: 0;
    width: 100%;
  }

  .verified-table {
    font-size: 0.75rem;
  }

  .verified-table th,
  .verified-table td {
    padding: 0.35rem 0.5rem;
  }
}

@media (max-width: 480px) {
  .quick-entry__textarea {
    min-height: 6rem;
    font-size: 0.85rem;
  }

  .tle-tab {
    padding: 0.4rem 0.6rem;
    font-size: 0.75rem;
  }

  .tle-tab svg { width: 14px; height: 14px; }

  .unverified-card__foot {
    flex-direction: column;
  }

  .verify-actions {
    flex-direction: column;
  }

  .verify-actions .btn {
    width: 100%;
    justify-content: center;
  }

  .modal__actions {
    flex-direction: column;
  }

  .modal__actions .btn {
    width: 100%;
    justify-content: center;
  }

  .event-item {
    flex-direction: column;
    gap: 0.35rem;
  }

  .event-type {
    flex: 0 0 auto;
  }
}
</style>
