## no critic (RequireUseStrict)
package Text::DokuWiki;

## use critic (RequireUseStrict)
use Moose;

use 5.010;

use Carp qw(croak);
use Regexp::Common qw(Email::Address URI);
use Text::DokuWiki::Document;

use aliased 'Text::DokuWiki::Element::Bold'             => 'BoldElement';
use aliased 'Text::DokuWiki::Element::Deleted'          => 'DeletedElement';
use aliased 'Text::DokuWiki::Element::EmailAddress'     => 'EmailAddressElement';
use aliased 'Text::DokuWiki::Element::ForcedNewline'    => 'ForcedNewlineElement';
use aliased 'Text::DokuWiki::Element::Header'           => 'HeaderElement';
use aliased 'Text::DokuWiki::Element::Image'            => 'ImageElement';
use aliased 'Text::DokuWiki::Element::Italic'           => 'ItalicElement';
use aliased 'Text::DokuWiki::Element::Link'             => 'LinkElement';
use aliased 'Text::DokuWiki::Element::Monospace'        => 'MonospaceElement';
use aliased 'Text::DokuWiki::Element::Paragraph'        => 'ParagraphElement';
use aliased 'Text::DokuWiki::Element::Subscript'        => 'SubscriptElement';
use aliased 'Text::DokuWiki::Element::Superscript'      => 'SuperscriptElement';
use aliased 'Text::DokuWiki::Element::Text'             => 'TextElement';
use aliased 'Text::DokuWiki::Element::Underlined'       => 'UnderlinedElement';

use aliased 'Text::DokuWiki::Link::External'     => 'ExternalLink';
use aliased 'Text::DokuWiki::Link::Internal'     => 'InternalLink';
use aliased 'Text::DokuWiki::Link::InterWiki'    => 'InterWikiLink';
use aliased 'Text::DokuWiki::Link::WindowsShare' => 'WindowsShareLink';

my $MAX_HEADER_LEVEL = 6;

my $HEADER_RE = qr{
    \s*
    (?<header_level>={1,$MAX_HEADER_LEVEL})
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

my $INTERNAL_LINK_RE = qr{
    [[][[] # leading [[
    (?<link>.*?)

    (?:
      [|]
      (?<link_text>.*?)
    )? # optional link text

    []][]] # trailing ]]
}x;

my $IMAGE_RE = qr{
    [{][{] # leading {{
    (?<right_align_padding>\s*) # optional padding on the left; specifies
                                # right alignment
    (?<link>.*?)
    (?:
      [?]
      (?<width>\d+)
      (?:
        x
        (?<height>\d+)
      )?
    )?
    (?<left_align_padding>\s*) # same deal as the right alignment padding

    (?:
      [|]
      (?<caption>.*?)
    )? # optional caption

    [}][}] # trailing }}
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

sub _create_node {
    my ( $self, $node_class, %params ) = @_;

    return $node_class->new(
        %params,
        parent => $self->current_node,
    );
}

sub _append_child {
    my ( $self, $child, %params ) = @_;

    unless(ref $child) {
        $child = $self->_create_node($child, %params);
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

# XXX add ability to position rules before/after one another
# XXX add ability to override rules
sub _add_parser_rule {
    my ( $self, %params ) = @_;

    my %copy = %params;

    my @required = qw{name pattern handler};
    my @optional = qw{before after};

    delete @copy{@optional}; # we'll process these properly later

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

sub _has_ancestor {
    my ( $self, $node_class ) = @_;

    my $current_node = $self->current_node;

    while(!$current_node->isa('Text::DokuWiki::Document')) {
        if($current_node->isa($node_class)) {
            return 1;
        }
        $current_node = $current_node->parent;
    }
    return;
}

sub _self_closing_element {
    my ( $self, $node_class ) = @_;

    return sub {
        my ( $parser ) = @_;

        $parser->_requires_paragraph;
        if($parser->_has_ancestor($node_class)) {
            $parser->_up;
        } else {
            $parser->_down($node_class);
        }
    };
}

sub _finish_paragraph {
    my ( $self ) = @_;

    while(!$self->current_node->isa('Text::DokuWiki::Document') &&
          !$self->current_node->isa(ParagraphElement)) {

        $self->_up;
    }
    if($self->current_node->isa(ParagraphElement)) {
        $self->_up;
    }
}

sub _parse_square_bracket_link {
    my ( $self, %params ) = @_;

    my $link = delete $params{'link'};
    my $text = $params{'text'};

    if($text =~ /$IMAGE_RE/) {
        $text = $self->_parse_image(
            right_align_padding => $+{'right_align_padding'},
            link                => $+{'link'},
            left_align_padding  => $+{'left_align_padding'},
            caption             => $+{'caption'},
            width               => $+{'width'},
            height              => $+{'height'},
        );
        $text->{'parent'} = undef; # XXX EVIL EVIL EVIL
    }

    if($link =~ $RE{URI}{HTTP}{-scheme => qr/https?/}) {
        $link = ExternalLink->new(
            uri  => $link,
            text => $text,
        );
    } elsif($link =~ /\A(?<wiki>\w+)>(?<page_name>.*?)(?:#(?<section_name>.*))?$/) {
        $link = InterWikiLink->new(
            wiki         => $+{'wiki'},
            page_name    => $+{'page_name'},
            section_name => $+{'section_name'},
            text         => $text,
        );
    } elsif($link =~ m{\A\\\\}) {
        $link = WindowsShareLink->new(
            share => $link,
            text  => $text,
        );
    } else {
        if($link =~ /(?<page_name>.*)#(?<section_name>.*)/) {
            $link = InternalLink->new(
                page_name    => $+{'page_name'},
                section_name => $+{'section_name'},
                text         => $text,
            );
        } else {
            $link = InternalLink->new(
                page_name => $link,
                text      => $text,
            );
        }
    }

    return $self->_create_node(
        LinkElement,
        link => $link,
    );
}

sub _parse_image {
    my ( $self, %params ) = @_;

    my $alignment;

    if($params{'right_align_padding'} ne '') {
        if($params{'left_align_padding'} ne '') {
            $alignment = 'center';
        } else {
            $alignment = 'right';
        }
    } elsif($params{'left_align_padding'} ne '') {
        $alignment = 'left';
    }

    my $link = $params{'link'};

    if($link =~ s/^wiki://) {
        $link = InternalLink->new(
            page_name => $link,
        );
    } else {
        $link = ExternalLink->new(
            uri => $link,
        );
    }

    return $self->_create_node(
        ImageElement,
        link      => $link,
        caption   => $params{'caption'},
        alignment => $alignment,
        width     => $params{'width'},
        height    => $params{'height'},
    );
}

sub _requires_paragraph {
    my ( $self ) = @_;

    unless($self->_has_ancestor(ParagraphElement)) {
        while(! $self->current_node->isa('Text::DokuWiki::Document')) {
            $self->_up;
        }
        $self->_down(ParagraphElement);
    }
}

sub BUILD {
    my ( $self ) = @_;

    $self->_add_parser_rule(
        name    => 'section_header',
        pattern => $HEADER_RE,
        handler => sub {
            my ( $parser, $match ) = @_;
            $parser->_finish_paragraph;
            $parser->_append_child(HeaderElement,
                content => $+{'header_content'},
                level   => ($MAX_HEADER_LEVEL + 1) - length($+{'header_level'}),
            );
        },
    );

    $self->_add_parser_rule(
        name    => 'bold',
        pattern => qr/[*][*]/,
        handler => $self->_self_closing_element(BoldElement),
    );

    $self->_add_parser_rule(
        name    => 'italic',
        pattern => qr{//},
        handler => $self->_self_closing_element(ItalicElement),
    );

    $self->_add_parser_rule(
        name    => 'underlined',
        pattern => qr/__/,
        handler => $self->_self_closing_element(UnderlinedElement),
    );

    $self->_add_parser_rule(
        name    => 'monospace',
        pattern => qr/''/,
        handler => $self->_self_closing_element(MonospaceElement),
    );

    $self->_add_parser_rule(
        name    => 'paragraph',
        pattern => qr/\n\n/,
        handler => sub {
            my ( $parser ) = @_;

            $parser->_finish_paragraph;
            $parser->_down(ParagraphElement);
        },
    );

    $self->_add_parser_rule(
        name    => 'forced_newline',
        pattern => qr{\\\\[\s\n]},
        handler => sub {
            my ( $parser ) = @_;

            $parser->_pop_text_node;
            $parser->_append_child(ForcedNewlineElement);
        },
    );

    $self->_add_parser_rule(
        name    => 'open_pseudo_html',
        pattern => $OPEN_PSEUDO_HTML_RE,
        handler => sub {
            my ( $parser ) = @_;

            $parser->_add_pseudo_html_node($+{'tag_name'});
        },
    );

    $self->_add_parser_rule(
        name => 'close_pseudo_html',
        pattern => $CLOSE_PSEUDO_HTML_RE,
        handler => sub {
            my ( $parser ) = @_;

            $parser->_remove_pseudo_html_node($+{'tag_name'});
        },
    );

    $self->_add_parser_rule(
        name    => 'external_link_uri',
        pattern => $RE{URI}{HTTP}{-scheme => qr/https?/},
        handler => sub {
            my ( $parser, $match ) = @_;

            $parser->_requires_paragraph;
            $parser->_pop_text_node;
            $parser->_append_child(LinkElement,
                link => ExternalLink->new(
                    uri => $match,
                ),
            );
        },
    );

    $self->_add_parser_rule(
        name    => 'external_link_mail',
        pattern => qr/<(?<address>$RE{Email}{Address})>/,
        handler => sub {
            my ( $parser, $match ) = @_;

            $parser->_requires_paragraph;
            $parser->_pop_text_node;
            $parser->_append_child(EmailAddressElement,
                content => $+{'address'},
            );
        },
    );

    $self->_add_parser_rule(
        name    => 'internal_link',
        pattern => $INTERNAL_LINK_RE,
        handler => sub {
            my ( $parser, $match ) = @_;

            $parser->_requires_paragraph;
            $parser->_pop_text_node;
            $parser->_append_child($parser->_parse_square_bracket_link(
                link => $+{'link'},
                text => $+{'link_text'},
            ));
        },
    );

    $self->_add_parser_rule(
        name    => 'image',
        pattern => $IMAGE_RE,
        handler => sub {
            my ( $parser, $match ) = @_;

            $parser->_requires_paragraph;
            $parser->_pop_text_node;
            $parser->_append_child($parser->_parse_image(
                right_align_padding => $+{'right_align_padding'},
                link                => $+{'link'},
                left_align_padding  => $+{'left_align_padding'},
                caption             => $+{'caption'},
                width               => $+{'width'},
                height              => $+{'height'},
            ));
        },
    );
}

sub parse {
    my ( $self, $text ) = @_;

    unless(ref($self)) {
        $self = $self->new;
    }

    my $doc = Text::DokuWiki::Document->new;
    $self->current_node($doc);

    TEXT_LOOP:
    while($text) {
        # XXX use \G?
        # XXX compile each component regex into a single regex?
        foreach my $parser_rule (@{ $self->parser_rules }) {
            my ( $pattern, $handler ) = @{$parser_rule}{qw/pattern handler/};

            if($text =~ /\A$pattern/p) {
                $handler->($self, ${^MATCH});
                $text = ${^POSTMATCH};
                next TEXT_LOOP;
            }
        }

        if($text =~ /\A./sp) {
            $self->_requires_paragraph;
            unless($self->current_node->_is_textual) {
                $self->_down(TextElement);
            }
            $self->_append_content(${^MATCH});
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
