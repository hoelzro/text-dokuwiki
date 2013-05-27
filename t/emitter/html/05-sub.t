use strict;
use warnings;
use Test::More tests => 1;

use Text::DokuWiki;
use Test::HTML::Differences;

my $html = Text::DokuWiki->parse(<<'END_DOKUWIKI')->as_html;
I <sub>am</sub> home!
END_DOKUWIKI

eq_or_diff_html $html, '<p>I <sub>am</sub> home!</p>';
