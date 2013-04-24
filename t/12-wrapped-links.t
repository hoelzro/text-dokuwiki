use strict;
use warnings;

use Test::More tests => 1;
use Test::Text::DokuWiki qw(:DEFAULT :link_classes);
use URI;

my $text = <<'END_DOKUWIKI';
Link One: [[http://google.com|Google]]
Link Two: <john.smith@example.com>
Link Three: [[http://google.com#section|Google Section]]
END_DOKUWIKI

my $tree = <<'END_TREE';
Paragraph
  Text 'Link One: '
  Link { link => ExternalLink->new(uri => URI->new('http://google.com'), label => 'Google') }
  Text "\nLink Two: "
  EmailAddress 'john.smith@example.com'
  Text "\nLink Three: "
  Link { link => ExternalLink->new(uri => URI->new('http://google.com#section'), label => 'Google Section') }
END_TREE

test_doc $text, $tree;
