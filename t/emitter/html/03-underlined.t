use strict;
use warnings;
use Test::More tests => 1;

use Text::DokuWiki;
use Test::Text::DokuWiki;

my $html = Text::DokuWiki->parse(<<'END_DOKUWIKI')->as_html;
I __am__ home!
END_DOKUWIKI

is_html_equal $html, '<p>I <em class="u">am</em> home!</p>';
