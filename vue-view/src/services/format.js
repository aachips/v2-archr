// ---------------------------------------------------------------------------
// Shared display formatters. These used to be duplicated as methods inside
// CaseReview.vue / QuickTasks.vue; new components import them from here.
// ---------------------------------------------------------------------------

export function formatDate(value) {
  if (!value) return "—";
  const date = new Date(value);
  return isNaN(date) ? String(value) : date.toLocaleDateString();
}

export function formatDateTime(value) {
  if (!value) return "—";
  const date = new Date(value);
  return isNaN(date) ? String(value) : date.toLocaleString();
}

export function formatMoney(value) {
  if (value === null || value === undefined || value === "") return "—";
  const num = Number(value);
  return isNaN(num) ? String(value) : "$" + num.toLocaleString();
}