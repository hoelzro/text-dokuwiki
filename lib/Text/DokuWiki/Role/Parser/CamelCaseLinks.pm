package Text::DokuWiki::Role::Parser::CamelCaseLinks;

use Moose::Role;

require Text::DokuWiki::Element::InternalLink;

after BUILD => sub {
    my ( $self ) = @_;

    $self->_add_parser_rule(
        after   => 'internal_link',
        name    => 'camel_case_link',
        pattern => qr/[A-Z][a-zA-Z0-9_]+/,
        handler => sub {
            my ( $parser, $match ) = @_;

            $parser->_pop_text_node;
            $parser->_append_child('Text::DokuWiki::Element::InternalLink',
                page_name => $match,
            );
        },
    );
};

1;

__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 FUNCTIONS

=cut
