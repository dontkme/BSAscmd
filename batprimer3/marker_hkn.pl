#!/usr/bin/perl -w
use strict;

my $dry_run = 0; 
sub run_cmd(@) {
    
    my ($cmd,$redirect) = @_;   
    print localtime() . ": marker.pl: $cmd\n";   
    return if $dry_run;  
    if ($redirect) { system ( "$cmd > $redirect" ) }
    else           { system ( $cmd ); }
}

my %para = @ARGV;
my $ref = $para{"-x"} || die ("\nError: parameter -x (reference) doesn't exist !\n");
my $head = $para{"-m"} || die ("\nError: parameter -m (.misa infile name) doesn't exist !\n");

run_cmd( "perl p3_in_hkn.pl $head.misa $ref" );
run_cmd( "primer3_core <$head.p3in >$head.p3out" );
run_cmd( "perl p3_out_hkn.pl $head.p3out $head.misa" );



