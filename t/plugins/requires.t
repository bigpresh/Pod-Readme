use Test::Most;

use lib 't/lib';
use Pod::Readme::Test;

my $class = 'Pod::Readme';
use_ok $class;

isa_ok $prf = $class->new(
    input_file => $0,
    output_fh  => $io,
), $class;

{
    filter_lines( '=for readme plugin requires', '' );

    note $out;

    # TODO: test content

    reset_out();
}

done_testing;
