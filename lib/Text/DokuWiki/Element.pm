package Text::DokuWiki::Element;

use Moose;

has children => (
    is      => 'ro',
    isa     => 'ArrayRef',
    traits  => ['Array'],
    default => sub { [] },
    handles => {
        append_child => 'push',
    },
);

has parent => (
    is       => 'ro',
    #isa      => 'Text::DokuWiki::Element',
    weak_ref => 1,
    required => 1,
);

# XXX technically, only textual nodes have this
has content => (
    is  => 'rw', # XXX does this need to be read-only?
    isa => 'Str',
);

sub _append_content {
    my ( $self, $text ) = @_;

    unless(defined $self->content) {
        $self->content('');
    }
    $self->content($self->content . $text);
}

sub _is_textual {
    return 0;
}

1;

__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 FUNCTIONS

=cut
