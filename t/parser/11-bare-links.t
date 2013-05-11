use strict;
use warnings;

use Test::More tests => 2;
use Test::Text::DokuWiki qw(:DEFAULT :link_classes);
use URI;

my $text = <<'END_DOKUWIKI';
Link One: http://google.com
Link Two: https://google.com
END_DOKUWIKI

my $tree = <<'END_TREE';
Paragraph
  Text 'Link One: '
  Link { link => ExternalLink->new(uri => URI->new('http://google.com')) }
  Text "\nLink Two: "
  Link { link => ExternalLink->new(uri => URI->new('https://google.com')) }
END_TREE

test_doc $text, $tree;

$text = <<'END_DOKUWIKI';
Link Three: www.google.com
END_DOKUWIKI

$tree = <<'END_TREE';
Paragraph
  Text 'Link Three: '
  Link { link => ExternalLink->new(uri => URI->new('www.google.com')) }
END_TREE

SKIP: {
    skip 'Schema-less bare links (www.google.com) are not implemented', 1;
    test_doc $text, $tree;
}
