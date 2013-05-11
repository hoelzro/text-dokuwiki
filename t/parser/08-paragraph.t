use strict;
use warnings;

use Test::More tests => 1;
use Test::Text::DokuWiki;

my $text = <<'END_DOKUWIKI';
I am home!

I'm leaving soon!
END_DOKUWIKI

my $tree = <<'END_TREE';
Paragraph
  Text 'I am home!'
Paragraph
  Text "I'm leaving soon!"
END_TREE

test_doc $text, $tree;

# XXX make sure that appropriate characters ('<' and '>', for example) are
# converted?
