package Text::DokuWiki::Element::Link;

use Moose;
use MooseX::SetOnce;

extends 'Text::DokuWiki::Element';

has link => (
    is     => 'rw',
    traits => [ qw{SetOnce} ],
);

sub _is_textual {
    return 0;
}

1;

__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 FUNCTIONS

=cut
