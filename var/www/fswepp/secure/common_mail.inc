<?php
//common_mail.inc
function mailer_header()
{
?>
<HTML>
<HEAD><TITLE>Mailer</TITLE></HEAD>
<BODY bgcolor="#8899aa">
<?php
}

function mailer_footer()
{
?>
</BODY>
</HTML>
<?php
}

function error_message($msg)
{
   mailer_header();
   echo "<SCRIPT>alert(\"Error: $msg\");history.go(-1)</SCRIPT>";
   mailer_footer();
   exit;
}

function user_message($msg)
{
   mailer_header();
   echo "<SCRIPT>alert(\"$msg\");history.go(-2)</SCRIPT>";
   mailer_footer();
   exit;
}

function mail_form() 
  { 
  global $PHP_SELF;
?> 
<FORM METHOD="POST" ENCTYPE="MULTIPART/FORM-DATA" ACTION="<?php echo
$PHP_SELF ?>"> 
<INPUT TYPE="HIDDEN" NAME="action" VALUE="send_mail"> 
<DIV ALIGN="CENTER ">
<TABLE CELLSPACING="2" CELLPADDING="5" WIDTH="90%" BORDER="1"> 
   <TR>
      <TH ALIGN="CENTER" WIDTH="30%">Your Name:</TH>
      <TD WIDTH="70%"><INPUT SIZE="20" NAME="name"></TD>
   </TR>
   <TR> 
      <TH ALIGN="CENTER" WIDTH="30%">Your Email:</TH> 
      <TD WIDTH="70%"><INPUT SIZE="20" NAME="mail_reply_to"></TD> 
   </TR> 
   <TR>
      <TH ALIGN="CENTER" WIDTH="30%">What would you like to tell me?</TH>
      <TD WIDTH="70%"><TEXTAREA NAME="mail_body" ROWS="16"
         COLS="70"></TEXTAREA></TD>
   </TR>
   <TR>
      <TH WIDTH="100%" COLSPAN="2" ALIGN="CENTER">
         <INPUT TYPE="SUBMIT" VALUE="Send" NAME="SUBMIT">
         <INPUT TYPE="RESET" VALUE="Reset" NAME="RESET">
      </TH>
   </TR>
</TABLE>
</DIV> 
</FORM> 

<?php 
  } 

function send_mail() 
  {
  global $name, $mail_reply_to, $mail_body;

  $mail_parts["name"] = $name;
  $mail_parts["mail_reply_to"] = $mail_reply_to;
  $mail_parts["mail_body"] = $mail_body;

  if(my_mail($mail_parts))
    {
    user_message("Your e-mail has successfully sent.");
    }
  else 
    {
    error_message("An unknown error occurred while attempting to send an
e-mail.");
    }
  }

function my_mail($mail_parts) 
  {
  global $PHP_SELF, $REMOTE_ADDR, $HTTP_HOST, $SCRIPT_URI, $SCRIPT_URL,
$SCRIPT_FILENAME;

  $userIP = gethostbyaddr($REMOTE_ADDR);
  $mail_to = "justin@rickertweb.com";

  $mail_subject = "Mail from someone on host ";
  $mail_subject .= $userIP;
  $name = $mail_parts["name"];
  $mail_reply_to = $mail_parts["mail_reply_to"];
  $mail_from = $mail_reply_to;
  $mail_body = "Name:		$name\n";
  $mail_body .= "From:		$mail_reply_to\n\n";
  $mail_body .= $mail_parts["mail_body"];
  $mail_body .= "\n\n\n The script uri: $SCRIPT_URI";
  $mail_body .= "\n The script url: $SCRIPT_URL";
  $mail_body .= "\n The script filename: $SCRIPT_FILENAME";
  $mail_body .= "\n On the server called: $HTTP_HOST";

  if(empty($mail_body)) 
    {
    error_message("Empty body! ");
    }

  $mail_to = str_replace(";", ",", $mail_to);
  $mail_headers = '';

  if(!empty($name))
    {
    $mail_headers .= "From: 		$mail_from\n";
    }   
  if(!empty($mail_reply_to)) 
    {
    $mail_headers .= "Reply-to: 	$mail_reply_to\n";
    }
  $mail_body = stripslashes($mail_body);
  return mail($mail_to,$mail_subject,$mail_body,$mail_headers);
  }
?>

