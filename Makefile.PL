use strict;
use warnings;
use ExtUtils::MakeMaker;
WriteMakefile(
    NAME => 'Pod::Readme',
    AUTHOR => 'Robert Rothenberg <rrwo@cpan.org>',
    VERSION_FROM => 'lib/Pod/Readme.pm',
    ABSTRACT_FROM => 'lib/Pod/Readme.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
        ? (LICENSE=> 'perl')
                : ()),
    PREREQ_PM => {
        'Moose'             => 0,
        'MooseX::NonMoose'  => 0,
        'namespace::autoclean' => 0,
        'parent'            => 0,
        'Pod::Simple::Text' => '3.0',
        'Test::Most'        => '0'
    },
    INSTALLDIRS => 'site',
    EXE_FILES => [
                    'bin/pod2readme'
                    ],
    PL_FILES => {},
    dist       => { COMPRESS => 'gzip -9f', SUFFIX => 'gz' },
    clean      => { FILES => 'Pod-Readme-*' },
);
