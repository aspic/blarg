#!/usr/bin/perl
use warnings;
use strict;

package Blarg::Anchors;

use Data::Dumper;

my $self;
my $blarg;

sub new {
	my ($class, $blarg_ref) = @_;
	my $self = {};
	bless $self, $class;

	return $self;
}

# Parse and inject anchors into the specified post
sub inject_anchors {
	my ($self, $blarg, $post) = @_;

	my @lines = split(/\n/, $post->{content});
	# Altered text
	my @content = ();

	for my $line (@lines) {

		if($line =~ s/(.*)(\[%.*%\])(.*)/$1$3/) {
			# Custom hooks directly into md-file
			my $left= $1;
			my $anchor = $2;
			my $right = $3;

			# Extract options
			$anchor =~ s/(\[% | %\])//g;
			my @cmd_options = split(/ /, $anchor);

			my $command = shift @cmd_options;
			my $options = {
				cmd => $command,
				file_name => $post->{file_name},
			};

			# Append arguments
			for my $arg (@cmd_options) {
				my ($key, $val) = split(/=/, $arg);
				$options->{$key} = $val;
			}
			# Add result
			push @content, $left.use_anchor($options, $post).$right;
		} else {
			# Nothing to see here, move along
			push @content, $line;
		}
	}
	# Create references
	$post->{content} = join("\n", @content);

	return $post;
}

# Simple and naive routine for handling anchors
sub use_anchor {
	my ($cmd, $post) = @_;

	my @result = ();
	my $type = $cmd->{cmd};

	# List N posts
	if($type =~ m/posts/) {
		for my $post ( @{ Blarg::get_posts() }) {
			my $title = $post->{meta}->{title};
			# Assign title
			unless(defined($title)) {
				$title = $post->{file_name};
			}
			# Create list
			push @result, "-    [$title]($post->{file}->{path})\n";
		}
	}

	# Single post
	elsif($type =~ m/post/) {
		my $last = Blarg::get_posts(1)->[0];
		my $content = $last->{content};
		push @result, $content;
	}
	# Git log
	elsif($type =~ m/git/) {
		my $log = git_log($cmd);
		push @result, $log;
	}
	# Date
	elsif($type =~ m/date/) {
		my $file = $post->{file};
		push @result, "    $file->{year}-$file->{month}-$file->{day}";
	}

	my $result = join("\n", @result);

	return $result;

}

# Returns the git log for the specified file
sub git_log {
	my ($cmd) = @_;

	my $title = $cmd->{title};
	my $path = $cmd->{path};
	my $limit = $cmd->{limit};
	my $style = $cmd->{style};

	unless(defined($limit)) {
		$limit = 1;
	}
	unless(defined($style)) {
		$style = "    ";
	}

	my @result = ();
	# Paths
	unless(defined($path)) {
		# We assume posts
		$path = Blarg::config('DIR_POSTS')."/".$cmd->{file_name};
		@result = `git log -$limit --pretty=format:'%h - %s (%ci)' --abbrev-commit $path`;
	} else {
		# Custom directory (for projects etc)
		my $git_dir = "$path/.git";
		# Only check root
		$path = ".";
		@result = `git --git-dir=$git_dir log -$limit --pretty=format:'%h - %s (%ci)' --abbrev-commit $path`;
	}

	for my $item (@result) {
		$item = $style.$item;
	}

	return join("", @result);
}

1;
