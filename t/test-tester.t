use strict;
use warnings;

use Test::Tester;
use Test::More tests => 18;
use Test::Text::DokuWiki;

my $doc  = Text::DokuWiki::Document->new;
my $para = Text::DokuWiki::Element::Paragraph->new;

$doc->add_child($para);
$para->add_child(Text::DokuWiki::Element::Text->new(content => 'I '));
$para->add_child(Text::DokuWiki::Element::Bold->new(content => 'am'));
$para->add_child(Text::DokuWiki::Element::Text->new(content => ' home!'));

check_test(
  sub {
    test_doc($doc, <<'END_TREE', 'test good doc');
Paragraph
  Text 'I '
  Bold 'am'
  Text ' home!'
END_TREE
  }, {
    ok   => 1,
    name => 'test good doc',
  }
);

check_test(
  sub {
    test_doc($doc, <<'END_TREE', 'test bad doc');
Paragraph
  Text 'I '
  Text 'am'
  Text ' home!'
END_TREE
  }, {
    ok   => 0,
    name => 'test bad doc',
  }
);

check_test(
  sub {
    test_doc($doc, <<'END_TREE', 'test bad tree');
Paragraph
  Text 'I '
 Bold 'am'
  Text ' home!'
END_TREE
  }, {
    ok   => 0,
    name => 'test bad tree',
  }
);
