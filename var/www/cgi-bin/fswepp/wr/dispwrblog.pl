#! /usr/bin/perl
#! /fsapps/fssys/bin/perl
#
# dispwrlogb.pl
# -rwxr--r-x 1 dhall 502 8378 2005-03-25 11:37 dispwrblog.pl
#
#  Display arbitrary WEPP:Road Batch log
#
#  parameters
#      ip		# 'Add to log' or 'Create new log'
#
#    to do: if no "?ip=xxx_xxx_xxx_xx then determine user's IP   x 2012.03.06
#    translate dots to underscores                               x 2012.03.06
#
#  reads
#    ..\\$working\\{ip}.wrblog

#     my $project;       # project title from log
#     my $climate_name;  # Climate station name
#     my $STx;           # Soil texture
#     my $units;         # project units from log
#     my $years;         # years of run
#     my $lu;            # length units ('m' or 'ft')
#     my $du;            # depth units ('mm' or 'in')
#     my $vu;            # volume units ('kg' or 'lb')
#     my $t;             # generic term from log

#  FSWEPP, USDA Forest Service, Rocky Mountain Research Station, Soil & Water Engineering
#  Science by Bill Elliot et alia                                      Code by David Hall
#  19 October 1999

   &ReadParse(*parameters);

   $ip=$parameters{'ip'};
   if ($ip ne '') {
     $ipd = $ip;
     $ipd =~ tr/./_/;
   }
#   $ipd = '166_2_22_221';                      # get from caller or argument list
   else {                                       # who am I?
     $ip=$ENV{'REMOTE_ADDR'};
     $user_really=$ENV{'HTTP_X_FORWARDED_FOR'};
     $ip=$user_really if ($user_really ne '');
     $ipd = $ip;
     $ipd =~ tr/./_/;
   }

#   $user_ID = $ipd;
#   $logFile = "../working/" . $user_ID . ".wrblog";
    $logFile = "../working/" . $ipd . ".wrblog";

    print "Content-type: text/html\n\n";
    print "<HTML>
 <HEAD>
  <TITLE>WEPP:Road log for $ip</TITLE>
 </HEAD>
 <BODY bgcolor='white'>
  <font face='Arial, Geneva, Helvetica'>
  <CENTER><H3>WEPP:Road log for $ip</H3></CENTER>
  <HR>
  <center>
";

      if (-e $logFile) {                # display it
        open LOG, "<" .$logFile;
        $project=<LOG>; chomp $project;
        $climate_name=<LOG>; chomp $climate_name;
        $STx=<LOG>; chomp $STx;
        $units=<LOG>; chomp $units;
        $years=<LOG>; chomp $years;
        if ($units eq "ft") {$lu = "ft"; $du = "in"; $vu = "lb"}
        else                {$lu = "m";  $du = "mm"; $vu = "kg"}
        $preci=<LOG>; chomp $preci;
        $preci_0 = sprintf '%i',$preci;
        print "
    <center>
     <h4>$project</h4>
     <h4>$climate_name<br>
         $STx soil -- $years year run<br>
         Average annual precipitation $preci_0 $du
     </h4>
    </center>
    <center>
     <table border=1>
      <tr>
       <th bgcolor='lightblue'>
        <font face='Arial, Geneva, Helvetica'>
         Run number
        </font>
       </th>
       <th bgcolor='lightblue'>
        <font face='Arial, Geneva, Helvetica'>
         Design
        </font>
       </th>
       <th bgcolor='lightblue'>
        <font face='Arial, Geneva, Helvetica'>
         Surface, traffic
        </font>
       </th>
       <th bgcolor='lightblue'>
        <font face='Arial, Geneva, Helvetica'>
         Road grad (%)
        </font>
       </th>
       <th bgcolor='lightblue'>
        <font face='Arial, Geneva, Helvetica'>
         Road length ($lu)
        </font>
       </th>
       <th bgcolor='lightblue'>
        <font face='Arial, Geneva, Helvetica'>
         Road width ($lu)
        </font>
       </th>
       <th bgcolor='lightblue'>
        <font face='Arial, Geneva, Helvetica'>
         Fill grad (%)
        </font>
       </th>
       <th bgcolor='lightblue'>
        <font face='Arial, Geneva, Helvetica'>
         Fill length ($lu)
        </font>
       </th>
       <th bgcolor='lightblue'>
        <font face='Arial, Geneva, Helvetica'>
         Buff grad (%)
        </font>
       </th>
       <th bgcolor='lightblue'>
        <font face='Arial, Geneva, Helvetica'>
         Buff length ($lu)
        </font>
       </th>
       <th bgcolor='lightblue'>
        <font face='Arial, Geneva, Helvetica'>
         Rock cont (%)
        </font>
       </th>
       <th bgcolor='lightgreen'>
        <font face='Arial, Geneva, Helvetica'>
         Average annual rain runoff ($du)
        </font>
       </th>
       <th bgcolor='lightgreen'>
        <font face='Arial, Geneva, Helvetica'>
         Average annual snow runoff ($du)
        </font>
       </th>
       <th bgcolor='lightgreen'>
        <font face='Arial, Geneva, Helvetica'>
         Average annual sediment leaving road ($vu)
        </font>
       </th>
       <th bgcolor='lightgreen'>
        <font face='Arial, Geneva, Helvetica'>
         Average annual sediment leaving buffer ($vu)
        </font>
       </th>
       <th bgcolor='lightblue'>
        <font face='Arial, Geneva, Helvetica'>
         Comment
        </font>
       </th>
      </tr>
";
      while (! eof LOG) {
        print "    <tr>
";
        if ($subs) {my $preci=<LOG>}; $subs=1;
        my $run  =<LOG>;
        my $roadd=<LOG>;
        my $surfa=<LOG>;
        my $roadg=<LOG>;
        my $roadl=<LOG>;
        my $roadw=<LOG>;
        my $fillg=<LOG>;
        my $filll=<LOG>;
        my $buffg=<LOG>;
        my $buffl=<LOG>;
        my $rockf=<LOG>;
        my $rainr=<LOG>; $rainr = sprintf '%.1f', $rainr;
        my $snowr=<LOG>; $snowr = sprintf '%.1f', $snowr;
        my $sedir=<LOG>; $sedir = sprintf '%.0f', $sedir;
        my $sedip=<LOG>; $sedip = sprintf '%.0f', $sedip;
        my $comme=<LOG>;

        $sedir = commify ($sedir);
        $sedip = commify ($sedip);
         $td_tag='<td bgcolor="lightblue">';
#        $td_tag='<td bgcolor="coral">' if ($surfa =~ /low/ || $surfa =~ /none/);
         $td_tag='<td bgcolor="coral">' if (lc($surfa) =~ /none/);
         $td_tag='<td bgcolor="red">' if ($run =~ / !/);
         print "     $td_tag
        <font face='Arial, Geneva, Helvetica'>
         $run
        </font>
       </td>
       <td align='center'>
        <font face='Arial, Geneva, Helvetica'>
         $roadd
        </font>
       </td>
       <td align='center'>
        <font face='Arial, Geneva, Helvetica'>
         $surfa
        </font>
       </td>
       <td align='right'>
        <font face='Arial, Geneva, Helvetica'>
         $roadg
        </font>
       </td>
       <td align='right'>
        <font face='Arial, Geneva, Helvetica'>
         $roadl
        </font>
       </td>
       <td align='right'>
        <font face='Arial, Geneva, Helvetica'>
         $roadw
        </font>
       </td>
       <td align='right'>
        <font face='Arial, Geneva, Helvetica'>
         $fillg
        </font>
       </td>
       <td align='right'>
        <font face='Arial, Geneva, Helvetica'>
         $filll
        </font>
       </td>
       <td align='right'>
        <font face='Arial, Geneva, Helvetica'>
         $buffg
        </font>
       </td>
       <td align='right'>
        <font face='Arial, Geneva, Helvetica'>
         $buffl
        </font>
       </td>
       <td align='right'>
        <font face='Arial, Geneva, Helvetica'>
         $rockf
        </font>
       </td>
       <td align='right'>
        <font face='Arial, Geneva, Helvetica'>
         $rainr
        </font>
       </td>
       <td align='right'>
        <font face='Arial, Geneva, Helvetica'>
         $snowr
        </font>
       </td>
       <td align='right'>
        <font face='Arial, Geneva, Helvetica'>
         $sedir
        </font>
       </td>
       <td align='right'>
        <font face='Arial, Geneva, Helvetica'>
         $sedip
        </font>
       </td>
       <td>
        <font face='Arial, Geneva, Helvetica'>
         $comme
        </font>
       </td>
";
      }
      close LOG;
      print "
     </tr>
     <tr>
      <td colspan=16>
       <font color='coral'>Provisional results for 'no' traffic</font>
      </td>
    </tr>
    </table>
    <br>
   </center>
";
    }
    else {
      print "No log file found\n";
    }

    print " </body>\n</html>\n";

# ------------------------ subroutines ---------------------------

sub ReadParse {

# ReadParse -- from cgi-lib.pl (Steve Brenner) from Eric Herrmann's
# "Teach Yourself CGI Programming With PERL in a Week" p. 131

  local (*in) = @_ if @_;
  local ($i, $loc, $key, $val);

  if ($ENV{'REQUEST_METHOD'} eq "GET") {
    $in = $ENV{'QUERY_STRING'};
  } elsif ($ENV{'REQUEST_METHOD'} eq "POST") {
    read(STDIN,$in,$ENV{'CONTENT_LENGTH'});
  }

  @in = split(/&/,$in);

  foreach $i (0 .. $#in) {
    # Convert pluses to spaces
    $in[$i] =~ s/\+/ /g;

    # Split into key and value
    ($key, $val) = split(/=/,$in[$i],2);  # splits on the first =

    # Convert %XX from hex numbers to alphanumeric
    $key =~ s/%(..)/pack("c",hex($1))/ge;
    $val =~ s/%(..)/pack("c",hex($1))/ge;

    # Associative key and value
    $in{$key} .= "\0" if (defined($in{$key}));  # \0 is the multiple separator
    $in{$key} .= $val;
  }
  return 1;
 }

sub commify {
    my $text = reverse $_[0];
    $text =~ s/(\d\d\d)(?=\d)(?!d*\.)/$1,/g;
    return scalar reverse $text;
}

