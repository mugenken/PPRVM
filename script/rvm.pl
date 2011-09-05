#!/usr/bin/perl

use strict;
use warnings;
use PPRVM;
use PPRVM::Config;
use Getopt::Long;

my $help_flag = 0;
my $bootstrap = 0;
my $ruby_version = '';
my $rubygems_version = '';
my $dbfile = '';

die $! unless GetOptions(
    "h|help"       => \$help_flag,
    "r|ruby=s"     => \$ruby_version,
    "g|rubygems=s" => \$rubygems_version,
    "db=s"         => \$dbfile,
    "bootstrap"    => \$bootstrap,
);

my $usage = "$0 [--help] [--db <database_file>] [--ruby <valid_version>] [--rubygems <valid_version>]\n";

if ($help_flag){
    print $usage;
    exit 0;
}


my $config = PPRVM::Config->new (
    bootstrap_only => $bootstrap,
    db_file => $dbfile,
    ruby_version => $ruby_version,
    rubygems_version => $rubygems_version,
);

my $rvm = PPRVM->new(
    config => $config,
);

$rvm->bootstrap;
$rvm->install unless $bootstrap;

