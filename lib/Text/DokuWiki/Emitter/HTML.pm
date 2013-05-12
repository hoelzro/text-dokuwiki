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

after BUILD => sub {
    my ( $self ) = @_;

    $self->_add_emitter_rule_pre(TextElement, sub {
        my ( $self, $element ) = @_;

        return escape_html($element->content);
    });

    $self->_add_emitter_rule_pre(ParagraphElement, sub {
        return '<p>';
    });

    $self->_add_emitter_rule_post(ParagraphElement, sub {
        return '</p>';
    });

    $self->_add_emitter_rule_pre(BoldElement, sub {
        my ( $self, $element ) = @_;

        return '<strong>' . escape_html($element->content) . '</strong>';
    });
};

1;

__END__

# ABSTRACT: Description for Text::DokuWiki::Emitter::HTML

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 FUNCTIONS

=cut
