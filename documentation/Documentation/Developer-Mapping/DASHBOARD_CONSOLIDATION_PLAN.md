# Dashboard Consolidation Plan 7/18/2026

## Current State

Currently, there are multiple separate dashboard/portal pages scattered throughout the app:
- `app/requestor-portal.php` - Requestor dashboard
- `app/admin-portal.php` (likely exists)
- `app/staff-portal.php` (likely exists)
- Various other role-specific pages

**Problems:**
1. **Duplicate Code** - Each portal has its own authentication, layout, navigation
2. **Inconsistent UI** - Different portals may have different styling and UX patterns
3. **Maintenance Burden** - Updates must be made to multiple files
4. **Path Confusion** - Links sometimes point to wrong locations (e.g., `../requestor-portal.php` vs `requestor-portal.php`)
5. **No Centralized Access Control** - Auth logic scattered across files

## Proposed Solution: Single Controller Pattern

### Architecture Overview

```
app/
├── dashboard.php              # Single entry point (controller)
├── config/
│   └── dashboard-routes.php  # Route definitions
├── controllers/
│   ├── DashboardController.php
│   ├── RequestorController.php
│   ├── AdminController.php
│   └── StaffController.php
├── views/
│   ├── layouts/
│   │   └── dashboard-layout.php  # Shared layout/chrome
│   ├── requestor/
│   │   ├── overview.php
│   │   ├── case-detail.php
│   │   ├── messages.php
│   │   └── documents.php
│   ├── admin/
│   │   ├── overview.php
│   │   ├── case-review.php
│   │   └── reports.php
│   └── staff/
│       ├── assigned-cases.php
│       └── task-queue.php
└── lib/
    └── router.php            # Simple routing logic
```

### Benefits

1. **Single Authentication Point** - All dashboard access goes through one file
2. **Consistent Layout** - Shared chrome (header, nav, footer)
3. **Easy Maintenance** - Update one place, affects all dashboards
4. **Clean URLs** - `dashboard.php?view=requestor/overview`
5. **Role-Based Access Control** - Centralized permission checking
6. **Easier Testing** - Single entry point to test

## Implementation Plan

### Phase 1: Planning & Architecture (Current - Do Not Implement)
- [x] Document current state
- [x] Design new architecture
- [ ] Map existing functionality to new structure
- [ ] Identify shared components
- [ ] Plan migration path

### Phase 2: Foundation (Future)
- [ ] Create `app/lib/router.php` with simple routing
- [ ] Create `app/config/dashboard-routes.php` for route definitions
- [ ] Create `app/views/layouts/dashboard-layout.php` for shared UI
- [ ] Create base `app/controllers/DashboardController.php`

### Phase 3: Migration (Future)
- [ ] Extract requestor portal to new structure first (pilot)
- [ ] Test thoroughly
- [ ] Migrate admin portal
- [ ] Migrate staff portal
- [ ] Deprecate old files (keep for 1 release cycle)

### Phase 4: Enhancement (Future)
- [ ] Add breadcrumbs
- [ ] Add unified navigation
- [ ] Add role-based menu system
- [ ] Add dashboard widgets
- [ ] Add notification center

## Technical Specification

### Router Implementation

```php
// app/lib/router.php
class Router {
    private array $routes = [];
    private string $basePath;
    
    public function addRoute(string $path, string $controller, string $method): void {
        $this->routes[$path] = ['controller' => $controller, 'method' => $method];
    }
    
    public function dispatch(string $path): void {
        if (!isset($this->routes[$path])) {
            http_response_code(404);
            require __DIR__ . '/../views/errors/404.php';
            return;
        }
        
        $route = $this->routes[$path];
        $controller = new $route['controller']();
        $method = $route['method'];
        $controller->$method();
    }
}
```

### Dashboard Controller Pattern

```php
// app/dashboard.php
require_once __DIR__ . '/lib/auth.php';
require_once __DIR__ . '/lib/router.php';
require_once __DIR__ . '/config/dashboard-routes.php';

// Require authentication
$user = require_authentication();

// Initialize router
$router = new Router();
load_dashboard_routes($router, $user);

// Get requested view
$view = $_GET['view'] ?? get_default_view($user);

// Dispatch
$router->dispatch($view);
```

### Example Route Configuration

```php
// app/config/dashboard-routes.php
function load_dashboard_routes(Router $router, User $user): void {
    // Requestor routes
    if ($user->hasRole('REQUESTOR')) {
        $router->addRoute('requestor/overview', RequestorController::class, 'overview');
        $router->addRoute('requestor/case', RequestorController::class, 'caseDetail');
        $router->addRoute('requestor/messages', RequestorController::class, 'messages');
    }
    
    // Admin routes
    if ($user->hasRole('ADMIN')) {
        $router->addRoute('admin/overview', AdminController::class, 'overview');
        $router->addRoute('admin/cases', AdminController::class, 'caseList');
        $router->addRoute('admin/case/:id', AdminController::class, 'caseDetail');
    }
    
    // Staff routes
    if ($user->hasRole('STAFF')) {
        $router->addRoute('staff/queue', StaffController::class, 'taskQueue');
    }
}
```

## URL Structure

### Current (Problematic)
```
app/requestor-portal.php
app/requestor-portal.php?page=case
app/admin-portal.php
app/admin-portal.php?action=review
```

### Proposed (Clean)
```
app/dashboard.php?view=requestor/overview
app/dashboard.php?view=requestor/case&id=123
app/dashboard.php?view=admin/overview
app/dashboard.php?view=admin/case/123
```

## Migration Strategy

### Step 1: Create Parallel System
- Build new dashboard alongside existing portals
- No changes to existing links
- Test with small group

### Step 2: Update Links Gradually
- Update intake confirmation to use new dashboard
- Update email templates
- Update navigation menus

### Step 3: Deprecate Old System
- Add deprecation notices to old portals
- Redirect old URLs to new system
- Remove old files after 1 release cycle

## Dependencies & Prerequisites

- [ ] Authentication system working (`app/lib/auth.php`)
- [ ] Role-based access control functional
- [ ] User session management stable
- [ ] Database schema supports all needed queries

## Success Criteria

1. **Single Entry Point** - All dashboard access via `dashboard.php`
2. **Consistent UI** - Same header/nav/footer everywhere
3. **No Broken Links** - All existing links work (via redirects if needed)
4. **Role-Based Access** - Users only see views for their roles
5. **Performance** - No slower than current system
6. **Maintainability** - Easier to add new views/features

## Non-Goals (Out of Scope)

- Rewriting existing business logic
- Changing database schema
- Adding new features (focus on consolidation)
- Changing authentication system
- API development

## Risks & Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking existing links | High | Keep old files, add redirects |
| Role permission bugs | High | Extensive testing per role |
| Performance regression | Medium | Load testing before rollout |
| User confusion | Medium | Clear communication, training |

## Timeline Estimate

- **Phase 1 (Planning)**: 1 week - Document and design
- **Phase 2 (Foundation)**: 2 weeks - Build core infrastructure  
- **Phase 3 (Migration)**: 3-4 weeks - Migrate all portals
- **Phase 4 (Enhancement)**: 2 weeks - Polish and improve

**Total: 8-9 weeks**

## Next Steps (When Ready to Implement)

1. Get stakeholder approval for plan
2. Review and refine architecture
3. Create detailed technical spec
4. Set up development environment
5. Begin Phase 2 implementation
