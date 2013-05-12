package Text::DokuWiki::Role::Emitter;

use Carp qw(croak);
use Moose::Role;

has pre_rules => (
    is      => 'ro',
    default => sub { {} },
);

has post_rules => (
    is      => 'ro',
    default => sub { {} },
);

sub BUILD {}

sub _invoke_rule {
    my ( $emitter, $element, $pieces, $rules ) = @_;

    my $element_type = ref($element);

    my $rule = $rules->{$element_type};

    unless($rule) {
        my $emitter_type = ref($emitter);
        croak "No emiter rule for element type '$element_type' using emitter '$emitter_type'";
    }

    push @$pieces, $rule->($emitter, $element);
}

sub _invoke_pre_rule {
    my ( $emitter ) = @_;

    return _invoke_rule(@_, $emitter->pre_rules);
}

sub _invoke_post_rule {
    my ( $emitter ) = @_;

    return _invoke_rule(@_, $emitter->post_rules);
}

sub _add_pieces {
    my ( $emitter, $element, $pieces ) = @_;

    _invoke_pre_rule($emitter, $element, $pieces);
    if($element->can('children')) {
        foreach my $child (@{ $element->children }) {
            _add_pieces($emitter, $child, $pieces);
        }
    }
    _invoke_post_rule($emitter, $element, $pieces);
}

sub emit {
    my ( $self, $doc ) = @_;

    unless(ref($self)) {
        $self = $self->new;
    }

    my @pieces;
    foreach my $child (@{ $doc->children }) {
        _add_pieces($self, $child, \@pieces);
    }
    return join('', @pieces);
}

my $dummy_action = sub {
    return '';
};

sub _add_emitter_rule_pre {
    my ( $self, $element_class, $action ) = @_;

    $self->post_rules->{$element_class} ||= $dummy_action;
    if(defined $self->pre_rules->{$element_class} && $self->pre_rules->{$element_class} != $dummy_action) {
        croak "A pre rule has already been defined for '$element_class'";
    }
    $self->pre_rules->{$element_class} = $action;
}

sub _add_emitter_rule_post {
    my ( $self, $element_class, $action ) = @_;

    $self->pre_rules->{$element_class} ||= $dummy_action;
    if(defined $self->post_rules->{$element_class} && $self->post_rules->{$element_class} != $dummy_action) {
        croak "A post rule has already been defined for '$element_class'";
    }
    $self->post_rules->{$element_class} = $action;
}

1;

__END__

# ABSTRACT: Description for Text::DokuWiki::Role::Emitter

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 FUNCTIONS

=cut
