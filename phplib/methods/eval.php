<?php

$user = $_POST['user'];
$type = $_POST['type'];
$testid = $_POST['testid'];
$save = $_POST['save'];

include '../phplib/api/main.php';
include '../phplib/api/eval.php';
include '../phplib/config/eval.php';

header('Content-type: application/xml');

if(is_null($user)) {
  api::response(400, "user id not specified");
  die();
}

if(is_null($type)) {
  api::response(400, "report type not specified"); 
  die();
}

$ot = new otulea(DIR_DATA);

$ot->set_user($user);
if(!$ot->is_valid_user()) {
  api::response(404, "requested user doesn't exist");
  die();
}

$type_match = array_search($type, array('1'=>'student', 
					'2'=>'teacher'));
switch($type_match) {
case 1:
  $type_is_student = true;
  break;
case 2:
  $type_is_student = false;
  break;
default:
  api::response(400, "invalid report type");
  die();
}

if(is_null($testid))
  $testid_filter = false;
else {
  $testid_filter = true;
  $testid_orig = $testid;
}

$tests = $ot->get_tests($testid);
if(!$tests) {
  api::response(500, "testindex file doesn't exist");
  die();
}

if($testid_filter && strcmp($testid_orig, $testid)) { 
  api::response(404, "requested test doesn't exist");
  die();
}

do {
  $it = otulea::glue_session($tests, $testid);
  //echo $it . " " . $testid . PHP_EOL;
  if(!$it) {
    api::response(500, "test history not found");
    die();
  }
  if($type_is_student) {
    $t = reset($tests);
    $tests = array($t);
    break;
  }
} while(!is_null($testid));

if($type_is_student) {
  $e = evaluate::student($tests, $ot, THRES_STUDENT, array(3, 2));
  $ot->set_alphalist();
  $data = $ot->results_student($e);
} else {
  $e = evaluate::teacher($tests, $ot, THRES_TEACHER);
  $ot->set_alphalist();
  $data = $ot->results_teacher($e);
}
if((int)$save != 1)
  api::response(200, "OK", $data);
else {
  $systime = time();
  $timestamp = date('YmdHis', $systime);
  $basename = $user . "_" .
    date('Ymd_H_i_s', $systime) .
    "_result_" . $type;
  $xmlname = $basename . ".xml";

  $data->save(DIR_TMP . "/" . $xmlname);
  $dom = new DomDocument('1.0', 'UTF-8');
  $dom->appendChild($dom->createElement('data', $basename));

  api::response(200, "OK", $dom);
}

?>