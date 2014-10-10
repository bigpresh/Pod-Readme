use v5.10.1;

use strict;
use warnings;

use Test::More;
use Test::Command;

use File::Compare qw/ compare_text /;
use File::Temp qw/ tempfile /;

plan skip_all => 'Need META.yml to run this test' unless -e 'META.yml';

my $cmd = 'perl -Ilib bin/pod2readme';

{
    my $test = Test::Command->new( cmd => "${cmd} -h" );
    $test->exit_isnt_num(0);
    $test->stderr_like(
        qr/^pod2readme \[-bcfhot\] \[long options\.\.\.\] input-file \[output-file\] \[target\]\n/
    );
}

SKIP: {

    my $source = "lib/Pod/Readme.pm";
    my $readme = "README.pod";

    ok my $test = Test::Command->new( cmd => "${cmd} -f pod -c ${source}" );
    $test->exit_is_num(0);
    $test->stderr_is_eq('');
    $test->stdout_is_file($readme);
}

SKIP: {

    my $source = "lib/Pod/Readme.pm";
    my $dest   = (tempfile)[1];
    my $readme = "README.pod";

    ok my $test = Test::Command->new( cmd => "${cmd} -f pod ${source} ${dest}" );
    $test->exit_is_num(0);
    $test->stdout_is_eq('');
    $test->stderr_is_eq('');
    ok !compare_text($dest, $readme), 'expected output';
}



done_testing;
