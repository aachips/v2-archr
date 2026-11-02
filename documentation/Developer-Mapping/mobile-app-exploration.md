# ARCHR Mobile App — Path to Explore

> **Status:** Exploration doc — not yet implemented
> **Date:** October 31, 2026
> **Context:** Assessor portal currently runs as a Vue SPA served by PHP/Laragon. Phase 1 offline (LocalStorage drafts) works in-browser. This doc explores what it would take to become a native mobile app for Android/iOS with full offline capability.

---

## Why a Mobile App?

The assessor portal is a **field-work tool**. Assessors go to properties that often have:
- No cell service (rural Appalachian properties)
- No Wi-Fi
- Intermittent connectivity after disasters
- Need for camera access (before/during/after photos)
- Need for GPS (check-in at property, route logging)

A browser tab works, but a native app gives us:
- **Reliable offline storage** (SQLite on device, not browser IndexedDB quirks)
- **Native camera integration** (photos with EXIF metadata, auto-compression)
- **Background GPS tracking** (works when the app is minimized)
- **Push notifications** (new assessment assignments, messages, schedule reminders)
- **App icon on home screen** (no need to remember a URL)
- **Works immediately on launch** (no loading spinner, no "needs JavaScript" warning)

---

## The Three Paths

### Path A: Capacitor (Recommended — Same Vue Code, Native Shell)

**What it is:** [Capacitor](https://capacitorjs.com/) is a tool from the Ionic team that wraps your existing web app in a native shell (Android Studio project + Xcode project). Your Vue code **doesn't change** — it's the same HTML/CSS/JS. Capacitor adds a bridge to native device APIs.

**How it works:**
1. You run `npx cap add android` and `npx cap add ios` in your existing Vue project
2. Capacitor copies your built `dist/` into a native WebView inside a bare-bones Android/iOS app
3. You use Capacitor plugins to access native features (camera, GPS, filesystem, push notifications)
4. You build the app with Android Studio (APK/AAB) or Xcode (IPA)

**What changes in our code:**
- **Vue app:** Almost nothing. Same components, same router, same store.
- **Add:** A few `@capacitor/*` plugin calls where we need native features.
- **Add:** A `capacitor.config.json` (one file, ~20 lines).
- **Build:** Run `npm run build` then `npx cap sync` then open in Android Studio/Xcode.

**Native features via Capacitor plugins:**

| Feature | Plugin | What it gives us |
|---------|--------|-----------------|
| Camera | `@capacitor/camera` | Take photos, pick from gallery, auto-compress |
| Filesystem | `@capacitor/filesystem` | Save photos/documents to device storage |
| GPS/Location | `@capacitor/geolocation` | Get coordinates, background tracking (with `@capacitor-community/background-geolocation`) |
| Storage | `@capacitor/preferences` | Key-value storage (replaces localStorage, persistent across app updates) |
| SQLite | `@capacitor-community/sqlite` | Full SQL database on device (replaces IndexedDB) |
| Push Notifications | `@capacitor/push-notifications` | Server can send push alerts for new assignments |
| Network | `@capacitor/network` | Detect online/offline state reliably |
| App Lifecycle | `@capacitor/app` | Handle app minimize/restore, back button |

**Offline architecture with Capacitor:**

```
┌─────────────────────────────────────────────────────┐
│                    Phone (Offline)                   │
│                                                     │
│  ┌──────────────┐   ┌──────────────────────────┐    │
│  │   Vue SPA    │──▶│   Capacitor WebView      │    │
│  │  (no change) │   │   (same JS, same CSS)    │    │
│  └──────┬───────┘   └──────────┬───────────────┘    │
│         │                      │                     │
│         │              Native API calls              │
│         │                      │                     │
│         │       ┌──────────────┴──────────────┐     │
│         │       │   @capacitor-community/      │     │
│         │       │   sqlite                     │     │
│         │       └──────────────┬──────────────┘     │
│         │                      │                     │
│         │              ┌───────┴───────┐            │
│         │              │  SQLite DB    │            │
│         │              │  (assessments,│            │
│         │              │   photos refs,│            │
│         │              │   GPS logs)   │            │
│         │              └───────────────┘            │
│         │                      │                     │
│         │       Filesystem API stores photos        │
│         │       as actual files on device           │
└─────────┼──────────────────────┼─────────────────────┘
          │                      │
          │         When back online:
          │                      │
          ▼                      ▼
┌─────────────────────────────────────────────────────┐
│                    PHP Server (Online)                │
│                                                     │
│  ┌──────────────────────────────────────────────┐   │
│  │  /app/vue_api/assessor.php                    │   │
│  │    - sync_assessment (accepts JSON + photos)  │   │
│  │    - sync_gps_logs (batch upload)             │   │
│  │    - sync_notes (batch upload)                │   │
│  │    - conflict detection                       │   │
│  └──────────────────────────────────────────────┘   │
│                                                     │
│  ┌──────────────────────────────────────────────┐   │
│  │  PostgreSQL                                   │   │
│  │    - assessments table                        │   │
│  │    - assessment_photos table                  │   │
│  │    - assessment_notes table                   │   │
│  │    - assessor_gps_logs table                  │   │
│  └──────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

**Pros:**
- ✅ **Same Vue code** — no rewrite, no new framework to learn
- ✅ **One codebase** — Android and iOS from the same source
- ✅ **Fast to prototype** — `npx cap add android` and you have an APK in hours
- ✅ **Incremental adoption** — start with browser, add native features one at a time
- ✅ **No app store required** — can distribute APK directly to assessors' phones
- ✅ **Web fallback** — if someone opens the URL in a browser, it still works as a web app

**Cons:**
- ❌ **Not a "real" native app** — still a WebView, not native UI components
- ❌ **iOS requires a Mac** — Xcode only runs on macOS (we have the Mac Mini for this)
- ❌ **App store submission** — if you want it on Google Play / App Store, there's review process and fees ($25 Google, $99/year Apple)
- ❌ **Performance ceiling** — very heavy pages with lots of DOM may feel sluggish in a WebView (not an issue for our current app)

**Effort estimate:**
- **Week 1:** Set up Capacitor, build Android APK with existing Vue app (no native features yet — just proves the wrapper works)
- **Week 2:** Add SQLite storage for offline assessments (replaces LocalStorage)
- **Week 3:** Add camera integration + filesystem for photo storage
- **Week 4:** Add GPS check-in/out + background sync endpoints on PHP server
- **Week 5:** Polish, testing, push notifications (optional)

**Total: ~4-5 weeks to a fully functional offline-first mobile app**

---

### Path B: React Native (Rewrite in React)

**What it is:** Rewrite the Vue app as a React Native app. React Native renders native UI components, not a WebView.

**What changes:** Everything. Vue templates → React components. Vue Router → React Navigation. Pinia → Redux/Zustand. CSS → React Native StyleSheet (no CSS).

**Pros:**
- ✅ True native UI (not a WebView)
- ✅ Better performance for complex screens
- ✅ Access to entire React Native ecosystem

**Cons:**
- ❌ **Full rewrite** — months of work, not weeks
- ❌ **Learn React** — same learning curve as Vue
- ❌ **Two codebases** if you keep the web version (maintenance burden)
- ❌ **No CSS** — all styling is JavaScript objects, different mental model

**Verdict:** Not worth it for our situation. The Vue SPA works fine; rewriting in React Native buys us marginal performance gains at enormous cost.

---

### Path C: Flutter (Rewrite in Dart)

**What it is:** Google's cross-platform native framework. Uses the Dart language, renders its own UI engine (skia), not native components.

**What changes:** Everything. Vue → Flutter widgets. JavaScript → Dart. HTML → Flutter widget tree.

**Pros:**
- ✅ Excellent offline support (SQLite via `sqflite`)
- ✅ Beautiful, consistent UI across platforms
- ✅ Strong tooling (VS Code extension, DevTools)

**Cons:**
- ❌ **Full rewrite** — even bigger than React Native
- ❌ **Learn Dart** — new language, new framework
- ❌ **Larger app size** — Flutter apps are ~15-30MB minimum
- ❌ **Two codebases** if you keep the web version

**Verdict:** Same as React Native — not worth the rewrite cost.

---

### Path D: Progressive Web App (PWA) — No Native Wrapper

**What it is:** Add a service worker + web app manifest to the existing Vue SPA. Users "install" it by visiting the URL and tapping "Add to Home Screen."

**What changes:**
- Add `service-worker.js` (caches app shell + API responses)
- Add `manifest.json` (app name, icon, theme color)
- Register service worker in `main.js`
- That's it — Vue code doesn't change

**Pros:**
- ✅ **No new framework** — same Vue app, just with caching
- ✅ **No app store** — installs from the URL
- ✅ **Works offline** (with IndexedDB or LocalStorage)
- ✅ **App icon on home screen** (looks like an app)
- ✅ **Fastest path** — 1-2 weeks to full PWA

**Cons:**
- ❌ **No native camera API** — must use `<input type="file" accept="image/*">` (works, but no EXIF control)
- ❌ **No background GPS** — GPS only works when the tab is active
- ❌ **No push notifications on iOS** — Safari doesn't support web push until iOS 16.4+ (and only if added to home screen)
- ❌ **Browser limitations** — IndexedDB has quirks, Background Sync is unreliable on iOS Safari

**Verdict:** **This is Phase 2.** It's a great intermediate step. If PWA offline is "good enough" after testing with real assessors, you may never need Capacitor.

---

## Recommended Path (Phased)

```
NOW        Phase 1: LocalStorage Drafts (in browser)
             ↓ 2-3 days
             ↓ "Fill forms offline, sync when back online"
             ↓ Photos: not stored offline (gap)
             
SOON       Phase 2: PWA (service worker + IndexedDB)
             ↓ 2-3 weeks
             ↓ Full offline in browser, including photos as Blobs
             ↓ Auto-sync via Background Sync API
             ↓ Test with real assessors in the field
             
LATER      Phase 3: Capacitor (native wrapper) — IF Phase 2 isn't enough
             ↓ 4-5 weeks
             ↓ Native camera, GPS, SQLite, push notifications
             ↓ Distribute as APK directly or via app stores
             ↓ Same Vue code, just wrapped
```

**Decision gate between Phase 2 and Phase 3:**
After Phase 2 is deployed and tested with real assessors for 2-4 weeks, ask:
- "Did the PWA work reliably offline?" (If yes → stay with PWA. If no → Capacitor.)
- "Do you need GPS tracking while the app is minimized?" (If yes → Capacitor.)
- "Do you need push notifications?" (If yes → Capacitor.)
- "Are photos working well enough?" (If yes → stay with PWA. If no → Capacitor.)

---

## What We'd Need on the Server (All Phases)

Regardless of which mobile path we take, the PHP backend needs new endpoints:

```php
// app/vue_api/assessor.php — new actions

'action=sync_assessment'
  // Accepts: { assessment_id, data: {...}, photos: [base64 or multipart], notes: [...] }
  // Stores: assessment data in assessments table, photos in filesystem + assessment_photos table
  // Returns: { success: true, server_version: 42 }

'action=sync_gps_logs'
  // Accepts: { logs: [{ assessment_id, lat, lng, timestamp, action }] }
  // Stores: in assessor_gps_logs table

'action=sync_notes'
  // Accepts: { notes: [{ assessment_id, note_type, content, is_public }] }
  // Stores: in assessment_notes table

'action=get_pending_conflicts'
  // Accepts: { assessment_id, client_version }
  // Returns: { conflict: true, server_version: 43, changes: {...} }
  // Used by the app to detect if server data changed while offline
```

And new database tables:

```sql
CREATE TABLE assessment_photos (
    id SERIAL PRIMARY KEY,
    assessment_id INTEGER REFERENCES assessments(id),
    doc_type VARCHAR(50),        -- 'before', 'during', 'after', 'quote', 'invoice'
    file_path VARCHAR(500),
    uploaded_at TIMESTAMP DEFAULT NOW(),
    uploaded_by INTEGER REFERENCES users(id)
);

CREATE TABLE assessment_notes (
    id SERIAL PRIMARY KEY,
    assessment_id INTEGER REFERENCES assessments(id),
    note_type VARCHAR(50),       -- 'general', 'safety', 'access', 'structural'
    content TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE assessor_gps_logs (
    id SERIAL PRIMARY KEY,
    assessment_id INTEGER REFERENCES assessments(id),
    assessor_id INTEGER REFERENCES users(id),
    action VARCHAR(20),          -- 'check_in', 'check_out', 'waypoint'
    lat DECIMAL(10, 8),
    lng DECIMAL(11, 8),
    accuracy_m DECIMAL(6, 2),
    logged_at TIMESTAMP DEFAULT NOW()
);
```

---

## Cost Summary

| Phase | Effort | What You Get | When to Move to Next |
|-------|--------|-------------|---------------------|
| **Phase 1: LocalStorage** | 2-3 days | Offline form filling (no photos) | Immediately — it's quick |
| **Phase 2: PWA** | 2-3 weeks | Full offline with photos, auto-sync | After 2-4 weeks of field testing |
| **Phase 3: Capacitor** | 4-5 weeks | Native app with camera, GPS, push | Only if Phase 2 has gaps |

**Total if you go all the way:** ~7-8 weeks to a production mobile app.
**Total if PWA is enough:** ~3 weeks to a working offline-first web app.

---

## Next Steps (When Ready)

1. **Build Phase 1** (LocalStorage drafts) — can be done this week
2. **Test with one assessor** — have them use it on a property with no cell service
3. **Gather feedback** — what worked, what didn't, what felt clunky
4. **Decide: PWA or Capacitor?** — based on real usage, not speculation
5. **Build chosen path** — with the learnings from Phase 1

---

## References

- [Capacitor Docs](https://capacitorjs.com/)
- [Capacitor Vue Plugin](https://capacitorjs.com/docs/vue)
- [PWA Vue Plugin](https://github.com/vuejs-templates/pwa)
- [Vue CLI PWA Mode](https://cli.vuejs.org/core-plugins/pwa.html) (already available in our `@vue/cli-plugin-pwa`)
- [IndexedDB Guide](https://web.dev/indexeddb/)
- [Background Sync API](https://web.dev/background-sync/)
