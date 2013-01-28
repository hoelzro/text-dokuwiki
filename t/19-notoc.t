use strict;
use warnings;

use Test::More tests => 1;
use Test::Text::DokuWiki;

my $text = <<'END_DOKUWIKI';
====== Heading 1 ======

This is a document without a table of
contents.

~~NOTOC~~
END_DOKUWIKI

my $tree = <<'END_TREE';
Header { content => ' Heading 1 ',   level => 1 }
Paragraph
  Text "\nThis is a document without a table of\ncontents."
NoTOC
END_TREE

chomp $text;

test_doc $text, $tree;
