#!/usr/bin/perl

use strict;
use Test::More;

plan skip_all => "Enable RELEASE_TESTING environent variable"
  unless ($ENV{RELEASE_TESTING});

eval "use Test::Pod::Coverage";

plan skip_all => "Test::Pod::Coverage required" if $@;

plan tests => 1;

pod_coverage_ok("Pod::Readme");
