<!--
  FilterableCaseList — Stage 1 rebuild
  ----------------------------------------------------------------
  Proper <table> with accessible <thead>, improved column selection,
  urgent flag as red triangle icon, and richer filters.

  Presentational only: the parent fetches and normalizes records
  (see src/services/caseService.js).

  Props:
    cases   Array  - normalized case items
    loading Boolean - show a loading notice instead of the list.

  Emits:
    select (caseItem) - user clicked a case row.
-->
<template>
  <section class="case-list">
    <!-- Filters -->
    <div class="case-list__filters">
      <label class="filter filter--wide">
        <span class="filter__label">Search</span>
        <input
          v-model.trim="search"
          type="text"
          placeholder="Name, placecode, address, city"
        />
      </label>

      <label class="filter">
        <span class="filter__label">Status</span>
        <select v-model="selectedStatus">
          <option value="">All statuses</option>
          <option v-for="s in statusOptions" :key="s.value" :value="s.value"> {{ s.label }} </option>
          <option value="assessment-ready">Assessment-Ready</option>
          <option value="in-assessment">In Assessment</option>
          <option value="assessed">Assessed (SOW Created)</option>
          <option value="ready-for-contract">Ready for Contract</option>
        </select>
      </label>

      <label class="filter">
        <span class="filter__label">Organization</span>
        <select v-model="selectedOrg">
          <option value="">All organizations</option>
          <option v-for="org in orgOptions" :key="org" :value="org">{{ org }}</option>
        </select>
      </label>

      <label class="filter">
        <span class="filter__label">From</span>
        <input v-model="dateFrom" type="date" />
      </label>

      <label class="filter">
        <span class="filter__label">To</span>
        <input v-model="dateTo" type="date" />
      </label>

      <label class="filter">
        <span class="filter__label">Sort by</span>
        <select v-model="sortBy">
          <option value="newest">Newest first</option>
          <option value="oldest">Oldest first</option>
          <option value="name">Name A–Z</option>
          <option value="city">City A–Z</option>
        </select>
      </label>

      <label class="filter filter--check">
        <input v-model="urgentOnly" type="checkbox" />
        <span>⚠ Urgent action needed</span>
      </label>

      <span class="case-list__count">
        {{ filteredCases.length }} of {{ cases.length }} cases
      </span>
    </div>

    <!-- Export buttons (only shown when there are filtered results) -->
    <div v-if="filteredCases.length > 0" class="case-list__export">
      <button type="button" class="btn-export" @click="exportCSV">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
          <path d="M12 3v12m0 0l-4-4m4 4l4-4M4 17v2a2 2 0 002 2h12a2 2 0 002-2v-2"/>
        </svg>
        Export CSV
      </button>
      <button type="button" class="btn-export" @click="exportXLSX">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
          <path d="M12 3v12m0 0l-4-4m4 4l4-4M4 17v2a2 2 0 002 2h12a2 2 0 002-2v-2"/>
        </svg>
        Export Excel
      </button>
    </div>

    <!-- Results -->
    <p v-if="loading" class="case-list__notice">Loading cases…</p>
    <p v-else-if="filteredCases.length === 0" class="case-list__notice">
      No cases match these filters.
    </p>

    <div v-else class="table-wrap">
      <table class="case-list-table">
        <thead>
          <tr>
            <th v-if="isColumnVisible('placecode')">Placecode</th>
            <th v-if="isColumnVisible('applicantName')">Applicant</th>
            <th v-if="isColumnVisible('address')">Address</th>
            <th v-if="isColumnVisible('city')">City</th>
            <th v-if="isColumnVisible('status')">Status</th>
            <th v-if="isColumnVisible('phase')">Phase</th>
            <th v-if="isColumnVisible('organization')">Organization</th>
            <th v-if="isColumnVisible('submittedAt')">Submitted</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="c in filteredCases"
            :key="c.id"
            :class="{ 'row-urgent': c.isUrgent }"
          >
            <td v-if="isColumnVisible('placecode')" class="cell-placecode">
              <button type="button" class="case-link" @click="$emit('select', c)">
                {{ derivePlacecode(c) || '—' }}
                <span v-if="c.isUrgent" class="urgent-icon" title="Urgent action needed">
                  <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                    <path d="M12 2L1 21h22L12 2zm0 4l7.53 13H4.47L12 6zm-1 5v4h2v-4h-2zm0 6v2h2v-2h-2z"/>
                  </svg>
                </span>
              </button>
            </td>
            <td v-if="isColumnVisible('applicantName')" class="cell-name">
              <button type="button" class="case-link" @click="$emit('select', c)">
                {{ c.applicantName || '—' }}
              </button>
            </td>
            <td v-if="isColumnVisible('address')">{{ c.address || '—' }}</td>
            <td v-if="isColumnVisible('city')">{{ c.city || '—' }}</td>
            <td v-if="isColumnVisible('status')">
              <span class="pill">{{ c.status || 'Unknown' }}</span>
            </td>
            <td v-if="isColumnVisible('phase')">
              <span class="pill pill-blue">{{ phaseLabel(c) }}</span>
            </td>
            <td v-if="isColumnVisible('organization')">{{ c.organization || 'Unclaimed' }}</td>
            <td v-if="isColumnVisible('submittedAt')" class="cell-date">{{ formatDate(c.submittedAt) }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>
</template>

<script>
import { casePhase } from '../config/casePhases';

export default {
  name: "FilterableCaseList",
  props: {
    cases: { type: Array, default: () => [] },
    loading: { type: Boolean, default: false }
  },
  data() {
    return {
      selectedOrg: "",
      selectedStatus: "",
      search: "",
      dateFrom: "",
      dateTo: "",
      sortBy: "newest",
      urgentOnly: false,
      visibleColumns: null // null = use defaults (all columns)
    };
  },

  mounted() {
    this.loadColumns();
    window.addEventListener('archr:columns-changed', this.onColumnsChanged);
  },

  beforeDestroy() {
    window.removeEventListener('archr:columns-changed', this.onColumnsChanged);
  },

  computed: {
    statusOptions() {
      const seen = new Set();
      const options = [];
      for (const c of this.cases) {
        const key = c.status || 'Unknown';
        if (!seen.has(key)) {
          seen.add(key);
          options.push({ label: key, value: key });
        }
      }
      return options.sort((a, b) => a.label.localeCompare(b.label));
    },
    orgOptions() {
      const orgs = this.cases.map(c => c.organization).filter(Boolean);
      return [...new Set(orgs)].sort();
    },
    filteredCases() {
      const term = this.search.toLowerCase();
      let results = this.cases.filter(c => {
        // Status + workflow filter (workflowStatus is on the case object, populated from application)
        const statusValue = c.workflowStatus || c.status;
        const statusOk = !this.selectedStatus || statusValue === this.selectedStatus;
        // Org filter
        const orgOk = !this.selectedOrg || c.organization === this.selectedOrg;
        // Search
        const termOk = !term || [
          c.caseNumber,
          this.derivePlacecode(c),
          c.applicantName,
          c.city,
          c.address
        ]
          .filter(Boolean)
          .some(v => v.toLowerCase().includes(term));
        // Date from
        const fromOk = !this.dateFrom || this.dateOnOrAfter(c.submittedAt, this.dateFrom);
        // Date to
        const toOk = !this.dateTo || this.dateOnOrBefore(c.submittedAt, this.dateTo);
        // Urgent only
        const urgentOk = !this.urgentOnly || c.isUrgent;

        return statusOk && orgOk && termOk && fromOk && toOk && urgentOk;
      });

      // Sort
      results.sort((a, b) => {
        switch (this.sortBy) {
          case 'oldest':
            return this.dateNum(a.submittedAt) - this.dateNum(b.submittedAt);
          case 'name':
            return (a.applicantName || '').localeCompare(b.applicantName || '');
          case 'city':
            return (a.city || '').localeCompare(b.city || '');
          default: // newest
            return this.dateNum(b.submittedAt) - this.dateNum(a.submittedAt);
        }
      });

      return results;
    }
  },
  methods: {
    phaseLabel(c) {
      if (!c.statusSequence && c.statusSequence !== 0) return '—';
      const phase = casePhase(c);
      return phase ? `P${phase.number} · ${phase.name}` : '—';
    },
    formatDate(iso) {
      if (!iso) return '—';
      const d = new Date(iso);
      if (isNaN(d)) return '—';
      return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
    },
    dateOnOrAfter(iso, dateStr) {
      if (!iso) return false;
      return new Date(iso) >= new Date(dateStr + 'T00:00:00');
    },
    dateOnOrBefore(iso, dateStr) {
      if (!iso) return false;
      return new Date(iso) <= new Date(dateStr + 'T23:59:59');
    },
    dateNum(iso) {
      if (!iso) return 0;
      const d = new Date(iso);
      return isNaN(d) ? 0 : d.getTime();
    },

    // --- Column visibility ---
    loadColumns() {
      try {
        const saved = JSON.parse(localStorage.getItem('archr:case-columns'));
        if (Array.isArray(saved) && saved.length > 0) {
          this.visibleColumns = saved;
        }
      } catch (_) {
        // use defaults (null = all columns)
      }
    },

    onColumnsChanged(event) {
      this.visibleColumns = event.detail.columns;
    },

    isColumnVisible(key) {
      if (!this.visibleColumns) return true; // default: all visible
      return this.visibleColumns.includes(key);
    },

    // --- Placecode derivation (mirrors app/lib/applications.php: archr_placecode)
    derivePlacecode(c) {
      // If the case already has a placecode from the applications table, use it.
      if (c.placecode && c.placecode.trim() !== '') return c.placecode;

      // Otherwise derive from the address.
      const addr = (c.address || '').trim();
      if (!addr) return '';

      const upper = addr.toUpperCase();

      // Remove unit/apt/suite designators.
      let cleaned = upper.replace(/\b(?:APT|UNIT|SUITE|STE|#)\s*\w+\b/g, '');

      // Extract leading number (supports ranges like 123-125).
      const numMatch = cleaned.match(/^([0-9]+(?:-[0-9]+)?)/);
      const number = numMatch ? numMatch[1] : '';

      // Remove the number, directionals, and non-letters from street.
      let street = cleaned.replace(/^[0-9]+(?:-[0-9]+)?\s*/, '');
      street = street.replace(/\b(?:NORTH|SOUTH|EAST|WEST|NORTHEAST|NORTHWEST|SOUTHEAST|SOUTHWEST|NE|NW|SE|SW|N|S|E|W)\b/g, '');
      street = street.replace(/[^A-Z]/g, '');

      const lettersNeeded = Math.max(0, 8 - number.length);
      const letters = street.substring(0, lettersNeeded);
      const code = (number + letters).substring(0, 8);

      return code || '';
    },

    // --- Export helpers ---
    _exportRows() {
      const headers = [
        'Placecode', 'Applicant', 'Address', 'City',
        'State', 'ZIP', 'Organization', 'Status', 'Phase',
        'Urgent', 'Submitted', 'Phone', 'Email'
      ];
      const rows = this.filteredCases.map(c => [
        this.derivePlacecode(c) || '',
        c.applicantName || '',
        c.address || '',
        c.city || '',
        c.state || '',
        c.zip || '',
        c.organization || 'Unclaimed',
        c.status || 'Unknown',
        this.phaseLabel(c),
        c.isUrgent ? 'Yes' : 'No',
        this.formatDate(c.submittedAt),
        c.phone || '',
        c.email || ''
      ]);
      return { headers, rows };
    },

    _downloadBlob(blob, filename) {
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = filename;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
    },

    exportCSV() {
      const { headers, rows } = this._exportRows();
      const BOM = '\uFEFF'; // UTF-8 BOM so Excel reads it correctly
      const csv = BOM + [headers, ...rows]
        .map(row => row.map(v => '"' + String(v).replace(/"/g, '""') + '"').join(','))
        .join('\r\n');
      const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
      const date = new Date().toISOString().slice(0, 10);
      this._downloadBlob(blob, `cases_export_${date}.csv`);
    },

    exportXLSX() {
      // Building a real .xlsx zip client-side requires JSZip. Instead, fall
      // back to a simpler approach: use an HTML table with Excel MIME type.
      this.exportAsExcelHtml();
    },

    exportAsExcelHtml() {
      const { headers, rows } = this._exportRows();
      let html = '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel"><head><meta charset="utf-8"><!--[if gte mso 9]><xml><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>Cases</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]--></head><body><table><tr>';
      for (const h of headers) {
        html += `<th>${escHtml(h)}</th>`;
      }
      html += '</tr>';
      for (const row of rows) {
        html += '<tr>';
        for (const v of row) {
          html += `<td>${escHtml(String(v))}</td>`;
        }
        html += '</tr>';
      }
      html += '</table></body></html>';

      const blob = new Blob([html], { type: 'application/vnd.ms-excel' });
      const date = new Date().toISOString().slice(0, 10);
      this._downloadBlob(blob, `cases_export_${date}.xls`);
    }
  }
};

function escHtml(s) {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}
</script>

<style scoped>
.case-list__filters {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
  align-items: flex-end;
  margin-bottom: 1rem;
  padding: 1rem;
  background: #f9fafb;
  border-radius: 8px;
  border: 1px solid #e5e7eb;
}

.filter {
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
}

.filter--wide input {
  min-width: 18rem;
}

.filter__label {
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  color: #6b7280;
  letter-spacing: 0.025em;
}

.filter select,
.filter input[type="text"],
.filter input[type="date"] {
  padding: 0.35rem 0.5rem;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  font-size: 0.875rem;
  background: #fff;
}

.filter--check {
  flex-direction: row;
  align-items: center;
  gap: 0.35rem;
  padding-top: 1.1rem;
}

.filter--check input {
  margin: 0;
}

.case-list__count {
  margin-left: auto;
  font-size: 0.8rem;
  color: #6b7280;
  padding-top: 1.1rem;
  white-space: nowrap;
}

.case-list__notice {
  color: #6b7280;
  font-style: italic;
  padding: 1rem 0;
}

.table-wrap {
  overflow-x: auto;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
}

.case-list-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.875rem;
}

.case-list-table thead {
  background: #f3f4f6;
  position: sticky;
  top: 0;
  z-index: 1;
}

.case-list-table th {
  text-align: left;
  padding: 0.6rem 0.75rem;
  font-weight: 600;
  color: #374151;
  font-size: 0.75rem;
  text-transform: uppercase;
  letter-spacing: 0.025em;
  border-bottom: 2px solid #d1d5db;
  white-space: nowrap;
}

.case-list-table td {
  padding: 0.5rem 0.75rem;
  border-bottom: 1px solid #f3f4f6;
  vertical-align: middle;
}

.case-list-table tbody tr:hover {
  background: #f9fafb;
}

.case-list-table tbody tr:last-child td {
  border-bottom: none;
}

.row-urgent {
  background: #fef2f2;
}

.row-urgent:hover {
  background: #fee2e2;
}

.case-link {
  background: none;
  border: none;
  color: #1a56db;
  font: inherit;
  cursor: pointer;
  padding: 0;
  text-align: left;
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
}

.case-link:hover {
  color: #1e40af;
  text-decoration: underline;
}

.urgent-icon {
  display: inline-flex;
  align-items: center;
  color: #dc2626;
  font-size: 1rem;
  line-height: 1;
  flex-shrink: 0;
}

.urgent-icon svg {
  width: 16px;
  height: 16px;
}

.cell-placecode {
  font-family: ui-monospace, 'Cascadia Code', 'Source Code Pro', monospace;
  font-size: 0.8rem;
  color: #4b5563;
}

.cell-name {
  min-width: 10rem;
}

.cell-date {
  white-space: nowrap;
  color: #6b7280;
}

.pill {
  display: inline-block;
  padding: 0.1rem 0.5rem;
  border-radius: 999px;
  background: #f3f4f6;
  color: #374151;
  font-size: 0.75rem;
  font-weight: 500;
}

.pill-blue {
  background: #eff6ff;
  color: #1e40af;
}

.pill-amber {
  background: #fef3c7;
  color: #92400e;
}

.case-list__export {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
}

.btn-export {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  padding: 0.4rem 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  background: #fff;
  color: #374151;
  font-size: 0.8rem;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.15s, border-color 0.15s;
}

.btn-export:hover {
  background: #f9fafb;
  border-color: #9ca3af;
}

.btn-export svg {
  width: 14px;
  height: 14px;
}

@media (max-width: 992px) {
  .case-list__filters {
    flex-direction: row;
    flex-wrap: wrap;
    justify-content: center;
    gap: 0.5rem;
    padding: 0.75rem;
  }

  .filter {
    width: 10rem;
  }

  .filter--wide {
    flex: 0 0 18rem;
  }

  .filter--wide input,
  .filter select,
  .filter input[type="text"],
  .filter input[type="date"] {
    width: 100%;
  }

  .case-list__count {
    margin-left: 0;
    padding-top: 0;
    width: 100%;
    text-align: center;
  }

  .filter--check {
    padding-top: 0;
    width: auto;
  }

  .case-list__export {
    flex-wrap: wrap;
    justify-content: center;
  }

  /* Hide status and phase on narrow screens */
  .case-list-table th:nth-child(5),
  .case-list-table th:nth-child(6),
  .case-list-table td:nth-child(5),
  .case-list-table td:nth-child(6) {
    display: none;
  }

  .case-list-table {
    font-size: 0.8rem;
  }

  .case-list-table th,
  .case-list-table td {
    padding: 0.4rem 0.5rem;
  }

  .cell-placecode {
    font-size: 0.75rem;
  }
}

@media (max-width: 480px) {
  .case-list__filters {
    padding: 0.5rem;
  }

  .filter__label {
    font-size: 0.7rem;
  }

  .case-list-table th,
  .case-list-table td {
    padding: 0.3rem 0.4rem;
    white-space: nowrap;
  }

  /* Also hide organization on very narrow */
  .case-list-table th:nth-child(7),
  .case-list-table td:nth-child(7) {
    display: none;
  }

  .pill {
    font-size: 0.7rem;
    padding: 0.05rem 0.35rem;
  }
}
</style>
