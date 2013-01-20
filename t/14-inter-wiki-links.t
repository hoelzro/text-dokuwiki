use strict;
use warnings;

use Test::More tests => 1;
use Test::Text::DokuWiki;

my $text = <<'END_DOKUWIKI';
[[wp>Wiki]]

[[wp>Wiki|Wikipedia's Article on Wikis]]

[[wp>Wiki#arbitrary_section|Wikipedia's Article on Wikis]]
END_DOKUWIKI

my $tree = <<'END_TREE';
Paragraph
  InterWikiLink { wiki => 'wp', page_name => 'Wiki' }
Paragraph
  InterWikiLink { wiki => 'wp', page_name => 'Wiki', link_text => q{Wikipedia's Article on Wikis} }
Paragraph
  InterWikiLink { wiki => 'wp', page_name => 'Wiki', section_name => 'arbitrary_section', link_text => q{Wikipedia's Article on Wikis} }
END_TREE

chomp $text;

test_doc $text, $tree;
