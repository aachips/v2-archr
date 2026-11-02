He's working on canonical schema and steps with robot

Keep rocking with vue components and page - migration

Neither of us know Pinia. Primary functionality believed is to be role/permission filtering for shared components.. "Admin" will see "verify documents", "Project Manager" will see "Assign Work Crew", etc..

As long as base-functionality of ~logged-in~=TRUE & ~show-for-role~=_ROLE_. Mix and match as to make sense. 

### Marketplace

Marketplace should behave like a shopping page, where there are Carts and a Check-Out. It should be noted that no financial transactions are happening here or anywhere on the platform. But for bulk management of: 

- Repair Needs - Claim/Release/Add Tasks
- Repair Tasks - Add to/Remove from Contract, Mark Complete, Delete
- Documents - Unlink/Reassign/Mark Verified/Unmark Verified
- People - Edit Roles/ Add to Workcrew/See History
- Subcontractors - Solicit Bids
- and Projects - Mark Complete/Assign Subcontractor/Add to Draw Requests

There will exist a bulk management "Check-Out" style page for bulk actions.

An example of the pseudo structure of this - {"cartType":"repairNeed, "cartItems":["rec123675867834"]}

The goal is not to sort all of these processes out right now. But we will likely be implementing the use of Pinia for state management. 

### Back-end Consolidation

We have two separate back-ends set up, one within vue-view, and another within app. Both are used and referenced in v2-archr, but they exist separately. One uses PHP, the other is with Vue. The PHP handles lots of logic for the app, and the most visible use is that it handles the log in portal for super admin (level 3 permissions / IT Account management). Vue-view handles level 2 permissions / Organization Admin functions, which make up most of what we are building right now. There are two auth.php's that exist, and we run into problems. Right now the log in screen on v2-archr breaks and gives an empty white page. When you go to app/login.php it reroutes to setup.php indicating it did not identify a super admin account existing. So my guess is that the connection it has to the user account table broke somehow. 

The PHP handles the log in logic and PSQL integration. It's somewhat hard to work with for other developers because PHP is what it is. Our goal in the future is to migrate to Nuxt and simplify to a lower complexity language that's easier for Vue developers to jump into. 

A goal for today is to get the log in portal working, and have it consolidated from two separate ones, to one log in portal, that supports different permission level dashboards. So if I log in as a superadmin, I can view and manage user accounts and helpdesk tickets. If I log in as a level 2 organization admin, I get the standard build that is present on the portal currently for intake and application case search and management.



### Technical Plan: Today's Goal (Consolidated Login)

**Objective:** Fix the broken login on `v2-archr` and consolidate the two separate login flows (PHP Super Admin + Vue Level 2) into one portal that routes based on role.

#### 1. Diagnose the Broken Login (First 30 Minutes)

The white page and the redirect to `setup.php` suggest the PHP backend is not finding the user table or the super admin account. Before writing new code, confirm the connection:

- Check `app/login.php` and `app/config/database.php`. Ensure the PSQL connection is active and the `system_users` (or equivalent) table exists.
    
- Run a direct query in the database to confirm a super admin user record exists. The `setup.php` redirect implies the check for `SELECT COUNT(*) FROM users WHERE role = 'superadmin'` is returning zero.
    
- Look at the PHP error log for the white screen. It is likely a fatal error (e.g., class not found, or a null database connection) that is being suppressed.
    
#### 2. Implement Pinia for Auth State (Simple Version)

Do not build a complex permission system yet. Build the minimum store to hold the user session and role.

**Step A: Install Pinia.** In your `vue-view` project:

bash

npm install pinia @vue/devtools-api

_(Note: Pinia v4 requires the devtools API as a peer dependency .)_[](https://pinia.vuejs.org/getting-started.md)

**Step B: Create a single `auth` store.** This is the only store you need today.

javascript

// stores/auth.js
import { defineStore } from 'pinia'
export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null, // { id, name, role }
    isLoggedIn: false,
  }),
  getters: {
    // Simple role checks for your components
    isSuperAdmin: (state) => state.user?.role === 'superadmin',
    isOrgAdmin: (state) => state.user?.role === 'org_admin',
  },
  actions: {
    setUser(userData) {
      this.user = userData
      this.isLoggedIn = true
    },
    logout() {
      this.user = null
      this.isLoggedIn = false
    }
  }
})

#### 3. Consolidate the Login Flow (The Actual Fix)

The cleanest path today is **not** to merge the PHP and Vue codebases. It is to have the **PHP login endpoint return the role**, and let the Vue frontend route the user.

**Step A: Fix the PHP login endpoint.** Ensure `app/login.php` (or a dedicated API endpoint) does the following:

1. Accepts email/password.
    
2. Validates against the PSQL `system_users` table.
    
3. Returns a JSON response: `{ success: true, user: { id, name, role: 'superadmin' or 'org_admin' } }`.
    

**Step B: The Vue login page calls this endpoint.**  
On success, it calls `useAuthStore().setUser(response.user)`.

**Step C: Route based on role in the Vue app.**  
After login, check the store:

- If `isSuperAdmin`, redirect to the Super Admin dashboard route (you can eventually point this to the existing PHP-based admin panel, or build a new Vue view for it).
    
- If `isOrgAdmin`, redirect to the existing Level 2 portal (`/dashboard` or wherever the current Vue build lives).
    

This eliminates the need to fix two separate login screens. The PHP backend becomes the single source of truth for authentication; the Vue frontend handles the user experience and routing.

#### 4. What to Defer (Be Explicit with Your Boss)

- **Nuxt Migration:** Do not start this today. It is a multi-day refactor. The login fix above works in plain Vue. Nuxt can wait until the auth flow is stable.
    
- **Vueform:** Do not start this today. The volunteer intake form is a separate project for Friday's meeting.
    
- **Marketplace "Cart" Logic:** Do not start this today. The `{"cartType":"repairNeed", "cartItems":[...]}` concept is sound for bulk actions, but it requires the repair need components to exist first. Today is about auth.
    

---

### What You and Others Should Know About Pinia/Nuxt (Operational Notes)

**For Pinia:**

- **Do not overuse it.** A store is for global state (user session, theme, cart). Local component state (a modal being open) stays in the component .[](https://pinia.vuejs.org/getting-started.md)
    
- **The pattern for permissions:** Keep the permission check in **one store** and **one directive** (or a simple `v-if` reading from the store). Do not scatter `if (user.role === 'admin')` across dozens of components. The store is the single source of truth .[](https://www.linkedin.com/posts/ali-sadiquee_roles-and-permissions-in-laravel-vue-activity-7493526427510919168-cn2j#1)
    

**For Nuxt (When You Get There):**

- **Prerequisites:** You need **Node.js 22.x or newer** (even-numbered versions) to run Nuxt 4 . Check your Laragon Node version before starting a migration.[](https://nuxt.com/raw/docs/4.x/getting-started/installation.md)
    
- **The structure is different:** Nuxt uses `pages/` for routing (not manual Vue Router config) . When you migrate, you will move your Vue views into `pages/` and your reusable components into `components/`.[](https://worktile.com/kb/p/3656731#1)[](https://nuxt.com/docs/3.x/guide/concepts/vuejs-development#vue-with-nuxt)
    
- **Auth in Nuxt:** The standard pattern is to use **httpOnly cookies** for tokens, not localStorage . This is more secure. Plan for that when you eventually migrate the auth flow.[](https://github.com/martinholovsky/claude-skills-generator/blob/HEAD/skills/vue-nuxt-expert/SKILL.md#2)
    

**A Note on the Existing PHP Login:** You do not need to rewrite the PHP login in Nuxt to fix it. The PHP backend can stay as the authentication API while the Vue frontend uses Pinia to manage the session state. This is a valid, common architecture (a PHP API with a Vue SPA frontend) .[](https://github.com/codelti/nuxt-laravel-api#1)

---

**Summary for your day:**

1. Fix the PSQL connection / user table issue in the PHP login.
    
2. Add Pinia to the Vue app.
    
3. Create one `auth` store with a `role` field.
    
4. Have the Vue login page call the PHP endpoint, store the role, and route to the correct dashboard.
    
5. Tell your boss: "Nuxt migration is next week; today we make the current stack authenticate and route correctly."