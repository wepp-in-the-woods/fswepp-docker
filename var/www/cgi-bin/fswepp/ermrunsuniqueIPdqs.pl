
# 10.192.202.137	"12:59 pm  Friday January 24, 2014"	"SAN DIEGO WB AP CA"	  32.73	-117.17
# 134.121.1.72	"10:22 am  Wednesday January 22, 2014"	"BIRMINGHAM WB AP AL"	  33.57	 -86.75
# 134.121.1.72	"10:07 am  Wednesday January 22, 2014"	"BIRMINGHAM WB AP AL"	  33.57	 -86.75
# 166.5.29.117	"09:53 am  Thursday January 16, 2014"	"MOUNT SHASTA CA"	  41.32	-122.32
# 166.5.29.117	"09:49 am  Thursday January 16, 2014"	"MOUNT SHASTA CA"	  41.32	-122.32
# 193.145.230.9	"02:59 am  Thursday January 16, 2014"	"Alicante +"	  41.97	   2.83
# 193.145.230.9	"02:57 am  Thursday January 16, 2014"	"Alicante +"	  41.97	   2.83
# 193.145.230.9	"02:53 am  Thursday January 16, 2014"	"Alicante +"	  41.97	   2.83
# 193.145.230.9	"02:49 am  Thursday January 16, 2014"	"Ávila, España +"	  41.97	   2.83
# 193.145.230.9	"02:47 am  Thursday January 16, 2014"	"Ávila, España +"	  41.97	   2.83
# 193.145.230.9	"02:45 am  Thursday January 16, 2014"	"Ávila, España +"	  41.97	   2.83
# 193.145.230.9	"02:33 am  Thursday January 16, 2014"	"Ávila, España +"	  41.97	   2.83
# 193.145.230.9	"02:32 am  Thursday January 16, 2014"	"Alicante +"	  41.97	   2.83
# 193.145.230.9	"02:30 am  Thursday January 16, 2014"	"Alicante +"	  41.97	   2.83
# 193.145.230.9	"02:30 am  Thursday January 16, 2014"	"Ávila, España +"	  41.97	   2.83
# 193.145.230.9	"02:28 am  Thursday January 16, 2014"	"Alicante +"	  41.97	   2.83
# 193.145.230.9	"02:00 am  Thursday January 16, 2014"	"Ávila, España +"	  41.97	   2.83
# 193.145.230.9	"01:56 am  Thursday January 16, 2014"	"Alicante, Spain +"	  41.97	   2.83
# 193.145.230.9	"01:56 am  Thursday January 16, 2014"	"Ávila, España +"	  41.97	   2.83
# 193.145.230.9	"01:37 am  Thursday January 16, 2014"	"Alicante, Spain +"	  41.97	   2.83
# 142.94.81.133	"10:10 am  Wednesday January 15, 2014"	"BIRMINGHAM WB AP AL"	  33.57	 -86.75
# 122.163.204.89	"11:18 am  Monday January 13, 2014"	"BIRMINGHAM WB AP AL"	  33.57	 -86.75
# 195.77.16.1	"02:26 am  Friday January 10, 2014"	"MOUNT SHASTA CA"	  41.32	-122.32

#     hash on climate counter
#     hash on IP counter
     
#     my %climates;
     my $IPs;

# open file

    $input_file = "working/_2013/we.log";
    open( INPUT_FH, "<", $input_file ) || die "Can't open $input_file: $!";

#     $line = ' 10.192.202.137	"12:59 pm  Friday January 24, 2014"	"SAN DIEGO WB AP CA"	  32.73	-117.17';

#     read lines
#     split on tab $IP, $time, $climate, $lat, $long


while (<INPUT_FH>) {

     @words = split "\t",$_;
     $IP = @words[0];
#     $climate = @words[2];

#     print "$IP\n";
#     print "$climate\n\n";

     if ($IPs{$IP}) {$IPs{$IP} = $IPs{$IP}+1} 
     else {$IPs{$IP} = 1};

}

# print %climates;

    for my $IP (keys %IPs) {

      $dottedquad = $IP;

# from engr/resolve_dq.pl

       $answer = $IP;
       $answer_r = $IP;
       if ($dottedquad =~ m/(\d{1,3}\.){3}(\d{1,3})/) {
         $arg = 'dig -x ' . $dottedquad;
         @result = `$arg`;
         for ( my $i=0; $i < scalar(@result); $i++) {
           if (@result[$i] =~ 'ANSWER SECTION') {
             $answer = @result[$i+1];           # get NEXT line following 'ANSWER'
             @parts=split(' ',$answer);
             $answer=@parts[4];

             @answer_s = split (/\./,$answer);
             $answer_r = join '.',reverse(@answer_s);
           }
         }
       }
       else {
         $answer = "Improper format: $dottedquad<br>example: 166.2.22.128";
       }
     
       print "$IPs{$IP}\t$IP\t$answer\t$answer_r\n";
    }

