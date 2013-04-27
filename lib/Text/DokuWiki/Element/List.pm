package Text::DokuWiki::Element::List;

use Moose;

extends 'Text::DokuWiki::Element';

has ordered => (
    is      => 'ro',
    default => 0,
);

has _indent => (
    is => 'ro',
);

=pod
before append_child => sub {
    my ( $self, $child ) = @_;

    assert($child->isa(ListItemElement));
    assert(!$self->last_child || $child->_indent == $self->last_child->_indent)
};
=cut

1;

__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 FUNCTIONS

=cut
