use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'PPRVM',
    AUTHOR              => q{Mugen Kenichi <mugen@braincore.org>},
    VERSION_FROM        => 'lib/PPRVM.pm',
    ABSTRACT_FROM       => 'lib/PPRVM.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'File::Util' => 0,
        'YAML'       => 0,
        'MooseX::Declare' => 0.34,
        'Sub::Exporter::ForMethods' => 0,
        'Data::Section' => 0,
    },
    INST_SCRIPT         => 'script/',
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'PPRVM-*' },
);

