#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 1;

use Text::DokuWiki;
use Test::Text::DokuWiki;

my $html = Text::DokuWiki->parse(<<'END_DOKUWIKI')->as_html;
This is not \\a forced newline
END_DOKUWIKI

is_html_equal $html, '<p>This is not \\\\a forced newline</p>';
