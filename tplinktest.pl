use strict;
use Socket qw(PF_INET SOCK_STREAM pack_sockaddr_in inet_aton);
use Getopt::ArgParse;
use bytes;
use JSON qw( decode_json );

my $reply;
my $debug = 1;

#my $ip = '192.168.1.165';
#my $ip = '192.168.1.129';
my $ip = '192.168.1.194';

executeAllBulbCommandsTest($ip);


###
#
#Subroutines
#
###

##
#General commands
##

#returns decoded json
sub get_sysinfo{
	my $ip = shift;
	my $command = '{"system":{"get_sysinfo":{}}}';
	my $return = sendcmd($ip, "$command");
	return $return;
}

sub identify{
	my $ip = shift;
	my $command = '{"system":{"get_sysinfo":{}}}';
	my $return = sendcmd($ip, "$command");
	print "model: " . $return->{'system'}{'get_sysinfo'}{'model'} . "\n" if $debug;
	print "alias: " . $return->{'system'}{'get_sysinfo'}{'alias'} . "\n" if $debug;
	return $return;
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

#1 = on
#0 = off
#returns decoded json
sub set_bulb_state{
	my $ip = shift;
	my $status = shift;
	my $command = '{"smartlife.iot.smartbulb.lightingservice":{"transition_light_state":{"on_off":' . $status . '}}}';
	my $return = sendcmd($ip, "$command");
	return $return;
}

sub get_bulb_state{
	my $ip = shift;
	my $status = shift;
	my $command = '{"smartlife.iot.smartbulb.lightingservice":{"get_light_state":{}}}';
	my $return = sendcmd($ip, "$command");
	return $return;
}

#only works if bulb is on
sub set_color_temp{
	my $ip = shift;
	my $temp = shift;
	my $command = '{"smartlife.iot.smartbulb.lightingservice":{"transition_light_state":{"color_temp":' . $temp . '}}}';
	my $return = sendcmd($ip, "$command");
	return $return;
}



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
	my $returned = get_sysinfo($ip);
	print "sw_ver: " . $returned->{'system'}{'get_sysinfo'}{'sw_ver'} . "\n";
	print "hw_ver: " . $returned->{'system'}{'get_sysinfo'}{'hw_ver'} . "\n";
	print "model: " . $returned->{'system'}{'get_sysinfo'}{'model'} . "\n";
	print "alias: " . $returned->{'system'}{'get_sysinfo'}{'alias'} . "\n";
	print "description: " . $returned->{'system'}{'get_sysinfo'}{'description'} . "\n";
	print "mic_type: " . $returned->{'system'}{'get_sysinfo'}{'mic_type'} . "\n";
	print "dev_state: " . $returned->{'system'}{'get_sysinfo'}{'dev_state'} . "\n";
	print "mic_mac: " . $returned->{'system'}{'get_sysinfo'}{'mic_mac'} . "\n";
	print "deviceId: " . $returned->{'system'}{'get_sysinfo'}{'deviceId'} . "\n";
	print "oemId: " . $returned->{'system'}{'get_sysinfo'}{'oemId'} . "\n";
	print "hwId: " . $returned->{'system'}{'get_sysinfo'}{'hwId'} . "\n";
	print "is_factory: " . $returned->{'system'}{'get_sysinfo'}{'is_factory'} . "\n";
	print "disco_ver: " . $returned->{'system'}{'get_sysinfo'}{'disco_ver'} . "\n";
	print "ctrl_protocols->name: " . $returned->{'system'}{'get_sysinfo'}{'ctrl_protocols'}{'name'} . "\n";
	print "ctrl_protocols->version: " . $returned->{'system'}{'get_sysinfo'}{'ctrl_protocols'}{'version'} . "\n";
	print "light_state->on_off: " . $returned->{'system'}{'get_sysinfo'}{'light_state'}{'on_off'} . "\n";
	print "light_state->mode: " . $returned->{'system'}{'get_sysinfo'}{'light_state'}{'mode'} . "\n";
	print "light_state->hue: " . $returned->{'system'}{'get_sysinfo'}{'light_state'}{'hue'} . "\n";
	print "light_state->saturation: " . $returned->{'system'}{'get_sysinfo'}{'light_state'}{'saturation'} . "\n";
	print "light_state->color_temp: " . $returned->{'system'}{'get_sysinfo'}{'light_state'}{'color_temp'} . "\n";
	print "light_state->brightness: " . $returned->{'system'}{'get_sysinfo'}{'light_state'}{'brightness'} . "\n";
	print "is_dimmable: " . $returned->{'system'}{'get_sysinfo'}{'is_dimmable'} . "\n";
	print "is_color: " . $returned->{'system'}{'get_sysinfo'}{'is_color'} . "\n";
	print "is_variable_color_temp: " . $returned->{'system'}{'get_sysinfo'}{'is_variable_color_temp'} . "\n";

	### Seems like there's a better way to do this...
	print "preferred_state->\n";
	my @prefArr = @{$returned->{'system'}{'get_sysinfo'}{'preferred_state'}};
	foreach(@prefArr)
	{
		my %tmphash = %{$_};
		print "\t";
		print "index:$tmphash{index}, ";
		print "hue:$tmphash{hue}, ";
		print "saturation:$tmphash{saturation}, ";
		print "color_temp:$tmphash{color_temp}, ";
		print "brightness:$tmphash{brightness}, ";
		print "\n";
	}

	print "rssi: " . $returned->{'system'}{'get_sysinfo'}{'rssi'} . "\n";
	print "active_mode: " . $returned->{'system'}{'get_sysinfo'}{'active_mode'} . "\n";
	print "heapsize: " . $returned->{'system'}{'get_sysinfo'}{'heapsize'} . "\n";
	print "err_code: " . $returned->{'system'}{'get_sysinfo'}{'err_code'} . "\n";
}

sub executeAllBulbCommandsTest{

	my $ip = shift;

	#get all the info
	printBulbInfo($ip);

	#turn a light on
	$reply = set_bulb_state($ip, 1);
	print "Reply: " . $reply->{'smartlife.iot.smartbulb.lightingservice'}{'transition_light_state'}{'on_off'} . "\n";
	#sleep(2);
	#turn a light off
	#$reply = set_bulb_state($ip, 0);
	print "Reply: " . $reply->{'smartlife.iot.smartbulb.lightingservice'}{'transition_light_state'}{'on_off'} . "\n";

	$reply = identify($ip);
	print "model:" . $reply->{'system'}{'get_sysinfo'}{'model'} . " alias:" . $reply->{'system'}{'get_sysinfo'}{'alias'} .  "\n";

	##not working
	#$reply = set_alias($ip, "test");
	#$reply = set_alias($ip, "Upstairs Lamp");

	## these have long responses and break something
	#get_emeter_daily($ip);
	#get_emeter_monthly($ip);

	get_emeter_realtime($ip);

	#commented out as to be nondestructive
	#erase_emeter_stats($ip);

	get_bulb_state($ip);

	set_color_temp($ip, 2500);

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

