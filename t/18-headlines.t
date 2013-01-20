use strict;
use warnings;

use Test::More tests => 1;
use Test::Text::DokuWiki;

my $text = <<'END_DOKUWIKI';
====== Heading One ======
===== Heading Two =====
==== Heading Three ====
=== Heading Four ===
== Heading Five ==
= Heading Six =
END_DOKUWIKI

my $tree = <<'END_TREE';
Header { content => ' Heading One ',   level => 1 }
Header { content => ' Heading Two ',   level => 2 }
Header { content => ' Heading Three ', level => 3 }
Header { content => ' Heading Four ',  level => 4 }
Header { content => ' Heading Five ',  level => 5 }
Header { content => ' Heading Six ',   level => 6 }
END_TREE

chomp $text;

test_doc $text, $tree;
