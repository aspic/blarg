#!/usr/bin/perl

use strict;
use warnings;

use lib 'lib/';
use Blarg;


unless (@ARGV == 0 || @ARGV == 1) {
	print "Usage: pass path of file to be deployed as parameter\n"; 
    exit(1);
}

my $blarg = new Blarg;

# Rebuild tree
if(@ARGV == 0) {
	opendir(DIR, Blarg::config('DIR_POSTS')) or die $!;

	while (my $file = readdir(DIR)) {
		next if ($file =~ m/^\./);
		$blarg->create_file($file);
		print "$file got recreated.\n";
	}
	closedir(DIR);

	$blarg->tag_handle()->write_tags();

	print "Site got rebuilt.\n";
}
# Rebuild specific post
elsif(@ARGV == 1) {
	my $post = $ARGV[0];

	$blarg->create_file($post);
	print "$post got deployed.\n";
}


