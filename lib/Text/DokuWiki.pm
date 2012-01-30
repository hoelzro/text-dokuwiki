## no critic (RequireUseStrict)
package Text::DokuWiki;

## use critic (RequireUseStrict)
use Moose;

use Text::DokuWiki::Document;
use Text::DokuWiki::Element::Bold;
use Text::DokuWiki::Element::Paragraph;
use Text::DokuWiki::Element::Text;

has parser => (
    is       => 'ro',
    lazy     => 1,
    builder  => '_build_parser',
    init_arg => undef,
);

sub _build_parser {
    my ( $self ) = @_;
}

sub parse {
    my $doc = Text::DokuWiki::Document->new;

    return $doc;
}

1;

__END__

# ABSTRACT:  A short description of Text::DokuWiki

=head1 SYNOPSIS

  use Text::DokuWiki;

  my $doku = Text::DokuWiki->new;
  my $doc  = $doku->parse($text);
  say $doc->as_html;

=head1 DESCRIPTION

This module is a parser for the markup language that
DokuWiki uses.

=head1 METHODS

=head2 Text::DokuWiki->new

Creates a new DokuWiki syntax parser.

=head2 $doku->parse($text)

Parses C<$text> as a DokuWiki document and returns
a L<Text::DokuWiki::Document> object.

=head1 UNSUPPORTED SYNTAX

The amount of syntax that we support in comparison
to the official DokuWiki parser will grow over time.
I don't know if we'll ever support PHP code blocks, though.

=head1 SEE ALSO

L<http://dokuwiki.org>

=cut
