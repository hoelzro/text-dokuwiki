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

sub parse {
    my ( $class, $text ) = @_;

    my $doc          = Text::DokuWiki::Document->new;
    my $current_node = ParagraphElement->new(
        parent => $doc,
    );
    $doc->append_child($current_node);

    # XXX this could be cleaner
    my $pop_text_node = sub {
        # XXX this logic is teh suck
        # XXX definitely don't use ref(...) eq $class
        while(ref($current_node) eq TextElement) {
            $current_node = $current_node->parent;
        }
    };

    my $add_and_replace = sub {
        my ( $node_class ) = @_;

        $pop_text_node->();

        my $child_node = $node_class->new(
            parent => $current_node,
        );
        $current_node->append_child($child_node);
        $current_node = $child_node;
    };

    my $add_pseudo_html_node = sub {
        my ( $tag_name ) = @_;

        my $node_class = $PSEUDO_HTML_NODE_CLASSES{$tag_name};
        # XXX barf if !$node_class
        $add_and_replace->($node_class);
    };

    my $remove_pseudo_html_node = sub {
        my ( $tag_name ) = @_;
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
        $current_node = $current_node->parent;
    };

    # XXX getting rid of these would be nice
    my $in_bold_section;
    my $in_italic_section;
    my $in_underlined_section;
    my $in_monospace_section;

    # XXX making the syntax "pluggable" would be nice

    while($text) {
        my $found_match = 1;

        # XXX use \G?
        # XXX compile each component regex into a single regex?
        if($text =~ /\A$HEADER_RE/p) {
            $pop_text_node->();
            $current_node->append_child(HeaderElement->new(
                content => $+{'header_content'},
                parent  => $current_node,
            ));
        } elsif($text =~ /\A[*][*]/p) {
            $in_bold_section = !$in_bold_section;

            if($in_bold_section) {
                $add_and_replace->(BoldElement);
            } else {
                $current_node = $current_node->parent;
            }
        } elsif($text =~ m{\A//}p) {
            $in_italic_section = !$in_italic_section;

            if($in_italic_section) {
                $add_and_replace->(ItalicElement);
            } else {
                $current_node = $current_node->parent;
            }
        } elsif($text =~ /\A__/p) {
            $in_underlined_section = !$in_underlined_section;

            if($in_underlined_section) {
                $add_and_replace->(UnderlinedElement);
            } else {
                $current_node = $current_node->parent;
            }
        } elsif($text =~ /\A''/p) {
            $in_monospace_section = !$in_monospace_section;

            if($in_monospace_section) {
                $add_and_replace->(MonospaceElement);
            } else {
                $current_node = $current_node->parent;
            }
        } elsif($text =~ /\A\n\n/p) {
            while(ref($current_node) ne 'Text::DokuWiki::Document' &&
                  ref($current_node) ne ParagraphElement) {

                $current_node = $current_node->parent;
            }
            if($current_node->isa(ParagraphElement)) {
                $current_node = $current_node->parent;
            }
            $add_and_replace->(ParagraphElement);
        } elsif($text =~ m{\A\\\\[\s\n]}p) {
            $pop_text_node->();
            $current_node->append_child(ForcedNewlineElement->new(
                parent => $current_node,
            ));
        } elsif($text =~ /\A$OPEN_PSEUDO_HTML_RE/p) {
            $add_pseudo_html_node->($+{'tag_name'});
        } elsif($text =~ /\A$CLOSE_PSEUDO_HTML_RE/p) {
            $remove_pseudo_html_node->($+{'tag_name'});
        } elsif($text =~ /\A./sp) {
            unless($current_node->_is_textual) {
                $add_and_replace->(TextElement);
            }
            $current_node->_append_content(${^MATCH});
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

# ABSTRACT:  A short description of Text::DokuWiki

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

L<http://dokuwiki.org>

=cut
