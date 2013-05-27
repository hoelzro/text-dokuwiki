#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 2;

use Text::DokuWiki;
use Test::HTML::Differences;

my $html = Text::DokuWiki->parse(<<'END_DOKUWIKI')->as_html;
Link One: http://google.com
Link Two: https://google.com
END_DOKUWIKI

eq_or_diff_html $html, <<'END_HTML';
<p>
  Link One: <a href='http://google.com'>http://google.com</a>
  Link Two: <a href='https://google.com'>https://google.com</a>
</p>
END_HTML

$html = Text::DokuWiki->parse(<<'END_DOKUWIKI')->as_html;
Link Three: www.google.com
END_DOKUWIKI

TODO: {
    local $TODO = 'Schema-less bare links (www.google.com) are not implemented';

    eq_or_diff_html $html, <<'END_HTML';
<p>
  Link Three: <a href='http://www.google.com'>www.google.com</a>
</p>
END_HTML
}
