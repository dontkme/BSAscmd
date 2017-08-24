#!/usr/bin/perl

#AUTHORS
# Kaining Hu (c) 2017
# Filter SNP_Index (FSI)v1.1000 2017/08/25
# hukaining@gmail.com
#
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;

use re 'eval';

our $opfn="";
my $verbose;
our $ADP = "";
our $WT = "";
our $HET = "";
our $HOM = "";
our $NC = "";
our $Ainfo;
our $mindepth=20;
our $filterpercent=0.3;

GetOptions("o=s" => \$opfn,"d=i"=>\$mindepth,"f=f"=>\$filterpercent,"verbose"=>\$verbose)
	or die("[-]Error in command line arguments\n    Filter SNP_Index (FSI)v1.1000 2017/08/25\nUsage: perl FSI.pl [options] <inputfile>\n
  options:\n
	 [-o outprefix default: filtered.out]\n
	 [-d int|mindepth default: 20]\n
	 [-f float|filterpercent [0-1.0] default: 0.3]\n
  Note: Compare with two samples and get abs delta SNP-Index. \n");
	#open IN,"chrA09.snp.vcf";
if ($opfn eq ""){
$opfn="filtered.out";
print "Output file:$opfn.txt \n";
}else{
print "Output file:$opfn.txt \n";
}

open OUT, "> $opfn.txt" or die ("[-] Error: Can't open or creat $opfn.txt\n");
print OUT "#CHROM\tPOS\tREF\tALT\tADP\tWT\tHET\tHOM\tNC\tS1_SDP\tS1_DP\tS1_RD\tS1_AD\tS1_FREQ\tS1_PVAL\tS2_SDP\tS2_DP\tS2_RD\tS2_AD\tS2_FREQ\tS2_PVAL\tabsDeltaFREQ\n";

#while(defined(our $row = <>)){
while(our $row = <>){	
#while(our $seq = <SEQFILENAME>){
	#chomp $row;
	if ($row =~ m/^\#/) {next;}
	
	my @col =split(/\t/,$row);
	my $Chr = $col[0];
	my $Pos = $col[1];
	my $Ref = $col[3];
	my $Alt = $col[4];
	 $Ainfo = $col[7];
	#print $Ainfo;
	#ADP=99;WT=0;HET=0;HOM=2;NC=0
	if ($Ainfo eq ""){}
	if ($Ainfo =~ m/ADP\=(\d+)\;WT\=(\d+)\;HET\=(\d+)\;HOM\=(\d+)\;NC\=(\d+)/) {
		 $ADP = $1;
		 $WT = $2;
		 $HET = $3;
		 $HOM = $4;
		 $NC = $5;
		
		if ($NC>0){next;}
		if ($HOM==2){next;}
		if ($ADP<$mindepth) {next;}
		
	}

	my @S1info = split(/:/,$col[9]);
	my @S2info = split (/:/,$col[10]);
	if ($S1info[0] eq'./.' or $S2info[0] eq './.') {
		next;
	}
	my $S1index = $S1info[6];
	my $S2index = $S2info[6];
	$S1index =~ s/\%//;
	$S2index =~ s/\%//;
	#if ($S1index/100<0.3 and $S2index/100<0.3) {next;}
	if ($S1index/100<$filterpercent and $S2index/100<$filterpercent) {next;}
	my $absdeltaindex=abs($S1index-$S2index)/100;
	
	
	print OUT "$Chr\t$Pos\t$Ref\t$Alt\t$ADP\t$WT\t$HET\t$HOM\t$NC\t".join("\t",@S1info[2,3,4,5,6,7])."\t".join("\t",@S2info[2,3,4,5,6,7])."\t$absdeltaindex\n";
	
}
close OUT;