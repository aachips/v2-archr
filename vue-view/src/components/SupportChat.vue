<!--
  SupportChat — floating bottom-right chat widget.
  "Dumb bot" greeting, collects bug/support info, submits to PHP endpoint.
-->
<template>
  <div class="support-chat">
    <!-- Floating launcher button -->
    <button
      v-if="!open"
      type="button"
      class="chat-launcher"
      aria-label="Get help"
      @click="open = true"
    >
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
        <path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/>
      </svg>
    </button>

    <!-- Chat panel -->
    <div v-if="open" class="chat-panel">
      <div class="chat-head">
        <span>💬 Support</span>
        <button type="button" class="chat-close" @click="open = false">&times;</button>
      </div>

      <!-- Greeting (always shown) -->
      <div class="chat-messages">
        <div class="msg msg--bot">
          <span class="msg-avatar">🤖</span>
          <div class="msg-bubble">
            <p class="msg-greeting">Beep boop. Me dumb robot.</p>
            <p>But a human will read this. Tell me what's wrong and I'll send it to the team.</p>
          </div>
        </div>

        <!-- Confirmation after submit -->
        <div v-if="submitted" class="msg msg--bot">
          <span class="msg-avatar">🤖</span>
          <div class="msg-bubble">
            <p>Beep boop. Ticket #{{ ticketId }} submitted. A human will look at it. Thank you!</p>
          </div>
        </div>

        <!-- User's submitted message -->
        <div v-if="submitted && userMsg" class="msg msg--user">
          <div class="msg-bubble">{{ userMsg }}</div>
        </div>

        <!-- Error -->
        <div v-if="errorMsg" class="msg msg--error">
          <div class="msg-bubble">⚠ {{ errorMsg }}</div>
        </div>
      </div>

      <!-- Form (shown before submit) -->
      <form v-if="!submitted" class="chat-form" @submit.prevent="onSubmit">
        <select v-model="form.category" class="chat-select">
          <option value="bug">🐛 Bug Report</option>
          <option value="feature_request">💡 Feature Request</option>
          <option value="access_issue">🔑 Access Issue</option>
          <option value="data_error">📊 Data Error</option>
          <option value="general">❓ General Support</option>
        </select>

        <input
          v-model.trim="form.subject"
          type="text"
          class="chat-input"
          placeholder="Short subject (optional)"
          maxlength="256"
        />

        <textarea
          v-model.trim="form.description"
          class="chat-textarea"
          placeholder="What happened? What were you trying to do?"
          rows="3"
          required
        ></textarea>

        <button type="submit" class="chat-submit" :disabled="saving || !form.description">
          {{ saving ? 'Sending…' : 'Send to Human →' }}
        </button>
      </form>

      <div v-if="submitted" class="chat-form chat-form--done">
        <button type="button" class="chat-submit" @click="resetForm">
          Submit another request
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { getAuthHeaders } from '../services/authService';

const CHAT_URL = '../app/vue_api/support-chat.php';

export default {
  name: 'SupportChat',
  data() {
    return {
      open: false,
      submitted: false,
      ticketId: null,
      userMsg: '',
      errorMsg: '',
      saving: false,
      form: {
        category: 'general',
        subject: '',
        description: '',
        name: '',
        email: '',
      },
    };
  },

  created() {
    // Pre-fill name/email from auth user
    if (this.$auth && this.$auth.user) {
      this.form.name = this.$auth.user.full_name || '';
      this.form.email = this.$auth.user.email || '';
    }
  },

  methods: {
    async onSubmit() {
      this.errorMsg = '';
      this.saving = true;
      this.userMsg = this.form.description;

      try {
        const res = await fetch(CHAT_URL, {
          method: 'POST',
          headers: getAuthHeaders(),
          body: JSON.stringify({
            action: 'submit',
            category: this.form.category,
            subject: this.form.subject,
            description: this.form.description,
            name: this.form.name,
            email: this.form.email,
          }),
        });

        const data = await res.json();
        if (!res.ok || !data.success) {
          this.errorMsg = data.error || 'Failed to submit. Try again.';
          this.userMsg = '';
          return;
        }

        this.ticketId = data.ticket_id;
        this.submitted = true;
      } catch (err) {
        this.errorMsg = 'Network error. Check your connection and try again.';
        this.userMsg = '';
      } finally {
        this.saving = false;
      }
    },

    resetForm() {
      this.submitted = false;
      this.ticketId = null;
      this.userMsg = '';
      this.errorMsg = '';
      this.form = {
        category: 'general',
        subject: '',
        description: '',
        name: (this.$auth && this.$auth.user && this.$auth.user.full_name) || '',
        email: (this.$auth && this.$auth.user && this.$auth.user.email) || '',
      };
    },
  },
};
</script>

<style scoped>
.support-chat {
  position: fixed;
  bottom: 1rem;
  right: 1rem;
  z-index: 300;
}

/* Launcher button */
.chat-launcher {
  width: 3.25rem;
  height: 3.25rem;
  border-radius: 50%;
  background: #1a56db;
  color: #fff;
  border: none;
  cursor: pointer;
  box-shadow: 0 4px 14px rgba(26, 86, 219, 0.35);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform 0.15s, background 0.15s;
}

.chat-launcher:hover {
  transform: scale(1.08);
  background: #1e40af;
}

.chat-launcher svg {
  width: 22px;
  height: 22px;
}

/* Chat panel */
.chat-panel {
  width: min(22rem, calc(100vw - 2rem));
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.15);
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.chat-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.75rem 1rem;
  background: #1a56db;
  color: #fff;
  font-weight: 600;
  font-size: 0.95rem;
}

.chat-close {
  background: none;
  border: none;
  color: #fff;
  font-size: 1.4rem;
  cursor: pointer;
  padding: 0;
  line-height: 1;
  opacity: 0.8;
}

.chat-close:hover { opacity: 1; }

/* Messages area */
.chat-messages {
  padding: 1rem;
  max-height: 18rem;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.msg {
  display: flex;
  align-items: flex-start;
  gap: 0.5rem;
}

.msg--user {
  flex-direction: row-reverse;
}

.msg-avatar {
  font-size: 1.2rem;
  flex-shrink: 0;
}

.msg-bubble {
  max-width: 85%;
  padding: 0.55rem 0.75rem;
  border-radius: 10px;
  font-size: 0.85rem;
  line-height: 1.45;
}

.msg--bot .msg-bubble {
  background: #f3f4f6;
  color: #1f2937;
  border-bottom-left-radius: 4px;
}

.msg--user .msg-bubble {
  background: #1a56db;
  color: #fff;
  border-bottom-right-radius: 4px;
}

.msg--error .msg-bubble {
  background: #fef2f2;
  color: #b91c1c;
  border: 1px solid #fecaca;
  border-bottom-left-radius: 4px;
}

.msg-greeting {
  font-weight: 600;
  color: #7c3aed;
  margin: 0 0 0.25rem;
}

.msg--bot .msg-bubble p {
  margin: 0;
}

/* Form */
.chat-form {
  padding: 0.75rem;
  border-top: 1px solid #e5e7eb;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.chat-select,
.chat-input,
.chat-textarea {
  padding: 0.45rem 0.6rem;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font: inherit;
  font-size: 0.85rem;
}

.chat-textarea {
  resize: none;
  min-height: 4rem;
}

.chat-select:focus,
.chat-input:focus,
.chat-textarea:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.15);
}

.chat-submit {
  padding: 0.5rem 1rem;
  background: #1a56db;
  color: #fff;
  border: none;
  border-radius: 6px;
  font-size: 0.875rem;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.15s;
}

.chat-submit:hover:not(:disabled) { background: #1e40af; }
.chat-submit:disabled { opacity: 0.5; cursor: not-allowed; }

.chat-form--done {
  border-top: none;
}

/* Mobile: panel goes full-width at very narrow screens */
@media (max-width: 400px) {
  .support-chat {
    bottom: 0;
    right: 0;
    left: 0;
  }

  .chat-panel {
    width: 100%;
    border-radius: 12px 12px 0 0;
    max-height: 75vh;
  }
}
</style>
