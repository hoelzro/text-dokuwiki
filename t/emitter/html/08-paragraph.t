use strict;
use warnings;
use Test::More tests => 1;

use Text::DokuWiki;
use Test::HTML::Differences;

my $html = Text::DokuWiki->parse(<<'END_DOKUWIKI')->as_html;
I am home!

I'm leaving soon!
END_DOKUWIKI

eq_or_diff_html $html, '<p>I am home!</p><p>I&#39;m leaving soon!</p>';
