#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 4;
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

test_doc $text, $tree;

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

test_doc $text, $tree;

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

test_doc $text, $tree;

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

test_doc $text, $tree;

# XXX Are lists within paragraphs, or outside of them?
# XXX Test markup (like **this**) in list items
# XXX Test unindented list items (they should be regular text)
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
