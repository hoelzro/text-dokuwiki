use strict;
use warnings;

use Test::More tests => 1;
use Test::Text::DokuWiki;

my $text = <<'END_DOKUWIKI';
I <sub>am</sub> home!
END_DOKUWIKI

my $tree = <<'END_TREE';
Paragraph
  Text 'I '
  Subscript 'am'
  Text ' home!'
END_TREE

chomp $text;

test_doc $text, $tree;
