use strict;
use warnings;

use Test::More tests => 1;
use Test::Text::DokuWiki qw(:DEFAULT :link_classes);

my $text = <<'END_DOKUWIKI';
{{wiki:dokuwiki-128.png}}
{{wiki:dokuwiki-128.png?50}}
{{wiki:dokuwiki-128.png?200x50}}
{{http://php.net/images/php.gif?200x50}}
{{ wiki:dokuwiki-128.png}}
{{wiki:dokuwiki-128.png }}
{{ wiki:dokuwiki-128.png }}
{{ wiki:dokuwiki-128.png |This is the caption}}
END_DOKUWIKI

my $tree = <<'END_TREE';
Paragraph
  Image { link => InternalLink->new(page_name => 'dokuwiki-128.png') }
  Text "\n"
  Image { link => InternalLink->new(page_name => 'dokuwiki-128.png'), width => 50 }
  Text "\n"
  Image { link => InternalLink->new(page_name => 'dokuwiki-128.png'), width => 200, height => 50 }
  Text "\n"
  Image { link => ExternalLink->new(uri => URI->new('http://php.net/images/php.gif')), width => 200, height => 50 }
  Text "\n"
  Image { link => InternalLink->new(page_name => 'dokuwiki-128.png'), alignment => 'right' }
  Text "\n"
  Image { link => InternalLink->new(page_name => 'dokuwiki-128.png'), alignment => 'left' }
  Text "\n"
  Image { link => InternalLink->new(page_name => 'dokuwiki-128.png'), alignment => 'center' }
  Text "\n"
  Image { link => InternalLink->new(page_name => 'dokuwiki-128.png'), alignment => 'center', caption => 'This is the caption' }
END_TREE

chomp $text;

test_doc $text, $tree;
