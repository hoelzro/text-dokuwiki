#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use List::MoreUtils qw(natatime);
use Test::More;
use Test::Text::DokuWiki;

sub create_indented_code_block {
    my ( $text, $code ) = @_;

    if(defined $code) {
        chomp $code;
        $code =~ s/\n/\n  /g;
        $text =~ s/«CODE»/  $code/;
        return $text;
    } else {
        chomp $text;
        $text =~ s/\n/\n  /g;
        return '  ' .$text;
    }
}

sub create_code_block {
    my ( $text, $code ) = @_;

    if(defined $code) {
        chomp $code;
        $code = "<code>$code</code>";
        $text =~ s/«CODE»/$code/;
        return $text;
    } else {
        chomp $text;
        return "<code>$text</code>";
    }
}

my @code_block_types = (
    indented     => \&create_indented_code_block,
    'code block' => \&create_code_block,
);

plan tests => (@code_block_types / 2 * 4 + 5);

my $iterator = natatime(2, @code_block_types);

while(my ( $name, $creator ) = $iterator->()) {
    my $code = 'A sample code block with no special highlighting.';
    my $text = $creator->(<<'END_DOKUWIKI', $code);
A paragraph.

«CODE»

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

    test_doc $text, $tree, "Test $name code block interspersed with paragraphs";

    $text = $creator->(<<'END_DOKUWIKI');
More
Than
One
Line!
END_DOKUWIKI

    $tree = <<'END_TREE';
Code
  Text "More\nThan\nOne\nLine!"
END_TREE

    test_doc $text, $tree, "Test multi-line $name code block";

    $text = $creator->(<<'END_DOKUWIKI');
Code
  With
    Indent!
END_DOKUWIKI

    $tree = <<'END_TREE';
Code
  Text "Code\n  With\n    Indent!"
END_TREE

    test_doc $text, $tree, "Test multi-line $name code block with multiple indent levels";

    $text = $creator->('I have some **fake** markup in my code block.');

    $tree = <<'END_TREE';
Code
  Text 'I have some **fake** markup in my code block.'
END_TREE

    test_doc $text, $tree, "Test fake markup in $name code block";
}

my $text;
my $tree;

$text = <<'END_DOKUWIKI';
 This is actually a paragraph.
END_DOKUWIKI

# XXX do we care about this indent?
$tree = <<'END_TREE';
Paragraph
  Text ' This is actually a paragraph.'
END_TREE

test_doc $text, $tree, 'Test paragraph with a single space of indent';

$text = <<'END_DOKUWIKI';
<code>
I have some **fake** markup in my code block.
</code>
END_DOKUWIKI

$tree = <<'END_TREE';
Code
  Text 'I have some **fake** markup in my code block.'
END_TREE

test_doc $text, $tree, 'Test fake markup in <code> block';

$text = <<'END_DOKUWIKI';
<code>

I have some **fake** markup in my code block.

</code>
END_DOKUWIKI

$tree = <<'END_TREE';
Code
  Text 'I have some **fake** markup in my code block.'
END_TREE

test_doc $text, $tree, 'Test <code> block with variable newlines';

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

test_doc $text, $tree, 'Test <code> block with nested <code> block';

$text = <<'END_DOKUWIKI';
<code>
<html>
  <body>
    Here's some fake HTML with <code class='codey'>code</code> in it.
  </body>
</html>
</code>
END_DOKUWIKI

$tree = <<'END_TREE';
Code
  Text qq{<html>\n  <body>\n    Here's some fake HTML with <code class='codey'>code</code> in it.\n  </body>\n</html>}
END_TREE

test_doc $text, $tree, 'Test <code> block with nested <code attr=value> block';
# syntax highlighting
# <code> block with language/name specification
# code block names
# <code> inline with a paragraph
