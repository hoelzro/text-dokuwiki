#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 1;
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

chomp $text;

test_doc $text, $tree;

# XXX Test markup (like **this**) in list items
# XXX Test unindented list items (they should be regular text)
# XXX Test exceptional circumstances mentioned on https://www.dokuwiki.org/faq:lists
# XXX Test nested an unordered list in an ordered list
# XXX should we mark orderedness with an attribute? or with the class?
# XXX test with forced newlines (should allow multiple lines in a list item)
# XXX test with code blocks
