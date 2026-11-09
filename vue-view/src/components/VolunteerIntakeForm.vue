<template>
  <div class="volunteer-intake">
    <header class="intake-header">
      <h2>Apply to Volunteer with ARCHR</h2>
      <p class="subtitle">Join our coalition of neighbors helping neighbors. This application takes about 5 minutes.</p>
    </header>

    <!-- Progress bar -->
    <div class="progress-bar" aria-hidden="true">
      <div class="progress-bar-fill" :style="{ width: progressPercent + '%' }"></div>
    </div>

    <form class="intake-form" @submit.prevent="handleSubmit">
      <!-- Page 1: Welcome & Motivation -->
      <section v-show="currentPage === 0" class="page" :class="{ active: currentPage === 0 }">
        <p class="progress">Step 1 of 5 &middot; Welcome</p>

        <p>Thank you for your interest in volunteering with the Asheville Regional Coalition for Home Repair. We're building a community of neighbors helping neighbors.</p>

        <div class="field">
          <label for="motivation">What motivates you to volunteer with ARCHR?</label>
          <textarea id="motivation" v-model="form.motivation" rows="4" placeholder="Tell us a bit about why you want to help..."></textarea>
        </div>

        <div class="field">
          <label for="hearAbout">How did you hear about ARCHR?</label>
          <select id="hearAbout" v-model="form.hearAbout">
            <option value="">-- Select --</option>
            <option value="friend">Friend or family member</option>
            <option value="social-media">Social media</option>
            <option value="organization">Partner organization</option>
            <option value="event">Community event</option>
            <option value="news">News or media coverage</option>
            <option value="other">Other</option>
          </select>
        </div>

        <footer class="actions">
          <span></span>
          <button type="button" @click="goNext">Next</button>
        </footer>
      </section>

      <!-- Page 2: Personal Information -->
      <section v-show="currentPage === 1" class="page" :class="{ active: currentPage === 1 }">
        <p class="progress">Step 2 of 5 &middot; About You</p>

        <div class="field">
          <label for="fullName">Full Name <span class="req">*</span></label>
          <input type="text" id="fullName" v-model="form.fullName" required>
        </div>

        <div class="field">
          <label for="email">Email Address <span class="req">*</span></label>
          <input type="email" id="email" v-model="form.email" required>
        </div>

        <div class="field">
          <label for="phone">Phone Number <span class="req">*</span></label>
          <input type="tel" id="phone" v-model="form.phone" required>
        </div>

        <div class="field">
          <label for="location">General Location / ZIP Code</label>
          <input type="text" id="location" v-model="form.location" placeholder="e.g., Asheville 28801">
        </div>

        <footer class="actions">
          <button type="button" class="secondary" @click="goPrev">Back</button>
          <button type="button" @click="goNext">Next</button>
        </footer>
      </section>

      <!-- Page 3: Skills & Availability -->
      <section v-show="currentPage === 2" class="page" :class="{ active: currentPage === 2 }">
        <p class="progress">Step 3 of 5 &middot; Skills & Availability</p>

        <fieldset class="field">
          <legend>Do you have experience with any of these? (select all that apply)</legend>
          <div class="checkboxes">
            <label><input type="checkbox" value="demo" v-model="form.skills"> Demolition</label>
            <label><input type="checkbox" value="carpentry" v-model="form.skills"> Carpentry</label>
            <label><input type="checkbox" value="roofing" v-model="form.skills"> Roofing</label>
            <label><input type="checkbox" value="painting" v-model="form.skills"> Painting / Drywall</label>
            <label><input type="checkbox" value="landscaping" v-model="form.skills"> Landscaping / Yard work</label>
            <label><input type="checkbox" value="debris" v-model="form.skills"> Debris removal</label>
            <label><input type="checkbox" value="power-tools" v-model="form.skills"> Power tool operation</label>
            <label><input type="checkbox" value="none" v-model="form.skills"> No experience — eager to learn!</label>
          </div>
        </fieldset>

        <fieldset class="field">
          <legend>When are you typically available?</legend>
          <div class="checkboxes">
            <label><input type="checkbox" value="weekday-am" v-model="form.availability"> Weekday mornings</label>
            <label><input type="checkbox" value="weekday-pm" v-model="form.availability"> Weekday afternoons</label>
            <label><input type="checkbox" value="weekend-am" v-model="form.availability"> Weekend mornings</label>
            <label><input type="checkbox" value="weekend-pm" v-model="form.availability"> Weekend afternoons</label>
            <label><input type="checkbox" value="flexible" v-model="form.availability"> Flexible schedule</label>
          </div>
        </fieldset>

        <div class="field">
          <label for="tools">Do you have your own tools or transportation? (optional)</label>
          <textarea id="tools" v-model="form.tools" rows="3" placeholder="e.g., Own truck, basic hand tools, reliable transport..."></textarea>
        </div>

        <footer class="actions">
          <button type="button" class="secondary" @click="goPrev">Back</button>
          <button type="button" @click="goNext">Next</button>
        </footer>
      </section>

      <!-- Page 4: Preferences & Boundaries -->
      <section v-show="currentPage === 3" class="page" :class="{ active: currentPage === 3 }">
        <p class="progress">Step 4 of 5 &middot; Preferences</p>

        <fieldset class="field">
          <legend>What type of volunteer work interests you most?</legend>
          <div class="radios">
            <label><input type="radio" name="interest" value="field" v-model="form.interest"> Field work (build sites, cleanup)</label>
            <label><input type="radio" name="interest" value="office" v-model="form.interest"> Office / administrative support</label>
            <label><input type="radio" name="interest" value="outreach" v-model="form.interest"> Community outreach / phone banking</label>
            <label><input type="radio" name="interest" value="writing" v-model="form.interest"> Writing / storytelling / photography</label>
            <label><input type="radio" name="interest" value="any" v-model="form.interest"> Whatever is needed most</label>
          </div>
        </fieldset>

        <div class="field">
          <label for="limits">Are there any physical limitations or accommodations we should know about? (optional)</label>
          <textarea id="limits" v-model="form.limits" rows="3" placeholder="This helps us match you with suitable tasks..."></textarea>
        </div>

        <div class="field">
          <label for="referral">Were you referred by a current ARCHR volunteer or staff member?</label>
          <input type="text" id="referral" v-model="form.referral" placeholder="Name (optional)">
        </div>

        <footer class="actions">
          <button type="button" class="secondary" @click="goPrev">Back</button>
          <button type="button" @click="goNext">Next</button>
        </footer>
      </section>

      <!-- Page 5: Agreement & Submit -->
      <section v-show="currentPage === 4" class="page" :class="{ active: currentPage === 4 }">
        <p class="progress">Step 5 of 5 &middot; Review & Submit</p>

        <h3>Before You Submit</h3>

        <div class="review-summary">
          <div class="review-row"><span class="review-label">Name:</span> <span class="review-value">{{ form.fullName || '—' }}</span></div>
          <div class="review-row"><span class="review-label">Email:</span> <span class="review-value">{{ form.email || '—' }}</span></div>
          <div class="review-row"><span class="review-label">Phone:</span> <span class="review-value">{{ form.phone || '—' }}</span></div>
          <div class="review-row"><span class="review-label">Skills:</span> <span class="review-value">{{ form.skills.length ? form.skills.join(', ') : 'None selected' }}</span></div>
          <div class="review-row"><span class="review-label">Availability:</span> <span class="review-value">{{ form.availability.length ? form.availability.join(', ') : 'Not specified' }}</span></div>
          <div class="review-row"><span class="review-label">Interest:</span> <span class="review-value">{{ form.interest || 'Not specified' }}</span></div>
        </div>

        <h3>Volunteer Agreement</h3>
        <p>By submitting this application, you acknowledge:</p>
        <ul class="agreement-list">
          <li>ARCHR will review your application and contact you within 5 business days.</li>
          <li>All volunteers must complete a safety orientation before joining field crews.</li>
          <li>Volunteer hours are logged and tracked through the ARCHR dashboard once your account is activated.</li>
          <li>ARCHR respects your privacy — personal information is shared only with the partner organization coordinating your volunteer activities.</li>
        </ul>

        <div class="field">
          <label><input type="checkbox" v-model="form.agree"> I agree to the terms above and authorize ARCHR to process my application.</label>
        </div>

        <footer class="actions">
          <button type="button" class="secondary" @click="goPrev">Back</button>
          <button type="submit" :disabled="!form.agree || submitting" class="submit-btn">
            {{ submitting ? 'Submitting...' : 'Submit Application' }}
          </button>
        </footer>
      </section>

      <!-- Success State -->
      <section v-if="submitted" class="page success-page">
        <div class="success-message">
          <span class="success-icon">✓</span>
          <h2>Application Submitted!</h2>
          <p>Thank you for stepping up to help your community. An ARCHR administrator will review your application and reach out within 5 business days.</p>
          <p>Once approved, you'll receive access to the Volunteer Dashboard where you can browse opportunities, log hours, and track your impact.</p>
        </div>
      </section>
    </form>
  </div>
</template>

<script>
export default {
  name: 'VolunteerIntakeForm',
  data() {
    return {
      currentPage: 0,
      submitting: false,
      submitted: false,
      form: {
        motivation: '',
        hearAbout: '',
        fullName: '',
        email: '',
        phone: '',
        location: '',
        skills: [],
        availability: [],
        tools: '',
        interest: '',
        limits: '',
        referral: '',
        agree: false,
      },
    };
  },
  computed: {
    totalPages() {
      return 5;
    },
    progressPercent() {
      return ((this.currentPage + 1) / this.totalPages) * 100;
    },
  },
  methods: {
    goNext() {
      if (this.currentPage < this.totalPages - 1) {
        this.currentPage++;
      }
    },
    goPrev() {
      if (this.currentPage > 0) {
        this.currentPage--;
      }
    },
    async handleSubmit() {
      if (!this.form.agree) return;
      this.submitting = true;

      try {
        const res = await fetch('/app/vue_api/volunteer-intake-submit.php', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(this.form),
        });
        const result = await res.json();
        if (!result.success) {
          alert('Submission failed: ' + (result.error || 'Unknown error'));
          return;
        }
        this.submitted = true;
      } catch (e) {
        console.error('Submission failed:', e);
        alert('Submission failed. Please try again.');
      } finally {
        this.submitting = false;
      }
    },
  },
};
</script>

<style scoped>
.volunteer-intake {
  max-width: 720px;
  margin: 0 auto;
  padding: 1.5rem;
}

.intake-header h2 {
  font-size: 1.5rem;
  color: var(--color-text, #1a1a2e);
  margin: 0 0 0.25rem;
}

.subtitle {
  color: var(--color-text-secondary, #666);
  margin: 0;
  font-size: 0.95rem;
}

/* Progress bar */
.progress-bar {
  height: 6px;
  background: var(--color-border, #e2e8f0);
  border-radius: 3px;
  margin: 1rem 0 1.5rem;
  overflow: hidden;
}

.progress-bar-fill {
  height: 100%;
  background: var(--color-accent, #2563eb);
  border-radius: 3px;
  transition: width 0.3s ease;
}

/* Pages */
.page {
  animation: fadeIn 0.3s ease;
}

.page.active {
  display: block;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(8px); }
  to { opacity: 1; transform: translateY(0); }
}

.progress {
  font-size: 0.85rem;
  color: var(--color-text-secondary, #64748b);
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

/* Form fields */
.field {
  margin-bottom: 1.25rem;
}

.field label {
  display: block;
  font-weight: 600;
  font-size: 0.9rem;
  color: var(--color-text, #1a1a2e);
  margin-bottom: 0.35rem;
}

.field input[type="text"],
.field input[type="email"],
.field input[type="tel"],
.field select,
.field textarea {
  width: 100%;
  padding: 0.6rem 0.75rem;
  border: 1px solid var(--color-border, #e2e8f0);
  border-radius: 6px;
  font-size: 0.95rem;
  font-family: inherit;
  background: var(--color-surface, #fff);
  color: var(--color-text, #1a1a2e);
  transition: border-color 0.2s;
}

.field input:focus,
.field select:focus,
.field textarea:focus {
  outline: none;
  border-color: var(--color-accent, #2563eb);
  box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
}

.field textarea {
  resize: vertical;
  min-height: 80px;
}

.req {
  color: var(--color-danger, #dc2626);
}

/* Checkboxes and radios */
.checkboxes,
.radios {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin-top: 0.35rem;
}

.checkboxes label,
.radios label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 400;
  cursor: pointer;
}

fieldset.field {
  border: none;
  padding: 0;
  margin: 0 0 1.25rem;
}

fieldset.field > legend {
  font-weight: 600;
  font-size: 0.9rem;
  color: var(--color-text, #1a1a2e);
  margin-bottom: 0.5rem;
}

/* Action buttons */
.actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
  padding-top: 1rem;
  border-top: 1px solid var(--color-border, #e2e8f0);
  margin-top: 1.5rem;
}

.actions button {
  padding: 0.6rem 1.5rem;
  border-radius: 6px;
  font-weight: 600;
  font-size: 0.95rem;
  cursor: pointer;
  border: none;
  transition: background 0.2s, transform 0.1s;
}

.actions button[type="button"],
.actions button[type="submit"] {
  background: var(--color-accent, #2563eb);
  color: #fff;
}

.actions button[type="button"]:hover,
.actions button[type="submit"]:hover:not(:disabled) {
  background: #1d4ed8;
}

.actions button[type="submit"]:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.actions button.secondary {
  background: var(--color-surface-alt, #f1f5f9);
  color: var(--color-text, #1a1a2e);
  border: 1px solid var(--color-border, #e2e8f0);
}

.actions button.secondary:hover {
  background: #e2e8f0;
}

/* Review summary */
.review-summary {
  background: var(--color-surface-alt, #f8fafc);
  border: 1px solid var(--color-border, #e2e8f0);
  border-radius: 8px;
  padding: 1rem;
  margin-bottom: 1.25rem;
}

.review-row {
  display: flex;
  justify-content: space-between;
  padding: 0.4rem 0;
  border-bottom: 1px dashed var(--color-border, #e2e8f0);
  font-size: 0.9rem;
}

.review-row:last-child {
  border-bottom: none;
}

.review-label {
  font-weight: 600;
  color: var(--color-text-secondary, #64748b);
}

.review-value {
  color: var(--color-text, #1a1a2e);
  text-align: right;
  max-width: 60%;
}

/* Agreement */
.agreement-list {
  padding-left: 1.25rem;
  margin: 0.75rem 0;
  font-size: 0.9rem;
  color: var(--color-text, #1a1a2e);
}

.agreement-list li {
  margin-bottom: 0.35rem;
}

/* Success state */
.success-page {
  text-align: center;
  padding: 2rem 1rem;
}

.success-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 64px;
  height: 64px;
  border-radius: 50%;
  background: #22c55e;
  color: #fff;
  font-size: 2rem;
  font-weight: 700;
  margin-bottom: 1rem;
}

.success-message h2 {
  color: var(--color-text, #1a1a2e);
  margin: 0 0 0.5rem;
}

.success-message p {
  color: var(--color-text, #1a1a2e);
  max-width: 500px;
  margin: 0 auto;
  line-height: 1.6;
}

.submit-btn {
  min-width: 180px;
}
</style>
