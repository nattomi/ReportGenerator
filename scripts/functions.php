<?php
function rrmdir($dir) { // this is for recursively deleting a folder            
  if (is_dir($dir)) {                                                           
    $objects = scandir($dir);                                                   
    foreach ($objects as $object) {                                             
      if ($object != "." && $object != "..") {                                  
        if (filetype($dir."/".$object) == "dir") rmdir($dir."/".$object); else \
unlink($dir."/".$object);                                                       
      }                                                                         
    }                                                                           
    reset($objects);                                                            
    rmdir($dir);                                                                
  }                                                                             
}

function ts2dt($timestamp) { // shorthand for timestamp 2 DateTime
  $pieces = explode("_",$timestamp);
  $date = new DateTime();
  $date->setDate($pieces[0],$pieces[1],$pieces[2]);
  $date->setTime($pieces[3],$pieces[4],$pieces[5]);
  return $date;
}

function getTimestamps($performedtests) {
  function callback(&$item,$key) {
    $item = $item->timestamp;
  }
  array_walk($performedtests,'callback');
  return $performedtests;
}

function matchTimestamp($performedtests,$timestamp=null) {
  $datetime_diff = array();

  function callback_abs($val) {
    return abs($val);
  }
  
  function callback_id($val) {
    return $val;
  }
  
  if (!is_null($timestamp)) {
    $refdate = ts2dt($timestamp)->getTimeStamp();
    $callback = 'callback_abs';
  } else {
    $refdate = 0;
    $callback = 'callback_id';
  }
  foreach ($performedtests as $test) {
    $unixtime_test = ts2dt($test->timestamp)->getTimeStamp();
    $datetime_diff[] = $callback($refdate - $unixtime_test);
  }
  $index = array_keys($datetime_diff,min($datetime_diff))[0];
  return $index;
}

function RecentSession($performedtests,$test) {
  $timestamps = getTimestamps($performedtests);
  $tests = array($test);
  $prev = $test->prev;
  $cond = strlen($prev) > 0;
  while ($cond) {
    $index = array_keys($timestamps,$prev)[0];
    $test = $performedtests[$index];
    $tests[] = $test;
    $prev = $test->prev;
    $cond = strlen($prev) > 0;
  }
  return $tests;
}

/* I probably do not need this
function getMarks($file_task) {
  if (file_exists($file_task)) { // parsing the user's global xml file (if exists)
    $xmldoc = simplexml_load_file($file_task);
    $marks = array();
    foreach ($xmldoc->marking->mark as $mark) {
      $marks[] = new mark((string)$mark['itemnumber'],
			  (string)$mark['alphalevel'],
			  (int)$mark);
    }
  } else {
    exit("Failed to open file" . $file_task . "\n");
  }
  return $marks;
}
*/

function ifelse($condition,$value_true,$value_false) { // resembles R's ifelse function. FIXME: It would be better to drop this and use statements like ($a < $b) ? -1 : 1 instead 
  if ($condition) {
    return $value_true; 
  } else {
    return $value_false;
  }
}

function array_mean($array) { // tells you the mean of an array
  return array_sum($array) / count($array);
}

function tapply_mean($val,$fac) { // resembles a special case of R's tapply function
  $levels = array();
  foreach (range(0,count($fac)-1) as $i) {
    $val_i = $val[$i];
    $fac_i = $fac[$i];
    if (in_array($fac_i,array_keys($levels))) {
      $levels_fac_i = $levels[$fac_i];
      $levels_fac_i[] = $val_i;
      $levels[$fac_i] = $levels_fac_i;
    } else {
      $levels[$fac_i] = array($val_i);
    }
  }
  $means = array();
  foreach (array_keys($levels) as $key) {
    $means[$key] = array_mean($levels[$key]);
  }
  return $means;
}
// I'm not sure yet but maybe there will be a need for comparing alphaIDs
//function cmp_alphaID($a,$b) {
//$a="1.4.1.1"
//$b="1.4.1.2"
//}
?>