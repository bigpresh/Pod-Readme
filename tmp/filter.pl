
use v5.10.1;

use strict;
use warnings;

use lib 'lib';

use Pod::Readme;


=for readme plugin version

=for readme plugin changes

=cut

use IO::File;

my $prf = Pod::Readme->new( input_file => $0 );

$prf->filter_file;
