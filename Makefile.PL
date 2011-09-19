use strict;
use warnings;
use autodie;
use ExtUtils::MakeMaker;
use YAML;
use JSON;

my $provides = {
    'PPRVM'         => 'lib/PPRVM.pm',
    'PPRVM::Config' => 'lib/PPRVM/Config.pm',
    'PPRVM::Types'  => 'lib/PPRVM/Types.pm',
};

my $release_status = 'unstable';
my $license        = ['MIT'];

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
        'JSON'       => 0,
        'MooseX::Declare' => 0.34,
        'Sub::Exporter::ForMethods' => 0,
        'Data::Section' => 0,
    },
    INST_SCRIPT         => 'script/',
    NO_META             => 1,
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'PPRVM-*' },
);

my $mymeta_yml_str;
my $mymeta_json_str;

{
    local $/;
    open my $mymeta, '<', 'MYMETA.yml';
    $mymeta_yml_str = <$mymeta>;
    close $mymeta;
}

{
    local $/;
    open my $mymeta, '<', 'MYMETA.json';
    $mymeta_json_str = <$mymeta>;
    close $mymeta;
}

my $mymeta_json = decode_json $mymeta_json_str;
my $mymeta_yml  = Load $mymeta_yml_str;

$mymeta_json->{provides} = $provides;
$mymeta_json->{license} = $license;
$mymeta_json->{release_status} = $release_status;

$mymeta_yml->{provides} = $provides;
$mymeta_yml->{license} = $license;
$mymeta_yml->{release_status} = $release_status;

open my $meta_yml, '>', 'META.yml';
print $meta_yml Dump $mymeta_yml;
close $meta_yml;

open my $meta_json, '>', 'META.json';
print $meta_json to_json $mymeta_json, ({ pretty => 1 });
close $meta_json;

