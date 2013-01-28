package Text::DokuWiki::Link::Internal;

use Moose;

extends 'Text::DokuWiki::Link';

has page_name => (
    is => 'ro',
);

has section_name => (
    is => 'ro',
);

1;

__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 FUNCTIONS

=cut
