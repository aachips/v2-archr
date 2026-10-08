<?php
/**
 * ARCHR secure credentials — TEMPLATE
 *
 * 1. Put a copy of this file OUTSIDE the web root, named archr_connect.php.
 *    The app searches these locations (first hit wins):
 *      a. The path in the ARCHR_SECURE_CONFIG environment variable (override)
 *      b. TWO levels above the app/ folder
 *         - web host (app at public_html/archr/): /home/<you>/secure_config/
 *           — sibling of public_html/, outside the web root
 *         - local: same convention, two levels above your local app/ folder
 *      c. ONE level above the app/ folder (local dev default; gitignored)
 *      d. Inside the app/ folder (last-resort local fallback; gitignored)
 *
 *    LOCAL vs WEBHOST: there is no switching logic on purpose. Each
 *    environment has its OWN archr_connect.php holding THAT environment's
 *    credentials — the local file hold`s the local database credentials,
 *    the web-host file holds the webhost credentials. The app simply uses
 *    whichever file exists where it is running. Never copy one
 *    environment's file into the other, and never commit a real file
 *    (the secure_config/ directory is gitignored).
 *
 * 2. Fill in real values. Omitted or EMPTY keys fall back to real
 *    environment variables, then to the local-development defaults in
 *    app/config/database.php — so locally you can omit every PG* line if
 *    your local database matches those defaults.
 * 3. This template is safe to commit; real copies are not.
 */

return [
    // ----------------------------------------------------------------
    // Global READ switch: which database the app reads from.
    //   'postgresql' (default) — read from the ARCHR PostgreSQL database
    //   'airtable'             — read from the Airtable dummy mirror base
    // Writes always go to PostgreSQL first and then to Airtable when a
    // token is configured, regardless of this setting.
    // ----------------------------------------------------------------
    'DB_DRIVER' => 'postgresql',

    // ----------------------------------------------------------------
    // PostgreSQL (the ARCHR database on your web host)
    // ----------------------------------------------------------------
    'PGHOST'     => 'localhost',        // shared hosting: usually 'localhost'
    'PGPORT'     => '5432',
    'PGDATABASE' => 'archr',            // some hosts prefix: cpaneluser_archr
    'PGUSER'     => 'postgres',
    'PGPASSWORD' => 'dumps-cassie-looks-trusts-nils-rubies',

    // ----------------------------------------------------------------
    // Airtable dummy database (dual-write target / read mirror)
    // Create the token at https://airtable.com/create/tokens with scopes:
    //   data.records:read, data.records:write, schema.bases:read
    // ...and access to the dummy base (default appiMfIEzULJtmi5v).
    // Removing or emptying AIRTABLE_PAT disables the Airtable dual-write.
    // ----------------------------------------------------------------
    'AIRTABLE_PAT' => 'patJmEFQXcAWZqvDo.ca1e2dfb4166366f4ae3578effea0fa7572442857f60968e400846deb30d4c16',

    // Only needed if your dummy base ID differs from the default.
    // 'AIRTABLE_INTAKE_BASE_ID' => 'appXXXXXXXXXXXXXX',

    // ----------------------------------------------------------------
    // Dropbox API (document storage integration; optional).
    // Generate a token in the Dropbox App Console
    // (https://www.dropbox.com/developers/apps). Omitted/empty = disabled.
    // Uncomment when you have a token:
    // ----------------------------------------------------------------
    'DROPBOX_ACCESS_TOKEN' => 'sl.u.AGss-1SDfUEkFu9dMgQJRICKp5_eEIZ-KmIU5KPTQaudHl2JpEGI7V_23QFnlShM76vZwOX90f9i_-XA29tRW_lNydPYvX_832JxvQKKQo6hPlHs9louzGCA1xlxE6WCJqQizarSfmQ1ZaAK3pdNo-7WQLWUml2rjBToLHCqsqhKhlLJUyxeK_2VN6vbwLmQq6AClke2QBNHQLrS3umkR5r2SjmTWxXzJWkCFSHEL1DFOzZ9PoqMt21XmO-jmT7g80meWMO7Iyr77eNzMcz_gvPzXtJjMVKQA1N8IJFxZ9-Htl6vYwFzWBazf1EI1d9_0HNX462tE1yYtUFE5IwaUHY5KGcojGFFymZrkLdOeYR98arjr6PJTrNKk1iITOKvAbBCMFHrUHeGo7L8BCcfRdBEBoYRIbzvBI15q_b2sZNx1zOe2rQuyLbimiem1gX30LGX-Q4RrzxVsooAZo3HxVspAMCQ3b3GSnwcpDpCohvNSnVX4vke442dS1BlJE5YdS9voR0E-IT5lb8zDbXsEpP5AfHLUXhjQe7LzPH8J_TGkWMWCjB1Ayj9ty30kzq3GwQKwMVao_48BK_BT-LYjah5AX1ryTiVQ9YXEWI7RRBtB63S-to9Kb2gkAc0a9f2jMeM1_tP2qCT2eL9bYDoRNGVGjFzVQDq9OrIXaKaJ7F5wXhNOhRJcjzVHeggB0kJYDj0wB1A3-Fv2I1qRFSkmdgn74-JTVTIlNOwVB1JcBT2mwuP8rvwRnwSmI6AMcpAAOfjO7HyPe0tpkdNWuW7v8kvBqvY-Gl3Y96S_Az-XXN_JvYJPULNg1NddPDYlQCHrVZbz52Ol65Hs4vjZOtmaJDXE5WtJmNkCEBjSRSuSuQkegEWqAV6RPOvPUq8j1sWWaJpHNDzvu4lo4PQeL9WZs74br2S1H9ksvAN5xUlQNGRDQefhx9slx_K8oM2L4yOpxqskiKHlZW_cFjfmfX6eAnrYibtWu55exFYwtrn0i7uLzodWExXljZQr1I64sUwooeyRPtvS8TRHWvl9FKVfNBMstiSf4RVmQOau5484DSZxW8aX_M93OwF0dHX6-gZPySp_KOw9tp-q4nFQQqcR5Te8sF6t42TeRB7Rv_JLHNC2Z-wivZ-LucUTlJoBqH8F55MewH485P10CKAUOQm1lawrbECJFFELKHlfht3di2l69AWddcz_w6KCpG0UFimpx928Nry0VDq7zTstAZrYT92GkaVt9RHwDf5TDn5OCQrF8RJHHZ1czvCjfs8XFYDJxK5PYb0eZ5XSWxsXBl6_CQESi8yxQTqi0fyuiq1GFkfVjTCIN5qTuQoPhXqG7WNl1Iwd0up7cREZFyikaae20s2kdxF4_gf1T-Ha1z6Gxec8rn3GzB8Y58t-DDp_ipyHI_ZbAorCBoM92f30zX7OvNJdDbV0BM33zSXAvPyXXfjgZkaUTHAiePdeghU1ELN6lo',
    'DROPBOX_APP_KEY'      => 'bmhd69jl48479s2',   // only needed for OAuth refresh flow
    'DROPBOX_APP_SECRET'   => 'ratsd3q3zfcucmn',   // only needed for OAuth refresh flow
    'DROPBOX_REFRESH_TOKEN' => '3t-wx0TIoroAAAAAAAAAAeDAP___WZNEId72y23d-NDuLOESEynDEQdxNOBCET9O',

    // ----------------------------------------------------------------
    // Optional: surface real error messages in submit.php responses
    // while you are setting up. Turn OFF when finished.
    // ----------------------------------------------------------------
    // 'APP_ENV'   => 'development',
    // 'APP_DEBUG' => 'true',
];
