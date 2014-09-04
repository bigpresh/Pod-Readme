
use v5.10.1;

use strict;
use warnings;

use lib 'lib';

use Pod::Readme::Filter;

=begin readme

Foo

=end readme

=cut

use IO::File;

my $io = IO::File->new($0, 'r');

my $prf = Pod::Readme::Filter->new( input_fh => $io );

$prf->filter_file;
