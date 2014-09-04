
use v5.10.1;

use strict;
use warnings;

use lib 'lib';

use Pod::Readme::Filter;

=begin readme

Foo

=end readme

=cut

my $prf = Pod::Readme::Filter->new();

$prf->filter_file;
