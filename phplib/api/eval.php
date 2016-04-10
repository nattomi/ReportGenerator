<?php

class evaluate {
  
  static function student(&$markarray, $limits, $threshold) {
    $passed = array();
    $failed = array();
    $scores = otulea::average_marks($markarray);
    foreach($scores as $k => $v) {
      if($v >= $threshold) {
	$passed[] = $k;
      } else {
	$failed[] = $k;
      }
    }

    usort($passed, "otulea::cmp_alphaid");
    $passed = array_slice($passed, 0, $limits[0]);
    usort($failed, "otulea::cmp_alphaid");
    $failed = array_slice($failed, 0, $limits[1]);
    
    return array('A1'=>$passed,
		 'A2'=>$failed);
  }

}

?>