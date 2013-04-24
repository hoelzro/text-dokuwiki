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
Heading { content => ' Heading One ',   level => 1 }
Heading { content => ' Heading Two ',   level => 2 }
Heading { content => ' Heading Three ', level => 3 }
Heading { content => ' Heading Four ',  level => 4 }
Heading { content => ' Heading Five ',  level => 5 }
Heading { content => ' Heading Six ',   level => 6 }
END_TREE

test_doc $text, $tree;
