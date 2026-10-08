/* ARCHR role-portal shared behavior.
   - Mobile sidebar open/close
   - Dark/light theme toggle (persisted to localStorage)
   - Topbar dropdown menus (role switcher, language switcher, user avatar)
   - .portal-nav-link active-state on click
   - Stub handler for in-page anchor actions used by the draft mockups
*/
(function () {
    'use strict';

    const sidebar = document.getElementById('portalSidebar');
    const sidebarToggle = document.getElementById('portalMobileToggle');
    const sidebarClose = document.getElementById('portalSidebarClose');
    if (sidebar && sidebarToggle) {
        sidebarToggle.addEventListener('click', () => {
            const open = sidebar.classList.toggle('is-open');
            sidebarToggle.setAttribute('aria-expanded', open ? 'true' : 'false');
        });
    }
    if (sidebar && sidebarClose) {
        sidebarClose.addEventListener('click', () => sidebar.classList.remove('is-open'));
    }

    const themeBtn = document.getElementById('themeToggle');
    if (themeBtn) {
        themeBtn.addEventListener('click', () => {
            const html = document.documentElement;
            const next = html.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
            html.setAttribute('data-theme', next);
            try { localStorage.setItem('archr-theme', next); } catch (e) { /* private mode */ }
        });
    }

    document.querySelectorAll('.portal-nav-link').forEach((link) => {
        link.addEventListener('click', (e) => {
            // Only treat as in-page nav if href starts with '#'
            const href = link.getAttribute('href') || '';
            if (!href.startsWith('#')) return;
            document.querySelectorAll('.portal-nav-link.active')
                .forEach((l) => l.classList.remove('active'));
            link.classList.add('active');
        });
    });

    /* Stub action handler — prevents the in-page anchor links in the
       draft mockups (e.g. #assessmentBuilder) from triggering a jump.
       Real handlers will replace this as features come online. */
    const stubSelectors = [
        '.assessor-action-btn',
        '.la-actions a',
        '.ai-actions a',
        '.msg-item a',
        '.task-action-list a',
        '.see-all-link'
    ];
    document.querySelectorAll(stubSelectors.join(', ')).forEach((el) => {
        el.addEventListener('click', (e) => {
            const href = el.getAttribute('href') || '';
            if (href.startsWith('#') && href.length > 1) {
                e.preventDefault();
                if (window.console) console.log('[archr-portal] stub navigate:', href);
            }
        });
    });

    /* Topbar dropdown menus — the role switcher, language switcher, and
       user avatar menu all share the same markup pattern: a container
       holding a <button aria-expanded> and a [role="menu"] list that
       starts with the `hidden` attribute. One helper wires them all:
       click toggles, outside click and Escape close. The language menu
       needs no extra JS — its items are plain ?lang= links. */
    function wireDropdown(containerId) {
        const container = document.getElementById(containerId);
        if (!container) return;
        const toggle = container.querySelector('button[aria-expanded]');
        const menu = container.querySelector('[role="menu"]');
        if (!toggle || !menu) return;
        const chevron = container.querySelector('.fa-chevron-down');

        function setOpen(open) {
            menu.hidden = !open;
            toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
            if (chevron) chevron.style.transform = open ? 'rotate(180deg)' : 'rotate(0deg)';
        }

        toggle.addEventListener('click', (e) => {
            e.stopPropagation();
            setOpen(toggle.getAttribute('aria-expanded') !== 'true');
        });

        document.addEventListener('click', (e) => {
            if (!container.contains(e.target)) setOpen(false);
        });

        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') setOpen(false);
        });
    }

    wireDropdown('roleSwitcher');
    wireDropdown('langSwitcher');
    wireDropdown('avatarDropdown');

})();
