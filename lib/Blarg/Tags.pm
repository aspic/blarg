#!/usr/bin/perl
use warnings;
use strict;

package Blarg::Tags;

use Data::Dumper;

my $self;
my $blarg;
my %tags = ();

sub new {
	my ($class, $blarg_ref) = @_;
	my $self = {};
	bless $self, $class;

	return $self;
}

# Store tags all tags for a single post.
sub store_tags {
	my ($self, $post) = @_;

	for my $tag( @{ $post->{meta}->{tags} }) {
		print Dumper($tag);
	}

}

# Routine for updating/creating the tag flatpage
sub write_tags {
	my $tag_file = Blarg::config('DIR_POSTS') ."/".Blarg::config('PAGE_TAGS');
	if(!defined($tag_file)) {
		print "Error: no tag file specified, will not create tags.\n";
		return;
	} elsif(keys %tags == 0) {
		print "Error: no tags found, $tag_file won't be created.\n";
		return;
	}

	# Create tags file
	open FH, ">>$tag_file" or die "can't open '$tag_file': $!";

	close FH;
}

1;
