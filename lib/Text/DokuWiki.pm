## no critic (RequireUseStrict)
package Text::DokuWiki;

## use critic (RequireUseStrict)
use Moose;

use 5.010;

use Carp qw(croak);
use Text::DokuWiki::Document;

use aliased 'Text::DokuWiki::Element::Bold'          => 'BoldElement';
use aliased 'Text::DokuWiki::Element::Deleted'       => 'DeletedElement';
use aliased 'Text::DokuWiki::Element::ForcedNewline' => 'ForcedNewlineElement';
use aliased 'Text::DokuWiki::Element::Header'        => 'HeaderElement';
use aliased 'Text::DokuWiki::Element::Italic'        => 'ItalicElement';
use aliased 'Text::DokuWiki::Element::Monospace'     => 'MonospaceElement';
use aliased 'Text::DokuWiki::Element::Paragraph'     => 'ParagraphElement';
use aliased 'Text::DokuWiki::Element::Subscript'     => 'SubscriptElement';
use aliased 'Text::DokuWiki::Element::Superscript'   => 'SuperscriptElement';
use aliased 'Text::DokuWiki::Element::Text'          => 'TextElement';
use aliased 'Text::DokuWiki::Element::Underlined'    => 'UnderlinedElement';

my $HEADER_RE = qr{
    \s*
    (?<header_level>={1,6})
    (?<header_content>.*?)
    \k<header_level>
    \s*
    $
}xm;

my $OPEN_PSEUDO_HTML_RE = qr{
    <(?<tag_name>\w+)>
}x;

my $CLOSE_PSEUDO_HTML_RE = qr{
    </(?<tag_name>\w+)>
}x;

my %PSEUDO_HTML_NODE_CLASSES = (
    del   => DeletedElement,
    'sub' => SubscriptElement,
    super => SuperscriptElement,
);

has current_node => (
    is      => 'rw',
    handles => {
        _append_content => '_append_content',
    },
);

has parser_rules => (
    is      => 'ro',
    default => sub { [] },
);

sub _append_child {
    my ( $self, $child, %params ) = @_;

    unless(ref $child) {
        $child = $child->new(
            %params,
            parent => $self->current_node,
        );
    }

    $self->current_node->append_child($child);
    return $child;
}

sub _pop_text_node {
    my ( $self ) = @_;

    my $node = $self->current_node;

    # XXX this logic is teh suck
    while($node->isa(TextElement)) {
        $node = $node->parent;
    }
    $self->current_node($node);
}

sub _down {
    my ( $self, $child, %params ) = @_;

    $self->_pop_text_node;
    $child = $self->_append_child($child, %params);
    $self->current_node($child);
}

sub _up {
    my ( $self ) = @_;

    $self->current_node($self->current_node->parent);
}

# XXX should <del>...</del> create an HTMLElement->new(tag => 'del'), or a
#     DeletedElement?
sub _add_pseudo_html_node {
    my ( $self, $tag_name ) = @_;

    my $node_class = $PSEUDO_HTML_NODE_CLASSES{$tag_name};
    # XXX barf if !$node_class
    $self->_down($node_class);
}

sub _remove_pseudo_html_node {
    my ( $self, $tag_name ) = @_;

    my $current_node = $self->current_node;

    my $node_class = $PSEUDO_HTML_NODE_CLASSES{$tag_name};
    # XXX barf if !$node_class

    # XXX it should probably be the direct parent, right?
    while(!$current_node->isa($node_class) &&
          !$current_node->isa('Text::DokuWiki::Document')) {

        $current_node = $current_node->parent;
    }
    if($current_node->isa('Text::DokuWiki::Document')) {
        # XXX we can't find the matching node, barf
    }
    $self->current_node($current_node->parent);
}

sub _add_parser_rule {
    my ( $self, %params ) = @_;

    my %copy = %params;

    my @required = qw{name pattern handler};

    foreach my $param (@required) {
        unless(exists $copy{$param}) {
            croak "argument '$param' required";
        }
        delete $copy{$param};
    }
    my @remaining = keys %copy;
    if(@remaining) {
        croak "invalid argument '$remaining[0]' passed to _add_parser_rule";
    }

    push @{$self->parser_rules}, \%params;
}

sub parse {
    my ( $self, $text ) = @_;

    unless(ref($self)) {
        $self = $self->new;
    }

    my $doc = Text::DokuWiki::Document->new;
    $self->current_node($doc);
    $self->_down(ParagraphElement);

    # XXX getting rid of these would be nice
    my $in_bold_section;
    my $in_italic_section;
    my $in_underlined_section;
    my $in_monospace_section;

    TEXT_LOOP:
    while($text) {
        foreach my $parser_rule (@{ $self->parser_rules }) {
            my ( $pattern, $handler ) = @{$parser_rule}{qw/pattern handler/};

            if($text =~ /\A$pattern/p) {
                $handler->($self, ${^MATCH});
                $text = ${^POSTMATCH};
                next TEXT_LOOP;
            }
        }

        my $found_match = 1;

        # XXX use \G?
        # XXX compile each component regex into a single regex?
        if($text =~ /\A$HEADER_RE/p) {
            $self->_pop_text_node;
            $self->_append_child(HeaderElement,
                content => $+{'header_content'},
            );
        } elsif($text =~ /\A[*][*]/p) {
            $in_bold_section = !$in_bold_section;

            if($in_bold_section) {
                $self->_down(BoldElement);
            } else {
                $self->_up;
            }
        } elsif($text =~ m{\A//}p) {
            $in_italic_section = !$in_italic_section;

            if($in_italic_section) {
                $self->_down(ItalicElement);
            } else {
                $self->_up;
            }
        } elsif($text =~ /\A__/p) {
            $in_underlined_section = !$in_underlined_section;

            if($in_underlined_section) {
                $self->_down(UnderlinedElement);
            } else {
                $self->_up;
            }
        } elsif($text =~ /\A''/p) {
            $in_monospace_section = !$in_monospace_section;

            if($in_monospace_section) {
                $self->_down(MonospaceElement);
            } else {
                $self->_up;
            }
        } elsif($text =~ /\A\n\n/p) {
            while(!$self->current_node->isa('Text::DokuWiki::Document') &&
                  !$self->current_node->isa(ParagraphElement)) {

                $self->_up;
            }
            if($self->current_node->isa(ParagraphElement)) {
                $self->_up;
            }
            $self->_down(ParagraphElement);
        } elsif($text =~ m{\A\\\\[\s\n]}p) {
            $self->_pop_text_node;
            $self->_append_child(ForcedNewlineElement);
        } elsif($text =~ /\A$OPEN_PSEUDO_HTML_RE/p) {
            $self->_add_pseudo_html_node($+{'tag_name'});
        } elsif($text =~ /\A$CLOSE_PSEUDO_HTML_RE/p) {
            $self->_remove_pseudo_html_node($+{'tag_name'});
        } elsif($text =~ /\A./sp) {
            unless($self->current_node->_is_textual) {
                $self->_down(TextElement);
            }
            $self->_append_content(${^MATCH});
        } else {
            $found_match = 0;
        }

        if($found_match) {
            $text = ${^POSTMATCH};
        } else {
            croak "Confused: '$text'";
        }
    }

    return $doc;
}

1;

__END__

# ABSTRACT: A parser for DokuWiki markup language (https://www.dokuwiki.org/)

=head1 SYNOPSIS

  use Text::DokuWiki;

  my $doku = Text::DokuWiki->new;
  my $doc  = $doku->parse($text);
  say $doc->as_html;

=head1 DESCRIPTION

This module is a parser for the markup language that
DokuWiki uses.

=head1 METHODS

=head2 Text::DokuWiki->new

Creates a new DokuWiki syntax parser.

=head2 $doku->parse($text)

Parses C<$text> as a DokuWiki document and returns
a L<Text::DokuWiki::Document> object.

=head1 UNSUPPORTED SYNTAX

The amount of syntax that we support in comparison
to the official DokuWiki parser will grow over time.
I don't know if we'll ever support PHP code blocks, though.

=head1 SEE ALSO

=over 4

=item *

L<http://dokuwiki.org>

=item *

L<http://dokuwiki.org/wiki:syntax>

=back

=cut
