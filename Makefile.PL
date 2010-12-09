use strict;
use warnings;
use ExtUtils::MakeMaker;
WriteMakefile(
    NAME => 'Pod::Readme',
    AUTHOR => 'David Precious <davidp@preshweb.co.uk>',
    VERSION_FROM => 'lib/Pod/Readme.pm',
    ABSTRACT_FROM => 'lib/Pod/Readme.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
        ? (LICENSE=> 'perl')
                : ()),
    PREREQ_PM => {
                    'Carp' => '0',
                    'File::Copy' => '0',
                    'IO::File' => '0',
                    'Pod::Text' => '3.0',
                    'Regexp::Common' => '0',
                    'Test::More' => '0'
                    },
    INSTALLDIRS => 'site',
    EXE_FILES => [
                    'bin/pod2readme'
                    ],
    PL_FILES => {},
    dist       => { COMPRESS => 'gzip -9f', SUFFIX => 'gz' },
    clean      => { FILES => 'Pod-Readme-*' },
);
