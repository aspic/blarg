#!/usr/bin/perl
use warnings;
use strict;

package Blarg;

use Template;
use Config::File qw(read_config_file);
use Text::Markdown 'markdown';
use Data::Dumper;
use File::Slurp;

my $config;

sub new {
	my $class = shift;
	my $self = {};
	bless $self, $class;
	return $self;
}

# Read some config
sub config {
	my $key = shift;
	return if not defined($key);

	if(!defined($config)) {
		$config = read_config_file('config');
	}
	return $config->{$key};
}

sub process_file {
	my ($self, $file_name, $template) = @_;

	my $posts = config('DIR_POSTS');
	# TODO: Extract metadata from text, before markdown
	my $text = read_file("$posts/$file_name");

	# Extract info from filename
	my @date = split(/-/, substr ($file_name, 0, 11));
	my $name = substr ($file_name, 11, length($file_name) - 11 - 3);

	my $meta = {
		title => $name,
		year => $date[0],
		month => $date[1],
		day  => $date[2],
		template => $template
	};

	# Build reference

	my $vars= {
		content => markdown($text),
		meta => $meta
	};

	$self->create_file($vars);
}

sub create_file {
	my ($self, $vars) = @_;


	my $meta = $vars->{meta};
	my $path = $self->dir_layout($meta->{year}, $meta->{month}, $meta->{day});
	my $type = 'html';
	my $output = "$path/$meta->{title}.$type";

	my $template = Template->new({
		INCLUDE_PATH => [config('DIR_TPL')],
	});

	# Adding some static variables
	$vars->{title} = "Mehl.no";

	# Process the data
	my $content = $template->process($vars->{meta}->{template}, $vars, $output) or die
	"Template rendering failed", $template->error(), "\n";
}

sub dir_layout {
	my ($self) = shift;

	my $root = config('DIR_DEST');

	while (@_) { 
		my $dir = shift;

		$root = "$root/$dir";
		if(-d $root) {
			next;
		}
		unless(mkdir $root) {
			die "Unable to create $root\n";
		}

	}

	return $root;
}


1;
