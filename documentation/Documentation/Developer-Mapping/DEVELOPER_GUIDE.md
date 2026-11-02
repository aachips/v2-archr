# Developer Guide: Dashboard & API Structure

## Quick Start

### Understanding the New Structure

Each role dashboard now follows this pattern:

1. **Main PHP File** (`app/{role}.php`) - Loads dashboard home
2. **Dashboard Home** (`app/partials/dashboard-home.php`) - Common landing page
3. **API Endpoints** (`app/api/{role}/*.php`) - Data providers for each feature
4. **Menu Navigation** - Each menu item maps to a feature/endpoint

---

## File Organization

```
app/
├── {role}.php                     # Main dashboard file for each role
├── partials/
│   ├── dashboard-home.php         # Shared home component
│   └── {role}-body.php            # Legacy full dashboard (can be archived)
└── api/
    ├── {role}/
    │   ├── dashboard.php          # Home dashboard data
    │   └── {feature}.php          # Feature-specific endpoints
    ├── cases/
    │   └── search.php             # Global case search
    └── tasks/
        └── quick-add.php          # Quick task submission
```

---

## Creating a New Dashboard Feature

### Step 1: Create the API Endpoint

**File:** `app/api/{role}/{feature-name}.php`

```php
<?php
declare(strict_types=1);

require __DIR__ . '/../../lib/auth.php';
require __DIR__ . '/../../lib/db.php';

archr_require_auth();
header('Content-Type: application/json');

$pdo = archr_pdo();
$userId = $_SESSION['user_id'] ?? 0;

// Your query here
$stmt = $pdo->prepare("SELECT * FROM table WHERE user_id = :uid");
$stmt->execute([':uid' => $userId]);
$data = $stmt->fetchAll();

echo json_encode([
    'success' => true,
    'data' => $data,
], JSON_PRETTY_PRINT);
```

### Step 2: Add Menu Item

Edit `app/{role}.php` and add to the `nav` array:

```php
['href' => '#featureName', 'icon' => 'fa-icon-name', 'label' => 'Feature Label'],
```

### Step 3: Create Feature Page (Optional)

For complex features, create a dedicated page:

**File:** `app/pages/{role}/{feature-name}.php`

```php
<?php
require __DIR__ . '/../../lib/auth.php';
archr_require_auth();

require __DIR__ . '/../../lib/portal-layout.php';

// Render header, then feature content
archr_render_portal_header([...]);
?>
<section class="portal-page">
    <!-- Your feature UI here -->
</section>
<?php
archr_render_portal_footer();
```

---

## Dashboard Home Variables

The `dashboard-home.php` component expects these variables:

```php
$userName = 'John Doe';           // User's full name
$roleLabel = 'Project Manager';   // Role display name
$stats = [                         // Key-value pairs of stats
    'active_projects' => 8,
    'unclaimed_jobs' => 5
];
$alerts = [                        // Array of alert items
    [
        'icon' => 'fa-bell',
        'title' => 'Alert Title',
        'message' => 'Alert message text',
        'display_time' => 'Dec 6, 3:45 PM',
        'severity' => 'high'       // Optional
    ]
];
$apiEndpoint = 'api/{role}/dashboard.php';  // API endpoint for this role
```

---

## API Response Format

All API endpoints should return JSON in this format:

```json
{
  "success": true,
  "data": [...],
  "count": 10,
  "message": "Optional message"
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error description"
}
```

---

## Common Patterns

### Loading User Info
```php
$userStmt = $pdo->prepare("SELECT full_name, email FROM system_users WHERE id = :uid");
$userStmt->execute([':uid' => $userId]);
$user = $userStmt->fetch() ?: ['full_name' => 'User', 'email' => ''];
```

### Formatting Dates
```php
$dt = new DateTimeImmutable($dbDate);
$formatted = [
    'date' => $dt->format('Y-m-d'),
    'time' => $dt->format('g:i A'),
    'display_time' => $dt->format('M j, g:i A'),
];
```

### Alert Structure
```php
$alerts = array_map(function($row) {
    return [
        'type' => 'alert_type',
        'icon' => 'fa-icon',
        'title' => 'Title',
        'message' => 'Message text',
        'display_time' => 'Formatted time',
    ];
}, $dbRows);
```

---

## Testing Your Changes

1. **Test Authentication:** Ensure endpoint redirects when not logged in
2. **Test Data:** Verify correct data is returned
3. **Test Permissions:** Ensure users only see their own data
4. **Test Error Cases:** Handle missing data, invalid input, etc.
5. **Test UI:** Check dashboard home displays correctly
6. **Test Navigation:** Verify menu items work

---

## Database Best Practices

### Use Prepared Statements
```php
// ✅ Good
$stmt = $pdo->prepare("SELECT * FROM table WHERE id = :id");
$stmt->execute([':id' => $id]);

// ❌ Bad (SQL injection risk)
$stmt = $pdo->query("SELECT * FROM table WHERE id = $id");
```

### Type Casting
```php
// Always cast to expected types
$id = (int)$row['id'];
$amount = (float)$row['amount'];
$name = (string)$row['name'];
```

### Handle Null Values
```php
$user = $stmt->fetch() ?: ['full_name' => 'User', 'email' => ''];
$value = $row['value'] ?? 'default';
```

---

## Debugging

### Enable Error Display (Development Only)
```php
error_reporting(E_ALL);
ini_set('display_errors', '1');
```

### Log to Console (API)
```php
error_log(print_r($data, true));
```

### Check Browser Console
API responses and JavaScript errors appear in browser console

---

## Next Steps

See `DASHBOARD_REFACTORING.md` for:
- Overall architecture
- Benefits of the new structure
- Migration guide
- Future improvements
