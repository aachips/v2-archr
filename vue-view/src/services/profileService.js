/**
 * Profile service — communicates with the PHP profile endpoint.
 */

import { getAuthHeaders } from './authService';

const PROFILE_URL = '/app/vue_api/profile.php';

/**
 * Fetch the current user's profile data.
 * Returns { success, user }.
 */
export async function getProfile() {
  const res = await fetch(`${PROFILE_URL}?action=get`, {
    method: 'GET',
    headers: getAuthHeaders(),
  });

  const data = await res.json();
  if (!res.ok || !data.success) {
    throw new Error(data.error || 'Failed to load profile');
  }
  return data;
}

/**
 * Update the current user's profile.
 * @param {object} updates - { full_name, email, phone, session_indefinite }
 * Returns { success, user }.
 */
export async function updateProfile(updates) {
  const res = await fetch(PROFILE_URL, {
    method: 'POST',
    headers: getAuthHeaders(),
    body: JSON.stringify({ action: 'update', ...updates }),
  });

  const data = await res.json();
  if (!res.ok || !data.success) {
    throw new Error(data.error || 'Failed to update profile');
  }
  return data;
}
