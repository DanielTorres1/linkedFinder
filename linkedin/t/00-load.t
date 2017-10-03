#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'linkedin' ) || print "Bail out!\n";
}

diag( "Testing linkedin $linkedin::VERSION, Perl $], $^X" );
