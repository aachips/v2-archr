open Command Prompt by pressing 🪟+R and entering "cmd"

run command "ipconfig" and note your device's IPv4 Address
and Default Gateway:
![[ipconfig-highlight.png]]


On a browser, go to your Default Gateway Address:
![[ip-browser-url.png]]
And log in to your Router Admin Portal (this may look different for your specific router)

![[router-login.png]]

In your router's settings, look for "DNS Host Mapping", "DNS settings" or a similar option:
![[mesh-topology.png]] 
Add your device IPv4 address as the URL you want to use to access the ARCHR Internal Portal:
![[hostname-ip-address.png]]

Click apply, now all calls to "v2-archr.test" will route to your device instead of trying to find that URL on the open internet for all devices on this Network:

![[archr-site-header.png]]Make sure to save any changes in your router before closing the page.

```dataview 
LIST FROM "Welcome" SORT file.name ASC 
```
