use strict;
use warnings;

use Test::More tests => 2;
use Test::Text::DokuWiki;

my $text = <<'END_DOKUWIKI';
Link One: http://google.com
Link Two: https://google.com
END_DOKUWIKI

my $tree = <<'END_TREE';
Paragraph
  Text 'Link One: '
  ExternalLinkURI 'http://google.com'
  Text "\nLink Two: "
  ExternalLinkURI 'https://google.com'
END_TREE

chomp $text;

test_doc $text, $tree;

$text = <<'END_DOKUWIKI';
Link Three: www.google.com
END_DOKUWIKI

$tree = <<'END_TREE';
Paragraph
  Text 'Link Three: '
  ExternalLinkURI 'www.google.com'
END_TREE

chomp $text;

SKIP: {
    skip 'Schema-less bare links (www.google.com) are not implemented', 1;
    test_doc $text, $tree;
}
