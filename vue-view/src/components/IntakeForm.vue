<template>
  <div class="app-shell">
    <!-- Brand header -->
    <header class="brand">
      <div class="lettermark" aria-hidden="true">A</div>
      <div class="titles">
        <h1 id="app-title">Asheville Regional Coalition for Home Repair</h1>
        <p class="subtitle">Home Repair Services Screening Form</p>
      </div>
      <div class="lang-switch" role="group" aria-label="Language switcher">
        <button type="button" :class="{ active: lang === 'eng' }" @click="lang = 'eng'" :aria-pressed="lang === 'eng'">EN</button>
        <button type="button" :class="{ active: lang === 'esp' }" @click="lang = 'esp'" :aria-pressed="lang === 'esp'">ES</button>
      </div>
    </header>

    <!-- Progress bar -->
    <div class="progress-bar" aria-hidden="true">
      <div class="progress-bar-fill" :style="{ width: progressWidth + '%' }"></div>
    </div>

    <main>
      <!-- Page 1: Welcome -->
      <section v-show="currentPage === 0" class="page" :class="{ active: currentPage === 0 }">
        <p class="progress" v-html="t('Step 1') + ' &middot; ' + t('Welcome')"></p>
        <p>{{ t('Use the EN / ES toggle at the top of the page at any time to switch between English and Spanish.') }}</p>

        <fieldset class="field">
          <legend>{{ t('Are you submitting this on behalf of someone else as a referral?') }}</legend>
          <div class="radios">
            <label><input type="radio" name="isReferral" value="yes" v-model="formData.isReferral"> <span>{{ t('Yes, I am referring someone') }}</span></label>
            <label><input type="radio" name="isReferral" value="no" v-model="formData.isReferral"> <span>{{ t('No, I am the applicant') }}</span></label>
          </div>
        </fieldset>

        <footer class="actions">
          <span></span>
          <button type="button" data-next @click="goNext">{{ t('Next') }}</button>
        </footer>
      </section>

      <!-- Page 2: Consent -->
      <section v-show="currentPage === 1" class="page" :class="{ active: currentPage === 1 }">
        <p class="progress" v-html="'Step 2' + ' &middot; ' + t('About this form')"></p>
        <h2>{{ t('Screening Form') }}</h2>
        <p>{{ t('This screening form will screen you for eligibility to apply for home repair services at any organization within the ARCHR partnership, which includes:') }}</p>
        <ul class="plain">
          <li>Asheville Habitat for Humanity</li>
          <li>Community Action Opportunities</li>
          <li>PODER Emma</li>
          <li>Asheville Buncombe Community Land Trust</li>
          <li>Mountain Housing Opportunities</li>
          <li>Community Housing Coalition of Madison County</li>
        </ul>

        <h3>{{ t('Data Confidentiality') }}</h3>
        <p>{{ t('This screening tool requests information about your home repair needs. This information will be shared with the organizations of ARCHR (Asheville Regional Coalition for Home Repair).') }}</p>
        <p>{{ t('These organizations support offering necessary repairs, accessibility modifications, and weatherization assistance to Western North Carolina homeowners.') }}</p>
        <p>{{ t('Because of complex eligibility criteria and funding availability across repair organizations, this screening tool helps our organizations identify which one of us is best able to serve you, preventing you from filling out applications for organizations that cannot serve you in the end.') }}</p>
        <p>{{ t('By submitting this form, you are agreeing to submit this screening and associated information to the organizations of the Asheville Regional Coalition for Home Repair so that we can work together to better serve you. Information will never be shared outside of the ARCHR organizations.') }}</p>
        <p>{{ t('If you meet the initial criteria, staff from ARCHR will contact you by telephone to set up a home visit to assess the requested repairs and report back to the coalition.') }}</p>

        <div class="field">
          <label><input type="checkbox" name="consentAgree" value="yes" v-model="formData.consentAgree"> {{ t('I agree to the data sharing terms above.') }}</label>
        </div>

        <footer class="actions">
          <button type="button" class="secondary" data-prev @click="goPrev">{{ t('Back') }}</button>
          <button type="button" data-next @click="goNext">{{ t('Next') }}</button>
        </footer>
      </section>

      <!-- Page 3: Referrer (conditional) -->
      <section v-show="currentPage === 2" class="page" :class="{ active: currentPage === 2 }">
        <p class="progress">{{ t('Referral submission') }}</p>
        <h2>{{ t('Submit referral') }}</h2>
        <p>{{ t('Tell us who is submitting this referral on behalf of the applicant.') }}</p>

        <div class="field">
          <label for="referrerName">{{ t('Your name') }} <span class="req">*</span></label>
          <input type="text" id="referrerName" v-model="formData.referrerName">
        </div>
        <div class="field">
          <label for="referrerOrganization">{{ t('Your organization') }}</label>
          <input type="text" id="referrerOrganization" v-model="formData.referrerOrganization">
        </div>
        <div class="field">
          <label for="referrerEmail">{{ t('Your email') }} <span class="req">*</span></label>
          <input type="email" id="referrerEmail" v-model="formData.referrerEmail">
        </div>
        <div class="field">
          <label for="referrerNotes">{{ t('Referral notes') }}</label>
          <textarea id="referrerNotes" v-model="formData.referrerNotes"></textarea>
        </div>

        <footer class="actions">
          <button type="button" class="secondary" data-prev @click="goPrev">{{ t('Back') }}</button>
          <button type="button" data-next @click="goNext">{{ t('Next') }}</button>
        </footer>
      </section>

      <!-- Submission result page -->
      <section v-show="submitted" class="page active">
        <h2>{{ t('Submission Received') }}</h2>
        <div v-if="submitError" class="error-msg">
          <p>{{ submitError }}</p>
        </div>
        <div v-else>
          <p>{{ t('Thank you! Your submission has been received.') }}</p>
          <p v-if="resultData.display_ref">{{ t('Reference') }}: <strong>{{ resultData.display_ref }}</strong></p>
          <div v-if="resultData.credentials" class="credentials-box">
            <h3>{{ t('Your Account Credentials') }}</h3>
            <p><strong>{{ t('Username') }}:</strong> {{ resultData.credentials.username }}</p>
            <p><strong>{{ t('Password') }}:</strong> {{ resultData.credentials.password }}</p>
            <p class="muted">{{ t('Save these credentials — you will need them to access your dashboard.') }}</p>
          </div>
          <p v-if="resultData.dashboard_url">
            <a :href="resultData.dashboard_url">{{ t('Go to your dashboard') }}</a>
          </p>
        </div>
      </section>
    </main>
  </div>
</template>

<script>
// Minimal translation map — matches the original intake.js language dictionary.
// Only Pages 1-3 are populated here; extend as more pages are added.
const translations = {
  eng: {
    'Step 1': 'Step 1',
    'Welcome': 'Welcome',
    'Use the EN / ES toggle at the top of the page at any time to switch between English and Spanish.': 'Use the EN / ES toggle at the top of the page at any time to switch between English and Spanish.',
    'Are you submitting this on behalf of someone else as a referral?': 'Are you submitting this on behalf of someone else as a referral?',
    'Yes, I am referring someone': 'Yes, I am referring someone',
    'No, I am the applicant': 'No, I am the applicant',
    'Next': 'Next',
    'Back': 'Back',
    'About this form': 'About this form',
    'Screening Form': 'Screening Form',
    'This screening form will screen you for eligibility to apply for home repair services at any organization within the ARCHR partnership, which includes:': 'This screening form will screen you for eligibility to apply for home repair services at any organization within the ARCHR partnership, which includes:',
    'Data Confidentiality': 'Data Confidentiality',
    'This screening tool requests information about your home repair needs. This information will be shared with the organizations of ARCHR (Asheville Regional Coalition for Home Repair).': 'This screening tool requests information about your home repair needs. This information will be shared with the organizations of ARCHR (Asheville Regional Coalition for Home Repair).',
    'These organizations support offering necessary repairs, accessibility modifications, and weatherization assistance to Western North Carolina homeowners.': 'These organizations support offering necessary repairs, accessibility modifications, and weatherization assistance to Western North Carolina homeowners.',
    'Because of complex eligibility criteria and funding availability across repair organizations, this screening tool helps our organizations identify which one of us is best able to serve you, preventing you from filling out applications for organizations that cannot serve you in the end.': 'Because of complex eligibility criteria and funding availability across repair organizations, this screening tool helps our organizations identify which one of us is best able to serve you, preventing you from filling out applications for organizations that cannot serve you in the end.',
    'By submitting this form, you are agreeing to submit this screening and associated information to the organizations of the Asheville Regional Coalition for Home Repair so that we can work together to better serve you. Information will never be shared outside of the ARCHR organizations.': 'By submitting this form, you are agreeing to submit this screening and associated information to the organizations of the Asheville Regional Coalition for Home Repair so that we can work together to better serve you. Information will never be shared outside of the ARCHR organizations.',
    'If you meet the initial criteria, staff from ARCHR will contact you by telephone to set up a home visit to assess the requested repairs and report back to the coalition.': 'If you meet the initial criteria, staff from ARCHR will contact you by telephone to set up a home visit to assess the requested repairs and report back to the coalition.',
    'I agree to the data sharing terms above.': 'I agree to the data sharing terms above.',
    'Referral submission': 'Referral submission',
    'Submit referral': 'Submit referral',
    'Tell us who is submitting this referral on behalf of the applicant.': 'Tell us who is submitting this referral on behalf of the applicant.',
    'Your name': 'Your name',
    'Your organization': 'Your organization',
    'Your email': 'Your email',
    'Referral notes': 'Referral notes',
    'Submission Received': 'Submission Received',
    'Thank you! Your submission has been received.': 'Thank you! Your submission has been received.',
    'Reference': 'Reference',
    'Your Account Credentials': 'Your Account Credentials',
    'Username': 'Username',
    'Password': 'Password',
    'Save these credentials — you will need them to access your dashboard.': 'Save these credentials — you will need them to access your dashboard.',
    'Go to your dashboard': 'Go to your dashboard',
  },
  esp: {
    'Step 1': 'Paso 1',
    'Welcome': 'Bienvenido',
    'Use the EN / ES toggle at the top of the page at any time to switch between English and Spanish.': 'Use el botón EN / ES en la parte superior de la página en cualquier momento para cambiar entre inglés y español.',
    'Are you submitting this on behalf of someone else as a referral?': '¿Está enviando esto en nombre de otra persona como referencia?',
    'Yes, I am referring someone': 'Sí, estoy refiriendo a alguien',
    'No, I am the applicant': 'No, soy el solicitante',
    'Next': 'Siguiente',
    'Back': 'Atrás',
    'About this form': 'Acerca de este formulario',
    'Screening Form': 'Formulario de screening',
    'This screening form will screen you for eligibility to apply for home repair services at any organization within the ARCHR partnership, which includes:': 'Este formulario de screening le permitirá evaluar su elegibilidad para solicitar servicios de reparación de viviendas en cualquier organización dentro de la asociación ARCHR, que incluye:',
    'Data Confidentiality': 'Confidencialidad de datos',
    'This screening tool requests information about your home repair needs. This information will be shared with the organizations of ARCHR (Asheville Regional Coalition for Home Repair).': 'Esta herramienta solicita información sobre sus necesidades de reparación del hogar. Esta información será compartida con las organizaciones de ARCHR.',
    'These organizations support offering necessary repairs, accessibility modifications, and weatherization assistance to Western North Carolina homeowners.': 'Estas organizaciones apoyan ofrecer reparaciones necesarias, modificaciones de accesibilidad y asistencia de climatización a propietarios del oeste de Carolina del Norte.',
    'Because of complex eligibility criteria and funding availability across repair organizations, this screening tool helps our organizations identify which one of us is best able to serve you, preventing you from filling out applications for organizations that cannot serve you in the end.': 'Debido a criterios complejos de elegibilidad y disponibilidad de fondos, esta herramienta ayuda a identificar cuál de nosotros puede servirle mejor.',
    'By submitting this form, you are agreeing to submit this screening and associated information to the organizations of the Asheville Regional Coalition for Home Repair so that we can work together to better serve you. Information will never be shared outside of the ARCHR organizations.': 'Al enviar este formulario, usted acepta enviar este screening e información asociada a las organizaciones de ARCHR. La información nunca será compartida fuera de las organizaciones ARCHR.',
    'If you meet the initial criteria, staff from ARCHR will contact you by telephone to set up a home visit to assess the requested repairs and report back to the coalition.': 'Si cumple con los criterios iniciales, el personal de ARCHR se comunicará con usted por teléfono para programar una visita a domicilio.',
    'I agree to the data sharing terms above.': 'Acepto los términos de intercambio de datos anteriores.',
    'Referral submission': 'Envío de referencia',
    'Submit referral': 'Enviar referencia',
    'Tell us who is submitting this referral on behalf of the applicant.': 'Díganos quién está enviando esta referencia en nombre del solicitante.',
    'Your name': 'Su nombre',
    'Your organization': 'Su organización',
    'Your email': 'Su correo electrónico',
    'Referral notes': 'Notas de referencia',
    'Submission Received': 'Envío recibido',
    'Thank you! Your submission has been received.': '¡Gracias! Su envío ha sido recibido.',
    'Reference': 'Referencia',
    'Your Account Credentials': 'Sus credenciales de cuenta',
    'Username': 'Nombre de usuario',
    'Password': 'Contraseña',
    'Save these credentials — you will need them to access your dashboard.': 'Guarde estas credenciales — las necesitará para acceder a su panel.',
    'Go to your dashboard': 'Ir a su panel',
  },
};

export default {
  name: 'IntakeForm',
  data() {
    return {
      lang: 'eng',
      currentPage: 0,
      submitted: false,
      submitError: '',
      resultData: {},
      formData: {
        isReferral: '',
        consentAgree: false,
        referrerName: '',
        referrerOrganization: '',
        referrerEmail: '',
        referrerNotes: '',
      },
    };
  },
  computed: {
    /** Number of visible pages (depends on isReferral) */
    visiblePages() {
      const pages = [0, 1]; // Page 1 (welcome), Page 2 (consent) always visible
      if (this.formData.isReferral === 'yes') {
        pages.push(2); // Page 3 (referrer)
      }
      return pages;
    },
    /** Which page index we're on within visiblePages */
    visibleIndex() {
      return this.visiblePages.indexOf(this.currentPage);
    },
    progressWidth() {
      const total = this.visiblePages.length;
      const idx = this.visibleIndex;
      return total > 0 ? ((idx + 1) / total) * 100 : 0;
    },
  },
  methods: {
    t(key) {
      return (translations[this.lang] && translations[this.lang][key]) || key;
    },

    /** Validation for the current page */
    validatePage(pageIndex) {
      // Page 1 (welcome): must select isReferral
      if (pageIndex === 0) {
        if (!this.formData.isReferral) {
          alert(this.t('Please select an option.'));
          return false;
        }
      }
      // Page 2 (consent): must check consent
      if (pageIndex === 1) {
        if (!this.formData.consentAgree) {
          alert(this.t('Please agree to the data sharing terms to continue.'));
          return false;
        }
      }
      // Page 3 (referrer): conditional, requires name + email
      if (this.visiblePages[pageIndex] === 2) {
        if (!this.formData.referrerName) {
          alert(this.t('Your name') + ' is required.');
          return false;
        }
        if (!this.formData.referrerEmail) {
          alert(this.t('Your email') + ' is required.');
          return false;
        }
      }
      return true;
    },

    goNext() {
      if (!this.validatePage(this.visibleIndex)) return;

      const nextIdx = this.visibleIndex + 1;
      if (nextIdx >= this.visiblePages.length) {
        // No more pages — submit
        this.submitForm();
        return;
      }
      this.currentPage = this.visiblePages[nextIdx];
    },

    goPrev() {
      const prevIdx = this.visibleIndex - 1;
      if (prevIdx < 0) return;
      this.currentPage = this.visiblePages[prevIdx];
    },

    async submitForm() {
      const payload = {
        language: this.lang,
        isReferral: this.formData.isReferral,
        consentAgree: this.formData.consentAgree ? 'yes' : 'no',
        referrerName: this.formData.referrerName,
        referrerOrganization: this.formData.referrerOrganization,
        referrerEmail: this.formData.referrerEmail,
        referrerNotes: this.formData.referrerNotes,
      };

      try {
        const res = await fetch('api/submit.php', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload),
        });
        const data = await res.json();
        if (data.success) {
          this.resultData = data;
          this.submitted = true;
        } else {
          this.submitError = data.error || 'Submission failed.';
        }
      } catch (err) {
        this.submitError = 'Network error: ' + err.message;
      }
    },
  },
};
</script>

<style scoped>
/* ===========================================================================
  ARCHR intake form — component styles (mirrors app/assets/intake.css)
  =========================================================================== */

:root {
  --max: 900px;
  --bg: #000;
  --shell-bg: #111;
  --field-bg: #1d1d1d;
  --border: #2e2e2e;
  --border-strong: #555;
  --text: #f0f0f0;
  --muted: #999;
  --accent: #fff;
  --req: #ff7a7a;
}

* {
  box-sizing: border-box;
}

.app-shell {
  max-width: var(--max);
  width: min(96vw, var(--max));
  margin: 2vh auto;
  background: var(--shell-bg);
  border: 1px solid var(--border);
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.6);
  display: flex;
  flex-direction: column;
  min-height: 90vh;
}

/* Brand header */
header.brand {
  display: grid;
  grid-template-columns: auto 1fr auto;
  align-items: center;
  gap: 1rem;
  padding: 1.5rem 2rem;
  border-bottom: 1px solid var(--border);
}

.lettermark {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: var(--accent);
  color: var(--bg);
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 1.5rem;
}

.titles h1 {
  margin: 0;
  font-size: 1.15rem;
  font-weight: 600;
  line-height: 1.2;
}

.subtitle {
  margin: 0.15rem 0 0;
  font-size: 0.85rem;
  color: var(--muted);
}

.lang-switch {
  display: flex;
  gap: 0.25rem;
}

.lang-switch button {
  padding: 0.3rem 0.6rem;
  border: 1px solid var(--border-strong);
  border-radius: 4px;
  background: transparent;
  color: var(--muted);
  cursor: pointer;
  font-size: 0.8rem;
  font-weight: 600;
}

.lang-switch button.active {
  background: var(--accent);
  color: var(--bg);
  border-color: var(--accent);
}

/* Progress bar */
.progress-bar {
  height: 4px;
  background: var(--border);
}

.progress-bar-fill {
  height: 100%;
  background: var(--accent);
  transition: width 0.3s ease;
}

/* Main scroll area */
main {
  flex: 1;
  overflow-y: auto;
  padding: 1.5rem 2rem;
}

.page {
  display: none;
}

.page.active {
  display: block;
}

.progress {
  color: var(--muted);
  font-size: 0.85rem;
  margin: 0 0 1rem;
}

h2 {
  margin: 0 0 1rem;
  font-size: 1.25rem;
}

h3 {
  margin: 1.5rem 0 0.5rem;
  font-size: 1.05rem;
}

ul.plain {
  list-style: disc;
  padding-left: 1.5rem;
  margin: 0.5rem 0 1rem;
}

/* Fields */
.field {
  margin-bottom: 1rem;
}

.field legend {
  font-weight: 600;
  margin-bottom: 0.5rem;
  display: block;
}

.field label {
  display: block;
  margin-bottom: 0.25rem;
  font-weight: 500;
}

.field input[type="text"],
.field input[type="email"],
.field input[type="date"],
.field textarea {
  width: 100%;
  padding: 0.5rem 0.75rem;
  background: var(--field-bg);
  border: 1px solid var(--border-strong);
  border-radius: 4px;
  color: var(--text);
  font-size: 0.95rem;
  font-family: inherit;
}

.field textarea {
  min-height: 80px;
  resize: vertical;
}

.radios label,
.checks label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.35rem;
  font-weight: 400;
}

.req {
  color: var(--req);
}

/* Action footer */
footer.actions {
  display: grid;
  grid-template-columns: 1fr auto;
  gap: 1rem;
  align-items: center;
  margin-top: 1.5rem;
  padding-top: 1rem;
  border-top: 1px solid var(--border);
}

footer.actions button {
  padding: 0.6rem 1.5rem;
  border: 1px solid var(--accent);
  border-radius: 4px;
  background: var(--accent);
  color: var(--bg);
  font-weight: 600;
  cursor: pointer;
  font-size: 0.95rem;
}

footer.actions button.secondary {
  background: transparent;
  color: var(--accent);
}

footer.actions button:hover {
  opacity: 0.85;
}

/* Credentials box */
.credentials-box {
  background: var(--field-bg);
  border: 1px solid var(--border-strong);
  border-radius: 6px;
  padding: 1rem;
  margin: 1rem 0;
}

.credentials-box h3 {
  margin: 0 0 0.75rem;
}

.credentials-box .muted {
  color: var(--muted);
  font-size: 0.85rem;
}

.error-msg {
  color: var(--req);
  font-weight: 600;
}

a {
  color: var(--accent);
}

/* Responsive */
@media (max-width: 640px) {
  .app-shell {
    margin: 0;
    border-radius: 0;
    min-height: 100vh;
  }
  header.brand {
    padding: 1rem;
    grid-template-columns: 1fr;
    text-align: center;
  }
  .lettermark {
    margin: 0 auto;
  }
  .lang-switch {
    justify-content: center;
  }
  main {
    padding: 1rem;
  }
}
</style>
