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

sub strip_meta {
	my ($self, $post) = @_;

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
			$meta->{$key} = $value;
			$count++;
		}
	}

	# Remove meta block
	my $length = scalar(@lines);
	@lines = @lines[$count..$length-1];
	$post->{content} = join("\n", @lines);

	$post->{file} = file_path($post->{file_name});
	$post->{meta} = $meta;

	return $post;
}


sub inject_actions {
	my ($self, $post) = @_;

	my @lines = split(/\n/, $post->{content});
	# Altered text
	my @content = ();

	for my $line (@lines) {
		if( $line =~ m/^{/) {
			# Custom hooks directly into md-file

			# Extract options
			my @cmd_options = split(/ /, substr ($line, 3, length($line) - 6));
			my $command = shift @cmd_options;
			my $options = {
				cmd => $command,
				file_name => $post->{file_name}
			};

			# Append arguments
			for my $arg (@cmd_options) {
				my ($key, $val) = split(/=/, $arg);
				$options->{$key} = $val;
			}
			# Add result
			push @content, $self->use_command($options);
		} else {
			push @content, $line;
		}
	}

	# Create references
	$post->{content} = join("\n", @content);

	return $post;
}

# Sequentially processes the raw markdown-file.
sub process_file {
	my ($self, $file_name) = @_;

	my $posts = config('DIR_POSTS');
	my $temp = read_file("$posts/$file_name");

	# Initial structure
	my $post = {
		content => $temp,
		file_name => $file_name
	};

	# Get meta data
	$post = $self->strip_meta($post);

	# Inject actions
	$post = $self->inject_actions($post);

	return $post;
}


#
# When reaching this point, file should be properly structured.
#
sub create_file {
	my ($self, $file_name) = @_;

	my $post = $self->process_file($file_name);

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

# We expect a hash, and should return text
sub use_command {
	my ($self, $cmd) = @_;

	my @result = ();
	my $type = $cmd->{cmd};

	# List N posts
	if($type =~ m/posts/) {
		for my $post ( @{ $self->get_posts() }) {
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
		my $last = $self->get_posts(1)->[0];
		my $content = $last->{content};
		push @result, $content;
	}
	# Git log
	elsif($type =~ m/git/) {
		my $log = git_log($cmd);
		push @result, $log;
	}

	my $result = join("\n", @result);

	return $result;

}

# Ghetto method for returning all posts.
sub get_posts {
	my ($self, $limit) = @_;

	unless(defined($limit)) {
		$limit = 10;
	}
	my @posts = ();

	my $count = 0;

	opendir(DIR, config('DIR_POSTS')) or die $!;
	while (my $file = readdir(DIR)) {
		if($file =~ m/^[0-9]/) {
			push @posts, $self->process_file($file);
			$count++;
			if($count >= $limit) {
				last;
			}
		}
	}
	closedir(DIR);

	return \@posts;
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
		$path = config('DIR_POSTS')."/".$cmd->{file_name};
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

# Convenient (but ugly) routine for getting path info
sub file_path {
	my $file_name = shift;

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
