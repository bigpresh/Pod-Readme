
use v5.10.1;

use strict;
use warnings;

use lib 'lib';

use Pod::Readme;

use version 0.77; our $VERSION = version->declare('v1.0.0_01');

=for readme plugin version

=for readme plugin requires omit-core

=for readme plugin changes no-verbatim

=cut

use IO::File;

my $prf = Pod::Readme->new( input_file => 'lib/Pod/Readme.pm' );

$prf->filter_file;
