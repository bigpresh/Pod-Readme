use Test::Most;

use IO::String;

our $VERSION = '1.23';

my $class = 'Pod::Readme';
use_ok $class;

my $out;
my $io = IO::String->new($out);

isa_ok my $prf = $class->new(
    input_file => $0,
    output_fh  => $io,
 ), $class;

{
    filter_lines('=for readme plugin version', '');
    is $out, "=head1 VERSION\n\n${VERSION}\n\n";
    reset_out();
}

{
    filter_lines("=for readme plugin version file=${0} title='THIS VER'", '');
    is $out, "=head1 THIS VER\n\n${VERSION}\n\n";
    reset_out();
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
