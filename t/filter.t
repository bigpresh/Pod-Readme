use Test::Most;

my $class = 'Pod::Readme::Filter';

use_ok($class);

isa_ok( my $prf = $class->new, 'Pod::Readme::Filter' );

done_testing;
