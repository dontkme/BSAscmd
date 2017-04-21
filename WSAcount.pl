#!/usr/bin/perl

#AUTHORS
# Kaining Hu (c) 2017
# Window Slide Analysis Sount simple command (WSAcount)v1.0000 2017/04/21
# hukaining@gmail.com
#
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;

use re 'eval';

our $opfn="";
my $verbose;
our $step = 25000;
our $window = 50000;
our $Chrlenlist = "Chrlength.txt";
our $Fline= -1;

GetOptions("o=s" => \$opfn,"verbose"=>\$verbose,"s=i"=>\$step, "w=i"=>\$window, "l=s"=> \$Chrlenlist,"f=f"=>\$Fline)
	or die("Error in command line arguments\nUsage: 
	\nperl WSAcount.pl [options] -l <Chromesome Length List> <inputFSIout>\n
	options:\n
	 [-o outprefix default: filtered.wsa.out]\n
	 [-s int|Step size default:25000]\n
	 [-w int|window size default: 50000]\n
	 [-f float|ABS delta SNP-Index Filter line [0-1.0] default: -1]\n
	 Note: Window slide analysis SNP/Indel counts.\n");
	#open IN,"chrA09.snp.vcf";

print "Step Size: $step\nWindow Size: $window\n";
if ($step>$window) {
	die("[-] Error: -s <Step Size> must <= -w <Window size> .\n");
}

open LEN, "$Chrlenlist" or die ("[-] Error: Can't open the Chromesome Length List.");

if ($opfn eq ""){
$opfn="filtered.wsa.out";
print "Output file:$opfn.txt \n";
}else{
print "Output file:$opfn.txt \n";
}

open OUT, "> $opfn.txt" or die ("[-] Error: Can't open or creat $opfn.txt\n");
print OUT "#CHROM\tPOS_Start\tPOS_End\tPOS_Mid\tm(dsi>$Fline)\n";


our %chrl;
our @chrs=();
while (my $chrinfo=<LEN>) {
	 chomp $chrinfo;
	 if ($chrinfo =~ m/^\#/) {next;}
	 my @chrlen = split (/\t/,$chrinfo);
	 push @chrs, $chrlen[0];
	 $chrl{$chrlen[0]}=$chrlen[1];
}

our @allsnp=();
while (defined(our $brow=<>)){
	chomp $brow;
	push @allsnp, $brow;
	
}



foreach our $chrid (@chrs){
	our $len=$chrl{$chrid};
	print "Deal with $chrid \n";
	#my $count1=0;
	
	our @snps=();
	
	foreach my $row (@allsnp) {
	#while (my $row=<>) {
		chomp $row;
		my @FSI = split (/\t/,$row);
		if ($FSI[0] eq $chrid and $FSI[21]>=$Fline){
			push @snps, $FSI[1];
		}else {
			next;
		}
#			if ($row=~m/__END__/) {
#				
#				last;
#				}
		}
		
		if (scalar @snps ==0) {
			print "[-] Not load $chrid pos.\n";
			next;
		}
		
	
		for (my $posstart=0;$posstart <= $len;$posstart+=$step){
			my $posend = $posstart + $window;
			my $posmid = ($posstart+$posend)/2;
			my $count1=0;
			foreach my $snppos (@snps){
				if ($snppos>=$posstart and $snppos<=$posend){$count1++;}
				if ($snppos>$posend){
					print OUT "$chrid\t$posstart\t$posend\t$posmid\t$count1\n";
					last;
				}
			}
		}
		print "[+] $chrid done.\n";
		
}

close OUT;
print "All done.\n"