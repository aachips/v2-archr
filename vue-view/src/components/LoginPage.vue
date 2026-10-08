<!--
  LoginPage — simple email/password form that calls the PHP auth bridge.
  Shown when the user is not authenticated.
-->
<template>
  <div class="login-page">
    <div class="login-card">
      <div class="login-card__brand">
        <img src="../assets/archr-logo.svg" alt="" class="login-card__logo" />
        <h1>ARCHR</h1>
        <p class="login-card__subtitle">Asheville Regional Coalition for Home Repair</p>
      </div>

      <form class="login-form" @submit.prevent="handleSubmit">
        <div v-if="error" class="login-form__error" role="alert">
          {{ error }}
        </div>

        <label class="field" for="email">
          Email or Username
          <input
            id="email"
            v-model.trim="email"
            type="text"
            placeholder="you@example.com"
            autocomplete="username"
            required
            autofocus
          />
        </label>

        <label class="field" for="password">
          Password
          <input
            id="password"
            v-model="password"
            type="password"
            placeholder="Your password"
            autocomplete="current-password"
            required
          />
        </label>

        <label class="field field--check" for="remember">
          <input id="remember" v-model="rememberMe" type="checkbox" />
          <span>Stay logged in for 30 days</span>
        </label>

        <button type="submit" class="login-btn" :disabled="pending">
          {{ pending ? 'Signing in…' : 'Sign In' }}
        </button>
      </form>

      <p class="login-card__footer">
        Don't have an account? Contact your organization's administrator.
      </p>

      <p class="login-card__forgot">
        Forgot your password? Contact the ARCHR Super Admin to reset it.
      </p>

      <div class="login-card__nav">
        <a href="../" class="nav-link"><i class="fas fa-arrow-left"></i> Back to ARCHR</a>
        <span class="nav-divider">|</span>
        <a href="../landing.html" class="nav-link"><i class="fas fa-play-circle"></i> View Demo</a>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'LoginPage',

  data() {
    return {
      email: '',
      password: '',
      rememberMe: false,
      pending: false,
      error: '',
    };
  },

  async created() {
    // If already logged in (from a previous session), skip straight to the app
    if (this.$auth.isLoggedIn) {
      this.$emit('logged-in');
    }
  },

  methods: {
    async handleSubmit() {
      this.error = '';
      this.pending = true;

      try {
        await this.$auth.login(this.email, this.password, this.rememberMe);
        this.$emit('logged-in');
      } catch (err) {
        this.error = err.message;
      } finally {
        this.pending = false;
      }
    },
  },
};
</script>

<style scoped>
.login-page {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  background: #f5f5f5;
  padding: 1rem;
}

.login-card {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  padding: 2.5rem 2rem;
  max-width: 400px;
  width: 100%;
}

.login-card__nav {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  margin-top: 1rem;
  padding-top: 0.75rem;
  border-top: 1px solid #e5e7eb;
  font-size: 0.8rem;
}

.nav-link {
  color: #2166b7;
  text-decoration: none;
  font-weight: 500;
}

.nav-link:hover {
  text-decoration: underline;
}

.nav-divider {
  color: #d1d5db;
}

.login-card__brand {
  text-align: center;
  margin-bottom: 1.5rem;
}

.login-card__logo {
  width: 48px;
  height: 48px;
  margin-bottom: 0.5rem;
}

.login-card__brand h1 {
  font-size: 1.5rem;
  margin: 0 0 0.25rem;
  color: #1a1a1a;
}

.login-card__subtitle {
  font-size: 0.85rem;
  color: #666;
  margin: 0;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.login-form__error {
  background: #fef2f2;
  color: #b91c1c;
  border: 1px solid #fecaca;
  border-radius: 6px;
  padding: 0.5rem 0.75rem;
  font-size: 0.875rem;
}

.field {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  font-size: 0.875rem;
  font-weight: 500;
  color: #333;
}

.field input[type="text"],
.field input[type="password"] {
  padding: 0.5rem 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 0.95rem;
  transition: border-color 0.15s;
}

.field input:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.15);
}

.field--check {
  flex-direction: row;
  align-items: center;
  gap: 0.5rem;
}

.field--check input {
  margin: 0;
}

.login-btn {
  background: #1a56db;
  color: #fff;
  border: none;
  border-radius: 6px;
  padding: 0.6rem 1rem;
  font-size: 0.95rem;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.15s;
}

.login-btn:hover:not(:disabled) {
  background: #1e40af;
}

.login-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.login-card__footer {
  text-align: center;
  font-size: 0.8rem;
  color: #888;
  margin-top: 1.5rem;
}

.login-card__forgot {
  text-align: center;
  font-size: 0.78rem;
  color: #b91c1c;
  margin: 0.5rem 0 0;
}
</style>
