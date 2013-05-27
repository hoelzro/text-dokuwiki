package Text::DokuWiki::Document;

use Moose;

with 'Text::DokuWiki::Role::Parent';

sub _is_textual {
    return 0;
}

sub parent {
    return undef;
}

sub as_html {
    my ( $self ) = @_;

    require Text::DokuWiki::Emitter::HTML;

    return Text::DokuWiki::Emitter::HTML->emit($self);
}

1;

__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 FUNCTIONS

=cut
