# read model run log
#
#  split out IP, store unique IPs and count (hash)
#
#  decode IP dotted quad to domain
#
#  reverse domain
#
#  print:
#
#  reverse domain	domain	IP	count
#
#  [200 most recent of 2265 Disturbed WEPP 2.0 runs]
#
# 159.149.116.48	"08:43 am  Monday November 7, 2011"	10	"DENVER WB AP CO"	  39.77	-104.88
# 129.101.58.144	"10:25 am  Sunday November 6, 2011"	100	"SANDPOINT EXP STA ID"	  48.28	-116.57
# 129.101.58.144	"10:25 am  Sunday November 6, 2011"	100	"SANDPOINT EXP STA ID"	  48.28	-116.57
# 129.101.58.144	"10:25 am  Sunday November 6, 2011"	100	"SANDPOINT EXP STA ID"	  48.28	-116.57
# 129.101.58.144	"10:23 am  Sunday November 6, 2011"	100	"SANDPOINT EXP STA ID"	  48.28	-116.57
# 129.101.58.144	"10:21 am  Sunday November 6, 2011"	50	"MOSCOW U OF I ID"	  46.73	-117.00
# 46.21.144.176		"09:53 am  Sunday November 6, 2011"		""		
# 129.101.58.144	"09:28 am  Sunday November 6, 2011"	10	"MOSCOW U OF I ID"	  46.73	-117.00
#

#
#  split out IP, store unique IPs and count (hash)
#

#    %IPcountHash={};
#    %IPhash={};

    my %IPs;

    open FILE, "<runlog.txt";

   while (<FILE>) {
     ($ip, $rest) = split (" ", $_, 2);
     $IPs{$ip}++;
   }
    $unique = keys %IPs;		# how many different tags there are in the list
    @unique = keys %IPs;		# delete the duplicates and end up with a list of the unique tags
    @counts = values %IPs;
#   @popular = (sort { $IPs{$b} <=> $IPs{$b} } @unique)[0..4];	# show the five most popular tags from the list

#	https://www.perl.com/pub/2006/11/02/all-about-hashes.html   Hash Crash Course
#    my %histogram;
#    $histogram{$_}++ for @list;

#    $unique = keys %histogram;		# how many different tags there are in the list
#    @unique = keys %histogram;		# delete the duplicates and end up with a list of the unique tags

    print "$unique different IPs\n";
#    print "@unique unique IPs\n";
#    print "@counts unique count\n";

#   print "@popular\n"; 

#     if ($IPhash{$ip}) {
#       $IPhash{$ip}=$IPhash+1;
#     }
#     else {
#       $IPhash=1;
#     }
#     print "$ip\n";
#   }

    for my $key ( keys %IPs ) {
        my $value = $IPs{$key};
#       print "\n$key => $value\t";
        print "\n$value\t$key\t";
#   }

#  while (($key, $value) = each(%IPs)){
#     print $value.", ".$key.', "'.$IPs{$key}.'"'."\n";

#
#  decode IP dotted quad to domain
#

#	forest:  /srv/www/cgi-bin/engr/resolve_dq.pl

#
#

   $answer='unknown';

   $dottedquad = $key;
#     $dottedquad = '134.121.1.72';
#     $dottedquad = '166.2.22.128';

#     if ($dottedquad eq '') {
#       $dottedquad = '166.2.22.128';
#       $answer = 'whitepine.moscow.rmrs.fs.fed.us';
#     }
#     else {
#
#    regexp check
#
       if ($dottedquad =~ m/(\d{1,3}\.){3}(\d{1,3})/) {
         $arg = 'dig -x ' . $dottedquad;
         @result = `$arg`;
         for ( my $i=0; $i < scalar(@result); $i++) {
           if (@result[$i] =~ 'ANSWER SECTION') {
             $answer = @result[$i+1];           # get NEXT line following 'ANSWE                                             R'
             @parts=split(' ',$answer);
             $answer=@parts[4];
           }
         }
       }
       else {
         $answer = "Improper format: $dottedquad<br>example: 166.2.22.128";
       }
#     }
     print $answer;
# }

#
#  reverse domain
#

#	\deh\_mine\revdots.pl

# @users=qw(
# zc7831518.ip.fs.fed.us
# zc783153d.ip.fs.fed.us
# zc783155d.ip.fs.fed.us
# };

#foreach (@users) {
  @parts=split (/\./,$answer);
##  print "first part: ".@parts[0]."\n";
  $strap = join '.', reverse @parts;
  print "\t$strap";
#}
}

############

#	c:\4702\deh\reverse_ip.pl
#     $host='166.2.22.245';
#     $host='blm-92-254.blm.gov';

#  chomp $host;

#     if ($host =~ m/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/) {
#           print "$host\n";
#     }
#     else {
#           @address = split(/\./, $host);   # Split into component names
##          print "r $host\t",join('.', reverse(@address)),"\n";
#           print join('.', reverse(@address)),"\n";
#     }
#}

#
#  print:
#
#     reverse_domain	domain	IP	count
#

