
use v5.10.1;

use strict;
use warnings;

use lib 'lib';

use Pod::Readme::Filter;

=begin readme

Foo

=end readme

ok

=cut

use IO::File;

my $prf = Pod::Readme::Filter->new( input_file => $0 );

$prf->filter_file;
