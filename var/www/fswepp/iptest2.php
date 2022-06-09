<?php ?>
<html>
<HEAD>

<SCRIPT LANGUAGE="JavaScript">

<!-- This script and many more are available free online at -->
<!-- The JavaScript Source!! http://javascript.internet.com -->

<!-- Begin
// http://www.kdcgrohl.com

// Depending on your server set-up,
// you may need to use the ".shtml"
// extension [instead of the "html"
// or "htm"] as the script uses Server
// Side Includes. To display in the
// title bar, exclude the
//"<title></title>" code from the page.

// This part gets the IP
var ip = '<!--#echo var="REMOTE_ADDR"-->';

// This part is for an alert box
alert("Your IP address is "+ip);

// This part is for the status bar
window.defaultStatus = "Your IP address is "+ip;

// This part is for the title bar
document.write("<title>Your IP address is "+ip+"</title>");
//  End -->
</script>

</head>
<body>
<script>
document.write("Your IP address is "+ip);
</script>


<SCRIPT LANGUAGE="JavaScript">
<!-- Begin

<!-- This script and many more are available free online at -->
<!-- The JavaScript Source!! http://javascript.internet.com -->

ip = "" + java.net.InetAddress.getLocalHost().getHostAddress();
document.write("Your IP address is " + ip);
//  End -->
</script>
<script language="JavaScript">
VIH_BackColor = "palegreen";
VIH_ForeColor = "navy";
VIH_FontPix = "16";
VIH_DisplayFormat = "You are visiting from:<br>IP Address: %%IP%%<br>Host: %%HOST%%";
VIH_DisplayOnPage = "yes";
</script>
<script language="JavaScript" src="http://scripts.hashemian.com/js/visitorIPHOST.js.php"></script>

<script type="text/javascript">
var ip = <?echo $_SERVER['REMOTE_ADDR'] ?>;
// var anyjavascriptvar = < ? php echo $_SERVER['REMOTE_ADDR'] ? >;
document.write("Your IP address is " + ip);
</script>
   <input type="text" name="IP" value='<?= @$_SERVER["REMOTE_ADDR"]?>'>

</body>
</html>
