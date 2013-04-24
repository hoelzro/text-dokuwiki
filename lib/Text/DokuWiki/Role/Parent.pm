## no critic (RequireUseStrict)
package Text::DokuWiki::Role::Parent;

## use critic (RequireUseStrict)
use Moose::Role;

has children => (
    is      => 'ro',
    isa     => 'ArrayRef',
    traits  => ['Array'],
    default => sub { [] },
    handles => {
        append_child => 'push',
    },
);

sub last_child {
    my ( $self ) = @_;

    my $children = $self->children;
    return @$children > 0 ? $children->[-1] : undef;
}

1;

__END__

# ABSTRACT: Description for Text::DokuWiki::Role::Parent

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 FUNCTIONS

=cut
