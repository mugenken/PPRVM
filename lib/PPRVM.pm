use MooseX::Declare;

class PPRVM {

    use autodie;
    use File::Util;
    use PPRVM::Types ':all';
    use YAML;

    has config => ( is => 'rw', isa => 'PPRVMConfig' );
    has path_to => ( is => 'rw', isa => 'HashRef' );

    our $VERSION = '0.02.15';
    my $sl = File::Util->SL;

    method BUILD {
        $self->path_to($self->config->path_map);
    }

    # create root directory and the other default dirs
    method bootstrap {
        $self->_sanity_check;

        if ( not -d $self->path_to->{'root'} ){
            mkdir $self->path_to->{'root'};
            while ( my ($k, $v) = each %{ $self->config->{'dirs'} }){
                mkdir $self->path_to->{'root'} . $sl . $v;
            }

            open my $fh, '>', $self->path_to->{'db_file'};
            # is a ref so it needs to be derefed
            print $fh Dump $self->config->download_db;
            close $fh;
        }

        return 1;
    }

    method install {
        $self->_sanity_check;
        if ( not $self->is_installed ){
            $self->_fetch_source;
            $self->_unpack_source;
            $self->_configure_and_make_and_install;
            $self->_copy_bin;
            $self->_set_installed;
        }
        # check for platform
        $self->_write_bash_exports;
        # $self->_write_win_exports;
        # $self->_write_shell_exports;
        $self->_install_rubygems;
    }

    method is_installed {

        # not installed if db does not exist
        if ( not -f $self->path_to->{'installed_db'}){
            return 0
        }

        open my $installed_db_in, '<', $self->path_to->{'installed_db'};

        while (<$installed_db_in>){
            chomp;
            # we found it and return in triumph
            if ($_ eq $self->path_to->{'real_version'}){
                close $installed_db_in;
                return 1;
            }
        }

        # not installed
        return 0;
    }

    method _sanity_check {
        return 1;
    }

    method _fetch_source {
        my $ruby_source = $self->path_to->{'ruby_url'};

        chdir $self->path_to->{'source'};

        system "wget -q -c -nc --tries=10 $ruby_source";

        return 1;
    }

    method _unpack_source {
        chdir $self->path_to->{'source'};

        system "tar xf " . $self->path_to->{'ruby_archive'};

        return 1;
    }

    method _configure_and_make_and_install {

        chdir $self->path_to->{'ruby_src'};

        my $prefix = $self->path_to->{'ruby_dest'};

        system "./configure --enable-pthread --enable-shared --prefix=$prefix && make && make install";

        return 1;
    }

    method _write_bash_exports {

        open my $rcfile, '>', $self->path_to->{'pprvmrc'};

        print $rcfile "export RUBY_VERSION="
            . $self->path_to->{'real_version'}
            . "\n";
        print $rcfile "export GEM_PATH="
            . $self->path_to->{'gem_dir'}
            . "\n";
        print $rcfile "export GEM_HOME="
            . $self->path_to->{'gem_dir'}
            . "\n";
        print $rcfile "export MY_RUBY_HOME="
            . $self->path_to->{'ruby_dest'}
            . "\n";
        print $rcfile "export PATH="
            . $self->path_to->{'path'}
            . "\n";

        close $rcfile;

        return 1;
    }

    method _set_installed {

        # make sure no doublicates exist
        my %installed = (
            $self->path_to->{'real_version'} => undef,
        );

        if ( -f $self->path_to->{'installed_db'}){
            open my $installed_db_in, '<', $self->path_to->{'installed_db'};

            while (<$installed_db_in>){
                next if $_ !~ /^\S.*/;
                chomp;
                $installed{$_} = undef;
            }

            close $installed_db_in;
        }

        open my $installed_db_out, '>', $self->path_to->{'installed_db'};

        for (keys %installed){
            print $installed_db_out $_ . "\n";
        }

        close $installed_db_out;

        return 1;
    }

    method _install_rubygems {

        if ( not -d $self->path_to->{'rubygems_src'}){
            my $rubygem_source = $self->path_to->{'rubygems_url'};
            chdir $self->path_to->{'source'};
            system "wget -q -c -nc --tries=10 $rubygem_source";
            system "tar xf " . $self->path_to->{'rubygems_archive'};
        }

        chdir $self->path_to->{'rubygems_src'};

        system "source "
            . $self->path_to->{'pprvmrc'}
            . ";"
            . "ruby setup.rb";
    }

    method _copy_bin {
        system "cp "
            . $self->path_to->{'ruby_src'}
            . $sl
            . 'bin'
            . $sl
            . '* '
            . $self->path_to->{'ruby_dest'}
            . $sl
            . 'bin'
            . $sl;
    }
}

=head1 NAME

PPRVM - The great new Perl Powered RVM!

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

This module provides a subset of rvm's functionality. It aims to be more
friendly to use when autogenerating users.

The config can be provided as hash referene or PPRVM::Config object.

    use PPRVM;

    my $rvm = PPRVM->new(
        config => {
            rootdir => '.pprvm',
        },
    );


    use PPRVM;
    use PPRVM::Config;

    my $config = PPRVM::Config->new(
        rootdir => '.pprvm',
    )

    my $rvm = PPRVM->new(
        config => $config,
    );

=head1 SUBROUTINES/METHODS

=head2 bootstrap

Will create the directory structure according to the given config.

    my $result = $rvm->bootstrap;

=head2 install

Will install OR change to the ruby version given.

    my $result = $rvm->install;

=head2 is_installed

Will return 1 if the given ruby version is installed and 0 if it is not.

    my $result = $rvm->is_installed('ruby-1.9.2-p180');

=head1 AUTHOR

Mugen Kenichi, C<< <mugen at braincore.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-pprvm at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PPRVM>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PPRVM


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=PPRVM>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/PPRVM>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/PPRVM>

=item * Search CPAN

L<http://search.cpan.org/dist/PPRVM/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 Mugen Kenichi.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
