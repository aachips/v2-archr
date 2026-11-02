/**
 * Event Resolver service — communicates with the PHP resolver endpoint.
 */

import { getAuthHeaders } from './authService';

const RESOLVER_URL = '/app/vue_api/event-resolver.php';

/**
 * Resolve the current state of a case.
 * @param {number} caseId
 * Returns { phase, phase_name, milestones[], next_actions[], blocked, ... }
 */
export async function resolveCase(caseId) {
  const url = `${RESOLVER_URL}?action=resolve&case_id=${caseId}`;
  const res = await fetch(url, {
    method: 'GET',
    headers: getAuthHeaders(),
  });

  const data = await res.json();
  if (!res.ok || !data.success) {
    throw new Error(data.error || 'Failed to resolve case');
  }
  return data;
}
