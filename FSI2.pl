#!/usr/bin/perl

#AUTHORS
# Kaining Hu (c) 2017
# Filter SNP_Index (FSI)v2.0001 2017/09/25
# hukaining@gmail.com
#
#use 5.0100;
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
our $samplenum=2;
our $compares1=1;
our $compares2=2;
our @Sindex="";
our %info;

GetOptions("o=s" => \$opfn,"d=i"=>\$mindepth,"f=f"=>\$filterpercent,"n=i"=>\$samplenum,"c1=i"=>\$compares1,"c2=i"=>\$compares2,"verbose"=>\$verbose)
	or die("[-]Error in command line arguments\n    Filter SNP_Index (FSI)v2.0000 2017/09/22\nUsage: perl FSI.pl [options] <inputfile>\n
  options:\n
	 [-o outprefix default: filtered.out]\n
	 [-d int|mindepth default: 20]\n
	 [-f float|filterpercent [0-1.0] default: 0.3]\n
  Note: Compare with two samples and get abs delta SNP-Index. \n");
	#open IN,"chrA09.snp.vcf";
if ($opfn eq ""){
$opfn="filtered.out";
print "Output file: $opfn.txt \n";
}else{
print "Output file: $opfn.txt \n";
}

open OUT, "> $opfn.txt" or die ("[-] Error: Can't open or creat $opfn.txt\n");
print "Input $samplenum samlpes.";
if ($compares1<=$samplenum and $compares2<=$samplenum){
  print "Compare sample$compares1 to sample$compares2.\n";
  }else{
    die ("[-]Error compare Sample ID.\nPlease confirm to compare sample$compares1 to sample$compares2?\n");
  } 
  
print OUT "#CHROM\tPOS\tREF\tALT\tADP\tWT\tHET\tHOM\tNC";
for (my $i=1;$i<=$samplenum;$i++){
  our $headertail="\tS{$i}_GT\tS{$i}_SDP\tS{$i}_DP\tS{$i}_RD\tS{$i}_AD\tS{$i}_FREQ\tS{$i}_PVAL";
  print OUT "$headertail";
  #print OUT "\tS{$i}_SDP\tS{$i}_DP\tS{$i}_RD\tS{$i}_AD\tS{$i}_FREQ\tS{$i}_PVAL";
} 
#print OUT "#CHROM\tPOS\tREF\tALT\tADP\tWT\tHET\tHOM\tNC\tS1_SDP\tS1_DP\tS1_RD\tS1_AD\tS1_FREQ\tS1_PVAL\tS2_SDP\tS2_DP\tS2_RD\tS2_AD\tS2_FREQ\tS2_PVAL\tabsDeltaFREQ\n";
print OUT "\tS{$compares1}_S{$compares2}.absDeltaFREQ\n";
#while(defined(our $row = <>)){
LINE: while(our $row = <>){	
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
		#if ($HOM==2){next;}
		if ($HOM==$samplenum){next;}
		if ($ADP<$mindepth) {next;}
		
	}
      for (my $j=1;$j<=$samplenum;$j++){
        #say $j;
         my @Sinfo=split(/:/,$col[8+$j]);
         $info{$j}=[@Sinfo];
         #$info{$j}=split(/:/,$col[8+$j]);
         #say $Sinfo[0];
         if ($Sinfo[0] eq './.') {
            #last;
            next LINE;
	       }
	       #say $j;
	       $Sindex[$j] = $Sinfo[6];
	       $Sindex[$j] =~ s/\%//;
	       $Sindex[$j]=$Sindex[$j]/100;
	       
	       
      }
      
      my $cs1index=$Sindex[$compares1];
      my $cs2index=$Sindex[$compares2];
      if ($cs1index<$filterpercent and $cs2index<$filterpercent) {next;}
      my $absdeltaindex=abs($cs1index-$cs2index);
     
     print OUT "$Chr\t$Pos\t$Ref\t$Alt\t$ADP\t$WT\t$HET\t$HOM\t$NC";
     our $z=1;
     for ($z=1;$z<=$samplenum;$z++){
      #say $z;
       print OUT "\t\"$info{$z}[0]\"\t$info{$z}[2]\t$info{$z}[3]\t$info{$z}[4]\t$info{$z}[5]\t$info{$z}[6]\t$info{$z}[7]";
       #print "$info{$z}[2,3,4,5,6,7]";
    
     }
     print OUT "\t$absdeltaindex\n";


#	my @S1info = split(/:/,$col[9]);
#	my @S2info = split (/:/,$col[10]);
#	if ($S1info[0] eq'./.' or $S2info[0] eq './.') {
#		next;
#	}
#	my $S1index = $S1info[6];
#	my $S2index = $S2info[6];
#	$S1index =~ s/\%//;
#	$S2index =~ s/\%//;
#	#if ($S1index/100<0.3 and $S2index/100<0.3) {next;}
#	if ($S1index/100<$filterpercent and $S2index/100<$filterpercent) {next;}
#	my $absdeltaindex=abs($S1index-$S2index)/100;
#	
#	
#	print OUT "$Chr\t$Pos\t$Ref\t$Alt\t$ADP\t$WT\t$HET\t$HOM\t$NC\t".join("\t",@S1info[2,3,4,5,6,7])."\t".join("\t",@S2info[2,3,4,5,6,7])."\t$absdeltaindex\n";
	
}
close OUT;
