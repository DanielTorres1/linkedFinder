#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'googlesearch' ) || print "Bail out!\n";
}

diag( "Testing googlesearch $googlesearch::VERSION, Perl $], $^X" );
