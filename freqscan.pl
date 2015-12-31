#! /usr/bin/perl

# Name:			lite.pl - Simple gqrx SDR Scanner
# Author:		James M. Lynes, Jr.
# Created:		September 17, 2015
# Modified By:		James M. Lynes, Jr.
# Last Modified:	September 17, 2015
# Change Log:		9/17/2015 - Program Created
# Description:		Simple interface to gqrx to implement a SDR scanner function using the
#				Remote Control feature of gqrx(small subset of rigctrl protocol)
#
# 			gqrx is a software defined receiver powered by GNU-Radio and QT
#    			Developed by Alex Csete - gqrx.dk
#
# 			This code is inspired by "Controlling gqrx from a Remote Host" by Alex Csete
# 			and the gqrx-scan scanner code by Khaytsus - github.com/khaytsus/gqrx-scan
#
#			Net::Telnet is not in the perl core and was installed from cpan
#				sudo cpanm Net::Telnet
#
# 			Start gqrx and the gqrx Remote Control option before running this perl code
#
#
use strict;
use warnings;
use Net::Telnet;
use Time::HiRes;

# Defines
my $ip = "127.0.0.1";
my $port = "7356";
my $step = 1000;
my $begin = 162400000;
my $end   = 162600000;
my $mode = "FM";
my $pause = .5;
my $listen = 5;
my $squelch = -15;
# , '172000000','172225000', '172485000'
my @freqarray = ('148227000','148388800', '148762000', '148965000','172225000');
# Open Telnet connection to gqrx via localhost::7356
my $t = Net::Telnet->new(Timeout=>1, port=>$port);
$t->open($ip);

# Set the demodulator type
$t->print("M $mode");
$t->waitfor(Match=> '/RPRT', Timeout=>1, Errmode=>"return");

# Set up to run the scan cycle count times
my $count = 0;

while(1) {
     my $start;
 foreach $start (@freqarray) {

        $t->print("l");                         # Get RSSI (-##.# format)
        my($prematch, $level) = $t->waitfor(Match => '/-{0,1}\d+\.\d/',  Errmode => "return");
        # if(!defined($level)) {next};


      if($level < $squelch) {
    # while($start <= $end) {
        $t->print("F $start");						# Set Frequency
        $t->waitfor(Match=> '/RPRT',Errmode=>"return");
      } else {
        Time::HiRes::sleep($listen);
      }

#       print $level;
        
 }						# Loop for next scan cycle
}

# Close the Telnet connection
$t->print("c");

