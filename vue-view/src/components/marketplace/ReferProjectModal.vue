<template>
  <div v-if="visible" class="refer-modal__backdrop" @click.self="$emit('close')" @keydown.esc="$emit('close')">
    <div class="refer-modal" role="dialog" aria-label="Refer Project" tabindex="-1" ref="modal">
      <div class="refer-modal__head">
        <h2>Refer Project</h2>
        <p class="refer-modal__subtitle">
          Use this form to create a referral record for {{ recordDetails }}
        </p>
        <button type="button" class="refer-modal__close" @click="$emit('close')" aria-label="Close">&times;</button>
      </div>

      <form class="refer-modal__form" @submit.prevent="handleSubmit">
        <!-- Referral type -->
        <div class="refer-modal__field">
          <label class="refer-modal__label">Referral type <span class="required">*</span></label>
          <div class="refer-modal__radio-group">
            <label class="refer-modal__radio-label">
              <input type="radio" v-model="form.referralType" value="partner" />
              Refer project to Partner
            </label>
            <label class="refer-modal__radio-label">
              <input type="radio" v-model="form.referralType" value="subcontractor" />
              Request Subcontractor Quote
            </label>
          </div>
        </div>

        <!-- Partner dropdown -->
        <div v-if="form.referralType === 'partner'" class="refer-modal__field">
          <label class="refer-modal__label" for="refer-partner">Referral To <span class="required">*</span></label>
          <select id="refer-partner" v-model="form.targetId" class="refer-modal__input">
            <option value="" disabled>Select a partner…</option>
            <option v-for="p in partners" :key="p.id" :value="p.id">{{ p.name }}</option>
          </select>
        </div>

        <!-- Subcontractor dropdown -->
        <div v-if="form.referralType === 'subcontractor'" class="refer-modal__field">
          <label class="refer-modal__label" for="refer-sub">Select Subcontractor <span class="required">*</span></label>
          <select id="refer-sub" v-model="form.targetId" class="refer-modal__input">
            <option value="" disabled>Select a subcontractor…</option>
            <option v-for="s in subcontractors" :key="s.id" :value="s.id">{{ s.name }}</option>
          </select>
        </div>

        <!-- Notes -->
        <div class="refer-modal__field">
          <label class="refer-modal__label" for="refer-notes">Notes / Message</label>
          <textarea
            id="refer-notes"
            v-model="form.notes"
            rows="4"
            class="refer-modal__input refer-modal__textarea"
            placeholder="Optional details, instructions, or context…"
          ></textarea>
        </div>

        <!-- Actions -->
        <div class="refer-modal__actions">
          <button type="button" class="btn btn-cancel" @click="$emit('close')">Cancel</button>
          <button type="submit" class="btn btn-submit" :disabled="!canSubmit">Send Referral</button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
/**
 * ReferProjectModal
 *
 * Modal for referring a project to a partner or requesting a subcontractor quote.
 *
 * Props:
 *   visible         Boolean — controls modal display
 *   recordDetails   String  — details text substituted into subtitle
 *   partners        Array   — [{ id, name }] partner organizations
 *   subcontractors  Array   — [{ id, name }] subcontractor list
 *
 * Emits:
 *   close
 *   submit(payload) — { referralType, targetId, targetType, notes }
 */
export default {
  name: 'ReferProjectModal',
  props: {
    visible: { type: Boolean, default: false },
    recordDetails: { type: String, default: '' },
    partners: { type: Array, default: function() { return []; } },
    subcontractors: { type: Array, default: function() { return []; } }
  },
  data: function() {
    return {
      form: {
        referralType: '',
        targetId: '',
        notes: ''
      }
    };
  },
  computed: {
    canSubmit: function() {
      var hasType = this.form.referralType !== '';
      var hasTarget = this.form.targetId !== '';
      return hasType && hasTarget;
    }
  },
  watch: {
    visible: function(val) {
      if (val) {
        this.resetForm();
        this.$nextTick(function() {
          if (this.$refs.modal) {
            this.$refs.modal.focus();
          }
        });
        document.addEventListener('keydown', this.handleKeydown);
      } else {
        document.removeEventListener('keydown', this.handleKeydown);
      }
    }
  },
  methods: {
    resetForm: function() {
      this.form.referralType = '';
      this.form.targetId = '';
      this.form.notes = '';
    },
    handleKeydown: function(e) {
      if (e.key === 'Escape' && this.visible) {
        this.$emit('close');
      }
    },
    handleSubmit: function() {
      if (!this.canSubmit) {
        return;
      }
      this.$emit('submit', {
        referralType: this.form.referralType,
        targetId: this.form.targetId,
        targetType: this.form.referralType === 'partner' ? 'partner' : 'subcontractor',
        notes: this.form.notes
      });
    }
  }
};
</script>

<style scoped>
/* Backdrop overlay */
.refer-modal__backdrop {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 1000;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
}

/* Modal container */
.refer-modal {
  background: var(--bg-surface, #fff);
  border-radius: var(--border-radius, 8px);
  width: 100%;
  max-width: 520px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.18);
  outline: none;
}

/* Header */
.refer-modal__head {
  padding: 24px 28px 0;
  position: relative;
}
.refer-modal__head h2 {
  margin: 0 0 6px;
  font-size: 1.35rem;
  color: var(--color-primary, #2a5c82);
}
.refer-modal__subtitle {
  margin: 0 0 16px;
  font-size: 0.9rem;
  color: var(--color-text-muted, #6b7280);
  line-height: 1.45;
  padding-right: 36px;
}
.refer-modal__close {
  position: absolute;
  top: 16px;
  right: 16px;
  background: none;
  border: none;
  font-size: 1.6rem;
  line-height: 1;
  color: var(--color-text-muted, #6b7280);
  cursor: pointer;
  padding: 2px 6px;
  border-radius: 4px;
}
.refer-modal__close:hover {
  background: var(--bg-surface-alt, #f3f4f6);
  color: var(--color-text, #333);
}

/* Form */
.refer-modal__form {
  padding: 20px 28px 24px;
}

.refer-modal__field {
  margin-bottom: 18px;
}

.refer-modal__label {
  display: block;
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--color-text, #333);
  margin-bottom: 6px;
}
.refer-modal__label .required {
  color: #dc2626;
  font-weight: 400;
}

/* Radio group */
.refer-modal__radio-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.refer-modal__radio-label {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.9rem;
  color: var(--color-text, #333);
  cursor: pointer;
  padding: 8px 12px;
  border: 1px solid var(--color-border, #e5e7eb);
  border-radius: var(--border-radius, 8px);
  transition: background 0.15s, border-color 0.15s;
}
.refer-modal__radio-label input[type="radio"] {
  accent-color: var(--color-primary, #2a5c82);
}

/* Inputs */
.refer-modal__input {
  width: 100%;
  padding: 10px 12px;
  font-size: 0.9rem;
  font-family: inherit;
  color: var(--color-text, #333);
  background: var(--bg-surface, #fff);
  border: 1px solid var(--color-border, #e5e7eb);
  border-radius: var(--border-radius, 8px);
  outline: none;
  transition: border-color 0.15s;
}
.refer-modal__input:focus {
  border-color: var(--color-primary, #2a5c82);
  box-shadow: 0 0 0 2px rgba(42, 92, 130, 0.12);
}
.refer-modal__textarea {
  resize: vertical;
  min-height: 80px;
}

/* Actions */
.refer-modal__actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding-top: 8px;
  margin-top: 8px;
  border-top: 1px solid var(--color-border, #e5e7eb);
}

.btn {
  padding: 10px 22px;
  font-size: 0.85rem;
  font-weight: 600;
  border-radius: var(--border-radius, 8px);
  cursor: pointer;
  border: 1px solid transparent;
  transition: background 0.15s, border-color 0.15s;
}

.btn-cancel {
  background: var(--bg-surface-alt, #f3f4f6);
  color: var(--color-text, #333);
  border-color: var(--color-border-strong, #d1d5db);
}
.btn-cancel:hover {
  background: var(--color-border, #e5e7eb);
}

.btn-submit {
  background: var(--color-primary, #2a5c82);
  color: #fff;
  border-color: var(--color-primary, #2a5c82);
}
.btn-submit:hover:not(:disabled) {
  background: var(--color-secondary, #1d4665);
  border-color: var(--color-secondary, #1d4665);
}
.btn-submit:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Responsive */
@media (max-width: 600px) {
  .refer-modal__backdrop {
    padding: 12px;
  }
  .refer-modal__head {
    padding: 20px 20px 0;
  }
  .refer-modal__form {
    padding: 16px 20px 20px;
  }
  .refer-modal__actions {
    flex-direction: column-reverse;
  }
  .btn {
    width: 100%;
    text-align: center;
  }
}
</style>
