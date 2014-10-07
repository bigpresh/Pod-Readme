use strict;
use warnings;

use Test::More;
use Test::Perl::Critic -profile => 'xt/perlcriticrc';

all_critic_ok(qw/ lib /);
