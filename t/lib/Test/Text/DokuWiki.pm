package Test::Text::DokuWiki;

use strict;
use warnings;
use parent 'Exporter';

use Text::DokuWiki;
use Test::More;

our @EXPORT = qw(test_doc);

my $NODE_RE = qr/^(\s*)(\w+)\s*(.*)?$/;

sub _parse_tree {
    my ( $tree ) = @_;

    my @lines        = split /\n/, $tree;
    my @indent_stack = ( 0 );
    my @node_stack   = ( { children => [] } );
    my $previous_node;

    foreach my $line (@lines) {
        my ( $indentation, $node_type, $content );

        unless(( $indentation, $node_type, $content ) = $line =~ /$NODE_RE/) {
            return;
        }
           $content       = defined($content) ? eval($content) : '';
        my $level         = length($indentation);
        my $node          = { type => $node_type, content => $content, children => [] };
        my $current_level = $indent_stack[-1];
        my $current_node  = $node_stack[-1];

        if($level < $current_level) {
            pop @indent_stack;
            pop @node_stack;
            if($level != $indent_stack[-1]) {
                return;
            }
            push @{ $node_stack[-1]->{'children'} }, $node;
        } elsif($level == $current_level) {
            push @{ $current_node->{'children'} }, $node;
        } else { # $level > $current_level
            push @{ $previous_node->{'children'} }, $node;
            push @node_stack, $previous_node;
            push @indent_stack, $level;
        }

        $previous_node = $node;
    }

    return $node_stack[0];
}

sub _check_tree {
    my ( $got, $expected ) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    unless($got->isa('Text::DokuWiki::Document')) {
        my $got_type      = ref($got);
        my $expected_type = 'Text::DokuWiki::Element::' . $expected->{'type'};

        if($got_type ne $expected_type) {
            return undef, "Type mismatch: $got_type vs $expected_type";
        }

        my $got_content      = $got->content;
        my $expected_content = $expected->{'content'};

        $got_content      = '' unless defined $got_content;
        $expected_content = '' unless defined $expected_content;

        if($got_content ne $expected_content) {
            return undef, "Content mismatch:\ngot: '$got_content'\nexpected: '$expected_content'";
        }
    }

    my $got_children      = $got->children;
    my $expected_children = $expected->{'children'};

    if(@$got_children != @$expected_children) {
        my $n_got      = @$got_children;
        my $n_expected = @$expected_children;

        return undef, "# children mismatch: $n_got vs $n_expected";
    }

    for(my $i = 0; $i < @$got_children; $i++) {
        my $got_child      = $got_children->[$i];
        my $expected_child = $expected_children->[$i];

        my ( $ok, $diag ) = _check_tree($got_child, $expected_child);

        unless($ok) {
            return $ok, $diag;
        }
    }
    return 1;
}

sub test_doc {
    my ( $doc, $expected_tree, $name ) = @_;

    unless(eval { $doc->isa('Text::DokuWiki::Document') }) {
        my $doku = Text::DokuWiki->new;
           $doc  = $doku->parse($doc);
    }

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    $expected_tree = _parse_tree($expected_tree);

    unless($expected_tree) {
        fail $name;
        return;
    }

    my ( $ok, $diag ) = _check_tree($doc, $expected_tree);

    ok($ok, $name) || diag($diag);
}

1;
