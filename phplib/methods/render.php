<?php

$data = $_POST['data'];

include '../phplib/config/render_paths.php';
include '../phplib/api/render.php';

define("FILE_TMP", $paths['dir_tmp'] . "/" . $data . ".xml");
$doc = simplexml_load_file(FILE_TMP);

switch($doc->type) {
case 'student':
  include '../phplib/config/render_modes_A.php';
  include '../phplib/api/render_student.php';
  $r = new render_student($doc);
  break;
case 'teacher':
  include '../phplib/config/render_modes_B.php';
  include '../phplib/api/render_teacher.php';
  $r = new render_teacher($doc);
  break;
default:
  api::response(500, "unkwown render type or missing input file"); 
  die();
}
		
header('Content-type: application/xml');

$r->toggle_dev_mode();
$r->configure_paths($paths);
$r->render_pdf($modes);
$dom = $r->save_xml();
api::response(200, "OK", $dom);

?>
