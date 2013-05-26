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
  Link { link => InternalLink->new(page_name => 'pagename', label => 'text') }
  Text ' Link Two: '
  Link { link => InternalLink->new(page_name => 'pagename', section_name => 'section') }
  Text ' Link Three: '
  Link { link => InternalLink->new(page_name => 'pagename', section_name => 'section', label => 'text') }
END_TREE

test_doc $text, $tree;
