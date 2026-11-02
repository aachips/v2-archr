<?php
/**
 * ARCHR · Assessor Component Library
 *
 * Renders every component spec under ./components/*.json with:
 *   - a live preview using the Assessor design system,
 *   - the raw JSON spec (copy-to-clipboard),
 *   - a Softr-ready HTML embed snippet (copy-to-clipboard).
 *
 * The embed snippet follows the di-*-slot / <script type="application/json">
 * hydration pattern defined in components/template.json so a single global
 * JS loader (added once via Softr's site-wide custom code) can mount any
 * component dropped into a Softr custom-code block.
 */

/** Strip leading `//` comment lines, then return [data, purpose, json_str]. */
function archr_parse_component(string $path): array {
    $raw = file_get_contents($path);
    if ($raw === false) return [null, '', ''];
    $purpose_lines = [];
    $json_lines = [];
    $in_json = false;
    foreach (preg_split('/\r\n|\r|\n/', $raw) as $line) {
        $t = trim($line);
        if (!$in_json) {
            if ($t === '') continue;
            if (strncmp($t, '//', 2) === 0) { $purpose_lines[] = ltrim(substr($t, 2)); continue; }
            $in_json = true;
        }
        if ($in_json) $json_lines[] = $line;
    }
    $json_str = trim(implode("\n", $json_lines));
    if ($json_str !== '' && $json_str[0] === '{') {
        $depth = 0; $end = strlen($json_str);
        for ($i = 0, $n = strlen($json_str); $i < $n; $i++) {
            $c = $json_str[$i];
            if ($c === '{') $depth++;
            elseif ($c === '}') { $depth--; if ($depth === 0) { $end = $i + 1; break; } }
        }
        $json_str = substr($json_str, 0, $end);
    }
    $data = json_decode($json_str, true);
    return [$data, trim(implode(' ', $purpose_lines)), $json_str];
}

function archr_slug(string $s): string {
    $s = strtolower(preg_replace('/[^A-Za-z0-9]+/', '-', $s));
    return trim($s, '-');
}

function archr_pretty(array $data): string {
    return json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
}

function archr_label(array $d): string {
    if (!empty($d['component_name'])) return $d['component_name'];
    if (!empty($d['task_name'])) return $d['task_name'];
    if (!empty($d['verification_button_template']['component_name'])) return $d['verification_button_template']['component_name'];
    if (!empty($d['location_tracking'])) return 'GPS & Location Tracking';
    if (!empty($d['offline_mode'])) return 'Offline Mode';
    return 'Untitled Component';
}

function archr_id(array $d): string {
    return $d['component_id'] ?? $d['task_id'] ?? ($d['verification_button_template']['component_id'] ?? '—');
}

function archr_type(array $d): string {
    if (!empty($d['component_type'])) return strtolower($d['component_type']);
    if (!empty($d['task_type'])) return strtolower($d['task_type']);
    if (!empty($d['display_text']) && !empty($d['icon'])) return 'button';
    if (!empty($d['verification_button_template'])) return 'button-template';
    if (!empty($d['location_tracking'])) return 'config';
    if (!empty($d['offline_mode'])) return 'config';
    if (!empty($d['fields']) || !empty($d['required_actions'])) return 'form';
    return 'component';
}

function h($s): string {
    return htmlspecialchars((string)$s, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

if (!function_exists('array_is_list')) {
    function array_is_list(array $a): bool {
        $i = 0;
        foreach ($a as $k => $_) { if ($k !== $i++) return false; }
        return true;
    }
}


// ---- Renderers ----------------------------------------------------------

function archr_render_button(array $d): string {
    $icon  = h($d['icon'] ?? 'fa-circle');
    $label = h($d['display_text'] ?? 'Action');
    $cls   = isset($d['component_class']) ? trim(str_replace('.', ' ', $d['component_class'])) : 'btn btn-primary';
    $href  = h($d['action']['target'] ?? '#');
    return "<a href=\"{$href}\" class=\"{$cls}\"><i class=\"fas {$icon}\"></i> {$label}</a>";
}

function archr_render_button_template(array $d): string {
    $t = $d['verification_button_template'] ?? [];
    $ctx = $t['component_context'] ?? [];
    $cls = isset($t['component_class']) ? trim(str_replace('.', ' ', $t['component_class'])) : 'btn btn-secondary';
    $label = h($ctx['buttonText'] ?? 'Verify {document_type}');
    return "<a href=\"#\" class=\"{$cls}\"><i class=\"fas fa-shield-halved\"></i> {$label}</a>"
        . '<p class="cmp-foot-note"><i class="fas fa-info-circle"></i> Template &mdash; <code>{document_type}</code> &amp; <code>{document_code}</code> resolve per document.</p>';
}

function archr_render_card(array $d): string {
    $title = h(archr_label($d));
    $rows = '';
    foreach (($d['data_sources'] ?? []) as $k => $v) {
        $rows .= '<div class="la-row"><span class="la-label">' . h(str_replace('_', ' ', $k)) . '</span><span class="la-value">' . h($v) . '</span></div>';
    }
    $btns = '';
    foreach (($d['actions'] ?? []) as $a) {
        $btns .= '<a href="#" class="btn btn-secondary btn-sm">' . h($a['label'] ?? 'Action') . '</a> ';
    }
    return '<article class="last-assessment">'
        . '<div><div class="la-address">' . $title . '</div>' . $rows . '</div>'
        . '<div class="la-actions">' . $btns . '</div>'
        . '</article>';
}

function archr_render_calendar(array $d): string {
    $days = [['Mon','9',1],['Tue','10',0],['Wed','11',1],['Thu','12',3],['Fri','13',0],['Sat','14',1],['Sun','15',0]];
    $cells = '';
    foreach ($days as $i => $day) {
        [$n, $num, $dots] = $day;
        $today = $i === 3 ? ' is-today' : '';
        $cells .= '<div class="week-day' . $today . '"><div class="wd-name">' . $n . '</div><div class="wd-num">' . $num . '</div><div class="wd-dots">' . str_repeat('<span class="wd-dot"></span>', $dots) . '</div></div>';
    }
    return '<div class="week-cal" role="list">' . $cells . '</div>'
        . '<p class="week-cal-foot"><strong>Today:</strong> 3 assessments &middot; <strong>This week:</strong> 6 total</p>';
}

function archr_sample_list_items(string $id): string {
    if (strpos($id, 'message') !== false || strpos($id, 'msg') !== false) {
        return '<li class="msg-item"><div class="msg-from">Sarah Williams <span class="pill" style="margin-left:6px;">Client</span></div>'
            . '<div class="msg-body">"Please call when you arrive &mdash; the gate code changed."</div>'
            . '<div class="msg-meta"><span>15 Merrill Ave &middot; 22 min ago</span><a href="#" class="btn btn-secondary btn-sm">Read</a></div></li>'
            . '<li class="msg-item is-system"><div class="msg-from">System <span class="pill" style="margin-left:6px;">Assignment</span></div>'
            . '<div class="msg-body">New assessment assigned: <strong>19 Riverside Dr</strong>.</div>'
            . '<div class="msg-meta"><span>Today, 8:47 AM</span><a href="#" class="btn btn-secondary btn-sm">Open</a></div></li>';
    }
    if (strpos($id, 'previous') !== false) {
        return '<li class="assess-item is-completed"><div class="ai-time">Dec 10</div>'
            . '<div><div class="ai-addr">8 Oakland Rd, Asheville</div>'
            . '<div class="ai-meta"><span>James Thornton</span><span><i class="fas fa-camera"></i> 14 photos</span><span class="pill pill-green"><i class="fas fa-circle-check"></i> Completed</span></div></div>'
            . '<div class="ai-actions"><a href="#" class="btn btn-secondary btn-sm">View</a></div></li>'
            . '<li class="assess-item"><div class="ai-time">Dec 6</div>'
            . '<div><div class="ai-addr">3 Sunset Ln, Asheville</div>'
            . '<div class="ai-meta"><span>Robert Chen</span><span class="pill pill-amber"><i class="fas fa-pen-to-square"></i> Draft</span></div></div>'
            . '<div class="ai-actions"><a href="#" class="btn btn-secondary btn-sm">Resubmit</a></div></li>';
    }
    return '<li class="assess-item is-inprogress"><div class="ai-time">9:00 AM</div>'
        . '<div><div class="ai-addr">42 Cherry St, Asheville</div>'
        . '<div class="ai-meta"><span><i class="fas fa-stopwatch"></i> 2.0 hours</span><span><i class="fas fa-location-dot"></i> 2.3 mi</span><span class="pill pill-amber"><i class="fas fa-spinner"></i> In progress</span></div></div>'
        . '<div class="ai-actions"><a href="#" class="btn btn-secondary btn-sm"><i class="fas fa-play"></i> Resume</a></div></li>'
        . '<li class="assess-item"><div class="ai-time">11:00 AM</div>'
        . '<div><div class="ai-addr">15 Merrill Ave, Asheville</div>'
        . '<div class="ai-meta"><span><i class="fas fa-stopwatch"></i> 1.5 hours</span><span><i class="fas fa-location-dot"></i> 4.1 mi</span><span class="pill pill-teal"><i class="fas fa-calendar-check"></i> Scheduled</span></div></div>'
        . '<div class="ai-actions"><a href="#" class="btn btn-secondary btn-sm"><i class="fas fa-route"></i> Directions</a></div></li>';
}

function archr_render_list(array $d): string {
    $id = $d['component_id'] ?? '';
    $is_msg = strpos($id, 'message') !== false || strpos($id, 'msg') !== false;
    $listCls = $is_msg ? 'msg-list' : 'assess-list';
    return '<ul class="' . $listCls . '">' . archr_sample_list_items($id) . '</ul>';
}


function archr_render_field(array $f): string {
    $name = h($f['name'] ?? '');
    $label = h($f['label'] ?? $name);
    $type = strtolower($f['type'] ?? 'text');
    $req = !empty($f['required']) ? ' required' : '';
    $req_mark = !empty($f['required']) ? ' <span class="cmp-req" aria-hidden="true">*</span>' : '';
    $ph = isset($f['placeholder']) ? ' placeholder="' . h($f['placeholder']) . '"' : '';
    $opts = $f['options'] ?? [];
    $out  = '<div class="cmp-field cmp-field--' . h($type) . '">';
    $out .= '<label for="f_' . $name . '">' . $label . $req_mark . '</label>';
    switch ($type) {
        case 'select':
            $out .= '<select id="f_' . $name . '" name="' . $name . '"' . $req . '>';
            foreach ($opts as $o) $out .= '<option>' . h(is_array($o) ? ($o['label'] ?? '') : $o) . '</option>';
            $out .= '</select>';
            break;
        case 'textarea':
            $out .= '<textarea id="f_' . $name . '" name="' . $name . '" rows="3"' . $ph . $req . '></textarea>';
            break;
        case 'checkbox':
        case 'boolean':
            $def = !empty($f['default']) ? ' checked' : '';
            $out .= '<input type="checkbox" id="f_' . $name . '" name="' . $name . '"' . $def . '>';
            break;
        case 'date':   $out .= '<input type="date" id="f_' . $name . '" name="' . $name . '"' . $req . '>'; break;
        case 'time':   $out .= '<input type="time" id="f_' . $name . '" name="' . $name . '"' . $req . '>'; break;
        case 'number': $out .= '<input type="number" id="f_' . $name . '" name="' . $name . '"' . $ph . $req . '>'; break;
        case 'currency': $out .= '<input type="number" step="0.01" id="f_' . $name . '" name="' . $name . '"' . $ph . $req . '>'; break;
        case 'file':   $out .= '<input type="file" id="f_' . $name . '" name="' . $name . '"' . $req . '>'; break;
        case 'camera': $out .= '<input type="file" accept="image/*" capture="environment" id="f_' . $name . '" name="' . $name . '" multiple>'; break;
        default:       $out .= '<input type="text" id="f_' . $name . '" name="' . $name . '"' . $ph . $req . '>';
    }
    $out .= '</div>';
    return $out;
}

function archr_render_form(array $d): string {
    $title = h(archr_label($d));
    $body = '';
    foreach (($d['fields'] ?? []) as $f) $body .= archr_render_field($f);
    foreach (($d['required_actions'] ?? []) as $a) {
        if (!empty($a['fields'])) { foreach ($a['fields'] as $f) $body .= archr_render_field($f); continue; }
        $body .= archr_render_field([
            'name'  => $a['action'] ?? 'action',
            'label' => $a['label'] ?? ($a['action'] ?? 'Action'),
            'type'  => $a['type'] ?? 'text',
            'options' => $a['options'] ?? null,
            'required' => !empty($a['required']),
        ]);
    }
    return '<form class="cmp-form" onsubmit="event.preventDefault();return false;">'
        . '<fieldset><legend>' . $title . '</legend>' . $body
        . '<div class="cmp-form-actions"><button type="submit" class="btn btn-primary"><i class="fas fa-check"></i> Submit</button></div>'
        . '</fieldset></form>';
}

function archr_render_config(array $d): string {
    $rows = '';
    $walk = function ($node, $prefix = '') use (&$walk, &$rows) {
        foreach ($node as $k => $v) {
            $label = h(($prefix ? $prefix . ' &rsaquo; ' : '') . str_replace('_', ' ', (string)$k));
            if (is_array($v)) {
                if (array_is_list($v)) {
                    $vals = array_map(fn($x) => is_scalar($x) ? (string)$x : json_encode($x), $v);
                    $rows .= '<div class="cmp-kv"><dt>' . $label . '</dt><dd>' . h(implode(', ', $vals)) . '</dd></div>';
                } else {
                    $walk($v, $prefix ? $prefix . ' › ' . $k : (string)$k);
                }
            } else {
                $rows .= '<div class="cmp-kv"><dt>' . $label . '</dt><dd>' . h((string)$v) . '</dd></div>';
            }
        }
    };
    $walk($d);
    return '<dl class="cmp-config">' . $rows . '</dl>'
        . '<p class="cmp-foot-note"><i class="fas fa-gear"></i> Configuration spec &mdash; no visual surface. Consumed by the platform runtime.</p>';
}

function archr_render(array $d): string {
    switch (archr_type($d)) {
        case 'button':          return archr_render_button($d);
        case 'button-template': return archr_render_button_template($d);
        case 'card':            return archr_render_card($d);
        case 'list':            return archr_render_list($d);
        case 'calendar':        return archr_render_calendar($d);
        case 'config':          return archr_render_config($d);
        default:                return archr_render_form($d);
    }
}

/** Build the Softr-ready embed snippet (visible markup + <script> config). */
function archr_embed(array $d, string $slug, string $rendered_html): string {
    $json = archr_pretty($d);
    $json_indented = '      ' . str_replace("\n", "\n      ", $json);
    $rendered_indented = '  ' . str_replace("\n", "\n  ", trim($rendered_html));
    return "<!-- ARCHR component: " . archr_label($d) . " -->\n"
        . "<div class=\"di-{$slug}-slot archr-cmp\" data-component-id=\"" . h(archr_id($d)) . "\">\n"
        . "  <script type=\"application/json\" class=\"{$slug}-json\">\n"
        . $json_indented . "\n"
        . "  </script>\n"
        . "  <div class=\"di-{$slug}-mount\">\n"
        . $rendered_indented . "\n"
        . "  </div>\n"
        . "</div>";
}


// ---- Load all components ------------------------------------------------

$component_dir = __DIR__ . DIRECTORY_SEPARATOR . 'components';
$component_files = glob($component_dir . DIRECTORY_SEPARATOR . '*.json') ?: [];
sort($component_files, SORT_NATURAL | SORT_FLAG_CASE);

$components = [];
foreach ($component_files as $file) {
    [$data, $purpose, $json_str] = archr_parse_component($file);
    if (!is_array($data)) continue;
    $slug = archr_slug(pathinfo($file, PATHINFO_FILENAME));
    $components[] = [
        'file'    => basename($file),
        'slug'    => $slug,
        'data'    => $data,
        'purpose' => $purpose,
        'json'    => $json_str,
    ];
}

// Group buckets for the in-page index (type-based).
$buckets = [];
foreach ($components as $c) {
    $t = archr_type($c['data']);
    $buckets[$t][] = $c;
}
ksort($buckets);

$type_label = [
    'button'           => 'Buttons',
    'button-template'  => 'Button Templates',
    'card'             => 'Cards',
    'list'             => 'Lists',
    'calendar'         => 'Calendars',
    'form'             => 'Forms',
    'documentation'    => 'Documentation Forms',
    'document_verification' => 'Document Verification Forms',
    'document_collection'   => 'Document Collection Forms',
    'document_upload'  => 'Document Upload Forms',
    'communication'    => 'Communication Forms',
    'scheduling'       => 'Scheduling Forms',
    'review'           => 'Review Forms',
    'planning'         => 'Planning Forms',
    'field_work'       => 'Field-Work Forms',
    'config'           => 'Configuration',
    'component'        => 'Other',
];
?>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ARCHR &middot; Assessor Component Library</title>
<link rel="icon" type="image/svg+xml" href="../../archr-logo.svg">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&family=Open+Sans:wght@400;600&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
<script>(function(){try{var t=localStorage.getItem('archr-theme');if(t!=='light'&&t!=='dark'){t=window.matchMedia&&window.matchMedia('(prefers-color-scheme: dark)').matches?'dark':'light';}document.documentElement.setAttribute('data-theme',t);}catch(e){}})();</script>

<style>
/* =========================================================================
   ARCHR Component Library — Assessor role.
   Mirrors the Assessor dashboard (assessor.html) design tokens so previews
   render identically to what users see in the live portal.
   ========================================================================= */
* { margin: 0; padding: 0; box-sizing: border-box; }
:root {
    --role-assessor: #219BA4;
    --role-assessor-deep: #14707a;
    --role-assessor-light: #d4eaec;
    --role-assessor-canvas: #ecf5f6;
    --color-primary: #E04E39; --color-primary-dark: #C23A26;
    --color-secondary: #2A5C82;
    --color-success: #2f9e69; --color-warning: #d99518; --color-danger: #c23a26;
    --bg-page: #f5f7fb; --bg-surface: #ffffff; --bg-surface-alt: #f3f5fa;
    --color-text: #1e293b; --color-text-muted: #5b6b85;
    --color-border: #e2e8f0; --color-border-strong: #cfd6e4;
    --font-sans: 'Open Sans', system-ui, sans-serif;
    --font-display: 'Poppins', system-ui, sans-serif;
    --font-mono: 'JetBrains Mono', ui-monospace, Menlo, Consolas, monospace;
    --fs-xs: 0.75rem; --fs-sm: 0.875rem; --fs-base: 1rem; --fs-md: 1.125rem; --fs-lg: 1.25rem; --fs-xl: 1.5rem; --fs-2xl: 2rem;
    --space-1: 0.25rem; --space-2: 0.5rem; --space-3: 0.75rem; --space-4: 1rem; --space-5: 1.25rem; --space-6: 1.5rem; --space-8: 2rem;
    --radius-sm: 0.3rem; --radius-md: 0.6rem; --radius-lg: 1rem; --radius-pill: 999px;
    --shadow-sm: 0 2px 6px rgba(0,0,0,0.06); --shadow: 0 6px 18px rgba(0,0,0,0.08);
    --transition: all 0.18s ease;
    --border-radius: var(--radius-md);
}
[data-theme="dark"] {
    --role-assessor-canvas: #16292c;
    --role-assessor-light: #1f3a3d;
    --bg-page: #0f1622; --bg-surface: #182231; --bg-surface-alt: #202b3d;
    --color-text: #e6ecf5; --color-text-muted: #9aa7bd;
    --color-border: #2a3447; --color-border-strong: #3a455c;
    --shadow-sm: 0 2px 6px rgba(0,0,0,0.3);
}
body { font-family: var(--font-sans); color: var(--color-text); background: var(--role-assessor-canvas); }

/* ---- Page chrome ---- */
.lib-topbar {
    display: flex; align-items: center; justify-content: space-between; gap: var(--space-4);
    padding: var(--space-4) var(--space-6);
    background: var(--bg-surface); border-bottom: 1px solid var(--color-border);
    position: sticky; top: 0; z-index: 10;
}
.lib-brand { display: inline-flex; align-items: center; gap: var(--space-3); text-decoration: none; color: var(--color-text); font-family: var(--font-display); font-weight: 700; }
.lib-brand img { height: 26px; }
.lib-brand small { font-weight: 400; color: var(--color-text-muted); margin-left: var(--space-2); font-size: var(--fs-sm); }
.lib-topbar-right { display: flex; gap: var(--space-3); align-items: center; }
.role-badge { padding: 6px 14px; border-radius: var(--radius-pill); font-size: var(--fs-xs); font-weight: 700; background: var(--role-assessor-light); color: var(--role-assessor-deep); border: 1px solid #b9dde1; display: inline-flex; align-items: center; gap: 6px; }
.theme-toggle { background: transparent; border: 1px solid var(--color-border); border-radius: var(--radius-pill); width: 40px; height: 40px; cursor: pointer; color: var(--color-text); }

.lib-wrap { max-width: 1180px; margin: 0 auto; padding: var(--space-6); }
.lib-hero { background: linear-gradient(135deg, var(--role-assessor-deep), #0e4c54); color: #fff; border-radius: var(--radius-lg); padding: var(--space-6) var(--space-8); margin-bottom: var(--space-6); }
.lib-hero h1 { font-family: var(--font-display); font-size: var(--fs-2xl); margin-bottom: var(--space-2); }
.lib-hero p { opacity: 0.92; font-size: var(--fs-sm); max-width: 70ch; }
.lib-hero a { color: #fff; text-decoration: underline; }

/* ---- Index ---- */
.lib-index { background: var(--bg-surface); border: 1px solid var(--color-border); border-radius: var(--radius-md); padding: var(--space-5); margin-bottom: var(--space-6); }
.lib-index h2 { font-family: var(--font-display); font-size: var(--fs-md); margin-bottom: var(--space-3); display: flex; align-items: center; gap: var(--space-2); }
.lib-index h2 i { color: var(--role-assessor-deep); }
.lib-index ul { list-style: none; columns: 2; column-gap: var(--space-6); }
.lib-index li { break-inside: avoid; padding: 2px 0; }
.lib-index a { color: var(--color-text); text-decoration: none; font-size: var(--fs-sm); }
.lib-index a:hover { color: var(--role-assessor-deep); text-decoration: underline; }
.lib-index .ix-group { font-weight: 700; color: var(--role-assessor-deep); margin-top: var(--space-2); display: block; font-size: var(--fs-xs); text-transform: uppercase; letter-spacing: 0.06em; }

/* ---- Component card ---- */
.cmp { background: var(--bg-surface); border: 1px solid var(--color-border); border-radius: var(--radius-md); margin-bottom: var(--space-6); overflow: hidden; box-shadow: var(--shadow-sm); }
.cmp-head { padding: var(--space-4) var(--space-5); border-bottom: 1px solid var(--color-border); display: grid; grid-template-columns: 1fr auto; gap: var(--space-3); align-items: center; }
.cmp-head h3 { font-family: var(--font-display); font-size: var(--fs-lg); margin: 0; }
.cmp-head .cmp-id { font-family: var(--font-mono); font-size: var(--fs-xs); color: var(--color-text-muted); }
.cmp-head .cmp-meta { display: flex; gap: var(--space-2); align-items: center; flex-wrap: wrap; justify-content: flex-end; }
.cmp-type { display: inline-flex; align-items: center; gap: 4px; padding: 2px 10px; border-radius: var(--radius-pill); font-size: var(--fs-xs); font-weight: 600; background: var(--role-assessor-light); color: var(--role-assessor-deep); border: 1px solid #b9dde1; text-transform: uppercase; letter-spacing: 0.04em; }
.cmp-file { font-family: var(--font-mono); font-size: var(--fs-xs); color: var(--color-text-muted); text-decoration: none; }
.cmp-file:hover { color: var(--role-assessor-deep); text-decoration: underline; }
.cmp-purpose { padding: var(--space-3) var(--space-5); color: var(--color-text-muted); font-size: var(--fs-sm); border-bottom: 1px solid var(--color-border); background: var(--bg-surface-alt); }
.cmp-section { padding: var(--space-4) var(--space-5); border-bottom: 1px solid var(--color-border); }
.cmp-section:last-child { border-bottom: 0; }
.cmp-section-head { display: flex; justify-content: space-between; align-items: center; margin-bottom: var(--space-3); }
.cmp-section-head h4 { font-family: var(--font-display); font-size: var(--fs-sm); text-transform: uppercase; letter-spacing: 0.06em; color: var(--color-text-muted); margin: 0; }
.cmp-preview { background: var(--role-assessor-canvas); border: 1px dashed var(--color-border-strong); border-radius: var(--radius-md); padding: var(--space-5); }
.cmp-code-wrap { position: relative; }
.cmp-code { display: block; background: #0f1622; color: #e6ecf5; padding: var(--space-4); border-radius: var(--radius-md); font-family: var(--font-mono); font-size: var(--fs-xs); line-height: 1.55; overflow-x: auto; max-height: 360px; overflow-y: auto; white-space: pre; }
.cmp-copy { position: absolute; top: var(--space-2); right: var(--space-2); background: rgba(255,255,255,0.08); color: #fff; border: 1px solid rgba(255,255,255,0.18); border-radius: var(--radius-sm); padding: 4px 10px; font-size: var(--fs-xs); cursor: pointer; font-family: var(--font-sans); }
.cmp-copy:hover { background: rgba(255,255,255,0.18); }
.cmp-copy.is-copied { background: var(--color-success); border-color: var(--color-success); }

/* ---- Form preview ---- */
.cmp-form fieldset { border: 1px solid var(--color-border); border-radius: var(--radius-md); padding: var(--space-4); background: var(--bg-surface); }
.cmp-form legend { padding: 0 var(--space-2); font-family: var(--font-display); font-weight: 600; color: var(--role-assessor-deep); }
.cmp-field { display: grid; gap: var(--space-1); margin-bottom: var(--space-3); }
.cmp-field label { font-size: var(--fs-sm); font-weight: 600; color: var(--color-text); }
.cmp-field input, .cmp-field select, .cmp-field textarea { font-family: inherit; font-size: var(--fs-sm); padding: 8px 10px; border: 1px solid var(--color-border-strong); border-radius: var(--radius-sm); background: var(--bg-surface); color: var(--color-text); }
.cmp-field input[type=checkbox] { width: auto; justify-self: start; }
.cmp-req { color: var(--color-danger); }
.cmp-form-actions { margin-top: var(--space-3); display: flex; justify-content: flex-end; }

/* ---- Config dl ---- */
.cmp-config { display: grid; grid-template-columns: minmax(220px, 1fr) 2fr; gap: 0; background: var(--bg-surface); border: 1px solid var(--color-border); border-radius: var(--radius-md); overflow: hidden; }
.cmp-config .cmp-kv { display: contents; }
.cmp-config dt { padding: 8px 12px; border-bottom: 1px solid var(--color-border); background: var(--bg-surface-alt); font-size: var(--fs-xs); font-weight: 600; text-transform: uppercase; letter-spacing: 0.04em; color: var(--color-text-muted); }
.cmp-config dd { padding: 8px 12px; border-bottom: 1px solid var(--color-border); font-size: var(--fs-sm); }
.cmp-config .cmp-kv:last-child dt, .cmp-config .cmp-kv:last-child dd { border-bottom: 0; }
.cmp-foot-note { margin-top: var(--space-3); font-size: var(--fs-xs); color: var(--color-text-muted); display: inline-flex; align-items: center; gap: 6px; }
.cmp-foot-note code { font-family: var(--font-mono); }

/* ---- Reusable: copy of assessor dashboard styles needed for previews ---- */
.btn { display: inline-flex; align-items: center; gap: 8px; padding: 10px 22px; border-radius: var(--border-radius); font-weight: 600; text-decoration: none; cursor: pointer; transition: var(--transition); border: 2px solid transparent; font-family: inherit; font-size: var(--fs-sm); }
.btn-primary { background: var(--color-primary); color: white; }
.btn-primary:hover { background: var(--color-primary-dark); }
.btn-secondary { background: var(--bg-surface); color: var(--color-secondary); border-color: var(--color-secondary); }
.btn-secondary:hover { background: var(--color-secondary); color: white; }
.btn-verify { background: var(--role-assessor-deep); color: white; }
.btn-verify:hover { background: var(--role-assessor); }
.btn-sm { padding: 6px 14px; font-size: var(--fs-xs); }

.last-assessment { display: grid; grid-template-columns: 1fr auto; gap: var(--space-4); align-items: center; padding: var(--space-5); background: var(--bg-surface); border: 1px solid var(--color-border-strong); border-left: 4px solid var(--role-assessor-deep); border-radius: var(--radius-md); }
.last-assessment .la-address { font-family: var(--font-display); font-size: var(--fs-lg); font-weight: 700; color: var(--color-text); }
.last-assessment .la-row { display: grid; grid-template-columns: 130px 1fr; gap: var(--space-2); margin-top: var(--space-2); font-size: var(--fs-sm); }
.last-assessment .la-label { color: var(--color-text-muted); text-transform: uppercase; letter-spacing: 0.04em; font-size: var(--fs-xs); font-weight: 600; }
.last-assessment .la-actions { display: flex; gap: var(--space-2); }

.week-cal { display: grid; grid-template-columns: repeat(7, 1fr); gap: var(--space-2); margin-bottom: var(--space-3); }
.week-day { text-align: center; padding: var(--space-3) var(--space-2); background: var(--bg-surface-alt); border: 1px solid var(--color-border); border-radius: var(--radius-md); }
.week-day.is-today { background: var(--role-assessor-light); border-color: var(--role-assessor-deep); }
.week-day .wd-name { font-size: var(--fs-xs); text-transform: uppercase; letter-spacing: 0.06em; color: var(--color-text-muted); font-weight: 600; }
.week-day .wd-num { font-family: var(--font-display); font-weight: 700; font-size: var(--fs-lg); }
.week-day .wd-dots { margin-top: 4px; min-height: 8px; display: flex; gap: 3px; justify-content: center; }
.week-day .wd-dot { width: 6px; height: 6px; border-radius: 50%; background: var(--role-assessor-deep); }
.week-cal-foot { font-size: var(--fs-sm); color: var(--color-text-muted); }

.assess-list, .msg-list { list-style: none; padding: 0; margin: 0; display: grid; gap: var(--space-3); }
.assess-item { display: grid; grid-template-columns: auto 1fr auto; gap: var(--space-3); align-items: center; padding: var(--space-3) var(--space-4); background: var(--bg-surface-alt); border: 1px solid var(--color-border-strong); border-radius: var(--radius-md); border-left: 4px solid var(--role-assessor-deep); }
.assess-item.is-inprogress { border-left-color: var(--color-warning); }
.assess-item.is-completed { border-left-color: var(--color-success); }
.assess-item .ai-time { font-family: var(--font-display); font-weight: 700; min-width: 80px; }
.assess-item .ai-addr { font-weight: 600; }
.assess-item .ai-meta { font-size: var(--fs-xs); color: var(--color-text-muted); display: flex; flex-wrap: wrap; gap: var(--space-3); margin-top: 2px; }
.assess-item .ai-meta i { color: var(--role-assessor-deep); margin-right: 2px; }

.msg-item { padding: var(--space-3) var(--space-4); background: var(--bg-surface-alt); border: 1px solid var(--color-border-strong); border-radius: var(--radius-md); border-left: 4px solid var(--role-assessor-deep); }
.msg-item.is-system { border-left-color: var(--color-secondary); }
.msg-item .msg-from { font-weight: 700; }
.msg-item .msg-body { font-size: var(--fs-sm); margin-top: 2px; }
.msg-item .msg-meta { font-size: var(--fs-xs); color: var(--color-text-muted); margin-top: var(--space-2); display: flex; align-items: center; justify-content: space-between; gap: var(--space-2); }

.pill { display: inline-flex; align-items: center; gap: 4px; padding: 2px 10px; border-radius: var(--radius-pill); font-size: var(--fs-xs); font-weight: 600; background: var(--bg-surface-alt); color: var(--color-text); border: 1px solid var(--color-border); }
.pill-teal { background: var(--role-assessor-light); color: var(--role-assessor-deep); border-color: #b9dde1; }
.pill-amber { background: #fdf3df; color: #8a5a0e; border-color: #f4dfa9; }
.pill-green { background: #d9f2d9; color: #1d8a3a; border-color: #b9e0bd; }

@media (max-width: 700px) {
    .lib-index ul { columns: 1; }
    .cmp-head { grid-template-columns: 1fr; }
    .cmp-head .cmp-meta { justify-content: flex-start; }
    .cmp-config { grid-template-columns: 1fr; }
    .last-assessment, .assess-item { grid-template-columns: 1fr; }
}
</style>
</head>

<body>

<header class="lib-topbar">
    <a href="assessor.html" class="lib-brand">
        <img src="../../archr-logo.svg" alt="">
        <span>ARCHR Component Library<small>Assessor role</small></span>
    </a>
    <div class="lib-topbar-right">
        <span class="role-badge"><i class="fas fa-tape"></i> Assessor</span>
        <a href="assessor.html" class="btn btn-secondary btn-sm"><i class="fas fa-gauge-high"></i> View live dashboard</a>
        <button type="button" class="theme-toggle" id="themeToggle" aria-label="Toggle dark mode"><i class="fas fa-circle-half-stroke"></i></button>
    </div>
</header>

<main class="lib-wrap">

    <section class="lib-hero">
        <h1>Assessor Component Library</h1>
        <p>
            Every component listed under <code>interface/assessor/components/</code> rendered with
            its live preview, copy-and-paste <strong>JSON spec</strong>, and a Softr-ready
            <strong>HTML embed snippet</strong>. The embed wrappers follow the
            <code>di-{component}-slot</code> / <code>&lt;script type="application/json"&gt;</code>
            hydration pattern from <code>components/template.json</code>, so a single global
            JS loader can mount any component dropped into a Softr custom code block. See
            <a href="https://docs.softr.io/custom-code/custom-code-block-overview" target="_blank" rel="noopener">Softr custom code docs</a>.
        </p>
    </section>

    <section class="cmp" id="how-to-use" aria-labelledby="how-to-h">
        <div class="cmp-head"><h3 id="how-to-h">How to use these in Softr</h3><div class="cmp-meta"><span class="cmp-type">Setup</span></div></div>
        <div class="cmp-purpose">
            Softr custom code blocks accept HTML/CSS/JS inline. Add the Assessor design tokens
            <strong>once</strong> as page-level or site-wide CSS, then drop any component's HTML
            snippet into an inline custom code block. The optional JS loader below replaces the
            static sample markup with live data once the platform hydration layer is in place.
        </div>
        <div class="cmp-section">
            <div class="cmp-section-head">
                <h4><i class="fas fa-palette"></i> Global CSS &mdash; paste once into Softr &rsaquo; Custom Code &rsaquo; Header</h4>
                <span class="cmp-foot-note">Same tokens as <code>assessor.html</code>.</span>
            </div>
            <div class="cmp-code-wrap">
                <button type="button" class="cmp-copy" data-copy="#global-css-code">Copy</button>
                <code class="cmp-code" id="global-css-code">&lt;link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"&gt;
&lt;link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&amp;family=Open+Sans:wght@400;600&amp;display=swap" rel="stylesheet"&gt;
&lt;style&gt;
:root{
  --role-assessor:#219BA4;--role-assessor-deep:#14707a;--role-assessor-light:#d4eaec;--role-assessor-canvas:#ecf5f6;
  --color-primary:#E04E39;--color-primary-dark:#C23A26;--color-secondary:#2A5C82;
  --color-success:#2f9e69;--color-warning:#d99518;--color-danger:#c23a26;
  --bg-surface:#fff;--bg-surface-alt:#f3f5fa;--color-text:#1e293b;--color-text-muted:#5b6b85;
  --color-border:#e2e8f0;--color-border-strong:#cfd6e4;
  --font-sans:'Open Sans',system-ui,sans-serif;--font-display:'Poppins',system-ui,sans-serif;
  --fs-xs:.75rem;--fs-sm:.875rem;--fs-md:1.125rem;--fs-lg:1.25rem;
  --space-1:.25rem;--space-2:.5rem;--space-3:.75rem;--space-4:1rem;--space-5:1.25rem;
  --radius-sm:.3rem;--radius-md:.6rem;--radius-pill:999px;
}
body.archr-assessor{background:var(--role-assessor-canvas);font-family:var(--font-sans);color:var(--color-text);}
.btn{display:inline-flex;align-items:center;gap:8px;padding:10px 22px;border-radius:var(--radius-md);font-weight:600;text-decoration:none;cursor:pointer;border:2px solid transparent;font-size:var(--fs-sm);}
.btn-primary{background:var(--color-primary);color:#fff;}.btn-primary:hover{background:var(--color-primary-dark);}
.btn-secondary{background:var(--bg-surface);color:var(--color-secondary);border-color:var(--color-secondary);}
.btn-secondary:hover{background:var(--color-secondary);color:#fff;}
.btn-verify{background:var(--role-assessor-deep);color:#fff;}.btn-verify:hover{background:var(--role-assessor);}
.btn-sm{padding:6px 14px;font-size:var(--fs-xs);}
.pill{display:inline-flex;align-items:center;gap:4px;padding:2px 10px;border-radius:var(--radius-pill);font-size:var(--fs-xs);font-weight:600;background:var(--bg-surface-alt);color:var(--color-text);border:1px solid var(--color-border);}
.pill-teal{background:var(--role-assessor-light);color:var(--role-assessor-deep);border-color:#b9dde1;}
.pill-amber{background:#fdf3df;color:#8a5a0e;border-color:#f4dfa9;}
.pill-green{background:#d9f2d9;color:#1d8a3a;border-color:#b9e0bd;}
.last-assessment{display:grid;grid-template-columns:1fr auto;gap:1rem;padding:1.25rem;background:var(--bg-surface);border:1px solid var(--color-border-strong);border-left:4px solid var(--role-assessor-deep);border-radius:var(--radius-md);}
.la-address{font-family:var(--font-display);font-weight:700;font-size:var(--fs-lg);}
.la-row{display:grid;grid-template-columns:130px 1fr;gap:.5rem;margin-top:.5rem;font-size:var(--fs-sm);}
.la-label{color:var(--color-text-muted);text-transform:uppercase;letter-spacing:.04em;font-size:var(--fs-xs);font-weight:600;}
.la-actions{display:flex;gap:.5rem;}
.assess-list,.msg-list{list-style:none;padding:0;margin:0;display:grid;gap:.75rem;}
.assess-item{display:grid;grid-template-columns:auto 1fr auto;gap:.75rem;align-items:center;padding:.75rem 1rem;background:var(--bg-surface-alt);border:1px solid var(--color-border-strong);border-radius:var(--radius-md);border-left:4px solid var(--role-assessor-deep);}
.assess-item.is-inprogress{border-left-color:var(--color-warning);}.assess-item.is-completed{border-left-color:var(--color-success);}
.ai-time{font-family:var(--font-display);font-weight:700;min-width:80px;}
.ai-addr{font-weight:600;}.ai-meta{font-size:var(--fs-xs);color:var(--color-text-muted);display:flex;flex-wrap:wrap;gap:.75rem;margin-top:2px;}
.ai-actions{display:flex;gap:.5rem;}
.msg-item{padding:.75rem 1rem;background:var(--bg-surface-alt);border:1px solid var(--color-border-strong);border-radius:var(--radius-md);border-left:4px solid var(--role-assessor-deep);}
.msg-item.is-system{border-left-color:var(--color-secondary);}
.msg-from{font-weight:700;}.msg-body{font-size:var(--fs-sm);margin-top:2px;}
.msg-meta{font-size:var(--fs-xs);color:var(--color-text-muted);margin-top:.5rem;display:flex;align-items:center;justify-content:space-between;gap:.5rem;}
.week-cal{display:grid;grid-template-columns:repeat(7,1fr);gap:.5rem;margin-bottom:.75rem;}
.week-day{text-align:center;padding:.75rem .5rem;background:var(--bg-surface-alt);border:1px solid var(--color-border);border-radius:var(--radius-md);}
.week-day.is-today{background:var(--role-assessor-light);border-color:var(--role-assessor-deep);}
.wd-name{font-size:var(--fs-xs);text-transform:uppercase;letter-spacing:.06em;color:var(--color-text-muted);font-weight:600;}
.wd-num{font-family:var(--font-display);font-weight:700;font-size:var(--fs-lg);}
.wd-dots{margin-top:4px;display:flex;gap:3px;justify-content:center;min-height:8px;}
.wd-dot{width:6px;height:6px;border-radius:50%;background:var(--role-assessor-deep);}
.week-cal-foot{font-size:var(--fs-sm);color:var(--color-text-muted);}
&lt;/style&gt;</code>
            </div>
        </div>
        <div class="cmp-section">
            <div class="cmp-section-head">
                <h4><i class="fab fa-js"></i> Global JS loader &mdash; paste once into Softr &rsaquo; Custom Code &rsaquo; Footer</h4>
                <span class="cmp-foot-note">Hydrates every <code>di-*-slot</code> on the page.</span>
            </div>
            <div class="cmp-code-wrap">
                <button type="button" class="cmp-copy" data-copy="#global-js-code">Copy</button>
                <code class="cmp-code" id="global-js-code">&lt;script&gt;
(function(){
  /* Find every ARCHR component slot and emit a 'archr:mount' event with its
     parsed JSON config. Page-level scripts or a future global runtime can
     listen on document and hydrate the mount node however they like. */
  document.querySelectorAll('[class*="di-"][class$="-slot"]').forEach(function(slot){
    var script = slot.querySelector('script[type="application/json"]');
    var mount  = slot.querySelector('[class*="di-"][class$="-mount"]');
    if(!script||!mount) return;
    var cfg=null; try{ cfg=JSON.parse(script.textContent); }catch(e){ return; }
    slot.dispatchEvent(new CustomEvent('archr:mount',{bubbles:true,detail:{config:cfg,mount:mount}}));
  });
})();
&lt;/script&gt;</code>
            </div>
        </div>
    </section>

    <section class="lib-index" aria-labelledby="ix-h">
        <h2 id="ix-h"><i class="fas fa-list"></i> Index <span style="font-weight:400;color:var(--color-text-muted);font-size:var(--fs-sm);">(<?= count($components) ?> components)</span></h2>
        <ul>
<?php foreach ($buckets as $type => $items): ?>
            <li><span class="ix-group"><?= h($type_label[$type] ?? ucfirst(str_replace('_',' ',$type))) ?></span></li>
<?php foreach ($items as $c): ?>
            <li><a href="#<?= h($c['slug']) ?>"><?= h(archr_label($c['data'])) ?></a></li>
<?php endforeach; endforeach; ?>
        </ul>
    </section>

<?php foreach ($buckets as $type => $items): ?>
<?php foreach ($items as $c):
    $d = $c['data'];
    $slug = $c['slug'];
    $rendered = archr_render($d);
    $type_pretty = $type_label[$type] ?? ucfirst(str_replace('_',' ',$type));
    $embed = archr_embed($d, $slug, $rendered);
?>
    <article class="cmp" id="<?= h($slug) ?>">
        <header class="cmp-head">
            <div>
                <h3><?= h(archr_label($d)) ?></h3>
                <div class="cmp-id"><?= h(archr_id($d)) ?></div>
            </div>
            <div class="cmp-meta">
                <span class="cmp-type"><?= h($type_pretty) ?></span>
                <a href="components/<?= h($c['file']) ?>" class="cmp-file" target="_blank" rel="noopener"><i class="fas fa-file-code"></i> <?= h($c['file']) ?></a>
            </div>
        </header>
<?php if ($c['purpose'] !== ''): ?>
        <p class="cmp-purpose"><i class="fas fa-info-circle"></i> <?= h($c['purpose']) ?></p>
<?php endif; ?>
        <section class="cmp-section">
            <div class="cmp-section-head"><h4><i class="fas fa-eye"></i> Preview</h4></div>
            <div class="cmp-preview"><?= $rendered ?></div>
        </section>
        <section class="cmp-section">
            <div class="cmp-section-head">
                <h4><i class="fas fa-code"></i> JSON spec</h4>
                <span class="cmp-foot-note">Source: <code>components/<?= h($c['file']) ?></code></span>
            </div>
            <div class="cmp-code-wrap">
                <button type="button" class="cmp-copy" data-copy="#json-<?= h($slug) ?>">Copy JSON</button>
                <code class="cmp-code" id="json-<?= h($slug) ?>"><?= h(archr_pretty($d)) ?></code>
            </div>
        </section>
        <section class="cmp-section">
            <div class="cmp-section-head">
                <h4><i class="fab fa-html5"></i> Softr HTML embed</h4>
                <span class="cmp-foot-note">Drop into a Softr inline custom code block.</span>
            </div>
            <div class="cmp-code-wrap">
                <button type="button" class="cmp-copy" data-copy="#html-<?= h($slug) ?>">Copy HTML</button>
                <code class="cmp-code" id="html-<?= h($slug) ?>"><?= h($embed) ?></code>
            </div>
        </section>
    </article>
<?php endforeach; endforeach; ?>

</main>

<script>
// Theme toggle (persists to localStorage)
(function(){
    var btn = document.getElementById('themeToggle');
    if (!btn) return;
    btn.addEventListener('click', function(){
        var html = document.documentElement;
        var next = html.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
        html.setAttribute('data-theme', next);
        try { localStorage.setItem('archr-theme', next); } catch (e) {}
    });
})();

// Copy-to-clipboard buttons
document.querySelectorAll('.cmp-copy').forEach(function(btn){
    btn.addEventListener('click', async function(){
        var sel = btn.getAttribute('data-copy');
        var node = sel ? document.querySelector(sel) : null;
        if (!node) return;
        var text = node.textContent;
        try {
            await navigator.clipboard.writeText(text);
        } catch (e) {
            var ta = document.createElement('textarea');
            ta.value = text; ta.style.position='fixed'; ta.style.opacity='0';
            document.body.appendChild(ta); ta.select();
            try { document.execCommand('copy'); } catch (_) {}
            document.body.removeChild(ta);
        }
        var original = btn.textContent;
        btn.textContent = 'Copied!';
        btn.classList.add('is-copied');
        setTimeout(function(){ btn.textContent = original; btn.classList.remove('is-copied'); }, 1400);
    });
});
</script>

</body>
</html>
