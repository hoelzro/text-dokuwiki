package Text::DokuWiki::Element::WindowsShareLink;

use Moose;

extends 'Text::DokuWiki::Element';

# XXX lots shared with other links
has [qw/share link_text/] => (
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








