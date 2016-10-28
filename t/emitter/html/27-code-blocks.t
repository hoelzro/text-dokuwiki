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

sub create_file_block {
    my ( $text, $code ) = @_;

    if(defined $code) {
        chomp $code;
        $code = "<file>$code</file>";
        $text =~ s/«CODE»/$code/;
        return $text;
    } else {
        chomp $text;
        return "<file>$text</file>";
    }
}

sub create_file_block_with_newlines {
    my ( $text, $code ) = @_;

    if(defined $code) {
        chomp $code;
        $code = "<file>\n$code\n</file>";
        $text =~ s/«CODE»/$code/;
        return $text;
    } else {
        chomp $text;
        return "<file>\n$text\n</file>";
    }
}

sub create_file_block_with_extra_newlines {
    my ( $text, $code ) = @_;

    if(defined $code) {
        chomp $code;
        $code = "<file>\n\n$code\n\n</file>";
        $text =~ s/«CODE»/$code/;
        return $text;
    } else {
        chomp $text;
        return "<file>\n\n$text\n\n</file>";
    }
}

sub create_file_block_with_language {
    my ( $text, $code ) = @_;

    if(defined $code) {
        chomp $code;
        $code = "<file text>$code</file>";
        $text =~ s/«CODE»/$code/;
        return $text;
    } else {
        chomp $text;
        return "<file text>$text</file>";
    }
}

my @code_block_types = (
    indented                         => \&create_indented_code_block,
    'code block'                     => \&create_code_block,
    'code block with newlines'       => \&create_code_block_with_newlines,
    'code block with extra newlines' => \&create_code_block_with_extra_newlines,
    'code block with language'       => \&create_code_block_with_language,
    'file block'                     => \&create_file_block,
    'file block with newlines'       => \&create_file_block_with_newlines,
    'file block with extra newlines' => \&create_file_block_with_extra_newlines,
    'file block with language'       => \&create_file_block_with_language,
);

plan tests => (@code_block_types / 2 * 6 + 5);

my $dw       = 'Text::DokuWiki';
my $iterator = natatime(2, @code_block_types);

while(my ( $name, $creator ) = $iterator->()) {
    my $code = 'A sample code block with no special highlighting.';
    my $text = $creator->(<<'END_DOKUWIKI', $code);
A paragraph.

«CODE»

Another paragraph.
END_DOKUWIKI

    is_html_equal($dw->parse($text)->as_html, <<'END_HTML');
<p>A paragraph.</p>
<pre>
A sample code block with no special highlighting.
</pre>
<p>Another paragraph.</p>
END_HTML

    $text = $creator->(<<'END_DOKUWIKI');
More
Than
One
Line!
END_DOKUWIKI


    is_html_equal($dw->parse($text)->as_html, <<'END_HTML');
<pre>
More
Than
One
Line!
</pre>
END_HTML

    $text = $creator->(<<'END_DOKUWIKI');
Code
  With
    Indent!
END_DOKUWIKI

    is_html_equal($dw->parse($text)->as_html, <<'END_HTML');
<pre>
Code
  With
    Indent!
</pre>
END_HTML

    $text = $creator->('I have some **fake** markup in my code block.');

    is_html_equal($dw->parse($text)->as_html, <<'END_HTML');
<pre>
I have some **fake** markup in my code block.
</pre>
END_HTML

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

    is_html_equal($dw->parse($text)->as_html, <<'END_HTML');
<pre>
&lt;html&gt;
  &lt;body&gt;
    Here&apos;s some fake HTML with &lt;code&gt;code&lt;/code&gt; in it.
  &lt;/body&gt;
&lt;/html&gt;
</pre>
END_HTML

    $text = $creator->(<<'END_DOKUWIKI');
<html>
  <body>
    Here's some fake HTML with <code class='codey'>code</code> in it.
  </body>
</html>
END_DOKUWIKI

    is_html_equal($dw->parse($text)->as_html, <<'END_HTML');
<pre>
&lt;html&gt;
  &lt;body&gt;
    Here&apos;s some fake HTML with &lt;code class=&apos;codey&apos;&gt;code&lt;/code&gt; in it.
  &lt;/body&gt;
&lt;/html&gt;
</pre>
END_HTML

}
my $text;

$text = <<'END_DOKUWIKI';
 This is actually a paragraph.
END_DOKUWIKI

is_html_equal($dw->parse($text)->as_html, <<'END_HTML');
<p> This is actually a paragraph.</p>
END_HTML

$text = <<'END_DOKUWIKI';
<code java>
public static void main(String[] args) {
    System.out.println("Hello, World!");
}
</code>
END_DOKUWIKI

# XXX NOTE: We don't have links for Java classes
is_html_equal($dw->parse($text)->as_html, <<'END_HTML');
<pre class='java'>
public static void main(String[] args) {
    System.out.println(&quot;Hello, World!&quot;);
}
</pre>
END_HTML

$text = <<'END_DOKUWIKI';
<code ->
public static void main(String[] args) {
    System.out.println("Hello, World!");
}
</code>
END_DOKUWIKI

is_html_equal($dw->parse($text)->as_html, <<'END_HTML');
<pre>
public static void main(String[] args) {
    System.out.println(&quot;Hello, World!&quot;);
}
</pre>
END_HTML

$text = <<'END_DOKUWIKI';
<code java Test.java>
public static void main(String[] args) {
    System.out.println("Hello, World!");
}
</code>
END_DOKUWIKI

# XXX href?
is_html_equal($dw->parse($text)->as_html, <<'END_HTML');
<dl class='code'>
<dt><a href=''>Test.java</a></dt>
<dd>
<pre class='java'>
public static void main(String[] args) {
    System.out.println(&quot;Hello, World!&quot;);
}
</pre>
</dd>
</dl>
END_HTML

$text = <<'END_DOKUWIKI';
This is a paragraph with <code>embedded</code> code.
END_DOKUWIKI

is_html_equal($dw->parse($text)->as_html, <<'END_HTML');
<p>This is a paragraph with </p>
<pre>embedded</pre>
<p> code.</p>
END_HTML
