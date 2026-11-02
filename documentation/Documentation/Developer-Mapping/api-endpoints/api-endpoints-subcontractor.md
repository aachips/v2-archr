## API Endpoints for Subcontractor

|Endpoint|Method|Purpose|
|---|---|---|
|`/api/subcontractor/dashboard`|GET|Dashboard data|
|`/api/subcontractor/tasks/accepted`|GET|Accepted tasks list|
|`/api/subcontractor/tasks/suggested`|GET|Suggested tasks list|
|`/api/subcontractor/tasks/:id`|GET|Single task detail|
|`/api/subcontractor/tasks/claim`|POST|Claim a task|
|`/api/subcontractor/tasks/accept`|POST|Accept a task|
|`/api/subcontractor/tasks/:id/status`|PUT|Update task status|
|`/api/subcontractor/tasks/:id/dates`|PUT|Set estimate/work dates|
|`/api/subcontractor/tasks/:id/photos`|POST|Upload after photos|
|`/api/subcontractor/quote`|POST|Submit quote|
|`/api/subcontractor/invoice`|POST|Submit invoice|
|`/api/subcontractor/communications`|GET|Get messages|
|`/api/subcontractor/communications/:id`|PUT|Mark message read|
|`/api/subcontractor/communications`|POST|Send message|
|`/api/subcontractor/past-jobs`|GET|Past jobs history|