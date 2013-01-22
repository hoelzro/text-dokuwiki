use strict;
use warnings;

use Test::More tests => 1;
use Test::Text::DokuWiki qw(:DEFAULT :link_classes);

my $text = <<'END_DOKUWIKI';
Link One: [[pagename|text]]
Link Two: [[pagename#section]]
Link Three: [[pagename#section|text]]
END_DOKUWIKI

my $tree = <<'END_TREE';
Paragraph
  Text 'Link One: '
  Link { link => InternalLink->new(page_name => 'pagename', text => 'text') }
  Text "\nLink Two: "
  Link { link => InternalLink->new(page_name => 'pagename', section_name => 'section') }
  Text "\nLink Three: "
  Link { link => InternalLink->new(page_name => 'pagename', section_name => 'section', text => 'text') }
END_TREE

chomp $text;

test_doc $text, $tree;
