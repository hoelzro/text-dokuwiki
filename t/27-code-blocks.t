#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 9;
use Test::Text::DokuWiki;

my $text = <<'END_DOKUWIKI';
A paragraph.

  A sample code block with no special highlighting.

Another paragraph.
END_DOKUWIKI

my $tree = <<'END_TREE';
Paragraph
  Text 'A paragraph.'
Code
  Text 'A sample code block with no special highlighting.'
Paragraph
  Text 'Another paragraph.'
END_TREE

test_doc $text, $tree;

$text = <<'END_DOKUWIKI';
  More
  Than
  One
  Line!
END_DOKUWIKI

$tree = <<'END_TREE';
Code
  Text "More\nThan\nOne\nLine!"
END_TREE

test_doc $text, $tree;

$text = <<'END_DOKUWIKI';
  Code
    With
      Indent!
END_DOKUWIKI

$tree = <<'END_TREE';
Code
  Text "Code\n  With\n    Indent!"
END_TREE

test_doc $text, $tree;

$text = <<'END_DOKUWIKI';
 This is actually a paragraph.
END_DOKUWIKI

# XXX do we care about this indent?
$tree = <<'END_TREE';
Paragraph
  Text ' This is actually a paragraph.'
END_TREE

test_doc $text, $tree;

$text = <<'END_DOKUWIKI';
  I have some **fake** markup in my code block.
END_DOKUWIKI

$tree = <<'END_TREE';
Code
  Text 'I have some **fake** markup in my code block.'
END_TREE

test_doc $text, $tree, 'fake markup';

$text = <<'END_DOKUWIKI';
<code>
I have some **fake** markup in my code block.
</code>
END_DOKUWIKI

$tree = <<'END_TREE';
Code
  Text 'I have some **fake** markup in my code block.'
END_TREE

test_doc $text, $tree;

$text = <<'END_DOKUWIKI';
<code>I have some **fake** markup in my code block.</code>
END_DOKUWIKI

$tree = <<'END_TREE';
Code
  Text 'I have some **fake** markup in my code block.'
END_TREE

test_doc $text, $tree;

$text = <<'END_DOKUWIKI';
<code>

I have some **fake** markup in my code block.

</code>
END_DOKUWIKI

$tree = <<'END_TREE';
Code
  Text 'I have some **fake** markup in my code block.'
END_TREE

test_doc $text, $tree;

# XXX This is actually *not* compliant with DokuWiki;
#     I'm "fixing" it for this parser.  If full compatibility
#     is desired, I might break it out into a role or offer
#     some capability option or something
$text = <<'END_DOKUWIKI';
<code>
<html>
  <body>
    Here's some fake HTML with <code>code</code> in it.
  </body>
</html>
</code>
END_DOKUWIKI

$tree = <<'END_TREE';
Code
  Text qq{<html>\n  <body>\n    Here's some fake HTML with <code>code</code> in it.\n  </body>\n</html>}
END_TREE

test_doc $text, $tree;

# syntax highlighting
# <code> block with language/name specification
# code block names
# <code> inline with a paragraph
# nested <code attr="value">
