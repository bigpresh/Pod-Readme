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
    filter_lines( '=for readme plugin changes', '' );

    note $out;

    like $out, qr/=head1 RECENT CHANGES\n\n/, '=head1';

    # TODO: test content:
    # - Changes file with sections (using alternative file)
    # - Changes file without sections (using alternative file)
    # - verbatim mode
    # - changed title

    reset_out();
}

done_testing;
