package Text::DokuWiki::Element::Quote;

use Moose;

extends 'Text::DokuWiki::Element';

has level => (
    is       => 'ro',
    required => 1,
);

1;

__END__

# ABSTRACT: Description for Text::DokuWiki::Element::Quote

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 FUNCTIONS

=cut
