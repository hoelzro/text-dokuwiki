#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 7;
use Test::Text::DokuWiki;

my $text = <<'END_DOKUWIKI';
  * This is a list
  * The second item
  * Another item
END_DOKUWIKI

my $tree = <<'END_TREE';
List { ordered => 0 }
  ListItem ' This is a list'
  ListItem ' The second item'
  ListItem ' Another item'
END_TREE

test_doc $text, $tree, 'Test a basic list of unordered items';

$text = <<'END_DOKUWIKI';
  - This is a list
  - The second item
  - Another item
END_DOKUWIKI

$tree = <<'END_TREE';
List { ordered => 1 }
  ListItem ' This is a list'
  ListItem ' The second item'
  ListItem ' Another item'
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
  ListItem ' This is a list'
  List { ordered => 0 }
    ListItem ' This is a nested sublist'
    ListItem ' Second item of the nested sublist'
  ListItem ' The second item'
  ListItem ' Another item'
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
  ListItem ' This is a list'
  ListItem ' Item 2'
List { ordered => 1 }
  ListItem ' First numbered item'
  ListItem ' Second numbered item'
List { ordered => 0 }
  ListItem ' Item 3'
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
  ListItem ' First Item'
  ListItem ' Second Item'
  List { ordered => 1 }
    ListItem ' Numbered Sublist!'
    ListItem ' More numbered stuff!'
  ListItem ' Third Item'
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
  ListItem ' A'
  ListItem ' list'
  ListItem ' of'
  ListItem ' items'
Paragraph
  Text "\nMore text."
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

# XXX Test markup (like **this**) in list items
# XXX Test exceptional circumstances mentioned on https://www.dokuwiki.org/faq:lists
# XXX Test nested an unordered list in an ordered list
# XXX should we mark orderedness with an attribute? or with the class?
# XXX test with forced newlines (should allow multiple lines in a list item)
# XXX test with code blocks
# XXX what about this:
#   * One
#    * Two (note, *one* space of indent)
#   * Three
# XXX also this:
#     * One (first item: four spaces indent)
