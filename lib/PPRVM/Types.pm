use MooseX::Declare;

class PPRVM::Types {
    use Moose::Util::TypeConstraints;

    subtype 'PPRVMConfig'
        => as 'Defined'
        => where {
            ref($_) eq 'HASH'
                or
            ref($_) eq 'PPRVM::Config'
        }
        => message {
            'No valid PPRVM config.'
        };
}

=head1 NAME

PPRVM::Types - Types inherited of MooseX::Types to be used by PPRVM

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

Currently containing a single type.

=head1 TYPES

=head2 PPRVMConfig

Checks if typeref is a hash or PPRVM::Config

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

