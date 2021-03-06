use strict;
use warnings;

use Test::More tests => 1;
use Test::Text::DokuWiki;

# XXX can footnotes contain other markup?
my $text = <<'END_DOKUWIKI';
This page contains ((footnotes)).
((Moar)) footnotes!
END_DOKUWIKI

my $tree = <<'END_TREE';
Paragraph
  Text 'This page contains '
  Footnote 'footnotes'
  Text '. '
  Footnote 'Moar'
  Text ' footnotes!'
END_TREE

test_doc $text, $tree;
