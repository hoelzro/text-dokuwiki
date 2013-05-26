#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 2;

use Text::DokuWiki;
use Text::DokuWiki::Emitter::HTML;
use Test::HTML::Differences;

my $doc = Text::DokuWiki->parse(<<'END_DOKUWIKI');
Link One: http://google.com
Link Two: https://google.com
END_DOKUWIKI

my $html = Text::DokuWiki::Emitter::HTML->emit($doc);
eq_or_diff_html $html, <<'END_HTML';
<p>
  Link One: <a href='http://google.com'>http://google.com</a>
  Link Two: <a href='https://google.com'>https://google.com</a>
</p>
END_HTML

$doc = Text::DokuWiki->parse(<<'END_DOKUWIKI');
Link Three: www.google.com
END_DOKUWIKI

$html = Text::DokuWiki::Emitter::HTML->emit($doc);

TODO: {
    local $TODO = 'Schema-less bare links (www.google.com) are not implemented';

    eq_or_diff_html $html, <<'END_HTML';
<p>
  Link Three: <a href='http://www.google.com'>www.google.com</a>
</p>
END_HTML
}
