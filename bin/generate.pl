#!/usr/bin/perl

use strict;
use warnings;

use lib 'lib/';
use Blarg;

my $blarg = new Blarg;

$blarg->process_file("2012-10-25-test-title-yow.md", "post.tpl");
