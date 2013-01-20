package Text::DokuWiki::Element::ExternalLinkURI;

use Moose;

extends 'Text::DokuWiki::Element';

# XXX shared with InternalLink
# XXX does content make sense for this element? for *all* elements?
has [qw/link_uri link_text/] => (
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






