/**
 * Simple Vue 2 reactive auth store.
 *
 * Not Vuex — just a reactive Vue instance shared across the app.
 * Import and use in any component as: import auth from '@/store/auth';
 *
 * Usage:
 *   auth.user          → reactive user object (or null)
 *   auth.isLoggedIn    → boolean
 *   auth.token         → string (or null)
 *   auth.login(email, password, rememberMe)
 *   auth.logout()
 *   await auth.init()  → checks for stored token on app load
 */

import Vue from 'vue';
import { login, verifyToken, logout as logoutService } from '../services/authService';

const TOKEN_KEY = 'archr_auth_token';

// A shared reactive Vue instance. Any component that imports this gets
// the same reactive state — no Vuex needed for a single store.
const auth = new Vue({
  data() {
    return {
      user: null,
      token: null,
      initializing: true,
      error: null,
    };
  },

  computed: {
    isLoggedIn() {
      return this.user !== null && this.token !== null;
    },

    role() {
      return this.user ? this.user.role : null;
    },

    roleLevel() {
      return this.user ? this.user.role_level : 0;
    },

    displayName() {
      return this.user ? this.user.full_name : 'Guest';
    },
  },

  methods: {
    /**
     * Attempt login. On success, stores token + user reactively and persists
     * the token to localStorage so the session survives page refresh.
     */
    async login(email, password, rememberMe = false) {
      this.error = null;
      try {
        const { token, user } = await login({ email, password, rememberMe });
        this.token = token;
        this.user = user;
        localStorage.setItem(TOKEN_KEY, token);
        return user;
      } catch (err) {
        this.error = err.message;
        throw err;
      }
    },

    /**
     * Clear session and remove stored token.
     */
    logout() {
      logoutService();
      this.user = null;
      this.token = null;
      this.error = null;
      localStorage.removeItem(TOKEN_KEY);
    },

    /**
     * On app load, check for a stored token and verify it.
     * If valid, restores the session. If expired/invalid, clears it.
     */
    async init() {
      this.initializing = true;
      const stored = localStorage.getItem(TOKEN_KEY);
      if (!stored) {
        this.initializing = false;
        return;
      }

      try {
        const { token, user } = await verifyToken(stored);
        this.token = token;
        this.user = user;
      } catch {
        // Token expired or invalid — clear it
        localStorage.removeItem(TOKEN_KEY);
        this.token = null;
        this.user = null;
      } finally {
        this.initializing = false;
      }
    },
  },
});

export default auth;
