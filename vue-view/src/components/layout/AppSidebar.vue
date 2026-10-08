<!--
  AppSidebar — left nav, present on every view.
  On desktop: fixed 14rem sidebar.
  On mobile (< 768px): collapses, toggled via hamburger from AppHeader.
-->
<template>
  <aside :class="['sidebar', { 'sidebar--open': mobileOpen }]">
    <nav class="nav">
      <div class="nav__head">
        <span class="nav__title">Navigation</span>
        <button
          v-if="mobileOpen"
          type="button"
          class="sidebar__close"
          aria-label="Close menu"
          @click="$emit('close-mobile')"
        >
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
            <path d="M18 6L6 18M6 6l12 12"/>
          </svg>
        </button>
      </div>
      <button
        v-for="(item, idx) in nav"
        :key="item.view || idx"
        type="button"
        :class="['nav__item', { active: !item.external && item.view === view && !caseOpen, 'nav__item--external': item.external }]"
        @click="$emit('go', item)"
      >
        {{ item.label }}
        <span v-if="item.external" class="nav__external-icon" title="Opens in new tab">
          <svg viewBox="0 0 16 16" fill="currentColor" aria-hidden="true">
            <path d="M6 1h10v10H6V1zm1 1v8h8V2H7z"/>
            <path d="M1 5h2v10h10v2H1V5z"/>
          </svg>
        </span>
      </button>
    </nav>
  </aside>
</template>

<script>
export default {
  name: "AppSidebar",
  props: {
    nav: { type: Array, default: () => [] },
    view: { type: String, default: "search" },
    caseOpen: { type: Boolean, default: false },
    mobileOpen: { type: Boolean, default: false }
  }
};
</script>

<style scoped>
.sidebar {
  width: 14rem;
  background: #fff;
  border-right: 1px solid #e5e7eb;
  padding: 0.75rem 0;
  flex-shrink: 0;
}

.nav {
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
}

.nav__head {
  display: none;
  align-items: center;
  justify-content: space-between;
  padding: 0.75rem 1rem;
  margin-bottom: 0.25rem;
  border-bottom: 1px solid #e5e7eb;
}

.nav__title {
  font-size: 0.85rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.025em;
  color: #6b7280;
}

.sidebar__close {
  display: none;
  align-items: center;
  justify-content: center;
  width: 2rem;
  height: 2rem;
  border: none;
  background: #f3f4f6;
  border-radius: 50%;
  cursor: pointer;
  color: #374151;
  padding: 0;
  flex-shrink: 0;
}

.sidebar__close:hover { background: #e5e7eb; }
.sidebar__close svg { width: 18px; height: 18px; }

.nav__item {
  padding: 0.5rem 1rem;
  text-align: left;
  border: none;
  background: transparent;
  font: inherit;
  color: #374151;
  cursor: pointer;
  border-radius: 4px;
  margin: 0 0.5rem;
  display: flex;
  align-items: center;
  gap: 0.35rem;
}

.nav__item:hover {
  background: #f3f4f6;
}

.nav__item.active {
  background: #eff6ff;
  color: #1d4ed8;
  font-weight: 600;
}

.nav__item--external {
  opacity: 0.75;
}

.nav__external-icon {
  display: inline-flex;
  width: 12px;
  height: 12px;
  color: #9ca3af;
  flex-shrink: 0;
}

@media (max-width: 992px) {
  .sidebar {
    position: fixed;
    top: 0;
    left: -14rem;
    bottom: 0;
    z-index: 200;
    transition: left 0.2s ease;
    box-shadow: none;
  }

  .sidebar--open {
    left: 0;
    box-shadow: 4px 0 20px rgba(0, 0, 0, 0.15);
  }

  .nav__head {
    display: flex;
  }

  .sidebar__close {
    display: flex;
  }
}
</style>
