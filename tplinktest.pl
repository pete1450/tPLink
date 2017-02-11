use strict;
use Socket qw(PF_INET SOCK_STREAM pack_sockaddr_in inet_aton);
use Getopt::ArgParse;
use bytes;
use JSON qw( decode_json );
use DateTime;

my $reply;
my $debug = 1;

my $plugip = '192.168.1.165';
#my $ip = '192.168.1.129';
my $bulbip = '192.168.1.194';



executeAllPlugCommandsTest($plugip);

#executeAllBulbCommandsTest($bulbip);



###
#
#Subroutines
#
###

##
#General commands
##


sub identify{
	my $ip = shift;
	my $command = '{"system":{"get_sysinfo":{}}}';
	my $return = sendcmd($ip, "$command");
	my %returnHash;
	print "model: " . $return->{'system'}{'get_sysinfo'}{'model'} . "\n" if $debug;
	print "alias: " . $return->{'system'}{'get_sysinfo'}{'alias'} . "\n" if $debug;
	$returnHash{"model"} = $return->{'system'}{'get_sysinfo'}{'model'};
	$returnHash{"alias"} = $return->{'system'}{'get_sysinfo'}{'alias'};
	return %returnHash;
}

sub set_alias{
	my $ip = shift;
	my $alias = shift;
	my $command = '{"system":{"set_dev_alias":{"alias":"' . $alias . '"}}}';
	my $return = sendcmd($ip, "$command");
	return $return;
}

sub get_emeter_realtime{
	my $ip = shift;
	my $command = '{"smartlife.iot.common.emeter":{"get_realtime":{}}}';
	my $return = sendcmd($ip, "$command");
	return $return;
}

sub get_emeter_daily{
	my $ip = shift;
	my $command = '{"smartlife.iot.common.emeter":{"get_daystat":{"month":1,"year":2017}}}';
	my $return = sendcmd($ip, "$command");
	return $return;
}

sub get_emeter_monthly{
	my $ip = shift;
	my $command = '{"smartlife.iot.common.emeter":{"get_monthstat":{"year":2017}}}';
	my $return = sendcmd($ip, "$command");
	return $return;
}

sub erase_emeter_stats{
	my $ip = shift;
	my $command = '{"smartlife.iot.common.emeter":{"erase_emeter_stat":{}}}';
	my $return = sendcmd($ip, "$command");
	return $return;
}


##
#Bulb Related commands
##

#returns hash of values
sub get_bulb_sysinfo{
	my $ip = shift;
	my %returnHash;
	my $command = '{"system":{"get_sysinfo":{}}}';
	my $returned = sendcmd($ip, "$command");
	$returnHash{'sw_ver'} = $returned->{'system'}{'get_sysinfo'}{'sw_ver'};
	$returnHash{'hw_ver'} = $returned->{'system'}{'get_sysinfo'}{'hw_ver'};
	$returnHash{'model'} = $returned->{'system'}{'get_sysinfo'}{'model'};
	$returnHash{'alias'} = $returned->{'system'}{'get_sysinfo'}{'alias'};
	$returnHash{'description'} = $returned->{'system'}{'get_sysinfo'}{'description'};
	$returnHash{'mic_type'} = $returned->{'system'}{'get_sysinfo'}{'mic_type'};
	$returnHash{'dev_state'} = $returned->{'system'}{'get_sysinfo'}{'dev_state'};
	$returnHash{'mic_mac'} = $returned->{'system'}{'get_sysinfo'}{'mic_mac'};
	$returnHash{'deviceId'} = $returned->{'system'}{'get_sysinfo'}{'deviceId'};
	$returnHash{'oemId'} = $returned->{'system'}{'get_sysinfo'}{'oemId'};
	$returnHash{'hwId'} = $returned->{'system'}{'get_sysinfo'}{'hwId'};
	$returnHash{'is_factory'} = $returned->{'system'}{'get_sysinfo'}{'is_factory'};
	$returnHash{'disco_ver'} = $returned->{'system'}{'get_sysinfo'}{'disco_ver'};
	$returnHash{'ctrl_protocols_name'} = $returned->{'system'}{'get_sysinfo'}{'ctrl_protocols'}{'name'};
	$returnHash{'ctrl_protocols_version'} = $returned->{'system'}{'get_sysinfo'}{'ctrl_protocols'}{'version'};
	$returnHash{'light_state_on_off'} = $returned->{'system'}{'get_sysinfo'}{'light_state'}{'on_off'};
	$returnHash{'light_state_mode'} = $returned->{'system'}{'get_sysinfo'}{'light_state'}{'mode'};
	$returnHash{'light_state_hue'} = $returned->{'system'}{'get_sysinfo'}{'light_state'}{'hue'};
	$returnHash{'light_state_saturation'} = $returned->{'system'}{'get_sysinfo'}{'light_state'}{'saturation'};
	$returnHash{'light_state_color_temp'} = $returned->{'system'}{'get_sysinfo'}{'light_state'}{'color_temp'};
	$returnHash{'light_state_brightness'} = $returned->{'system'}{'get_sysinfo'}{'light_state'}{'brightness'};
	$returnHash{'is_dimmable'} = $returned->{'system'}{'get_sysinfo'}{'is_dimmable'};
	$returnHash{'is_color'} = $returned->{'system'}{'get_sysinfo'}{'is_color'};
	$returnHash{'is_variable_color_temp'} = $returned->{'system'}{'get_sysinfo'}{'is_variable_color_temp'};

	### Seems like there's a better way to do this... don't care for now
	# print "preferred_state->\n";
	# my @prefArr = @{$returned->{'system'}{'get_sysinfo'}{'preferred_state'}};
	# foreach(@prefArr)
	# {
		# my %tmphash = %{$_};
		# print "\t";
		# $returnHash("preferred_state_index"} = $tmphash{index};
		# $returnHash("preferred_state_hue"} = $tmphash{hue};
		# $returnHash("preferred_state_saturation"} = $tmphash{saturation};
		# $returnHash("preferred_state_color_temp"} = $tmphash{color_temp};
		# $returnHash("preferred_state_brightness"} = $tmphash{brightness};
		# print "\n";
	# }

	$returnHash{'rssi'} = $returned->{'system'}{'get_sysinfo'}{'rssi'};
	$returnHash{'active_mode'} = $returned->{'system'}{'get_sysinfo'}{'active_mode'};
	$returnHash{'heapsize'} = $returned->{'system'}{'get_sysinfo'}{'heapsize'};
	$returnHash{'err_code'} = $returned->{'system'}{'get_sysinfo'}{'err_code'};
	return %returnHash;
}

#1 = on
#0 = off
#returns new status of light
sub set_bulb_state{
	my $ip = shift;
	my $status = shift;
	my $command = '{"smartlife.iot.smartbulb.lightingservice":{"transition_light_state":{"on_off":' . $status . '}}}';
	my $return = sendcmd($ip, "$command");
	my $reply = $return->{'smartlife.iot.smartbulb.lightingservice'}{'transition_light_state'}{'on_off'};
	return $reply;
}

#returns hash of state info
sub get_bulb_state{
	my $ip = shift;
	my $status = shift;
	my $command = '{"smartlife.iot.smartbulb.lightingservice":{"get_light_state":{}}}';
	my $return = sendcmd($ip, "$command");
	my %reply;
	$reply{'on_off'} = $return->{'smartlife.iot.smartbulb.lightingservice'}{'get_light_state'}{'on_off'};
	$reply{'mode'} = $return->{'smartlife.iot.smartbulb.lightingservice'}{'get_light_state'}{'mode'};
	$reply{'hue'} = $return->{'smartlife.iot.smartbulb.lightingservice'}{'get_light_state'}{'hue'};
	$reply{'saturation'} = $return->{'smartlife.iot.smartbulb.lightingservice'}{'get_light_state'}{'saturation'};
	$reply{'color_temp'} = $return->{'smartlife.iot.smartbulb.lightingservice'}{'get_light_state'}{'color_temp'};
	$reply{'brightness'} = $return->{'smartlife.iot.smartbulb.lightingservice'}{'get_light_state'}{'brightness'};
	return %reply;
}

#only works if bulb is on
sub set_white_temp{
	my $ip = shift;
	my $temp = shift;
	my $command = '{"smartlife.iot.smartbulb.lightingservice":{"transition_light_state":{"color_temp":' . $temp . '}}}';
	my $return = sendcmd($ip, "$command");
	my $reply = $return->{'smartlife.iot.smartbulb.lightingservice'}{'transition_light_state'}{'color_temp'};
	return $reply;
}

#returns hash of state info
sub get_color_temp{
	my $ip = shift;
	my $status = shift;
	my $command = '{"smartlife.iot.smartbulb.lightingservice":{"get_light_state":{}}}';
	my $return = sendcmd($ip, "$command");
	my $reply = $return->{'smartlife.iot.smartbulb.lightingservice'}{'get_light_state'}{'color_temp'};
	return $reply;
}

#HSV- h values 0-255, other 0-100 #imnocolorexpert so  #thismaybeincorrect
#returns hash of hsv
sub get_hsv{
	my $ip = shift;
	my %reply = get_bulb_state($ip);
	my %return;
	$return{'hue'} = $reply{'hue'};
	$return{'saturation'} = $reply{'saturation'};
	$return{'value'} = $reply{'brightness'};
	return %return;
}


sub set_hsv{
	my $ip = shift;
	my $h = shift;
	my $s = shift;
	my $v = shift;
	my $command = '{"smartlife.iot.smartbulb.lightingservice":{"transition_light_state":{"hue":' . $h . ',"saturation":' . $s . ',"brightness":' . $v . ',"color_temp":0}}}';
	my $return = sendcmd($ip, "$command");
	my %reply;
	$reply{'hue'} = $return->{'smartlife.iot.smartbulb.lightingservice'}{'transition_light_state'}{'hue'};
	$reply{'saturation'} = $return->{'smartlife.iot.smartbulb.lightingservice'}{'transition_light_state'}{'saturation'};
	$reply{'value'} = $return->{'smartlife.iot.smartbulb.lightingservice'}{'transition_light_state'}{'brightness'};
	return %reply;
}

sub set_bulb_red{
	my $ip = shift;
	set_hsv($ip, 0, 100, 100);
}

sub set_bulb_green{
	my $ip = shift;
	set_hsv($ip, 120, 100, 100);
}

sub set_bulb_blue{
	my $ip = shift;
	set_hsv($ip, 200, 100, 100);
}

sub set_brightness{
	my $ip = shift;
	my $brightness = shift;
	my $command = '{"smartlife.iot.smartbulb.lightingservice":{"transition_light_state":{"brightness":' . $brightness . '}}}';
	my $return = sendcmd($ip, "$command");
	my $reply = $return->{'smartlife.iot.smartbulb.lightingservice'}{'transition_light_state'}{'brightness'};
	return $reply;
}

sub get_brightness{
	my $ip = shift;
	my %reply = get_bulb_state($ip);
	my $return;
	$return = $reply{'brightness'};
	return $return;
}


##
#Bulb Related commands
##

sub get_plug_sysinfo{
	my $ip = shift;
	my %returnHash;
	my $command = '{"system":{"get_sysinfo":{}}}';
	my $returned = sendcmd($ip, "$command");
	$returnHash{'sw_ver'} = $returned->{'system'}{'get_sysinfo'}{'sw_ver'};
	$returnHash{'hw_ver'} = $returned->{'system'}{'get_sysinfo'}{'hw_ver'};
	$returnHash{'type'} = $returned->{'system'}{'get_sysinfo'}{'type'};
	$returnHash{'model'} = $returned->{'system'}{'get_sysinfo'}{'model'};
	$returnHash{'mac'} = $returned->{'system'}{'get_sysinfo'}{'mac'};
	$returnHash{'deviceId'} = $returned->{'system'}{'get_sysinfo'}{'deviceId'};
	$returnHash{'hwId'} = $returned->{'system'}{'get_sysinfo'}{'hwId'};
	$returnHash{'fwId'} = $returned->{'system'}{'get_sysinfo'}{'fwId'};
	$returnHash{'oemId'} = $returned->{'system'}{'get_sysinfo'}{'oemId'};
	$returnHash{'alias'} = $returned->{'system'}{'get_sysinfo'}{'alias'};
	$returnHash{'dev_name'} = $returned->{'system'}{'get_sysinfo'}{'dev_name'};
	$returnHash{'icon_hash'} = $returned->{'system'}{'get_sysinfo'}{'icon_hash'};
	$returnHash{'relay_state'} = $returned->{'system'}{'get_sysinfo'}{'relay_state'};
	$returnHash{'on_time'} = $returned->{'system'}{'get_sysinfo'}{'on_time'};
	$returnHash{'active_mode'} = $returned->{'system'}{'get_sysinfo'}{'active_mode'};
	$returnHash{'feature'} = $returned->{'system'}{'get_sysinfo'}{'feature'};
	$returnHash{'updating'} = $returned->{'system'}{'get_sysinfo'}{'updating'};
	$returnHash{'rssi'} = $returned->{'system'}{'get_sysinfo'}{'rssi'};
	$returnHash{'led_off'} = $returned->{'system'}{'get_sysinfo'}{'led_off'};
	$returnHash{'latitude'} = $returned->{'system'}{'get_sysinfo'}{'latitude'};
	return %returnHash;
}

#1 = on
#0 = off
#command doesnt return status so I'm not
sub set_plug_state{
	my $ip = shift;
	my $status = shift;
	my $command = '{"system":{"set_relay_state":{"state": ' . $status . '}}}';
	my $return = sendcmd($ip, "$command");
}

sub plug_is_off{
	my $ip = shift;
	my %replyHash = get_plug_sysinfo($ip);
	my $return = $replyHash{'relay_state'};
	if($return){
	 return 0;
	}
	else{
		return 1;
	}
}

sub plug_is_on{
	my $ip = shift;
	my %replyHash = get_plug_sysinfo($ip);
	my $return = $replyHash{'relay_state'};
	if($return){
	 return 1;
	}
	else{
		return 0;
	}
}

sub turn_plug_on{
	my $ip = shift;
	my $command = '{"system":{"set_relay_state":{"state": 1}}}';
	my $return = sendcmd($ip, "$command");
}
sub turn_plug_off{
	my $ip = shift;
	my $command = '{"system":{"set_relay_state":{"state": 0}}}';
	my $return = sendcmd($ip, "$command");
}

sub plug_has_emeter{
	my $ip = shift;
	my %replyHash = get_plug_sysinfo($ip);
	my $return = $replyHash{'feature'};
	if($return =~ /ENE/){
		return 1;
	}
	else{
		return 0;
	}
}

sub get_plug_led{
	my $ip = shift;
	my %replyHash = get_plug_sysinfo($ip);
	my $return = $replyHash{'led_off'};
	if($return){
		return 0;
	}
	else{
		return 1;
	}
}

sub set_plug_led{
	my $ip = shift;
	my $status = shift;
	if($status){
		$status = 0;
	}
	else{
		$status = 1;
	}
	
	my $command = '{"system":{"set_led_off":{"off": ' . $status . '}}}';
	my $return = sendcmd($ip, "$command");
}

#returns datetime
sub plug_on_since{
	my $ip = shift;
	my %replyHash = get_plug_sysinfo($ip);
	my $return = $replyHash{'on_time'};
	my $dt = DateTime->now();
	$dt->subtract(seconds=>$return);
	return $dt;
}




#
#Communication subs
#

#returns decoded json
sub sendcmd{
	my $ip = shift;
	my $command = shift;
	my $port = 9999;
	my $paddr = pack_sockaddr_in($port, inet_aton($ip));
	my $msg;

	my $proto = getprotobyname('tcp');
	socket(my $socket, PF_INET, SOCK_STREAM, $proto) or die "socket: $!";
	connect($socket, $paddr) or die "connect: $!";
	send($socket, encrypt($command),$proto) or die $!;
	my $data;
	recv($socket, $data, 4096, $proto);
	close($socket); 

	print "Sent: $command\n" if $debug;
	my $received = substr(decrypt($data), 4);
	$received =~ s/.{1}/\{/; #always starts with a random char for some reason
	print ("Received: " . $received . "\n") if $debug;
	my $decoded = decode_json($received);
	return $decoded;
}

sub encrypt{
	my ($inString) = @_;
	my $key = 171;
	#my $result = "\0\0\0\0";
	my $result = "";
	
	$result .= pack('I>',length($inString));

	foreach my $i(split //, $inString){
		my $a = $key ^ ord($i);
		$key = $a;
		$result .= chr($a);
	}

	return $result;
}

sub decrypt{
	my ($inString) = @_;
	my $key = 171;
	my $result = "";
	foreach my $i(split //, $inString){
		my $a = $key ^ ord($i);
		$key = ord($i);
		$result .= chr($a);
	}
	return $result;
}

sub printBulbInfo{
	my $ip = shift;
	my %returnHash = get_bulb_sysinfo($ip);
	foreach (sort keys %returnHash) {
		print "$_ : $returnHash{$_}\n";
	}

}

sub executeAllPlugCommandsTest{
	my $ip = shift;
	my $return;
	
	get_plug_sysinfo($ip);
	
	set_plug_state($ip,0);
	$return = plug_is_off($ip);
	print "Plug is off? $return\n";
	sleep(1);
	set_plug_state($ip,1);
	$return = plug_is_on($ip);
	print "Plug is on? $return\n";
	sleep(1);
	set_plug_state($ip,0);
	sleep(1);
	
	turn_plug_on($ip);
	turn_plug_off($ip);
	
	$return = plug_has_emeter($ip);
	print "Has emeter: $return\n";
	
	
	set_plug_led($ip,0);
	$return = get_plug_led($ip);
	print "Plug led: $return\n";
	sleep(1);
	set_plug_led($ip,1);
	$return = get_plug_led($ip);
	print "Plug led: $return\n";
	sleep(1);
	
	$return = plug_on_since($ip);
	print "On since: $return\n";
	
	
}

sub executeAllBulbCommandsTest{

	my $ip = shift;
	my %returnHash;
	my $return;

	#print all the info
	printBulbInfo($ip);

	#get all the info
	%returnHash = get_sysinfo($ip);

	#turn a light on
	$return = set_bulb_state($ip, 1);
	print "New status: " . $return . "\n";
	#sleep(2);
	#turn a light off
	#$return = set_bulb_state($ip, 0);
	print "New status: " . $return . "\n";
	print "\n";

	my %returnHash = identify($ip);
	print "model:" . $returnHash{'model'} . " alias:" . $returnHash{'alias'} .  "\n";
	print "\n";

	##not working
	#$reply = set_alias($ip, "test");
	#$reply = set_alias($ip, "Upstairs Lamp");

	## these have long responses and break something
	#get_emeter_daily($ip);
	#get_emeter_monthly($ip);

	get_emeter_realtime($ip);

	#commented out as to be nondestructive
	#erase_emeter_stats($ip);

	%returnHash = get_bulb_state($ip);
	print "Bulb State-----\n";
	foreach (sort keys %returnHash) {
		print "$_: $returnHash{$_}\n";
	}
	print "End bulb State-----\n";
	print "\n";

	my $return = set_white_temp($ip, 2500);
	print "New white temp: $return\n";
	print "\n";
	
	%returnHash = get_hsv($ip);
	print "HSV-----\n";
	foreach (sort keys %returnHash) {
		print "$_: $returnHash{$_}\n";
	}
	print "HSV-----\n";
	print "\n";
	
	$return = get_color_temp($ip);
	print "Color temp: $return";
	
	%returnHash = set_hsv($ip, 240, 100, 100);
	print "New HSV-----\n";
	foreach (sort keys %returnHash) {
		print "$_: $returnHash{$_}\n";
	}
	print "New HSV-----\n";
	print "\n";

	set_bulb_red($ip);
	sleep(1);
	set_bulb_green($ip);
	sleep(1);
	set_bulb_blue($ip);
	sleep(1);
	
	set_brightness($ip, 50);
	sleep(1);
	$return = set_brightness($ip, 10);
	print "New brightness: $return\n";
	sleep(1);
	set_brightness($ip, 100);
	sleep(1);
	
	
	$return = get_brightness($ip);
	print "Brightness: $return\n";

}


#hashes for notes
my %plugcommands = (
	'info'     => '{"system":{"get_sysinfo":{}}}',
	'on'       => '{"system":{"set_relay_state":{"state":1}}}',
	'off'      => '{"system":{"set_relay_state":{"state":0}}}',
	'cloudinfo'=> '{"cnCloud":{"get_info":{}}}',
	'wlanscan' => '{"netif":{"get_scaninfo":{"refresh":0}}}',
	'time'     => '{"time":{"get_time":{}}}',
	'schedule' => '{"schedule":{"get_rules":{}}}',
	'countdown'=> '{"count_down":{"get_rules":{}}}',
	'antitheft'=> '{"anti_theft":{"get_rules":{}}}',
	'reboot'   => '{"system":{"reboot":{"delay":1}}}',
	'reset'    => '{"system":{"reset":{"delay":1}}}'
);
my %bulbcommands = (
	'info'     		=> '{"system":{"get_sysinfo":{}}}',
	'on'       		=> '{"smartlife.iot.smartbulb.lightingservice":{"transition_light_state":{"on_off":1}}}',
	'off'      		=> '{"smartlife.iot.smartbulb.lightingservice":{"transition_light_state":{"on_off":0}}}',
	'setbrightness' => '{"smartlife.iot.smartbulb.lightingservice":{"transition_light_state":{"brightness":10}}}',
	
	'cloudinfo'		=> '{"cnCloud":{"get_info":{}}}',
	'wlanscan' 		=> '{"netif":{"get_scaninfo":{"refresh":0}}}',
	'time'     		=> '{"time":{"get_time":{}}}',
	'schedule' 		=> '{"schedule":{"get_rules":{}}}',
	'countdown'		=> '{"count_down":{"get_rules":{}}}',
	'antitheft'		=> '{"anti_theft":{"get_rules":{}}}',
	'reboot'   		=> '{"system":{"reboot":{"delay":1}}}',
	'reset'    		=> '{"system":{"reset":{"delay":1}}}'
);

