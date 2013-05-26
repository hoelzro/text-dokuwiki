#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 1;
use Test::Text::DokuWiki;

my $text = <<'END_DOKUWIKI';
Foo
Bar
END_DOKUWIKI

my $tree = <<'END_TREE';
Paragraph
  Text 'Foo Bar'
END_TREE

test_doc $text, $tree;
