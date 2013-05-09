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

sub create_code_block_with_newlines {
    my ( $text, $code ) = @_;

    if(defined $code) {
        chomp $code;
        $code = "<code>\n$code\n</code>";
        $text =~ s/«CODE»/$code/;
        return $text;
    } else {
        chomp $text;
        return "<code>\n$text\n</code>";
    }
}

sub create_code_block_with_extra_newlines {
    my ( $text, $code ) = @_;

    if(defined $code) {
        chomp $code;
        $code = "<code>\n\n$code\n\n</code>";
        $text =~ s/«CODE»/$code/;
        return $text;
    } else {
        chomp $text;
        return "<code>\n\n$text\n\n</code>";
    }
}

sub create_code_block_with_language {
    my ( $text, $code ) = @_;

    if(defined $code) {
        chomp $code;
        $code = "<code text>$code</code>";
        $text =~ s/«CODE»/$code/;
        return $text;
    } else {
        chomp $text;
        return "<code text>$text</code>";
    }
}

my @code_block_types = (
    indented                         => \&create_indented_code_block,
    'code block'                     => \&create_code_block,
    'code block with newlines'       => \&create_code_block_with_newlines,
    'code block with extra newlines' => \&create_code_block_with_extra_newlines,
    'code block with language'       => \&create_code_block_with_language,
);

plan tests => (@code_block_types / 2 * 6 + 4);

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
Code { language => 'text', filename => undef }
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
Code { language => 'text', filename => undef }
  Text "More\nThan\nOne\nLine!"
END_TREE

    test_doc $text, $tree, "Test multi-line $name code block";

    $text = $creator->(<<'END_DOKUWIKI');
Code
  With
    Indent!
END_DOKUWIKI

    $tree = <<'END_TREE';
Code { language => 'text', filename => undef }
  Text "Code\n  With\n    Indent!"
END_TREE

    test_doc $text, $tree, "Test multi-line $name code block with multiple indent levels";

    $text = $creator->('I have some **fake** markup in my code block.');

    $tree = <<'END_TREE';
Code { language => 'text', filename => undef }
  Text 'I have some **fake** markup in my code block.'
END_TREE

    test_doc $text, $tree, "Test fake markup in $name code block";

    # XXX This is actually *not* compliant with DokuWiki;
    #     I'm "fixing" it for this parser.  If full compatibility
    #     is desired, I might break it out into a role or offer
    #     some capability option or something
    $text = $creator->(<<'END_DOKUWIKI');
<html>
  <body>
    Here's some fake HTML with <code>code</code> in it.
  </body>
</html>
END_DOKUWIKI

    $tree = <<'END_TREE';
Code { language => 'text', filename => undef }
  Text qq{<html>\n  <body>\n    Here's some fake HTML with <code>code</code> in it.\n  </body>\n</html>}
END_TREE

    test_doc $text, $tree, "Test $name block with nested <code> block";

    $text = $creator->(<<'END_DOKUWIKI');
<html>
  <body>
    Here's some fake HTML with <code class='codey'>code</code> in it.
  </body>
</html>
END_DOKUWIKI

    $tree = <<'END_TREE';
Code { language => 'text', filename => undef }
  Text qq{<html>\n  <body>\n    Here's some fake HTML with <code class='codey'>code</code> in it.\n  </body>\n</html>}
END_TREE

    test_doc $text, $tree, "Test $name block with nested <code attr=value> block";
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
<code java>
public static void main(String[] args) {
    System.out.println("Hello, World!");
}
</code>
END_DOKUWIKI

$tree = <<'END_TREE';
Code { language => 'java', filename => undef }
  Text qq'public static void main(String[] args) {\n    System.out.println("Hello, World!");\n}'
END_TREE

test_doc $text, $tree, 'Test language attribute for non-text code';

$text = <<'END_DOKUWIKI';
<code ->
public static void main(String[] args) {
    System.out.println("Hello, World!");
}
</code>
END_DOKUWIKI

$tree = <<'END_TREE';
Code { language => 'text', filename => undef }
  Text qq'public static void main(String[] args) {\n    System.out.println("Hello, World!");\n}'
END_TREE

test_doc $text, $tree, 'Test highlighting override for text code';

$text = <<'END_DOKUWIKI';
<code java Test.java>
public static void main(String[] args) {
    System.out.println("Hello, World!");
}
</code>
END_DOKUWIKI

$tree = <<'END_TREE';
Code { language => 'java', filename => 'Test.java' }
  Text qq'public static void main(String[] args) {\n    System.out.println("Hello, World!");\n}'
END_TREE

test_doc $text, $tree, 'Test filenames for <code> blocks';

# <code> inline with a paragraph
