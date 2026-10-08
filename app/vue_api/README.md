# Vue API — Auth Bridge & Token Middleware

## Endpoints

### `POST /app/vue_api/auth.php`

Authentication endpoint — login and token verification.

#### Actions: `login`, `verify`

(See original README content for full login/verify docs)

### `POST /app/vue_api/cases.php`

Cases listing endpoint (requires auth token).

**Request:**
```json
{ "action": "list" }
```

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Response:**
```json
{
  "success": true,
  "user": { "id": 151, "role": "super_admin", "level": 15 },
  "cases": [...]
}
```

## Token Middleware

### `require_once __DIR__ . '/vue_api/token-middleware.php';`

Reusable token verification for any PHP endpoint.

```php
require_once __DIR__ . '/vue_api/token-middleware.php';
$user = vue_require_auth_token();
// $user['user_id'], $user['role'], $user['role_level'], etc.
```

**Token sources checked (in order):**
1. `Authorization: Bearer <token>` HTTP header
2. POST body field `token`

**On failure:** Exits with 401 JSON error.

**On success:** Returns decoded user payload array.

### Available functions

| Function | Description |
|---|---|
| `vue_require_auth_token()` | Require valid token, exit with 401 on failure |
| `vue_verify_token(string $token)` | Verify token, return payload or null |
| `vue_get_bearer_token()` | Extract Bearer token from headers |
| `vue_get_auth_secret()` | Load AUTH_SECRET_KEY from env/.env |

## Token Format

Tokens use a JWT-like structure (HMAC-SHA256 signed, no external library):

```
base64url(header).base64url(payload).base64url(signature)
```

- **Expiration:** 24 hours by default, 30 days with `remember_me: true`
- **Signature:** HMAC-SHA256 using `AUTH_SECRET_KEY` from environment
- **Payload contains:** `user_id`, `email`, `full_name`, `role`, `role_display`, `role_level`, `exp`, `iat`

## Security Notes

- **No rate limiting** — add this before exposing to the public internet
- **CSRF:** Tokens are bearer tokens sent in request body (not cookies)
- **AUTH_SECRET_KEY** must be set in production — the file falls back to `.env` in development
- Legacy accounts without `password_hash` accept `12345` (logged as a warning)
- Passwords hashed with `password_hash()` (bcrypt)

## CORS

CORS headers are set to allow any origin in development. In production, restrict `Access-Control-Allow-Origin` to your Vue app's domain.
