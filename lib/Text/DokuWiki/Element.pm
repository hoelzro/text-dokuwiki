package Text::DokuWiki::Element;

use Moose;

has children => (
    is      => 'ro',
    isa     => 'ArrayRef',
    traits  => ['Array'],
    default => sub { [] },
    handles => {
        add_child => 'push',
    },
);

has content => (
    is      => 'ro',
    isa     => 'Str',
    default => '',
);

1;

__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 FUNCTIONS

=cut
