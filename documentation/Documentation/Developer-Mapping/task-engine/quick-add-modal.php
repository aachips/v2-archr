<?php
/**
 * Quick Add Modal &mdash; ARCHR Tasks, Logs &amp; Events
 *
 * Single-line include partial. Drop into any portal page that needs a
 * one-or-two-click capture surface without rendering the full TLE page.
 *
 *   <?php require __DIR__ . '/../../documentation/task-engine/quick-add-modal.php'; ?>
 *
 * After include, any element can open the modal via:
 *   data-quick-add        attribute, OR
 *   onclick="archrQuickAdd.open()"
 *
 * Optional pre-fill variables (set BEFORE the include):
 *   $qa_user_initials  string  &mdash; defaults to 'JD' (POC stub).
 *   $qa_default_case   string  &mdash; pre-fills the Case field.
 *   $qa_default_text   string  &mdash; pre-fills the description.
 *
 * Idempotent: safe to include multiple times per request; markup + assets
 * only emit once via a static guard.
 */
if (!function_exists('archr_quick_add_modal_render')) {
    function archr_quick_add_modal_render($initials = 'JD', $case = '', $text = '') {
        static $rendered = false;
        if ($rendered) { return; }
        $rendered = true;
        $initials = htmlspecialchars($initials, ENT_QUOTES, 'UTF-8');
        $case     = htmlspecialchars($case,     ENT_QUOTES, 'UTF-8');
        $text     = htmlspecialchars($text,     ENT_QUOTES, 'UTF-8');
        ?>
<style>
    /* Self-scoped under #qaModal so host pages can&rsquo;t collide. Uses host
       design tokens when present, with safe fallbacks. */
    #qaModal { position: fixed; inset: 0; background: rgba(15, 23, 30, 0.55);
        display: none; align-items: center; justify-content: center;
        padding: 16px; z-index: 1500; }
    #qaModal.is-open { display: flex; }
    #qaModal .qa-card { background: var(--bg-surface, #fff); color: var(--color-text, #1a1a1a);
        border-radius: var(--radius-lg, 12px); box-shadow: 0 20px 60px rgba(0,0,0,0.30);
        width: 100%; max-width: 520px; max-height: calc(100vh - 32px); overflow: auto;
        border-top: 6px solid var(--tle-accent-deep, #1f4862);
        font-family: var(--font-sans, system-ui, -apple-system, "Segoe UI", sans-serif); }
    #qaModal .qa-head { display: flex; align-items: center; justify-content: space-between;
        padding: 18px 20px; border-bottom: 1px solid var(--color-border, #e3e8ec); }
    #qaModal .qa-head h3 { margin: 0; font-size: 1.1rem; font-family: var(--font-display, inherit);
        display: inline-flex; align-items: center; gap: 8px; }
    #qaModal .qa-head h3 i { color: var(--tle-accent-deep, #1f4862); }
    #qaModal .qa-close { background: none; border: none; font-size: 1.4rem; line-height: 1;
        cursor: pointer; color: var(--color-text-muted, #6b7480); padding: 4px 8px; border-radius: 6px; }
    #qaModal .qa-close:hover { background: var(--bg-surface-alt, #f3f5f7); }
    #qaModal form { padding: 18px 20px; display: grid; gap: 14px; }
    #qaModal label { display: grid; gap: 4px; font-size: 0.85rem; font-weight: 600; }
    #qaModal input[type=text], #qaModal input[type=date], #qaModal input[type=time],
    #qaModal select, #qaModal textarea {
        width: 100%; padding: 10px 12px; border: 1px solid var(--color-border-strong, #c5ccd2);
        border-radius: var(--radius-md, 8px); background: var(--bg-surface, #fff);
        color: var(--color-text, #1a1a1a); font: inherit; font-weight: 400; }
    #qaModal textarea { min-height: 96px; resize: vertical; }
    #qaModal input:focus, #qaModal select:focus, #qaModal textarea:focus {
        outline: none; border-color: var(--tle-accent-deep, #1f4862);
        box-shadow: 0 0 0 3px var(--tle-accent-light, #d6e6f0); }
    #qaModal .qa-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
    @media (max-width: 480px) { #qaModal .qa-row { grid-template-columns: 1fr; } }
    #qaModal .qa-note { display: flex; gap: 8px; padding: 10px 12px;
        background: var(--tle-warn-light, #fdf3df); border: 1px solid var(--tle-warn-border, #f4dfa9);
        color: var(--tle-warn-deep, #8a5a0e); border-radius: var(--radius-md, 8px);
        font-size: 0.8rem; line-height: 1.45; }
    #qaModal .qa-foot { display: flex; gap: 8px; justify-content: flex-end; flex-wrap: wrap;
        padding-top: 4px; }
    #qaModal .qa-btn { padding: 9px 14px; border-radius: var(--radius-md, 8px);
        font: inherit; font-weight: 600; cursor: pointer; border: 1px solid transparent;
        display: inline-flex; gap: 6px; align-items: center; }
    #qaModal .qa-btn.is-primary { background: var(--tle-accent-deep, #1f4862); color: #fff; }
    #qaModal .qa-btn.is-secondary { background: var(--bg-surface-alt, #f3f5f7);
        color: var(--color-text, #1a1a1a); border-color: var(--color-border-strong, #c5ccd2); }
    #qaModal .qa-btn.is-ghost { background: transparent; color: var(--color-text-muted, #6b7480); }
    #qaModal .qa-stamp { font-size: 0.75rem; color: var(--color-text-muted, #6b7480);
        font-variant-numeric: tabular-nums; }
    #qaModal .qa-stamp .qa-chip { background: var(--tle-accent-light, #d6e6f0);
        color: var(--tle-accent-deep, #1f4862); padding: 2px 8px; border-radius: 999px;
        font-weight: 700; margin-right: 6px; }
</style>

<div id="qaModal" role="dialog" aria-modal="true" aria-labelledby="qaTitle" aria-hidden="true">
    <div class="qa-card">
        <div class="qa-head">
            <h3 id="qaTitle"><i class="fas fa-bolt" aria-hidden="true"></i> Quick Add</h3>
            <button type="button" class="qa-close" data-qa-close aria-label="Close">&times;</button>
        </div>
        <form id="qaForm" novalidate>
            <p class="qa-stamp">
                <span class="qa-chip" id="qaWho"><?php echo $initials; ?></span>
                <span id="qaWhen">Stamped on submit</span>
            </p>
            <label>Case
                <input type="text" name="case" id="qaCase" placeholder="Case # or address fragment"
                       value="<?php echo $case; ?>" autocomplete="off" required>
            </label>
            <label>What needs to be done, what happened, or what was said?
                <textarea name="description" id="qaDesc" required
                          placeholder="One fact per line. e.g. Roof needs tarping before storm."><?php echo $text; ?></textarea>
            </label>
            <div class="qa-row">
                <label>Date <input type="date" name="date" id="qaDate" required></label>
                <label>Time <input type="time" name="time" id="qaTime" required></label>
            </div>
            <label>Type
                <select name="type" id="qaType">
                    <option value="task">Task</option>
                    <option value="event">Event</option>
                    <option value="comm">Communication</option>
                    <option value="mixed">Mixed &middot; let Rabbit parse</option>
                </select>
            </label>
            <p class="qa-note">
                <i class="fas fa-circle-info" aria-hidden="true"></i>
                <span>Lands in the <strong>Unverified</strong> queue. A Task Rabbit will
                parse, categorize, and verify before it counts toward metrics.
                See <a href="<?php echo htmlspecialchars(dirname($_SERVER['PHP_SELF']), ENT_QUOTES); ?>/../../documentation/task-engine/sop-entries.md">SOP &middot; Good vs bad entries</a>.</span>
            </p>
            <div class="qa-foot">
                <button type="button" class="qa-btn is-ghost" data-qa-close>Cancel</button>
                <button type="submit" class="qa-btn is-secondary" data-qa-add-another>
                    <i class="fas fa-plus" aria-hidden="true"></i> Save &amp; Add Another
                </button>
                <button type="submit" class="qa-btn is-primary" data-qa-submit>
                    <i class="fas fa-paper-plane" aria-hidden="true"></i> Submit to Unverified
                </button>
            </div>
        </form>
    </div>
</div>

<script>
(function(){
    if (window.archrQuickAdd) { return; }
    var modal = document.getElementById('qaModal');
    var form  = document.getElementById('qaForm');
    var dateF = document.getElementById('qaDate');
    var timeF = document.getElementById('qaTime');
    var whenF = document.getElementById('qaWhen');
    function pad(n){ return n < 10 ? '0' + n : '' + n; }
    function defaults(){
        var d = new Date();
        if (!dateF.value) dateF.value = d.getFullYear() + '-' + pad(d.getMonth()+1) + '-' + pad(d.getDate());
        if (!timeF.value) timeF.value = pad(d.getHours()) + ':' + pad(d.getMinutes());
    }
    function open(prefill){
        defaults();
        if (prefill && prefill.case) document.getElementById('qaCase').value = prefill.case;
        if (prefill && prefill.text) document.getElementById('qaDesc').value = prefill.text;
        modal.classList.add('is-open'); modal.setAttribute('aria-hidden', 'false');
        setTimeout(function(){ document.getElementById('qaCase').focus(); }, 30);
    }
    function close(){ modal.classList.remove('is-open'); modal.setAttribute('aria-hidden', 'true'); }
    modal.addEventListener('click', function(e){
        if (e.target === modal || e.target.closest('[data-qa-close]')) close();
    });
    document.addEventListener('keydown', function(e){
        if (e.key === 'Escape' && modal.classList.contains('is-open')) close();
    });
    document.addEventListener('click', function(e){
        var trigger = e.target.closest('[data-quick-add]');
        if (!trigger) return;
        e.preventDefault();
        open({ case: trigger.getAttribute('data-quick-add-case') || '',
               text: trigger.getAttribute('data-quick-add-text') || '' });
    });
    form.addEventListener('submit', function(e){
        e.preventDefault();
        var payload = {
            case: document.getElementById('qaCase').value.trim(),
            description: document.getElementById('qaDesc').value.trim(),
            date: dateF.value, time: timeF.value,
            type: document.getElementById('qaType').value,
            submitted_by: document.getElementById('qaWho').textContent.trim(),
            submitted_at: new Date().toISOString()
        };
        if (!payload.case || !payload.description) return;
        whenF.textContent = 'Last submitted ' + payload.submitted_at;
        document.dispatchEvent(new CustomEvent('archr:quickAdd:submit', { detail: payload }));
        var addAnother = e.submitter && e.submitter.matches('[data-qa-add-another]');
        if (addAnother) {
            document.getElementById('qaDesc').value = '';
            document.getElementById('qaDesc').focus();
        } else {
            form.reset(); defaults(); close();
        }
    });
    window.archrQuickAdd = { open: open, close: close };
})();
</script>
        <?php
    }
}
// Single-include entry point. Reads optional $qa_* variables from caller scope.
archr_quick_add_modal_render(
    isset($qa_user_initials) ? $qa_user_initials : 'JD',
    isset($qa_default_case)  ? $qa_default_case  : '',
    isset($qa_default_text)  ? $qa_default_text  : ''
);
