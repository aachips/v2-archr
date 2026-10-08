<?php declare(strict_types=1);
/**
 * ARCHR Component Library — Standalone page (two-pane layout)
 *
 * Left sidebar: categorized component list
 * Right panel: dedicated component detail view
 * Detects active session cookie and fetches real cases if authenticated.
 * Accessible at: /component-library.php
 */

// ---------------------------------------------------------------------------
// Session detection + case fetching (same token verifier as index.php)
// ---------------------------------------------------------------------------

function lib_get_auth_secret(): string {
    $secret = getenv('AUTH_SECRET_KEY');
    if ($secret !== false && $secret !== '') return $secret;
    $envFile = __DIR__ . '/app/.env';
    if (file_exists($envFile)) {
        $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        foreach ($lines as $line) {
            $line = trim($line);
            if (strpos($line, '#') === 0) continue;
            if (preg_match('/^AUTH_SECRET_KEY\s*=\s*(.+)$/', $line, $m)) {
                return trim($m[1]);
            }
        }
    }
    return 'change-me-in-production';
}

function lib_base64url_decode(string $data): string {
    $remainder = strlen($data) % 4;
    if ($remainder) $data .= str_repeat('=', 4 - $remainder);
    return base64_decode($data);
}

function lib_verify_auth_token(string $token): ?array {
    $secret = lib_get_auth_secret();
    $parts  = explode('.', $token, 3);
    if (count($parts) !== 3) return null;
    [$headerB64, $bodyB64, $sigB64] = $parts;
    $expectedSig = rtrim(strtr(base64_encode(hash_hmac('sha256', "$headerB64.$bodyB64", $secret, true)), '+/', '-_'), '=');
    if (!hash_equals($expectedSig, $sigB64)) return null;
    $payload = json_decode(lib_base64url_decode($bodyB64), true);
    if (!$payload) return null;
    if (isset($payload['exp']) && time() > (int)$payload['exp']) return null;
    return $payload;
}

// Check for active session
$libUser = null;
$libCases = [];
$cookieName = 'archr_session';
$cookie = $_COOKIE[$cookieName] ?? null;

// Debug: log cookie presence
error_log("[component-library] Cookie present: " . ($cookie ? 'YES (len=' . strlen($cookie) . ')' : 'NO'));
error_log("[component-library] All cookies: " . json_encode($_COOKIE));

if ($cookie) {
    $payload = lib_verify_auth_token($cookie);
    if ($payload) {
        $libUser = [
            'name' => $payload['full_name'] ?? 'User',
            'role' => $payload['role'] ?? 'viewer',
            'role_level' => (int)($payload['role_level'] ?? 0),
        ];

        // Cases come from Airtable via the Vue app's caseService.js.
        // We can't fetch them server-side without exposing the API key.
        // The portal version (/portal/#components) passes real cases from
        // the Vue app's state. This standalone page shows placeholders.
        $libCases = [];
    }
}

$libCasesJson = json_encode($libCases, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
$libUserJson = json_encode($libUser, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);

// DEBUG: inline output
$libDebugCookie = $cookie ? 'YES (len=' . strlen($cookie) . ')' : 'NO';
$libDebugCookies = json_encode($_COOKIE);
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ARCHR — Component Library</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&family=Open+Sans:wght@400;600&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/vue@2.7.16/dist/vue.min.js"></script>
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --color-primary: #2a5c82;
            --color-secondary: #1d4665;
            --color-success: #16a34a;
            --color-warning: #d97706;
            --color-text: #333;
            --color-text-muted: #6b7280;
            --color-border: #e5e7eb;
            --color-border-strong: #d1d5db;
            --bg-page: #f0f2f5;
            --bg-surface: #fff;
            --bg-surface-alt: #f3f4f6;
            --border-radius: 8px;
            --shadow: 0 2px 8px rgba(0,0,0,0.08);
            --font-display: 'Poppins', sans-serif;
            --font-sans: 'Open Sans', sans-serif;
            --sidebar-w: 280px;
        }
        html, body { height: 100%; }
        body { font-family: var(--font-sans, system-ui, sans-serif); background: var(--bg-page); color: var(--color-text); line-height: 1.5; }

        /* Top bar */
        .lib-topbar { background: var(--color-secondary); color: #fff; padding: 12px 24px; display: flex; align-items: center; justify-content: space-between; position: sticky; top: 0; z-index: 100; }
        .lib-topbar h1 { font-family: var(--font-display, 'Poppins', sans-serif); font-size: 1.1rem; font-weight: 600; }
        .lib-topbar h1 i { opacity: 0.6; margin-right: 8px; }
        .lib-topbar a { color: rgba(255,255,255,0.8); text-decoration: none; font-size: 0.8rem; font-weight: 500; }
        .lib-topbar a:hover { color: #fff; }

        /* Two-pane layout */
        .lib-layout { display: flex; height: calc(100vh - 48px); }

        /* Sidebar */
        .lib-sidebar {
            width: var(--sidebar-w);
            min-width: var(--sidebar-w);
            background: var(--bg-surface);
            border-right: 1px solid var(--color-border);
            overflow-y: auto;
            padding: 16px 0;
        }
        .lib-sidebar-section { margin-bottom: 4px; }
        .lib-sidebar-section-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 0.7rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.1em;
            color: var(--color-text-muted);
            padding: 8px 20px;
            cursor: pointer;
            user-select: none;
        }
        .lib-sidebar-section-header:hover { background: var(--bg-surface-alt); }
        .lib-sidebar-section-header i { font-size: 0.6rem; opacity: 0.5; }
        .lib-sidebar-section-items { padding-left: 8px; }
        .lib-sidebar-item {
            display: block;
            padding: 8px 20px;
            font-size: 0.85rem;
            color: var(--color-text);
            cursor: pointer;
            border-left: 3px solid transparent;
            transition: background 0.15s, border-color 0.15s;
        }
        .lib-sidebar-item:hover { background: var(--bg-surface-alt); }
        .lib-sidebar-item.is-active {
            background: var(--bg-surface-alt);
            border-left-color: var(--color-primary);
            font-weight: 600;
            color: var(--color-primary);
        }

        /* Main content */
        .lib-main {
            flex: 1;
            overflow-y: auto;
            padding: 32px 40px;
            max-width: 900px;
        }

        /* Welcome state */
        .lib-welcome {
            text-align: center;
            padding: 80px 40px;
            color: var(--color-text-muted);
        }
        .lib-welcome i { font-size: 3rem; opacity: 0.2; display: block; margin-bottom: 16px; }
        .lib-welcome h2 { font-family: var(--font-display); font-size: 1.5rem; color: var(--color-text); margin-bottom: 8px; }

        /* Component detail view */
        .lib-detail-header { margin-bottom: 24px; }
        .lib-detail-header h2 {
            font-family: var(--font-display);
            font-size: 1.5rem;
            color: var(--color-primary);
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .lib-detail-desc {
            color: var(--color-text-muted);
            font-size: 1rem;
            line-height: 1.6;
            margin: 12px 0 24px;
        }

        /* Preview frame */
        .lib-preview {
            border: 2px dashed var(--color-border-strong);
            border-radius: var(--border-radius);
            padding: 24px;
            background: var(--bg-surface-alt);
            margin-bottom: 24px;
        }
        .lib-preview-label {
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: var(--color-text-muted);
            margin-bottom: 12px;
        }

        /* Variant tabs */
        .lib-variants { display: flex; gap: 4px; margin-bottom: 20px; }
        .lib-variant-tab {
            padding: 6px 16px;
            border: 1px solid var(--color-border-strong);
            border-radius: 4px 4px 0 0;
            background: var(--bg-surface-alt);
            cursor: pointer;
            font-size: 0.85rem;
            font-weight: 500;
            color: var(--color-text-muted);
        }
        .lib-variant-tab.is-active { background: var(--color-primary); color: #fff; border-color: var(--color-primary); }

        /* Section headings */
        .lib-section-title {
            font-size: 0.8rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: var(--color-text-muted);
            margin-bottom: 8px;
            margin-top: 24px;
            font-weight: 600;
        }

        /* Tables */
        .lib-table { width: 100%; border-collapse: collapse; font-size: 0.85rem; margin: 12px 0; }
        .lib-table th, .lib-table td { text-align: left; padding: 10px 12px; border-bottom: 1px solid var(--color-border); }
        .lib-table th { background: var(--bg-surface-alt); font-weight: 600; }
        .lib-table code { background: var(--bg-surface-alt); padding: 2px 6px; border-radius: 3px; font-size: 0.8rem; }

        /* Events */
        .lib-events { display: flex; flex-wrap: wrap; gap: 8px; margin: 8px 0; }
        .lib-event { background: #fef3c7; color: #92400e; padding: 3px 12px; border-radius: 12px; font-size: 0.8rem; font-weight: 600; }

        /* Code block */
        .lib-code { background: #1e293b; color: #e2e8f0; padding: 16px; border-radius: 6px; overflow-x: auto; font-size: 0.8rem; line-height: 1.6; font-family: 'Consolas', 'Monaco', monospace; margin: 12px 0; }

        /* Badge */
        .lib-badge { display: inline-block; font-size: 0.65rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; padding: 2px 8px; border-radius: 10px; }
        .badge--shared { background: #dbeafe; color: #1d4ed8; }
        .badge--feature { background: #fef3c7; color: #92400e; }
        .badge--layout { background: #e0e7ff; color: #4338ca; }

        /* Buttons */
        .btn { display: inline-flex; align-items: center; gap: 6px; padding: 6px 14px; border: 1px solid var(--color-border-strong); border-radius: 4px; background: var(--bg-surface); color: var(--color-text); font-size: 0.85rem; font-weight: 500; cursor: pointer; }
        .btn:hover { background: var(--bg-surface-alt); }
        .btn-sm { padding: 4px 10px; font-size: 0.8rem; }
        .btn-primary { background: var(--color-primary); color: #fff; border-color: var(--color-primary); }
        .btn-primary:hover { background: #1e4461; }
        .btn-secondary { background: var(--color-secondary); color: #fff; border-color: var(--color-secondary); }
        .btn-success { background: var(--color-success); color: #fff; border-color: var(--color-success); }
        .btn-warning { background: var(--color-warning); color: #fff; border-color: var(--color-warning); }
        .btn-icon { padding: 4px 8px; min-width: 32px; justify-content: center; }

        /* Triage badges */
        .triage { display: inline-flex; align-items: center; gap: 4px; font-weight: 700; padding: 2px 8px; border-radius: 10px; font-size: 0.8rem; }
        .triage--critical { background: #fee2e2; color: #dc2626; }
        .triage--high { background: #fef3c7; color: #d97706; }
        .triage--medium { background: #dbeafe; color: #2563eb; }
        .triage--low { background: #d1fae5; color: #059669; }

        /* Inline preview components */
        .apc { background: var(--bg-surface); border: 1px solid var(--color-border); border-radius: var(--border-radius); padding: 16px; }
        .apc-header { display: flex; align-items: center; justify-content: space-between; gap: 12px; }
        .apc-meta { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; font-size: 0.9rem; }
        .apc-actions { display: flex; gap: 4px; }
        .apc-body { margin-top: 12px; padding-top: 12px; border-top: 1px solid var(--color-border); }
        .apc-repair { display: flex; align-items: center; gap: 8px; padding: 6px 0; border-bottom: 1px solid var(--color-border); font-size: 0.85rem; }
        .apc-repair:last-child { border-bottom: 0; }
        .apc-trade { font-weight: 600; color: var(--color-primary); min-width: 80px; }
        .apc-footer { display: flex; gap: 8px; margin-top: 12px; }

        .rnc { background: var(--bg-surface); border: 1px solid var(--color-border); border-radius: var(--border-radius); padding: 16px; }
        .rnc--claimed { border-left: 3px solid var(--color-success); }
        .rnc-main { display: flex; align-items: baseline; gap: 10px; }
        .rnc-meta { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; font-size: 0.8rem; }
        .rnc-actions { display: flex; gap: 6px; flex-wrap: wrap; margin-top: 8px; }
        .rnc-children { margin-top: 12px; padding: 12px 16px; background: var(--bg-surface-alt); border-radius: 6px; border: 1px solid var(--color-border); }
        .rnc-child { display: flex; align-items: center; justify-content: space-between; gap: 8px; padding: 6px 0; border-bottom: 1px solid var(--color-border); font-size: 0.85rem; }
        .rnc-child:last-child { border-bottom: 0; }
        .rnc-child-icon { color: var(--color-text-muted); font-size: 0.7rem; margin-left: 12px; }
    </style>
</head>
<body>

<!-- DEBUG BAR -->
<div style="background:#1e293b;color:#e2e8f0;padding:8px 24px;font-size:0.8rem;font-family:monospace;display:flex;gap:20px;align-items:center;flex-wrap:wrap;">
    <span><strong>Session:</strong></span>
    <span>Cookie: <?= $libDebugCookie ?></span>
    <span>User: <?= $libUser ? htmlspecialchars($libUser['name']) : 'null' ?></span>
    <?php if ($libUser): ?>
        <span style="color:#4ade80;">✓ Authenticated</span>
    <?php else: ?>
        <span style="color:#f87171;">✗ Not logged in</span>
    <?php endif; ?>
    <span style="color:#94a3b8;font-size:0.7rem;">(Cases require Vue portal — Airtable SDK)</span>
</div>

<div id="component-library-app">
    <!-- Top bar -->
    <div class="lib-topbar">
        <h1><i class="fas fa-puzzle-piece"></i> ARCHR Component Library</h1>
        <a href="./help.php">&larr; Documentation</a>
    </div>

    <!-- Two-pane layout -->
    <div class="lib-layout">
        <!-- Sidebar -->
        <nav class="lib-sidebar">
            <div v-for="section in sidebarSections" :key="section.label" class="lib-sidebar-section">
                <div class="lib-sidebar-section-header" @click="toggleSection(section.label)">
                    <span>{{ section.label }}</span>
                    <i :class="openSections[section.label] ? 'fas fa-chevron-down' : 'fas fa-chevron-right'"></i>
                </div>
                <div v-if="openSections[section.label]" class="lib-sidebar-section-items">
                    <a
                        v-for="comp in section.components"
                        :key="comp.id"
                        class="lib-sidebar-item"
                        :class="{ 'is-active': selectedId === comp.id }"
                        @click="selectedId = comp.id"
                    >{{ comp.name }}</a>
                </div>
            </div>
        </nav>

        <!-- Main content area -->
        <main class="lib-main">
            <!-- Welcome (no selection) -->
            <div v-if="!selectedComponent" class="lib-welcome">
                <i class="fas fa-puzzle-piece"></i>
                <h2>Select a Component</h2>
                <p>Choose a component from the sidebar to view its details, preview, props, and usage.</p>
            </div>

            <!-- Component detail view -->
            <div v-else>
                <div class="lib-detail-header">
                    <h2>
                        <span class="lib-badge" :class="'badge--' + selectedComponent.category">{{ selectedComponent.category }}</span>
                        {{ selectedComponent.name }}
                    </h2>
                </div>
                <p class="lib-detail-desc">{{ selectedComponent.description }}</p>

                <!-- Variant tabs -->
                <div v-if="selectedComponent.variants && selectedComponent.variants.length" class="lib-variants">
                    <button v-for="v in selectedComponent.variants" :key="v.id" class="lib-variant-tab" :class="{ 'is-active': activeVariant === v.id }" @click="activeVariant = v.id">{{ v.label }}</button>
                </div>

                <!-- Live preview -->
                <div class="lib-preview">
                    <div class="lib-preview-label">Live Preview</div>
                    <div v-if="selectedId === 'fcl'" v-html="getFclPreview()"></div>
                    <div v-else v-html="selectedComponent.preview"></div>
                </div>

                <!-- Props table -->
                <div v-if="selectedComponent.props && Object.keys(selectedComponent.props).length">
                    <div class="lib-section-title">Props</div>
                    <table class="lib-table">
                        <thead><tr><th>Name</th><th>Type</th><th>Default</th></tr></thead>
                        <tbody>
                            <tr v-for="(prop, key) in selectedComponent.props" :key="key">
                                <td><code>{{ key }}</code></td>
                                <td>{{ prop.type }}</td>
                                <td>{{ prop.default != null ? prop.default : '—' }}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <!-- Events -->
                <div v-if="selectedComponent.events && selectedComponent.events.length">
                    <div class="lib-section-title">Emitted Events</div>
                    <div class="lib-events">
                        <span v-for="ev in selectedComponent.events" :key="ev" class="lib-event">{{ ev }}</span>
                    </div>
                </div>

                <!-- Code snippet -->
                <div v-if="selectedComponent.code">
                    <div class="lib-section-title">Usage</div>
                    <pre class="lib-code"><code>{{ selectedComponent.code }}</code></pre>
                </div>
            </div>
        </main>
    </div>
</div>

<script>
// Component data definitions (same as before, static previews)
var componentData = [
    // ============================================================
    // SHARED: Application Preview Card
    // ============================================================
    {
        id: 'apc',
        name: 'Application Preview Card',
        category: 'shared',
        description: 'Reusable card showing application summary. Two variants: Marketplace (claim action) and Case List (open/toolbox actions). Expandable repair needs preview (shows 4, then "+N more").',
        variants: [
            { id: 'marketplace', label: 'Marketplace' },
            { id: 'case-list', label: 'Case List' }
        ],
        props: {
            application: { type: 'Object', default: '—' },
            variant: { type: 'String', default: "'marketplace'" },
            claimed: { type: 'Boolean', default: 'false' }
        },
        events: ['claim', 'open', 'review', 'toolbox', 'comment-submitted'],
        code: '<ApplicationPreviewCard\n  :application="app"\n  variant="marketplace"\n  @claim="onClaim"\n/>',
        preview: '<div class="apc">' +
            '<div class="apc-header">' +
                '<div class="apc-meta">' +
                    '<span style="color:var(--color-text-muted,#6b7280);font-weight:500;">Sep 15, 2026</span>' +
                    '<span style="font-weight:600;">BAILEY, E.</span>' +
                    '<span style="font-family:monospace;font-size:0.8rem;background:var(--bg-surface-alt,#f3f4f6);padding:2px 6px;border-radius:4px;">247-RIVERSIDE</span>' +
                    '<span class="triage triage--critical"><i class="fas fa-exclamation-triangle"></i> 8</span>' +
                '</div>' +
                '<div class="apc-actions">' +
                    '<button class="btn btn-primary btn-sm" data-variant="marketplace"><i class="fas fa-hand-holding-heart"></i> Claim</button>' +
                    '<button class="btn btn-secondary btn-sm" data-variant="case-list" style="display:none;">Open</button>' +
                    '<button class="btn btn-icon btn-sm" title="More options"><i class="fas fa-ellipsis-v"></i></button>' +
                    '<button class="btn btn-icon btn-sm apc-toggle"><i class="fas fa-chevron-down"></i></button>' +
                '</div>' +
            '</div>' +
            '<div class="apc-body" style="display:none;">' +
                '<div class="apc-repair"><span class="apc-trade">Roofing</span><span style="flex:1;color:var(--color-text,#333);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">Complete roof replacement, storm damage</span><span class="triage triage--critical">9</span></div>' +
                '<div class="apc-repair"><span class="apc-trade">Carpentry</span><span style="flex:1;color:var(--color-text,#333);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">Replace flooring and rebuild south wall</span><span class="triage triage--high">7</span></div>' +
                '<div class="apc-repair"><span class="apc-trade">Plumbing</span><span style="flex:1;color:var(--color-text,#333);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">Replace main water line</span><span class="triage triage--high">6</span></div>' +
                '<div class="apc-repair"><span class="apc-trade">Electrical</span><span style="flex:1;color:var(--color-text,#333);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">Rewire damaged circuits</span><span class="triage triage--medium">5</span></div>' +
                '<div style="color:var(--color-text-muted,#6b7280);font-style:italic;font-size:0.85rem;padding:6px 0;">+2 more repair needs</div>' +
                '<div class="apc-footer">' +
                    '<button class="btn btn-sm" data-variant="marketplace">Review</button><button class="btn btn-sm" data-variant="marketplace">Comment</button>' +
                    '<button class="btn btn-sm" data-variant="case-list" style="display:none;">Toolbox</button>' +
                '</div>' +
            '</div>' +
        '</div>'
    },

    // ============================================================
    // SHARED: Repair Need List / Card
    // ============================================================
    {
        id: 'rnl',
        name: 'Repair Need List / Card',
        category: 'shared',
        description: 'Hierarchical list of repair needs with parent/child task structure. Shows trade, description, triage score, claim status, and action buttons.',
        props: {
            repairNeeds: { type: 'Array', default: '—' },
            currentOrg: { type: 'String', default: "''" },
            showClaim: { type: 'Boolean', default: 'true' },
            showMarkMet: { type: 'Boolean', default: 'true' },
            showEdit: { type: 'Boolean', default: 'true' },
            showDelete: { type: 'Boolean', default: 'false' }
        },
        events: ['claim-need', 'mark-met', 'edit-need', 'delete-need', 'edit-task', 'delete-task'],
        code: '<RepairNeedList\n  :repair-needs="needs"\n  current-org="AHFH"\n  @claim-need="onClaim"\n  @mark-met="onMarkMet"\n/>',
        preview: '<div style="display:flex;flex-direction:column;gap:12px;">' +
            '<div class="rnc rnc--claimed">' +
                '<div style="display:flex;flex-direction:column;gap:8px;">' +
                    '<div class="rnc-main"><span style="font-weight:700;font-size:0.95rem;color:var(--color-primary,#2a5c82);min-width:90px;">Carpentry</span><span style="flex:1;font-size:0.9rem;color:var(--color-text,#333);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">Rental cabin completely destroyed by creek damage</span></div>' +
                    '<div class="rnc-meta">' +
                        '<span class="triage triage--critical"><i class="fas fa-exclamation-triangle"></i> 8</span>' +
                        '<span style="color:var(--color-text-muted,#6b7280);">Received Sep 10, 2026</span>' +
                        '<span style="color:var(--color-success,#16a34a);font-weight:600;display:inline-flex;align-items:center;gap:4px;"><i class="fas fa-hand-holding-heart"></i> Claimed by: Asheville Area Habitat for Humanity</span>' +
                    '</div>' +
                    '<div class="rnc-actions">' +
                        '<button class="btn btn-success btn-sm"><i class="fas fa-check-circle"></i> Mark Met</button>' +
                        '<button class="btn btn-sm"><i class="fas fa-edit"></i> Edit</button>' +
                        '<button class="btn btn-sm rnl-toggle" data-target="rnl-rn1"><i class="fas fa-chevron-down"></i> 3 tasks</button>' +
                    '</div>' +
                '</div>' +
                '<div class="rnc-children" id="rnl-rn1">' +
                    '<div class="rnc-child"><div style="display:flex;align-items:center;gap:8px;flex:1;"><span class="rnc-child-icon"><i class="fas fa-arrow-right"></i></span><span style="color:var(--color-text,#333);">Replace flooring</span></div><div style="display:flex;gap:4px;"><button class="btn btn-sm"><i class="fas fa-edit"></i> Edit</button></div></div>' +
                    '<div class="rnc-child"><div style="display:flex;align-items:center;gap:8px;flex:1;"><span class="rnc-child-icon"><i class="fas fa-arrow-right"></i></span><span style="color:var(--color-text,#333);">Rebuild south wall</span></div><div style="display:flex;gap:4px;"><button class="btn btn-sm"><i class="fas fa-edit"></i> Edit</button></div></div>' +
                    '<div class="rnc-child"><div style="display:flex;align-items:center;gap:8px;flex:1;"><span class="rnc-child-icon"><i class="fas fa-arrow-right"></i></span><span style="color:var(--color-text,#333);">Install new door frame</span></div><div style="display:flex;gap:4px;"><button class="btn btn-sm"><i class="fas fa-edit"></i> Edit</button></div></div>' +
                '</div>' +
            '</div>' +
            '<div class="rnc">' +
                '<div style="display:flex;flex-direction:column;gap:8px;">' +
                    '<div class="rnc-main"><span style="font-weight:700;font-size:0.95rem;color:var(--color-primary,#2a5c82);min-width:90px;">Drywall</span><span style="flex:1;font-size:0.9rem;color:var(--color-text,#333);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">Replace ceiling and sheetrock materials</span></div>' +
                    '<div class="rnc-meta">' +
                        '<span class="triage triage--high"><i class="fas fa-exclamation-triangle"></i> 5</span>' +
                        '<span style="color:var(--color-text-muted,#6b7280);">Received Sep 12, 2026</span>' +
                        '<span style="color:var(--color-text-muted,#6b7280);font-style:italic;display:inline-flex;align-items:center;gap:4px;"><i class="fas fa-globe"></i> Unclaimed</span>' +
                    '</div>' +
                    '<div class="rnc-actions">' +
                        '<button class="btn btn-primary btn-sm"><i class="fas fa-hand-holding-heart"></i> Claim Need</button>' +
                        '<button class="btn btn-sm"><i class="fas fa-edit"></i> Edit</button>' +
                    '</div>' +
                '</div>' +
            '</div>' +
            '<div class="rnc rnc--claimed">' +
                '<div style="display:flex;flex-direction:column;gap:8px;">' +
                    '<div class="rnc-main"><span style="font-weight:700;font-size:0.95rem;color:var(--color-primary,#2a5c82);min-width:90px;">Plumbing</span><span style="flex:1;font-size:0.9rem;color:var(--color-text,#333);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">Fix burst pipe in basement, replace water heater</span></div>' +
                    '<div class="rnc-meta">' +
                        '<span class="triage triage--critical"><i class="fas fa-exclamation-triangle"></i> 9</span>' +
                        '<span style="color:var(--color-text-muted,#6b7280);">Received Sep 8, 2026</span>' +
                        '<span style="color:var(--color-success,#16a34a);font-weight:600;display:inline-flex;align-items:center;gap:4px;"><i class="fas fa-hand-holding-heart"></i> Claimed by: AHFH</span>' +
                    '</div>' +
                    '<div class="rnc-actions">' +
                        '<button class="btn btn-success btn-sm"><i class="fas fa-check-circle"></i> Mark Met</button>' +
                        '<button class="btn btn-sm"><i class="fas fa-edit"></i> Edit</button>' +
                        '<button class="btn btn-sm rnl-toggle" data-target="rnl-rn3"><i class="fas fa-chevron-right"></i> 2 tasks</button>' +
                    '</div>' +
                '</div>' +
                '<div class="rnc-children" id="rnl-rn3" style="display:none;">' +
                    '<div class="rnc-child"><div style="display:flex;align-items:center;gap:8px;flex:1;"><span class="rnc-child-icon"><i class="fas fa-arrow-right"></i></span><span style="color:var(--color-text,#333);">Replace main water line</span></div><div style="display:flex;gap:4px;"><button class="btn btn-sm"><i class="fas fa-edit"></i> Edit</button></div></div>' +
                    '<div class="rnc-child"><div style="display:flex;align-items:center;gap:8px;flex:1;"><span class="rnc-child-icon"><i class="fas fa-arrow-right"></i></span><span style="color:var(--color-text,#333);">Install new water heater</span></div><div style="display:flex;gap:4px;"><button class="btn btn-sm"><i class="fas fa-edit"></i> Edit</button></div></div>' +
                '</div>' +
            '</div>' +
        '</div>'
    },

    // ============================================================
    // SHARED: Claim Widget / Card
    // ============================================================
    {
        id: 'claim',
        name: 'Claim Widget / Card',
        category: 'shared',
        description: 'Shows claim status with color coding (Active/Expired/Released/Unclaimed). Actions: Claim, Release Claim (with confirmation modal), Renew Timer.',
        variants: [
            { id: 'card', label: 'Card' },
            { id: 'row', label: 'Row' }
        ],
        props: {
            status: { type: 'String', default: "'unclaimed'" },
            claimedBy: { type: 'String', default: "''" },
            claimDate: { type: 'String', default: null },
            expireDate: { type: 'String', default: null },
            isCurrentUserOrg: { type: 'Boolean', default: false },
            layout: { type: 'String', default: "'card'" }
        },
        events: ['claim', 'renew', 'release-confirmed'],
        code: '<ClaimWidget\n  status="active"\n  claimed-by="AHFH"\n  @release-confirmed="onRelease"\n  @renew="onRenew"\n/>',
        preview: '<div style="display:flex;flex-direction:column;gap:12px;">' +
            '<div class="rnc" style="border-top:3px solid var(--color-success,#16a34a);border-left:none;">' +
                '<div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:12px;">' +
                    '<div style="width:40px;height:40px;border-radius:6px;background:var(--bg-surface-alt,#f3f4f6);display:flex;align-items:center;justify-content:center;font-size:0.7rem;font-weight:700;color:var(--color-text-muted);">AHFH</div>' +
                    '<span class="triage" style="background:#d1fae5;color:#059669;"><i class="fas fa-circle-check"></i> Active</span>' +
                '</div>' +
                '<div style="display:flex;flex-direction:column;gap:8px;margin-bottom:12px;font-size:0.85rem;">' +
                    '<div style="display:flex;justify-content:space-between;"><span style="color:var(--color-text-muted,#6b7280);font-weight:500;">Claimed by</span><span style="font-weight:600;">Asheville Area Habitat for Humanity</span></div>' +
                    '<div style="display:flex;justify-content:space-between;"><span style="color:var(--color-text-muted,#6b7280);font-weight:500;">Claim date</span><span>Sep 10, 2026</span></div>' +
                    '<div style="display:flex;justify-content:space-between;"><span style="color:var(--color-text-muted,#6b7280);font-weight:500;">Expires</span><span style="font-weight:600;">Dec 9, 2026 <span style="font-size:0.75rem;color:var(--color-text-muted);font-weight:400;">(75 days left)</span></span></div>' +
                '</div>' +
                '<div style="display:flex;gap:6px;">' +
                    '<button class="btn btn-sm" style="background:#d97706;color:#fff;border-color:#d97706;"><i class="fas fa-undo"></i> Release Claim</button>' +
                    '<button class="btn btn-sm"><i class="fas fa-redo"></i> Renew Timer</button>' +
                '</div>' +
            '</div>' +
            '<div class="rnc" style="border-top:3px solid var(--color-primary,#2a5c82);border-left:none;">' +
                '<div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:12px;">' +
                    '<div></div>' +
                    '<span class="triage" style="background:#dbeafe;color:#2563eb;"><i class="fas fa-circle-plus"></i> Unclaimed</span>' +
                '</div>' +
                '<div style="display:flex;gap:6px;">' +
                    '<button class="btn btn-primary btn-sm"><i class="fas fa-hand-holding-heart"></i> Claim</button>' +
                '</div>' +
            '</div>' +
        '</div>'
    },

    // ============================================================
    // SHARED: Tabbed Panel
    // ============================================================
    {
        id: 'tabs',
        name: 'Tabbed Information Panel',
        category: 'shared',
        description: 'Reusable tabbed container driven by configuration. Tabs can render child Vue components, slot content, or empty state. Supports badges.',
        props: {
            tabs: { type: 'Array', default: '—' },
            initial: { type: 'String', default: "''" }
        },
        events: ['tab-changed'],
        code: '<TabbedPanel\n  :tabs="caseReviewTabs"\n  @tab-changed="onTabChange"\n/>',
        preview: '<div style="background:var(--bg-surface);border:1px solid var(--color-border);border-radius:var(--border-radius);overflow:hidden;">' +
            '<div style="display:flex;border-bottom:1px solid var(--color-border);background:var(--bg-surface-alt,#f8f9fa);overflow-x:auto;">' +
                '<button style="padding:12px 20px;border:none;background:var(--bg-surface,#fff);font-size:0.85rem;font-weight:600;color:var(--color-primary,#2a5c82);cursor:pointer;border-bottom:2px solid var(--color-primary,#2a5c82);white-space:nowrap;">Eligibility Summary</button>' +
                '<button style="padding:12px 20px;border:none;background:none;font-size:0.85rem;font-weight:500;color:var(--color-text-muted,#6b7280);cursor:pointer;border-bottom:2px solid transparent;white-space:nowrap;">Comments <span style="display:inline-block;font-size:0.7rem;font-weight:700;background:var(--color-primary,#2a5c82);color:#fff;padding:1px 7px;border-radius:10px;">3</span></button>' +
                '<button style="padding:12px 20px;border:none;background:none;font-size:0.85rem;font-weight:500;color:var(--color-text-muted,#6b7280);cursor:pointer;border-bottom:2px solid transparent;white-space:nowrap;">Documents</button>' +
                '<button style="padding:12px 20px;border:none;background:none;font-size:0.85rem;font-weight:500;color:var(--color-text-muted,#6b7280);cursor:pointer;border-bottom:2px solid transparent;white-space:nowrap;">Property Card</button>' +
            '</div>' +
            '<div style="padding:20px;min-height:120px;text-align:center;color:var(--color-text-muted,#6b7280);">' +
                '<i class="fas fa-folder-open" style="font-size:2rem;opacity:0.3;display:block;margin-bottom:12px;"></i>' +
                '<p style="font-size:0.9rem;">Content rendered from child component or slot</p>' +
            '</div>' +
        '</div>'
    },

    // ============================================================
    // SHARED: Document Card + Metadata Modal
    // ============================================================
    {
        id: 'doccard',
        name: 'Document Card + Metadata Modal',
        category: 'shared',
        description: 'Single document row with file icon, type badge, redaction status. Clicking opens the consolidated "Edit Document Metadata" modal.',
        props: {
            doc: { type: 'Object', default: '—' },
            docTypes: { type: 'Array', default: 'Reference table' },
            folders: { type: 'Array', default: 'Dropbox paths' },
            placecodes: { type: 'Array', default: '—' },
            projects: { type: 'Array', default: '—' }
        },
        events: ['save', 'download', 'delete'],
        code: '<DocumentCard\n  :doc="file"\n  :doc-types="types"\n  @save="onSave"\n/>',
        preview: '<div>' +
            '<div style="display:flex;align-items:center;gap:12px;padding:10px 12px;border:1px solid var(--color-border,#e5e7eb);border-radius:6px;background:var(--bg-surface,#fff);margin-bottom:6px;">' +
                '<span style="font-size:1.3rem;color:#dc2626;min-width:28px;text-align:center;"><i class="fas fa-file-pdf"></i></span>' +
                '<div style="flex:1;min-width:0;"><span style="display:block;font-weight:600;font-size:0.9rem;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">247-RIVERSIDE_income_verification.pdf</span><span style="display:flex;gap:10px;font-size:0.75rem;color:var(--color-text-muted,#6b7280);margin-top:2px;"><span style="background:var(--bg-surface-alt,#f3f4f6);padding:1px 6px;border-radius:3px;font-weight:500;">Eligibility Verification</span><span>2.4 MB</span><span>Sep 10, 2026</span></span></div>' +
                '<span style="font-size:0.75rem;font-weight:600;color:#d97706;min-width:80px;text-align:center;"><i class="fas fa-eye-slash"></i> Redacted</span>' +
                '<div style="display:flex;gap:4px;"><button class="btn btn-icon btn-sm"><i class="fas fa-edit"></i></button><button class="btn btn-icon btn-sm"><i class="fas fa-download"></i></button></div>' +
            '</div>' +
            '<div style="display:flex;align-items:center;gap:12px;padding:10px 12px;border:1px solid var(--color-border,#e5e7eb);border-radius:6px;background:var(--bg-surface,#fff);margin-bottom:6px;">' +
                '<span style="font-size:1.3rem;color:#8b5cf6;min-width:28px;text-align:center;"><i class="fas fa-file-image"></i></span>' +
                '<div style="flex:1;min-width:0;"><span style="display:block;font-weight:600;font-size:0.9rem;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">roof_damage_north_side.jpg</span><span style="display:flex;gap:10px;font-size:0.75rem;color:var(--color-text-muted,#6b7280);margin-top:2px;"><span style="background:var(--bg-surface-alt,#f3f4f6);padding:1px 6px;border-radius:3px;font-weight:500;">Site Photo</span><span>5.1 MB</span><span>Sep 8, 2026</span></span></div>' +
                '<span style="font-size:0.75rem;font-weight:600;color:var(--color-text-muted,#9ca3af);min-width:80px;text-align:center;"><i class="fas fa-eye"></i> Visible</span>' +
                '<div style="display:flex;gap:4px;"><button class="btn btn-icon btn-sm"><i class="fas fa-edit"></i></button><button class="btn btn-icon btn-sm"><i class="fas fa-download"></i></button></div>' +
            '</div>' +
        '</div>'
    },

    // ============================================================
    // FEATURE: Documents Bucket
    // ============================================================
    {
        id: 'docs',
        name: 'Documents Bucket',
        category: 'feature',
        description: 'Document management with upload, folder navigation, metadata editing, and redaction. Supports Dropbox and local file storage.',
        props: {},
        events: ['file-uploaded', 'metadata-updated'],
        code: '<DocumentsBucket\n  :case-id="caseId"\n  @file-uploaded="onUpload"\n/>',
        preview: '<div style="text-align:center;padding:40px 20px;color:var(--color-text-muted,#6b7280);"><i class="fas fa-folder-open" style="font-size:2.5rem;opacity:0.3;display:block;margin-bottom:12px;"></i><p style="font-size:0.95rem;">Documents Bucket — requires case context to render</p></div>'
    },

    // ============================================================
    // FEATURE: Filterable Case List
    // ============================================================
    {
        id: 'fcl',
        name: 'Filterable Case List',
        category: 'feature',
        description: 'Searchable, filterable table of cases with CSV/Excel export and column visibility toggles. Rich filters for status, org, date range, sort, and urgent-only.',
        props: {},
        events: ['select'],
        code: '<FilterableCaseList\n  :cases="cases"\n  :loading="loading"\n  @select="openCase"\n/>',
        preview: '<!-- FCL_PREVIEW_MARKER -->'
    },

    // ============================================================
    // FEATURE: Quick Tasks (TLE-POC)
    // ============================================================
    {
        id: 'qt',
        name: 'Quick Tasks (TLE-POC)',
        category: 'feature',
        description: 'Two-phase task engine with Quick Entry, Unverified Queue, and Triage Modal. Data stored in localStorage (POC phase).',
        props: {},
        events: [],
        code: '<QuickTasks :cases="cases" />',
        preview: '<div style="text-align:center;padding:40px 20px;color:var(--color-text-muted,#6b7280);"><i class="fas fa-tasks" style="font-size:2.5rem;opacity:0.3;display:block;margin-bottom:12px;"></i><p style="font-size:0.95rem;">Quick Tasks — requires cases array to render</p></div>'
    },

    // ============================================================
    // LAYOUT: Login Page
    // ============================================================
    {
        id: 'login',
        name: 'Login Page',
        category: 'layout',
        description: 'Authentication form with email/password, remember-me checkbox, and error handling. Calls /app/vue_api/auth.php.',
        props: {},
        events: ['logged-in'],
        code: '<LoginPage @logged-in="onLoginSuccess" />',
        preview: '<div style="max-width:400px;margin:0 auto;background:var(--bg-surface);border:1px solid var(--color-border);border-radius:var(--border-radius);padding:32px;text-align:center;"><i class="fas fa-lock" style="font-size:2rem;color:var(--color-primary,#2a5c82);margin-bottom:16px;"></i><h3 style="margin-bottom:16px;font-size:1.2rem;">ARCHR Login</h3><div style="text-align:left;"><div style="margin-bottom:12px;"><label style="font-size:0.85rem;color:var(--color-text-muted);display:block;margin-bottom:4px;">Email</label><input type="email" placeholder="you@example.com" style="width:100%;padding:8px 12px;border:1px solid var(--color-border-strong);border-radius:4px;font-size:0.9rem;" disabled></div><div style="margin-bottom:12px;"><label style="font-size:0.85rem;color:var(--color-text-muted);display:block;margin-bottom:4px;">Password</label><input type="password" placeholder="••••••••" style="width:100%;padding:8px 12px;border:1px solid var(--color-border-strong);border-radius:4px;font-size:0.9rem;" disabled></div><div style="margin-bottom:16px;display:flex;align-items:center;gap:6px;"><input type="checkbox" disabled> <span style="font-size:0.85rem;">Remember me for 30 days</span></div><button class="btn btn-primary" style="width:100%;justify-content:center;" disabled>Sign In</button></div></div>'
    },

    // ============================================================
    // LAYOUT: Profile Settings
    // ============================================================
    {
        id: 'profile',
        name: 'Profile Settings',
        category: 'layout',
        description: 'Tabbed profile with Profile Info, Menu Configuration, Search Columns, and session settings (Keep me logged in indefinitely).',
        props: {},
        events: [],
        code: '<ProfileSettings />',
        preview: '<div style="max-width:600px;margin:0 auto;background:var(--bg-surface);border:1px solid var(--color-border);border-radius:var(--border-radius);overflow:hidden;"><div style="display:flex;border-bottom:1px solid var(--color-border);"><button style="flex:1;padding:10px;text-align:center;font-size:0.85rem;font-weight:600;background:var(--color-primary,#2a5c82);color:#fff;border:none;cursor:pointer;">Profile</button><button style="flex:1;padding:10px;text-align:center;font-size:0.85rem;font-weight:500;background:var(--bg-surface-alt);color:var(--color-text-muted);border:none;cursor:pointer;">Menu Config</button><button style="flex:1;padding:10px;text-align:center;font-size:0.85rem;font-weight:500;background:var(--bg-surface-alt);color:var(--color-text-muted);border:none;cursor:pointer;">Session</button></div><div style="padding:20px;"><div style="margin-bottom:16px;"><label style="font-size:0.85rem;color:var(--color-text-muted);display:block;margin-bottom:4px;">Full Name</label><input type="text" value="Eileen Bailey" style="width:100%;padding:8px 12px;border:1px solid var(--color-border-strong);border-radius:4px;font-size:0.9rem;" disabled></div><div style="display:flex;align-items:center;gap:8px;"><input type="checkbox" disabled> <span style="font-size:0.85rem;">Keep me logged in indefinitely</span></div></div></div>'
    },

    // ============================================================
    // LAYOUT: Support Chat Widget
    // ============================================================
    {
        id: 'chat',
        name: 'Support Chat Widget',
        category: 'layout',
        description: 'Floating bottom-right chat panel with bot greeting ("Beep boop. Me dumb robot"), category selector, and submit form.',
        props: {},
        events: [],
        code: '<SupportChat v-if="authenticated" />',
        preview: '<div style="max-width:360px;margin:0 auto;background:var(--bg-surface);border:1px solid var(--color-border);border-radius:var(--border-radius);overflow:hidden;box-shadow:var(--shadow);"><div style="background:var(--color-secondary);color:#fff;padding:12px 16px;font-weight:600;font-size:0.9rem;display:flex;align-items:center;gap:8px;"><i class="fas fa-comment-dots"></i> ARCHR Support</div><div style="padding:16px;min-height:200px;"><div style="background:var(--bg-surface-alt);padding:10px 14px;border-radius:12px 12px 12px 0;margin-bottom:12px;font-size:0.85rem;max-width:85%;">Beep boop. Me dumb robot. 🤖<br>How can I help?</div><div style="display:flex;flex-wrap:wrap;gap:6px;margin-top:12px;"><span style="background:var(--bg-surface-alt);border:1px solid var(--color-border);padding:4px 10px;border-radius:12px;font-size:0.75rem;">🐛 Bug</span><span style="background:var(--bg-surface-alt);border:1px solid var(--color-border);padding:4px 10px;border-radius:12px;font-size:0.75rem;">💡 Feature</span><span style="background:var(--bg-surface-alt);border:1px solid var(--color-border);padding:4px 10px;border-radius:12px;font-size:0.75rem;">🔑 Access</span></div></div><div style="border-top:1px solid var(--color-border);padding:8px 12px;display:flex;gap:8px;"><input type="text" placeholder="Type a message..." style="flex:1;padding:6px 10px;border:1px solid var(--color-border-strong);border-radius:4px;font-size:0.85rem;" disabled><button class="btn btn-primary btn-sm" disabled><i class="fas fa-paper-plane"></i></button></div></div>'
    },

    // ============================================================
    // LAYOUT: App Header
    // ============================================================
    {
        id: 'header',
        name: 'App Header',
        category: 'layout',
        description: 'Top navigation bar with case selector, role dropdown, theme toggle, language switch, and avatar menu.',
        props: {},
        events: ['open-case', 'set-role', 'toggle-theme', 'set-lang', 'logout', 'open-profile', 'toggle-mobile'],
        code: '<AppHeader\n  :cases="cases"\n  :role="role"\n  :theme="theme"\n  :user-name="$auth.displayName"\n  @logout="onLogout"\n/>',
        preview: '<div style="background:var(--color-secondary);color:#fff;padding:10px 20px;display:flex;align-items:center;justify-content:space-between;font-size:0.9rem;border-radius:var(--border-radius);"><div style="display:flex;align-items:center;gap:16px;"><strong style="font-family:var(--font-display);font-size:1.1rem;">ARCHR</strong><select style="background:rgba(255,255,255,0.15);color:#fff;border:1px solid rgba(255,255,255,0.3);border-radius:4px;padding:4px 8px;font-size:0.8rem;" disabled><option>Select Case...</option></select></div><div style="display:flex;align-items:center;gap:12px;"><span style="font-size:0.8rem;opacity:0.7;">Super Admin</span><button style="background:none;border:none;color:#fff;cursor:pointer;font-size:1rem;"><i class="fas fa-moon"></i></button><div style="width:32px;height:32px;border-radius:50%;background:rgba(255,255,255,0.3);display:flex;align-items:center;justify-content:center;font-size:0.8rem;font-weight:600;"><i class="fas fa-user"></i></div></div></div>'
    },

    // ============================================================
    // MARKETPLACE: Marketplace Home
    // ============================================================
    {
        id: 'mkt-home',
        name: 'Marketplace Home',
        category: 'marketplace',
        description: 'Landing page for the Marketplace. Welcome message + 4 browse options: Applications, Repair Needs, Trade, Triage.',
        props: {},
        events: ['browse'],
        code: '<MarketplaceHome @browse="onBrowse" />',
        preview: '<div style="text-align:center;padding:32px 20px;"><h2 style="font-family:var(--font-display);font-size:1.8rem;color:var(--color-primary,#2a5c82);margin-bottom:8px;">Welcome to the Marketplace</h2><p style="font-size:1.05rem;color:var(--color-text-muted,#6b7280);max-width:600px;margin:0 auto 32px;">Browse applications, repair needs, trades, or triage-prioritized work.</p><div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:20px;max-width:800px;margin:0 auto;">' +
            '<div style="background:var(--bg-surface);border:1px solid var(--color-border);border-radius:8px;padding:24px;text-align:center;cursor:pointer;"><div style="font-size:2rem;color:var(--color-primary);margin-bottom:8px;"><i class="fas fa-clipboard-list"></i></div><h3 style="font-size:1rem;margin-bottom:8px;">Browse by Applications</h3><button class="btn btn-primary btn-sm">View List</button></div>' +
            '<div style="background:var(--bg-surface);border:1px solid var(--color-border);border-radius:8px;padding:24px;text-align:center;cursor:pointer;"><div style="font-size:2rem;color:var(--color-primary);margin-bottom:8px;"><i class="fas fa-wrench"></i></div><h3 style="font-size:1rem;margin-bottom:8px;">Browse by Repair Needs</h3><button class="btn btn-primary btn-sm">View List</button></div>' +
            '<div style="background:var(--bg-surface);border:1px solid var(--color-border);border-radius:8px;padding:24px;text-align:center;cursor:pointer;"><div style="font-size:2rem;color:var(--color-primary);margin-bottom:8px;"><i class="fas fa-hammer"></i></div><h3 style="font-size:1rem;margin-bottom:8px;">Browse by Trade</h3><button class="btn btn-primary btn-sm"><i class="fas fa-hammer"></i></button></div>' +
            '<div style="background:var(--bg-surface);border:1px solid var(--color-border);border-radius:8px;padding:24px;text-align:center;cursor:pointer;"><div style="font-size:2rem;color:var(--color-primary);margin-bottom:8px;"><i class="fas fa-sort-amount-down"></i></div><h3 style="font-size:1rem;margin-bottom:8px;">Browse by Triage</h3><button class="btn btn-primary btn-sm"><i class="fas fa-exclamation-triangle"></i></button></div>' +
        '</div></div>'
    },

    // ============================================================
    // MARKETPLACE: Your Claims
    // ============================================================
    {
        id: 'mkt-claims',
        name: 'Your Claims',
        category: 'marketplace',
        description: 'List of all cases and repair projects your organization has claimed. Search, hide applications, release claims, renew timers.',
        props: {
            claims: { type: 'Array', default: '—' },
            currentOrg: { type: 'String', default: "''" }
        },
        events: ['release-claim', 'renew-claim'],
        code: '<YourClaims\n  :claims="claims"\n  current-org="AHFH"\n  @release-claim="onRelease"\n  @renew-claim="onRenew"\n/>',
        preview: '<div style="background:var(--bg-surface);border:1px solid var(--color-border);border-radius:8px;overflow:hidden;"><div style="padding:12px 16px;border-bottom:1px solid var(--color-border);display:flex;justify-content:space-between;align-items:center;"><strong>Your Claims</strong><div style="display:flex;gap:8px;"><input type="text" placeholder="Search claims..." style="padding:4px 8px;border:1px solid var(--color-border-strong);border-radius:4px;font-size:0.8rem;" disabled><label style="font-size:0.8rem;display:flex;align-items:center;gap:4px;"><input type="checkbox" disabled> Show applications</label></div></div>' +
            '<div style="padding:12px 16px;border-bottom:1px solid var(--color-border);display:flex;align-items:center;gap:12px;"><div style="width:48px;height:48px;background:var(--bg-surface-alt);border-radius:6px;display:flex;align-items:center;justify-content:center;color:var(--color-text-muted);font-size:0.7rem;"><i class="fas fa-image"></i></div><div style="flex:1;"><div style="font-weight:600;font-size:0.9rem;">BAILEY, E.</div><div style="font-size:0.8rem;color:var(--color-text-muted);font-family:monospace;">247-RIVERSIDE</div></div><div style="font-size:0.8rem;color:var(--color-text-muted);">Claimed Sep 10</div><span class="triage" style="background:#d1fae5;color:#059669;font-size:0.75rem;padding:2px 8px;border-radius:10px;">Active</span><div style="display:flex;gap:4px;"><button class="btn btn-sm" style="background:#d97706;color:#fff;"><i class="fas fa-undo"></i> Release</button><button class="btn btn-sm"><i class="fas fa-redo"></i> Renew</button></div></div>' +
            '<div style="padding:12px 16px;display:flex;align-items:center;gap:12px;"><div style="width:48px;height:48px;background:var(--bg-surface-alt);border-radius:6px;display:flex;align-items:center;justify-content:center;color:var(--color-text-muted);font-size:0.7rem;"><i class="fas fa-image"></i></div><div style="flex:1;"><div style="font-weight:600;font-size:0.9rem;">JOHNSON, M.</div><div style="font-size:0.8rem;color:var(--color-text-muted);font-family:monospace;">55-OAK-AVE</div></div><div style="font-size:0.8rem;color:var(--color-text-muted);">Claimed Aug 28</div><span class="triage" style="background:#fef3c7;color:#d97706;font-size:0.75rem;padding:2px 8px;border-radius:10px;">Expiring</span><div style="display:flex;gap:4px;"><button class="btn btn-sm" style="background:#d97706;color:#fff;"><i class="fas fa-undo"></i> Release</button><button class="btn btn-sm"><i class="fas fa-redo"></i> Renew</button></div></div>' +
        '</div>'
    },

    // ============================================================
    // MARKETPLACE: Unclaimed Needs
    // ============================================================
    {
        id: 'mkt-unclaimed',
        name: 'Unclaimed Repair Needs',
        category: 'marketplace',
        description: 'Filterable, searchable table of unclaimed repair needs with trade, triage score, and claim button.',
        props: {
            needs: { type: 'Array', default: '—' },
            currentOrg: { type: 'String', default: "''" }
        },
        events: ['claim-need'],
        code: '<UnclaimedNeeds\n  :needs="repairNeeds"\n  current-org="AHFH"\n  @claim-need="onClaim"\n/>',
        preview: '<div style="background:var(--bg-surface);border:1px solid var(--color-border);border-radius:8px;overflow:hidden;"><div style="padding:12px 16px;border-bottom:1px solid var(--color-border);display:flex;gap:8px;flex-wrap:wrap;"><input type="text" placeholder="Search by trade or description..." style="flex:1;padding:6px 10px;border:1px solid var(--color-border-strong);border-radius:4px;font-size:0.85rem;" disabled><select style="padding:6px 10px;border:1px solid var(--color-border-strong);border-radius:4px;font-size:0.85rem;" disabled><option>All Triage Levels</option></select><select style="padding:6px 10px;border:1px solid var(--color-border-strong);border-radius:4px;font-size:0.85rem;" disabled><option>Sort by Triage ↓</option></select></div>' +
            '<table style="width:100%;border-collapse:collapse;"><thead><tr style="background:var(--bg-surface-alt);"><th style="text-align:left;padding:8px 12px;font-size:0.75rem;text-transform:uppercase;color:var(--color-text-muted);border-bottom:1px solid var(--color-border);">Trade</th><th style="text-align:left;padding:8px 12px;font-size:0.75rem;text-transform:uppercase;color:var(--color-text-muted);border-bottom:1px solid var(--color-border);">Description</th><th style="text-align:left;padding:8px 12px;font-size:0.75rem;text-transform:uppercase;color:var(--color-text-muted);border-bottom:1px solid var(--color-border);">Triage</th><th style="text-align:left;padding:8px 12px;font-size:0.75rem;text-transform:uppercase;color:var(--color-text-muted);border-bottom:1px solid var(--color-border);">Received</th><th style="padding:8px 12px;border-bottom:1px solid var(--color-border);"></th></tr></thead>' +
            '<tbody>' +
            '<tr style="border-bottom:1px solid var(--color-border);"><td style="padding:10px 12px;font-weight:600;color:var(--color-primary);font-size:0.85rem;">Roofing</td><td style="padding:10px 12px;font-size:0.85rem;">Complete roof replacement after storm damage</td><td style="padding:10px 12px;"><span class="triage triage--critical">9</span></td><td style="padding:10px 12px;font-size:0.8rem;color:var(--color-text-muted);">Sep 15</td><td style="padding:10px 12px;"><button class="btn btn-primary btn-sm"><i class="fas fa-hand-holding-heart"></i> Claim</button></td></tr>' +
            '<tr style="border-bottom:1px solid var(--color-border);"><td style="padding:10px 12px;font-weight:600;color:var(--color-primary);font-size:0.85rem;">Plumbing</td><td style="padding:10px 12px;font-size:0.85rem;">Fix burst pipe in basement</td><td style="padding:10px 12px;"><span class="triage triage--critical">8</span></td><td style="padding:10px 12px;font-size:0.8rem;color:var(--color-text-muted);">Sep 12</td><td style="padding:10px 12px;"><button class="btn btn-primary btn-sm"><i class="fas fa-hand-holding-heart"></i> Claim</button></td></tr>' +
            '<tr><td style="padding:10px 12px;font-weight:600;color:var(--color-primary);font-size:0.85rem;">Drywall</td><td style="padding:10px 12px;font-size:0.85rem;">Replace ceiling and sheetrock</td><td style="padding:10px 12px;"><span class="triage triage--high">5</span></td><td style="padding:10px 12px;font-size:0.8rem;color:var(--color-text-muted);">Sep 10</td><td style="padding:10px 12px;"><button class="btn btn-primary btn-sm"><i class="fas fa-hand-holding-heart"></i> Claim</button></td></tr>' +
            '</tbody></table>' +
        '</div>'
    },

    // ============================================================
    // MARKETPLACE: Claimed by My Org
    // ============================================================
    {
        id: 'mkt-claimed-org',
        name: 'Claimed by My Org',
        category: 'marketplace',
        description: 'All repair needs claimed by your organization. Filter by trade and status. Shows expiring claims with countdown.',
        props: {
            claims: { type: 'Array', default: '—' },
            currentOrg: { type: 'String', default: "''" }
        },
        events: ['renew-claim', 'release-claim'],
        code: '<ClaimedByOrg\n  :claims="orgClaims"\n  current-org="AHFH"\n  @renew-claim="onRenew"\n  @release-claim="onRelease"\n/>',
        preview: '<div style="background:var(--bg-surface);border:1px solid var(--color-border);border-radius:8px;overflow:hidden;"><div style="padding:12px 16px;border-bottom:1px solid var(--color-border);display:flex;gap:8px;"><input type="text" placeholder="Search claims..." style="flex:1;padding:6px 10px;border:1px solid var(--color-border-strong);border-radius:4px;font-size:0.85rem;" disabled><select style="padding:6px 10px;border:1px solid var(--color-border-strong);border-radius:4px;font-size:0.85rem;" disabled><option>All Statuses</option></select></div>' +
            '<div style="padding:12px 16px;border-bottom:1px solid var(--color-border);display:flex;align-items:center;gap:12px;"><div style="flex:1;"><div style="font-weight:600;font-size:0.9rem;">Carpentry — Rental cabin destroyed</div><div style="font-size:0.8rem;color:var(--color-text-muted);">247-RIVERSIDE · Claimed Sep 10</div></div><span class="triage" style="background:#d1fae5;color:#059669;font-size:0.75rem;padding:2px 8px;border-radius:10px;">Active (75 days)</span><div style="display:flex;gap:4px;"><button class="btn btn-sm"><i class="fas fa-redo"></i> Renew</button><button class="btn btn-sm" style="background:#d97706;color:#fff;">Release</button></div></div>' +
            '<div style="padding:12px 16px;display:flex;align-items:center;gap:12px;"><div style="flex:1;"><div style="font-weight:600;font-size:0.9rem;">Plumbing — Burst pipe repair</div><div style="font-size:0.8rem;color:var(--color-text-muted);">55-OAK-AVE · Claimed Aug 28</div></div><span class="triage" style="background:#fef3c7;color:#d97706;font-size:0.75rem;padding:2px 8px;border-radius:10px;"><i class="fas fa-exclamation-triangle"></i> Expiring (8 days)</span><div style="display:flex;gap:4px;"><button class="btn btn-sm"><i class="fas fa-redo"></i> Renew</button><button class="btn btn-sm" style="background:#d97706;color:#fff;">Release</button></div></div>' +
        '</div>'
    },

    // ============================================================
    // MARKETPLACE: Repair Need Review
    // ============================================================
    {
        id: 'mkt-review',
        name: 'Repair Need Review',
        category: 'marketplace',
        description: 'Detail page for a specific repair need. Shows trade, description, claims history, and actions: Mark Met, Edit, Renew, Release.',
        props: {
            need: { type: 'Object', default: '—' },
            claims: { type: 'Array', default: '—' },
            currentOrg: { type: 'String', default: "''" }
        },
        events: ['mark-met', 'edit-need', 'renew-claim', 'release-claim'],
        code: '<RepairNeedReview\n  :need="selectedNeed"\n  :claims="needClaims"\n  current-org="AHFH"\n  @mark-met="onMarkMet"\n/>',
        preview: '<div style="background:var(--bg-surface);border:1px solid var(--color-border);border-radius:8px;overflow:hidden;"><div style="padding:20px;border-bottom:1px solid var(--color-border);"><div style="display:flex;align-items:baseline;gap:10px;margin-bottom:8px;"><span style="font-weight:700;font-size:1.1rem;color:var(--color-primary);">Carpentry</span><span style="flex:1;font-size:0.95rem;">Rental cabin completely destroyed by creek damage</span></div><div style="display:flex;gap:12px;align-items:center;font-size:0.85rem;"><span class="triage triage--critical"><i class="fas fa-exclamation-triangle"></i> 8</span><span style="color:var(--color-text-muted);">Case: AHFH-247-RIVERSIDE</span><span style="color:var(--color-success);font-weight:600;"><i class="fas fa-hand-holding-heart"></i> Claimed by: Asheville Area Habitat for Humanity</span></div><div style="display:flex;gap:8px;margin-top:12px;"><button class="btn btn-success btn-sm"><i class="fas fa-check-circle"></i> Mark Met</button><button class="btn btn-sm"><i class="fas fa-edit"></i> Edit</button></div></div>' +
            '<div style="padding:20px;"><h4 style="font-size:0.9rem;margin-bottom:12px;">Claims History</h4>' +
            '<div style="padding:10px 12px;background:var(--bg-surface-alt);border-radius:6px;margin-bottom:8px;display:flex;align-items:center;justify-content:space-between;"><div><div style="font-weight:600;font-size:0.85rem;">Asheville Area Habitat for Humanity</div><div style="font-size:0.8rem;color:var(--color-text-muted);">Claimed Sep 10 · Expires Dec 9</div></div><div style="display:flex;gap:4px;"><button class="btn btn-sm"><i class="fas fa-redo"></i> Renew</button><button class="btn btn-sm" style="background:#d97706;color:#fff;">Release</button></div></div>' +
            '</div></div>'
    },

    // ============================================================
    // MARKETPLACE: My Referrals
    // ============================================================
    {
        id: 'mkt-referrals',
        name: 'My Referrals',
        category: 'marketplace',
        description: 'Referral inbox and outbox. View sent and received referrals with request text, scope of work, and Open Application button.',
        props: {
            inbox: { type: 'Array', default: '—' },
            outbox: { type: 'Array', default: '—' }
        },
        events: ['open-application'],
        code: '<MyReferrals\n  :inbox="referralInbox"\n  :outbox="referralOutbox"\n  @open-application="openCase"\n/>',
        preview: '<div style="background:var(--bg-surface);border:1px solid var(--color-border);border-radius:8px;overflow:hidden;"><div style="display:flex;border-bottom:1px solid var(--color-border);"><button style="flex:1;padding:10px;text-align:center;font-size:0.85rem;font-weight:600;background:var(--color-primary);color:#fff;border:none;cursor:pointer;">Inbox (2)</button><button style="flex:1;padding:10px;text-align:center;font-size:0.85rem;font-weight:500;background:var(--bg-surface-alt);color:var(--color-text-muted);border:none;cursor:pointer;">Outbox (1)</button></div>' +
            '<div style="padding:12px 16px;border-bottom:1px solid var(--color-border);"><div style="display:flex;justify-content:space-between;align-items:start;"><div><div style="font-weight:600;font-size:0.9rem;">From: Community Housing Coalition</div><div style="font-size:0.85rem;color:var(--color-text-muted);margin-top:4px;">Request: Roof assessment for elderly resident</div><div style="font-size:0.8rem;color:var(--color-text-muted);margin-top:2px;">Scope: Full roof inspection and estimate</div></div><span style="font-size:0.7rem;font-weight:700;background:#dbeafe;color:#1d4ed8;padding:2px 8px;border-radius:10px;">Pending</span></div><div style="margin-top:8px;"><button class="btn btn-primary btn-sm"><i class="fas fa-folder-open"></i> Open Application</button></div></div>' +
            '<div style="padding:12px 16px;"><div style="display:flex;justify-content:space-between;align-items:start;"><div><div style="font-weight:600;font-size:0.9rem;">To: PODER Emma</div><div style="font-size:0.85rem;color:var(--color-text-muted);margin-top:4px;">Request: Plumbing emergency at 55-OAK-AVE</div><div style="font-size:0.8rem;color:var(--color-text-muted);margin-top:2px;">Scope: Emergency pipe replacement</div></div><span style="font-size:0.7rem;font-weight:700;background:#d1fae5;color:#059669;padding:2px 8px;border-radius:10px;">Accepted</span></div><div style="margin-top:8px;"><button class="btn btn-primary btn-sm"><i class="fas fa-folder-open"></i> Open Application</button></div></div>' +
        '</div>'
    },

    // ============================================================
    // MARKETPLACE: Refer Project Modal
    // ============================================================
    {
        id: 'mkt-refer',
        name: 'Refer Project Modal',
        category: 'marketplace',
        description: 'Modal for referring a project to a partner organization or requesting a subcontractor quote.',
        props: {
            visible: { type: 'Boolean', default: 'false' },
            recordDetails: { type: 'String', default: "''" },
            partners: { type: 'Array', default: '—' },
            subcontractors: { type: 'Array', default: '—' }
        },
        events: ['close', 'submit'],
        code: '<ReferProjectModal\n  :visible="showModal"\n  record-details="AHFH-247-RIVERSIDE"\n  :partners="orgs"\n  @close="showModal = false"\n  @submit="onSubmit"\n/>',
        preview: '<div style="background:var(--bg-surface);border:1px solid var(--color-border);border-radius:8px;padding:28px 32px;box-shadow:var(--shadow);"><h3 style="margin:0 0 4px;color:var(--color-primary);font-size:1.2rem;">Refer Project</h3><p style="font-size:0.9rem;color:var(--color-text-muted);margin-bottom:20px;">Use this form to create a referral record for AHFH-247-RIVERSIDE</p>' +
            '<div style="margin-bottom:16px;"><label style="font-size:0.85rem;font-weight:600;display:block;margin-bottom:6px;">Referral Type <span style="color:#dc2626;">*</span></label><div style="display:flex;flex-direction:column;gap:8px;"><label style="display:flex;align-items:center;gap:8px;font-size:0.9rem;cursor:pointer;"><input type="radio" name="rt" checked disabled><span>Refer project to Partner</span></label><label style="display:flex;align-items:center;gap:8px;font-size:0.9rem;cursor:pointer;"><input type="radio" name="rt" disabled><span>Request Subcontractor Quote</span></label></div></div>' +
            '<div style="margin-bottom:16px;"><label style="font-size:0.85rem;font-weight:600;display:block;margin-bottom:6px;">Referral To <span style="color:#dc2626;">*</span></label><select disabled style="width:100%;padding:8px 12px;border:1px solid var(--color-border-strong);border-radius:4px;font-size:0.9rem;"><option>— Select Partner —</option><option selected>Asheville Area Habitat for Humanity</option></select></div>' +
            '<div style="margin-bottom:20px;"><label style="font-size:0.85rem;font-weight:600;display:block;margin-bottom:6px;">Notes / Message</label><textarea disabled rows="3" style="width:100%;padding:8px 12px;border:1px solid var(--color-border-strong);border-radius:4px;font-size:0.9rem;font-family:inherit;" placeholder="Optional message..."></textarea></div>' +
            '<div style="display:flex;justify-content:flex-end;gap:8px;"><button class="btn btn-sm" disabled>Cancel</button><button class="btn btn-primary btn-sm" disabled><i class="fas fa-paper-plane"></i> Send Referral</button></div>' +
        '</div>'
    }
];

new Vue({
    el: '#component-library-app',
    data: {
        selectedId: '',
        activeVariant: '',
        cases: <?php echo $libCasesJson; ?>,
        user: <?php echo $libUserJson; ?>,
        openSections: {
            'Shared Components': true,
            'Marketplace': true,
            'Feature Components': false,
            'Layout / Page Components': false
        }
    },
    computed: {
        components: function() {
            return componentData;
        },
        sidebarSections: function() {
            var grouped = {};
            for (var i = 0; i < this.components.length; i++) {
                var c = this.components[i];
                if (!grouped[c.category]) grouped[c.category] = [];
                grouped[c.category].push(c);
            }
            var order = ['shared', 'marketplace', 'feature', 'layout'];
            var labels = { shared: 'Shared Components', marketplace: 'Marketplace', feature: 'Feature Components', layout: 'Layout / Page Components' };
            var sections = [];
            for (var j = 0; j < order.length; j++) {
                if (grouped[order[j]]) {
                    sections.push({ label: labels[order[j]], components: grouped[order[j]] });
                }
            }
            return sections;
        },
        selectedComponent: function() {
            for (var i = 0; i < this.components.length; i++) {
                if (this.components[i].id === this.selectedId) return this.components[i];
            }
            return null;
        }
    },
    methods: {
        toggleComp: function(id) {
            this.$set(this.openComponents, id, !this.openComponents[id]);
        },
        toggleSection: function(label) {
            this.$set(this.openSections, label, !this.openSections[label]);
        },
        getFclPreview: function() {
            if (!this.cases || !this.cases.length) {
                return '<div style="text-align:center;padding:40px 20px;color:var(--color-text-muted,#6b7280);"><i class="fas fa-table" style="font-size:2.5rem;opacity:0.3;display:block;margin-bottom:12px;"></i><p style="font-size:0.95rem;">Filterable Case List — no cases loaded</p><p style="font-size:0.8rem;margin-top:8px;">Log in via the portal to see live cases here.</p></div>';
            }
            var rows = '';
            for (var i = 0; i < Math.min(this.cases.length, 10); i++) {
                var c = this.cases[i];
                var name = c.applicant_name || c.name || c.contact || 'Unknown';
                var placecode = c.placecode || c.place_code || c.jobcode || '—';
                var status = c.status || c.case_status || '—';
                rows += '<tr><td style="padding:8px 12px;border-bottom:1px solid var(--color-border);font-size:0.85rem;">' + name + '</td>' +
                    '<td style="padding:8px 12px;border-bottom:1px solid var(--color-border);font-size:0.85rem;font-family:monospace;">' + placecode + '</td>' +
                    '<td style="padding:8px 12px;border-bottom:1px solid var(--color-border);font-size:0.85rem;">' + status + '</td></tr>';
            }
            return '<div style="background:var(--bg-surface);border:1px solid var(--color-border);border-radius:var(--border-radius);overflow:hidden;">' +
                '<div style="padding:12px 16px;border-bottom:1px solid var(--color-border);display:flex;justify-content:space-between;align-items:center;">' +
                    '<strong style="font-size:0.95rem;">Case List</strong>' +
                    '<span style="font-size:0.8rem;color:var(--color-text-muted);">' + this.cases.length + ' case' + (this.cases.length !== 1 ? 's' : '') + ' loaded</span>' +
                '</div>' +
                '<table style="width:100%;border-collapse:collapse;">' +
                    '<thead><tr style="background:var(--bg-surface-alt);">' +
                        '<th style="text-align:left;padding:8px 12px;font-size:0.75rem;text-transform:uppercase;letter-spacing:0.05em;color:var(--color-text-muted);border-bottom:1px solid var(--color-border);">Applicant</th>' +
                        '<th style="text-align:left;padding:8px 12px;font-size:0.75rem;text-transform:uppercase;letter-spacing:0.05em;color:var(--color-text-muted);border-bottom:1px solid var(--color-border);">Placecode</th>' +
                        '<th style="text-align:left;padding:8px 12px;font-size:0.75rem;text-transform:uppercase;letter-spacing:0.05em;color:var(--color-text-muted);border-bottom:1px solid var(--color-border);">Status</th>' +
                    '</tr></thead>' +
                    '<tbody>' + rows + '</tbody>' +
                '</table>' +
                (this.cases.length > 10 ? '<div style="padding:8px 16px;font-size:0.8rem;color:var(--color-text-muted);text-align:center;">Showing 10 of ' + this.cases.length + ' cases</div>' : '') +
            '</div>';
        }
    },
    mounted: function() {
        var self = this;
        this.$nextTick(function() {
            // Repair Need List toggle buttons
            document.querySelectorAll('.rnl-toggle').forEach(function(btn) {
                btn.addEventListener('click', function() {
                    var targetId = this.getAttribute('data-target');
                    var target = document.getElementById(targetId);
                    if (!target) return;
                    var isHidden = target.style.display === 'none';
                    target.style.display = isHidden ? '' : 'none';
                    var icon = this.querySelector('i');
                    if (icon) icon.className = isHidden ? 'fas fa-chevron-up' : 'fas fa-chevron-right';
                });
            });

            // Application Preview Card toggle
            document.querySelectorAll('.apc-toggle').forEach(function(btn) {
                btn.addEventListener('click', function() {
                    var card = this.closest('.apc');
                    if (!card) return;
                    var body = card.querySelector('.apc-body');
                    if (!body) return;
                    var isHidden = body.style.display === 'none';
                    body.style.display = isHidden ? '' : 'none';
                    var icon = this.querySelector('i');
                    if (icon) icon.className = isHidden ? 'fas fa-chevron-up' : 'fas fa-chevron-down';
                });
            });

            // Variant tabs
            document.querySelectorAll('.lib-variant-tab').forEach(function(tab) {
                tab.addEventListener('click', function() {
                    var container = this.closest('.lib-main');
                    if (!container) return;
                    var siblings = this.parentElement.querySelectorAll('.lib-variant-tab');
                    siblings.forEach(function(s) { s.classList.remove('is-active'); });
                    this.classList.add('is-active');
                    var variantId = this.textContent.trim().toLowerCase().replace(/\s+/g, '-');
                    var preview = container.querySelector('.lib-preview');
                    if (!preview) return;
                    var allVariantEls = preview.querySelectorAll('[data-variant]');
                    allVariantEls.forEach(function(el) {
                        el.style.display = el.getAttribute('data-variant') === variantId ? '' : 'none';
                    });
                });
            });
        });
    }
});
</script>

</body>
</html>
