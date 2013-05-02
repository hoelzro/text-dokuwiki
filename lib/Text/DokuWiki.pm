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
use aliased 'Text::DokuWiki::Element::Footnote'         => 'FootnoteElement';
use aliased 'Text::DokuWiki::Element::Heading'          => 'HeadingElement';
use aliased 'Text::DokuWiki::Element::Image'            => 'ImageElement';
use aliased 'Text::DokuWiki::Element::Italic'           => 'ItalicElement';
use aliased 'Text::DokuWiki::Element::Link'             => 'LinkElement';
use aliased 'Text::DokuWiki::Element::List'             => 'ListElement';
use aliased 'Text::DokuWiki::Element::ListItem'         => 'ListItemElement';
use aliased 'Text::DokuWiki::Element::Monospace'        => 'MonospaceElement';
use aliased 'Text::DokuWiki::Element::NoTOC'            => 'NoTOCElement';
use aliased 'Text::DokuWiki::Element::Paragraph'        => 'ParagraphElement';
use aliased 'Text::DokuWiki::Element::Subscript'        => 'SubscriptElement';
use aliased 'Text::DokuWiki::Element::Superscript'      => 'SuperscriptElement';
use aliased 'Text::DokuWiki::Element::Text'             => 'TextElement';
use aliased 'Text::DokuWiki::Element::Underlined'       => 'UnderlinedElement';

use aliased 'Text::DokuWiki::Link::External'     => 'ExternalLink';
use aliased 'Text::DokuWiki::Link::Internal'     => 'InternalLink';
use aliased 'Text::DokuWiki::Link::InterWiki'    => 'InterWikiLink';
use aliased 'Text::DokuWiki::Link::WindowsShare' => 'WindowsShareLink';

my $IS_DEBUGGING = 0;

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
      (?<link_label>.*?)
    )? # optional link label

    []][]] # trailing ]]
}x;

my $IMAGE_RE = qr{
    [{][{] # leading {{
    (?<right_align_padding>\s*) # optional padding on the left; specifies
                                # right alignment
    (?<source>.*?)
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
    default => sub { {} },
);

has state_augmentations => (
    is      => 'ro',
    default => sub { {} },
);

has state_stack => (
    is      => 'ro',
    default => sub { ['top'] },
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

sub _diag {
    my ( $self, $message ) = @_;

    print STDERR "# $message\n";
}

# XXX instead of this, shouldn't we just append the previous child if it's a TextElement?
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

    # XXX do we want to pop the text node?
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

    my @required = qw{name pattern handler state};
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

    my $state = delete $params{'state'};

    push @{$self->parser_rules->{$state}}, \%params;
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

        # XXX do this with state?
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

    my $link  = delete $params{'link'};
    my $label = $params{'label'};

    if(defined($label) && $label =~ /$IMAGE_RE/) {
        $label = $self->_parse_image(
            right_align_padding => $+{'right_align_padding'},
            source              => $+{'source'},
            left_align_padding  => $+{'left_align_padding'},
            caption             => $+{'caption'},
            width               => $+{'width'},
            height              => $+{'height'},
        );
        $label->{'parent'} = undef; # XXX EVIL EVIL EVIL
    }

    if($link =~ $RE{URI}{HTTP}{-scheme => qr/https?/}) {
        $link = ExternalLink->new(
            uri   => $link,
            label => $label,
        );
    } elsif($link =~ /\A(?<wiki>\w+)>(?<page_name>.*?)(?:#(?<section_name>.*))?$/) {
        $link = InterWikiLink->new(
            wiki         => $+{'wiki'},
            page_name    => $+{'page_name'},
            section_name => $+{'section_name'},
            label        => $label,
        );
    } elsif($link =~ m{\A\\\\}) {
        $link = WindowsShareLink->new(
            share => $link,
            label => $label,
        );
    } else {
        if($link =~ /(?<page_name>.*)#(?<section_name>.*)/) {
            $link = InternalLink->new(
                page_name    => $+{'page_name'},
                section_name => $+{'section_name'},
                label        => $label,
            );
        } else {
            $link = InternalLink->new(
                page_name => $link,
                label     => $label,
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

    my $source = $params{'source'};

    if($source =~ s/^wiki://) {
        $source = InternalLink->new(
            page_name => $source,
        );
    } else {
        $source = ExternalLink->new(
            uri => $source,
        );
    }

    return $self->_create_node(
        ImageElement,
        source    => $source,
        caption   => $params{'caption'},
        alignment => $alignment,
        width     => $params{'width'},
        height    => $params{'height'},
    );
}

sub _push_state {
    my ( $self, $state ) = @_;

    $self->_diag("entering state $state") if $IS_DEBUGGING;

    push @{$self->state_stack}, $state;
}

sub _pop_state {
    my ( $self ) = @_;

    if($IS_DEBUGGING) {
        my $state = $self->_current_state;
        $self->_diag("leaving state $state");
    }

    pop @{$self->state_stack};
}

sub _current_state {
    my ( $self ) = @_;

    return $self->state_stack->[-1];
}

sub _get_parser_rules {
    my ( $self ) = @_;

    my @rules;

    my $state = $self->_current_state;
    my $augmentations = $self->state_augmentations->{$state};

    return [
        @{$self->parser_rules->{$state}},
        map {
            @{$self->parser_rules->{$_}}
        } @$augmentations
    ];
}

sub _augment_state {
    my ( $self, $state, @augmentations ) = @_;

    push @{$self->state_augmentations->{$state}}, @augmentations;
}

sub BUILD {
    my ( $self ) = @_;

    ### Inline Rules
    $self->_add_parser_rule(
        name    => 'bold',
        state   => 'inline',
        pattern => qr/[*][*]/,
        handler => $self->_self_closing_element(BoldElement),
    );

    $self->_add_parser_rule(
        name    => 'italic',
        state   => 'inline',
        pattern => qr{//},
        handler => $self->_self_closing_element(ItalicElement),
    );

    $self->_add_parser_rule(
        name    => 'underlined',
        state   => 'inline',
        pattern => qr/__/,
        handler => $self->_self_closing_element(UnderlinedElement),
    );

    $self->_add_parser_rule(
        name    => 'monospace',
        state   => 'inline',
        pattern => qr/''/,
        handler => $self->_self_closing_element(MonospaceElement),
    );

    $self->_add_parser_rule(
        name    => 'forced_newline',
        state   => 'inline',
        pattern => qr{\\\\[\s\n]},
        handler => sub {
            my ( $parser ) = @_;

            unless($self->current_node->_is_textual) {
                $self->_down(TextElement);
            }
            # XXX should we represent this with a link break element object?
            $self->_append_content("\n");
        },
    );

    $self->_add_parser_rule(
        name    => 'open_pseudo_html',
        state   => 'inline',
        pattern => $OPEN_PSEUDO_HTML_RE,
        handler => sub {
            my ( $parser ) = @_;

            $parser->_add_pseudo_html_node($+{'tag_name'});
        },
    );

    # XXX add a state for this?
    $self->_add_parser_rule(
        name => 'close_pseudo_html',
        state => 'inline',
        pattern => $CLOSE_PSEUDO_HTML_RE,
        handler => sub {
            my ( $parser ) = @_;

            $parser->_remove_pseudo_html_node($+{'tag_name'});
        },
    );

    $self->_add_parser_rule(
        name    => 'external_link_uri',
        state   => 'inline',
        pattern => $RE{URI}{HTTP}{-scheme => qr/https?/},
        handler => sub {
            my ( $parser, $match ) = @_;

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
        state   => 'inline',
        pattern => qr/<(?<address>$RE{Email}{Address})>/,
        handler => sub {
            my ( $parser, $match ) = @_;

            $parser->_pop_text_node;
            $parser->_append_child(EmailAddressElement,
                content => $+{'address'},
            );
        },
    );

    $self->_add_parser_rule(
        name    => 'internal_link',
        state   => 'inline',
        pattern => $INTERNAL_LINK_RE,
        handler => sub {
            my ( $parser, $match ) = @_;

            $parser->_pop_text_node;
            $parser->_append_child($parser->_parse_square_bracket_link(
                link  => $+{'link'},
                label => $+{'link_label'},
            ));
        },
    );

    $self->_add_parser_rule(
        name    => 'image',
        state   => 'inline',
        pattern => $IMAGE_RE,
        handler => sub {
            my ( $parser, $match ) = @_;

            $parser->_pop_text_node;
            $parser->_append_child($parser->_parse_image(
                right_align_padding => $+{'right_align_padding'},
                source              => $+{'source'},
                left_align_padding  => $+{'left_align_padding'},
                caption             => $+{'caption'},
                width               => $+{'width'},
                height              => $+{'height'},
            ));
        },
    );

    $self->_add_parser_rule(
        name    => 'footnotes',
        state   => 'inline',
        pattern => qr/[(][(](?<footnote>.*?)[)][)]/,
        handler => sub {
            my ( $parser, $match ) = @_;

            $parser->_pop_text_node;
            $parser->_append_child(FootnoteElement,
                content => $+{'footnote'},
            );
        },
    );

    ### Paragraph Rules

    # XXX this has to be the first rule in paragraph
    $self->_add_parser_rule(
        name    => 'end_paragraph',
        state   => 'paragraph',
        pattern => qr/\n/,
        handler => sub {
            my ( $parser ) = @_;

            $parser->_finish_paragraph;
            $parser->_pop_state;
        },
    );

    ### Top Level Rules

    # XXX do we need these rules in the paragraph state to properly do them?
    $self->_add_parser_rule(
        name    => 'notoc',
        state   => 'top',
        pattern => qr/~~NOTOC~~/,
        handler => sub {
            my ( $parser ) = @_;

            $parser->_append_child(NoTOCElement);
        },
    );

    $self->_add_parser_rule(
        name    => 'section_header',
        state   => 'top',
        pattern => $HEADER_RE,
        handler => sub {
            my ( $parser, $match ) = @_;
            $parser->_finish_paragraph;
            $parser->_append_child(HeadingElement,
                content => $+{'header_content'},
                level   => ($MAX_HEADER_LEVEL + 1) - length($+{'header_level'}),
            );
        },
    );

    # XXX enter into a state
    $self->_add_parser_rule(
        name    => 'lists',
        state   => 'top',
        pattern => qr/^(?<indent>\s{2,})(?<list_char>[*-])(?<list_item_content>[^\n]+)$/m,
        handler => sub {
            my ( $parser ) = @_;

            $parser->_finish_paragraph;

            my $last_child = $parser->current_node->last_child;
            my $parent_list;

            my $ordered = ($+{'list_char'} eq '-') ? 1 : 0;
            my $content = $+{'list_item_content'};
            my $indent  = $+{'indent'};
            $indent     =~ s/^\n//; # for some reason, we sometimes have a leading newline
            $indent     = length($indent);

            $indent-- if $indent % 2 == 1; # we only care about increments of two spaces or more

            if($last_child && $last_child->isa(ListElement)) {
                $parent_list       = $last_child;
                my $last_list_item = $parent_list->last_child; # we assume here that no listelement is empty

                while($last_list_item->isa(ListElement)) {
                    my $sublist    = $last_list_item;
                    if($sublist->last_child->_indent > $indent) {
                        last;
                    }
                    $parent_list    = $sublist;
                    $last_list_item = $parent_list->last_child;
                }
                if($last_list_item->_indent < $indent) {
                    my $super_list = $parent_list;
                    $parent_list = ListElement->new(
                        ordered => $ordered,
                        parent  => $super_list,
                        _indent  => $last_list_item->_indent,
                    );
                    $super_list->append_child($parent_list);
                } elsif($ordered != $parent_list->ordered) {
                    my $superlist = $parent_list->parent;

                    $parent_list = ListElement->new(
                        ordered => $ordered,
                        parent  => $superlist,
                        _indent  => $last_list_item->_indent,
                    );
                    $superlist->append_child($parent_list);
                }
            } else {
                $parent_list = $parser->_append_child(ListElement,
                    ordered => $ordered,
                    _indent => 0,
                );
            }

            my $child = ListItemElement->new(
                content => $content,
                _indent => $indent,
                parent  => $parent_list,
            );

            $parent_list->append_child($child);
        }
    );

    $self->_add_parser_rule(
        name    => 'close_paragraph',
        state   => 'top',
        pattern => qr/\n/,
        handler => sub {
            my ( $parser ) = @_;

            my $last_child = $parser->current_node->last_child;

            if($last_child && $last_child->isa(ParagraphElement)) {
                $last_child->_close;
            }
        },
    );

    $self->_add_parser_rule(
        name    => 'start_paragraph',
        state   => 'top',
        pattern => qr//,
        handler => sub {
            my ( $parser ) = @_;

            my $last_child = $parser->current_node->last_child;

            if($last_child && $last_child->isa(ParagraphElement) && !$last_child->_is_closed) {
                my $paragraph = $last_child;
                $parser->current_node($paragraph);
                $last_child = $paragraph->last_child;
                if($last_child && $last_child->_is_textual) {
                    $last_child->_append_content("\n");
                } else {
                    $last_child = $self->_append_child(TextElement,
                        content => "\n",
                    );
                }
                $parser->current_node($last_child);
            } else {
                $parser->_down(ParagraphElement);
            }

            $parser->_push_state('paragraph');
        },
    );

    $self->_augment_state(paragraph => 'inline');
}

sub parse {
    my ( $self, $text ) = @_;

    unless(ref($self)) {
        $self = $self->new;
    }

    my $doc = Text::DokuWiki::Document->new;
    $self->current_node($doc);

    # XXX normalize newlines?

    TEXT_LOOP:
    while($text) {
        # XXX use \G?
        # XXX compile each component regex into a single regex?
        # XXX I'll probably want to inline this
        my $rules = $self->_get_parser_rules;

        foreach my $parser_rule (@$rules) {
            my ( $pattern, $handler ) = @{$parser_rule}{qw/pattern handler/};

            if($text =~ /\A$pattern/p) {
                if($IS_DEBUGGING) {
                    $self->_diag('text matched pattern ' . $parser_rule->{'name'});
                }
                $handler->($self, ${^MATCH});
                $text = ${^POSTMATCH};
                next TEXT_LOOP;
            }
        }

        #if($self->_current_state eq 'inline') {
            # XXX move this into inline rules
            # XXX I think there's probably a more efficient way to go about this;
            #     namely, finding all of the possible "next chars" for the paragraph
            #     state and matching an arbitrarily long sequence of *not* those
            if($text =~ /\A./sp) {
                unless($self->current_node->_is_textual) {
                    $self->_down(TextElement);
                }
                $self->_append_content(${^MATCH});
                $text = ${^POSTMATCH};
            } else {
                croak "Confused: '$text'";
            }
        #} else {
            #croak "Confused: '$text'";
        #}
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
