#!/usr/bin/php
<?php

include '../phplib/api.php';

$ot = new otulea("../data");
if($argc < 2)
  die("usage: ./getLatestMarks.php [userid] [testid]" . PHP_EOL);
  
$ot->set_user($argv[1]);
$timestamp = $argc < 3 ? "" : $argv[2];
$tests = $ot->get_tests($timestamp);
otulea::glue_session($tests, $timestamp);
$test = reset($tests);
$marks = $ot->get_marks($test);
otulea::print_markarray($marks);
