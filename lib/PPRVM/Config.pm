# needed to keep __DATA__ in class scope
package PPRVM::Config;

use MooseX::Declare;

class PPRVM::Config {

    use File::Util;
    use autodie;
    use YAML;

    # needed to make use of __DATA__ sections with MooseX::Declare
    # as namespace::autoclean throws Data::Sections exports out of
    # class scope
    use Sub::Exporter::ForMethods qw|method_installer|;
    use Data::Section { installer => method_installer }, -setup;

    has rootdir => ( is => 'rw', isa => 'Str' );
    has ruby_version => ( is => 'rw', isa => 'Str' );
    has rubygems_version => ( is => 'rw', isa => 'Str' );
    has version_map => ( is => 'rw', isa => 'Str' );
    has pprvmrc => ( is => 'rw', isa => 'Str' );
    has dirs    => ( is => 'rw', isa => 'HashRef');
    has installed_db => ( is => 'rw', isa => 'Str' );
    has download_db => ( is => 'rw', isa => 'HashRef' );
    has db_file => ( is => 'ro', isa => 'Str' );
    has path_map => ( is => 'rw', isa => 'HashRef' );
    has bootstrap_only => ( is => 'rw', isa => 'Bool', default => 0 );

    my $sl = File::Util->SL;

    method BUILD {
        $self->_make_base_config;
        $self->_make_db unless $self->download_db;
        die "sanity check failed\n" unless $self->_sanity_check;
        $self->_make_path_map;
    }

    method _make_base_config {
        # load default config unless options are defined
        $self->rootdir('.pprvm') unless $self->rootdir;
        $self->ruby_version('latest_ruby') unless $self->ruby_version;
        $self->rubygems_version('latest_rubygems') unless $self->rubygems_version;
        unless ($self->dirs){
            $self->dirs({
                 bin => 'bin',
                 source => 'source',
                 var => 'var',
                 gemsets => 'gemsets',
                 rubies => 'rubies',
            });
        }
        $self->pprvmrc('pprvmrc') unless $self->pprvmrc;
        $self->installed_db('installed_db') unless $self->installed_db;

        return 1;
    }

    method _make_db {

        # at bootstrap time no default config file exists leading to errors
        # if none is given
        if ($self->bootstrap_only){
            $self->download_db(Load ${$self->section_data('defaultDB')});
            return 1;
        }

        my $file = undef;

        if (defined $self->db_file && -f $self->db_file){
            $file = $self->db_file;
        }
        elsif ( -f $ENV{'HOME'}
                . $sl
                . $self->rootdir
                . $sl
                . $self->dirs->{'var'}
                . $sl
                . 'db.yml'
        ){
            $file = $ENV{'HOME'}
                . $sl
                . $self->rootdir
                . $sl
                . $self->dirs->{'var'}
                . $sl
                . 'db.yml';
        }
        else {
            $self->download_db(Load ${$self->section_data('defaultDB')});
        }

        if (defined $file){
            my $slurp;
            open my $fh, '<', $file;
            $slurp = do { local $/; <$fh> };
            close $fh;

            $self->download_db(Load $slurp);
        }

        return 1;
    }

    method _sanity_check {
        my $err = 0;

        if (not defined $self->download_db->{$self->ruby_version}){
            warn "ruby version " . $self->ruby_version . " not in database.\n";
            $err++;
        }
        if (not defined $self->download_db->{$self->rubygems_version}){
            warn "rubygems version " . $self->rubygems_version . " not in database.\n";
            $err++;
        }

        return $err ? 0 : 1;
    }

    method _make_path_map {
        my $pathmap = {
            'root' =>
                $ENV{'HOME'}
                . $sl
                . $self->rootdir,
            'real_version' =>
                $self->download_db->{$self->ruby_version}->{'dir'},
            'installed_db' =>
                $ENV{'HOME'}
                . $sl
                . $self->rootdir
                . $sl
                . $self->dirs->{'var'}
                . $sl
                . $self->installed_db,
            'db_file' =>
                $ENV{'HOME'}
                . $sl
                . $self->rootdir
                . $sl
                . $self->dirs->{'var'}
                . $sl
                . 'db.yml',
            'pprvmrc' =>
                $ENV{'HOME'}
                . $sl
                . $self->rootdir
                . $sl
                . $self->dirs->{'var'}
                . $sl
                . $self->pprvmrc,
            'ruby_dest' =>
                $ENV{'HOME'}
                . $sl
                . $self->rootdir
                . $sl
                . $self->dirs->{'rubies'}
                . $sl
                . $self->download_db->{$self->ruby_version}->{'dir'},
            'ruby_src' =>
                $ENV{'HOME'}
                . $sl
                . $self->rootdir
                . $sl
                . $self->dirs->{'source'}
                . $sl
                . $self->download_db->{$self->ruby_version}->{'dir'},
            'ruby_url' =>
                $self->download_db->{$self->ruby_version}->{'url'},
            'ruby_archive' =>
                $ENV{'HOME'}
                . $sl
                . $self->rootdir
                . $sl
                . $self->dirs->{'source'}
                . $sl
                . $self->download_db->{$self->ruby_version}->{'file'},
            'gem_dir' =>
                $ENV{'HOME'}
                . $sl
                . $self->rootdir
                . $sl
                . $self->dirs->{'gemsets'}
                . $sl
                . $self->download_db->{$self->ruby_version}->{'dir'},
            'path' =>
                $ENV{'HOME'}
                . $sl
                . $self->rootdir
                . $sl
                . $self->dirs->{'rubies'}
                . $sl
                . $self->download_db->{$self->ruby_version}->{'dir'}
                . $sl
                . 'bin'
                . ':'
                . $ENV{'HOME'}
                . $sl
                . $self->rootdir
                . $sl
                . $self->dirs->{'gemsets'}
                . $sl
                . $self->download_db->{$self->ruby_version}->{'dir'}
                . $sl
                . 'bin'
                . ':'
                . '$PATH',
            'rubygems_src' =>
                $ENV{'HOME'}
                . $sl
                . $self->rootdir
                . $sl
                . $self->dirs->{'source'}
                . $sl
                . $self->download_db->{$self->rubygems_version}->{'dir'},
            'rubygems_archive' =>
                $ENV{'HOME'}
                . $sl
                . $self->rootdir
                . $sl
                . $self->dirs->{'source'}
                . $sl
                . $self->download_db->{$self->rubygems_version}->{'file'},
            'rubygems_url' =>
                $self->download_db->{$self->rubygems_version}->{'url'},

        };

        while ( my ($k,$v) = each %{ $self->dirs }){
            $pathmap->{$k} = $pathmap->{'root'}
                . $sl
                . $v;
        }

        $self->path_map($pathmap);
        return 1;
    }
}

__DATA__
__[defaultDB]__
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

__END__
=head1 NAME

PPRVM::Config - Config module used by PPRVM

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

PPRVM::Config is used to structure the PPRVM config and build sane defaults.

    my $config = PPRVM::Config->new(
        rootdir => '.pprvm',
    )

=head1 SUBROUTINES/METHODS

=head2 rootdir

The root of the whole PPRVM directory structure. Defaults to $ENV{HOME}

=head2 ruby_version

The exact ruby version (e.g. ruby-1.9.2-p180).
Defaults to 'latest'.

=head2 rubygems_version

The exact rubygems version.
Defaults to 'latest'.

=head2 pprvmrc

The file containing the shell paths and environment variables.
Defaults to '~/.pprvm/var/pprvmrc' if root_dir and dirs are default.

This file should be sourced in the users .bashrc.

=head2 dirs

A hashref defining the directories under root_dir.
Defaults to:

    {
        bin => 'bin',
        source => 'source',
        var => 'var',
        gemsets => 'gemsets',
        rubies => 'rubies',

    }

=head2 installed_db

A simple textfile with a list of installed ruby versions.

=head2 download_db

A hashref containing information on download urls and archive
type of the ruby and rubygems versions.
Example:

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

=head2 db_file

The yml file the download_db is generated from.

=head2 path_map

A hashref containing shortcuts to most config options and paths.
The path are build from config and are absolute.

Those options are:

Root dir
    $config->root

Ruby version after resolution of 'latest'
    $config->real_version

File with installed versions
    $config->installed_db

File with available versions
    $config->db_file

Environment variables and PATH
    $config->pprvmrc

Path to binaries
    $config->path

    $config->ruby_dest
    $config->ruby_src
    $config->ruby_url
    $config->ruby_archive
    $config->gem_dir
    $config->rubygems_src
    $config->rubygems_archive
    $config->rubygems_url

=head2 bootstrap_only


=head1 AUTHOR

Mugen Kenichi, C<< <mugen.kenichi at uninets.eu> >>

=head1 BUGS

Report bugs at:

=over 2

=item * Unicorn::Manager issue tracker

L<https://github.com/mugenken/Unicorn/issues>

=item * support at uninets.eu

C<< <mugen.kenichi at uninets.eu> >>

=back

=head1 SUPPORT

=over 2

=item * Technical support

C<< <mugen.kenichi at uninets.eu> >>

=back

=cut

