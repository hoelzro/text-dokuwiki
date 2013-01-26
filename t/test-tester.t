use strict;
use warnings;

use Test::Tester;
use Test::More tests => 42;
use Test::Text::DokuWiki;

my $doc  = Text::DokuWiki::Document->new;
my $para = Text::DokuWiki::Element::Paragraph->new(
    parent => $doc,
);

$doc->append_child($para);
$para->append_child(Text::DokuWiki::Element::Text->new(content => 'I ', parent => $para));
$para->append_child(Text::DokuWiki::Element::Bold->new(content => 'am', parent => $para));
$para->append_child(Text::DokuWiki::Element::Text->new(content => ' home!', parent => $para));

check_test(
  sub {
    test_doc($doc, <<'END_TREE', 'test good doc');
Paragraph
  Text 'I '
  Bold 'am'
  Text ' home!'
END_TREE
  }, {
    ok    => 1,
    name  => 'test good doc',
  }
);

check_test(
  sub {
    my $expected = Text::DokuWiki::Document->new;
    my $para = Text::DokuWiki::Element::Paragraph->new(
        parent => $expected,
    );

    $expected->append_child($para);
    $para->append_child(Text::DokuWiki::Element::Text->new(content => 'I ', parent => $para));
    $para->append_child(Text::DokuWiki::Element::Bold->new(content => 'am', parent => $para));
    $para->append_child(Text::DokuWiki::Element::Text->new(content => ' home!', parent => $para));

    test_doc($doc, $expected, 'test good doc');
  }, {
    ok    => 1,
    name  => 'test good doc',
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
    my $expected = Text::DokuWiki::Document->new;
    my $para = Text::DokuWiki::Element::Paragraph->new(
        parent => $expected,
    );

    $expected->append_child($para);
    $para->append_child(Text::DokuWiki::Element::Text->new(content => 'I ', parent => $para));
    $para->append_child(Text::DokuWiki::Element::Text->new(content => 'am', parent => $para));
    $para->append_child(Text::DokuWiki::Element::Text->new(content => ' home!', parent => $para));

    test_doc($doc, $expected, 'test bad doc');
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
$para    = Text::DokuWiki::Element::Paragraph->new(parent => $doc);
my $bold = Text::DokuWiki::Element::Bold->new(content => 'Two', parent => $para);

$doc->append_child($para);
$para->append_child(Text::DokuWiki::Element::Text->new(content => 'One', parent => $para));
$para->append_child($bold);
$bold->append_child(Text::DokuWiki::Element::Text->new(content => 'Three', parent => $bold));
$para->append_child(Text::DokuWiki::Element::Text->new(content => 'Four', parent => $para));

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

check_test(
  sub {
    my $expected = Text::DokuWiki::Document->new;
    $para        = Text::DokuWiki::Element::Paragraph->new(parent => $expected);
    my $bold     = Text::DokuWiki::Element::Bold->new(content => 'Two', parent => $para);

    $expected->append_child($para);
    $para->append_child(Text::DokuWiki::Element::Text->new(content => 'One', parent => $para));
    $para->append_child($bold);
    $bold->append_child(Text::DokuWiki::Element::Text->new(content => 'Three', parent => $bold));
    $para->append_child(Text::DokuWiki::Element::Text->new(content => 'Four', parent => $para));

    test_doc($doc, $expected, 'test good doc with more depth');
  }, {
    ok   => 1,
    name => 'test good doc with more depth',
  }
);
