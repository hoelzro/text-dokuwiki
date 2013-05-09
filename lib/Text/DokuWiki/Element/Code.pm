package Text::DokuWiki::Element::Code;

use Moose;

extends 'Text::DokuWiki::Element';

has _level => (
    is      => 'rw',
    default => 0,
);

has language => (
    is      => 'ro',
    default => 'text',
);

has filename => (
    is      => 'ro',
    default => undef,
);

1;

__END__

# ABSTRACT: Description for Text::DokuWiki::Element::Code

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 FUNCTIONS

=cut
