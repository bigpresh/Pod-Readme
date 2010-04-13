#!/usr/bin/perl

use strict;
use Test::More;

plan skip_all => "Enable DEVEL_TESTS environent variable"
  unless ($ENV{DEVEL_TESTS});

eval "use Test::Pod::Coverage";

plan skip_all => "Test::Pod::Coverage required" if $@;

plan tests => 1;

pod_coverage_ok("Pod::Readme");

