use strict;
use warnings;

use Test::More tests => 1;
use Test::Text::DokuWiki;

my $text = <<'END_DOKUWIKI';
[[\\windows\share]]

[[\\windows\share|with label]]
END_DOKUWIKI

my $tree = <<'END_TREE';
Paragraph
  WindowsShareLink { share => q{\\\\windows\\share} }
Paragraph
  WindowsShareLink { share => q{\\\\windows\\share}, link_text => 'with label' }
END_TREE

chomp $text;

test_doc $text, $tree;
