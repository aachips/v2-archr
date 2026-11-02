,dcmdPoint app towards PostgreSQL on global variables  

![[psql-database-connection.png]]

on php.ini, find line or add if missing: extension=pdo_pgsql
make sure not commented out at start with a semicolon / ;
also uncomment out extension=pgsql

```dataview 
LIST FROM "Welcome" SORT file.name ASC 
```
