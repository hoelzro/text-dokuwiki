use strict;
use warnings;

use Test::More tests => 1;
use Test::Text::DokuWiki;

my $text = <<'END_DOKUWIKI';
This is not \\a forced newline
END_DOKUWIKI

my $tree = <<'END_TREE';
Paragraph
  Text 'This is not \\\\a forced newline'
END_TREE

test_doc $text, $tree;
