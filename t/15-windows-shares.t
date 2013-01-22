use strict;
use warnings;

use Test::More tests => 1;
use Test::Text::DokuWiki qw(:DEFAULT :link_classes);

my $text = <<'END_DOKUWIKI';
[[\\windows\share]]

[[\\windows\share|with label]]
END_DOKUWIKI

my $tree = <<'END_TREE';
Paragraph
  Link { link => WindowsShareLink->new(share => q{\\\\windows\\share}) }
Paragraph
  Link { link => WindowsShareLink->new(share => q{\\\\windows\\share}, text => 'with label') }
END_TREE

chomp $text;

test_doc $text, $tree;
