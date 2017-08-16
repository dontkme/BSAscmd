#!/usr/bin/perl -w
# Author: Thomas Thiel
# Program name: primer3_in.pl
# Description: creates a PRIMER3 input file based on SSR search results

my ($sec,$min,$hour)=localtime(time);
print "$hour-$min-$sec\n";

open (IN,"<$ARGV[0]") || die ("\nError: Couldn't open misa.pl results file (*.misa) !\n\n");




my $filename = $ARGV[0];
$filename =~ s/\.misa//;
open (SRC,"<$ARGV[1]") || die ("\nError: Couldn't open source file containing original FASTA sequences !\n\n");
open (OUT,">$filename.p3in");

 my $count;
  
  while (<IN>) {
	
    next unless  (my ($id0,$ssr_nr,$start,$size)= /(\S+)\t(\d+)\t(\d+)\t(\d+)/g); #用于匹配 $1,$2,$3等     
   #	ID	SSR nr.	SSR type	SSR	size	start	end
    #  Scaffold000001	1	13128	26

	my $id2="$id0"."_$ssr_nr";  #构建一个唯一键值
	
	$sid_id2{$id2}=$id0;
    $nr_id2{$id2}=$ssr_nr;
	$start_id2{$id2}=$start;
    $size_id2{$id2}=$size;
	 };


undef $/;


$/= ">";  #系统变量 分割符号，默认为\n


while (<SRC>)
  {
  next unless (my ($id,$seq) = /(.*?)\n(.*)/s); 
  $seq =~ s/[\d\s>]//g;#remove digits, spaces, line breaks,...   ~ 匹配符号
  $seq_id{$id}=$seq;
  };

   sub by_id {
	   $sid_id2{$a} cmp $sid_id2{$b} 
          or
        $nr_id2{$a} <=> $nr_id2{$b}
       }

  foreach $id5 (sort by_id keys %sid_id2) {
		 my $id3=$sid_id2{$id5};
    	my $start3=$start_id2{$id5};
        my $size3=$size_id2{$id5};
	 

    my $start2= ($start3<300) ? 0:$start3-300; 
	
	    my $seq1=substr($seq_id{$id3},$start2,$size3+600);
	
    $count++;
    print OUT "PRIMER_SEQUENCE_ID=$id5\nSEQUENCE_TEMPLATE=$seq1\n";
    print OUT "PRIMER_PRODUCT_SIZE_RANGE=121-150\n";
    print OUT "TARGET=",$start3-3-$start2,",",$size3+6,"\n";
    print OUT "PRIMER_MAX_END_STABILITY=250\n=\n";
	
		
		};
		 
		print "\n$count records created.\n";
		my ($sec1,$min1,$hour1)=localtime(time);
        print "$hour1-$min1-$sec1\n";



