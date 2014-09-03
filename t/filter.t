use Test::Most;

use IO::String;

my $class = 'Pod::Readme::Filter';

use_ok $class;

my $out;

isa_ok my $prf = $class->new(
    output_fh => IO::String->new($out),
 ), 'Pod::Readme::Filter';

is_deeply
    [ $prf->_plugin_app_ns ],
    [qw/ Pod::Readme Pod::Readme::Filter /],
    'plugin namespace';

can_ok($prf, "cmd_" . $_)
    for qw/ stop start continue plugin /;



done_testing;
