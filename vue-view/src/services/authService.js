/**
 * Auth service — communicates with the PHP auth bridge at /app/vue_api/auth.php.
 *
 * The Vue dev server proxies /app/* to the PHP backend (see vue.config.js),
 * so no CORS or full URLs are needed.
 */

const AUTH_URL = '/app/vue_api/auth.php';

/**
 * Attempt login with email/username and password.
 * Returns { success, token, user } on success.
 * Throws on failure.
 */
export async function login({ email, password, rememberMe = false }) {
  const res = await fetch(AUTH_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      action: 'login',
      email,
      password,
      remember_me: rememberMe
    }),
  });

  const data = await res.json();
  if (!res.ok || !data.success) {
    throw new Error(data.error || 'Login failed');
  }
  return data; // { success, token, user }
}

/**
 * Verify a stored token and refresh user info.
 * Returns { success, token, user } on success.
 * Throws on failure (expired/invalid token).
 */
export async function verifyToken(token) {
  const res = await fetch(AUTH_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ action: 'verify', token }),
  });

  const data = await res.json();
  if (!res.ok || !data.success) {
    throw new Error(data.error || 'Token verification failed');
  }
  return data;
}

/**
 * Log out — clears the stored token.
 * The backend is stateless (token-based), so client-side cleanup is sufficient.
 */
export function logout() {
  // No server call needed — tokens are stateless
}

/**
 * Get the stored token from localStorage.
 */
export function getToken() {
  return localStorage.getItem('archr_auth_token');
}

/**
 * Build fetch headers that include the auth token.
 * Use with any PHP endpoint that calls verify_auth_token().
 *
 * Example:
 *   fetch('/app/api/cases.php', {
 *     method: 'POST',
 *     headers: getAuthHeaders(),
 *     body: JSON.stringify({ action: 'list' }),
 *   })
 */
export function getAuthHeaders() {
  const token = getToken();
  const headers = { 'Content-Type': 'application/json' };
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }
  return headers;
}

/**
 * Log an entry to the PostgreSQL activity_log via the Vue auth bridge.
 * This ensures Vue-side edits appear in the Activity Log audit trail.
 *
 * @param {object} entry - { category, action, summary, application_id, case_id, organization_id, details, source }
 */
export async function logActivity(entry) {
  const res = await fetch('/app/vue_api/activity-log.php', {
    method: 'POST',
    headers: getAuthHeaders(),
    body: JSON.stringify({ action: 'log', entry }),
  });

  const data = await res.json();
  if (!res.ok || !data.success) {
    // Non-fatal — the primary edit succeeded even if the log append fails
    console.warn('[auth] Activity log append failed:', data.error);
    return null;
  }
  return data;
}
