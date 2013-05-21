use strict;
use warnings;
use Test::More tests => 2;

use Text::DokuWiki;
use Text::DokuWiki::Emitter::HTML;

my $doc = Text::DokuWiki->parse(<<'END_DOKUWIKI');
This is\\ a forced newline
END_DOKUWIKI

my $html = Text::DokuWiki::Emitter::HTML->emit($doc);
is $html, "<p>This is<br />\na forced newline</p>";

$doc = Text::DokuWiki->parse(<<'END_DOKUWIKI');
This is \\not a forced newline
END_DOKUWIKI

$html = Text::DokuWiki::Emitter::HTML->emit($doc);
is $html, '<p>This is \\\\not a forced newline</p>';
