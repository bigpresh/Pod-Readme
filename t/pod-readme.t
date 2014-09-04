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
