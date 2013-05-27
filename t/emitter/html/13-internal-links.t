#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 1;

use Text::DokuWiki;
use Test::HTML::Differences;

my $html = Text::DokuWiki->parse(<<'END_DOKUWIKI')->as_html;
Link One: [[pagename|text]]
Link Two: [[pagename#section]]
Link Three: [[pagename#section|text]]
END_DOKUWIKI

eq_or_diff_html $html, <<'END_HTML';
<p>
  Link One: <a href='pagename'>text</a>
  Link Two: <a href='pagename#section'>pagename</a>
  Link Three: <a href='pagename#section'>text</a>
</p>
END_HTML
