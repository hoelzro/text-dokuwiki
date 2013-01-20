use strict;
use warnings;

use Test::More tests => 1;
use Test::Text::DokuWiki;

my $text = <<'END_DOKUWIKI';
Link One: [[http://google.com|Google]]
Link Two: <john.smith@example.com>
Link Three: [[http://google.com#section|Google Section]]
END_DOKUWIKI

my $tree = <<'END_TREE';
Paragraph
  Text 'Link One: '
  ExternalLinkURI { link_uri => 'http://google.com', link_text => 'Google' }
  Text "\nLink Two: "
  EmailAddress 'john.smith@example.com'
  Text "\nLink Three: "
  ExternalLinkURI { link_uri => 'http://google.com#section', link_text => 'Google Section' }
END_TREE

chomp $text;

test_doc $text, $tree;
