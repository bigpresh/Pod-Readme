use Test::Most;

use IO::String;

my $class = 'Pod::Readme::Filter';

use_ok $class;

my $out;
my $io = IO::String->new($out);

isa_ok my $prf = $class->new(
    output_fh => $io,
 ), 'Pod::Readme::Filter';

is_deeply
    [ $prf->_plugin_app_ns ],
    [qw/ Pod::Readme Pod::Readme::Filter /],
    'plugin namespace';

can_ok($prf, "cmd_" . $_)
    for qw/ stop start continue plugin /;

ok $prf->in_target, 'default in target';
is $prf->mode, 'default', 'mode';

note "=pod";
$prf->filter_line("=pod\n");

is $out, "=pod\n", 'expected output';
is $prf->mode, 'pod', 'mode';
ok $prf->in_target, 'in target';

reset_out();

note "=for readme stop";
$prf->filter_line("=for readme stop\n");
is $prf->mode, 'pod:for', 'mode';

$prf->filter_line("\n");
is $prf->mode, 'pod', 'mode';

is $out, '', 'no output';

ok !$prf->in_target, 'not in target';

note "=for readme continue";
$prf->filter_line("=for readme continue\n");
is $prf->mode, 'pod:for', 'mode';

$prf->filter_line("\n");
is $prf->mode, 'pod', 'mode';
ok $prf->in_target, 'in target';

is $out, '', 'no output';

note "=for readme stop";
$prf->filter_line("=for readme stop\n");
is $prf->mode, 'pod:for', 'mode';

$prf->filter_line("\n");
is $prf->mode, 'pod', 'mode';

is $out, '', 'no output';

ok !$prf->in_target, 'not in target';

$prf->filter_line("This should not be copied.\n");
$prf->filter_line("\n");

is $out, '', 'no output';

note "=for readme start";
$prf->filter_line("=for readme start\n");
is $prf->mode, 'pod:for', 'mode';

$prf->filter_line("\n");
is $prf->mode, 'pod', 'mode';
ok $prf->in_target, 'in target';

is $out, '', 'no output';

ok !$prf->can('cmd_noop'), 'no noop';

note "=for readme plugin noop";
$prf->filter_line("=for readme plugin noop\n");
is $prf->mode, 'pod:for', 'mode';

$prf->filter_line("\n");
is $prf->mode, 'pod', 'mode';
ok $prf->in_target, 'in target';

is $out, '', 'no output';

can_ok($prf, 'cmd_noop');
isa_ok($prf, 'Pod::Readme::Filter');

$prf->filter_line("This should be copied.\n");
$prf->filter_line("\n");

is $out, "This should be copied.\n\n", 'output';

reset_out();

done_testing;

sub reset_out {
    $io->close;
    $out = '';
    $io->open($out);
}
