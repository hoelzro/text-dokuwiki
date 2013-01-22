package Text::DokuWiki::Element::Link;

use Moose;

extends 'Text::DokuWiki::Element';

has [qw/link link_text/] => (
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









