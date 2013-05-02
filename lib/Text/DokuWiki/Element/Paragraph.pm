package Text::DokuWiki::Element::Paragraph;

use Moose;

extends 'Text::DokuWiki::Element';

has _closed => (
    is      => 'rw',
    default => 0,
    reader => '_is_closed',
    writer => '_set_closed',
);

sub _close {
    my ( $self ) = @_;

    $self->_set_closed(1);
}

1;

__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 FUNCTIONS

=cut
