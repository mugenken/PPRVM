use strict;
use warnings;

use Test::More tests => 2;
use PPRVM::Config;
use File::Temp qw[ tempfile tempdir ];

my $yaml = '
---
latest_ruby:
  archtype: tgz
  dir: ruby-1.9.2-p180
  file: ruby-1.9.2-p180.tar.gz
  url: ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p180.tar.gz
latest_rubygems:
  archtype: tgz
  dir: rubygems-1.6.2
  file: rubygems-1.6.2.tgz
  url: http://rubyforge.org/frs/download.php/74445/rubygems-1.6.2.tgz
ruby-1.8.7-p334:
  archtype: tgz
  dir: ruby-1.8.7-p334
  file: ruby-1.8.7-p334.tar.gz
  url: ftp://ftp.ruby-lang.org/pub/ruby/1.8/ruby-1.8.7-p334.tar.gz
ruby-1.8.7-p302:
  archtype: tgz
  dir: ruby-1.8.7-p302
  file: ruby-1.8.7-p302.tar.gz
  url: ftp://ftp.ruby-lang.org/pub/ruby/1.8/ruby-1.8.7-p302.tar.gz
ruby-1.9.2-p0:
  archtype: tgz
  dir: ruby-1.9.2-p0
  file: ruby-1.9.2-p0.tar.gz
  url: ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p0.tar.gz
ruby-1.9.2-p180:
  archtype: tgz
  dir: ruby-1.9.2-p180
  file: ruby-1.9.2-p180.tar.gz
  url: ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p180.tar.gz
rubygems-1.3.7:
  archtype: tgz
  dir: rubygems-1.3.7
  file: rubygems-1.3.7.tgz
  url: https://rubyforge.org/frs/download.php/70696/rubygems-1.3.7.tgz
rubygems-1.6.2:
  archtype: tgz
  dir: rubygems-1.6.2
  file: rubygems-1.6.2.tgz
  url: http://rubyforge.org/frs/download.php/74445/rubygems-1.6.2.tgz
';

my $hash = {
    'ruby-1.8.7-p334' => {
        'file' => 'ruby-1.8.7-p334.tar.gz',
        'url'  => 'ftp://ftp.ruby-lang.org/pub/ruby/1.8/ruby-1.8.7-p334.tar.gz',
        'dir'  => 'ruby-1.8.7-p334',
        'archtype' => 'tgz'
    },
    'ruby-1.8.7-p302' => {
        'file' => 'ruby-1.8.7-p302.tar.gz',
        'url'  => 'ftp://ftp.ruby-lang.org/pub/ruby/1.8/ruby-1.8.7-p302.tar.gz',
        'dir'  => 'ruby-1.8.7-p302',
        'archtype' => 'tgz'
    },
    'rubygems-1.6.2' => {
        'file' => 'rubygems-1.6.2.tgz',
        'url' =>
          'http://rubyforge.org/frs/download.php/74445/rubygems-1.6.2.tgz',
        'dir'      => 'rubygems-1.6.2',
        'archtype' => 'tgz'
    },
    'ruby-1.9.2-p180' => {
        'file' => 'ruby-1.9.2-p180.tar.gz',
        'url'  => 'ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p180.tar.gz',
        'dir'  => 'ruby-1.9.2-p180',
        'archtype' => 'tgz'
    },
    'ruby-1.9.2-p0' => {
        'file' => 'ruby-1.9.2-p0.tar.gz',
        'url'  => 'ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p0.tar.gz',
        'dir'  => 'ruby-1.9.2-p0',
        'archtype' => 'tgz'
    },
    'latest_rubygems' => {
        'file' => 'rubygems-1.6.2.tgz',
        'url' =>
          'http://rubyforge.org/frs/download.php/74445/rubygems-1.6.2.tgz',
        'dir'      => 'rubygems-1.6.2',
        'archtype' => 'tgz'
    },
    'rubygems-1.3.7' => {
        'file' => 'rubygems-1.3.7.tgz',
        'url' =>
          'https://rubyforge.org/frs/download.php/70696/rubygems-1.3.7.tgz',
        'dir'      => 'rubygems-1.3.7',
        'archtype' => 'tgz'
    },
    'latest_ruby' => {
        'file' => 'ruby-1.9.2-p180.tar.gz',
        'url'  => 'ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p180.tar.gz',
        'dir'  => 'ruby-1.9.2-p180',
        'archtype' => 'tgz'
    }
};

my ( $fh, $filename ) = tempfile;

print $fh $yaml;
close $fh;

my $rvmconfig = PPRVM::Config->new();
is_deeply $rvmconfig->download_db, $hash, 'default db should be the same as test db';

$rvmconfig = PPRVM::Config->new( db_file => $filename );
is_deeply $rvmconfig->download_db, $hash, 'db loaded from yaml should be the same as test db';
