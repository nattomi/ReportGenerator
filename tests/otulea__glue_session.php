#!/usr/bin/php
<?php

include '../phplib/config.php';
include '../phplib/api.php';

echo "Testing otulea::glue_session" . PHP_EOL;

$ot = new otulea(config::DIR_DATA);
$ot->set_user("SD5AM");
$tests = $ot->get_tests();
//otulea::print_testarray($tests);

// TEST 1
echo "Test 1: length of session is 2: ";
$timestamp = "2014_10_7_13_56_23";
otulea::glue_session($tests, $timestamp);
$cond1 = strlen($tests[$timestamp]->get_prev()) == 0;
$cond2 = !array_key_exists("2014_9_5_10_55_25", $tests);
$cond3 = is_null($tests["2014_9_5_11_4_55"]->get_key_prev());
if($cond1 && $cond2 && $cond3)
  echo "OK";
else
  echo "Failed";
echo PHP_EOL;

//otulea::print_testarray($tests);

echo "Test 2: length of session is 3: ";
$timestamp = "2014_10_7_11_57_1";
otulea::glue_session($tests, $timestamp);
$cond1 = strlen($tests[$timestamp]->get_prev());
$cond2 = !array_key_exists("2014_10_7_11_53_58", $tests);
$cond3 = !array_key_exists("2014_10_7_11_47_5", $tests);
$cond4 = strcmp($tests[$timestamp]->get_key_next(),
		"2014_10_7_11_57_11") === 0;
$cond5 = strcmp($tests[$timestamp]->get_key_prev(),
		"2014_10_7_11_42_53") === 0;
if(!$cond1 && $cond2 &&
   $cond3  && $cond4 && $cond5)
  echo "OK";
else
  echo "Failed";
echo PHP_EOL;

//otulea::print_testarray($tests);

echo "Test 3: multiple reference to same prev entry" . PHP_EOL;
echo "        part 1: ";  
$timestamp = "2014_10_7_11_42_53";
otulea::glue_session($tests, $timestamp);
//otulea::print_testarray($tests);
$cond1 = strlen($tests[$timestamp]->get_prev());
$cond2 = !array_key_exists("2014_10_7_11_39_22", $tests);
$cond3 = strcmp($tests["2014_10_7_11_41_40"]->get_key_prev(),
		"2014_10_7_11_29_11");
$cond4 = strcmp($tests["2014_10_7_11_29_11"]->get_key_next(),
		"2014_10_7_11_41_40");
if(!$cond1 && $cond2  &&
   !$cond3 && !$cond4)
  echo "OK";
else
  echo "Failed";
echo PHP_EOL;
echo "        part 2: ";
if(otulea::glue_session($tests, "2014_10_7_11_42_25"))
  echo "OK";
else
  echo "Failed";
echo PHP_EOL;
  

