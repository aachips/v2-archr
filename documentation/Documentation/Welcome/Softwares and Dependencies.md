These are the softwares and dependencies needed to run or host this. As it migrates to a live server / VPS, keeping this list is helpful for developers involved, and to anyone curious.

So far here is a list of what we have installed on this computer to have this work:

### Laragon (226MB) 
This is a local development environment that allows for quick configurations and easy use among the entire network. 

The root folder for this is at C:/laragon

Here are a list of setting configurations: 
+ Apache, MySQL, and Mailpit are allowed through the firewalls for "Private Networks" and "Public Networks"
+ For the network binding on Apache, httpd.conf is changed from 'Require all denied' to 'Require all granted' on line 243. This allows anyone on the office network to access the local sites hosted.
+ This computer's IP address, which can be used to access local sites through the browser, is 192.168.1.119

### Obsidian.md (336MB)

This is just a fancy, free, open source note management tool where I can write this tutorial maze easily. It is not critical for the functioning of the prototype.

### Visual Studio Code (245MB)

VS Code is an industry standard for editing and modifying code bases. Since this prototype is built in code, and it may require editing or altering, this is the safest most recognized standard to do so.

### PostgreSQL V18

This is what the future database / migration from Airtable will run on. The program is already written for both. 

```dataview 
LIST FROM "Welcome" SORT file.name ASC 
```
