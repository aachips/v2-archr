<template>
  <div class="marketplace-home">
    <!-- Welcome banner -->
    <div class="marketplace-home__welcome">
      <h1>Welcome to the Marketplace</h1>
      <p>Browse applications, repair needs, trades, or triage-prioritized work. Claim what your organization can handle.</p>
    </div>

    <!-- 4 browse options -->
    <div class="marketplace-home__grid">
      <div class="marketplace-home__card" @click="$emit('browse', 'applications')">
        <div class="marketplace-home__icon"><i class="fas fa-clipboard-list"></i></div>
        <h3>Browse by Applications</h3>
        <p>View all submitted applications with their details, eligibility status, and repair needs.</p>
        <button class="btn btn-primary"><i class="fas fa-list"></i> View List</button>
      </div>
      <div class="marketplace-home__card" @click="$emit('browse', 'needs')">
        <div class="marketplace-home__icon"><i class="fas fa-wrench"></i></div>
        <h3>Browse by Repair Needs</h3>
        <p>See individual repair needs across all applications, filterable by trade, triage, and claim status.</p>
        <button class="btn btn-primary"><i class="fas fa-search"></i> View List</button>
      </div>
      <div class="marketplace-home__card" @click="$emit('browse', 'trade')">
        <div class="marketplace-home__icon"><i class="fas fa-hammer"></i></div>
        <h3>Browse by Trade</h3>
        <p>Group repair needs by trade category — carpentry, roofing, plumbing, electrical, and more.</p>
        <button class="btn btn-primary"><i class="fas fa-hammer"></i> View by Trade</button>
      </div>
      <div class="marketplace-home__card" @click="$emit('browse', 'triage')">
        <div class="marketplace-home__icon"><i class="fas fa-sort-amount-down"></i></div>
        <h3>Browse by Triage</h3>
        <p>Prioritize work by urgency score — critical needs first, then high, medium, and low.</p>
        <button class="btn btn-primary"><i class="fas fa-exclamation-triangle"></i> View by Triage</button>
      </div>
    </div>
  </div>
</template>

<script>
/**
 * MarketplaceHome
 *
 * Landing page for the Marketplace. Shows welcome message and 4 browse options.
 *
 * Emits:
 *   browse(mode) — 'applications' | 'needs' | 'trade' | 'triage'
 */
export default {
  name: 'MarketplaceHome',
  emits: ['browse']
};
</script>

<style scoped>
.marketplace-home__welcome {
  text-align: center;
  padding: 32px 20px;
  margin-bottom: 32px;
}
.marketplace-home__welcome h1 {
  font-family: var(--font-display, 'Poppins', sans-serif);
  font-size: 1.8rem;
  color: var(--color-primary, #2a5c82);
  margin-bottom: 8px;
}
.marketplace-home__welcome p {
  font-size: 1.05rem;
  color: var(--color-text-muted, #6b7280);
  max-width: 600px;
  margin: 0 auto;
}

.marketplace-home__grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 24px;
  max-width: 960px;
  margin: 0 auto;
  padding: 0 20px;
}

.marketplace-home__card {
  background: var(--bg-surface, #fff);
  border: 1px solid var(--color-border, #e5e7eb);
  border-radius: var(--border-radius, 8px);
  padding: 32px 24px;
  text-align: center;
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
}
.marketplace-home__card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow, 0 4px 12px rgba(0,0,0,0.1));
  border-color: var(--color-primary, #2a5c82);
}

.marketplace-home__icon {
  font-size: 2.5rem;
  color: var(--color-primary, #2a5c82);
  margin-bottom: 8px;
}

.marketplace-home__card h3 {
  font-size: 1.1rem;
  color: var(--color-text, #333);
  margin: 0;
}

.marketplace-home__card p {
  font-size: 0.9rem;
  color: var(--color-text-muted, #6b7280);
  line-height: 1.5;
  flex: 1;
}

.btn {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 8px 20px;
  border: 1px solid var(--color-primary, #2a5c82);
  border-radius: 4px;
  background: var(--color-primary, #2a5c82);
  color: #fff;
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  margin-top: auto;
}
.btn:hover { background: #1e4461; }
</style>
