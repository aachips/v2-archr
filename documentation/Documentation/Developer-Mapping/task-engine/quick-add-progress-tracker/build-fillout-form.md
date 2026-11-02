## Fillout Form Configuration

### Form Name: Quick Add Progress Task

### Fields (Conditional):

1. **Case Selection**
   - Type: Dropdown (from Project Records)
   - Filter: Cases assigned to current org
   - Required: Yes

2. **Task Type**
   - Type: Dropdown (dynamic based on display conditions)
   - Options: ASSESS, SCOPE, START, COMPLETE, PROGRESS
   - Required: Yes
   - Visibility: Based on displayClaim, displayAssess, displayScope, displayStart, displayComplete

3. **Date**
   - Type: Date Picker
   - Default: Today
   - Required: Yes
   - Visibility: All task types

4. **Notes**
   - Type: Text Area
   - Required: No
   - Visibility: ASSESS, START, COMPLETE

5. **Photos Upload**
   - Type: File Upload (multiple)
   - Accepted: JPG, PNG, HEIC
   - Max: 10 files
   - Visibility: ASSESS, COMPLETE

6. **Scope Table**
   - Type: Table (Task, Location, Cost)
   - Visibility: SCOPE
   - Required: No (but encouraged)

7. **Contract Upload**
   - Type: File Upload
   - Visibility: START
   - Required: No

8. **Certificate Upload**
   - Type: File Upload
   - Visibility: COMPLETE
   - Required: Yes

9. **After Photos Upload**
   - Type: File Upload (multiple)
   - Visibility: COMPLETE
   - Required: No

### Webhooks:
- On Submit: POST to /api/progress/quick-add
- On Document Upload: POST to /api/documents/upload