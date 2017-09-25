#!/usr/bin/perl

#AUTHORS
# Kaining Hu (c) 2017
# Window Slide Analysis Count simple command (WSAcount)v2.1000 2017/09/25
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
	\nperl WSAcount.pl [options] -l <Chromesome Length List(tab)> <inputFSIout>\n
	options:\n
	 [-o outprefix default: filtered.wsa.out]\n
	 [-s int|Step size default:25000]\n
	 [-w int|window size default: 50000]\n
	 [-f float|ABS delta SNP-Index Filter line [0-1.0] default: -1]\n
	 Note: Window slide analysis SNP/Indel counts.\n");
	#open IN,"chrA09.snp.vcf";

print "Step Size: $step\nWindow Size: $window\nFilter line: $Fline\n";
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

open OUT, "> $opfn.count.txt" or die ("[-] Error: Can't open or creat $opfn.count.txt\n");
print OUT "#CHROM\tPOS_Start\tPOS_End\tPOS_Mid\tCounts(dsi>$Fline)\tS1_average_freq\tS2_average_freq\tdelta_average_freq\n";

open OUT2, "> $opfn.freq.txt" or die ("[-] Error: Can't open or creat $opfn.freq.txt\n");
print OUT2 "#CHROM\tPOS\tREF\tALT\tADP\tWT\tHET\tHOM\tNC\tS1_GT\tS1_SDP\tS1_DP\tS1_RD\tS1_AD\tS1_FREQ\tS1_PVAL\tS2_GT\tS2_SDP\tS2_DP\tS2_RD\tS2_AD\tS2_FREQ\tS2_PVAL\tabsDeltaFREQ\twindow_counts\tS1_average_freq\tS2_average_freq\tdelta_average_freq\n";

our %chrl;
our @chrs=();
while (my $chrinfo=<LEN>) {
	 chomp ($chrinfo);
	 if ($chrinfo =~ m/^\#/) {next;}
	 my @chrlen = split (/\t/,$chrinfo);
	 push @chrs, $chrlen[0];
	 $chrl{$chrlen[0]}=$chrlen[1];
}

our @allsnp=();
while (defined(our $brow=<>)){
	chomp ($brow);
	push @allsnp, $brow;
	
}



foreach our $chrid (@chrs){
	our $len=$chrl{$chrid};
	print "Deal with $chrid length: $len\n";
	#my $count1=0;
	
	our @snps=();
	our @sortsnps=();
	our @chrsnps=();
	our %snpS1freq=();
	our %snpS2freq=();
	our %snpdeltafreq=();
	
	
	foreach my $row (@allsnp) {
	#while (my $row=<>) {
		chomp ($row);
		my @FSI = split (/\t/,$row);
		#print "$FSI[0] $FSI[1] $FSI[23]\n";
		if ($FSI[0] eq $chrid and $FSI[23]>=$Fline){
		  push @chrsnps, $row;
			push @snps, $FSI[1];
				my $S1index = $FSI[14];
	      my $S2index = $FSI[21];
	         $S1index =~ s/\%//;
	         $S2index =~ s/\%//;
	         $snpS1freq{$FSI[1]}=$S1index/100;
	         $snpS2freq{$FSI[1]}=$S2index/100;
	         $snpdeltafreq{$FSI[1]}=$FSI[23];
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
		print scalar @snps." SNP/Indel record(s) abs delta SNP-index larger than $Fline filter line.\n";
		@sortsnps = sort {$a<=>$b} @snps;
	
		for (my $posstart=0;$posstart < $len+$step;$posstart+=$step){
			my $posend = $posstart + $window;
			my $posmid = ($posstart+$posend)/2;
			my $count1=0;
			my $S1freqsum=0;
			my $S2freqsum=0;
			my $deltafreqsum=0;
			my $S1averagefreq=0;
      my $S2averagefreq=0;
      my $deltaaveragefreq=0;
      
      
			foreach my $snppos (@sortsnps){
			  
				if ($snppos>=$posstart and $snppos<=$posend){
				  $count1++;
				   $S1freqsum+=$snpS1freq{$snppos};
				  #print "$S1freqsum\n";
				   $S2freqsum+=$snpS2freq{$snppos};
				   $deltafreqsum+=$snpdeltafreq{$snppos};
				}
				  
				if ($snppos>$posend){
				  
				    if ($count1!=0) {
               $S1averagefreq=$S1freqsum/$count1;
             $S2averagefreq=$S2freqsum/$count1;
             $deltaaveragefreq=$deltafreqsum/$count1;
            }
					print OUT "$chrid\t$posstart\t$posend\t$posmid\t$count1\t$S1averagefreq\t$S2averagefreq\t$deltaaveragefreq\n";
					
					last;
				}
			}
			
			
			foreach my $id (@chrsnps){
	          my @OUT2=split/\t/,$id;
	          
            if ($OUT2[0]eq $chrid and $OUT2[1]>=$posstart and $OUT2[1]<=$posend) {
              #my $snpid=$OUT2[1];
             # print "$S1freqsum\n";
              #my $S1averagefreq=$S1freqsum/$count1;
              #my $S2averagefreq=$S2freqsum/$count1;
              #my $deltaaveragefreq=$deltafreqsum/$count1;
             print OUT2 "$id\t$count1\t$S1averagefreq\t$S2averagefreq\t$deltaaveragefreq\n";
            }
          	
          	 
      }
		}
		
		
		print "[+] $chrid done.\n";
		
}

close OUT;
close OUT2;
print "All done.\n"
