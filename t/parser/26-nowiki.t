use strict;
use warnings;

use Test::More tests => 2;
use Test::Text::DokuWiki;
use Carp::Always;

my $text = <<'END_DOKUWIKI';
<nowiki>This is some *awesome* text with //some// markup</nowiki>
END_DOKUWIKI

my $tree = <<'END_TREE';
Paragraph
  Text 'This is some *awesome* text with //some// markup'
END_TREE

test_doc $text, $tree;

$text = <<'END_DOKUWIKI';
%%This is some *awesome* text with //some// markup%%
END_DOKUWIKI

$tree = <<'END_TREE';
Paragraph
  Text 'This is some *awesome* text with //some// markup'
END_TREE

test_doc $text, $tree;
