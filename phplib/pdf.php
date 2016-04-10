<?php

$user = $_POST['user'];
$testid = $_POST['testid'];
$type = $_POST['type'];

include '../phplib/config/pdf.php';

$r = new request(config::API_URI);
$pdf = new pdffactory($user, $testid, $type);
$pdf->get_results($r);
if(is_null($pdf->get_data())) {
  echo "Couldn't get results" . PHP_EOL;
  die();
}
//echo $pdf->get_data()->saveXML();
$response = $pdf->render_results($r);
if(!$response) {
  echo "Error while rendering pdf" . PHP_EOL;
  die();
}
if(!strcmp($type, 'teacher')) 
  $response = strip_tags($response);
echo $response;

?>