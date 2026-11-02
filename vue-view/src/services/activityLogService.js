/**
 * Activity Log service — reads from the PostgreSQL activity_log table
 * via the PHP API endpoint at /app/api/activity-log.php.
 *
 * The Activity Log is an IMMUTABLE audit trail of all user changes to
 * records — accountability and rollback support. This is separate from
 * Progress Events (case workflow milestones in Airtable).
 *
 * In production, the endpoint requires auth. For now, it works through
 * the Vue dev server proxy with the auth token.
 */

import { getAuthHeaders } from './authService';

const API_URL = '/app/api/activity-log.php';

/**
 * Fetch activity log entries with optional filters.
 */
export async function fetchActivityLog(filters = {}) {
  const params = new URLSearchParams();

  if (filters.userId != null) params.set('user_id', filters.userId);
  if (filters.applicationId != null) params.set('application_id', filters.applicationId);
  if (filters.caseId != null) params.set('case_id', filters.caseId);
  if (filters.category) params.set('category', filters.category);
  if (filters.action) params.set('action', filters.action);
  if (filters.source) params.set('source', filters.source);
  if (filters.since) params.set('since', filters.since);
  if (filters.until) params.set('until', filters.until);
  if (filters.search) params.set('search', filters.search);
  if (filters.limit) params.set('limit', filters.limit);
  if (filters.offset != null) params.set('offset', filters.offset);

  const url = params.toString() ? `${API_URL}?${params.toString()}` : API_URL;

  const res = await fetch(url, {
    method: 'GET',
    headers: getAuthHeaders(),
  });

  const data = await res.json();
  if (!res.ok || !data.success) {
    throw new Error(data.error || data.message || 'Failed to load activity log');
  }

  return {
    entries: data.data || [],
    meta: data.meta || { categories: [], actions: [], sources: [], users: [], count: 0 },
  };
}

/**
 * Verify chain integrity of the activity_log hash chain.
 */
export async function verifyChain() {
  const res = await fetch(API_URL, {
    method: 'POST',
    headers: getAuthHeaders(),
  });

  const data = await res.json();
  if (!res.ok || !data.success) {
    return null;
  }

  const chain = data.chain;
  return {
    ok: chain.ok,
    checked: chain.checked || 0,
    first_bad_id: chain.first_bad_id,
    error: chain.error,
  };
}
