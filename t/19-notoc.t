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
Heading { content => ' Heading 1 ',   level => 1 }
Paragraph
  Text "\nThis is a document without a table of\ncontents."
NoTOC
END_TREE

test_doc $text, $tree;
