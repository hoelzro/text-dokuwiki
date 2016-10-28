use strict;
use warnings;
use Test::More tests => 2;

use Text::DokuWiki;
use Test::Text::DokuWiki;

my $html = Text::DokuWiki->parse(<<'END_DOKUWIKI')->as_html;
This is\\ a forced newline
END_DOKUWIKI

is_html_equal $html, "<p>This is<br />\na forced newline</p>";

$html = Text::DokuWiki->parse(<<'END_DOKUWIKI')->as_html;
This is \\not a forced newline
END_DOKUWIKI

is_html_equal $html, '<p>This is \\\\not a forced newline</p>';
