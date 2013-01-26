package Text::DokuWiki::Element::Image;

use Moose;

extends 'Text::DokuWiki::Element';

has [qw/link width height alignment caption/] => (
    is => 'ro',
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


