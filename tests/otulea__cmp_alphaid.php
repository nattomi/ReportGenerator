#!/usr/bin/php
<?php

include '../phplib/api.php';

echo "Testing otulea::cmp_alphaid" . PHP_EOL;

// TEST 1
echo "Test 1: length(\$a) = length(\$b) but \$a <> \$b: ";
if(otulea::cmp_alphaid("1.3.2.1", "1.4.1.2") == -1)
  echo "OK";
else
  echo "Failed";
echo PHP_EOL;

// TEST 2
echo "Test 2: length(\$a) = length(\$b) and \$a == \$b: ";
if(!otulea::cmp_alphaid("1.3.1.2", "1.3.1.2"))
  echo "OK";
else
  echo "Failed";
echo PHP_EOL;

// TEST 3
echo "Test 3: length(\$a) <> length(\$b) and \$a <> \$b: ";
if(otulea::cmp_alphaid("1.4.1.1.5", "1.4.2.2") == -1)
  echo "OK";
else
  echo "Failed";
echo PHP_EOL;

// TEST 4
echo "Test 4: length(\$a) <> length(\$b) but \$a == \$b: ";
if(otulea::cmp_alphaid("1.3.1.2.4", "1.3.1.2") == 1)
  echo "OK";
else
  echo "Failed";
echo PHP_EOL;