<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Volunteer Dashboard (Draft) &ndash; ARCHR</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&family=Open+Sans:wght@400;600&display=swap" rel="stylesheet">
    <!-- <link rel="stylesheet" href="../../css/style.css"> -->
    <link rel="icon" type="image/svg+xml" href="../../archr-logo.svg">
    <script>(function(){try{var t=localStorage.getItem('archr-theme');if(t!=='light'&&t!=='dark'){t=window.matchMedia&&window.matchMedia('(prefers-color-scheme: dark)').matches?'dark':'light';}document.documentElement.setAttribute('data-theme',t);}catch(e){}})();</script>
    <style>
                /* CSS Reset & Base Styles */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

:root {
    /* ----- Brand ----- */
    --color-primary: #E04E39;        /* Habitat-style red/orange */
    --color-primary-dark: #C23A26;
    --color-secondary: #2A5C82;      /* Trustworthy blue */
    --color-canvas-cream: #FFFAE7;   /* Brand-spec page canvas */

    /* ----- Role Identity (from branding guide) ----- */
    --role-requestor: #FF7979;
    --role-caseworker: #FF7979;
    --role-assessor: #219BA4;
    --role-subcontractor: #AA6709;
    --role-envoy: #FFCC00;
    --role-project-manager: #3366CC;
    --role-crew-lead: #FF6600;
    --role-crew-member: #FF9900;
    --role-bursar: #00CC00;
    --role-volunteer: #A3C2FF;
    --role-admin: #5415B1;

    /* ----- Project Lifecycle Phases ----- */
    --phase-0-select: #0E232E;
    --phase-1-intake: #5C6D70;
    --phase-2-review: #A1683A;
    --phase-3-assign: #D4A373;
    --phase-4-site-work: #1B1B1B;
    --phase-5-complete: #00CC66;

    /* ----- Semantic ----- */
    --color-success: #2f9e69;
    --color-warning: #d99518;
    --color-danger:  #c23a26;
    --color-info:    #1d4665;

    /* ----- Typography ----- */
    --font-sans: 'Open Sans', system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;
    --font-display: 'Poppins', system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;
    --fs-xs: 0.75rem;
    --fs-sm: 0.875rem;
    --fs-base: 1rem;
    --fs-md: 1.125rem;
    --fs-lg: 1.25rem;
    --fs-xl: 1.5rem;
    --fs-2xl: 2rem;
    --fs-3xl: 2.5rem;
    --lh-tight: 1.3;
    --lh-base: 1.6;

    /* ----- Spacing scale (4px base) ----- */
    --space-1: 0.25rem;
    --space-2: 0.5rem;
    --space-3: 0.75rem;
    --space-4: 1rem;
    --space-5: 1.25rem;
    --space-6: 1.5rem;
    --space-8: 2rem;
    --space-10: 2.5rem;
    --space-12: 3rem;

    /* ----- Radii (0.6rem rule from brand guide) ----- */
    --radius-sm: 0.3rem;
    --radius-md: 0.6rem;
    --radius-lg: 1rem;
    --radius-pill: 999px;
    --border-radius: var(--radius-md); /* legacy alias */

    /* ----- Tap target ----- */
    --tap-target: 4rem;              /* brand-guide 4.0rem rule */

    /* ----- Layout ----- */
    --container-max: 1200px;
    --container-gutter: 20px;

    /* ----- Effects ----- */
    --shadow-sm: 0 2px 6px rgba(0, 0, 0, 0.06);
    --shadow:    0 4px 12px rgba(0, 0, 0, 0.08);
    --shadow-lg: 0 10px 25px rgba(0, 0, 0, 0.12);
    --transition: all 0.3s ease;

    /* ----- Z-index ----- */
    --z-sticky:   100;
    --z-dropdown: 200;
    --z-modal:   1000;

    /* ----- Semantic theme tokens — LIGHT (default) ----- */
    --bg-page:         var(--color-canvas-cream);
    --bg-surface:      #ffffff;
    --bg-surface-alt:  #F8F9FA;
    --color-text:      #333333;
    --color-text-muted:#6C757D;
    --color-text-inverse: #fafafa;
    --color-border-strong: #DEE2E6;
    --color-header-bg:   #ffffff;
    --color-header-text: #333333;
    --color-footer-bg:   #333333;
    --color-footer-text: #ffffff;

    /* ----- Legacy aliases (kept so existing rules theme automatically) ----- */
    --color-light:  var(--bg-surface-alt);
    --color-dark:   var(--color-text);
    --color-gray:   var(--color-text-muted);
    --color-border: var(--color-border-strong);
}

/* ----- Dark theme overrides ----- */
[data-theme="dark"] {
    --bg-page:         #1f1b1c;
    --bg-surface:      #2a2526;
    --bg-surface-alt:  #332d2e;
    --color-text:      #fafafa;
    --color-text-muted:#b6acad;
    --color-text-inverse: #2a2526;
    --color-border-strong: #4a4243;
    --color-header-bg:   #3b3637;   /* dark header per brand-guide note */
    --color-header-text: #fafafa;
    --color-footer-bg:   #1a1718;
    --color-footer-text: #fafafa;

    --shadow-sm: 0 2px 6px rgba(0, 0, 0, 0.3);
    --shadow:    0 4px 12px rgba(0, 0, 0, 0.4);
    --shadow-lg: 0 10px 25px rgba(0, 0, 0, 0.55);
}

/* Respect OS preference when the user hasn't explicitly chosen */
@media (prefers-color-scheme: dark) {
    :root:not([data-theme="light"]) {
        --bg-page:         #1f1b1c;
        --bg-surface:      #2a2526;
        --bg-surface-alt:  #332d2e;
        --color-text:      #fafafa;
        --color-text-muted:#b6acad;
        --color-text-inverse: #2a2526;
        --color-border-strong: #4a4243;
        --color-header-bg:   #3b3637;
        --color-header-text: #fafafa;
        --color-footer-bg:   #1a1718;
        --color-footer-text: #fafafa;
        --shadow-sm: 0 2px 6px rgba(0, 0, 0, 0.3);
        --shadow:    0 4px 12px rgba(0, 0, 0, 0.4);
        --shadow-lg: 0 10px 25px rgba(0, 0, 0, 0.55);
    }
}

body {
    font-family: var(--font-sans);
    line-height: var(--lh-base);
    color: var(--color-text);
    background-color: var(--bg-page);
    transition: background-color 0.3s ease, color 0.3s ease;
}

h1, h2, h3, h4 {
    font-family: var(--font-display);
    font-weight: 600;
    line-height: var(--lh-tight);
}

.container {
    width: 100%;
    max-width: var(--container-max);
    margin: 0 auto;
    padding: 0 var(--container-gutter);
}

/* Header */
.site-header {
    background-color: var(--color-header-bg);
    color: var(--color-header-text);
    box-shadow: 0 2px 10px rgba(0,0,0,0.05);
    position: sticky;
    top: 0;
    z-index: var(--z-sticky);
    transition: background-color 0.3s ease, color 0.3s ease;
}

.header-container {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 15px 20px;
    flex-wrap: wrap;
}

.logo-link {
    display: flex;
    align-items: center;
    text-decoration: none;
    color: inherit;
    gap: 15px;
}

.site-logo {
    height: 60px;
    width: auto;
}

.logo-text h1 {
    font-size: 1.8rem;
    margin-bottom: 0;
    color: var(--color-primary);
}

.tagline {
    font-size: 0.9rem;
    color: var(--color-gray);
    margin-top: -5px;
}

/* Navigation */
.nav-list {
    display: flex;
    list-style: none;
    align-items: center;
    gap: 25px;
    flex-wrap: wrap;
}

.nav-link {
    text-decoration: none;
    color: var(--color-dark);
    font-weight: 500;
    padding: 8px 0;
    position: relative;
    transition: var(--transition);
}

.nav-link:hover, .nav-link.active {
    color: var(--color-primary);
}

.nav-link.active::after {
    content: '';
    position: absolute;
    bottom: 0;
    left: 0;
    width: 100%;
    height: 3px;
    background-color: var(--color-primary);
    border-radius: 3px;
}

/* Theme toggle (light/dark) */
.theme-toggle {
    background: transparent;
    border: 2px solid var(--color-border);
    color: var(--color-text);
    width: 40px;
    height: 40px;
    border-radius: var(--radius-pill);
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-size: 0.95rem;
    line-height: 0;
    transition: var(--transition);
}

.theme-toggle:hover,
.theme-toggle:focus-visible {
    border-color: var(--color-primary);
    color: var(--color-primary);
    outline: none;
}

.theme-toggle .icon-sun { display: none; }
[data-theme="dark"] .theme-toggle .icon-moon { display: none; }
[data-theme="dark"] .theme-toggle .icon-sun  { display: inline-block; }

@media (prefers-color-scheme: dark) {
    :root:not([data-theme="light"]) .theme-toggle .icon-moon { display: none; }
    :root:not([data-theme="light"]) .theme-toggle .icon-sun  { display: inline-block; }
}

/* Buttons */
.btn {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 10px 22px;
    border-radius: var(--border-radius);
    font-weight: 600;
    text-decoration: none;
    cursor: pointer;
    transition: var(--transition);
    border: 2px solid transparent;
    font-size: 1rem;
}

.btn-primary {
    background-color: var(--color-primary);
    color: white;
}

.btn-primary:hover {
    background-color: var(--color-primary-dark);
    transform: translateY(-2px);
    box-shadow: var(--shadow);
}

.btn-secondary {
    background-color: var(--bg-surface);
    color: var(--color-primary);
    border: 2px solid var(--color-primary);
}

.btn-secondary:hover {
    background-color: var(--bg-surface-alt);
}

.btn-outline {
    background-color: transparent;
    color: var(--color-secondary);
    border: 2px solid var(--color-secondary);
}

.btn-outline:hover {
    background-color: var(--color-secondary);
    color: white;
}

.btn-large {
    padding: 14px 28px;
    font-size: 1.1rem;
}

/* Main Content & Tabs */
.content-tab {
    display: none;
    animation: fadeIn 0.5s ease;
    padding: 40px 0;
}

.active-tab {
    display: block;
}

@keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}

/* Hero Section */
.hero {
    position: relative;
    display: flex;
    align-items: center;
    min-height: 480px;
    margin-bottom: 60px;
    border-radius: var(--border-radius);
    overflow: hidden;
    isolation: isolate;
}

.hero-image {
    position: absolute;
    inset: 0;
    z-index: -1;
}

.hero-image .image-placeholder {
    width: 100%;
    height: 100%;
    background: var(--color-secondary);
}

.hero-image .image-placeholder img {
    display: block;
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.hero-image::after {
    content: "";
    position: absolute;
    inset: 0;
    background: linear-gradient(
        90deg,
        rgba(0, 0, 0, 0.7) 0%,
        rgba(0, 0, 0, 0.55) 40%,
        rgba(0, 0, 0, 0.15) 100%
    );
}

.hero-content {
    position: relative;
    max-width: 600px;
    padding: 60px 50px;
    color: #fff;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.35);
}

.hero-content h2 {
    font-size: 2.5rem;
    margin-bottom: 20px;
    color: #fff;
}

.lead {
    font-size: 1.2rem;
    color: rgba(255, 255, 255, 0.92);
    margin-bottom: 30px;
}

.hero-actions {
    display: flex;
    gap: 20px;
    flex-wrap: wrap;
}

.image-placeholder i {
    font-size: 4rem;
    margin-bottom: 20px;
    opacity: 0.7;
}

/* Cards */
.info-cards {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: 30px;
    margin-bottom: 50px;
}

.card {
    background: var(--bg-surface);
    border-radius: var(--border-radius);
    padding: 30px;
    box-shadow: var(--shadow);
    border-top: 5px solid var(--color-primary);
    transition: var(--transition);
}

.card:hover {
    transform: translateY(-5px);
    box-shadow: 0 10px 20px rgba(0,0,0,0.1);
}

.card-icon {
    font-size: 2.5rem;
    color: var(--color-primary);
    margin-bottom: 20px;
}

.card h3 {
    margin-bottom: 15px;
    font-size: 1.4rem;
}

/* Qualifications */
.qualifications-list {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 25px;
    margin: 40px 0;
}

.qualification-item {
    background: var(--color-light);
    padding: 25px;
    border-radius: var(--border-radius);
    border-left: 4px solid var(--color-secondary);
}

.qualification-header {
    display: flex;
    align-items: center;
    gap: 15px;
    margin-bottom: 15px;
}

.qualification-header i {
    font-size: 1.8rem;
    color: var(--color-secondary);
}

.callout {
    background: #e8f4ff;
    border-radius: var(--border-radius);
    padding: 30px;
    margin-top: 40px;
    border-left: 6px solid var(--color-secondary);
}

/* Partners */
.partners-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 30px;
    margin: 40px 0;
}

.partner-card {
    text-align: center;
    padding: 30px 20px;
    border: 1px solid var(--color-border);
    border-radius: var(--border-radius);
    transition: var(--transition);
}

.partner-card:hover {
    border-color: var(--color-primary);
    box-shadow: var(--shadow);
}

.partner-logo i {
    font-size: 3rem;
    color: var(--color-primary);
    margin-bottom: 20px;
}

.text-center {
    text-align: center;
}

/* Footer */
.site-footer {
    background-color: var(--color-footer-bg);
    color: var(--color-footer-text);
    padding: 40px 0;
    margin-top: 60px;
    transition: background-color 0.3s ease, color 0.3s ease;
}

.site-footer a {
    color: #a3d0ff;
}

.footer-contact {
    margin-top: 15px;
    font-size: 0.95rem;
}

.footer-note {
    margin-top: 30px;
    color: #aaa;
    font-size: 0.85rem;
}

/* Responsive */
@media (max-width: 992px) {
    .hero {
        min-height: 420px;
    }
    .hero-content {
        padding: 50px 40px;
    }
}

@media (max-width: 768px) {
    .header-container {
        flex-direction: column;
        gap: 20px;
    }
    .nav-list {
        justify-content: center;
    }
    .hero {
        min-height: 380px;
    }
    .hero-content {
        padding: 40px 25px;
        max-width: 100%;
    }
    .hero-content h2 {
        font-size: 2rem;
    }
    .hero-image::after {
        background: linear-gradient(
            180deg,
            rgba(0, 0, 0, 0.35) 0%,
            rgba(0, 0, 0, 0.65) 100%
        );
    }
    .btn-large {
        width: 100%;
        justify-content: center;
    }
    .hero-actions {
        flex-direction: column;
    }
}

/* ===== Dashboard ===== */
.dash-hero {
    background: linear-gradient(135deg, var(--color-secondary), var(--color-info));
    color: white;
    border-radius: var(--border-radius);
    padding: 40px;
    margin: 30px 0 40px;
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    justify-content: space-between;
    gap: 20px;
}

.dash-hero h2 {
    font-size: 2rem;
    margin-bottom: 8px;
}

.dash-hero p {
    opacity: 0.9;
    max-width: 60ch;
}

.dash-hero .updated {
    font-size: 0.85rem;
    opacity: 0.75;
    margin-top: 6px;
}

.dash-hero-meta {
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    gap: 10px;
}

.org-badge {
    background: rgba(255, 255, 255, 0.15);
    padding: 8px 16px;
    border-radius: var(--radius-pill);
    font-weight: 600;
    font-size: 0.9rem;
    border: 1px solid rgba(255, 255, 255, 0.25);
}

/* Section tabs (within dashboard pages) */
.dash-tabs {
    display: flex;
    gap: 4px;
    border-bottom: 2px solid var(--color-border);
    margin-bottom: 30px;
    flex-wrap: wrap;
}

.dash-tab {
    background: none;
    border: none;
    padding: 12px 20px;
    font-family: inherit;
    font-size: 1rem;
    font-weight: 600;
    color: var(--color-gray);
    cursor: pointer;
    border-bottom: 3px solid transparent;
    margin-bottom: -2px;
    transition: var(--transition);
}

.dash-tab:hover { color: var(--color-dark); }

.dash-tab.active {
    color: var(--color-primary);
    border-bottom-color: var(--color-primary);
}

.dash-section { display: none; }
.dash-section.active { display: block; animation: fadeIn 0.4s ease; }

.dash-section h3.dash-section-title {
    font-size: 1.4rem;
    margin: 30px 0 18px;
    color: var(--color-dark);
    display: flex;
    align-items: center;
    gap: 10px;
}

.dash-section h3.dash-section-title i {
    color: var(--color-primary);
}

/* KPI tile grid */
.kpi-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(210px, 1fr));
    gap: 20px;
    margin-bottom: 35px;
}

.kpi {
    background: var(--bg-surface);
    border-radius: var(--border-radius);
    padding: 22px;
    box-shadow: var(--shadow);
    border-left: 4px solid var(--color-primary);
    display: flex;
    flex-direction: column;
    gap: 6px;
    transition: var(--transition);
}

.kpi:hover { transform: translateY(-3px); }

.kpi.kpi-blue { border-left-color: var(--color-secondary); }
.kpi.kpi-green { border-left-color: var(--color-success); }
.kpi.kpi-amber { border-left-color: var(--color-warning); }
.kpi.kpi-gray  { border-left-color: var(--color-gray); }

.kpi-label {
    font-size: 0.85rem;
    color: var(--color-gray);
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.kpi-value {
    font-family: var(--font-display);
    font-size: var(--fs-2xl);
    font-weight: 700;
    color: var(--color-dark);
    line-height: 1.1;
}

.kpi-sub {
    font-size: 0.85rem;
    color: var(--color-gray);
}

.kpi-sub .delta-up   { color: var(--color-success); font-weight: 600; }
.kpi-sub .delta-down { color: var(--color-danger);  font-weight: 600; }


/* Chart card grid */
.chart-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
    gap: 25px;
    margin-bottom: 40px;
}

.chart-grid.cols-2 {
    grid-template-columns: repeat(auto-fit, minmax(420px, 1fr));
}

.chart-card {
    background: var(--bg-surface);
    border-radius: var(--border-radius);
    padding: 24px;
    box-shadow: var(--shadow);
    border: 1px solid var(--color-border);
    display: flex;
    flex-direction: column;
}

.chart-card header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 18px;
    gap: 10px;
}

.chart-card h4 {
    font-size: 1.05rem;
    color: var(--color-dark);
    margin: 0;
}

.chart-card .muted {
    color: var(--color-gray);
    font-size: 0.85rem;
}

.chart-canvas-wrap {
    position: relative;
    height: 260px;
}

.chart-canvas-wrap.tall { height: 320px; }

/* Cost summary card */
.cost-extremes {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
}

.cost-extremes .extreme {
    background: var(--color-light);
    padding: 18px;
    border-radius: var(--border-radius);
    border-left: 4px solid var(--color-secondary);
}

.cost-extremes .extreme.high { border-left-color: var(--color-danger); }
.cost-extremes .extreme.low  { border-left-color: var(--color-success); }

.cost-extremes .extreme .label {
    font-size: 0.8rem;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    color: var(--color-gray);
    font-weight: 600;
}

.cost-extremes .extreme .amount {
    font-family: var(--font-display);
    font-size: 1.6rem;
    font-weight: 700;
    color: var(--color-dark);
    margin: 4px 0;
}

.cost-extremes .extreme .meta {
    font-size: 0.85rem;
    color: var(--color-gray);
}

/* Pills / status badges */
.pill {
    display: inline-block;
    padding: 3px 10px;
    border-radius: var(--radius-pill);
    font-size: 0.78rem;
    font-weight: 600;
    background: var(--color-light);
    color: var(--color-gray);
    border: 1px solid var(--color-border);
}

.pill.pill-green { background: #e6f4ec; color: #1f6f47; border-color: #c5e6d2; }
.pill.pill-amber { background: #fdf3df; color: #8a5a0e; border-color: #f4dfa9; }
.pill.pill-red   { background: #fbe7e3; color: #8a2818; border-color: #f0c6bd; }
.pill.pill-blue  { background: #e3eef7; color: #1d4665; border-color: #b9d2e5; }

/* Mini login banner on private dashboard */
.login-banner {
    background: #fff8e1;
    border: 1px solid #f0d97c;
    color: #6b4f00;
    padding: 12px 18px;
    border-radius: var(--border-radius);
    margin-bottom: 25px;
    font-size: 0.9rem;
    display: flex;
    align-items: center;
    gap: 10px;
}

.login-banner i { color: #b07f00; }

/* Responsive tweaks */
@media (max-width: 700px) {
    .dash-hero { padding: 25px; }
    .dash-hero h2 { font-size: 1.5rem; }
    .kpi-value { font-size: 1.6rem; }
    .cost-extremes { grid-template-columns: 1fr; }
}


/* Nav dropdown (Partner Log In split menu) */
.nav-dropdown {
    position: relative;
}

.nav-dropdown > .btn {
    cursor: pointer;
}

.nav-dropdown-menu {
    position: absolute;
    top: calc(100% + 8px);
    right: 0;
    min-width: 220px;
    background: var(--bg-surface);
    border: 1px solid var(--color-border);
    border-radius: var(--border-radius);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
    padding: 8px;
    list-style: none;
    margin: 0;
    opacity: 0;
    visibility: hidden;
    transform: translateY(-4px);
    transition: opacity 0.18s ease, transform 0.18s ease, visibility 0.18s;
    z-index: var(--z-dropdown);
}

.nav-dropdown:hover .nav-dropdown-menu,
.nav-dropdown:focus-within .nav-dropdown-menu {
    opacity: 1;
    visibility: visible;
    transform: translateY(0);
}

.nav-dropdown-menu li { display: block; }

.nav-dropdown-menu a {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 10px 12px;
    border-radius: 6px;
    text-decoration: none;
    color: var(--color-dark);
    font-weight: 500;
    font-size: 0.95rem;
}

.nav-dropdown-menu a:hover,
.nav-dropdown-menu a:focus {
    background: var(--color-light);
    color: var(--color-primary);
    outline: none;
}

.nav-dropdown-menu .menu-divider {
    height: 1px;
    background: var(--color-border);
    margin: 6px 4px;
}

.nav-dropdown-menu .menu-label {
    display: block;
    padding: 6px 12px 2px;
    font-size: 0.72rem;
    color: var(--color-gray);
    text-transform: uppercase;
    letter-spacing: 0.6px;
    font-weight: 600;
}

/* Admin badge variant */
.org-badge.admin-badge {
    background: rgba(224, 78, 57, 0.18);
    border-color: rgba(255, 255, 255, 0.35);
}

/* =========================================================================
   Partner Portal (sidebar app shell)
   Used on partner-portal.html. body.has-portal claims the viewport so the
   shell can manage its own scroll. Sidebar + topbar = --bg-surface; content
   area uses --bg-page (canvas cream) so KPIs/cards continue to pop.
   ========================================================================= */
body.has-portal {
    overflow: hidden;
}

.portal-app {
    display: grid;
    grid-template-columns: 260px 1fr;
    height: 100vh;
    height: 100dvh;
    background: var(--bg-page);
}

.portal-sidebar {
    background: var(--bg-surface);
    color: var(--color-text);
    display: flex;
    flex-direction: column;
    border-right: 1px solid var(--color-border);
    transition: transform 0.3s ease;
    z-index: var(--z-sticky);
    min-width: 0;
}

.portal-sidebar-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: var(--space-4) var(--space-5);
    border-bottom: 1px solid var(--color-border);
    gap: var(--space-3);
}

.portal-brand {
    display: inline-flex;
    align-items: center;
    gap: var(--space-3);
    text-decoration: none;
    color: inherit;
    min-width: 0;
}

.portal-brand-mark {
    height: 36px;
    width: auto;
    flex-shrink: 0;
}

.portal-brand-text {
    font-family: var(--font-display);
    font-weight: 700;
    color: var(--color-primary);
    font-size: var(--fs-lg);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.portal-icon-btn {
    background: transparent;
    border: none;
    color: var(--color-text);
    cursor: pointer;
    width: 36px;
    height: 36px;
    border-radius: var(--radius-sm);
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-size: 1rem;
    transition: var(--transition);
}

.portal-icon-btn:hover,
.portal-icon-btn:focus-visible {
    background: var(--bg-surface-alt);
    color: var(--color-primary);
    outline: none;
}

.portal-sidebar-close { display: none; }

.portal-nav {
    flex: 1;
    overflow-y: auto;
    padding: var(--space-3);
}

.portal-nav ul {
    list-style: none;
    margin: 0;
    padding: 0;
    display: flex;
    flex-direction: column;
    gap: 2px;
}

.portal-nav-link {
    display: flex;
    align-items: center;
    gap: var(--space-3);
    padding: var(--space-3) var(--space-4);
    border-radius: var(--radius-sm);
    color: var(--color-text);
    text-decoration: none;
    font-weight: 500;
    font-size: var(--fs-sm);
    transition: var(--transition);
    border-left: 3px solid transparent;
}

.portal-nav-link i {
    width: 1.25rem;
    text-align: center;
    font-size: 1rem;
    color: var(--color-text-muted);
    transition: var(--transition);
}

.portal-nav-link:hover {
    background: var(--bg-surface-alt);
    color: var(--color-primary);
}

.portal-nav-link:hover i { color: var(--color-primary); }

.portal-nav-link.active {
    background: var(--bg-surface-alt);
    color: var(--color-primary);
    border-left-color: var(--color-primary);
    font-weight: 600;
}

.portal-nav-link.active i { color: var(--color-primary); }

.portal-sidebar-footer {
    padding: var(--space-3);
    border-top: 1px solid var(--color-border);
}

/* Main column */
.portal-main {
    display: flex;
    flex-direction: column;
    min-width: 0;
    overflow: hidden;
}

.portal-topbar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: var(--space-3) var(--space-6);
    background: var(--bg-surface);
    border-bottom: 1px solid var(--color-border);
    gap: var(--space-4);
    flex-shrink: 0;
}

.portal-topbar-left,
.portal-topbar-right {
    display: flex;
    align-items: center;
    gap: var(--space-3);
}

.portal-mobile-toggle { display: none; }

.portal-page-title {
    font-family: var(--font-display);
    font-size: var(--fs-xl);
    font-weight: 600;
    color: var(--color-text);
    margin: 0;
}

.portal-user-menu { position: relative; }

.portal-avatar {
    width: 40px;
    height: 40px;
    border-radius: var(--radius-pill);
    background: var(--color-primary);
    color: #fff;
    border: 2px solid transparent;
    font-weight: 600;
    font-size: var(--fs-sm);
    cursor: pointer;
    transition: var(--transition);
}

.portal-avatar:hover,
.portal-avatar:focus-visible {
    border-color: var(--color-primary-dark);
    outline: none;
}

.portal-user-dropdown {
    position: absolute;
    top: calc(100% + 8px);
    right: 0;
    min-width: 240px;
    background: var(--bg-surface);
    border: 1px solid var(--color-border);
    border-radius: var(--border-radius);
    box-shadow: var(--shadow-lg);
    z-index: var(--z-dropdown);
}

.portal-user-info {
    padding: var(--space-3) var(--space-4);
    border-bottom: 1px solid var(--color-border);
    display: flex;
    flex-direction: column;
    gap: var(--space-1);
}

.portal-user-info strong { color: var(--color-text); font-size: var(--fs-sm); }
.portal-user-info small  { color: var(--color-text-muted); font-size: var(--fs-xs); }

.portal-user-dropdown ul {
    list-style: none;
    margin: 0;
    padding: var(--space-2) 0;
}

.portal-user-dropdown a {
    display: flex;
    align-items: center;
    gap: var(--space-3);
    padding: var(--space-2) var(--space-4);
    color: var(--color-text);
    text-decoration: none;
    font-size: var(--fs-sm);
    transition: var(--transition);
}

.portal-user-dropdown a:hover { background: var(--bg-surface-alt); color: var(--color-primary); }
.portal-user-dropdown a.danger { color: var(--color-danger); }
.portal-user-dropdown a.danger:hover { background: rgba(194, 58, 38, 0.08); color: var(--color-danger); }

.portal-user-dropdown li[role="separator"] {
    height: 1px;
    background: var(--color-border);
    margin: var(--space-2) 0;
}

/* Scrollable content area */
.portal-content {
    flex: 1;
    overflow-y: auto;
    padding: var(--space-6);
    background: var(--bg-page);
}

.portal-page { max-width: var(--container-max); margin: 0 auto; }
.portal-page[hidden] { display: none; }

.portal-coming-soon {
    text-align: center;
    padding: var(--space-12) var(--space-6);
    color: var(--color-text-muted);
    background: var(--bg-surface);
    border-radius: var(--border-radius);
    box-shadow: var(--shadow-sm);
}

.portal-coming-soon i {
    font-size: 3rem;
    color: var(--color-primary);
    margin-bottom: var(--space-4);
    opacity: 0.7;
}

.portal-coming-soon h2 {
    font-family: var(--font-display);
    font-size: var(--fs-xl);
    color: var(--color-text);
    margin-bottom: var(--space-2);
}

.chart-card-note {
    margin-top: 18px;
    color: var(--color-text-muted);
    font-size: 0.9rem;
}
.chart-card-note strong { color: var(--color-text); }

/* Mobile: sidebar becomes a slide-in drawer */
@media (max-width: 992px) {
    .portal-app { grid-template-columns: 1fr; }
    .portal-sidebar {
        position: fixed;
        top: 0;
        left: 0;
        bottom: 0;
        width: 280px;
        max-width: 85vw;
        transform: translateX(-100%);
        box-shadow: var(--shadow-lg);
    }
    .portal-sidebar.is-open { transform: translateX(0); }
    .portal-sidebar-close { display: inline-flex; }
    .portal-mobile-toggle { display: inline-flex; }
}

@media (max-width: 700px) {
    .portal-topbar { padding: var(--space-3) var(--space-4); }
    .portal-content { padding: var(--space-4); }
    .portal-page-title { font-size: var(--fs-lg); }
    .portal-topbar-right .org-badge { display: none; }
}

/* =========================================================================
   Cases module (partner portal)
   Long-scroll case detail that stitches all six schema systems onto one page,
   plus the privacy-first Placecode list view. Class names map 1:1 to the
   data-* hooks in partner-portal.html and the renderers in js/case-detail.js.
   ========================================================================= */

.visually-hidden {
    position: absolute;
    width: 1px; height: 1px;
    padding: 0; margin: -1px;
    overflow: hidden; clip: rect(0, 0, 0, 0);
    white-space: nowrap; border: 0;
}

.muted { color: var(--color-text-muted); }

/* ----- List view --------------------------------------------------------- */
.case-list-header {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: var(--space-4);
    margin-bottom: var(--space-5);
}
.case-list-header h2 {
    font-family: var(--font-display);
    font-size: var(--fs-xl);
    color: var(--color-text);
    margin-bottom: var(--space-2);
}
.case-list-sub {
    color: var(--color-text-muted);
    max-width: 60ch;
    font-size: var(--fs-sm);
}

.case-list-table-wrap {
    background: var(--bg-surface);
    border: 1px solid var(--color-border-strong);
    border-radius: var(--radius-md);
    box-shadow: var(--shadow-sm);
    overflow-x: auto;
}
.case-list-table {
    width: 100%;
    border-collapse: collapse;
    font-size: var(--fs-sm);
}
.case-list-table thead th {
    text-align: left;
    padding: var(--space-3) var(--space-4);
    background: var(--bg-surface-alt);
    color: var(--color-text-muted);
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    font-size: var(--fs-xs);
    border-bottom: 1px solid var(--color-border-strong);
}
.case-list-table tbody td,
.case-list-table tbody th {
    padding: var(--space-3) var(--space-4);
    border-bottom: 1px solid var(--color-border-strong);
    vertical-align: middle;
}
.case-list-table tbody tr:last-child td,
.case-list-table tbody tr:last-child th { border-bottom: 0; }
.case-list-table tbody tr:hover { background: var(--bg-surface-alt); }
.case-list-placecode {
    font-family: var(--font-display);
    font-weight: 600;
    color: var(--color-text);
    letter-spacing: 0.02em;
}
.case-list-actions { text-align: right; }
.case-list-open { min-height: auto; padding: 6px 14px; font-size: var(--fs-sm); }
.case-list-loading {
    text-align: center;
    padding: var(--space-6);
    color: var(--color-text-muted);
}

/* ----- Detail view shell ------------------------------------------------- */
.case-back-link {
    display: inline-flex;
    align-items: center;
    gap: var(--space-2);
    color: var(--color-secondary);
    text-decoration: none;
    font-weight: 600;
    margin-bottom: var(--space-4);
}
.case-back-link:hover { text-decoration: underline; }

.case-section-nav {
    position: sticky;
    top: 0;
    z-index: var(--z-sticky);
    background: var(--bg-page);
    padding: var(--space-3) 0;
    margin-bottom: var(--space-4);
    border-bottom: 1px solid var(--color-border-strong);
}
.case-section-nav ul {
    display: flex;
    flex-wrap: wrap;
    gap: var(--space-2);
    list-style: none;
    padding: 0; margin: 0;
}
.case-section-nav a {
    display: inline-block;
    padding: 6px 12px;
    border-radius: var(--radius-pill);
    text-decoration: none;
    color: var(--color-text-muted);
    background: var(--bg-surface);
    border: 1px solid var(--color-border-strong);
    font-size: var(--fs-sm);
    font-weight: 600;
    transition: var(--transition);
}
.case-section-nav a:hover { color: var(--color-text); }
.case-section-nav a.is-active {
    color: #fff;
    background: var(--color-secondary);
    border-color: var(--color-secondary);
}

.case-detail-body { display: grid; gap: var(--space-6); }

.case-section {
    background: var(--bg-surface);
    border: 1px solid var(--color-border-strong);
    border-radius: var(--radius-md);
    padding: var(--space-6);
    box-shadow: var(--shadow-sm);
    scroll-margin-top: 80px;
}
.case-section-title {
    font-family: var(--font-display);
    font-size: var(--fs-lg);
    color: var(--color-text);
    display: flex;
    align-items: center;
    gap: var(--space-2);
    margin-bottom: var(--space-4);
    flex-wrap: wrap;
}
.case-section-title i { color: var(--color-secondary); }
.case-section-source {
    font-family: var(--font-sans);
    font-size: var(--fs-xs);
    color: var(--color-text-muted);
    font-weight: 500;
    text-transform: uppercase;
    letter-spacing: 0.05em;
}
.case-section-lead {
    color: var(--color-text-muted);
    margin-bottom: var(--space-4);
}

/* ----- Overview: phase tracker + KPIs ------------------------------------ */
.case-overview-sub {
    color: var(--color-text-muted);
    margin-bottom: var(--space-4);
}
.case-overview-sub strong { color: var(--color-text); }

.phase-tracker {
    list-style: none;
    padding: 0; margin: 0 0 var(--space-5);
    display: grid;
    grid-template-columns: repeat(6, 1fr);
    gap: var(--space-2);
    counter-reset: phase;
}
.phase-step {
    position: relative;
    text-align: center;
    padding: var(--space-3) var(--space-2) var(--space-2);
    border-radius: var(--radius-md);
    background: var(--bg-surface-alt);
    border: 1px solid var(--color-border-strong);
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: var(--space-1);
}
.phase-step-dot {
    width: 32px; height: 32px;
    border-radius: var(--radius-pill);
    background: var(--bg-surface);
    border: 2px solid var(--color-border-strong);
    color: var(--color-text-muted);
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-weight: 700;
    font-family: var(--font-display);
}
.phase-step-label {
    font-weight: 600;
    color: var(--color-text);
    font-size: var(--fs-sm);
}
.phase-step-date {
    font-size: var(--fs-xs);
    color: var(--color-text-muted);
}
.phase-step--done .phase-step-dot {
    background: var(--color-success);
    border-color: var(--color-success);
    color: #fff;
}
.phase-step--current {
    background: #fdf3df;
    border-color: #f4dfa9;
}
.phase-step--current .phase-step-dot {
    background: var(--color-warning);
    border-color: var(--color-warning);
    color: #fff;
    box-shadow: 0 0 0 4px rgba(217, 149, 24, 0.18);
}
.phase-step--pending { opacity: 0.7; }

.case-kpi-grid { margin-top: var(--space-2); }

/* ----- Generic case cards + rows ----------------------------------------- */
.case-card {
    background: var(--bg-surface-alt);
    border: 1px solid var(--color-border-strong);
    border-radius: var(--radius-md);
    padding: var(--space-5);
}
.case-card h3 {
    font-family: var(--font-display);
    font-size: var(--fs-md);
    color: var(--color-text);
    margin-bottom: var(--space-3);
    display: flex; align-items: center; gap: var(--space-2);
}
.case-card-grid {
    display: grid;
    gap: var(--space-4);
}
.case-card-grid.cols-2 { grid-template-columns: 1fr 1fr; }
.case-card-note {
    margin-top: var(--space-3);
    font-size: var(--fs-sm);
    color: var(--color-text-muted);
}
.case-card-note strong { color: var(--color-text); }
.case-card--alert {
    background: #fbe7e3;
    border-color: #f0c6bd;
}
.case-card--alert h3 { color: #8a2818; }
.case-card--status {
    border-left: 4px solid var(--color-secondary);
}
.case-row {
    display: flex;
    justify-content: space-between;
    gap: var(--space-3);
    padding: var(--space-2) 0;
    border-bottom: 1px dashed var(--color-border-strong);
}
.case-row:last-of-type { border-bottom: 0; }
.case-row-k {
    font-size: var(--fs-sm);
    color: var(--color-text-muted);
    text-transform: uppercase;
    letter-spacing: 0.04em;
    font-weight: 600;
}
.case-row-v {
    color: var(--color-text);
    text-align: right;
}
.case-private-line {
    display: flex; align-items: center; gap: var(--space-2);
    padding: var(--space-2) var(--space-3);
    background: var(--bg-surface);
    border-radius: var(--radius-sm);
    border: 1px solid var(--color-border-strong);
    margin-bottom: var(--space-3);
}
.case-private-line i { color: var(--color-secondary); }
.case-private-tag {
    margin-left: auto;
    font-size: var(--fs-xs);
    color: var(--color-text-muted);
    text-transform: uppercase;
    letter-spacing: 0.04em;
}
.case-urgent-list {
    list-style: none;
    padding: 0; margin: 0;
    display: grid; gap: var(--space-2);
}
.case-urgent-list li {
    display: flex; align-items: center; gap: var(--space-2);
    color: #8a2818;
}
.case-urgent-list i { color: var(--color-danger); }
.case-next-action {
    margin-top: var(--space-3);
    padding-top: var(--space-3);
    border-top: 1px solid var(--color-border-strong);
    color: var(--color-text);
}
.case-next-action i { color: var(--color-secondary); margin-right: var(--space-1); }


/* ----- Coalition match list --------------------------------------------- */
.match-list {
    list-style: none;
    padding: 0; margin: 0;
    display: grid; gap: var(--space-3);
}
.match-item {
    display: grid;
    grid-template-columns: auto 1fr;
    gap: var(--space-4);
    align-items: center;
    padding: var(--space-4);
    border-radius: var(--radius-md);
    background: var(--bg-surface-alt);
    border: 1px solid var(--color-border-strong);
}
.match-item--claimed { border-left: 4px solid var(--color-success); }
.match-item--expired { opacity: 0.7; border-left: 4px solid var(--color-danger); }
.match-item--passed  { border-left: 4px solid var(--color-secondary); }
.match-score {
    width: 64px; height: 64px;
    border-radius: var(--radius-pill);
    background: var(--bg-surface);
    border: 2px solid var(--color-border-strong);
    display: flex; align-items: baseline; justify-content: center;
    font-family: var(--font-display);
    color: var(--color-secondary);
}
.match-score-num { font-size: 1.5rem; font-weight: 700; line-height: 1; }
.match-score-pct { font-size: var(--fs-xs); margin-left: 2px; }
.match-head {
    display: flex; align-items: center; gap: var(--space-3);
    margin-bottom: var(--space-1);
}
.match-head strong { color: var(--color-text); font-family: var(--font-display); }
.match-reason { color: var(--color-text); font-size: var(--fs-sm); }
.match-responded { color: var(--color-text-muted); font-size: var(--fs-xs); margin-top: var(--space-1); }

/* ----- Team chips ------------------------------------------------------- */
.team-chip-row {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    gap: var(--space-3);
    margin-bottom: var(--space-4);
}
.team-chip {
    display: flex; align-items: center; gap: var(--space-3);
    padding: var(--space-3);
    background: var(--bg-surface-alt);
    border: 1px solid var(--color-border-strong);
    border-radius: var(--radius-md);
    border-left: 4px solid var(--color-gray);
}
.team-chip--caseworker      { border-left-color: var(--role-caseworker); }
.team-chip--assessor        { border-left-color: var(--role-assessor); }
.team-chip--crew_lead       { border-left-color: var(--role-crew-lead); }
.team-chip--crew_member     { border-left-color: var(--role-crew-member); }
.team-chip--project_manager { border-left-color: var(--role-project-manager); }
.team-chip--bursar          { border-left-color: var(--role-bursar); }
.team-chip--volunteer       { border-left-color: var(--role-volunteer); }
.team-chip--admin           { border-left-color: var(--role-admin); }
.team-chip-avatar {
    width: 44px; height: 44px;
    border-radius: var(--radius-pill);
    background: var(--color-secondary);
    color: #fff;
    display: inline-flex; align-items: center; justify-content: center;
    font-family: var(--font-display);
    font-weight: 700;
    flex-shrink: 0;
}
.team-chip-body { display: flex; flex-direction: column; min-width: 0; }
.team-chip-role {
    font-size: var(--fs-xs);
    color: var(--color-text-muted);
    text-transform: uppercase;
    letter-spacing: 0.04em;
    font-weight: 600;
}
.team-chip-body strong { color: var(--color-text); }
.team-chip-meta { font-size: var(--fs-xs); color: var(--color-text-muted); }

/* ----- Documents -------------------------------------------------------- */
.doc-group + .doc-group { margin-top: var(--space-5); }
.doc-group-title {
    font-family: var(--font-display);
    font-size: var(--fs-md);
    color: var(--color-text);
    margin-bottom: var(--space-3);
}
.doc-group-count { color: var(--color-text-muted); font-weight: 400; font-size: var(--fs-sm); }

.doc-file-list { display: grid; gap: var(--space-2); }
.doc-file {
    display: flex; align-items: center; gap: var(--space-3);
    padding: var(--space-3);
    background: var(--bg-surface-alt);
    border: 1px solid var(--color-border-strong);
    border-radius: var(--radius-sm);
}
.doc-file > i:first-child {
    font-size: 1.25rem;
    color: var(--color-secondary);
    width: 32px; text-align: center;
}
.doc-file-body { display: flex; flex-direction: column; flex: 1; min-width: 0; }
.doc-file-label { font-weight: 600; color: var(--color-text); }
.doc-file-meta { font-size: var(--fs-xs); color: var(--color-text-muted); }
.doc-file--redacted .doc-file-label::after {
    content: '';
}

.doc-photo-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
    gap: var(--space-3);
}
.doc-photo {
    margin: 0;
    background: var(--bg-surface-alt);
    border: 1px solid var(--color-border-strong);
    border-radius: var(--radius-md);
    overflow: hidden;
}
.doc-photo-thumb {
    aspect-ratio: 4 / 3;
    display: flex; align-items: center; justify-content: center;
    color: rgba(255, 255, 255, 0.7);
    font-size: 2rem;
}
.doc-photo figcaption {
    padding: var(--space-2) var(--space-3);
    display: flex; flex-direction: column;
}
.doc-photo-label { font-weight: 600; color: var(--color-text); font-size: var(--fs-sm); }
.doc-photo-date { font-size: var(--fs-xs); color: var(--color-text-muted); }


/* ----- Finance: stacked funding bar ------------------------------------- */
.fund-bar {
    display: flex;
    width: 100%;
    height: 28px;
    border-radius: var(--radius-pill);
    overflow: hidden;
    background: var(--bg-surface);
    border: 1px solid var(--color-border-strong);
    margin: var(--space-3) 0;
}
.fund-bar-slice {
    display: block;
    height: 100%;
    min-width: 2px;
}
.fund-legend {
    list-style: none;
    padding: 0; margin: 0;
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    gap: var(--space-2) var(--space-4);
}
.fund-legend li {
    display: flex; align-items: center; gap: var(--space-2);
    font-size: var(--fs-sm);
}
.fund-legend-swatch {
    width: 14px; height: 14px;
    border-radius: var(--radius-sm);
    flex-shrink: 0;
}
.fund-legend-name { flex: 1; color: var(--color-text); }
.fund-legend-amount { color: var(--color-text-muted); font-variant-numeric: tabular-nums; }

/* ----- Help cards ------------------------------------------------------- */
.help-card-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: var(--space-3);
}
.help-card {
    display: flex; align-items: center; gap: var(--space-3);
    padding: var(--space-4);
    background: var(--bg-surface-alt);
    border: 1px solid var(--color-border-strong);
    border-radius: var(--radius-md);
    text-decoration: none;
    color: var(--color-text);
    transition: var(--transition);
}
.help-card:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow);
    border-color: var(--color-secondary);
}
.help-card > i:first-child {
    font-size: 1.5rem;
    color: var(--color-secondary);
    width: 32px; text-align: center;
}
.help-card > div { flex: 1; display: flex; flex-direction: column; min-width: 0; }
.help-card-type {
    font-size: var(--fs-xs);
    color: var(--color-text-muted);
    text-transform: uppercase;
    letter-spacing: 0.04em;
    font-weight: 600;
}
.help-card strong { color: var(--color-text); }
.help-card-arrow { color: var(--color-text-muted); }
.help-card:hover .help-card-arrow { color: var(--color-secondary); }

/* ----- Responsive ------------------------------------------------------- */
@media (max-width: 992px) {
    .phase-tracker { grid-template-columns: repeat(3, 1fr); }
    .case-card-grid.cols-2 { grid-template-columns: 1fr; }
}
@media (max-width: 700px) {
    .case-list-header { flex-direction: column; }
    .case-section { padding: var(--space-4); }
    .phase-tracker { grid-template-columns: repeat(2, 1fr); }
    .case-row { flex-direction: column; gap: var(--space-1); }
    .case-row-v { text-align: left; }
    .match-item { grid-template-columns: 1fr; text-align: center; }
    .match-score { margin: 0 auto; }
    .match-head { justify-content: center; }
}

/* ----- Dark-theme tweaks for cases module ------------------------------- */
[data-theme="dark"] .case-card--alert {
    background: #3a201a;
    border-color: #5a2f25;
}
[data-theme="dark"] .case-card--alert h3,
[data-theme="dark"] .case-urgent-list li { color: #f3b8ac; }
[data-theme="dark"] .case-urgent-list i { color: #e57c66; }
[data-theme="dark"] .phase-step--current {
    background: #3a2f1a;
    border-color: #5a4a25;
}



/* =========================================================================
   Dark-theme component overrides
   Component tweaks that can't be expressed purely through theme tokens.
   Mirror each rule under both [data-theme="dark"] (explicit choice) and
   the prefers-color-scheme fallback (no explicit choice stored).
   ========================================================================= */

/* Temporary logo fix: the SVG ships in black + red only. invert(1) flips
   luminance so the black mark reads on dark backgrounds; hue-rotate(180deg)
   restores red so the accent arrow is preserved. Remove when a true
   white-on-dark logo asset is available. */
[data-theme="dark"] .site-logo {
    filter: invert(1) hue-rotate(180deg);
}

/* .btn-outline uses --color-secondary (deep blue) for text + border; on the
   dark header that's a low-contrast read. Give it a solid light surface so
   the blue ink pops. */
[data-theme="dark"] .btn-outline {
    background-color: #ffffff;
    color: var(--color-secondary);
    border-color: var(--color-secondary);
}
[data-theme="dark"] .btn-outline:hover {
    background-color: var(--color-secondary);
    color: #ffffff;
}

/* Hero overlay reads better when the dark half of the gradient sits on the
   right, blending into the dark page background instead of sitting over the
   headline. */
[data-theme="dark"] .hero-image::after {
    background: linear-gradient(
        270deg,
        rgba(0, 0, 0, 0.7) 0%,
        rgba(0, 0, 0, 0.55) 40%,
        rgba(0, 0, 0, 0.15) 100%
    );
}

@media (prefers-color-scheme: dark) {
    :root:not([data-theme="light"]) .site-logo {
        filter: invert(1) hue-rotate(180deg);
    }
    :root:not([data-theme="light"]) .btn-outline {
        background-color: #ffffff;
        color: var(--color-secondary);
        border-color: var(--color-secondary);
    }
    :root:not([data-theme="light"]) .btn-outline:hover {
        background-color: var(--color-secondary);
        color: #ffffff;
    }
    :root:not([data-theme="light"]) .hero-image::after {
        background: linear-gradient(
            270deg,
            rgba(0, 0, 0, 0.7) 0%,
            rgba(0, 0, 0, 0.55) 40%,
            rgba(0, 0, 0, 0.15) 100%
        );
    }
}




        /* Role accent overrides &mdash; Volunteer (#A3C2FF). Same role-theming
           pattern used in figma/partner-dashboard-volunteer.html and the requestor draft. */
        :root { --role-volunteer-deep: #4F7CC4; }
        .portal-nav-link.active { border-left-color: var(--role-volunteer-deep); color: var(--role-volunteer-deep); background: rgba(163,194,255,0.18); }
        .portal-nav-link.active i,
        .portal-nav-link:hover i { color: var(--role-volunteer-deep); }
        .dash-section-title i { color: var(--role-volunteer-deep); }
        .role-badge {
            background: var(--role-volunteer); color: #1d2c4b;
            padding: 6px 14px; border-radius: var(--radius-pill);
            font-weight: 700; font-size: var(--fs-xs);
            display: inline-flex; align-items: center; gap: 6px;
            border: 1px solid #c7d8f1;
        }
        .portal-avatar { background: var(--role-volunteer-deep); color: #fff; border-color: var(--role-volunteer); }
        .pill.pill-volunteer { background: #e9f0fb; color: var(--role-volunteer-deep); border-color: #c7d8f1; }

        /* Panels + two-column primitives (mirrors requestor draft). */
        .dash-two-col { display: grid; grid-template-columns: 2fr 1fr; gap: var(--space-5); }
        @media (max-width: 900px) { .dash-two-col { grid-template-columns: 1fr; } }
        .panel { background: var(--bg-surface); border: 1px solid var(--color-border); border-radius: var(--border-radius); padding: var(--space-5); box-shadow: var(--shadow-sm); }
        .panel-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: var(--space-4); gap: var(--space-3); }
        .panel-header h3 { font-family: var(--font-display); font-size: var(--fs-lg); color: var(--color-text); display: flex; align-items: center; gap: var(--space-2); margin: 0; }
        .panel-header h3 i { color: var(--role-volunteer-deep); }
        .panel-header a { font-size: var(--fs-sm); color: var(--role-volunteer-deep); text-decoration: none; font-weight: 600; }

        /* Shifts list (with date chip). */
        .shift-list { list-style: none; padding: 0; margin: 0; display: grid; gap: var(--space-3); }
        .shift-item { display: grid; grid-template-columns: 64px 1fr auto; gap: var(--space-4); align-items: center; padding: var(--space-3) var(--space-4); background: var(--bg-surface-alt); border: 1px solid var(--color-border); border-radius: var(--radius-md); border-left: 4px solid var(--role-volunteer-deep); }
        .date-chip { background: var(--bg-surface); border: 1px solid var(--color-border); border-radius: var(--radius-sm); padding: 6px 4px; text-align: center; font-family: var(--font-display); }
        .date-chip .day { display: block; font-size: 1.4rem; font-weight: 700; color: var(--role-volunteer-deep); line-height: 1; }
        .date-chip .month { display: block; font-size: 0.7rem; text-transform: uppercase; letter-spacing: 0.08em; color: var(--color-text-muted); font-weight: 600; margin-top: 2px; }
        .shift-body strong { display: block; color: var(--color-text); font-family: var(--font-display); font-size: 1.05rem; }
        .shift-body small { display: block; color: var(--color-text-muted); font-size: var(--fs-sm); margin-top: 2px; }
        .shift-body .meta-row { display: flex; flex-wrap: wrap; gap: var(--space-2); margin-top: 6px; }

        /* Orientation list. */
        .orientation-list { list-style: none; padding: 0; margin: 0; display: grid; gap: var(--space-3); }
        .orientation-item { padding: var(--space-3) var(--space-4); background: var(--bg-surface-alt); border: 1px solid var(--color-border); border-radius: var(--radius-md); display: flex; flex-direction: column; gap: 4px; }
        .orientation-item strong { font-family: var(--font-display); color: var(--color-text); }
        .orientation-item small { color: var(--color-text-muted); font-size: var(--fs-xs); }
        .orientation-item .meta-row { display: flex; flex-wrap: wrap; gap: var(--space-2); margin-top: 6px; }

        /* Hours block. */
        .hours-block { display: grid; grid-template-columns: 1fr 1fr; gap: var(--space-4); padding: var(--space-4); background: var(--bg-surface-alt); border-radius: var(--radius-md); border: 1px solid var(--color-border); margin-top: var(--space-5); }
        .hours-stat { display: flex; flex-direction: column; gap: 2px; }
        .hours-stat .num { font-family: var(--font-display); font-size: 1.8rem; font-weight: 700; color: var(--role-volunteer-deep); line-height: 1; }
        .hours-stat .lbl { font-size: 0.78rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--color-text-muted); font-weight: 600; }

        /* XP / level progress bar &mdash; quest system flavour from the volunteer SOP. */
        .xp-bar { background: var(--bg-surface-alt); border: 1px solid var(--color-border); border-radius: var(--radius-md); padding: var(--space-4); }
        .xp-bar header { display: flex; justify-content: space-between; align-items: baseline; margin-bottom: var(--space-2); }
        .xp-bar header strong { font-family: var(--font-display); color: var(--color-text); }
        .xp-bar header small { color: var(--color-text-muted); font-size: var(--fs-xs); }
        .xp-track { height: 10px; background: var(--bg-surface); border-radius: var(--radius-pill); overflow: hidden; border: 1px solid var(--color-border); }
        .xp-fill { height: 100%; background: linear-gradient(90deg, var(--role-volunteer), var(--role-volunteer-deep)); border-radius: var(--radius-pill); }

        /* Opportunities (quests). */
        .opp-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: var(--space-4); }
        .opp-card { background: var(--bg-surface); border: 1px solid var(--color-border); border-top: 4px solid var(--role-volunteer-deep); border-radius: var(--border-radius); padding: var(--space-5); display: flex; flex-direction: column; gap: var(--space-3); box-shadow: var(--shadow-sm); }
        .opp-card h4 { font-family: var(--font-display); font-size: 1.1rem; color: var(--color-text); }
        .opp-card p { font-size: var(--fs-sm); color: var(--color-text-muted); flex: 1; }
        .opp-card .meta-row { display: flex; flex-wrap: wrap; gap: var(--space-2); }
        .opp-card .opp-foot { display: flex; justify-content: space-between; align-items: center; padding-top: var(--space-3); border-top: 1px solid var(--color-border); font-size: var(--fs-sm); color: var(--color-text-muted); }

        /* Role notice. */
        .role-notice { background: #fdf3df; border: 1px solid #f4dfa9; color: #8a5a0e; padding: 12px 18px; border-radius: var(--border-radius); margin-top: var(--space-5); font-size: var(--fs-sm); display: flex; align-items: flex-start; gap: 10px; }
        .role-notice i { color: #8a5a0e; margin-top: 3px; }
    </style>
</head>
<body class="has-portal">
    <div class="portal-app">
        <aside class="portal-sidebar" id="portalSidebar" aria-label="Portal navigation">
            <div class="portal-sidebar-header">
                <a href="../../index.html" class="portal-brand">
                    <img src="../../archr-logo.svg" alt="ARCHR" class="portal-brand-mark">
                    <span class="portal-brand-text">ARCHR Portal</span>
                </a>
                <button type="button" class="portal-icon-btn portal-sidebar-close" id="portalSidebarClose" aria-label="Close menu">
                    <i class="fas fa-xmark" aria-hidden="true"></i>
                </button>
            </div>

            <nav class="portal-nav">
                <ul>
                    <li><a href="#dashboard" class="portal-nav-link active"><i class="fas fa-gauge-high"></i><span>My Dashboard</span></a></li>
                    <li><a href="#shifts" class="portal-nav-link"><i class="fas fa-calendar-day"></i><span>My Shifts</span></a></li>
                    <li><a href="#quests" class="portal-nav-link"><i class="fas fa-hand-holding-heart"></i><span>Find Opportunities</span></a></li>
                    <li><a href="#orientations" class="portal-nav-link"><i class="fas fa-graduation-cap"></i><span>Orientations</span></a></li>
                    <li><a href="../../documentation/task-engine/tle-poc.html" class="portal-nav-link"><i class="fas fa-list-check"></i><span>Tasks, Logs &amp; Events</span></a></li>
                    <li><a href="#hours" class="portal-nav-link"><i class="fas fa-clock"></i><span>Hours Log</span></a></li>
                    <li><a href="#profile" class="portal-nav-link"><i class="fas fa-user"></i><span>My Profile</span></a></li>
                    <li><a href="#help" class="portal-nav-link"><i class="fas fa-circle-question"></i><span>Help</span></a></li>
                </ul>
            </nav>

            <div class="portal-sidebar-footer">
                <a href="../../index.html" class="portal-nav-link"><i class="fas fa-arrow-left"></i><span>Back to public site</span></a>
            </div>
        </aside>

        <div class="portal-main">
            <header class="portal-topbar">
                <div class="portal-topbar-left">
                    <button type="button" class="portal-icon-btn portal-mobile-toggle" id="portalMobileToggle" aria-label="Open menu" aria-controls="portalSidebar" aria-expanded="false">
                        <i class="fas fa-bars" aria-hidden="true"></i>
                    </button>
                    <h1 class="portal-page-title">My Dashboard</h1>
                </div>
                <div class="portal-topbar-right">
                    <span class="role-badge"><i class="fas fa-hand-holding-heart"></i> Volunteer</span>
                    <button type="button" class="theme-toggle" aria-label="Toggle dark mode" aria-pressed="false">
                        <i class="fas fa-moon icon-moon" aria-hidden="true"></i>
                        <i class="fas fa-sun icon-sun" aria-hidden="true"></i>
                    </button>
                    <span class="portal-avatar" aria-label="Riley Park">RP</span>
                </div>
            </header>


            <div class="portal-content">
                <section class="portal-page active" data-page-title="My Dashboard">
                    <p class="login-banner" role="status">
                        <i class="fas fa-shield-halved"></i>
                        <span>Volunteer view &mdash; you only see your own shifts, hours, and orientations. Applicant case details and financials are not visible to your role.</span>
                    </p>

                    <section class="dash-hero" aria-labelledby="vol-welcome">
                        <div>
                            <h2 id="vol-welcome">Welcome back, Riley</h2>
                            <p>Thanks for showing up for your neighbors. You have <strong>2 upcoming shifts</strong> this week and one orientation to complete before joining demo crews.</p>
                            <p class="updated"><i class="far fa-clock"></i> Last updated: today, 9:14 AM</p>
                        </div>
                        <div class="dash-hero-meta">
                            <span class="org-badge"><i class="fas fa-building"></i> Asheville Habitat for Humanity</span>
                            <a href="#quests" class="btn btn-secondary"><i class="fas fa-hand-holding-heart"></i> Find Opportunities</a>
                        </div>
                    </section>

                    <section class="dash-section active" aria-label="At-a-glance volunteer stats">
                        <h3 class="dash-section-title"><i class="fas fa-gauge-high"></i> At a Glance</h3>
                        <div class="kpi-grid">
                            <div class="kpi"><span class="kpi-label">Upcoming Shifts</span><span class="kpi-value">2</span><span class="kpi-sub">Next: Saturday 8:00 AM</span></div>
                            <div class="kpi kpi-green"><span class="kpi-label">Hours This Year</span><span class="kpi-value">47.5</span><span class="kpi-sub">Goal: 60 hours</span></div>
                            <div class="kpi kpi-amber"><span class="kpi-label">Orientations</span><span class="kpi-value">1</span><span class="kpi-sub"><span class="pill pill-amber">Action needed</span></span></div>
                            <div class="kpi kpi-blue"><span class="kpi-label">Lifetime Total</span><span class="kpi-value">312</span><span class="kpi-sub">Hours across 3 years</span></div>
                        </div>
                    </section>

                    <section class="dash-section active">
                        <div class="dash-two-col">

                            <article class="panel" aria-labelledby="shifts-h">
                                <div class="panel-header">
                                    <h3 id="shifts-h"><i class="fas fa-calendar-day"></i> My Upcoming Shifts</h3>
                                    <a href="#shifts">View all</a>
                                </div>
                                <ul class="shift-list">
                                    <li class="shift-item">
                                        <div class="date-chip"><span class="day">14</span><span class="month">Jun</span></div>
                                        <div class="shift-body">
                                            <strong>Roof tarp removal &amp; cleanup</strong>
                                            <small>Saturday &middot; 8:00 AM &ndash; 1:00 PM &middot; Buncombe County build site</small>
                                            <div class="meta-row">
                                                <span class="pill pill-volunteer"><i class="fas fa-users"></i> Crew of 6</span>
                                                <span class="pill"><i class="fas fa-user-tie"></i> Lead: Sam Chen</span>
                                            </div>
                                        </div>
                                        <a href="#shifts" class="btn btn-secondary btn-sm">Details</a>
                                    </li>
                                    <li class="shift-item">
                                        <div class="date-chip"><span class="day">21</span><span class="month">Jun</span></div>
                                        <div class="shift-body">
                                            <strong>Interior demo &amp; haul-out</strong>
                                            <small>Saturday &middot; 9:00 AM &ndash; 2:00 PM &middot; Henderson County build site</small>
                                            <div class="meta-row">
                                                <span class="pill pill-volunteer"><i class="fas fa-users"></i> Crew of 8</span>
                                                <span class="pill"><i class="fas fa-user-tie"></i> Lead: Tyrell Banks</span>
                                            </div>
                                        </div>
                                        <a href="#shifts" class="btn btn-secondary btn-sm">Details</a>
                                    </li>
                                    <li class="shift-item">
                                        <div class="date-chip"><span class="day">05</span><span class="month">Jul</span></div>
                                        <div class="shift-body">
                                            <strong>Volunteer appreciation cookout</strong>
                                            <small>Friday &middot; 6:00 PM &ndash; 8:30 PM &middot; AHFH office, Asheville</small>
                                            <div class="meta-row">
                                                <span class="pill pill-green"><i class="fas fa-circle-check"></i> RSVP confirmed</span>
                                            </div>
                                        </div>
                                        <a href="#shifts" class="btn btn-secondary btn-sm">Details</a>
                                    </li>
                                </ul>
                            </article>

                            <article class="panel" aria-labelledby="orientations-h">
                                <div class="panel-header">
                                    <h3 id="orientations-h"><i class="fas fa-graduation-cap"></i> Upcoming Orientations</h3>
                                    <a href="#orientations">All trainings</a>
                                </div>
                                <ul class="orientation-list">
                                    <li class="orientation-item">
                                        <strong>Power tool safety</strong>
                                        <small>Required before joining demo crews</small>
                                        <div class="meta-row">
                                            <span class="pill pill-amber"><i class="fas fa-circle-exclamation"></i> Required</span>
                                            <span class="pill">Jun 12, 6 PM</span>
                                        </div>
                                    </li>
                                    <li class="orientation-item">
                                        <strong>Site etiquette &amp; resident privacy</strong>
                                        <small>Annual refresher &mdash; completed Nov 2025</small>
                                        <div class="meta-row">
                                            <span class="pill pill-green"><i class="fas fa-circle-check"></i> Current</span>
                                            <span class="pill">Renews Nov 2026</span>
                                        </div>
                                    </li>
                                    <li class="orientation-item">
                                        <strong>Crew leader pathway</strong>
                                        <small>For volunteers with 100+ hours</small>
                                        <div class="meta-row">
                                            <span class="pill pill-blue">Optional</span>
                                            <span class="pill">Jul 10, 6 PM</span>
                                        </div>
                                    </li>
                                </ul>

                                <div class="hours-block">
                                    <div class="hours-stat"><span class="num">47.5</span><span class="lbl">Hours YTD</span></div>
                                    <div class="hours-stat"><span class="num">12.5</span><span class="lbl">To reach goal</span></div>
                                </div>
                            </article>

                        </div>
                    </section>

                    <section class="dash-section active" aria-labelledby="progression-h">
                        <h3 class="dash-section-title" id="progression-h"><i class="fas fa-trophy"></i> Progression</h3>
                        <article class="panel">
                            <div class="xp-bar">
                                <header>
                                    <strong>Level 4 &middot; Field Volunteer</strong>
                                    <small>820 / 1,000 XP to Level 5 (Crew Member)</small>
                                </header>
                                <div class="xp-track" role="progressbar" aria-valuemin="0" aria-valuemax="1000" aria-valuenow="820">
                                    <div class="xp-fill" style="width: 82%;"></div>
                                </div>
                                <p style="margin-top: var(--space-3); font-size: var(--fs-sm); color: var(--color-text-muted);">
                                    Reputation <strong style="color: var(--color-text);">684</strong> / 1,000 &middot;
                                    Badges earned: <span class="pill pill-volunteer">First Steps</span>
                                    <span class="pill pill-volunteer">10 Shifts</span>
                                    <span class="pill pill-volunteer">Storyteller</span>
                                </p>
                            </div>
                        </article>
                    </section>


                    <section class="dash-section active" aria-labelledby="opps-h">
                        <h3 class="dash-section-title" id="opps-h"><i class="fas fa-hand-holding-heart"></i> Find Opportunities</h3>
                        <div class="opp-grid">
                            <article class="opp-card">
                                <h4>Drywall hang &amp; mud day</h4>
                                <p>Looking for 4&ndash;6 volunteers comfortable with cordless drills. Light lifting required.</p>
                                <div class="meta-row">
                                    <span class="pill pill-volunteer">AHFH</span>
                                    <span class="pill"><i class="fas fa-location-dot"></i> Buncombe</span>
                                    <span class="pill"><i class="far fa-calendar"></i> Jun 28</span>
                                    <span class="pill pill-blue">+50 XP</span>
                                </div>
                                <div class="opp-foot">
                                    <span>2 of 6 spots filled</span>
                                    <a href="#quests" class="btn btn-primary btn-sm">Sign up</a>
                                </div>
                            </article>

                            <article class="opp-card">
                                <h4>Yard cleanup &amp; debris hauling</h4>
                                <p>Helene-affected property. Heavy outdoor work, all skill levels welcome. Tools provided.</p>
                                <div class="meta-row">
                                    <span class="pill pill-volunteer">MHO</span>
                                    <span class="pill"><i class="fas fa-location-dot"></i> Madison</span>
                                    <span class="pill"><i class="far fa-calendar"></i> Jul 06</span>
                                    <span class="pill pill-blue">+35 XP</span>
                                </div>
                                <div class="opp-foot">
                                    <span>5 of 12 spots filled</span>
                                    <a href="#quests" class="btn btn-primary btn-sm">Sign up</a>
                                </div>
                            </article>

                            <article class="opp-card">
                                <h4>Phone bank: scheduling outreach</h4>
                                <p>Remote opportunity. Help confirm upcoming inspection appointments with applicants.</p>
                                <div class="meta-row">
                                    <span class="pill pill-volunteer">ARCHR</span>
                                    <span class="pill"><i class="fas fa-globe"></i> Remote</span>
                                    <span class="pill"><i class="far fa-calendar"></i> Ongoing</span>
                                    <span class="pill pill-blue">+20 XP</span>
                                </div>
                                <div class="opp-foot">
                                    <span>Flexible hours</span>
                                    <a href="#quests" class="btn btn-primary btn-sm">Sign up</a>
                                </div>
                            </article>
                        </div>

                        <p class="role-notice">
                            <i class="fas fa-shield-halved"></i>
                            <span><strong>Role-based access:</strong> as a Volunteer, you see shifts you've signed up for and opportunities open to your role. Case files, applicant names, financial details, and other partner organizations' private data are not shown. To take on more responsibilities (crew lead, assessor), complete the Crew Leader Pathway orientation.</span>
                        </p>
                    </section>
                </section>
            </div>
        </div>
    </div>

    <script src="../../js/script.js"></script>
</body>
</html>
