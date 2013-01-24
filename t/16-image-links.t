use strict;
use warnings;

use Test::More tests => 1;
use Test::Text::DokuWiki qw(:DEFAULT :link_classes :element_classes);
use URI;

my $text = <<'END_DOKUWIKI';
[[http://php.net|{{wiki:dokuwiki-128.png}}]]
END_DOKUWIKI

my $tree = <<'END_TREE';
Paragraph
  Link { link => ExternalLink->new(uri => 'http://php.net', text => ImageElement->new(link => InternalLink->new(page_name => 'dokuwiki-128.png'))) }
END_TREE

chomp $text;

test_doc $text, $tree;
