/* ARCHR – global site script
 * Currently handles: light/dark theme toggle with localStorage persistence
 * and OS-preference fallback. Safe to load on every page.
 */
(function () {
    'use strict';

    var STORAGE_KEY = 'archr-theme';
    var root = document.documentElement;

    function readStored() {
        try { return localStorage.getItem(STORAGE_KEY); } catch (e) { return null; }
    }

    function writeStored(value) {
        try { localStorage.setItem(STORAGE_KEY, value); } catch (e) { /* no-op */ }
    }

    function prefersDark() {
        return window.matchMedia
            && window.matchMedia('(prefers-color-scheme: dark)').matches;
    }

    function resolveInitial() {
        var stored = readStored();
        if (stored === 'light' || stored === 'dark') return stored;
        return prefersDark() ? 'dark' : 'light';
    }

    function applyTheme(theme) {
        root.setAttribute('data-theme', theme);
        var buttons = document.querySelectorAll('.theme-toggle');
        for (var i = 0; i < buttons.length; i++) {
            buttons[i].setAttribute('aria-pressed', theme === 'dark' ? 'true' : 'false');
        }
    }

    // Apply ASAP in case the inline pre-paint script in <head> didn't run.
    if (!root.hasAttribute('data-theme')) {
        applyTheme(resolveInitial());
    }

    document.addEventListener('DOMContentLoaded', function () {
        var current = root.getAttribute('data-theme') || resolveInitial();
        var buttons = document.querySelectorAll('.theme-toggle');

        for (var i = 0; i < buttons.length; i++) {
            buttons[i].setAttribute('aria-pressed', current === 'dark' ? 'true' : 'false');
            buttons[i].addEventListener('click', function () {
                var next = root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
                applyTheme(next);
                writeStored(next);
            });
        }
    });

    // Follow OS changes only when the user hasn't made an explicit choice.
    if (window.matchMedia) {
        var mql = window.matchMedia('(prefers-color-scheme: dark)');
        var listener = function (e) {
            if (readStored()) return;
            applyTheme(e.matches ? 'dark' : 'light');
        };
        if (mql.addEventListener) mql.addEventListener('change', listener);
        else if (mql.addListener) mql.addListener(listener);
    }

    /* ---------------------------------------------------------------------
     * Tab routing for index.html's hidden-display content sections.
     * Reads the URL hash on load so cross-page links like
     * "index.html#qualifications" land on the right tab. Updates the hash
     * on click for shareable URLs. No-ops on pages without .content-tab.
     * ------------------------------------------------------------------ */
    function hashTabName() {
        var h = (window.location.hash || '').replace('#', '');
        return h ? h.replace(/-tab$/, '') : null;
    }

    function activateTab(name) {
        var sections = document.querySelectorAll('.content-tab');
        if (!sections.length) return false;
        var matched = false;
        for (var i = 0; i < sections.length; i++) {
            var sec = sections[i];
            var hit = sec.id === name + '-tab';
            sec.classList.toggle('active-tab', hit);
            sec.style.display = hit ? 'block' : 'none';
            if (hit) matched = true;
        }
        if (!matched) return false;
        var links = document.querySelectorAll('.nav-link[data-tab]');
        for (var j = 0; j < links.length; j++) {
            links[j].classList.toggle('active', links[j].getAttribute('data-tab') === name);
        }
        return true;
    }

    function initTabs() {
        var tabs = document.querySelectorAll('[data-tab]');
        if (!tabs.length || !document.querySelector('.content-tab')) return;

        var initial = hashTabName();
        if (!initial || !activateTab(initial)) {
            var active = document.querySelector('.content-tab.active-tab');
            initial = active ? active.id.replace(/-tab$/, '') : 'home';
            activateTab(initial);
        }

        for (var i = 0; i < tabs.length; i++) {
            tabs[i].addEventListener('click', function (e) {
                var name = this.getAttribute('data-tab');
                if (!document.getElementById(name + '-tab')) return; // cross-page link
                e.preventDefault();
                activateTab(name);
                if (history.pushState) {
                    history.pushState(null, '', '#' + name);
                } else {
                    window.location.hash = name;
                }
                window.scrollTo({ top: 0, behavior: 'smooth' });
            });
        }

        window.addEventListener('hashchange', function () {
            var name = hashTabName();
            if (name) activateTab(name);
        });
    }

    document.addEventListener('DOMContentLoaded', initTabs);
})();
