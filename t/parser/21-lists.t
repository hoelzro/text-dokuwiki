#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 12;
use Test::Text::DokuWiki;

my $text = <<'END_DOKUWIKI';
  * This is a list
  * The second item
  * Another item
END_DOKUWIKI

my $tree = <<'END_TREE';
List { ordered => 0 }
  ListItem
    Text ' This is a list'
  ListItem
    Text ' The second item'
  ListItem
    Text ' Another item'
END_TREE

test_doc $text, $tree, 'Test a basic list of unordered items';

$text = <<'END_DOKUWIKI';
  - This is a list
  - The second item
  - Another item
END_DOKUWIKI

$tree = <<'END_TREE';
List { ordered => 1 }
  ListItem
    Text ' This is a list'
  ListItem
    Text ' The second item'
  ListItem
    Text ' Another item'
END_TREE

test_doc $text, $tree, 'Test a basic list of ordered items';

$text = <<'END_DOKUWIKI';
  * This is a list
    * This is a nested sublist
    * Second item of the nested sublist
  * The second item
  * Another item
END_DOKUWIKI

$tree = <<'END_TREE';
List { ordered => 0 }
  ListItem
    Text ' This is a list'
  List { ordered => 0 }
    ListItem
      Text ' This is a nested sublist'
    ListItem
      Text ' Second item of the nested sublist'
  ListItem
    Text ' The second item'
  ListItem
    Text ' Another item'
END_TREE

test_doc $text, $tree, 'Test a nested list';

$text = <<'END_DOKUWIKI';
  * This is a list
  * Item 2
  - First numbered item
  - Second numbered item
  * Item 3
END_DOKUWIKI

$tree = <<'END_TREE';
List { ordered => 0 }
  ListItem
    Text ' This is a list'
  ListItem
    Text ' Item 2'
List { ordered => 1 }
  ListItem
    Text ' First numbered item'
  ListItem
    Text ' Second numbered item'
List { ordered => 0 }
  ListItem
    Text ' Item 3'
END_TREE

test_doc $text, $tree, 'Test a mixture of ordered/unordered items';

$text = <<'END_DOKUWIKI';
  * First Item
  * Second Item
    - Numbered Sublist!
    - More numbered stuff!
  * Third Item
END_DOKUWIKI

$tree = <<'END_TREE';
List { ordered => 0 }
  ListItem
    Text ' First Item'
  ListItem
    Text ' Second Item'
  List { ordered => 1 }
    ListItem
      Text ' Numbered Sublist!'
    ListItem
      Text ' More numbered stuff!'
  ListItem
    Text ' Third Item'
END_TREE

test_doc $text, $tree, 'Test an ordered sublist under an unordered list';

$text = <<'END_DOKUWIKI';
Some text in a paragraph.
  * A
  * list
  * of
  * items
More text.
END_DOKUWIKI

$tree = <<'END_TREE';
Paragraph
  Text 'Some text in a paragraph.'
List { ordered => 0 }
  ListItem
    Text ' A'
  ListItem
    Text ' list'
  ListItem
    Text ' of'
  ListItem
    Text ' items'
Paragraph
  Text "More text."
END_TREE

test_doc $text, $tree, 'Test interleaving of lists and paragraphs';

$text = <<'END_DOKUWIKI';
* Unindented list itemy thing
END_DOKUWIKI

$tree = <<'END_TREE';
Paragraph
  Text '* Unindented list itemy thing'
END_TREE

test_doc $text, $tree, 'Test unindented list items';

$text = <<'END_DOKUWIKI';
  * One
   * Two (note, one space of indent)
  * Three
END_DOKUWIKI

$tree = <<'END_TREE';
List { ordered => 0 }
  ListItem
    Text ' One'
  ListItem
    Text ' Two (note, one space of indent)'
  ListItem
    Text ' Three'
END_TREE

test_doc $text, $tree, 'Test that at least two spaces are required to increase list level';

$text = <<'END_DOKUWIKI';
    * One
END_DOKUWIKI

$tree = <<'END_TREE';
List { ordered => 0 }
  ListItem
    Text ' One'
END_TREE

test_doc $text, $tree, 'Test that four spaces outside of a list only introduces one level';

$text = <<'END_DOKUWIKI';
  * One
      * Two
END_DOKUWIKI

$tree = <<'END_TREE';
List { ordered => 0 }
  ListItem
    Text ' One'
  List { ordered => 0 }
    ListItem
      Text ' Two'
END_TREE

test_doc $text, $tree, 'Test that four spaces indent only introduces a single list level';

$text = <<'END_DOKUWIKI';
  * Contains\\ newline
END_DOKUWIKI

$tree = <<'END_TREE';
List { ordered => 0 }
  ListItem
    Text " Contains\nnewline"
END_TREE

test_doc $text, $tree, 'Test forced newline in list item';

$text = <<'END_DOKUWIKI';
  * Here's some **great** text
END_DOKUWIKI

$tree = <<'END_TREE';
List { ordered => 0 }
  ListItem
    Text q{ Here's some }
    Bold 'great'
    Text ' text'
END_TREE

test_doc $text, $tree, 'Test markup in list item';

# XXX Test exceptional circumstances mentioned on https://www.dokuwiki.org/faq:lists
# XXX test with code blocks
