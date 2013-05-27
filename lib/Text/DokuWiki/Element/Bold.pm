package Text::DokuWiki::Element::Bold;

use Moose;

extends 'Text::DokuWiki::Element';

# XXX should elements like this *really* have content?
sub _is_textual {
    return 1;
}

1;

__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 FUNCTIONS

=cut
