use strict;
use warnings;

use Test::More tests => 1;
use Test::Text::DokuWiki qw(:DEFAULT :link_classes :element_classes);
use URI;

my $text = <<'END_DOKUWIKI';
[[http://php.net|{{wiki:dokuwiki-128.png}}]]
END_DOKUWIKI

my $tree = Text::DokuWiki::Document->new;
my $para = ParagraphElement->new(
    parent => $tree,
);
$tree->append_child($para);
my $link = LinkElement->new(
    parent => $para,
);
$para->append_child($link);
$link->link(ExternalLink->new(
    uri  => URI->new('http://php.net'),
    text => ImageElement->new(
        parent => $link,
        source => InternalLink->new(
            page_name => 'dokuwiki-128.png',
        ),
    ),
));

chomp $text;

test_doc $text, $tree;
