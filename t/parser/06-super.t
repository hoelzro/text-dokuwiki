use strict;
use warnings;

use Test::More tests => 1;
use Test::Text::DokuWiki;

my $text = <<'END_DOKUWIKI';
I <sup>am</sup> home!
END_DOKUWIKI

my $tree = <<'END_TREE';
Paragraph
  Text 'I '
  Superscript 'am'
  Text ' home!'
END_TREE

test_doc $text, $tree;
