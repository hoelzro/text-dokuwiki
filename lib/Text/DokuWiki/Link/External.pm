package Text::DokuWiki::Link::External;

use Moose;
use URI;

extends 'Text::DokuWiki::Link';

has uri => (
    is  => 'ro',
    isa => 'URI',
);

1;

__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 FUNCTIONS

=cut
