#!/usr/bin/php
<?php

include '../phplib/config.php';
include '../phplib/api.php';

echo "Testing otulea::merge_items" . PHP_EOL;

$ot = new otulea(config::DIR_DATA);
$ot->set_user("SD5AM");
$timestamp = "2014_10_7_13_56_23";
$tests = $ot->get_tests($timestamp);
$test = $tests[$timestamp];
$test_prev = $tests[$test->get_prev()];

// TEST 1
echo "Test 1: 'data' is empty for both items: ";
$item = "2.3.03_II";
$item1 = $test->get_items()[$item];
$item2 = $test_prev->get_items()[$item];
$merged = otulea::merge_items($item1, $item2);
$cond1 = strcmp($merged['timestamp'], $timestamp) === 0;
$cond2 = strlen($merged['data']) === 0;
if($cond1 && $cond2)
  echo "OK";
else
  echo "Failed";
echo PHP_EOL;

// TEST 2
echo "Test 2: 'data' is empty only for the first item: ";
$item = '2.3.01_I';
$item1 = $test->get_items()[$item];
$item2 = $test_prev->get_items()[$item];
$merged = otulea::merge_items($item1, $item2);
$cond1 = strcmp($merged['timestamp'], $test->get_prev()) === 0;
$cond2 = strcmp($merged['data'], $item2['data']) === 0;
if($cond1 && $cond2)
  echo "OK";
else
  echo "Failed";
echo PHP_EOL;

// TEST 3
echo "Test 3: 'data' is empty only for the second item: ";
$item = '2.3.03_I';
$item1 = $test->get_items()[$item];
$item2 = $test_prev->get_items()[$item];
$merged = otulea::merge_items($item1, $item2);
$cond1 = strcmp($merged['timestamp'], $timestamp) === 0;
$cond2 = strcmp($merged['data'], $item1['data']) === 0;
if($cond1 && $cond2)
  echo "OK";
else
  echo "Failed";
echo PHP_EOL;