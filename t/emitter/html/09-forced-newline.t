use strict;
use warnings;
use Test::More tests => 2;

use Text::DokuWiki;
use Test::HTML::Differences;

my $html = Text::DokuWiki->parse(<<'END_DOKUWIKI')->as_html;
This is\\ a forced newline
END_DOKUWIKI

eq_or_diff_html $html, "<p>This is<br />\na forced newline</p>";

$html = Text::DokuWiki->parse(<<'END_DOKUWIKI')->as_html;
This is \\not a forced newline
END_DOKUWIKI

eq_or_diff_html $html, '<p>This is \\\\not a forced newline</p>';
