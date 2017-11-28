# BSAscmd
NGS BSA simple commands.

FSI2.pl is written by Perl for filtering the SNP-Index form VCF file which made by VarScan or any other SNP/Indel calling softwares.

Get filtered SNP/Indels simple but most important values and get the absolute value of delte SNP-Index.

   Usage: 
   
      perl FSI2.pl [options] <inputVCFfile>

   OR 
    
    ./FSI2.pl [options] <inputVCFfile>
   
 Output file could be used for next window slide analysis or draw plots of SNP-Index.
 
 Options:
 
     [-o outprefix default: filtered.out]
	 
	 [-d int|mindepth default: 20]
	 
	 [-f float|compared samples at least one SNP-index bigger than filterpercent [0-1.0] default: 0.3]
	 
	 [-n int|number of all samples default: 2]
	 
	 [-c1 int|The first sample used for comparing to the sencond sample to calculate abs delta SNP-Index default: 1]
	 
	 [-c2 int|The second sample used for comparing to the first sample to calculate abs delta SNP-Index default: 2]



WSAcount (Window Slide Analysis SNP/Indel Count simple command) 
is written by Perl for counting the filtered SNP-Index form FSI output file .

Usage:

      perl WSAcount.pl [options] -l <Chromesome Length List> <inputFSIout>

Options:

         [-o outprefix default: filtered.wsa.out]

         [-s int|Step size default:25000]

         [-w int|window size default: 50000]

         [-f float|ABS delta SNP-Index Filter line [0-1.0] default: -1]

         Note: Window slide analysis SNP/Indel counts.
         
         
