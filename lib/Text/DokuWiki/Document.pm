package Text::DokuWiki::Document;

use Moose;

with 'Text::DokuWiki::Role::Parent';

sub _is_textual {
    return 0;
}

1;

__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 FUNCTIONS

=cut
