#!/usr/bin/perl

use strict;
use Test::More;
use Test::Pod::Coverage;

plan tests => 1;

pod_coverage_ok("Pod::Readme");
