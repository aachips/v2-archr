<!--
  AppHeader — topbar present on every view.
  Mirrors the portal header in app/lib/portal-layout.php: brand, quick search,
  role switcher, dark/light toggle, language menu, avatar menu.

  Props:
    cases    Array  - normalized case items (quick-search pool)
    role     String - staff | org-admin | super-admin
    theme    String - light | dark
    lang     String - en | es | uk
    userName String - avatar initials source (stub until the demo has auth)

  Emits:
    open-case (caseItem) - quick-search selection
    set-role (role) / set-lang (code) / toggle-theme
-->
<template>
  <header class="app-header">
    <button type="button" class="hamburger" aria-label="Toggle menu" @click="$emit('toggle-mobile')">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
        <path d="M3 12h18M3 6h18M3 18h18"/>
      </svg>
    </button>

    <div class="app-header__brand">
      <img class="brand-logo" src="../../assets/archr-logo.svg" alt="" />
      <span class="brand-wordmark">ARCHR<span class="brand-tag">{{ t("brand.tag") }}</span></span>
    </div>

    <div class="quick-search">
      <input
        v-model.trim="search"
        type="search"
        :placeholder="t('header.searchPlaceholder')"
        aria-label="Quick case search"
        @focus="searchOpen = true"
        @input="searchOpen = true"
        @keydown.enter.prevent="selectFirst"
      />
      <ul v-if="searchOpen && matches.length" class="quick-search__results">
        <li v-for="m in matches" :key="m.id">
          <button type="button" @click="selectCase(m)">
            <strong>{{ m.caseNumber }}</strong>
            {{ m.applicantName }}
            <span class="muted">{{ m.city }}</span>
          </button>
        </li>
      </ul>
      <p v-else-if="searchOpen && search" class="quick-search__none">No matching cases.</p>
    </div>

    <div class="header-actions">
      <!-- Role preview. In app/ this is the super-admin "view as" switcher;
           the demo keeps it visible for every role so you can exercise the
           permission levels (staff = limited view, org-admin/super-admin = full). -->
      <div class="menu-wrap">
        <button type="button" class="icon-btn" :aria-expanded="openMenu === 'role'" @click="toggle('role')">
          {{ roleLabel }} &#9662;
        </button>
        <ul v-if="openMenu === 'role'" class="menu" role="menu">
          <li v-for="r in ROLES" :key="r">
            <button type="button" class="menu__item" @click="chooseRole(r)">
              {{ roleName(r) }}<span v-if="r === role" class="menu__check">&#10003;</span>
            </button>
          </li>
        </ul>
      </div>

      <button type="button" class="icon-btn" :title="themeTitle" @click="$emit('toggle-theme')">
        {{ theme === "dark" ? "☀" : "☾" }}
      </button>

      <div class="menu-wrap">
        <button
          type="button"
          class="icon-btn"
          :aria-expanded="openMenu === 'lang'"
          :title="t('header.language')"
          @click="toggle('lang')"
        >
          {{ lang.toUpperCase() }} &#9662;
        </button>
        <ul v-if="openMenu === 'lang'" class="menu" role="menu">
          <li v-for="l in LANGUAGES" :key="l.code">
            <button type="button" class="menu__item" @click="chooseLang(l.code)">
              {{ l.label }}<span v-if="l.code === lang" class="menu__check">&#10003;</span>
            </button>
          </li>
        </ul>
      </div>

      <!-- Avatar menu. BACK-END NEED: the demo has no auth or users table —
           userName is a stub prop and the menu items just close the menu
           until login exists (app/ equivalent: lib/auth.php). -->
      <div class="menu-wrap">
        <button
          type="button"
          class="avatar-btn"
          :aria-expanded="openMenu === 'avatar'"
          :title="userName"
          @click="toggle('avatar')"
        >
          {{ initials }}
        </button>
        <ul v-if="openMenu === 'avatar'" class="menu" role="menu">
          <li>
            <a href="../" class="menu__item menu__item--link">Public Site</a>
          </li>
          <li>
            <button type="button" class="menu__item" @click="openProfile">Profile Settings</button>
          </li>
          <li>
            <button type="button" class="menu__item" @click="doLogout">{{ t("header.logout") }}</button>
          </li>
        </ul>
      </div>
    </div>
  </header>
</template>

<script>
import { translate, LANGUAGES } from "../../config/i18n";

const ROLES = ["staff", "org-admin", "super-admin"];
const ROLE_KEYS = {
  staff: "header.role.staff",
  "org-admin": "header.role.orgAdmin",
  "super-admin": "header.role.superAdmin"
};

export default {
  name: "AppHeader",
  props: {
    cases: { type: Array, default: () => [] },
    role: { type: String, default: "super-admin" },
    theme: { type: String, default: "light" },
    lang: { type: String, default: "en" },
    userName: { type: String, default: "Demo User" }
  },
  data() {
    return { ROLES, LANGUAGES, openMenu: null, search: "", searchOpen: false };
  },
  computed: {
    matches() {
      const term = this.search.toLowerCase();
      if (!term) return [];
      return this.cases
        .filter(c =>
          [c.caseNumber, c.applicantName, c.city, c.address, c.zip, c.placecode, c.organization]
            .filter(Boolean)
            .some(v => v.toLowerCase().includes(term))
        )
        .slice(0, 8);
    },
    initials() {
      const parts = this.userName.split(/\s+/).filter(Boolean).map(p => p[0]);
      return parts.slice(0, 2).join("").toUpperCase() || "?";
    },
    roleLabel() {
      return this.roleName(this.role);
    },
    themeTitle() {
      return this.t(this.theme === "dark" ? "header.themeToLight" : "header.themeToDark");
    }
  },
  mounted() {
    document.addEventListener("click", this.onDocClick);
    document.addEventListener("keydown", this.onKeydown);
  },
  beforeDestroy() {
    document.removeEventListener("click", this.onDocClick);
    document.removeEventListener("keydown", this.onKeydown);
  },
  methods: {
    t(key) {
      return translate(this.lang, key);
    },
    roleName(r) {
      return this.t(ROLE_KEYS[r] || "header.role.staff");
    },
    toggle(menu) {
      this.openMenu = this.openMenu === menu ? null : menu;
    },
    closeAll() {
      this.openMenu = null;
      this.searchOpen = false;
    },
    selectCase(c) {
      this.$emit("open-case", c);
      this.search = "";
      this.searchOpen = false;
    },
    selectFirst() {
      if (this.matches.length) this.selectCase(this.matches[0]);
    },
    chooseRole(r) {
      this.$emit("set-role", r);
      this.openMenu = null;
    },
    chooseLang(code) {
      this.$emit("set-lang", code);
      this.openMenu = null;
    },
    onDocClick(e) {
      if (!this.$el.contains(e.target)) this.closeAll();
    },
    onKeydown(e) {
      if (e.key === "Escape") this.closeAll();
    },
    doLogout() {
      this.openMenu = null;
      this.$emit('logout');
    },
    openProfile() {
      this.openMenu = null;
      this.$emit('open-profile');
    }
  }
};
</script>

<style scoped>
.app-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 0.5rem 1rem;
  background: #fff;
  border-bottom: 1px solid #e5e7eb;
}

.hamburger {
  display: none;
  background: none;
  border: none;
  padding: 0.4rem;
  cursor: pointer;
  color: #374151;
  border-radius: 4px;
}

.hamburger:hover { background: #f3f4f6; }
.hamburger svg { width: 22px; height: 22px; }

.app-header__brand {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.brand-logo { width: 28px; height: 28px; }

.brand-wordmark {
  font-weight: 700;
  font-size: 1.1rem;
  color: #1a1a1a;
}

.brand-tag {
  font-weight: 400;
  font-size: 0.7rem;
  color: #6b7280;
  margin-left: 0.25rem;
}

.quick-search {
  position: relative;
  flex: 1;
  max-width: 22rem;
}

.quick-search input {
  width: 100%;
  padding: 0.4rem 0.65rem;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 0.875rem;
}

.quick-search__results {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  max-height: 16rem;
  overflow-y: auto;
  z-index: 50;
}

.quick-search__item {
  padding: 0.4rem 0.65rem;
  cursor: pointer;
  font-size: 0.85rem;
  border-bottom: 1px solid #f3f4f6;
}

.quick-search__item:hover { background: #f9fafb; }
.quick-search__item:last-child { border-bottom: none; }

.header-controls {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-left: auto;
}

.header-btn {
  padding: 0.35rem 0.55rem;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  background: #fff;
  color: #374151;
  font-size: 0.8rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.header-btn:hover { background: #f9fafb; }

.avatar-btn {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: #e0e7ff;
  color: #3730a3;
  font-size: 0.75rem;
  font-weight: 700;
  border: none;
  cursor: pointer;
}

.menu {
  position: absolute;
  top: 100%;
  right: 0;
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  list-style: none;
  margin: 0;
  padding: 0.25rem 0;
  min-width: 140px;
  z-index: 50;
}

.menu__item {
  width: 100%;
  padding: 0.5rem 0.75rem;
  border: none;
  background: none;
  text-align: left;
  font: inherit;
  font-size: 0.85rem;
  color: #374151;
  cursor: pointer;
}

.menu__item--link {
  display: block;
  color: #2166b7;
  text-decoration: none;
}

.menu__item:hover { background: #f9fafb; }

@media (max-width: 992px) {
  .hamburger { display: flex; }

  .app-header {
    gap: 0.5rem;
    padding: 0.5rem 0.75rem;
  }

  .brand-tag { display: none; }

  .quick-search {
    max-width: none;
    order: 10;
    flex: 0 0 100%;
  }

  .app-header {
    flex-wrap: wrap;
  }

  .header-controls { gap: 0.35rem; }
  .header-btn span.btn-label { display: none; }
}

@media (max-width: 480px) {
  .brand-wordmark { font-size: 0.95rem; }
  .quick-search { margin-top: 0.5rem; }
}
</style>