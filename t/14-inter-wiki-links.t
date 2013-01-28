use strict;
use warnings;

use Test::More tests => 1;
use Test::Text::DokuWiki qw(:DEFAULT :link_classes);

my $text = <<'END_DOKUWIKI';
[[wp>Wiki]]

[[wp>Wiki|Wikipedia's Article on Wikis]]

[[wp>Wiki#arbitrary_section|Wikipedia's Article on Wikis]]
END_DOKUWIKI

my $tree = <<'END_TREE';
Paragraph
  Link { link => InterWikiLink->new(wiki => 'wp', page_name => 'Wiki') }
Paragraph
  Link { link => InterWikiLink->new(wiki => 'wp', page_name => 'Wiki', label => q{Wikipedia's Article on Wikis}) }
Paragraph
  Link { link => InterWikiLink->new(wiki => 'wp', page_name => 'Wiki', section_name => 'arbitrary_section', label => q{Wikipedia's Article on Wikis}) }
END_TREE

chomp $text;

test_doc $text, $tree;
