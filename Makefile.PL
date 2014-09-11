use strict;
use warnings FATAL => 'all';
use inc::Module::Install;

author 'Robert Rothenberg <rrwo@cpan.org>';
name 'Pod-Readme';
all_from 'lib/Pod/Readme.pm';
license 'artistic2';

tests_recursive('t');

# tests_recursive('xt');

resources(
    license    => 'http://www.perlfoundation.org/artistic_license_2_0',
    repository => 'git://github.com/bigpresh/Pod-Readme.git',
    bugtracker => 'https://rt.cpan.org/Public/Dist/Display.html?Name=Pod-Readme',
);

configure_requires();

build_requires(
    'Exporter::Lite' => 0,
    'Test::Most'     => 0,
);

requires(
    'CPAN::Changes'              => 0,
    'CPAN::Meta'                 => 0,
    'ExtUtils::MakeMaker'        => 6.56,
    'File::Slurp'                => 0,
    'Getopt::Long::Descriptive'  => 0.097,
    'Hash::Util'                 => 0,
    'IO'                         => 0,
    'IPC::System::Simple'        => 0,
    'Module::CoreList'           => 0,
    'Moose'                      => 0,
    'MooseX::Object::Pluggable'  => 0,
    'MooseX::Types::IO'          => 0,
    'MooseX::Types::Path::Class' => 0,
    'namespace::autoclean'       => 0,
    'Path::Class'                => 0.33,
    'Try::Tiny'                  => 0,
    'version'                    => 0.77,
);

test_requires(
    'Exporter::Lite' => 0,
    'Test::Most'     => 0,
);

install_script( qw{ bin/pod2readme } );

install_as_cpan;
auto_install;
WriteAll;
