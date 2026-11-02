# Dashboard Testing Checklist

## Pre-Testing Setup

- [ ] Database is up and running
- [ ] Web server (Apache/Nginx) is running
- [ ] PHP is configured correctly
- [ ] Session handling is working
- [ ] Test users exist for each role

---

## Common Features (All Roles)

### Dashboard Home Component

- [ ] Welcome message displays with user's first name
- [ ] Current date displays correctly
- [ ] Role label shows correctly
- [ ] Primary stat displays (role-specific count)

### Alerts Panel

- [ ] Alerts section displays when alerts exist
- [ ] Up to 5 alerts are shown
- [ ] Each alert has icon, title, message, and time
- [ ] "View all" link is present
- [ ] Empty state shows when no alerts

### Case Search

- [ ] Search input field is visible
- [ ] Search button is clickable
- [ ] Filter buttons display (All cases, My cases, Recent, Urgent)
- [ ] Active filter is highlighted
- [ ] Clicking filter toggles active state
- [ ] Search returns results when query is entered
- [ ] Search handles empty results gracefully
- [ ] Invalid queries show appropriate message

### Quick Task Box

- [ ] Task type dropdown shows all options (Task, Event, Log, Note)
- [ ] Description textarea accepts input
- [ ] Submit button is enabled
- [ ] Clear button resets form
- [ ] Form validation works (required fields)
- [ ] Successful submission shows confirmation
- [ ] Error handling displays errors properly
- [ ] Task is added to database (`task_rabbit_queue` table)

---

## API Endpoints Testing

### Common Endpoints

**Case Search** (`/api/cases/search.php`)
- [ ] Returns 401 when not authenticated
- [ ] Returns empty results for no matches
- [ ] Returns correct results for valid query
- [ ] Respects filter parameter (all, my_cases, recent, urgent)
- [ ] Returns proper JSON format
- [ ] Handles special characters in query

**Quick Task** (`/api/tasks/quick-add.php`)
- [ ] Returns 405 for non-POST requests
- [ ] Validates task_type parameter
- [ ] Validates task_text parameter
- [ ] Returns 400 for invalid input
- [ ] Returns 200 and success for valid input
- [ ] Creates record in database

---

## Role-Specific Testing

### Assessor Dashboard

**Home Page** (`assessor.php`)
- [ ] Page loads without errors
- [ ] User territory displays in badge
- [ ] Today's assessment count shows correctly
- [ ] Upcoming alerts display (next 7 days)

**API Endpoints:**
- [ ] `/api/assessor/dashboard.php` returns user info and stats
- [ ] `/api/assessor/today.php` returns today's assessments
- [ ] `/api/assessor/upcoming.php` returns future assessments
- [ ] `/api/assessor/previous.php` returns completed assessments

**Menu Navigation:**
- [ ] Dashboard link goes to home
- [ ] All menu items are clickable
- [ ] Active state highlights correctly

### Project Manager Dashboard

**Home Page** (`project-manager.php`)
- [ ] Page loads without errors
- [ ] Active projects count displays
- [ ] Unclaimed jobs count displays
- [ ] Recent escalations show as alerts

**API Endpoints:**
- [ ] `/api/project-manager/dashboard.php` returns correct data
- [ ] `/api/project-manager/projects.php` returns active projects
- [ ] `/api/project-manager/unclaimed.php` returns unclaimed jobs
- [ ] `/api/project-manager/escalations.php` returns escalations

**Menu Navigation:**
- [ ] All menu groups display correctly
- [ ] Grouped menu items are organized properly

### Crew Lead Dashboard

**Home Page** (`crew-lead.php`)
- [ ] Page loads without errors
- [ ] Active jobs count displays
- [ ] Today's jobs count displays
- [ ] Upcoming jobs show in alerts

**API Endpoints:**
- [ ] `/api/crew-lead/dashboard.php` returns correct stats
- [ ] `/api/crew-lead/current-job.php` returns active job details
- [ ] Returns null when no current job

### Other Roles

**Crew Member:**
- [ ] `/api/crew-member/dashboard.php` returns data

**Bursar:**
- [ ] `/api/bursar/dashboard.php` returns pending payments

**Volunteer:**
- [ ] `/api/volunteer/dashboard.php` returns available slots

**Subcontractor:**
- [ ] `/api/subcontractor/dashboard.php` returns quote requests

**Envoy:**
- [ ] `/api/envoy/dashboard.php` returns new applications

---

## Browser Compatibility

- [ ] Chrome/Edge (latest)
- [ ] Firefox (latest)
- [ ] Safari (latest)
- [ ] Mobile browsers (iOS Safari, Chrome Mobile)

---

## Responsive Design

- [ ] Dashboard home displays correctly on desktop (1920px)
- [ ] Dashboard home displays correctly on tablet (768px)
- [ ] Dashboard home displays correctly on mobile (375px)
- [ ] Sidebar menu collapses on mobile
- [ ] Search and quick task form are usable on mobile

---

## Security Testing

- [ ] Unauthenticated users are redirected to login
- [ ] Users can only access their own data
- [ ] SQL injection is prevented (prepared statements)
- [ ] XSS is prevented (proper escaping)
- [ ] CSRF tokens are used on forms (if implemented)

---

## Performance

- [ ] Dashboard home loads in < 2 seconds
- [ ] API endpoints respond in < 1 second
- [ ] No N+1 query problems
- [ ] Database queries use indexes
- [ ] Large result sets are paginated

---

## Error Handling

- [ ] Database connection errors show gracefully
- [ ] Missing data shows empty states
- [ ] API errors return proper HTTP codes
- [ ] JavaScript errors are caught and logged
- [ ] PHP errors don't expose sensitive info

---

## Accessibility

- [ ] All interactive elements are keyboard accessible
- [ ] Form labels are associated with inputs
- [ ] ARIA labels are present where needed
- [ ] Color contrast meets WCAG standards
- [ ] Screen reader can navigate the page

---

## Testing Tools

### Manual Testing
- Browser DevTools (Network, Console, Elements)
- Multiple browsers and devices
- Test user accounts for each role

### Automated Testing (Optional)
- PHPUnit for API endpoint testing
- Jest/Cypress for frontend testing
- Selenium for end-to-end testing

---

## Issue Tracking

When you find issues, document:
- [ ] What you were doing
- [ ] What you expected to happen
- [ ] What actually happened
- [ ] Browser and device info
- [ ] Console errors (if any)
- [ ] Network errors (if any)

---

## Sign-Off

Once all tests pass:

- [ ] All common features work across all roles
- [ ] All API endpoints return correct data
- [ ] All role dashboards display correctly
- [ ] Documentation is complete and accurate
- [ ] Code is committed to version control
- [ ] Deployment checklist is ready

**Tested By:** _________________  
**Date:** _________________  
**Status:** ☐ Pass  ☐ Fail (see issues)
