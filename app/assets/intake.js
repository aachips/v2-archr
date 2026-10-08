/* ARCHR intake form - page nav, conditional visibility, signature pads, progress bar, i18n */
(() => {
    const form = document.getElementById('intake-form');
    if (!form) return;

    const allPages = Array.from(form.querySelectorAll('.page'));
    const progressFill = document.getElementById('progress-bar-fill');
    const langInput = document.getElementById('language');
    const langButtons = Array.from(document.querySelectorAll('.lang-switch [data-lang]'));
    const debugMode = new URLSearchParams(window.location.search).get('debug') === 'true';
    let current = allPages.find(p => p.classList.contains('active')) || allPages[0];
    let currentLang = 'eng';

    /* ---------- Form value helpers ---------- */
    function getValue(name) {
        const el = form.elements[name];
        if (!el) return '';
        if (el instanceof RadioNodeList || el.length !== undefined) {
            if (el.value !== undefined) return el.value;
            return Array.from(el).filter(n => n.checked).map(n => n.value);
        }
        if (el.type === 'checkbox') return el.checked ? el.value : '';
        return el.value || '';
    }

    /* ---------- Page navigation + progress bar ---------- */
    function visiblePages() {
        return allPages.filter(p => {
            const cond = p.dataset.showIf;
            if (!cond) return true;
            const [name, val] = cond.split('=');
            return getValue(name) === val;
        });
    }
    function updateProgress() {
        if (!progressFill) return;
        const pages = visiblePages();
        const idx = Math.max(0, pages.indexOf(current));
        progressFill.style.width = (((idx + 1) / pages.length) * 100) + '%';
    }
    function showPage(page) {
        allPages.forEach(p => p.classList.toggle('active', p === page));
        updateProgress();
        resizeSignaturePads();
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }
    function goTo(delta) {
        const pages = visiblePages();
        let idx = pages.indexOf(current);
        if (idx === -1) {
            const absIdx = allPages.indexOf(current);
            current = pages.find(p => allPages.indexOf(p) >= absIdx) || pages[pages.length - 1];
            idx = pages.indexOf(current);
        }
        if (delta > 0 && !debugMode && !validatePage(current)) return;
        const next = idx + delta;
        if (next >= 0 && next < pages.length) {
            current = pages[next];
            showPage(current);
            renderSummary();
        }
    }

    /* ---------- Per-page required-field validation ----------
       A field is required when its <label> or owning <fieldset>'s <legend>
       contains a .req marker. Inputs inside [hidden] sub-blocks are skipped.
       Pass ?debug=true on the URL to bypass entirely. */
    function isInHidden(el) {
        for (let n = el; n && n !== form; n = n.parentElement) {
            if (n.hidden) return true;
        }
        return false;
    }
    function fieldsetHasValue(fs) {
        const inputs = fs.querySelectorAll('input, select, textarea');
        for (const i of inputs) {
            if ((i.type === 'radio' || i.type === 'checkbox') && i.checked) return true;
            if (i.type !== 'radio' && i.type !== 'checkbox' && i.value && i.value.trim()) return true;
        }
        return false;
    }
    function markError(el, on) {
        const wrap = el.closest('.field') || el.parentElement;
        if (wrap) wrap.classList.toggle('field-error', on);
    }
    function validatePage(page) {
        let firstInvalid = null;
        page.querySelectorAll('.field-error').forEach(el => el.classList.remove('field-error'));

        page.querySelectorAll('fieldset.field').forEach(fs => {
            const legend = fs.querySelector(':scope > legend');
            if (!legend || !legend.querySelector('.req')) return;
            if (isInHidden(fs)) return;
            if (!fieldsetHasValue(fs)) {
                fs.classList.add('field-error');
                if (!firstInvalid) firstInvalid = fs.querySelector('input, select, textarea');
            }
        });

        page.querySelectorAll('.field > label[for]').forEach(label => {
            if (!label.querySelector('.req')) return;
            const el = document.getElementById(label.getAttribute('for'));
            if (!el || isInHidden(el)) return;
            const empty = (el.tagName === 'SELECT')
                ? !el.value
                : !el.value || !String(el.value).trim();
            if (empty) {
                markError(el, true);
                if (!firstInvalid) firstInvalid = el;
            }
        });

        if (firstInvalid) {
            firstInvalid.focus({ preventScroll: false });
            return false;
        }
        return true;
    }

    /* ---------- Conditional sub-block visibility ---------- */
    function refreshConditionalBlocks() {
        document.querySelectorAll('[data-show-when-checked]').forEach(el => {
            const value = el.dataset.showWhenChecked;
            const cb = form.querySelector('input[type="checkbox"][value="' + value + '"]');
            el.hidden = !(cb && cb.checked);
        });
        document.querySelectorAll('[data-show-when-value]').forEach(el => {
            const [name, val] = el.dataset.showWhenValue.split('=');
            el.hidden = getValue(name) !== val;
        });
        updateProgress();
    }

    function renderSummary() {
        document.querySelectorAll('[data-summary]').forEach(span => {
            const v = getValue(span.dataset.summary);
            span.textContent = Array.isArray(v) ? v.join(', ') : v;
        });
    }

    form.addEventListener('click', (e) => {
        if (e.target.matches('[data-next]')) goTo(1);
        else if (e.target.matches('[data-prev]')) goTo(-1);
    });
    form.addEventListener('change', refreshConditionalBlocks);
    form.addEventListener('input', refreshConditionalBlocks);
    form.addEventListener('input', (e) => {
        const wrap = e.target.closest('.field-error');
        if (wrap) wrap.classList.remove('field-error');
    });

    /* ---------- Repair table add/clear ---------- */
    const repairBody = form.querySelector('#repair-table tbody');
    function repairRow() {
        return '<td><input type="text" name="repairNeed[]" aria-label="Repair need"></td>' +
            '<td><select name="repairPriority[]" aria-label="Urgency level">' +
            '<option value="">Select urgency</option>' +
            '<option value="1">Critical - Immediate danger/uninhabitable</option>' +
            '<option value="2">High - Major issue affecting daily life</option>' +
            '<option value="3">Medium - Significant but manageable</option>' +
            '<option value="4">Low - Minor repair needed</option>' +
            '</select></td>';
    }
    form.addEventListener('click', (e) => {
        if (e.target.matches('[data-repair-add]') && repairBody) {
            const tr = document.createElement('tr');
            tr.innerHTML = repairRow();
            repairBody.appendChild(tr);
            applyLanguage(currentLang);
        } else if (e.target.matches('[data-repair-clear]') && repairBody) {
            repairBody.innerHTML = '<tr>' + repairRow() + '</tr>';
            applyLanguage(currentLang);
        }
    });

    /* ---------- Income calculator modal ---------- */
    const modal = document.getElementById('calc-modal');
    const incomeBody = document.querySelector('#income-records tbody');
    const incomeRecords = []; // parallel array submitted as JSON
    function openCalc() { if (modal) modal.classList.add('open'); }
    function closeCalc() { if (modal) modal.classList.remove('open'); }
    document.addEventListener('click', (e) => {
        if (e.target.matches('[data-open-calc]')) openCalc();
        else if (e.target.matches('[data-close-calc]')) closeCalc();
        else if (e.target.matches('[data-save-calc]')) {
            const record = {
                whose: getValue('calcWhose'),
                source: getValue('calcSource'),
                frequency: getValue('calcFrequency'),
                amount: getValue('calcAmount')
            };
            if (incomeBody) {
                const tr = document.createElement('tr');
                const cells = [record.whose, record.source, record.frequency, record.amount];
                tr.innerHTML = cells.map((c, i) => '<td>' + (c ? (i === 3 ? '$' + c : c) : '&mdash;') + '</td>').join('');
                incomeBody.appendChild(tr);
            }
            incomeRecords.push(record);
            closeCalc();
        }
    });


    /* ---------- Signature pads (signature_pad UMD on window) ---------- */
    const signaturePads = [];
    function initSignaturePads() {
        if (typeof window.SignaturePad === 'undefined') return;
        document.querySelectorAll('canvas[data-signature]').forEach(canvas => {
            const targetName = canvas.dataset.target;
            const hidden = document.getElementById(targetName);
            const pad = new window.SignaturePad(canvas, {
                backgroundColor: 'rgba(255,255,255,0)',
                penColor: '#000'
            });
            pad.addEventListener('endStroke', () => {
                if (hidden) hidden.value = pad.toDataURL('image/png');
            });
            signaturePads.push({ canvas, pad, hidden });
        });
    }
    function resizeSignaturePads() {
        signaturePads.forEach(({ canvas, pad }) => {
            if (canvas.offsetWidth === 0) return;
            const ratio = Math.max(window.devicePixelRatio || 1, 1);
            const data = pad.toData();
            canvas.width = canvas.offsetWidth * ratio;
            canvas.height = canvas.offsetHeight * ratio;
            canvas.getContext('2d').scale(ratio, ratio);
            pad.clear();
            if (data && data.length) pad.fromData(data);
        });
    }
    document.addEventListener('click', (e) => {
        if (e.target.matches('[data-signature-clear]')) {
            const wrap = e.target.closest('.signature-wrap');
            const canvas = wrap && wrap.querySelector('canvas[data-signature]');
            const entry = signaturePads.find(s => s.canvas === canvas);
            if (entry) {
                entry.pad.clear();
                if (entry.hidden) entry.hidden.value = '';
            }
        }
    });
    window.addEventListener('resize', resizeSignaturePads);

    /* ---------- i18n: walk text nodes, swap with translations ---------- */
    const translations = { esp: {
        "Asheville Regional Coalition for Home Repair": "Coalición Regional de Asheville para la Reparación del Hogar",
        "Home Repair Services Screening Form": "Formulario de selección de servicios de reparación del hogar",
        "Next": "Siguiente", "Back": "Atrás", "Submit": "Enviar", "Save": "Guardar",
        "Cancel": "Cancelar", "Clear": "Borrar", "Yes": "Sí", "No": "No", "Done": "Listo",
        "+ Add row": "+ Agregar fila",
        "+ Add income record ($ calculator)": "+ Agregar registro de ingresos (calculadora $)",
        "Step 1 · Welcome": "Paso 1 · Bienvenido",
        "Use the EN / ES toggle at the top of the page at any time to switch between English and Spanish.": "Use el botón EN / ES en la parte superior de la página en cualquier momento para cambiar entre inglés y español.",
        "Are you submitting this on behalf of someone else as a referral?": "¿Está enviando esto en nombre de otra persona como referencia?",
        "Yes, I am referring someone": "Sí, estoy refiriendo a alguien",
        "No, I am the applicant": "No, yo soy el solicitante",
        "Step 2 · About this form": "Paso 2 · Acerca de este formulario",
        "Screening Form": "Formulario de selección",
        "This screening form will screen you for eligibility to apply for home repair services at any organization within the ARCHR partnership, which includes:": "Este formulario lo evaluará para determinar su elegibilidad para solicitar servicios de reparación del hogar en cualquier organización dentro de la alianza ARCHR, que incluye:",
        "Data Confidentiality": "Confidencialidad de los datos",
        "This screening tool requests information about your home repair needs. This information will be shared with the organizations of ARCHR (Asheville Regional Coalition for Home Repair).": "Esta herramienta solicita información sobre sus necesidades de reparación del hogar. Esta información se compartirá con las organizaciones de ARCHR.",
        "These organizations support offering necessary repairs, accessibility modifications, and weatherization assistance to Western North Carolina homeowners.": "Estas organizaciones brindan reparaciones necesarias, modificaciones de accesibilidad y asistencia de climatización a propietarios del oeste de Carolina del Norte.",
        "Because of complex eligibility criteria and funding availability across repair organizations, this screening tool helps our organizations identify which one of us is best able to serve you, preventing you from filling out applications for organizations that cannot serve you in the end.": "Debido a los criterios de elegibilidad complejos y la disponibilidad de fondos, esta herramienta ayuda a identificar cuál de nosotros puede atenderlo mejor, evitando que llene solicitudes para organizaciones que no podrían servirle.",
        "By submitting this form, you are agreeing to submit this screening and associated information to the organizations of the Asheville Regional Coalition for Home Repair so that we can work together to better serve you. Information will never be shared outside of the ARCHR organizations.": "Al enviar este formulario, usted acepta enviar esta selección a las organizaciones de ARCHR para que podamos trabajar juntos para servirle mejor. La información nunca se compartirá fuera de las organizaciones de ARCHR.",
        "If you meet the initial criteria, staff from ARCHR will contact you by telephone to set up a home visit to assess the requested repairs and report back to the coalition.": "Si cumple con los criterios iniciales, el personal de ARCHR lo contactará por teléfono para programar una visita y evaluar las reparaciones solicitadas.",
        "I agree to the data sharing terms above.": "Acepto los términos de intercambio de datos anteriores.",
        "Referral submission": "Envío de referencia",
        "Submit referral": "Enviar referencia",
        "Tell us who is submitting this referral on behalf of the applicant.": "Díganos quién envía esta referencia en nombre del solicitante.",
        "Your name": "Su nombre",
        "Your organization": "Su organización",
        "Your email": "Su correo electrónico",
        "Referral notes": "Notas de la referencia",
        "Primary contact information": "Información de contacto principal",
        "Primary Contact Information": "Información de contacto principal",
        "Primary applicant first name": "Nombre del solicitante principal",
        "Primary applicant last name": "Apellido del solicitante principal",
        "Primary applicant date of birth": "Fecha de nacimiento del solicitante principal",
        "Check if primary applicant DOB unknown": "Marque si la fecha de nacimiento del solicitante principal es desconocida",
        "Preferred contact method": "Método de contacto preferido",
        "— select all that work": "— seleccione todos los que apliquen",
        "Phone call": "Llamada telefónica",
        "Text message": "Mensaje de texto",
        "Email": "Correo electrónico",
        "Other contact method": "Otro método de contacto",
        "Home phone": "Teléfono de casa",
        "Cell phone": "Teléfono celular",
        "One phone number is required, and email is required.": "Se requiere un número de teléfono y un correo electrónico.",
        "Email address": "Dirección de correo electrónico",
        "Other contact method — please describe how you would like to be contacted": "Otro método de contacto — describa cómo le gustaría ser contactado",
        "Are there any specific times of day or other details you'd like to add about how to contact you?": "¿Hay horas específicas del día u otros detalles que le gustaría añadir sobre cómo contactarlo?",
        "Home address & household": "Dirección del hogar y miembros",
        "Home Address": "Dirección del hogar",
        "Home address": "Dirección del hogar",
        "City": "Ciudad",
        "State / Province": "Estado / Provincia",
        "Zip / Postal code": "Código postal",
        "Zip / Postal": "Código postal",
        "Address": "Dirección",
        "Is this your primary residence?": "¿Es esta su residencia principal?",
        "Do you receive mail at a different address?": "¿Recibe correo en una dirección diferente?",
        "Mailing address": "Dirección postal",
        "About your home": "Acerca de su hogar",
        "Type of home": "Tipo de vivienda",
        "— Select —": "— Seleccione —",
        "Traditional construction": "Construcción tradicional",
        "Modular home": "Casa modular",
        "Mobile home": "Casa móvil",
        "Other": "Otro",
        "Year built": "Año de construcción",
        "When did you move into this address?": "¿Cuándo se mudó a esta dirección?",
        "Do you own your home?": "¿Es propietario de su vivienda?",
        "Do you own the lot your mobile home is on?": "¿Es propietario del lote donde está su casa móvil?",
        "Home owner's insurance provider (optional)": "Proveedor de seguro de vivienda (opcional)",
        "Have you lived in your home for at least 1 year?": "¿Ha vivido en su vivienda por al menos 1 año?",
        "How many people live in your home full time?": "¿Cuántas personas viven en su vivienda a tiempo completo?",
        "Of those, how many are over 18 years old?": "De esos, ¿cuántos son mayores de 18 años?",
        "Count adults and children residing at your home at least 50% of the time.": "Cuente adultos y niños que residen en su vivienda al menos el 50% del tiempo.",
        "Select any that are part of this household (check all that apply):": "Seleccione cualquiera que sea parte de este hogar (marque todos los que apliquen):",
        "Single parent": "Padre/madre soltero",
        "Child under 5 years old": "Niño menor de 5 años",
        "Person over 62": "Persona mayor de 62",
        "Person with disability": "Persona con discapacidad",
        "Person that receives SNAP/EBT or WIC": "Persona que recibe SNAP/EBT o WIC",
        "US Armed Forces Veteran": "Veterano de las Fuerzas Armadas de EE. UU.",
        "Repair request": "Solicitud de reparación",
        "Add Repair Request": "Agregar solicitud de reparación",
        "Enter a brief description of needed repairs (i.e. \"gutters replaced\" or \"unsafe entry stairs\"). If you can, enter an applicant-identified priority rank (e.g. \"replace leaking roof | 1\", \"repaint hallway | 2\").": "Ingrese una breve descripción de las reparaciones necesarias (p. ej., \"reemplazar canalones\" o \"escaleras inseguras\"). Si puede, ingrese una prioridad identificada por el solicitante (p. ej., \"reparar techo con goteras | 1\").",
        "Repair need": "Necesidad de reparación",
        "Priority": "Prioridad",
        "Enter any additional repair need details": "Ingrese cualquier detalle adicional sobre las necesidades de reparación",
        "Check any that apply:": "Marque las que apliquen:",
        "Applicant is unable to stay in home": "El solicitante no puede permanecer en la vivienda",
        "Applicant does not have functional heating and/or air conditioning": "El solicitante no tiene calefacción y/o aire acondicionado funcional",
        "Applicant does not have potable water": "El solicitante no tiene agua potable",
        "Applicant can not use bathroom facilities (toilet/shower/bath)": "El solicitante no puede usar las instalaciones del baño (inodoro/ducha/bañera)",
        "Applicant can not use kitchen facilities (stove/oven/refrigerator)": "El solicitante no puede usar las instalaciones de cocina (estufa/horno/refrigerador)",
        "Applicant's home is open to the elements (rain/wind/animals)": "La vivienda del solicitante está expuesta a los elementos (lluvia/viento/animales)",
        "Applicant can not get into or out of home": "El solicitante no puede entrar o salir de la vivienda",
        "Applicant has accessibility need": "El solicitante tiene necesidad de accesibilidad",
        "Applicant has an issue not listed": "El solicitante tiene un problema no enumerado",
        "Applicant is at risk of eviction": "El solicitante está en riesgo de desalojo",
        "Home repair requests": "Solicitudes de reparación del hogar",
        "Home Repair Requests": "Solicitudes de reparación del hogar",
        "Please check all boxes that apply to your home:": "Marque todas las casillas que apliquen a su vivienda:",
        "I am unable to stay in my home": "No puedo permanecer en mi vivienda",
        "I do not have functional heating and/or air conditioning": "No tengo calefacción y/o aire acondicionado funcional",
        "I do not have potable water": "No tengo agua potable",
        "I can not use bathroom facilities (toilet/shower/bath)": "No puedo usar las instalaciones del baño (inodoro/ducha/bañera)",
        "I can not use kitchen facilities (stove/oven/refrigerator)": "No puedo usar las instalaciones de cocina (estufa/horno/refrigerador)",
        "My home is open to the elements (rain/wind/animals)": "Mi vivienda está expuesta a los elementos (lluvia/viento/animales)",
        "I can not get into or out of my home": "No puedo entrar o salir de mi vivienda",
        "I have an accessibility need": "Tengo una necesidad de accesibilidad",
        "I have an issue not listed": "Tengo un problema no enumerado",
        "I am at risk of eviction": "Estoy en riesgo de desalojo",
        "Request details": "Detalles de la solicitud",
        "Request Details": "Detalles de la solicitud",
        "Please tell us more about each issue you selected.": "Por favor, cuéntenos más sobre cada problema que seleccionó.",
        "Please describe the issue as best as you can": "Por favor describa el problema lo mejor que pueda",
        "Please describe the issue": "Por favor describa el problema",
        "Please describe your accessibility need": "Por favor describa su necesidad de accesibilidad",
        "Please describe your situation": "Por favor describa su situación",
        "How do you heat your home? (check all that apply)": "¿Cómo calienta su vivienda? (marque todos los que apliquen)",
        "Woodstove / fireplace": "Estufa de leña / chimenea",
        "Natural gas / propane": "Gas natural / propano",
        "Electric": "Eléctrica",
        "Kerosene": "Queroseno",
        "Please select source of water": "Por favor seleccione la fuente de agua",
        "City / municipal": "Ciudad / municipal",
        "Well": "Pozo",
        "Hurricane Helene": "Huracán Helene",
        "Tropical Storm Helene": "Tormenta tropical Helene",
        "Was this issue caused by Tropical Storm Helene?": "¿Fue este problema causado por la tormenta tropical Helene?",
        "FEMA": "FEMA",
        "Have you filed a claim with FEMA for repairs listed?": "¿Ha presentado una reclamación a FEMA por las reparaciones enumeradas?",
        "What was the outcome of the FEMA claim?": "¿Cuál fue el resultado de la reclamación de FEMA?",
        "Denied": "Denegada",
        "Settled": "Liquidada",
        "What was total FEMA settlement amount?": "¿Cuál fue el monto total del acuerdo de FEMA?",
        "Is there any remaining $ from the FEMA settlement amount paid?": "¿Queda algo del monto del acuerdo de FEMA pagado?",
        "What is the total amount remaining from the FEMA settlement amount?": "¿Cuál es el monto total restante del acuerdo de FEMA?",
        "Homeowner's insurance": "Seguro del propietario de vivienda",
        "Homeowner's Insurance": "Seguro del propietario de vivienda",
        "Have you filed a claim with your homeowner's insurance for repairs you listed?": "¿Ha presentado una reclamación con su seguro de vivienda por las reparaciones enumeradas?",
        "What was the outcome of the homeowner's insurance claim?": "¿Cuál fue el resultado de la reclamación del seguro de vivienda?",
        "What was the total homeowner's insurance settlement amount?": "¿Cuál fue el monto total del acuerdo del seguro de vivienda?",
        "Is there any remaining $ from the homeowner's insurance settlement amount paid?": "¿Queda algo del monto del acuerdo del seguro de vivienda pagado?",
        "What is the total amount remaining from the homeowner's insurance settlement amount?": "¿Cuál es el monto total restante del acuerdo del seguro de vivienda?",
        "Income information": "Información de ingresos",
        "Add Income Information": "Agregar información de ingresos",
        "Do you receive income?": "¿Recibe ingresos?",
        "How would you like to record your income?": "¿Cómo le gustaría registrar sus ingresos?",
        "Enter gross annual income": "Ingresar ingresos brutos anuales",
        "Use the $ calculator": "Usar la calculadora $",
        "Please enter gross annual income": "Por favor ingrese ingresos brutos anuales",
        "Total household income before taxes.": "Ingresos totales del hogar antes de impuestos.",
        "Whose": "De quién",
        "Source": "Fuente",
        "Frequency": "Frecuencia",
        "Amount": "Monto",
        "How do you want to add income documents?": "¿Cómo desea agregar los documentos de ingresos?",
        "I will upload income documents now": "Subiré los documentos de ingresos ahora",
        "Email me a link to upload income documents": "Envíenme un enlace por correo para subir los documentos de ingresos",
        "I will present income documents in person at time of property assessment": "Presentaré los documentos de ingresos en persona durante la evaluación de la propiedad",
        "What counts as proof of income?": "¿Qué cuenta como prueba de ingresos?",
        "Accepted income proof varies based on income source. Examples include recent pay stubs, W-2s, benefits award letters, bank statements, and tax returns.": "La prueba de ingresos aceptada varía según la fuente. Ejemplos incluyen talones de pago recientes, formularios W-2, cartas de beneficios, estados de cuenta bancarios y declaraciones de impuestos.",
        "Enter signature": "Ingresar firma",
        "Zero income affidavit": "Declaración jurada de ingreso cero",
        "Zero Income Affidavit": "Declaración jurada de ingreso cero",
        "First name": "Nombre",
        "Last name": "Apellido",
        "I hereby certify that I do not individually receive income from any of the following sources:": "Por la presente certifico que no recibo individualmente ingresos de ninguna de las siguientes fuentes:",
        "Wages from employment (including commissions, tips, bonuses, fees, etc.);": "Salarios de empleo (incluidas comisiones, propinas, bonos, honorarios, etc.);",
        "Income from operation of a business;": "Ingresos por la operación de un negocio;",
        "Rental income from real or personal property;": "Ingresos por alquiler de bienes raíces o personales;",
        "Interest or dividends from assets;": "Intereses o dividendos de activos;",
        "Social Security payments, annuities, insurance policies, retirement funds, pensions, or death benefits;": "Pagos del Seguro Social, anualidades, pólizas de seguro, fondos de jubilación, pensiones o beneficios por fallecimiento;",
        "Unemployment or disability payments;": "Pagos por desempleo o discapacidad;",
        "Public assistance payments;": "Pagos de asistencia pública;",
        "Periodic allowances such as alimony, child support, or gifts received from persons living in my household;": "Subvenciones periódicas como pensión alimenticia, manutención infantil o regalos recibidos de personas que viven en mi hogar;",
        "Sales from self-employed resources (Avon, Mary Kay, Shaklee, etc.);": "Ventas de recursos autónomos (Avon, Mary Kay, Shaklee, etc.);",
        "Any other source not named above.": "Cualquier otra fuente no mencionada anteriormente.",
        "Under penalty of perjury, I certify that the information presented in this certification is true and accurate to the best of my knowledge. The undersigned further understand(s) that providing false representations herein constitutes an act of fraud.": "Bajo pena de perjurio, certifico que la información presentada en esta certificación es verdadera y exacta a mi leal saber y entender. El abajo firmante entiende además que presentar falsedades aquí constituye un acto de fraude.",
        "Signature": "Firma",
        "I certify the statement above is true.": "Certifico que la declaración anterior es verdadera.",
        "Submission received!": "¡Envío recibido!",
        "Once we make a determination on your eligibility, a member of an ARCHR Partner Organization's staff will reach out via your preferred contact with next steps.": "Una vez que determinemos su elegibilidad, un miembro del personal de una organización asociada de ARCHR se comunicará con usted a través de su contacto preferido con los próximos pasos.",
        "Visit the ARCHR website": "Visite el sitio web de ARCHR",
        "Your contact info": "Su información de contacto",
        "Preferred contact method:": "Método de contacto preferido:",
        "Home phone:": "Teléfono de casa:",
        "Cell phone:": "Teléfono celular:",
        "Email:": "Correo electrónico:",
        "Other contact method:": "Otro método de contacto:",
        "Contact notes:": "Notas de contacto:",
        "Income Calculator": "Calculadora de ingresos",
        "We use this to determine what kind of documentation we need to collect in order to verify eligibility. Enter one (1) source of income at a time.": "Usamos esto para determinar qué tipo de documentación necesitamos recopilar para verificar la elegibilidad. Ingrese una (1) fuente de ingresos a la vez.",
        "Whose income are you adding?": "¿De quién son los ingresos que está agregando?",
        "Mine": "Míos",
        "Another household member": "Otro miembro del hogar",
        "Source of income": "Fuente de ingresos",
        "Work / job": "Trabajo / empleo",
        "Self-employment": "Trabajo por cuenta propia",
        "Social Security": "Seguro Social",
        "Disability": "Discapacidad",
        "Retirement / pension": "Jubilación / pensión",
        "How often is $ received?": "¿Con qué frecuencia se reciben $?",
        "Weekly": "Semanalmente",
        "Bi-weekly": "Quincenalmente",
        "Monthly": "Mensualmente",
        "Annually": "Anualmente",
        "Dollar amount received (before taxes).": "Monto en dólares recibido (antes de impuestos)."
    }};

    // Collect every translatable text node once on load, storing the original.
    const textCache = [];
    function collectTextNodes(root) {
        const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT, {
            acceptNode(node) {
                if (!node.nodeValue || !node.nodeValue.trim()) return NodeFilter.FILTER_REJECT;
                const p = node.parentNode;
                if (!p) return NodeFilter.FILTER_REJECT;
                const tag = p.tagName;
                if (tag === 'SCRIPT' || tag === 'STYLE' || tag === 'NOSCRIPT') return NodeFilter.FILTER_REJECT;
                return NodeFilter.FILTER_ACCEPT;
            }
        });
        let n;
        while ((n = walker.nextNode())) textCache.push({ node: n, original: n.nodeValue });
    }

    // Translate placeholders on inputs as well.
    const placeholderCache = [];
    function collectPlaceholders(root) {
        root.querySelectorAll('input[placeholder], textarea[placeholder]').forEach(el => {
            placeholderCache.push({ el, original: el.getAttribute('placeholder') });
        });
    }

    function applyLanguage(lang) {
        const dict = translations[lang] || {};
        textCache.forEach(({ node, original }) => {
            const trimmed = original.trim();
            if (!trimmed) return;
            const replacement = dict[trimmed];
            if (lang !== 'eng' && replacement) {
                const leading = original.match(/^\s*/)[0];
                const trailing = original.match(/\s*$/)[0];
                node.nodeValue = leading + replacement + trailing;
            } else {
                node.nodeValue = original;
            }
        });
        placeholderCache.forEach(({ el, original }) => {
            if (!original) return;
            const replacement = dict[original.trim()];
            el.setAttribute('placeholder', (lang !== 'eng' && replacement) ? replacement : original);
        });
        document.documentElement.lang = (lang === 'esp') ? 'es' : 'en';
    }

    /* ---------- Language switcher ---------- */
    function setLanguage(lang) {
        currentLang = lang;
        if (langInput) langInput.value = lang;
        langButtons.forEach(b => {
            const active = b.dataset.lang === lang;
            b.classList.toggle('active', active);
            b.setAttribute('aria-pressed', active ? 'true' : 'false');
        });
        applyLanguage(lang);
    }
    langButtons.forEach(b => {
        b.addEventListener('click', () => setLanguage(b.dataset.lang));
    });

    /* ---------- Form submission ----------
       The final page's button has type="submit" + [data-submit]. We POST a
       JSON payload to form.action (form-handler.php) and advance to the
       confirmation page only after the server reports success. */
    function buildPayload() {
        const fd = new FormData(form);
        const data = {};
        for (const [key, value] of fd.entries()) {
            if (key.endsWith('[]')) {
                const k = key.slice(0, -2);
                (data[k] = data[k] || []).push(value);
            } else if (data[key] !== undefined) {
                if (!Array.isArray(data[key])) data[key] = [data[key]];
                data[key].push(value);
            } else {
                data[key] = value;
            }
        }
        const needs = data.repairNeed || [];
        const prios = data.repairPriority || [];
        if (needs.length || prios.length) {
            data.repairNeeds = needs
                .map((n, i) => ({ need: n, priority: prios[i] || '' }))
                .filter(r => r.need || r.priority);
        }
        delete data.repairNeed;
        delete data.repairPriority;
        data.incomeRecords = incomeRecords;
        return data;
    }

    const errBox = form.querySelector('[data-submit-error]');
    const dupBox = document.getElementById('duplicate-warning');
    function showSubmitError(msg) {
        if (!errBox) return;
        errBox.textContent = msg;
        errBox.hidden = false;
    }
    function clearSubmitError() {
        if (errBox) { errBox.textContent = ''; errBox.hidden = true; }
    }

    function translateDuplicateLabel(label) {
        if (currentLang !== 'esp') return label;
        return String(label)
            .replace(/\bemail\b/g, 'correo electrónico')
            .replace(/\baddress\b/g, 'dirección')
            .replace(/\bhome phone\b/g, 'teléfono de casa')
            .replace(/\bcell phone\b/g, 'teléfono celular')
            .replace(/\binformation\b/g, 'información');
    }

    function duplicateWarningText(matchLabel, number) {
        const label = translateDuplicateLabel(matchLabel);
        if (currentLang === 'esp') {
            return 'Ya se recibió un envío reciente para esta ' + label + '. Para evitar un duplicado, llámenos al ' + number + ' antes de continuar.';
        }
        return 'A recent submission for this ' + label + ' was already received. To avoid a duplicate, please call ' + number + ' before continuing.';
    }

    function showDuplicateWarning(matchLabel, number) {
        if (!dupBox) return;
        const text = duplicateWarningText(matchLabel, number);
        const digits = String(number).replace(/[^0-9+]/g, '');
        dupBox.innerHTML = text.replace(number, '<a href="tel:' + digits + '">' + number + '</a>');
        dupBox.hidden = false;
    }

    function clearDuplicateWarning() {
        if (dupBox) { dupBox.innerHTML = ''; dupBox.hidden = true; }
    }

    let duplicateCheckTimeout = null;
    async function checkDuplicate() {
        const email = (document.getElementById('contactEmail')?.value || '').trim();
        const homeAddress = (document.getElementById('homeAddress')?.value || '').trim();
        const homePhone = (document.getElementById('homePhone')?.value || '').trim();
        const cellPhone = (document.getElementById('cellPhone')?.value || '').trim();
        if (!email && !homeAddress && !homePhone && !cellPhone) {
            clearDuplicateWarning();
            return;
        }
        try {
            const res = await fetch('api/check-duplicate.php', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
                body: JSON.stringify({ email, home_address: homeAddress, home_phone: homePhone, cell_phone: cellPhone })
            });
            const json = await res.json().catch(() => null);
            if (json && json.duplicate && json.submission) {
                showDuplicateWarning(json.submission.match_label || 'information', json.call_in_number || '');
            } else {
                clearDuplicateWarning();
            }
        } catch (err) {
            // Silent failure — duplicate warning is a convenience, not a gate.
        }
    }

    function scheduleDuplicateCheck() {
        if (duplicateCheckTimeout) clearTimeout(duplicateCheckTimeout);
        duplicateCheckTimeout = setTimeout(checkDuplicate, 600);
    }

    ['contactEmail', 'homePhone', 'cellPhone', 'homeAddress'].forEach(id => {
        const el = document.getElementById(id);
        if (el) el.addEventListener('input', scheduleDuplicateCheck);
    });

    /* ---------- Form Progress Saving to LocalStorage ---------- */
    const STORAGE_KEY = 'archr_intake_progress';
    const STORAGE_EXPIRY = 7 * 24 * 60 * 60 * 1000; // 7 days

    function saveProgress() {
        try {
            const formData = buildPayload();
            const saveData = {
                data: formData,
                currentPage: allPages.indexOf(current),
                timestamp: Date.now(),
                expiresAt: Date.now() + STORAGE_EXPIRY
            };
            localStorage.setItem(STORAGE_KEY, JSON.stringify(saveData));
            console.log('Progress saved');
        } catch (e) {
            console.warn('Could not save progress:', e);
        }
    }

    function loadProgress() {
        try {
            const saved = localStorage.getItem(STORAGE_KEY);
            if (!saved) return false;

            const saveData = JSON.parse(saved);
            if (Date.now() > saveData.expiresAt) {
                localStorage.removeItem(STORAGE_KEY);
                return false;
            }

            if (!confirm('Found saved progress from ' + new Date(saveData.timestamp).toLocaleString() + '. Restore it?')) {
                return false;
            }

            // Restore form values
            Object.entries(saveData.data).forEach(([key, value]) => {
                const el = form.elements[key];
                if (!el) return;

                if (el instanceof RadioNodeList) {
                    if (Array.isArray(value)) {
                        el.forEach(input => {
                            if (input.type === 'checkbox') {
                                input.checked = value.includes(input.value);
                            }
                        });
                    } else {
                        el.forEach(input => {
                            if (input.type === 'radio') {
                                input.checked = input.value === value;
                            }
                        });
                    }
                } else if (el.type === 'checkbox') {
                    el.checked = value === el.value || value === true;
                } else {
                    el.value = value || '';
                }
            });

            // Restore page position
            if (saveData.currentPage >= 0 && saveData.currentPage < allPages.length) {
                current = allPages[saveData.currentPage];
                showPage(current);
            }

            refreshConditionalBlocks();
            return true;
        } catch (e) {
            console.warn('Could not load progress:', e);
            return false;
        }
    }

    function clearProgress() {
        try {
            localStorage.removeItem(STORAGE_KEY);
            console.log('Progress cleared');
        } catch (e) {
            console.warn('Could not clear progress:', e);
        }
    }

    // Auto-save on input changes (debounced)
    let saveTimeout;
    form.addEventListener('input', () => {
        clearTimeout(saveTimeout);
        saveTimeout = setTimeout(saveProgress, 1000);
    });

    // Save on page navigation
    form.addEventListener('click', (e) => {
        if (e.target.matches('[data-next]') || e.target.matches('[data-prev]')) {
            saveProgress();
        }
    });

    /* ---------- Credentials Display ---------- */
    function displayCredentials(credentials, errorText = '') {
        console.log('displayCredentials called with:', credentials, 'error:', errorText);

        const credBox = document.getElementById('credentials-box');
        const usernameDisplay = document.getElementById('username-display');
        const passwordDisplay = document.getElementById('password-display');
        const debugMsg = document.getElementById('debug-message');

        if (!credBox || !usernameDisplay || !passwordDisplay) {
            console.error('❌ Credential display elements not found!');
            if (debugMsg) debugMsg.textContent = 'Error: Display elements not found';
            return;
        }

        credBox.hidden = false;

        if (!credentials || !credentials.username || !credentials.password) {
            console.error('❌ Invalid credentials object:', credentials);
            usernameDisplay.textContent = 'Not available';
            passwordDisplay.textContent = 'Not available';
            if (debugMsg) {
                const detail = errorText
                    ? 'Server error: ' + errorText
                    : 'Account may not have been created. Check app/logs/account-credentials.log.';
                debugMsg.innerHTML = '<strong>❌ No credentials received!</strong><br>' + detail;
            }
            return;
        }

        // Display credentials
        usernameDisplay.textContent = credentials.username;
        passwordDisplay.textContent = credentials.password;

        if (debugMsg) {
            debugMsg.innerHTML = '<strong>✅ Credentials received!</strong><br>Username: ' +
                credentials.username + '<br>Password: ' + credentials.password;
        }

        console.log('✅ Credentials displayed successfully');
    }

    // Copy to clipboard functionality
    document.addEventListener('click', (e) => {
        if (e.target.matches('[data-copy]')) {
            const field = e.target.dataset.copy;
            const text = field === 'username'
                ? document.getElementById('username-display').textContent
                : document.getElementById('password-display').textContent;

            if (navigator.clipboard) {
                navigator.clipboard.writeText(text).then(() => {
                    const btn = e.target;
                    const originalText = btn.textContent;
                    btn.textContent = 'Copied!';
                    setTimeout(() => btn.textContent = originalText, 2000);
                }).catch(() => {
                    fallbackCopy(text, e.target);
                });
            } else {
                fallbackCopy(text, e.target);
            }
        }
    });

    function fallbackCopy(text, btn) {
        const textarea = document.createElement('textarea');
        textarea.value = text;
        document.body.appendChild(textarea);
        textarea.select();
        try {
            document.execCommand('copy');
            const originalText = btn.textContent;
            btn.textContent = 'Copied!';
            setTimeout(() => btn.textContent = originalText, 2000);
        } catch (err) {
            alert('Failed to copy. Please copy manually: ' + text);
        }
        document.body.removeChild(textarea);
    }

    form.addEventListener('submit', async (e) => {
        e.preventDefault();
        const btn = form.querySelector('[data-submit]');
        // Enter in a text field on an earlier page fires `submit` too;
        // treat that as a Next navigation instead of an actual POST.
        if (!btn || !current.contains(btn)) {
            goTo(1);
            return;
        }
        if (!debugMode && !validatePage(current)) return;
        clearSubmitError();
        if (btn) btn.disabled = true;
        try {
            const res = await fetch(form.action, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
                body: JSON.stringify(buildPayload())
            });
            const json = await res.json().catch(() => null);
            console.log('Submission response:', json);

            if (res.ok && json && json.success) {
                clearProgress(); // Clear saved form data on successful submission

                // Show success alert
                const caseNum = json.display_ref || json.placecode || json.case_number || json.anchor_id || '#' + (json.submission_id || '');

                // Build alert message with credentials if available
                let alertMsg = '✅ Submission Successful!\n\nReference: ' + caseNum;
                if (json.credentials && json.credentials.username) {
                    alertMsg += '\n\n🔑 Your Login Credentials:\n';
                    alertMsg += 'Username: ' + json.credentials.username + '\n';
                    alertMsg += 'Password: ' + json.credentials.password + '\n';
                    alertMsg += '\nSave these credentials! They are also shown on the next page.';
                } else {
                    alertMsg += '\n\nYour application has been received. Check your email for confirmation.';
                    console.warn('No credentials in response:', json);
                }

                alert(alertMsg);

                // Update case number display
                const caseEl = document.querySelector('[data-submitted-case]');
                if (caseEl) caseEl.textContent = caseNum;

                // Update dashboard link
                const linkEl = document.querySelector('[data-dashboard-link]');
                if (linkEl && json.dashboard_url) linkEl.setAttribute('href', json.dashboard_url);

                // Display credentials (or the reason they were not created)
                displayCredentials(json.credentials, json.credentials_error || '');

                goTo(1);
            } else {
                const msg = (json && json.error) ? json.error : ('Submission failed (HTTP ' + res.status + ')');
                console.error('Submission error:', msg, json);

                // Show debug info if available
                if (json && json.debug) {
                    console.error('Debug info:', json.debug);
                    alert('❌ Submission Failed\n\n' + msg + '\n\nDebug:\n' +
                          json.debug.message + '\n\nFile: ' + json.debug.file +
                          '\nLine: ' + json.debug.line +
                          '\n\nCheck browser console for more details.');
                }

                showSubmitError(msg);
            }
        } catch (err) {
            showSubmitError('Could not reach the server: ' + err.message);
        } finally {
            if (btn) btn.disabled = false;
        }
    });

    /* ---------- Initial paint ---------- */
    collectTextNodes(document.body);
    collectPlaceholders(document.body);
    initSignaturePads();
    refreshConditionalBlocks();
    if (current) showPage(current);
    setLanguage(currentLang);

    // Try to load saved progress
    loadProgress();

    if (debugMode) {
        const badge = document.createElement('div');
        badge.className = 'debug-badge';
        badge.textContent = 'DEBUG: required-field validation bypassed';
        document.body.appendChild(badge);
    }
})();
