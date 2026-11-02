
**Goal:** Make the ARCHR platform available in English (default), Spanish, Ukrainian, and Arabic, with a simple translation system that non-technical translators can maintain.

**Approach:** Centralized translation files (JSON/JavaScript) with a language switcher, dynamic content replacement, and RTL support for Arabic.

**Timeline:** Foundation → Spanish → Ukrainian → Arabic

---

## Core Architecture

### Translation Pattern (Familiar and Maintainable)

javascript

// translations.js - Single source of truth for all static text
const translations = {
    'en': {
        // Navigation
        'nav.dashboard': 'Dashboard',
        'nav.applications': 'Applications',
        'nav.tasks': 'Tasks, Logs & Events',
        
        // Common
        'common.save': 'Save',
        'common.cancel': 'Cancel',
        'common.delete': 'Delete',
        'common.continue': 'Continue',
        'common.back': 'Back',
        'common.next': 'Next',
        'common.submit': 'Submit',
        
        // Dashboard
        'dashboard.welcome': 'Welcome back, {name}',
        'dashboard.last_application': 'Last Application',
        'dashboard.next_step': 'Next Step',
        'dashboard.holding_on': 'Holding On',
        
        // Bursar specific
        'bursar.total_approved': 'Total Approved',
        'bursar.pending_reimbursement': 'Pending Reimbursement',
        'bursar.reimbursed_to_date': 'Reimbursed to Date',
        'bursar.on_hold': 'On Hold',
        
        // ... thousands more strings
    },
    'es': {
        'nav.dashboard': 'Panel de Control',
        'nav.applications': 'Solicitudes',
        'nav.tasks': 'Tareas, Registros y Eventos',
        'common.save': 'Guardar',
        'common.cancel': 'Cancelar',
        'common.delete': 'Eliminar',
        'common.continue': 'Continuar',
        'common.back': 'Atrás',
        'common.next': 'Siguiente',
        'common.submit': 'Enviar',
        'dashboard.welcome': 'Bienvenido de nuevo, {name}',
        // ... Spanish translations
    },
    'uk': {
        // Ukrainian translations
    },
    'ar': {
        // Arabic translations (RTL)
    }
};
// Translation function
function t(key, params = {}) {
    const lang = getCurrentLanguage();
    let text = translations[lang]?.[key] || translations['en'][key] || key;
    
    // Replace parameters
    Object.keys(params).forEach(param => {
        text = text.replace(`{${param}}`, params[param]);
    });
    
    return text;
}

### Language Detection & Persistence

javascript

// language.js - Language management
const SUPPORTED_LANGUAGES = ['en', 'es', 'uk', 'ar'];
const DEFAULT_LANGUAGE = 'en';
const STORAGE_KEY = 'archr_language';
function getCurrentLanguage() {
    // 1. Check localStorage
    const stored = localStorage.getItem(STORAGE_KEY);
    if (stored && SUPPORTED_LANGUAGES.includes(stored)) return stored;
    
    // 2. Check browser preference
    const browserLang = navigator.language?.substring(0, 2);
    if (browserLang && SUPPORTED_LANGUAGES.includes(browserLang)) return browserLang;
    
    // 3. Fallback to default
    return DEFAULT_LANGUAGE;
}
function setLanguage(lang) {
    if (!SUPPORTED_LANGUAGES.includes(lang)) return;
    localStorage.setItem(STORAGE_KEY, lang);
    document.documentElement.lang = lang;
    document.documentElement.dir = lang === 'ar' ? 'rtl' : 'ltr';
    updatePageContent();
}

---

## Implementation Phases

### Phase 1: Foundation (Week 1-2)

**Goal:** Set up the translation system and make English the default.

#### Tasks

|Task|Description|Effort|
|---|---|---|
|1.1|Create translation files structure|2 hours|
|1.2|Build translation function `t()`|4 hours|
|1.3|Build language switcher component|4 hours|
|1.4|Add persistence (localStorage + cookie)|2 hours|
|1.5|Add RTL support for Arabic (CSS)|4 hours|
|1.6|Document translation process|2 hours|

#### Translation File Structure

text

/translations/
├── en.json          # English (source of truth)
├── es.json          # Spanish
├── uk.json          # Ukrainian
├── ar.json          # Arabic
├── translations.js  # Loader and t() function
└── README.md        # Instructions for translators

#### Language Switcher UI

html

<!-- Language Switcher Component -->
<div class="lang-switch" role="group" aria-label="Language switcher">
    <button class="lang-btn active" data-lang="en" aria-pressed="true">EN</button>
    <button class="lang-btn" data-lang="es" aria-pressed="false">ES</button>
    <button class="lang-btn" data-lang="uk" aria-pressed="false">UK</button>
    <button class="lang-btn" data-lang="ar" aria-pressed="false">AR</button>
</div>

#### CSS for RTL Support

css

/* rtl.css - RTL overrides */
[dir="rtl"] {
    /* General */
    text-align: right;
    
    /* Navigation */
    .portal-sidebar .nav-link { padding-right: 1rem; padding-left: 0.5rem; }
    .portal-sidebar .nav-link i { margin-left: 0.75rem; margin-right: 0; }
    
    /* Forms */
    .form-group label { text-align: right; }
    .form-actions { flex-direction: row-reverse; }
    
    /* Tables */
    .funding-table th { text-align: right; }
    
    /* Badges/Pills */
    .pill { margin-left: 0.25rem; margin-right: 0; }
    
    /* Icons that should flip (arrows, etc) */
    .icon-flip-rtl { transform: scaleX(-1); }
}

---

### Phase 2: Spanish Language Support (Week 3-4)

**Goal:** Add full Spanish translation with translator-friendly workflow.

#### Translation Process for Spanish

1. **Extract all strings** from the codebase (English source)
    
2. **Create `es.json`** with English keys and empty Spanish values
    
3. **Send to translator** with clear instructions
    
4. **Import completed translations**
    
5. **Test** with Spanish-speaking users
    

#### Translator Instructions (README.md)

markdown

# Translation Guide for ARCHR Platform
## How This Works
This file contains all the text that appears in the ARCHR platform. Your job is to translate the English text (on the left) into Spanish (on the right).
## File Format
```json
{
    "key": "English text to translate",
    "another.key": "More English text"
}

## Rules

1. **Leave the keys unchanged** - the part before the colon (e.g., "dashboard.welcome") must stay exactly as-is.
    
2. **Translate only the value** - the text after the colon.
    
3. **Keep parameters** - things like {name} or {date} should stay in the translated text.
    
4. **Be consistent** - use the same Spanish word for the same English word across the file.
    
5. **Test your translations** - if possible, view them in context before finalizing.
    

## Example

|English (DO NOT CHANGE)|Spanish (CHANGE THIS)|
|---|---|
|`"common.save": "Save"`|`"common.save": "Guardar"`|
|`"dashboard.welcome": "Welcome back, {name}"`|`"dashboard.welcome": "Bienvenido de nuevo, {name}"`|

## Tools

- Use a JSON validator to check your work: [https://jsonlint.com/](https://jsonlint.com/)
    
- For large files, consider using a translation tool like POEditor or CrowdIn.
    

## Questions?

Contact the development team at dev@archr.org

text

#### QA Checklist for Spanish
- [ ] All navigation items translated
- [ ] All form labels and buttons translated
- [ ] All dashboard KPIs and metrics labeled in Spanish
- [ ] All error messages and notifications translated
- [ ] Date formats localized (DD/MM/YYYY for Spanish)
- [ ] Currency format localized ($ → $ or €)
- [ ] Character encoding correct (no mojibake)
- [ ] No text overflow (Spanish is ~20% longer than English)
---
### Phase 3: Ukrainian Language Support (Week 5-6)
**Goal:** Add Ukrainian translation with support for Cyrillic encoding.
#### Ukrainian Considerations
| Issue | Solution |
|-------|----------|
| Cyrillic characters | Ensure UTF-8 encoding throughout |
| Longer text | Ukrainian is ~30% longer than English. Adjust UI spacing. |
| Date format | DD.MM.YYYY (with dots) |
| Currency | ₴ UAH |
#### Ukrainian QA Checklist
- [ ] Cyrillic characters display correctly
- [ ] Text doesn't overflow buttons or containers
- [ ] Number formatting uses Ukrainian conventions (decimal comma)
- [ ] Date formatting correct
- [ ] No encoding issues
---
### Phase 4: Arabic Language Support (Week 7-8)
**Goal:** Add Arabic translation with full RTL (right-to-left) support.
#### Arabic Considerations
| Issue | Solution |
|-------|----------|
| RTL layout | CSS RTL overrides + `dir="rtl"` |
| Text expansion | Arabic is ~20-30% longer than English |
| UI mirroring | Icons, arrows, and progress indicators need flipping |
| Input fields | Text should be right-aligned |
| Dates | Hijri or Gregorian with Arabic numerals |
| Currency | ﷼ SAR or $ with Arabic formatting |
#### Arabic QA Checklist
- [ ] Page layout flows right-to-left
- [ ] All text is right-aligned
- [ ] Icons and arrows flip direction (e.g., back/next arrows)
- [ ] Tables and grids flow RTL
- [ ] Form inputs align right
- [ ] Dropdowns open with RTL positioning
- [ ] Breadcrumbs reverse direction
- [ ] Progress bars show direction (RTL)
- [ ] No hardcoded `left`/`right` positions (use `start`/`end` or CSS logical properties)
---
## Translation File Structure (Detailed)
### en.json (Source of Truth - English)
```json
{
    "meta": {
        "language": "English",
        "code": "en",
        "direction": "ltr",
        "version": "1.0.0",
        "last_updated": "2024-12-01"
    },
    "navigation": {
        "dashboard": "Dashboard",
        "applications": "Applications",
        "tasks": "Tasks, Logs & Events",
        "team": "Team",
        "reports": "Reports",
        "settings": "Settings",
        "logout": "Log Out"
    },
    "common": {
        "save": "Save",
        "cancel": "Cancel",
        "delete": "Delete",
        "edit": "Edit",
        "view": "View",
        "continue": "Continue",
        "back": "Back",
        "next": "Next",
        "submit": "Submit",
        "close": "Close",
        "confirm": "Confirm",
        "loading": "Loading...",
        "error": "Error",
        "success": "Success",
        "search": "Search",
        "filter": "Filter",
        "reset": "Reset",
        "select": "Select",
        "select_all": "Select All",
        "deselect_all": "Deselect All"
    },
    "dashboard": {
        "title": "Dashboard",
        "welcome": "Welcome back, {name}",
        "last_application": "Last Application",
        "next_step": "Next Step",
        "holding_on": "Holding On",
        "recent_applications": "Recent Applications",
        "latest_events": "Latest Events",
        "latest_messages": "Latest Messages"
    },
    "bursar": {
        "title": "Bursar Dashboard",
        "total_approved": "Total Approved",
        "pending_reimbursement": "Pending Reimbursement",
        "reimbursed_to_date": "Reimbursed to Date",
        "on_hold": "On Hold",
        "active_cases": "Active Cases with Funding",
        "reimbursement_queue": "Reimbursement Queue",
        "funding_sources": "Funding Sources",
        "duplicate_alerts": "Duplicate & Overlap Alerts",
        "approve_invoice": "Approve Invoice",
        "mark_paid": "Mark Paid",
        "reject_reason": "Reject with Reason",
        "place_on_hold": "Place On Hold",
        "allocate_funds": "Allocate Funds",
        "export_report": "Export Report"
    }
}

### es.json (Spanish - Example)

json

{
    "meta": {
        "language": "Español",
        "code": "es",
        "direction": "ltr",
        "version": "1.0.0",
        "last_updated": "2024-12-01"
    },
    "navigation": {
        "dashboard": "Panel de Control",
        "applications": "Solicitudes",
        "tasks": "Tareas, Registros y Eventos",
        "team": "Equipo",
        "reports": "Informes",
        "settings": "Configuración",
        "logout": "Cerrar Sesión"
    },
    "common": {
        "save": "Guardar",
        "cancel": "Cancelar",
        "delete": "Eliminar",
        "edit": "Editar",
        "view": "Ver",
        "continue": "Continuar",
        "back": "Atrás",
        "next": "Siguiente",
        "submit": "Enviar",
        "close": "Cerrar",
        "confirm": "Confirmar",
        "loading": "Cargando...",
        "error": "Error",
        "success": "Éxito",
        "search": "Buscar",
        "filter": "Filtrar",
        "reset": "Restablecer",
        "select": "Seleccionar",
        "select_all": "Seleccionar Todo",
        "deselect_all": "Deseleccionar Todo"
    }
}

---

## Integration with Existing Code

### HTML Implementation

html

<!-- Before -->
<h1>Welcome back, John</h1>
<button>Save</button>
<p>You have 3 unread messages</p>
<!-- After -->
<h1 data-i18n="dashboard.welcome">Welcome back, {name}</h1>
<button data-i18n="common.save">Save</button>
<p data-i18n="messages.unread">You have {count} unread messages</p>

### JavaScript Implementation

javascript

// app.js - Apply translations to page
function updatePageContent() {
    const lang = getCurrentLanguage();
    
    // Update all elements with data-i18n
    document.querySelectorAll('[data-i18n]').forEach(el => {
        const key = el.getAttribute('data-i18n');
        const params = {};
        
        // Extract any parameters from the element
        const paramKeys = el.dataset.i18nParams ? JSON.parse(el.dataset.i18nParams) : {};
        Object.assign(params, paramKeys);
        
        // Get translated text
        const text = t(key, params);
        
        // Update based on element type
        if (el.tagName === 'INPUT' || el.tagName === 'TEXTAREA') {
            if (el.type === 'button' || el.type === 'submit') {
                el.value = text;
            } else {
                el.placeholder = text;
            }
        } else {
            el.textContent = text;
        }
    });
    
    // Update document title
    document.title = t('app.title');
}
// Run on page load and language change
document.addEventListener('DOMContentLoaded', updatePageContent);

---

## Browser Support Considerations

|Browser|Language Support|RTL Support|
|---|---|---|
|Chrome|Full|Full|
|Firefox|Full|Full|
|Safari|Full|Full|
|Edge|Full|Full|
|Mobile Safari|Full|Full|
|Chrome Mobile|Full|Full|

---

## Maintenance & Governance

### Translation Update Process

### Translation File Diff Example (Git)

diff

// en.json - Added new text
{
    "new_feature": {
+        "title": "New Feature Title",
+        "description": "This is a new feature description"
    }
}
// es.json - Translators update
{
    "new_feature": {
+        "title": "Nuevo Título de Característica",
+        "description": "Esta es una descripción de nueva característica"
    }
}

---

## Total Effort Estimate

|Phase|Effort|Deliverables|
|---|---|---|
|**Phase 1: Foundation**|2 weeks|Translation system, language switcher, documentation|
|**Phase 2: Spanish**|2 weeks|Full Spanish translation, QA|
|**Phase 3: Ukrainian**|2 weeks|Full Ukrainian translation, Cyrillic support|
|**Phase 4: Arabic**|2 weeks|Full Arabic translation, RTL support, UI mirroring|
|**Total**|**8 weeks**|4 languages supported|

---

## Quick Reference: Translation Functions

javascript

// Basic translation
t('common.save') // Returns: "Guardar" (if Spanish)
// With parameters
t('dashboard.welcome', { name: 'John' }) // Returns: "Welcome back, John"
// Nested keys (dot notation)
t('navigation.dashboard') // Returns: "Dashboard"
// Fallback (key itself)
t('nonexistent.key') // Returns: "nonexistent.key"

---

## Next Steps

1. **Set up translation file structure** in the codebase
    
2. **Extract all English text** from existing HTML/JS
    
3. **Build the `t()` function** and language switcher
    
4. **Deploy English-only** with the foundation ready
    
5. **Add Spanish** (2 weeks of translator time)
    
6. **Add Ukrainian** (2 weeks)
    
7. **Add Arabic** (2 weeks + UI adjustments)
   
   


graph LR
    A[Add new English text] --> B[Update en.json]
    B --> C[Run extraction script]
    C --> D[Generate translation files]
    D --> E[Notify translators]
    E --> F[Translators update files]
    F --> G[Import translations]
    G --> H[Test in context]
    H --> I[Deploy]