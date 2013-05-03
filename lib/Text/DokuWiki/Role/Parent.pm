## no critic (RequireUseStrict)
package Text::DokuWiki::Role::Parent;

## use critic (RequireUseStrict)
use Moose::Role;

require Text::DokuWiki::Element::Dummy;

has children => (
    is      => 'ro',
    isa     => 'ArrayRef',
    traits  => ['Array'],
    default => sub { [] },
    handles => {
        append_child => 'push',
    },
);

my $dummy_child = Text::DokuWiki::Element::Dummy->new;

sub last_child {
    my ( $self ) = @_;

    my $children = $self->children;
    return @$children > 0 ? $children->[-1] : $dummy_child;
}

1;

__END__

# ABSTRACT: Description for Text::DokuWiki::Role::Parent

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 FUNCTIONS

=cut
