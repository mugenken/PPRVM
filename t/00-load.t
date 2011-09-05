#!perl

use Test::More tests => 1;

BEGIN {
    use_ok( 'PPRVM' ) || print "Bail out!";
}

diag( "Testing PPRVM $PPRVM::VERSION, Perl $], $^X" );
