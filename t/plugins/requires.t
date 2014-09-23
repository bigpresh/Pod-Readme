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

    like $out, qr/=head1 REQUIREMENTS\n\n/, '=head1';
    like $out, qr/\nThis distribution requires the following modules:\n\n/,
        'description';

    reset_out();

    $prf->requires_run(0);
}

{
    filter_lines(
        '=for readme plugin requires from-file="t/data/META-1.yml" title="PREREQS"',
        ''
    );

    note $out;

    like $out, qr/=head1 PREREQS\n\n/, '=head1';

    like $out, qr/\nThis distribution requires Perl v5\.10\.1\.\n\n/,
        'minimum perl';

    # TODO: test content
    # - test no-omit-core option

    reset_out();

    $prf->requires_run(0);
}

done_testing;
