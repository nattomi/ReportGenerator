#!/usr/bin/php
<?php

include '../phplib/config.php';
include '../phplib/api.php';

$ot = new otulea(config::DIR_DATA);
if($argc < 2) {
  foreach($ot->ls_users() as $id)
    echo $id . PHP_EOL;
} else {
  $ot->set_user($argv[1]);
  $timestamp = $argc < 3 ? "" : $argv[2];
  $tests = $ot->get_tests($timestamp);
  $tests = otulea::filter_latest($tests);
  otulea::print_testarray($tests);
}