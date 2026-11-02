In order for me to work on components, I need to have a working unified auth. This would mean that when you log into different account types, we reliably get different routes and dashboards. i am going to do this in v2-archr. 

Consolidating the auth by hand and migrating to Nuxt is an awesome step, but that should happen in a branch, because it will break a lot of things. And it won't be useful till it is complete. I am not going to push a new version of v2-archr until a branch has been started and the last update has been effectively pulled.

I was worried that doing the unified auth would break a lot of things, but now I'm not so worried about it. Here's the plan I have:

1) Create a simple PHP page at portal/role-check.php. Whenever you are logged in, you can go here, and it will give you a simple text display "You are logged in as [name], role: [role], level [level] permission, with the following capabilities: [list]"
2) Then we can make accounts and test them at different levels and ensure the routing and dashboard directing is solid.
3) Then we can mess with login.php and auth.php's redirect to go to the right place based on role-level
4) Then we can migrate Super Admin Dashboard from the PHP backend to the Vue. 
5) Give SuperAdmin the ability to modify account permissions from user management. This would have account levels, roles, and permissions by checkbox or radio button. Some would be immutable, but still displayed. This would mostly be for level 1 custom permissions. 
6) Then we can build the subcontractor portal with Marketplace as default, where they can claim tasks, submit and bid on quotes, set dates, upload photos, and submit invoices.
7) Then we can build a volunteer portal (level 0/level 1) with a welcome message, available quests/tasks, active quests, personal info, and hour logging