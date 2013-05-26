#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 1;

use Text::DokuWiki;
use Text::DokuWiki::Emitter::HTML;
use Test::HTML::Differences;

my $doc = Text::DokuWiki->parse(<<'END_DOKUWIKI');
This is not \\a forced newline
END_DOKUWIKI

my $html = Text::DokuWiki::Emitter::HTML->emit($doc);
eq_or_diff_html $html, '<p>This is not \\\\a forced newline</p>';
