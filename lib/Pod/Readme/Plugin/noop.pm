package Pod::Readme::Plugin::noop;

use Moose::Role;

=head1 NAME

Pod::Readme::Plugin::noop - do nothing

=head1 SYNOPSIS

  =pod

  =for readme plugin noop

=head1 DESCRIPTION

This is a no-op plugin.

=cut

sub cmd_noop { }

use namespace::autoclean;

1;
