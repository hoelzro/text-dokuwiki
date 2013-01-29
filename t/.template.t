#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 1;
use Test::Text::DokuWiki;

my $text = <<'END_DOKUWIKI';
END_DOKUWIKI

my $tree = <<'END_TREE';
END_TREE

chomp $text;

test_doc $text, $tree;
