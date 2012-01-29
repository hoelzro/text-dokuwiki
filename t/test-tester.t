use strict;
use warnings;

use Test::Tester;
use Test::More tests => 24;
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

$doc     = Text::DokuWiki::Document->new;
$para    = Text::DokuWiki::Element::Paragraph->new;
my $bold = Text::DokuWiki::Element::Bold->new(content => 'Two');

$doc->add_child($para);
$para->add_child(Text::DokuWiki::Element::Text->new(content => 'One'));
$para->add_child($bold);
$bold->add_child(Text::DokuWiki::Element::Text->new(content => 'Three'));
$para->add_child(Text::DokuWiki::Element::Text->new(content => 'Four'));

check_test(
  sub {
    test_doc($doc, <<'END_TREE', 'test good doc with more indent');
Paragraph
  Text 'One'
  Bold 'Two'
    Text 'Three'
  Text 'Four'
END_TREE
  }, {
    ok   => 1,
    name => 'test good doc with more indent',
  }
);
