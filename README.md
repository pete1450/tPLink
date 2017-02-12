#tPLink
Interacting with TPlink home automation products via perl

I haven't taken the time to fiddle with(learn) python but the only examples of controlling TP-Link products are written in it. This is my messy implementation in perl. Will be implementing the full set of commands but starting this reporitory with what I got working in one night.

This code currently works with the LB100 and LB130 bulbs. HS100 switch commands are in there and will be implemented shortly.

Based on and many thanks to:  
[softScheck](https://github.com/softScheck/tplink-smartplug)  
[GadgetReactor](https://github.com/GadgetReactor/pyHS100)

##Install
*Place the contents of the lib dir in your perl lib location. For instance mine is /usr/local/share/perl/5.20.2. I included JSON because I had to install it. If you already have it just ignore it.
*Place the perl script in a cgi dir that is set up to run perl scripts

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
All commands require the ip to be sent. Anything else is noted.
*identify
***set_alias** returns new alias
 *alias
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*


##TODO
*Add discovery
*Use discovery to allow commands by device name instead of ip



