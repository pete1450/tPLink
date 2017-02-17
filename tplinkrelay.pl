#!/usr/bin/perl
use CGI;
use strict;
use My::TPLCmd;

my $cgi = new CGI;
my %params;

%params = map { $_ => ($cgi->param($_))[0] } $cgi->param;

#print "Content-Type: text/plain", "\n\n";
#print '<html>';
#print '<head>';
#print '</body>';
#print '</html>';

#foreach (sort keys %params) {
#		print "$_: $params{$_}\n";
#}

if($params{'cmd'} =~ /^identify$/){
	my $ip = $params{'ip'};
	my %returnHash = identify($ip);
	foreach (sort keys %returnHash) {
		print "$_:$returnHash{$_}\n";
	}
}
if($params{'cmd'} =~ /^set_alias$/){
	my $ip = $params{'ip'};
	my $alias = $params{'alias'};
	my $return = set_alias($ip,$alias);
	print $return;
}
if($params{'cmd'} =~ /^get_emeter_realtime$/){
	my $ip = $params{'ip'};
	my $return = get_emeter_realtime($ip);
	print $return;
}
if($params{'cmd'} =~ /^get_emeter_daily$/){
	my $ip = $params{'ip'};
	my $return = get_emeter_daily($ip);
	print $return;
}
if($params{'cmd'} =~ /^get_emeter_monthly$/){
	my $ip = $params{'ip'};
	my $return = get_emeter_monthly($ip);
	print $return;
}
if($params{'cmd'} =~ /^erase_emeter_stats$/){
	my $ip = $params{'ip'};
	my $return = erase_emeter_stats($ip);
	print $return;
}
if($params{'cmd'} =~ /^get_bulb_sysinfo$/){
	my $ip = $params{'ip'};
	my %returnHash = get_bulb_sysinfo($ip);
	foreach (sort keys %returnHash) {
		print "$_:$returnHash{$_}\n";
	}
}
if($params{'cmd'} =~ /^set_bulb_state$/){
	my $ip = $params{'ip'};
	my $status = $params{'state'};
	my $return = set_bulb_state($ip, $status);
	print $return;
}
if($params{'cmd'} =~ /^get_bulb_state$/){
	my $ip = $params{'ip'};
	my %returnHash = get_bulb_state($ip);
	foreach (sort keys %returnHash) {
		print "$_:$returnHash{$_}\n";
	}
}
if($params{'cmd'} =~ /^set_white_temp$/){
	my $ip = $params{'ip'};
	my $temp = $params{'temp'};
	my $return = set_white_temp($ip, $temp);
	print $return;
}
if($params{'cmd'} =~ /^get_color_temp$/){
	my $ip = $params{'ip'};
	my $return = get_color_temp($ip);
	print $return;
}
if($params{'cmd'} =~ /^get_hsv$/){
	my $ip = $params{'ip'};
	my %returnHash = get_hsv($ip);
	foreach (sort keys %returnHash) {
		print "$_:$returnHash{$_}\n";
	}
}
if($params{'cmd'} =~ /^set_hsv$/){
	my $ip = $params{'ip'};
	my $hue = $params{'hue'};
	my $sat = $params{'sat'};
	my $val = $params{'val'};
	my %returnHash = set_hsv($ip, $hue, $sat, $val);
	foreach (sort keys %returnHash) {
		print "$_:$returnHash{$_}\n";
	}
}
if($params{'cmd'} =~ /^set_bulb_red$/){
	my $ip = $params{'ip'};
	my $return = set_bulb_red($ip);
	print $return;
}
if($params{'cmd'} =~ /^set_bulb_green$/){
	my $ip = $params{'ip'};
	my $return = set_bulb_green($ip);
	print $return;
}
if($params{'cmd'} =~ /^set_bulb_blue$/){
	my $ip = $params{'ip'};
	my $return = set_bulb_blue($ip);
	print $return;
}
if($params{'cmd'} =~ /^set_brightness$/){
	my $ip = $params{'ip'};
	my $brightness = $params{'brightness'};
	my $return = set_brightness($ip, $brightness);
	print $return;
}
if($params{'cmd'} =~ /^get_brightness$/){
	my $ip = $params{'ip'};
	my $return = get_brightness($ip);
	print $return;
}
if($params{'cmd'} =~ /^get_plug_sysinfo$/){
	my $ip = $params{'ip'};
	my %returnHash = get_plug_sysinfo($ip);
	foreach (sort keys %returnHash) {
		print "$_:$returnHash{$_}\n";
	}
}
if($params{'cmd'} =~ /^set_plug_state$/){
	my $ip = $params{'ip'};
	my $state = $params{'state'};
	my $return = set_plug_state($ip, $state);
	print $return;
}
if($params{'cmd'} =~ /^plug_is_off$/){
	my $ip = $params{'ip'};
	my $return = plug_is_off($ip);
	print $return;
}
if($params{'cmd'} =~ /^plug_is_on$/){
	my $ip = $params{'ip'};
	my $return = plug_is_on($ip);
	print $return;
}
if($params{'cmd'} =~ /^turn_plug_on$/){
	my $ip = $params{'ip'};
	my $return = turn_plug_on($ip);
	print $return;
}
if($params{'cmd'} =~ /^turn_plug_off$/){
	my $ip = $params{'ip'};
	my $return = turn_plug_off($ip);
	print $return;
}
if($params{'cmd'} =~ /^plug_has_emeter$/){
	my $ip = $params{'ip'};
	my $return = plug_has_emeter($ip);
	print $return;
}
if($params{'cmd'} =~ /^get_plug_led$/){
	my $ip = $params{'ip'};
	my $return = get_plug_led($ip);
	print $return;
}
if($params{'cmd'} =~ /^set_plug_led$/){
	my $ip = $params{'ip'};
	my $status = $params{'status'};
	my $return = set_plug_led($ip, $status);
	print $return;
}
if($params{'cmd'} =~ /^plug_on_since$/){
	my $ip = $params{'ip'};
	my $return = plug_on_since($ip);
	print $return;
}
if($params{'cmd'} =~ /^discover$/){
	my $return = discover();
	print $return;
}


