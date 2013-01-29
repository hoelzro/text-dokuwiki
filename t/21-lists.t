#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 1;
use Test::Text::DokuWiki;

my $text = <<'END_DOKUWIKI';
Hello!
  * This is a list
  * The second item
    * You may have different levels
  * Another item

  - The same list but ordered
  - Another item
    - Just use indentation for deeper levels
  - That's it
END_DOKUWIKI

my $tree = <<'END_TREE';
Paragraph
  Text "Hello!\n"
  List { ordered => 0 }
    ListItem 'This is a list'
    ListItem 'The second item'
      List { ordered => 0 }
        ListItem 'You may have different levels'
    ListItem 'Another item'
Paragraph
  List { ordered => 1 }
    ListItem 'The same list but ordered'
    ListItem 'Another item'
      List { ordered => 1 }
        ListItem 'Just use indentation for deeper levels'
    ListItem q{That's it}
END_TREE

chomp $text;

test_doc $text, $tree;

# XXX Test markup (like **this**) in list items
# XXX Test unindented list items (they should be regular text)
# XXX Test exceptional circumstances mentioned on https://www.dokuwiki.org/faq:lists
# XXX Test nested an unordered list in an ordered list
