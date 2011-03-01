<?php
//URL encode the query string
$q = urlencode("twitter");
 
//request URL
$request = $_GET["url"];

$request = str_replace(" ","+",$request); 


 
$curl= curl_init();
 
curl_setopt ($curl, CURLOPT_RETURNTRANSFER, 1);
 
curl_setopt ($curl, CURLOPT_URL,$request);
 
$response = curl_exec ($curl);
 
curl_close($curl);
 
//remove "twitter:" from the $response string
$response = str_replace("twitter:", "", $response);

echo $response;

?>