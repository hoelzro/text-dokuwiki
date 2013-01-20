package Text::DokuWiki::Element::InterWikiLink;

use Moose;

extends 'Text::DokuWiki::Element';

# XXX lots shared with other links
has [qw/wiki page_name section_name link_text/] => (
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








