use strict;
use warnings;

use Test::More tests => 1;
use Test::Text::DokuWiki;

my $text = <<'END_DOKUWIKI';
Link One: [[pagename|text]]
Link Two: [[pagename#section]]
Link Three: [[pagename#section|text]]
END_DOKUWIKI

my $tree = <<'END_TREE';
Paragraph
  Text 'Link One: '
  InternalLink { page_name => 'pagename', link_text => 'text' }
  Text "\nLink Two: "
  InternalLink { page_name => 'pagename', section_name => 'section' }
  Text "\nLink Three: "
  InternalLink { page_name => 'pagename', section_name => 'section', link_text => 'text'}
END_TREE

chomp $text;

test_doc $text, $tree;
