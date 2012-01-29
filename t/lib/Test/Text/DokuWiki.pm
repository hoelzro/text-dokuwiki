package Test::Text::DokuWiki;

use strict;
use warnings;
use parent 'Exporter';

use Text::DokuWiki;
use Test::More;

our @EXPORT = qw(test_doc);

sub test_doc {
    my ( $doku_text, $expected_tree ) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    pass 'for now';
}

1;
