use Test::Most;

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
