#!/usr/bin/perl -w
# Author: Thomas Thiel; Edited by Hu Kaining 2016.12.28 for primer3 2.3.6 p3out 
# Program name: prim_output.pl
# Description: converts the Primer3 output into an table
#use 5.0080;
my ($sec,$min,$hour)=localtime(time);
print "$hour-$min-$sec\n";

open (SRC,"<$ARGV[0]") || die ("\nError: Couldn't open Primer3 results file (*.p3out) !\n\n");
my $filename = $ARGV[0];
$filename =~ s/\.p3out//;
open (IN,"<$ARGV[1]") || die ("\nError: Couldn't open source file containing MISA (*.misa) results !\n\n");
open (OUT,">$filename.results") || die ("nError: Couldn't create file !\n\n");
open (OUT2,">$filename.results2") || die ("nError: Couldn't create file !\n\n");

my ($seq_names_failed,$count,$countfailed);

print OUT "ID\tInDel nr.\tstart\tsize\t";
print OUT "FORWARD PRIMER1 (5'-3')\tTm\tsize\tREVERSE PRIMER1 (5'-3')\tTm\tsize\tPRODUCT1 size (bp)\tstart (bp)\tend (bp)\t";
print OUT "FORWARD PRIMER2 (5'-3')\tTm\tsize\tREVERSE PRIMER2 (5'-3')\tTm\tsize\tPRODUCT2 size (bp)\tstart (bp)\tend (bp)\t";
print OUT "FORWARD PRIMER3 (5'-3')\tTm\tsize\tREVERSE PRIMER3 (5'-3')\tTm\tsize\tPRODUCT3 size (bp)\tstart (bp)\tend (bp)\n";
print OUT2 "ID\tInDel nr.\tstart\tsize\t";
print OUT2 "FORWARD PRIMER1 (5'-3')\tTm\tsize\tREVERSE PRIMER1 (5'-3')\tTm\tsize\tPRODUCT1 size (bp)\tstart (bp)\tend (bp)\t";
print OUT2 "FORWARD PRIMER2 (5'-3')\tTm\tsize\tREVERSE PRIMER2 (5'-3')\tTm\tsize\tPRODUCT2 size (bp)\tstart (bp)\tend (bp)\t";
print OUT2 "FORWARD PRIMER3 (5'-3')\tTm\tsize\tREVERSE PRIMER3 (5'-3')\tTm\tsize\tPRODUCT3 size (bp)\tstart (bp)\tend (bp)\n";



  while (<IN>) {
	
    next unless  (my ($id0,$ssr_nr,$s1,$s2)= /(\S+)\t(\d+)\t(\d+)\t(\d+)/g); #用于匹配 $1,$2,$3等     
   #	ID	SSR nr.		start	SSR	size
    #  Scaffold000001	1	26003	26

	my $id2="$id0"."_$ssr_nr";  #构建一个唯一键值
	$misalist{$id2}="$id0\t$ssr_nr\t$s1\t$s2";
   $count2++;
   $orderlist{$id2}=$count2;
	 };



##############

$/ = "=\n";

while (<SRC>)
  {
  ($id2) = (/PRIMER_SEQUENCE_ID=(\S+_\d+)/);
  

  /PRIMER_LEFT_0_SEQUENCE=(.*)/ || do {$count_failed++; next};
   my $info = "$1\t";
  
  /PRIMER_LEFT_0_TM=(.*)/; $info .= "$1\t";
  /PRIMER_LEFT_0=\d+,(\d+)/; $info .= "$1\t";
  
  /PRIMER_RIGHT_0_SEQUENCE=(.*)/;  $info .= "$1\t";
  /PRIMER_RIGHT_0_TM=(.*)/; $info .= "$1\t";
  /PRIMER_RIGHT_0=\d+,(\d+)/; $info .= "$1\t";
  
  /PRIMER_PAIR_0_PRODUCT_SIZE=(.*)/; $info .= "$1\t";
  /PRIMER_LEFT_0=(\d+),\d+/; $info .= "$1\t";
  /PRIMER_RIGHT_0=(\d+),\d+/; $info .= "$1\t";
  
  
  /PRIMER_LEFT_1_SEQUENCE=(.*)/; $info .= "$1\t";
  /PRIMER_LEFT_1_TM=(.*)/; $info .= "$1\t";
  /PRIMER_LEFT_1=\d+,(\d+)/; $info .= "$1\t";
    
  /PRIMER_RIGHT_1_SEQUENCE=(.*)/;  $info .= "$1\t";
  /PRIMER_RIGHT_1_TM=(.*)/; $info .= "$1\t";
  /PRIMER_RIGHT_1=\d+,(\d+)/; $info .= "$1\t";
  
  /PRIMER_PAIR_1_PRODUCT_SIZE=(.*)/; $info .= "$1\t";
  /PRIMER_LEFT_1=(\d+),\d+/; $info .= "$1\t";
  /PRIMER_RIGHT_1=(\d+),\d+/; $info .= "$1\t";
  
  
  /PRIMER_LEFT_2_SEQUENCE=(.*)/; $info .= "$1\t";
  /PRIMER_LEFT_2_TM=(.*)/; $info .= "$1\t";
  /PRIMER_LEFT_2=\d+,(\d+)/; $info .= "$1\t";
    
  /PRIMER_RIGHT_2_SEQUENCE=(.*)/;  $info .= "$1\t";
  /PRIMER_RIGHT_2_TM=(.*)/; $info .= "$1\t";
  /PRIMER_RIGHT_2=\d+,(\d+)/; $info .= "$1\t";
  
  /PRIMER_PAIR_2_PRODUCT_SIZE=(.*)/; $info .= "$1\t";
  /PRIMER_LEFT_2=(\d+),\d+/; $info .= "$1\t";
  /PRIMER_RIGHT_2=(\d+),\d+/; $info .= "$1";
  
  $count++;
 $result{$id2}=$info;
 
  };

#####################

@allgo1=keys %misalist;             # all misa list; id_nr
@allgo1= sort by_list2 @allgo1;    
sub by_list2 { $orderlist{$a}<=> $orderlist{$b}};

for($i=0;$i<@allgo1;$i++){
my $dd=$allgo1[$i];	            # $dd is misa list; id_nr
my $dd3=$misalist{$dd};

       if ($result{$dd}) {
          $dd2=$result{$dd};

      print OUT "$dd3\t$dd2\n";
      print OUT2 "$dd3\t$dd2\n";
     }else{
      print OUT2 "$dd3\n";
                      }

 }

############
print "\nPrimer modelling was successful for $count sequences.\n";
print "Primer modelling failed for $count_failed sequences.\n";
	
		my ($sec1,$min1,$hour1)=localtime(time);
        print "$hour1-$min1-$sec1\n";
