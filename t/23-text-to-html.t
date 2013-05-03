#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 1;
use Test::Text::DokuWiki;

my $text = <<'END_DOKUWIKI';
Paragraph of text: -> <- <-> => <= <=> >> << -- --- 640x480 (c) (tm) (r)
END_DOKUWIKI

my $tree = <<'END_TREE';
Paragraph
  Text 'Paragraph of text: -> <- <-> => <= <=> >> << -- --- 640x480 (c) (tm) (r)'
END_TREE

test_doc $text, $tree, 'Testing that text-to-html patters are unaltered in the parse phase';

# XXX test that they dump to HTML ok
