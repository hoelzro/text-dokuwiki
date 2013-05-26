#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 1;

use Text::DokuWiki;
use Text::DokuWiki::Emitter::HTML;
use Test::HTML::Differences;

my $doc = Text::DokuWiki->parse(<<'END_DOKUWIKI');
Link One: [[http://google.com|Google]]
Link Two: <john.smith@example.com>
Link Three: [[http://google.com#section|Google Section]]
END_DOKUWIKI

my $html = Text::DokuWiki::Emitter::HTML->emit($doc);
eq_or_diff_html $html, <<'END_HTML';
<p>
  Link One: <a href='http://google.com'>Google</a>
  Link Two: <a href='mailto:john.smith@example.com'>john.smith@example.com</a>
  Link Three: <a href='http://google.com#section'>Google Section</a>
</p>
END_HTML
