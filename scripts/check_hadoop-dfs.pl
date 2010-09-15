#!/usr/bin/perl -w

use strict;
use Socket;
use FileHandle;


my $node;
my $warn_node;
my $crit_node;
my $http;
my $buf;
my ($host, $port, $url, $ip, $sockaddr);
my $ST_OK=0;
my $ST_WR=1;
my $ST_CR=2;
my $ST_UK=3;



$host = $ARGV[0];
$warn_node = $ARGV[1]; #DataNodeがこの数以下ならWARNING
$crit_node = $ARGV[2]; #DataNodeがかの数以下ならCRITICAL
$port = 50070;
$url = '/dfshealth.jsp';

# ソケットの生成
$ip = inet_aton($host) || die "CRITICAL - host($host) not found.\n";
$sockaddr = pack_sockaddr_in($port, $ip);
socket(SOCKET, PF_INET, SOCK_STREAM, 0) || die "CRITICAL - socket error.\n";

# ソケットの接続
connect(SOCKET, $sockaddr) || die "CRITICAL - connect $host $port error.\n";
autoflush SOCKET (1);

print SOCKET "GET $url HTTP/1.0\n\n";

while ($buf=<SOCKET>) {
	$_ = $buf;
	# httpの結果からLive Nodesの数値を拾う
	if( /Live Nodes.*Dead Nodes/){
		$node = $&;
		$node =~ s/<[^>]*>//gs;
		$node =~ s/Live Nodes.*://g;
		$node =~ s/Dead Nodes//g;
		$node =~ s/\s//g;
	}
}

close(SOCKET);

if ($node <= $crit_node ){
	print "CRITICAL - Datanodes up and running: $node \n";
	exit($ST_CR);
} elsif ($node <= $warn_node ){
	print "WARNING - Datanodes up and running: $node \n";
	exit($ST_WR);
}else{
	print "OK - Datanodes up and running: $node \n";
	exit($ST_OK);
}
