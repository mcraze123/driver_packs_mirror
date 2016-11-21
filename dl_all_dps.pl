#!/usr/bin/perl
#
# Downloads all torrents for all driver packs for all windows operating systems
# and architectures
#
# &copy; Michael Craze -- http://projectcraze.us.to

use strict;
use warnings;
use LWP::Simple;

my $debug=0;
my $domain="http://driverpacks.net";
my $url=$domain."/driverpacks/latest";
my $content=get($url);
die "Couldn't get url: $url" unless defined $content;

if ($debug){
	print "$content\n";
}

my @torrent_links=($content =~ /(\/driverpacks\/windows\/(7|xp)\/(x86|x64)\/[-a-zA-Z]+\/\d+\.\d+)/g);
foreach my $link (@torrent_links){
	if($link =~ /(\/driverpacks\/windows\/(7|xp)\/(x86|x64)\/[-a-zA-Z]+\/\d+\.\d+)/g){
		#print "Getting: $domain"."$link\n";
		my $link_content=get($domain.$link);
		die "Couldn't get url: $url" unless defined $link_content;
		if($debug){
			print "$link_content\n";
		}
		if($link_content =~ /(\/driverpacks\/windows\/(7|xp)\/(x86|x64)\/[-a-zA-Z]+\/\d+\.\d+\/download\/torrent)/g){
			my $uri=$domain.$1;
			print "Downloading: $uri\n";
			my @dirs=split("/",$1);
			my $filename="DP_".$dirs[2]."_".$dirs[3]."_".$dirs[4]."_".$dirs[5]."_".$dirs[6].".torrent";
			print " Filename: $filename\n";
			my $status=getstore($uri,$filename);
			die "$status error while getting $uri" unless is_success($status);
		}
	}
}
