use strict;
use warnings;

use Test::More;
use Test::CleanNamespaces;

my %skip = map { $_ => 1 } qw/ Pod::Readme::Types /;

my @modules = grep { !$skip{$_} } Test::CleanNamespaces->find_modules;

namespaces_clean(@modules);

done_testing;
