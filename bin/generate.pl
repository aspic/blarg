#!/usr/bin/perl

use strict;
use warnings;

use lib 'lib/';
use Blarg;

my $blarg = new Blarg;

$blarg->process_file("index.md", "index.tpl");
