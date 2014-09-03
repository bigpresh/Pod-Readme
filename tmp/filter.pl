
use v5.10.1;

use strict;
use warnings;

use lib 'lib';

use Pod::Readme::Filter;

=head1 NAME

main - this is for testing

=begin readme

Foo

=end readme

=for readme
stop

This is a para that should not appear.

=for readme start

=head2 Test

=for bobobo goo
boobo

=for readme
continue

Hello

=cut

my $prf = Pod::Readme::Filter->new();

$prf->filter_file;

