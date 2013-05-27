#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 1;

use Text::DokuWiki;
use Test::HTML::Differences;

my $html = Text::DokuWiki->parse(<<'END_DOKUWIKI')->as_html;
Link One: [[http://google.com|Google]]
Link Two: <john.smith@example.com>
Link Three: [[http://google.com#section|Google Section]]
END_DOKUWIKI

eq_or_diff_html $html, <<'END_HTML';
<p>
  Link One: <a href='http://google.com'>Google</a>
  Link Two: <a href='mailto:john.smith@example.com'>john.smith@example.com</a>
  Link Three: <a href='http://google.com#section'>Google Section</a>
</p>
END_HTML
