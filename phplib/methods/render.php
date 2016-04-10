<?php

$string = $_POST['data'];
$type = $_POST['type'];

include '../phplib/config/render_paths.php';
include '../phplib/api/render.php';

switch($type) {
case 'student':
  include '../phplib/config/render_modes_A.php';
  include '../phplib/api/render_student.php';
  $r = new render_student($string);
  break;
case 'teacher':
  include '../phplib/config/render_modes_B.php';
  include '../phplib/api/render_teacher.php';
  $r = new render_teacher($string);
  break;
default:
  die("Unkwown render type" . PHP_EOL);
  break;
}
		
header('Content-type: application/xml');

$r->toggle_dev_mode();
$r->configure_paths($paths);
$r->render_pdf($modes);
$dom = $r->save_xml();
api::response(200, "OK", $dom);

?>
