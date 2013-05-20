use strict;
use warnings;
use Test::More tests => 1;

use Text::DokuWiki;
use Text::DokuWiki::Emitter::HTML;

my $doc = Text::DokuWiki->parse(<<'END_DOKUWIKI');
I <del>am</del> home!
END_DOKUWIKI

my $html = Text::DokuWiki::Emitter::HTML->emit($doc);
is $html, '<p>I <del>am</del> home!</p>';
