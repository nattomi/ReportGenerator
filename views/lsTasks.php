#!/usr/bin/php
<?php

include '../phplib/api.php';

$ot = new otulea("../data");

if($argc < 3)
  die("usage: ./lsTaks [id] [test]");
$ot->set_user($argv[1]);
$tests = $ot->get_tests($argv[2]);
$tests[$argv[2]]->print_test();