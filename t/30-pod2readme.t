use strict;
use warnings;

use Test::More;
use Test::Command;

use File::Compare qw/ compare_text /;

plan skip_all => 'This fails on some test environments';

my $cmd = 'perl bin/pod2readme';

{
    my $test = Test::Command->new( cmd => "${cmd} -h" );
    $test->exit_isnt_num(0);
    $test->stderr_like(
        qr/^pod2readme \[-bcfhot\] \[long options\.\.\.\] input-file \[output-file\] \[target\]\n/
    );
}

{
    my $test = Test::Command->new( cmd => "${cmd} -f pod -c lib/Pod/Readme.pm" );
    $test->exit_is_num(0);
    ok !compare_text($test->stdout_file, 'README.pod'), 'expected output';
}

done_testing;
