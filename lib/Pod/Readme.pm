package Pod::Readme;

=head1 NAME

Pod::Readme - generate README files from POD

=head1 SYNOPSIS

TODO

=head1 DESCRIPTION

TODO

=for readme plugin version

=for readme plugin changes

=for readme stop

=head1 METHODS

See L<Pod::Simple::Methody> for the base methods that this module
uses.

This module adds methods of the form C<pod_readme_CMD>, which are
triggered by the POD directives

  =for readme CMD

=for readme start

=cut

use 5.10.1;

use Moose;
use MooseX::NonMoose;

with 'MooseX::Object::Pluggable';

extends 'Pod::Simple::Text';

use version 0.77; our $VERSION = version->declare('v1.0.0_01');

has 'enabled' => (
    is       => 'ro',
    isa      => 'Bool',
    traits   => [qw/ Bool /],
    init_arg => 'start_enabled',
    default  => 1,
    handles  => {
        pod_readme_start => 'set',
        pod_readme_stop  => 'unset',
    },
);

has 'target' => (
    is      => 'ro',
    isa     => 'Str',
    default => 'readme',
);

has '_elements' => (
    is      => 'rw',
    isa     => 'ArrayRef[Str]',
    traits  => [qw/ Array /],
    default => sub { [] },
    handles => {
        _push_element => 'push',
        _pop_element  => 'pop',
    },
);

sub BUILD {
    my ( $self, $args ) = @_;
    $self->accept_targets_as_text( $self->target );
}

sub start_for {
    my ( $self, $attrs ) = @_;
    if ( $attrs->{target_matching} eq $self->target ) {
        $self->_push_element( $attrs->{'~really'} );
    }
}

sub end_for {
    my ( $self, $attrs ) = @_;
    $self->_pop_element;
}

sub _is_for {
    my ($self) = @_;
    ( $self->_elements->[-1] // '' ) eq '=for';
}

sub pod_readme_plugin {
    my ( $self, $plugin, @args ) = @_;
    $self->load_plugin($plugin);
    if ( my $method = $self->can("pod_readme_${plugin}") ) {
        $self->$method(@args);
    }
}

sub _elem_wrap {
    my ( $self, $name, $text ) = @_;
    my $start = $self->can("start_${name}");
    my $end   = $self->can("end_${name}");
    $self->$start();
    $self->handle_text($text);
    $self->$end();
}

around 'handle_text' => sub {
    my ( $orig, $self, $text ) = @_;

    # Bug: =for readme stop inserts a blank line

    if ( $self->_is_for ) {

        $text =~ s/^\s+//;
        $text =~ s/\s+$//;

        my @args = split /\s+/, $text;
        my $cmd = shift @args;

        my $cmd_method = 'pod_readme_' . $cmd;
        if ( my $method = $self->can($cmd_method) ) {

            my $elem = $self->_pop_element;
            $self->$method(@args);
            $self->_push_element($elem);

        } else {

            die "Unsupported command: ${cmd}";    # TODO

        }

    } else {

        $self->$orig($text);

    }
};

around emit_par => sub {
    my ( $orig, $self, @args ) = @_;
    $self->$orig(@args) if $self->enabled && !$self->_is_for;
};

around end_Verbatim => sub {
    my ( $orig, $self, @args ) = @_;
    $self->$orig(@args) if $self->enabled && !$self->_is_for;
};

use namespace::autoclean;

1;

=head1 SEE ALSO

See L<perlpod>, L<perlpodspec> and L<podlators>.

=head1 AUTHOR

Originally by Robert Rothenberg <rrwo at cpan.org>

Now maintained by David Precious <davidp@preshweb.co.uk>

=head2 Suggestions, Bug Reporting and Contributing

This module is developed on GitHub at:

http://github.com/bigpresh/Pod-Readme


=head1 LICENSE

Copyright (c) 2005-2014 Robert Rothenberg. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
