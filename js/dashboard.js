/* ARCHR dashboard – dummy data + Chart.js wiring
 * Drives both dashboard.html (public) and partner-portal.html (org).
 * Each chart only renders if its <canvas id="..."> exists on the page.
 */
(function () {
    "use strict";

    // ---------- Section tab switching ----------
    const tabs = document.querySelectorAll(".dash-tab");
    const sections = document.querySelectorAll(".dash-section");
    tabs.forEach((tab) => {
        tab.addEventListener("click", () => {
            const target = tab.dataset.section;
            tabs.forEach((t) => {
                const active = t === tab;
                t.classList.toggle("active", active);
                t.setAttribute("aria-selected", active ? "true" : "false");
            });
            sections.forEach((s) => s.classList.toggle("active", s.id === target));
        });
    });

    if (typeof Chart === "undefined") return;

    // ---------- Shared theme ----------
    Chart.defaults.font.family = "'Open Sans', sans-serif";
    Chart.defaults.color = "#444";

    const PALETTE = {
        primary: "#E04E39",
        secondary: "#2A5C82",
        green: "#2f9e69",
        amber: "#d99518",
        purple: "#7d5ba6",
        teal: "#3aa6a0",
        gray: "#9aa3ab"
    };
    const PIE_COLORS = [
        PALETTE.primary, PALETTE.secondary, PALETTE.green,
        PALETTE.amber, PALETTE.purple, PALETTE.teal, PALETTE.gray
    ];

    const pieOpts = {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { position: "bottom", labels: { boxWidth: 12, padding: 14 } } }
    };
    const barOpts = {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { display: false } },
        scales: {
            y: { beginAtZero: true, grid: { color: "#eef0f2" } },
            x: { grid: { display: false } }
        }
    };

    function make(id, type, data, options) {
        const el = document.getElementById(id);
        if (!el) return;
        new Chart(el, { type, data, options });
    }

    // ---------- Dummy data ----------
    const incomeLabels = ["0–30% AMI", "31–50% AMI", "51–80% AMI", ">80% AMI"];
    const countyLabels = ["Buncombe", "Henderson", "Madison", "Haywood", "Yancey", "Mitchell"];
    const issueLabels  = ["Roof", "Plumbing", "Electrical", "Accessibility", "HVAC", "Structural"];

    // ===== Public dashboard – Past Week =====
    make("weekIncomeChart", "doughnut", {
        labels: incomeLabels,
        datasets: [{ data: [18, 14, 8, 2], backgroundColor: PIE_COLORS, borderWidth: 2, borderColor: "#fff" }]
    }, pieOpts);

    make("weekCountyChart", "bar", {
        labels: countyLabels,
        datasets: [{ data: [16, 9, 6, 5, 4, 2], backgroundColor: PALETTE.secondary, borderRadius: 6 }]
    }, barOpts);

    make("weekIssueChart", "pie", {
        labels: issueLabels,
        datasets: [{ data: [12, 8, 6, 7, 5, 4], backgroundColor: PIE_COLORS, borderWidth: 2, borderColor: "#fff" }]
    }, pieOpts);

    // ===== Public dashboard – All Time =====
    make("allIncomeChart", "doughnut", {
        labels: incomeLabels,
        datasets: [{ data: [512, 438, 261, 73], backgroundColor: PIE_COLORS, borderWidth: 2, borderColor: "#fff" }]
    }, pieOpts);

    make("allCountyChart", "bar", {
        labels: countyLabels,
        datasets: [{ data: [486, 271, 178, 152, 121, 76], backgroundColor: PALETTE.primary, borderRadius: 6 }]
    }, barOpts);

    // ===== Partner / Org dashboard =====
    make("orgIncomeChart", "doughnut", {
        labels: incomeLabels,
        datasets: [{ data: [94, 78, 41, 11], backgroundColor: PIE_COLORS, borderWidth: 2, borderColor: "#fff" }]
    }, pieOpts);

    make("orgCountyChart", "bar", {
        labels: countyLabels,
        datasets: [{ data: [88, 51, 32, 28, 17, 8], backgroundColor: PALETTE.secondary, borderRadius: 6 }]
    }, barOpts);

    make("orgAssessmentsChart", "bar", {
        labels: ["Assigned", "Completed", "Pending"],
        datasets: [{
            data: [312, 247, 65],
            backgroundColor: [PALETTE.secondary, PALETTE.green, PALETTE.amber],
            borderRadius: 6
        }]
    }, barOpts);
})();
