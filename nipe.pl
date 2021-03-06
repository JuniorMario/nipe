#!/usr/bin/perl

#### OPEN MODULOS ####
use strict;
use warnings;
use Switch;
use Term::ANSIColor;
#### /END MODULOS ####

#### OPEN VARIAVEIS ####
my $command    = $ARGV[0];
my $tor_user   = "debian-tor";
my $dns_port   = "9061";
my $trans_port = "9051";
my $network    = "10.66.0.0/255.255.0.0";
my @table      = ("nat","filter");
#### /END VARIAVEIS ####

sub install {
	system ("sudo apt-get install tor");
	system ("sudo mkdir -p /etc/tor");
	system ("sudo cp ./torrc /etc/tor/torrc");
	system ("sudo chmod 644 /etc/tor/torrc");
	exit;
}

sub help {
	print color("red"),"\n\tCOMMAND \t FUCTION\n
	\r\tinstall \t To install
	\r\tstart   \t To start
	\r\tstop    \t To stop
	\r\tstatus  \t Status
	\r\tabout   \t About us\n\n",color("reset");
	exit;
}

sub about {
	print color("red"),"\nCreated by Heitor Gouvea
	\rFacebook: www.fb.com/heitor.gouvea.9
	\rSite: www.heitorgouvea.com
	\rE-mail: cold\@protonmail.com\n\n",color("reset");
	exit;
}

sub start {

	print color("red"),"\n[+] Transferring traffic for the Tor network....\n";

	foreach my $nipe(@table) {

		my $target = "ACCEPT";

		if ($nipe eq "nat") {
			$target = "RETURN";
		}

		system ("iptables -t $nipe -F OUTPUT");
		system ("iptables -t $nipe -A OUTPUT -m state --state ESTABLISHED -j $target");
		system ("iptables -t $nipe -A OUTPUT -m owner --uid debian-tor -j $target");

		my $match_dns_port = $dns_port;

		if ($nipe eq "nat") {
			
			$target = "REDIRECT --to-ports $dns_port";
			$match_dns_port = "53";
		}

		system ("iptables -t $nipe -A OUTPUT -p udp --dport $match_dns_port -j $target");
		system ("iptables -t $nipe -A OUTPUT -p tcp --dport $match_dns_port -j $target");

		if ($nipe eq "nat") {
			$target = "REDIRECT --to-ports $trans_port";
		}

		system ("iptables -t $nipe -A OUTPUT -d $network -p tcp -j $target");

		if ($nipe eq "nat") {
			$target = "RETURN";
		}

		system ("iptables -t $nipe -A OUTPUT -d 127.0.0.1/8    -j $target");
		system ("iptables -t $nipe -A OUTPUT -d 192.168.0.0/16 -j $target");
		system ("iptables -t $nipe -A OUTPUT -d 172.16.0.0/12  -j $target");
		system ("iptables -t $nipe -A OUTPUT -d 10.0.0.0/8     -j $target");

		if ($nipe eq "nat") {
			$target = "REDIRECT --to-ports $trans_port";
		}

		system ("iptables -t $nipe -A OUTPUT -p tcp -j $target");
	}

	system ("iptables -t filter -A OUTPUT -p udp -j REJECT");
	system ("iptables -t filter -A OUTPUT -p icmp -j REJECT");

	print "[+] Transfer this ok.\n\n",color("reset");
}

sub stop {
	print color("red"),"\n[+] Stopping traffic transfer\n";
		
	system ("iptables -t nat -F OUTPUT");
	system ("iptables -t filter -F OUTPUT");
		
	print "[+] Transfer stopped\n\n",color("reset");
	exit;
}

switch ($command) {
	case "install" { install(); }
	case "start"   { start(); }
	case "stop"    { stop(); }
	case "help"    { help(); }
	case "about"   { about(); }
	else           { error(); }
}
