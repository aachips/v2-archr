# ARCHR Intake Form - Quick Testing Guide

## Prerequisites

1. **Database Setup**
   ```bash
   # Apply schema updates
   psql -d archr -f sql/add/requestor-account-link.sql
   ```

2. **Environment Configuration**
   Create/update `.env` file:
   ```env
   APP_ENV=development
   APP_URL=http://localhost
   ADMIN_ALERT_EMAILS=test@example.com
   ```

## Quick Test Scenarios

### Test 1: Basic Form Submission
**Goal:** Verify complete submission workflow

1. Open `app/intake.php` in browser
2. Fill out minimum required fields:
   - Welcome: "No, I am the applicant"
   - Consent: Check agreement
   - Contact: First name, last name, email, phone
   - Address: Home address, city, state, zip
   - Home: Select "owns home"
   - Repairs: Add at least one repair with urgency level
   - FEMA/Insurance: Select options
   - Income: Enter or select "no income"
   - Sign
3. Submit form
4. **Expected Result:**
   - Success page appears
   - Case number displayed
   - Credentials box shows username/password
   - Check logs:
     ```bash
     tail app/logs/emails.log
     tail app/logs/intake-submissions.jsonl
     ```

### Test 2: Progress Saving
**Goal:** Verify auto-save functionality

1. Open form, fill first 3 pages
2. Close browser tab
3. Reopen `app/intake.php`
4. **Expected Result:** Prompt to restore progress
5. Click "OK"
6. **Expected Result:** Form restored to page 3 with all data

### Test 3: Copy Credentials
**Goal:** Test credential display and copy buttons

1. Complete submission
2. On confirmation page, click "Copy" next to username
3. Paste into notepad
4. **Expected Result:** Username copied correctly
5. Repeat for password

### Test 4: Database Verification
**Goal:** Verify data written correctly

After submission, run:
```sql
-- Check submission created
SELECT id, applicant_first_name, applicant_last_name, case_number 
FROM intake_submissions 
ORDER BY id DESC LIMIT 1;

-- Check account created
SELECT id, username, email, full_name 
FROM system_users 
WHERE id = (
  SELECT requestor_user_id FROM intake_submissions 
  ORDER BY id DESC LIMIT 1
);

-- Check role assigned
SELECT u.username, r.role_name 
FROM system_users u
JOIN user_role_assignments ura ON u.id = ura.user_id
JOIN roles r ON ura.role_id = r.id
WHERE u.id = (
  SELECT requestor_user_id FROM intake_submissions 
  ORDER BY id DESC LIMIT 1
);

-- Check eligibility ran
SELECT id, submission_status, eligibility_checked_at 
FROM intake_submissions 
ORDER BY id DESC LIMIT 1;
```

### Test 5: Eligibility Scenarios

**Scenario A: Eligible (Low Income, Urgent)**
- Household size: 2
- Income: $30,000
- Urgent conditions: Check "unable to stay in home"
- **Expected:** `submission_status = 'eligible'`

**Scenario B: High Income (Over AMI)**
- Household size: 2  
- Income: $100,000
- **Expected:** `submission_status = 'needs_review'`

**Scenario C: Priority Scoring**
- Check multiple urgent conditions
- Mark as Helene-related
- **Expected:** Higher priority score (check logs)

### Test 6: Error Handling

**Test Database Failure:**
1. Stop PostgreSQL: `pg_ctl stop`
2. Try to submit form
3. **Expected:** "Database unavailable" error
4. Start PostgreSQL: `pg_ctl start`
5. Resubmit (data should be saved from auto-save)
6. **Expected:** Success

## Development Mode Features

### Email Logging
Instead of sending emails, check `app/logs/emails.log`:
```bash
tail -f app/logs/emails.log
```

You should see:
1. Requestor confirmation email with credentials
2. Admin alert email(s)

### Submission Logging
All submissions logged to `app/logs/intake-submissions.jsonl`:
```bash
tail -f app/logs/intake-submissions.jsonl | jq
```

### Airtable Retry Queue
If Airtable write fails, check retry queue:
```bash
cat app/logs/airtable-retry-queue.jsonl | jq
```

## Common Issues & Solutions

### Issue: "Submission Processing Failed"
**Causes:**
1. Database connection error
2. Missing required PHP extensions
3. Permissions on `app/logs/` directory

**Solutions:**
```bash
# Check logs
tail app/logs/intake-submissions.jsonl

# Check PHP error log
tail /var/log/php-fpm/error.log  # or php_errors.log

# Fix log directory permissions
chmod 755 app/logs
```

### Issue: Credentials not showing
**Cause:** Account creation failed (non-fatal)

**Solution:**
Check error log for account creation failure reason:
```bash
grep "AccountCreation" /var/log/php-fpm/error.log
```

Common causes:
- REQUESTOR role doesn't exist
- Database permissions
- Email already exists

### Issue: Progress not saving
**Cause:** localStorage blocked or disabled

**Solution:**
- Check browser console for errors
- Ensure cookies/storage enabled
- Try different browser

## Production Deployment Checklist

Before going live:
- [ ] Set `APP_ENV=production`
- [ ] Configure real SMTP settings
- [ ] Update `ADMIN_ALERT_EMAILS` with real emails
- [ ] Set correct `APP_URL`
- [ ] Configure Airtable API key (if using)
- [ ] Test email sending (send test email)
- [ ] Review AMI thresholds in `app/lib/eligibility.php`
- [ ] Update service area cities/zips
- [ ] Clear old test data from database
- [ ] Set up log rotation for `app/logs/`
- [ ] Configure backup for PostgreSQL
- [ ] Test full workflow end-to-end

## Performance Testing

### Load Test
Use Apache Bench or similar:
```bash
# Test form page load
ab -n 100 -c 10 http://localhost/app/intake.php

# Test submission endpoint (requires JSON payload)
ab -n 50 -c 5 -p test-payload.json -T application/json \
  http://localhost/app/api/submit.php
```

### Database Performance
Monitor slow queries:
```sql
-- Enable query logging
ALTER DATABASE archr SET log_min_duration_statement = 100;

-- Check slow queries
SELECT query, calls, total_time, mean_time
FROM pg_stat_statements
WHERE mean_time > 100
ORDER BY mean_time DESC;
```

## Support & Troubleshooting

Check these in order:
1. Browser console (F12) for JavaScript errors
2. `app/logs/intake-submissions.jsonl` for submission data
3. `app/logs/emails.log` for email activity
4. PHP error log for server-side errors
5. PostgreSQL log for database errors
6. Network tab (F12) to see API response

For help, include:
- Error message (exact text)
- Browser console errors
- Last 10 lines from relevant log files
- Steps to reproduce
