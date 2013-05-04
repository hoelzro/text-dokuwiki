package Test::Text::DokuWiki;

use strict;
use warnings;
use parent 'Exporter';

use Data::Dumper;
use List::MoreUtils qw(none uniq);
use Scalar::Util qw(blessed);
use Text::DokuWiki;
use Test::More;

use aliased 'Text::DokuWiki::Link::External'     => 'ExternalLink';
use aliased 'Text::DokuWiki::Link::Internal'     => 'InternalLink';
use aliased 'Text::DokuWiki::Link::InterWiki'    => 'InterWikiLink';
use aliased 'Text::DokuWiki::Link::WindowsShare' => 'WindowsShareLink';

use aliased 'Text::DokuWiki::Element::Image'     => 'ImageElement';
use aliased 'Text::DokuWiki::Element::Link'      => 'LinkElement';
use aliased 'Text::DokuWiki::Element::Paragraph' => 'ParagraphElement';

my @LINK_CLASSES = qw{
    ExternalLink
    InternalLink
    InterWikiLink
    WindowsShareLink
};

my @ELEMENT_CLASSES = qw{
    ImageElement
    LinkElement
    ParagraphElement
};

our @EXPORT      = qw(test_doc);
our @EXPORT_OK   = ( @EXPORT, @LINK_CLASSES, @ELEMENT_CLASSES );
our %EXPORT_TAGS = (
    element_classes => \@ELEMENT_CLASSES,
    link_classes    => \@LINK_CLASSES,
);

my $NODE_RE = qr/^(\s*)(\w+)\s*(.*)?$/;

my %CLASS_COMPARATORS = (
    'Text::DokuWiki::Element::Image'     => \&_general_moose_comparator,
    'Text::DokuWiki::Link::External'     => \&_general_moose_comparator,
    'Text::DokuWiki::Link::Internal'     => \&_general_moose_comparator,
    'Text::DokuWiki::Link::InterWiki'    => \&_general_moose_comparator,
    'Text::DokuWiki::Link::WindowsShare' => \&_general_moose_comparator,
    'URI::http'                          => \&_uri_comparator,
    'URI::https'                         => \&_uri_comparator,
);

my %CLASS_STRINGIFIERS = (
    'Text::DokuWiki::Element::Image'     => \&_general_moose_stringifier,
    'Text::DokuWiki::Link::External'     => \&_general_moose_stringifier,
    'Text::DokuWiki::Link::Internal'     => \&_general_moose_stringifier,
    'Text::DokuWiki::Link::InterWiki'    => \&_general_moose_stringifier,
    'Text::DokuWiki::Link::WindowsShare' => \&_general_moose_stringifier,
    'URI::http'                          => \&_stringify_uri,
    'URI::https'                         => \&_stringify_uri,
);

my @test_predicates = (sub { 1 });

sub _general_moose_comparator {
    my ( $lhs, $rhs ) = @_;

    my $lhs_attrs = _extract_attributes($lhs);
    my $rhs_attrs = _extract_attributes($rhs);

    foreach my $attr_name (keys %$lhs_attrs) {
        my $lhs_value = $lhs_attrs->{$attr_name};
        my $rhs_value = $rhs_attrs->{$attr_name};

        if(_not_equals($lhs_value, $rhs_value)) {
            return 1;
        }
    }

    return 0;
}

sub _uri_comparator {
    my ( $lhs, $rhs ) = @_;

    return $lhs == $rhs;
}

sub _general_moose_stringifier {
    my ( $value ) = @_;

    my $class      = blessed($value);
    my $attributes = _extract_attributes($value);

    return $class . '->new(' . join(', ', map { "$_ => " . _stringify($attributes->{$_}) } keys %$attributes) . ')';
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
            while(@indent_stack && $level < $indent_stack[-1]) {
                pop @indent_stack;
                pop @node_stack;
            }
            return unless @indent_stack;
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
    my ( $element, $include_private ) = @_;

    my $meta = $element->meta;

    my @attributes = grep { $_->name ne 'children' && $_->name ne 'parent' && ($include_private || $_->name !~ /^_/) } $meta->get_all_attributes;
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
        return $comparator->($lhs, $rhs);
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

sub _summarize_diff {
    my ( $diff, $text_path, $got_attrs, $expected_attrs ) = @_;

    my @pieces;
    foreach my $key (@$diff) {
        my $got_value      = _stringify($got_attrs->{$key});
        my $expected_value = _stringify($expected_attrs->{$key});
        push @pieces, "  got->$key: $got_value expected->$key $expected_value";
    }
    $text_path = join(' => ', @$text_path);
    return "Attribute mismatch: ($text_path)\n" . join("\n", @pieces);
}

sub _diff_children {
    my %params = @_;

    my $got_children      = $params{'got'};
    my $expected_children = $params{'expected'};
    my $recurse           = $params{'recurse'};
    my $text_path         = $params{'text_path'};
    my $parent            = $params{'parent'};

    if(@$got_children != @$expected_children) {
        my $n_got      = @$got_children;
        my $n_expected = @$expected_children;

        return undef, "# children mismatch: $n_got vs $n_expected";
    }

    for(my $i = 0; $i < @$got_children; $i++) {
        my $got_child      = $got_children->[$i];
        my $expected_child = $expected_children->[$i];

        unless($got_child->parent == $parent) {
            return undef, { message => q{parent doesn't match} };
        }

        my ( $ok, $diag ) = $recurse->($got_child, $expected_child, @$text_path);

        unless($ok) {
            return $ok, $diag;
        }
    }

    return 1;
}

sub _check_tree {
    my ( $got, $expected, @text_path ) = @_;

    push @text_path, $expected->{'type'} // 'Document';

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    unless($got->isa('Text::DokuWiki::Document')) {
        my $got_type      = ref($got);
        my $expected_type = 'Text::DokuWiki::Element::' . $expected->{'type'};

        if($got_type ne $expected_type) {
            return undef, { message => "Type mismatch: $got_type vs $expected_type" };
        }

        my $got_attrs      = _extract_attributes($got);
        my $expected_attrs = $expected->{'attributes'};

        my @diff = _diff_attributes($got_attrs, $expected_attrs);

        if(@diff) {
            return undef, { message => _summarize_diff(\@diff, \@text_path, $got_attrs, $expected_attrs) };
        }
    }

    return _diff_children(
        parent    => $got,
        got       => $got->children,
        expected  => $expected->{'children'},
        recurse   => \&_check_tree,
        text_path => \@text_path,
    );
}

sub _check_document {
    my ( $got, $expected, @text_path ) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    unless(ref($got) eq ref($expected)) {
        my $text_path      = join(' => ', @text_path);
        my $got_class      = ref($got);
        my $expected_class = ref($expected);
        return undef, { message => "Type mismatch: ($text_path)\ngot:      $got_class\nexpected: $expected_class" };
    }

    my $got_attrs      = _extract_attributes($got);
    my $expected_attrs = _extract_attributes($expected);
    my @diff           = _diff_attributes($got_attrs, $expected_attrs);

    if(@diff) {
        return undef, { message => _summarize_diff(\@diff, \@text_path, $got_attrs, $expected_attrs) };
    }

    my $type = ref($got);
    $type    =~ s/^Text::DokuWiki::(?:Element::)?//;
    push @text_path, $type;

    return _diff_children(
        parent    => $got,
        got       => $got->children,
        expected  => $expected->children,
        recurse   => \&_check_document,
        text_path => \@text_path,
    );
}

sub dump_tree {
    my ( $doc, $dumper, $indent_level ) = @_;

    unless($dumper) {
        unless(eval { $doc->isa('Text::DokuWiki::Document') }) {
            my $doku = Text::DokuWiki->new;
               $doc  = $doku->parse($doc);
        }

        $dumper = Data::Dumper->new([]);
        $dumper->Indent(0);
        $dumper->Terse(1);
        $dumper->Quotekeys(0);
        $dumper->Maxdepth(1);
        $dumper->Sortkeys(1);
    }

    $indent_level //= 0;

    if($indent_level == 0) {
        diag('');
    }

    my $indent = ' ' x $indent_level;

    my $class = ref($doc);
    $class    =~ s/^Text::DokuWiki::(?:Element::)?//;
    my $attrs = _extract_attributes($doc);
    if(exists $attrs->{'content'} && none { $_ ne 'content' } keys %$attrs) {
        $attrs = $attrs->{'content'};
    }

    $dumper->Values([ $attrs ]);
    $dumper->Reset;

    if(defined $attrs) {
        diag($indent . $class . ' ' . $dumper->Dump);
    } else {
        diag($indent . $class);
    }
    my $children = $doc->can('children') ? $doc->children : [];

    foreach my $child (@$children){
        dump_tree($child, $dumper, $indent_level + 1);
    }
}

sub test_doc {
    my ( $doc, $expected_tree, $name ) = @_;

    my ( $pkg, undef, $line ) = caller();

    if(none { $_->($line, $name) } @test_predicates) {
        SKIP: {
            skip q{This is not the test you're looking for}, 1;
        }
        return;
    }

    unless(eval { $doc->isa('Text::DokuWiki::Document') }) {
        chomp $doc;
        my $doku = Text::DokuWiki->new;
           $doc  = $doku->parse($doc);
    }

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my ( $ok, $diag );
    if(eval { $expected_tree->isa('Text::DokuWiki::Document') }) {
        ( $ok, $diag ) = _check_document($doc, $expected_tree);
    } else {
        my $parsed_tree = _parse_tree($pkg, $expected_tree);

        unless($parsed_tree) {
            fail $name;
            return;
        }
        ( $ok, $diag ) = _check_tree($doc, $parsed_tree);
    }

    unless(ok($ok, $name)) {
        diag($diag->{'message'});
        diag("expected tree:\n$expected_tree");
        diag('got tree:');
        dump_tree($doc);
    }
}

if(@ARGV) {
    @test_predicates = ();

    foreach my $predicate (@ARGV) {
        if($predicate =~ /^[+](?<line_no>\d+)$/) {
            my $test_line = $+{'line_no'};

            push @test_predicates, sub {
                my ( $line ) = @_;

                return $test_line == $line;
            };
        } else {
            my $test_re = qr/$predicate/;

            push @test_predicates, sub {
                my ( undef, $name ) = @_;

                return defined($name) && $name =~ /$test_re/;
            };
        }
    }
}

1;
