use Test::Most;

use lib 't/lib';
use Pod::Readme::Test;

our $VERSION = '1.23'; # for testing

my $class = 'Pod::Readme';
use_ok $class;

isa_ok $prf = $class->new(
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
