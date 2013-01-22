package Test::Text::DokuWiki;

use strict;
use warnings;
use parent 'Exporter';

use List::MoreUtils qw(uniq);
use Scalar::Util qw(blessed);
use Text::DokuWiki;
use Test::More;

use aliased 'Text::DokuWiki::Link::External'     => 'ExternalLink';
use aliased 'Text::DokuWiki::Link::Internal'     => 'InternalLink';
use aliased 'Text::DokuWiki::Link::InterWiki'    => 'InterWikiLink';
use aliased 'Text::DokuWiki::Link::WindowsShare' => 'WindowsShareLink';

my @LINK_CLASSES = qw{
    ExternalLink
    InternalLink
    InterWikiLink
    WindowsShareLink
};

our @EXPORT      = qw(test_doc);
our @EXPORT_OK   = ( @EXPORT, @LINK_CLASSES );
our %EXPORT_TAGS = (
    link_classes => \@LINK_CLASSES,
);

my $NODE_RE = qr/^(\s*)(\w+)\s*(.*)?$/;

my %CLASS_COMPARATORS = (
    'Text::DokuWiki::Link::External' => \&_general_moose_comparator,
);

my %CLASS_STRINGIFIERS = (
    'Text::DokuWiki::Link::External' => \&_general_moose_stringifier,
    'URI::http'                      => \&_stringify_uri,
);

sub _general_moose_comparator {
    my ( $lhs, $rhs ) = @_;

    return 1;
}

sub _general_moose_stringifier {
    my ( $value ) = @_;

    my $class      = blessed($value);
    my $attributes = _extract_attributes($value);

    return $class . '->new(' . join(', ', map { "$_ => " . _stringify($attributes->{$_}) } keys %$attributes);
}

sub _stringify_uri {
    my ( $uri ) = @_;

    return "URI->new('$uri')";
}

sub _parse_tree {
    my ( $context, $tree ) = @_;

    my @lines        = split /\n/, $tree;
    my @indent_stack = ( 0 );
    my @node_stack   = ( { children => [] } );
    my $previous_node;

    foreach my $line (@lines) {
        my ( $indentation, $node_type, $content );

        unless(( $indentation, $node_type, $content ) = $line =~ /$NODE_RE/) {
            return;
        }
        if($content) {
            my $code = $content;
            $content = eval("package $context; $code");
            unless($content) {
                die "$code did not compile: $@";
            }
        } else {
            $content = undef;
        }
        unless(ref($content) eq 'HASH') {
            $content = { content => $content };
        }
        my $level         = length($indentation);
        my $node          = { type => $node_type, attributes => $content, children => [] };
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

sub _extract_attributes {
    my ( $element ) = @_;

    my $meta = $element->meta;

    my @attributes = grep { $_->name ne 'children' && $_->name ne 'parent' } $meta->get_all_attributes;
    my %hash;

    foreach my $attr (@attributes) {
        $hash{$attr->name} = $attr->get_value($element);
    }

    return \%hash;
}

sub _not_equals {
    my ( $lhs, $rhs ) = @_;

    return 1 if defined($lhs)  && !defined($rhs);
    return 1 if !defined($lhs) && defined($rhs);
    return 0 if !defined($lhs) && !defined($rhs);

    if(blessed($lhs) && blessed($rhs)) {
        if(blessed($lhs) ne blessed($rhs)) {
            return 1;
        }
        my $class      = blessed($lhs);
        my $comparator = $CLASS_COMPARATORS{$class};
        unless($comparator) {
            die "I don't know how to compare objects of type '$class'";
        }
        return $comparator->($lhs, $rhs) != 0;
    } else {
        return $lhs ne $rhs;
    }
}

sub _diff_attributes {
    my ( $lhs, $rhs ) = @_;

    my @diff;

    foreach my $key (keys %$lhs) {
        my $lhs_value = $lhs->{$key};
        my $rhs_value = $rhs->{$key};

        if(_not_equals($lhs_value, $rhs_value)) {
            push @diff, $key;
        }
    }

    foreach my $key (keys %$rhs) {
        my $rhs_value = $rhs->{$key};
        my $lhs_value = $lhs->{$key};

        if(_not_equals($lhs_value, $rhs_value)) {
            push @diff, $key;
        }
    }

    return uniq(@diff);
}

sub _stringify {
    my ( $value ) = @_;

    return 'undef' unless defined($value);
    if(my $class = blessed($value)) {
        my $stringifier = $CLASS_STRINGIFIERS{$class};
        unless($stringifier) {
            die "I don't know how to stringify objects of type '$class'";
        }
        return $stringifier->($value);
    }

    return "$value";
}

sub _check_tree {
    my ( $got, $expected, @path ) = @_;

    push @path, $expected->{'type'} // 'Document';

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    unless($got->isa('Text::DokuWiki::Document')) {
        my $got_type      = ref($got);
        my $expected_type = 'Text::DokuWiki::Element::' . $expected->{'type'};

        if($got_type ne $expected_type) {
            return undef, "Type mismatch: $got_type vs $expected_type";
        }

        my $got_attrs      = _extract_attributes($got);
        my $expected_attrs = $expected->{'attributes'};

        my @diff = _diff_attributes($got_attrs, $expected_attrs);

        if(@diff) {
            my @pieces;
            foreach my $key (@diff) {
                my $got_value      = _stringify($got_attrs->{$key});
                my $expected_value = _stringify($expected_attrs->{$key});
                push @pieces, "  got->$key: $got_value expected->$key $expected_value";
            }
            my $path = join(' => ', @path);
            my $diag = "Attribute mismatch: ($path)\n" . join("\n", @pieces);
            return undef, $diag;
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

        my ( $ok, $diag ) = _check_tree($got_child, $expected_child, @path);

        unless($ok) {
            return $ok, $diag;
        }
    }
    return 1;
}

sub test_doc {
    my ( $doc, $expected_tree, $name ) = @_;

    my $pkg = caller();

    unless(eval { $doc->isa('Text::DokuWiki::Document') }) {
        my $doku = Text::DokuWiki->new;
           $doc  = $doku->parse($doc);
    }

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    $expected_tree = _parse_tree($pkg, $expected_tree);

    unless($expected_tree) {
        fail $name;
        return;
    }

    my ( $ok, $diag ) = _check_tree($doc, $expected_tree);

    ok($ok, $name) || diag($diag);
}

1;
