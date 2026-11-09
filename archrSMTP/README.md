# Archr SMTP Relay Service

Local SMTP relay service built with Haraka.

This service accepts mail only from localhost and forwards outbound mail through a configurable upstream SMTP provider.

Current upstream provider:

```text
Resend
```

The service is intentionally designed so the auth application does not need to know or care which outbound email vendor is being used.

---

## Architecture

```text
Auth Service
127.0.0.1:8790
     |
     | SMTP
     v
Haraka
127.0.0.1:2525
     |
     | authenticated STARTTLS
     v
Resend
smtp.resend.com:587
     |
     v
Recipient MX
```

Haraka is not exposed as a public SMTP server.

---

# Service Location

```text
/Users/archrmac/archr/services/smtp
```

Current listener:

```text
127.0.0.1:2525
```

SMTP hostname:

```text
mail.archr.live
```

---

# Haraka Version

Current tested version:

```text
Haraka 3.4.0
```

Installed globally through Node/Homebrew.

Typical executable:

```text
/opt/homebrew/bin/haraka
```

---

# Service Structure

Typical layout:

```text
smtp/
 config/
    me
    plugins
    smtp.ini
    smtp_forward.ini
    tls.ini
    tls_key.pem
    tls_cert.pem
 plugins/
    local_relay.js
 logs/
 .gitignore
```

Some generated Haraka files may differ depending on the version used to initialize the service.

---

# Listener Configuration

Current `config/smtp.ini`:

```ini
listen=127.0.0.1:2525

nodes=1
```

Important:

```text
127.0.0.1
```

means Haraka accepts SMTP connections only from the local machine.

Do not change this to:

```text
0.0.0.0
*
[::0]
```

unless public SMTP exposure is explicitly intended and separately secured.

---

# SMTP Hostname

Current `config/me`:

```text
mail.archr.live
```

This controls Haraka's SMTP identity / HELO hostname.

---

# Plugins

Current `config/plugins`:

```text
local_relay
queue/smtp_forward
```

---

## local_relay

Custom plugin:

```text
plugins/local_relay.js
```

Purpose:

- allow SMTP relay from localhost
- avoid operating an open relay
- keep the SMTP service private to local applications

Expected allowed addresses include:

```text
127.0.0.1
::1
::ffff:127.0.0.1
```

Representative implementation:

```javascript
exports.register = function () {
    this.register_hook("connect", "allow_local_relay");
};

exports.allow_local_relay = function (next, connection) {
    const remoteIp =
        connection?.remote?.ip ||
        connection?.remote?.addr ||
        "";

    if (
        remoteIp === "127.0.0.1" ||
        remoteIp === "::1" ||
        remoteIp === "::ffff:127.0.0.1"
    ) {
        connection.relaying = true;
        this.loginfo(connection, "Allowing localhost relay");
    }

    next();
};
```

---

## queue/smtp_forward

This plugin forwards outbound mail through an upstream SMTP server instead of attempting direct-to-MX delivery.

This is the preferred production mode because it avoids depending on:

- a static public IP
- ISP port-25 policy
- local IP reputation
- PTR / reverse DNS control
- direct-delivery reputation management

---

# Current Upstream Provider: Resend

Haraka currently forwards mail through:

```text
Host: smtp.resend.com
Port: 587
Security: STARTTLS
Username: resend
Password: Resend API key
```

The API key should exist only in the local Haraka forwarding config.

Do not place it in:

```text
auth/.env
README files
Git history
shell history where avoidable
public logs
```

---

# SMTP Forward Configuration

Current conceptual `config/smtp_forward.ini`:

```ini
host=smtp.resend.com
port=587

enable_outbound=true
enable_tls=true

auth_type=plain
auth_user=resend
auth_pass=YOUR_RESEND_API_KEY

connect_timeout=30

[tls]
rejectUnauthorized=true
minVersion=TLSv1.2
```

The real file containing credentials should not be committed.

Protect it locally:

```bash
chmod 600 /Users/archrmac/archr/services/smtp/config/smtp_forward.ini
```

---

# TLS

Haraka has local TLS certificate/key files under `config/`.

These were created for the local SMTP service and are not required to be trusted publicly when the auth application connects locally without TLS.

The important outbound TLS path is:

```text
Haraka
  ->
STARTTLS
  ->
smtp.resend.com:587
```

The working setup has confirmed:

```text
TLSv1.3
verified=true
```

against Resend.

Private keys and certificates should not be committed.

---

# Confirmed Relay Flow

The following flow has been tested successfully:

```text
Auth application
   |
   | SMTP localhost
   v
Haraka :2525
   |
   | local_relay permits connection
   v
queue/smtp_forward
   |
   | STARTTLS
   v
smtp.resend.com:587
   |
   | AUTH PLAIN
   v
Authentication successful
   |
   v
Message accepted by Resend
```

Representative successful Haraka events include:

```text
forwarding to smtp.resend.com:587
```

```text
secured ... TLSv1.3 verified=true
```

```text
Authenticating with AUTH PLAIN resend
```

```text
235 Authentication successful
```

```text
queue code=OK
```

---

# DNS / Mail Authentication Responsibilities

Current sending domain:

```text
archr.live
```

The domain is verified with Resend.

Responsibilities are divided as follows:

```text
SPF    DNS / Resend-provided records
DKIM   Resend
DMARC  DNS
PTR    Not required for local host when Resend is the public sender
```

Haraka is not performing DKIM signing.

Resend is the Internet-facing sender and applies the DKIM signature for the verified sending domain.

DMARC is currently configured initially with:

```text
p=none
```

This allows monitoring before later moving to:

```text
p=quarantine
```

or:

```text
p=reject
```

---

# Why Direct-to-MX Was Replaced

Direct delivery from the Mac was tested successfully at the network level:

```text
outbound TCP/25 reachable
```

However, the public IP was dynamic and did not have configurable PTR / reverse DNS.

That makes direct delivery less portable and less reliable.

Using an SMTP smarthost removes that dependency.

Current production path:

```text
Haraka
  ->
Resend
  ->
recipient
```

instead of:

```text
Haraka
  ->
recipient MX directly
```

---

# Portability

The SMTP layer is intentionally vendor-neutral.

The application only needs:

```text
SMTP_HOST=127.0.0.1
SMTP_PORT=2525
SMTP_SECURE=false
```

Only Haraka knows the upstream provider.

A different deployment can replace Resend with:

```text
Brevo
Postmark
Amazon SES
Mailgun
organizational SMTP
government SMTP
regional provider
institutional relay
```

without changing the auth application.

Only the Haraka forwarding configuration changes.

---

# Security Model

Current protections:

```text
[x] Haraka bound only to 127.0.0.1
[x] Relay permitted only from localhost
[x] No public SMTP listener
[x] Upstream SMTP uses STARTTLS
[x] Upstream certificate verification enabled
[x] Upstream SMTP authentication required
[x] Resend API key isolated to Haraka
[x] Resend API key excluded from Git
[x] Private keys excluded from Git
[x] DKIM handled by the Internet-facing provider
[x] DMARC configured
```

---

# `.gitignore`

Recommended SMTP-service `.gitignore`:

```gitignore
# Environment / secrets
.env
.env.*
!.env.example

# Haraka / SMTP config that may contain credentials
config/smtp_forward.ini
config/*.secret.ini
config/*.local.ini

# TLS / private key material
*.pem
*.key
*.crt
*.p12
*.pfx

# Logs
*.log
logs/

# Runtime / spool data
queue/
outbound/
tmp/
temp/
run/

# Node
node_modules/

# macOS
.DS_Store
```

This intentionally ignores the actual credential-bearing SMTP forwarding config while allowing harmless Haraka configuration such as:

```text
config/smtp.ini
config/plugins
config/me
```

to remain version-controlled.

If additional `.ini` files later contain secrets, add them explicitly rather than globally ignoring every `.ini` file.

---

# Credential Safety

Before committing, verify that the secret SMTP forwarding file is ignored:

```bash
git check-ignore -v config/smtp_forward.ini
```

Verify private keys:

```bash
git check-ignore -v config/tls_key.pem
```

Inspect the staging area before committing:

```bash
git status
```

and after staging:

```bash
git add .
git status
```

Confirm that none of the following are staged:

```text
config/smtp_forward.ini
*.pem
*.key
.env
logs
runtime queue data
```

Important:

`.gitignore` does not remove credentials that were already committed.

If an API key was ever committed or pushed:

1. Revoke / rotate the key
2. Remove the secret from Git history
3. Verify the remote repository history is clean

---

# Operational Commands

## Start Haraka

```bash
haraka -c /Users/archrmac/archr/services/smtp
```

Expected output includes:

```text
Listening on 127.0.0.1:2525
```

---

## Confirm Listener

```bash
lsof -nP -iTCP:2525 -sTCP:LISTEN
```

Expected:

```text
TCP 127.0.0.1:2525 (LISTEN)
```

Do not expect:

```text
TCP *:2525
```

or:

```text
TCP *:25
```

for the current private-relay design.

---

## Test SMTP Banner

```bash
nc -v 127.0.0.1 2525
```

Expected:

```text
220 mail.archr.live ESMTP Haraka/... ready
```

---

## Stop Haraka

```bash
pkill -f "/opt/homebrew/bin/haraka -c /Users/archrmac/archr/services/smtp"
```

---

# Troubleshooting

## Haraka listens on port 25 instead of 2525

Check:

```text
config/smtp.ini
```

Correct syntax:

```ini
listen=127.0.0.1:2525
nodes=1
```

Do not use:

```ini
listen_host=127.0.0.1
listen_port=2525
```

Haraka 3.4.0 did not use those fields for this listener configuration.

---

## Connection refused on 2525

Check:

```bash
lsof -nP -iTCP -sTCP:LISTEN | grep -E 'node|haraka'
```

Confirm Haraka is actually listening on:

```text
127.0.0.1:2525
```

---

## SMTP forwarding fails

Check Haraka logs for:

```text
forwarding to smtp.resend.com:587
```

Then verify:

```text
STARTTLS succeeded
certificate verified
AUTH PLAIN succeeded
235 Authentication successful
```

If authentication fails, rotate or verify the upstream API key.

---

## Message reaches Haraka but not Resend

Confirm:

```text
queue/smtp_forward
```

is loaded in:

```text
config/plugins
```

and verify:

```ini
enable_outbound=true
```

in the forwarding config.

---

# Current Status

The SMTP relay is operational.

Confirmed path:

```text
Auth service
   |
   v
127.0.0.1:2525
   |
   v
Haraka
   |
   | STARTTLS + AUTH
   v
smtp.resend.com:587
   |
   v
Resend
   |
   v
Recipient
```

The service is currently suitable as the local mail-delivery abstraction for the magic-link authentication service.

