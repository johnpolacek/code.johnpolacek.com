<?php
	include("Mobile_Detect.php");
	$detect = new Mobile_Detect();
	if ($detect->isMobile()) 
	{
		header('Location: mobile/index.html') ;
	}
?>

<?php
	$browser = strpos($_SERVER['HTTP_USER_AGENT'],"iPhone");
	if ($browser == true)  { header('Location: mobile/index.html') ; }
?>
        
<?php
		$browser = strpos($_SERVER['HTTP_USER_AGENT'],"iPod");
		if ($browser == true)  { header('Location: mobile/index.html') ; }
?>

<?php
	$browser = strpos($_SERVER['HTTP_USER_AGENT'],"iPad");
		if ($browser == true)  { header('Location: mobile/index.html') ; }
?>

<?php
	include("briefingroom.html");
?>

