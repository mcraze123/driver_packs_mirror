#!/usr/bin/perl
# Driver Packs Scrapper v0.1
# Michael Craze 2012
#
# Scrapes the driverpacks.net RSS feed for the latest torrents,
# The RSS feed only give links to the website, so those links are
# scrapped for the links to the torrent files. They are saved in
# the $dest directory with their correct filenames.
# This can be used in conjunction with your torrent client's "watch"
# directory for automatic downloading of latest driver packs.
use strict;
use warnings;
use URI;
use XML::RSS;
use LWP::Simple;
use Web::Scraper;

my $log_file='/home/mike/code/dpmirror/driver_packs.log';
#my $dest='/home/mike/code/dpmirror/torrents';
my $dest='/store/torrent/watch';
my $feed='http://driverpacks.net/driverpacks/latest/feed';

my @driver_packs=();
open my $ILFH, '<', $log_file or die "Can't open $log_file: $!\n";
chomp(@driver_packs=<$ILFH>);
close $ILFH;

my $rss=new XML::RSS;
my $content=get($feed);
die unless $content;
$rss->parse($content);
foreach my $item (@{$rss->{'items'}}){
	next unless defined($item->{'title'}) && defined($item->{'link'});
	my $already_downloaded_flag=0;
	my $title=$item->{'title'};
	my $link=$item->{'link'};
	#<div class="download-link"><a href="/driverpacks/windows/7/x86/cablemodem/10.01/download/torrent">Download ↓</a></div>
	my $data = scraper {
		process "div.download-link > a", 'urls[]' => '@href';
	};
	my $res = $data->scrape(URI->new("$link"));
	for my $i (0 .. $#{$res->{urls}}){
		print "Checking $link\n";
		my @fields = split /\//, $res->{urls}[$i];
		my $kind=$fields[7];
		my $arch=$fields[6];
		my $ver=$fields[8];
		$ver =~ tr/.//d;
		my $nt="";
		if($fields[5] =~ m/^7$/){ $nt="6"; }
		if($fields[5] =~ m/^xp$/i){ $nt="5"; }
		my $fn=$dest."/DP_".$kind."_wnt".$nt."-".$arch."_".$ver.".torrent";
		next if(-e $fn);
		for my $driver_pack (@driver_packs){
			if($fn =~ m/$driver_pack/){ $already_downloaded_flag=1; }
		}
		next if $already_downloaded_flag;
		push(@driver_packs,$fn);
		my $status=getstore($res->{urls}[$i],$fn);
		if(is_success($status)){
			my $time=localtime();
			print "Updated: $fn [$time]\n";
		}
	}
}

# Write new log file
open my $OLFH, '>', $log_file or die "Can't open $log_file: $!\n";
for my $driver_pack (@driver_packs){
	    print $OLFH "$driver_pack\n";
}
close $OLFH;

exit;

__END__

