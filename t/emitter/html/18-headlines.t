#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 1;

use Text::DokuWiki;
use Test::HTML::Differences;

my $html = Text::DokuWiki->parse(<<'END_DOKUWIKI')->as_html;
====== Heading One ======
===== Heading Two =====
==== Heading Three ====
=== Heading Four ===
== Heading Five ==
= Heading Six =
END_DOKUWIKI

eq_or_diff_html $html, <<'END_HTML';
<h1>Heading One</h1>
<h2>Heading Two</h2>
<h3>Heading Three</h3>
<h4>Heading Four</h4>
<h5>Heading Five</h5>
<h6>Heading Six</h6>
END_HTML
