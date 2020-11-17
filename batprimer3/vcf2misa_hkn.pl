#!/usr/bin/perl

foreach  $filename(@ARGV) {
open (IN,"<$filename");
$filename =~ s/\.out\.vcf//;

open (OUT,">$filename.misa");
#print OUT "##fileformat=VCFv4.1\n##source=VarScan2\n";
my $count;
while($line=<IN>){
	if ($line=~m/#/){
	next;
	}else{
	my @data=split(/\t/,$line);
	my $len;
	$count++;
	if ($data[4] =~ /,/) {
		my @d=split(/,/,$data[4]);
		$len=abs((length $d[1])-(length $d[0]));
	}else{
		$len=abs((length $data[4])-(length $data[3]));
	} 
	print OUT "$data[0]\t$count\t$data[1]\t$len\n";
	}
}
}
