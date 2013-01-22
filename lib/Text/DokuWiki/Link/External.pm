package Text::DokuWiki::Link::External;

use Moose;
use URI;
use MooseX::Types::URI qw(Uri);

extends 'Text::DokuWiki::Link';

has uri => (
    is     => 'ro',
    isa    => Uri,
    coerce => 1,
);

1;

__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 FUNCTIONS

=cut
