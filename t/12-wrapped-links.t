use strict;
use warnings;

use Test::More tests => 1;
use Test::Text::DokuWiki;

my $text = <<'END_DOKUWIKI';
Link One: [[http://google.com|Google]]
Link Two: <john.smith@example.com>
END_DOKUWIKI

my $tree = <<'END_TREE';
Paragraph
  Text 'Link One: '
  ExternalLinkURI { link_uri => 'http://google.com', link_text => 'Google' }
  Text "\nLink Two: "
  EmailAddress 'john.smith@example.com'
END_TREE

chomp $text;

test_doc $text, $tree;
