package Text::DokuWiki::Element::Link;

use Moose;

extends 'Text::DokuWiki::Element';

has link => (
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









