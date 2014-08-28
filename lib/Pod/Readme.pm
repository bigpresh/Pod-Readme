package Pod::Readme;

=head1 NAME

Pod::Readme - generate README files from POD

=head1 SYNOPSIS

TODO

=head1 DESCRIPTION

TODO

=begin :readme

=for readme plugin changes

=for readme changes

=for readme stop

=end :readme

=head1 METHODS

See L<Pod::Simple::Methody> for the base methods that this module
uses.

It adds methods of the form C<pod_readme_CMD>, which are triggered by

  =for readme CMD

=for readme start

=cut

use 5.10.1;

use Moose;
use MooseX::NonMoose;

with 'MooseX::Object::Pluggable';

extends 'Pod::Simple::Text';

use version 0.77; our $VERSION = version->declare('v0.999.0');

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
    is => 'ro',
    isa => 'Str',
    default => 'readme',
);

has '_elements' => (
    is => 'rw',
    isa => 'ArrayRef[Str]',
    traits   => [qw/ Array /],
    default => sub { [] },
    handles => {
        _push_element => 'push',
        _pop_element  => 'pop',
    },
);

sub BUILD {
    my ($self, $args) = @_;
    $self->accept_targets_as_text( $self->target );
}

sub start_for {
    my ($self, $attrs) = @_;
    if ($attrs->{target_matching} eq $self->target) {
        $self->_push_element( $attrs->{'~really'} ) ;
    }
}

sub end_for {
    my ($self, $attrs) = @_;
    $self->_pop_element;
}

sub pod_readme_plugin {
    my ($self, @args) = @_;
    $self->load_plugin($_) for @args;
}

around 'handle_text' => sub {
    my ($orig, $self, $text) = @_;

    if (my $element = $self->_elements->[-1]) {

        if ($element eq '=for') {

            $text =~ s/^\s+//;
            $text =~ s/\s+$//;

            my @args = split /\s+/, $text;
            my $cmd  = shift @args;

            my $cmd_method = 'pod_readme_' . $cmd;
            if (my $method = $self->can($cmd_method)) {

                $self->$method(@args);

            } else {

                die "Unsupported command: ${cmd}"; # TODO

            }

        } elsif ($element eq '=begin') {

            $self->$orig($text);

        }

    } else {

        $self->$orig($text) if $self->enabled;

    }
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
