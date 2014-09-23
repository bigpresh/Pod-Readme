#!/usr/bin/perl

use Test::More;

plan skip_all => "Enable RELEASE_TESTING environent variable"
  unless ($ENV{RELEASE_TESTING});

eval "use Test::Portability::Files";

plan skip_all => "Test::Portability::Files required for testing filenames portability" if $@;

run_tests();
