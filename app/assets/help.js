/* ARCHR Help Center — collapsible categories + client-side search over the role-filtered search index. */
(function () {
    'use strict';

    // ---------- Collapsible categories ----------
    var nav = document.querySelector('.help-nav');
    if (nav) {
        nav.addEventListener('click', function (e) {
            var header = e.target.closest('.help-nav-category');
            if (!header) return;
            var cat = header.dataset.category;
            var section = nav.querySelector('.help-nav-section[data-category="' + cat + '"]');
            if (!section) return;

            var isCollapsed = header.classList.contains('collapsed');
            if (isCollapsed) {
                header.classList.remove('collapsed');
                section.classList.remove('collapsed');
            } else {
                header.classList.add('collapsed');
                section.classList.add('collapsed');
            }
        });
    }

    // ---------- Search ----------
    var input = document.getElementById('help-search-input');
    var results = document.getElementById('help-search-results');
    if (!input || !results) {
        return;
    }

    var index = null;
    var loading = false;
    var debounceTimer = null;

    function loadIndex() {
        if (index !== null || loading) {
            return;
        }
        loading = true;
        fetch('help.php?action=search-index', { credentials: 'same-origin' })
            .then(function (res) { return res.ok ? res.json() : []; })
            .then(function (data) { index = Array.isArray(data) ? data : []; })
            .catch(function () { index = []; });
    }

    function score(entry, terms) {
        var title = entry.title.toLowerCase();
        var tags = (entry.tags || []).join(' ').toLowerCase();
        var text = entry.text.toLowerCase();
        var total = 0;
        for (var i = 0; i < terms.length; i++) {
            var term = terms[i];
            var termScore = 0;
            if (title.indexOf(term) !== -1) { termScore += 100; }
            if (tags.indexOf(term) !== -1) { termScore += 40; }
            if (entry.category.toLowerCase().indexOf(term) !== -1) { termScore += 20; }
            if (text.indexOf(term) !== -1) { termScore += 10; }
            if (termScore === 0) {
                return 0; // every term must match somewhere
            }
            total += termScore;
        }
        return total;
    }

    function render(matches) {
        results.innerHTML = '';
        if (matches.length === 0) {
            var none = document.createElement('li');
            none.className = 'hsr-none';
            none.textContent = 'No matching documents';
            results.appendChild(none);
        } else {
            matches.slice(0, 8).forEach(function (entry) {
                var li = document.createElement('li');
                var a = document.createElement('a');
                a.href = 'help.php?doc=' + encodeURIComponent(entry.slug);

                var cat = document.createElement('span');
                cat.className = 'hsr-category';
                cat.textContent = entry.category;

                var title = document.createElement('span');
                title.textContent = entry.title;

                var excerpt = document.createElement('span');
                excerpt.className = 'hsr-excerpt';
                excerpt.textContent = entry.excerpt;

                a.appendChild(cat);
                a.appendChild(title);
                a.appendChild(excerpt);
                li.appendChild(a);
                results.appendChild(li);
            });
        }
        results.hidden = false;
    }

    function search() {
        var query = input.value.trim().toLowerCase();
        if (query.length < 2 || index === null) {
            results.hidden = true;
            results.innerHTML = '';
            return;
        }
        var terms = query.split(/\s+/);
        var matches = [];
        index.forEach(function (entry) {
            var s = score(entry, terms);
            if (s > 0) {
                matches.push({ entry: entry, score: s });
            }
        });
        matches.sort(function (a, b) { return b.score - a.score; });
        render(matches.map(function (m) { return m.entry; }));
    }

    input.addEventListener('focus', loadIndex);
    input.addEventListener('input', function () {
        clearTimeout(debounceTimer);
        debounceTimer = setTimeout(search, 150);
    });
    input.addEventListener('keydown', function (event) {
        if (event.key === 'Escape') {
            input.value = '';
            results.hidden = true;
        } else if (event.key === 'Enter') {
            var first = results.querySelector('a');
            if (!results.hidden && first) {
                event.preventDefault();
                window.location.href = first.href;
            }
        }
    });
    document.addEventListener('click', function (event) {
        if (!results.contains(event.target) && event.target !== input) {
            results.hidden = true;
        }
    });
})();
