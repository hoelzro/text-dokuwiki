#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 6;
use Test::Text::DokuWiki qw(:DEFAULT :link_classes);
use URI;

test_doc '[[http://google.com]]', <<'END_TREE';
Paragraph
  Link { link => ExternalLink->new(uri => URI->new('http://google.com')) }
END_TREE

test_doc '[[http://google.com|Google]]', <<'END_TREE';
Paragraph
  Link { link => ExternalLink->new(uri => URI->new('http://google.com'), label => 'Google') }
END_TREE

test_doc '[[http://google.com]] [[http://ddg.gg]]', <<'END_TREE';
Paragraph
  Link { link => ExternalLink->new(uri => URI->new('http://google.com')) }
  Text ' '
  Link { link => ExternalLink->new(uri => URI->new('http://ddg.gg')) }
END_TREE

test_doc '[[http://google.com|Google]] [[http://ddg.gg]]', <<'END_TREE';
Paragraph
  Link { link => ExternalLink->new(uri => URI->new('http://google.com'), label => 'Google') }
  Text ' '
  Link { link => ExternalLink->new(uri => URI->new('http://ddg.gg')) }
END_TREE

test_doc '[[http://google.com]] [[http://ddg.gg|DuckDuckGo]]', <<'END_TREE';
Paragraph
  Link { link => ExternalLink->new(uri => URI->new('http://google.com')) }
  Text ' '
  Link { link => ExternalLink->new(uri => URI->new('http://ddg.gg'), label => 'DuckDuckGo') }
END_TREE

test_doc '[[http://google.com|Google]] [[http://ddg.gg|DuckDuckGo]]', <<'END_TREE';
Paragraph
  Link { link => ExternalLink->new(uri => URI->new('http://google.com'), label => 'Google') }
  Text ' '
  Link { link => ExternalLink->new(uri => URI->new('http://ddg.gg'), label => 'DuckDuckGo') }
END_TREE
