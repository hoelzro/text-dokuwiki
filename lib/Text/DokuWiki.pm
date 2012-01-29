## no critic (RequireUseStrict)
package Text::DokuWiki;

## use critic (RequireUseStrict)
use strict;
use warnings;

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

=head1 SEE ALSO

L<http://dokuwiki.org>

=cut
