<?php

$request = "http://api2.socialmention.com/search?q=%22";
$search = $_GET["search"];
$request .= $search;
$request .= "%22&t=blogs&f=rss";
$request = str_replace(" ","+",$request); 
 
$curl = curl_init();

# CURL SETTINGS.
curl_setopt($curl, CURLOPT_URL, $request);

# GRAB THE XML FILE.
$xml = curl_exec($curl);

curl_close($curl);


$xmlObj = simplexml_load_string( $xml );

echo $xmlObj;
?>