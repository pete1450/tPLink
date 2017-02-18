#tPLink
Interacting with TPlink home automation products via local web requests.

I got annoyed that I couldn't tie all the tp-link bulbs and plugs into my home automation so I decided to do something about it. I wrote a perl module that I threw on my pi3 which does the socket communication directly to the devices; no TP-link middleman. Then there is a cgi script so you can make web requests from any home automation device or webpage you want.

This code currently works with the LB100 and LB130 bulbs as well as the HS100 switch

Based on and many thanks to:  
[softScheck](https://github.com/softScheck/tplink-smartplug)  
[GadgetReactor](https://github.com/GadgetReactor/pyHS100)

##Install
* Place the contents of the lib dir in your perl lib location. For instance mine is /usr/local/share/perl/5.20.2. I included JSON because I had to install it. If you already have it just ignore it.
* Place the perl script in a cgi dir that is set up to run perl scripts

##Usage
Call the script with a command name, ip address of your device, and any relevent data for setters.  
Commands that return multiple data points do so as one key:value per line
###Example 1  
http://mywebserver.com/tplinkrelay.pl?cmd=identify&ip=192.168.1.165  
returns  
alias:Upstairs Lamp
model:HS110(US)

###Example 2
http://mywebserver.com/tplinkrelay.pl?cmd=set_plug_state&ip=192.168.1.165&state=0
Turns the plug off and should return new state(doesn't... bug)

##Available commands
All commands require the ip to be sent unless noted. Anything else is required is a subitem.
* **identify**
* **list_devices** returns newline separated ip,alias pairs that were discovered
* **set_alias** returns new alias
 * alias
* **get_emeter_realtime**
* **get_emeter_daily**
* **get_emeter_monthly**
* **erase_emeter_stats**
* **get_bulb_sysinfo**
* **set_bulb_state** Returns 1 for on, 0 for off
 * status
* **get_bulb_state** Returns multiple items
* **set_white_temp**
 * temp (in K i.e. 3000K)
* **get_color_temp** returns temp in K
* **get_hsv** Returns hue(0-255), saturation(0-100), and value(0-100)
* **set_hsv** Returns the new setpoints
 * hue
 * sat
 * val
* **set_bulb_red** Turns the bulb red at full brightness
* **set_bulb_green** Turns the bulb green at full brightness
* **set_bulb_blue** Turns the bulb blue at full brightness
* **set_brightness** Returns new brightness
 * brightness
* **get_brightness** Returns brightness(0-100)
* **get_plug_sysinfo** Returns all plug info
* **set_plug_state**
 * state (1 for on, 0 for off)
* **set_state_by_name** no ip needed. returns -1 if name not found
 * name 
* **plug_is_off** Returns 1 for true, 0 for false
* **plug_is_on** Returns 0 for true, 1 for false
* **turn_plug_on** Returns 1 for new status
* **turn_plug_off** Returns 0 for new status
* **plug_has_emeter** Returns 1 for true, 0 for false
* **get_plug_led** Returns 1 for on, 0 for off
* **set_plug_led** Returns 1/0 for new status
 * status
* **plug_on_since** Returns datetime i.e. 2017-02-12T03:01:22


##TODO
*Add discovery
*Use discovery to allow commands by device name instead of ip
*error checking and response(-1?)




