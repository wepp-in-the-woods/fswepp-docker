<html>
 <head>
 </head>
 <body>

<script>
//peakflowlogger.php
//
//determine IP address
//read arguments
//if none, display log
//if all, append to log
//
//allow clearing log
</script>


<?php
echo $_SERVER['REMOTE_ADDR'];
?>
<br><br>

<?php		// http://forums.digitalpoint.com/showthread.php?t=1028597

if ($_SERVER['HTTP_X_FORWARD_FOR']) {
$ip = $_SERVER['HTTP_X_FORWARD_FOR'];
} else {
$ip = $_SERVER['REMOTE_ADDR'];
}

$hostname = gethostbyaddr($_SERVER['REMOTE_ADDR']);

echo "Hello Visitor, here is your Info:<br><br>";

echo "Your IP is: " . $ip . "<br>";

echo "Your Hostname is: " . $hostname;

?>

 </body>
</html>

