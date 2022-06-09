<?php
//adv_mailer.php
include "./secure/common_mail.inc";

switch ($action)
{
   case "send_mail":
      mailer_header();
      send_mail();
      mailer_footer();
      break;
   case "mail_form":
      mailer_header();
      mail_form();
      mailer_footer();
      break;
   default:
      mailer_header();
      mail_form();
      mailer_footer();
      break;
}
?>

