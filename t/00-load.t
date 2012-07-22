#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Context' ) || print "Bail out!\n";
}

diag( "Testing Context $Context::VERSION, Perl $], $^X" );
