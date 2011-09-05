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

