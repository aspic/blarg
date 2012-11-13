#!/usr/bin/perl
use warnings;
use strict;

package Blarg::Tags;

use Data::Dumper;

my $self;
my $blarg;
my $tags = {};

sub new {
	my ($class, $blarg_ref) = @_;
	my $self = {};
	bless $self, $class;

	return $self;
}

# Store tags all tags for a single post.
sub store_tags {
	my ($self, $post) = @_;

	my $post_link = $post->{file}->{path};
	my $post_title = $post->{meta}->{title};

	for my $tag( @{ $post->{meta}->{tags} }) {
		if(!defined($tags->{$tag})) {
			$tags->{$tag} = {};
		}
		$tags->{$tag}->{$post_title} = $post_link;
	}

	return $post;
}

# Routine for updating/creating the tag flatpage
# Right now the file will get entirely recreated.
sub set_content {
	my ($post) = @_; 
	my $tag_file = Blarg::config('DIR_POSTS') ."/".Blarg::config('PAGE_TAGS');
	if(!defined($tag_file)) {
		print "Error: no tag file specified, will not create tags.\n";
		return;
	} elsif(keys $tags == 0) {
		print "Error: no tags found, $tag_file won't be created.\n";
		return;
	}

	# Start structuring text.
	my $content = "## Tags\n";

	# Loop over all the tags.
	for my $tag_key (keys $tags) {
		$content .= "### [$tag_key](#$tag_key)\n";
		# Array of hashes
		my $tag = $tags->{$tag_key};
		# Append the links and their titles	
		for my $title (keys $tag) {
			$content .= "[$title]($tag->{$title}) ";
		}
		$content .= "\n";
	}

	$post->{content} = $content;
	return $post;
}

1;
