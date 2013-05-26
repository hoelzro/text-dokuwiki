#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 1;

use Text::DokuWiki;
use Text::DokuWiki::Emitter::HTML;
use Test::HTML::Differences;

my $doc = Text::DokuWiki->parse(<<'END_DOKUWIKI');
Link One: [[pagename|text]]
Link Two: [[pagename#section]]
Link Three: [[pagename#section|text]]
END_DOKUWIKI

my $html = Text::DokuWiki::Emitter::HTML->emit($doc);
eq_or_diff_html $html, <<'END_HTML';
<p>
  Link One: <a href='pagename'>text</a>
  Link Two: <a href='pagename#section'>pagename</a>
  Link Three: <a href='pagename#section'>text</a>
</p>
END_HTML
