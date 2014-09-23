use strict;
use warnings;
use Test::More;
use Test::ConsistentVersion;

Test::ConsistentVersion::check_consistent_versions(
  no_readme => 1,
  no_pod    => 1,
);

