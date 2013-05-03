#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 1;
use Test::Text::DokuWiki;

my $text = <<'END_DOKUWIKI';
I think we should do it

> No we shouldn't

>> Well, I say we should

> Really?

>> Yes!

>>> Then lets do it!
END_DOKUWIKI

my $tree = <<'END_TREE';
Paragraph
  Text 'I think we should do it'
Quote { level => 1 }
  Text q{ No we shouldn't}
Quote { level => 2 }
  Text ' Well, I say we should'
Quote { level => 1 }
  Text ' Really?'
Quote { level => 2 }
  Text ' Yes!'
Quote { level => 3 }
  Text ' Then lets do it!'
END_TREE

test_doc $text, $tree;
