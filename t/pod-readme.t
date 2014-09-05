use Test::Most;

use lib 't/lib';

use IO::String;

my $class = 'Pod::Readme';

use_ok $class;

my $out;
my $io = IO::String->new($out);

isa_ok my $prf = $class->new(
    output_fh => $io,
 ), $class;

{
   is_deeply
        [ $prf->_plugin_app_ns ],
        [$class, "${class}::Filter" ],
        'plugin namespace';

}

{
    ok !$prf->can('cmd_noop'), 'no noop';

    filter_lines('=for readme plugin noop');
    is $prf->mode, 'pod:for', 'mode';

    filter_lines('');
    is $prf->mode, 'pod', 'mode';
    ok $prf->in_target, 'in target';

    is $out, '', 'no output';

    can_ok($prf, 'cmd_noop');
    isa_ok($prf, 'Pod::Readme::Filter');

    throws_ok {
        filter_lines('=for readme plugin noop::invalid');
        is $prf->mode, 'pod:for', 'mode';
        filter_lines('');
    } qr/Unable to locate plugin 'noop::invalid'/, 'bad plugin';

    is $prf->mode('pod'), 'pod', 'mode reset';

    filter_lines('=for readme plugin noop', '');

    can_ok($prf, qw/ noop_bool noop_str /);
    ok !$prf->noop_bool, 'plugin accessor default';
    is $prf->noop_str, '', 'plugin accessor default';

    filter_lines('=for readme plugin noop bool', '');
    ok $prf->noop_bool, 'plugin accessor set';
    filter_lines('=for readme plugin noop no-bool str="Isn\'t this nice?"', '');
    ok !$prf->noop_bool, 'plugin accessor unset';
    is $prf->noop_str, "Isn\'t this nice?", 'plugin accessor set';
};


done_testing;

sub filter_lines {
    my @lines = @_;
    foreach my $line (@lines) {
        note $line if $line =~ /^=(?:\w+)/;
        $prf->filter_line($line . "\n");
    }
}

sub reset_out {
    $io->close;
    $out = '';
    $io->open($out);
}
