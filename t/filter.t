use Test::Most;

use IO::String;

my $class = 'Pod::Readme::Filter';

use_ok $class;

my $out;
my $io = IO::String->new($out);

isa_ok my $prf = $class->new(
    output_fh => $io,
 ), 'Pod::Readme::Filter';

{
    is_deeply
        [ $prf->_plugin_app_ns ],
        [qw/ Pod::Readme Pod::Readme::Filter /],
        'plugin namespace';

    can_ok($prf, "cmd_" . $_)
        for qw/ stop start continue plugin /;
};

{
    ok $prf->in_target, 'default in target';
    is $prf->mode, 'default', 'mode';
};

{
    filter_lines('=pod');
    is $out, "=pod\n", 'expected output';
    is $prf->mode, 'pod', 'mode';
    ok $prf->in_target, 'in target';
    reset_out();
};

{
    filter_lines('=for readme stop');
    is $prf->mode, 'pod:for', 'mode';

    filter_lines('');
    is $prf->mode, 'pod', 'mode';

    is $out, '', 'no output';
    ok !$prf->in_target, 'not in target';

    filter_lines('This should not be copied.', '', 'Boop!','');

    is $out, '', 'no output';

    filter_lines('=for readme continue');
    is $prf->mode, 'pod:for', 'mode';

    filter_lines('');
    is $prf->mode, 'pod', 'mode';
    ok $prf->in_target, 'in target';

    is $out, '', 'no output';
};

{
    filter_lines('=for readme stop');
    is $prf->mode, 'pod:for', 'mode';

    filter_lines('');
    is $prf->mode, 'pod', 'mode';

    is $out, '', 'no output';

    ok !$prf->in_target, 'not in target';

    filter_lines('This should not be copied.', '', 'Boop!','');

    is $out, '', 'no output';

    filter_lines('=for readme start');
    is $prf->mode, 'pod:for', 'mode';

    filter_lines('');
    is $prf->mode, 'pod', 'mode';
    ok $prf->in_target, 'in target';

    is $out, '', 'no output';
};

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

{
    filter_lines('=cut');
    is $prf->mode, 'default', 'default mode';
    filter_lines('');

    is $out, '', 'no content';

    filter_lines('=head1 TEST');
    is $prf->mode, 'pod', 'pod mode';
    filter_lines('');

    is $out, "=head1 TEST\n\n", 'expected content';
    reset_out();
};

{
    filter_lines("This should be copied.", '');

    is $out, "This should be copied.\n\n", 'output';
    reset_out();
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
