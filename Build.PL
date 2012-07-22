use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Context',
    license             => 'perl',
    dist_author         => q{Jerome Eteve <jerome.eteve@gmail.com>},
    dist_version_from   => 'lib/Context.pm',
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'perl' => 5.006,
    },
    add_to_cleanup      => [ 'Context-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
