use strict;
use warnings FATAL => 'all';
use inc::Module::Install;

author 'Robert Rothenberg <rrwo@cpan.org>';
name 'Pod-Readme';
all_from 'lib/Pod/Readme.pm';
license 'artistic2';

tests_recursive('t');

resources(
    license    => 'http://www.perlfoundation.org/artistic_license_2_0',
    repository => 'git://github.com/bigpresh/Pod-Readme.git',
    bugtracker => 'https://github.com/bigpresh/Pod-Readme/issues',
);

configure_requires();

build_requires(
    'Exporter::Lite' => 0,
    'Test::Most'     => 0,
);

requires(
    'CPAN::Changes'              => '0.30',
    'CPAN::Meta'                 => 0,
    'ExtUtils::MakeMaker'        => 6.56,
    'File::Slurp'                => 0,
    'Getopt::Long::Descriptive'  => 0,
    'Hash::Util'                 => 0,
    'IO'                         => 0,
    'Module::CoreList'           => 0,
    'Moose'                      => 0,
    'MooseX::Object::Pluggable'  => 0,
    'MooseX::Types::IO'          => 0,
    'MooseX::Types::Path::Class' => 0,
    'namespace::autoclean'       => 0,
    'Path::Class'                => 0.33,
    'Pod::Simple'                => 0,
    'Try::Tiny'                  => 0,
    'version'                    => 0.77,
);

recommends(
    'Pod::Simple::LaTeX' => 0,
    'Pod::Man'           => 0,
    'Pod::Markdown'      => 0,
);

test_requires(
    'Exporter::Lite' => 0,
    'File::Compare'  => 0,
    'File::Temp'     => 0,
    'Test::Most'     => 0,    # requires Test::More
);

install_script(qw{ bin/pod2readme });

author_requires(
    'Module::Install::AuthorRequires' => 0.02,
    'Module::Install::AuthorTests'    => 0,
    'Test::CheckManifest'             => 0.9,
    'Test::Perl::Critic'              => 0,
    'Test::Portability::Files'        => 0,
    'Test::Pod'                       => '1.00',
    'Test::CleanNamespaces'           => 0,
    'Test::Pod::Coverage'             => 0,
    'Test::MinimumVersion'            => 0,
);

recursive_author_tests('xt');

install_as_cpan;
auto_install;
WriteAll;
