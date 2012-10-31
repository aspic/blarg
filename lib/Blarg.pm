#!/usr/bin/perl
use warnings;
use strict;

package Blarg;

use Template;
use Config::File qw(read_config_file);
use Text::Markdown 'markdown';
use Data::Dumper;
use File::Slurp;

# Custom modules
use Blarg::Anchors;

my $config;
my $anchors = new Blarg::Anchors;
my $blarg;
my $self;

sub new {
	my $class = shift;
	$self = {};
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

sub strip_meta {
	my ($post) = @_;

	my @lines = split(/\n/, $post->{content});

	my $meta = {};
	my $meta_started = 0;
	my $count = 0;

	# While meta block, extract
	for my $line (@lines) {
		if($line =~ m/^---/) {
			if($meta_started) {
				$count++;
				last;
			} else {
				$count++;
				$meta_started = 1;
			}
			next;
		} elsif($meta_started) {
			my ($key, $value)= split(/: /, $line);

			# Array
			if($value =~ m/,/) {
				my @values = split(/,/, $value);
				$meta->{$key} = \@values;
			} else {
				$meta->{$key} = $value;
			}
			$count++;
		}
	}

	# Remove meta block
	my $length = scalar(@lines);
	@lines = @lines[$count..$length-1];

	# Set content
	$post->{content} = join("\n", @lines);
	# Append file meta data
	$post->{file} = file_path($post->{file_name});
	# Append meta data
	$post->{meta} = $meta;

	return $post;
}



# Sequentially processes the raw markdown-file.
sub process_file {
	my ($file_name) = @_;

	my $posts = config('DIR_POSTS');
	my $temp = read_file("$posts/$file_name");

	# Initial structure
	my $post = {
		content => $temp,
		file_name => $file_name
	};

	# Get meta data
	$post = strip_meta($post);

	# Inject actions
	$post = $anchors->inject_anchors($self, $post);

	return $post;
}


#
# When reaching this point, file should be properly structured.
#
sub create_file {
	my ($self, $file_name) = @_;

	my $post = process_file($file_name);

	my $meta = $post->{meta};
	my $file = $post->{file};

	# Prepare file
	my $path = $self->dir_layout($file->{year}, $file->{month}, $file->{day});
	my $type = 'html';
	my $output = "$path/$file->{name}.$type";

	# Do markdown
	$post->{content} = markdown($post->{content});

	# Check whether variables have been overridden
	unless(defined($meta->{title})) {
		$meta->{title} = config('TITLE');
	}

	my $template = Template->new({
		INCLUDE_PATH => [config('DIR_TPL')],
	});

	# Process the data
	my $content = $template->process($meta->{template}, $post, $output) or die
	"Template rendering failed", $template->error(), "\n";
}

# Routine for creating directory structure
sub dir_layout {
	my ($self) = shift;

	my $root = config('DIR_DEST');

	while (@_) {
		my $dir = shift;

		if(!defined($dir)) {
			last;
		}

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

# Ghetto method for returning all posts.
sub get_posts {
	my ($limit) = @_;

	unless(defined($limit)) {
		$limit = 10;
	}
	my @posts = ();

	my $count = 0;

	opendir(DIR, config('DIR_POSTS')) or die $!;
	while (my $file = readdir(DIR)) {
		if($file =~ m/^[0-9]/) {
			push @posts, process_file($file);
			$count++;
			if($count >= $limit) {
				last;
			}
		}
	}
	closedir(DIR);

	return \@posts;
}


# Convenient (but ugly) routine for getting path info
sub file_path {
	my $file_name = shift;

	# TODO: Do different.
	my $date_offset = 0;
	my @date = split(/-/, substr ($file_name, 0, 11));
	if(@date != 3) {
		return { name => substr ($file_name, 0, length($file_name) - 3) };
	} else {
		$date_offset = 11;
	}
	my $name = substr ($file_name, $date_offset, length($file_name) - $date_offset - 3);

	# Assign meta
	my $meta = {
		full => $file_name,
		name => $name,
		year => $date[0],
		month => $date[1],
		day => $date[2],
		path => "$date[0]/$date[1]/$date[2]/$name.html",
	};
	return $meta;
}

1;
