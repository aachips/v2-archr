<template>
  <div class="ami-calculator">
    <header class="calc-header">
      <h2><i class="fas fa-calculator"></i> Income Verification — AMI Calculator</h2>
      <p class="subtitle">Calculate what percentage of Area Median Income (AMI) a household qualifies for.</p>
    </header>

    <!-- County selection -->
    <div class="calc-section">
      <label for="county">County</label>
      <select id="county" v-model="countyId" @change="calculate">
        <option value="">— Select County —</option>
        <option v-for="(c, id) in amiData.counties" :key="id" :value="id">{{ c.name }}</option>
      </select>
      <span v-if="countyConfig" class="data-year">Data year: {{ countyConfig.year }}</span>
    </div>

    <!-- Household info -->
    <div class="calc-section">
      <div class="calc-row">
        <label for="hhSize">Household Size</label>
        <input type="number" id="hhSize" v-model.number="householdSize" min="1" max="8" placeholder="1–8">
      </div>
      <div class="calc-row">
        <label for="income">Total Annual Household Income ($)</label>
        <input type="number" id="income" v-model.number="annualIncome" min="0" step="100" placeholder="e.g., 24000">
      </div>
    </div>

    <!-- Results -->
    <div v-if="result" class="calc-results">
      <h3>Results</h3>
      <div class="result-grid">
        <div class="result-card" :class="{ current: result.atOrBelow === tier }" v-for="tier in result.tiers" :key="tier.pct">
          <div class="tier-pct">{{ tier.pct }}% AMI</div>
          <div class="tier-limit">${{ tier.limit.toLocaleString() }}</div>
          <div class="tier-status" v-if="result.atOrBelow === tier">
            <i class="fas fa-check-circle"></i> At or below
          </div>
          <div class="tier-status above" v-else-if="result.above === tier.pct">
            <i class="fas fa-arrow-up"></i> Above
          </div>
        </div>
      </div>

      <div class="result-summary">
        <span class="summary-pct">
          Household income is <strong>{{ result.percentOfAMI }}%</strong> of AMI for {{ countyConfig?.name || 'selected county' }} ({{ householdSize }}-person household)
        </span>
      </div>

      <!-- Save to case (admin only) -->
      <div v-if="isAdmin" class="save-to-case">
        <h4><i class="fas fa-save"></i> Save to Case</h4>
        <div class="save-row">
          <label for="caseId">Case ID (optional)</label>
          <input type="text" id="caseId" v-model="caseId" placeholder="Enter case ID to attach results">
        </div>
        <div class="save-row">
          <label for="saveNotes">Notes (optional)</label>
          <textarea id="saveNotes" v-model="saveNotes" rows="2" placeholder="Verification notes..."></textarea>
        </div>
        <button class="btn-save" @click="saveToCase" :disabled="saving">
            {{ saving ? 'Saving...' : 'Save Verification to Case' }}
          </button>
        <span v-if="saved" class="save-ok"><i class="fas fa-check"></i> Saved!</span>
      </div>

      <div class="result-disclaimer">
        <p>These values are based on HUD Income Limits for {{ countyConfig?.year || 'the selected year' }}. Always verify with current published limits at <a href="https://www.huduser.gov/portal/datasets/il.html" target="_blank" rel="noopener">huduser.gov</a>.</p>
      </div>
    </div>
  </div>
</template>

<script>
/**
 * AMICalculator — Income verification tool.
 *
 * Uses HUD AMI limits from app/config/ami-data.json.
 * Future: Census API integration (key stubbed in ami-data.json).
 *
 * Admins (level 2+) can save results to a case record.
 */
export default {
  name: 'AMICalculator',
  data() {
    return {
      countyId: '',
      householdSize: null,
      annualIncome: null,
      caseId: '',
      saveNotes: '',
      saving: false,
      saved: false,
      result: null,
      amiData: { counties: {} },
    };
  },
  computed: {
    countyConfig() {
      if (!this.countyId || !this.amiData.counties[this.countyId]) return null;
      return this.amiData.counties[this.countyId];
    },
    isAdmin() {
      const level = this.$auth?.level ?? 0;
      return level >= 2;
    },
  },
  created() {
    this.loadAmiData();
  },
  methods: {
    async loadAmiData() {
      try {
        // TODO: Wire to backend endpoint: GET /app/vue_api/ami-data.php
        // which reads app/config/ami-data.json
        // For now, fetch directly (works if file is served):
        const resp = await fetch('/app/config/ami-data.json');
        if (resp.ok) {
          this.amiData = await resp.json();
        } else {
          // Fallback: hardcoded
          this.amiData = this.getFallbackData();
        }
      } catch (e) {
        console.warn('AMI data load failed, using fallback:', e);
        this.amiData = this.getFallbackData();
      }
    },

    getFallbackData() {
      return {
        counties: {
          buncombe_nc: {
            name: 'Buncombe County, NC',
            metro: 'Asheville MSA',
            fips: '37021',
            year: 2024,
            limits: {
              30: { 1: 20650, 2: 23600, 3: 26550, 4: 29500, 5: 31900, 6: 34250, 7: 36600, 8: 38950 },
              50: { 1: 34450, 2: 39350, 3: 44250, 4: 49150, 5: 53100, 6: 57050, 7: 61000, 8: 64950 },
              80: { 1: 55100, 2: 63000, 3: 70850, 4: 78700, 5: 85000, 6: 91300, 7: 97600, 8: 103900 },
            },
          },
          madison_nc: {
            name: 'Madison County, NC',
            metro: 'Asheville MSA',
            fips: '37115',
            year: 2024,
            limits: {
              30: { 1: 20650, 2: 23600, 3: 26550, 4: 29500, 5: 31900, 6: 34250, 7: 36600, 8: 38950 },
              50: { 1: 34450, 2: 39350, 3: 44250, 4: 49150, 5: 53100, 6: 57050, 7: 61000, 8: 64950 },
              80: { 1: 55100, 2: 63000, 3: 70850, 4: 78700, 5: 85000, 6: 91300, 7: 97600, 8: 103900 },
            },
          },
        },
      };
    },

    calculate() {
      if (!this.countyConfig || !this.householdSize || !this.annualIncome) {
        this.result = null;
        return;
      }

      const size = Math.min(Math.max(this.householdSize, 1), 8);
      const limits = this.countyConfig.limits;
      const tiers = [
        { pct: 30, limit: limits[30]?.[size] ?? 0 },
        { pct: 50, limit: limits[50]?.[size] ?? 0 },
        { pct: 80, limit: limits[80]?.[size] ?? 0 },
      ];

      // Find highest tier the household is at or below
      let atOrBelow = null;
      let above = null;
      for (const tier of tiers) {
        if (this.annualIncome <= tier.limit) {
          atOrBelow = tier;
        } else {
          above = tier.pct;
        }
      }

      // Percent of AMI (relative to 100% — extrapolate from 50% limit)
      const ami100 = limits[50]?.[size] ? limits[50][size] * 2 : 0;
      const percentOfAMI = ami100 > 0 ? Math.round((this.annualIncome / ami100) * 100) : null;

      this.result = { tiers, atOrBelow, above, percentOfAMI };
    },

    async saveToCase() {
      if (!this.caseId) return;
      this.saving = true;
      try {
        // TODO: POST /app/vue_api/ami-verification.php
        // Body: { case_id, county_id, household_size, annual_income, ami_percent, tier, notes }
        console.log('Saving AMI verification to case:', {
          caseId: this.caseId,
          county: this.countyId,
          householdSize: this.householdSize,
          annualIncome: this.annualIncome,
          amiPercent: this.result?.percentOfAMI,
          tier: this.result?.atOrBelow?.pct,
          notes: this.saveNotes,
        });
        this.saved = true;
        setTimeout(() => { this.saved = false; }, 3000);
      } finally {
        this.saving = false;
      }
    },
  },
};
</script>

<style scoped>
.ami-calculator {
  max-width: 700px;
  margin: 0 auto;
  padding: 1.5rem;
}

.calc-header h2 {
  font-size: 1.3rem;
  color: var(--color-text, #1a1a2e);
  margin: 0 0 0.25rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.subtitle {
  color: var(--color-text-secondary, #64748b);
  margin: 0;
  font-size: 0.9rem;
}

.calc-section {
  background: var(--color-surface, #fff);
  border: 1px solid var(--color-border, #e2e8f0);
  border-radius: 10px;
  padding: 1.25rem;
  margin-bottom: 1rem;
}

.calc-section label {
  display: block;
  font-weight: 600;
  font-size: 0.9rem;
  color: var(--color-text, #1a1a2e);
  margin-bottom: 0.35rem;
}

.calc-section select,
.calc-section input[type="number"],
.calc-section input[type="text"] {
  width: 100%;
  padding: 0.6rem 0.75rem;
  border: 1px solid var(--color-border, #e2e8f0);
  border-radius: 6px;
  font-size: 0.95rem;
  font-family: inherit;
  background: var(--color-surface, #fff);
  color: var(--color-text, #1a1a2e);
}

.calc-section select:focus,
.calc-section input:focus {
  outline: none;
  border-color: var(--color-accent, #2563eb);
  box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
}

.calc-row {
  margin-bottom: 1rem;
}

.calc-row:last-child {
  margin-bottom: 0;
}

.data-year {
  display: inline-block;
  font-size: 0.75rem;
  color: var(--color-text-secondary, #64748b);
  margin-top: 0.35rem;
  background: var(--color-surface-alt, #f1f5f9);
  padding: 0.15rem 0.5rem;
  border-radius: 4px;
}

/* Results */
.calc-results {
  background: var(--color-surface, #fff);
  border: 1px solid var(--color-border, #e2e8f0);
  border-radius: 10px;
  padding: 1.25rem;
}

.calc-results h3 {
  font-size: 1rem;
  color: var(--color-text, #1a1a2e);
  margin: 0 0 1rem;
}

.result-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 0.75rem;
  margin-bottom: 1rem;
}

.result-card {
  background: var(--color-surface-alt, #f8fafc);
  border: 1px solid var(--color-border, #e2e8f0);
  border-radius: 8px;
  padding: 0.75rem;
  text-align: center;
}

.result-card.current {
  border-color: #22c55e;
  background: #f0fdf4;
}

.tier-pct {
  font-size: 1.25rem;
  font-weight: 700;
  color: var(--color-text, #1a1a2e);
}

.tier-limit {
  font-size: 0.85rem;
  color: var(--color-text-secondary, #64748b);
  margin-top: 0.25rem;
}

.tier-status {
  margin-top: 0.4rem;
  font-size: 0.8rem;
  font-weight: 600;
  color: #16a34a;
}

.tier-status i {
  margin-right: 0.25rem;
}

.tier-status.above {
  color: #64748b;
}

.result-summary {
  background: #eff6ff;
  border: 1px solid #bfdbfe;
  border-radius: 8px;
  padding: 0.75rem 1rem;
  margin-bottom: 1rem;
}

.summary-pct {
  font-size: 0.9rem;
  color: #1e40af;
}

.summary-pct strong {
  font-size: 1.1rem;
}

/* Save to case */
.save-to-case {
  border-top: 1px solid var(--color-border, #e2e8f0);
  padding-top: 1rem;
  margin-bottom: 1rem;
}

.save-to-case h4 {
  font-size: 0.9rem;
  color: var(--color-text, #1a1a2e);
  margin: 0 0 0.75rem;
  display: flex;
  align-items: center;
  gap: 0.35rem;
}

.save-to-case h4 i {
  color: var(--color-accent, #2563eb);
}

.save-row {
  margin-bottom: 0.75rem;
}

.save-row label {
  display: block;
  font-weight: 600;
  font-size: 0.8rem;
  color: var(--color-text, #1a1a2e);
  margin-bottom: 0.25rem;
}

.save-row input,
.save-row textarea {
  width: 100%;
  padding: 0.5rem 0.65rem;
  border: 1px solid var(--color-border, #e2e8f0);
  border-radius: 6px;
  font-size: 0.85rem;
  font-family: inherit;
}

.btn-save {
  padding: 0.5rem 1.25rem;
  border-radius: 6px;
  font-weight: 600;
  font-size: 0.85rem;
  background: var(--color-accent, #2563eb);
  color: #fff;
  border: none;
  cursor: pointer;
}

.btn-save:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.save-ok {
  margin-left: 0.75rem;
  color: #16a34a;
  font-size: 0.85rem;
  font-weight: 600;
}

.result-disclaimer {
  font-size: 0.75rem;
  color: var(--color-text-secondary, #64748b);
  border-top: 1px dashed var(--color-border, #e2e8f0);
  padding-top: 0.75rem;
}

.result-disclaimer a {
  color: var(--color-accent, #2563eb);
}
</style>
