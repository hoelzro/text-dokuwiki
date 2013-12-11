package Text::DokuWiki::Emitter::HTML;

use Moose;

use HTML::Escape qw(escape_html);

use aliased 'Text::DokuWiki::Element::Bold'             => 'BoldElement';
use aliased 'Text::DokuWiki::Element::Code'             => 'CodeElement';
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
use aliased 'Text::DokuWiki::Element::NoCache'          => 'NoCacheElement';
use aliased 'Text::DokuWiki::Element::NoTOC'            => 'NoTOCElement';
use aliased 'Text::DokuWiki::Element::Paragraph'        => 'ParagraphElement';
use aliased 'Text::DokuWiki::Element::Quote'            => 'QuoteElement';
use aliased 'Text::DokuWiki::Element::Subscript'        => 'SubscriptElement';
use aliased 'Text::DokuWiki::Element::Superscript'      => 'SuperscriptElement';
use aliased 'Text::DokuWiki::Element::Text'             => 'TextElement';
use aliased 'Text::DokuWiki::Element::Underlined'       => 'UnderlinedElement';

use aliased 'Text::DokuWiki::Link::External'     => 'ExternalLink';
use aliased 'Text::DokuWiki::Link::Internal'     => 'InternalLink';
use aliased 'Text::DokuWiki::Link::InterWiki'    => 'InterWikiLink';
use aliased 'Text::DokuWiki::Link::WindowsShare' => 'WindowsShareLink';

with 'Text::DokuWiki::Role::Emitter';

sub _process_content {
    my ( $content ) = @_;

    $content = escape_html($content);
    $content =~ s{\n}{<br />\n}g;

    return $content;
}

# XXX how to handle <title>?
after BUILD => sub {
    my ( $self ) = @_;

    $self->_add_emitter_rule_pre(TextElement, sub {
        my ( $self, $element ) = @_;

        return _process_content($element->content);
    });

    $self->_add_emitter_rule_pre(ParagraphElement, sub {
        return '<p>';
    });

    $self->_add_emitter_rule_post(ParagraphElement, sub {
        return '</p>';
    });

    $self->_add_emitter_rule_pre(BoldElement, sub {
        my ( $self, $element ) = @_;

        return '<strong>' . _process_content($element->content) . '</strong>';
    });

    $self->_add_emitter_rule_pre(ItalicElement, sub {
        my ( $self, $element ) = @_;

        return '<em>' . _process_content($element->content) . '</em>';
    });

    $self->_add_emitter_rule_pre(UnderlinedElement, sub {
        my ( $self, $element ) = @_;

        return '<em class="u">' . _process_content($element->content) . '</em>';
    });

    $self->_add_emitter_rule_pre(MonospaceElement, sub {
        my ( $self, $element ) = @_;

        return '<code>' . _process_content($element->content) . '</code>';
    });

    $self->_add_emitter_rule_pre(SubscriptElement, sub {
        my ( $self, $element ) = @_;

        return '<sub>' . _process_content($element->content) . '</sub>';
    });

    $self->_add_emitter_rule_pre(SuperscriptElement, sub {
        my ( $self, $element ) = @_;

        return '<sup>' . _process_content($element->content) . '</sup>';
    });

    $self->_add_emitter_rule_pre(DeletedElement, sub {
        my ( $self, $element ) = @_;

        return '<del>' . _process_content($element->content) . '</del>';
    });

    $self->_add_emitter_rule_pre(HeadingElement, sub {
        my ( $self, $element ) = @_;

        my $level   = $element->level;
        my $content = $element->content;

        return "<h$level>$content</h$level>";
    });

    $self->_add_emitter_rule_pre(LinkElement, sub {
        my ( $self, $element ) = @_;

        my $link = $element->link;
        my $location;
        my $name;

        if($link->isa(InternalLink)) {
            $location = $link->page_name;
            $name     = $link->label // $location;

            if($link->section_name) {
                $location .= '#' . $link->section_name;
            }
        } elsif($link->isa(ExternalLink)) {
            $location = '' . $link->uri;
            $name     = $link->label // $location;
        }

        return "<a href='$location'>$name</a>";
    });

    $self->_add_emitter_rule_pre(EmailAddressElement, sub {
        my ( $self, $element ) = @_;

        my $address = $element->content;

        return "<a href='mailto:$address'>$address</a>";
    });

    # XXX Pygments? Other highlighter? (how can I override this with another role?)
    $self->_add_emitter_rule_pre(CodeElement, sub {
        my ( $self, $element ) = @_;

        # Do I have to escape pre stuff?
        my $content = escape_html($element->children->[0]->content);

        # XXX CSS classes?
        return "<pre>\n$content\n</pre>";
    });
};

1;

__END__

# ABSTRACT: Description for Text::DokuWiki::Emitter::HTML

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 FUNCTIONS

=cut
