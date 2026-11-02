/**
 * PSEUDOCODE: Nuxt server middleware.
 *
 * - Read the authenticated session or service token.
 * - Resolve the acting person and organization.
 * - Load roles and permissions into event.context.auth.
 * - Create a request/correlation ID when one was not supplied.
 * - Do not make domain decisions here.
 * - Do not return a response from middleware.
 */
export default defineEventHandler(async (event) => {
  // Resolve authentication and attach a typed request context.
});

