use strict;
use warnings;
use Test::More tests => 1;

use Text::DokuWiki;
use Text::DokuWiki::Emitter::HTML;
use Test::HTML::Differences;

my $doc = Text::DokuWiki->parse(<<'END_DOKUWIKI');
I **am** home!
END_DOKUWIKI

my $html = Text::DokuWiki::Emitter::HTML->emit($doc);
eq_or_diff_html $html, '<p>I <strong>am</strong> home!</p>';
