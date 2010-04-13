use Module::Build;

my $build = Module::Build->new
    (
     module_name => 'Pod::Readme',
     license => 'perl',
     requires => {
       'perl'             => '5.005',
       'Carp'             => 0,
       'File::Copy'       => 0,       # for pod2readme script
       'IO::File'         => 0,
       'Pod::Text'        => '3.0',
       'Regexp::Common'   => 0,
     },
     recommends => {
       'Test::Pod'                => '1.00', # for DEVEL_TESTS tests
       'Test::Pod::Coverage'      => 0,
       'Test::Portability::Files' => 0,      #
     },
     build_requires => {
       'Test::More'     => 0,
     },
     script_files       => [
       'bin/pod2readme',
     ],
     create_readme      => ($Module::Build::VERSION >= 0.2702),
     create_makefile_pl => 'traditional',
     dist_author        => 'Robert Rothenberg <rrwo at cpan.org>',
     sign               => 0,
);

$build->create_build_script;

