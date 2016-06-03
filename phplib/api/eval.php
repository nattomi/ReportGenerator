<?php

class evaluate {
  
  static function student($testarray, $otulea, $threshold, $limits) {
    $meta = array();
    foreach($testarray as $test) {
      foreach($otulea->get_marks($test) as $mark) {
        $marks[] = $mark;
      }
      $meta['timestamp'] = $test->get_timestamp();
      $meta['subject'] = $test->get_subject();
      $meta['level'] = $test->get_level();
      break;
    }

    $passed = array();
    $failed = array();
    $scores = otulea::average_marks($marks);
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
    
    return array(
		 'meta'=>$meta,
		 'eval'=>array(
			       'A1'=>$passed,
			       'A2'=>$failed)
		 );
  }

  static function teacher($testarray, $otulea, $threshold) {
    /* order tests by subject, alphaid, task, subtask */
    /* and calculate number of tests taken            */
    $alphaids0 = array();
    $stats = array('Lesen'=>0,         // FIXME 1
		   'Schreiben'=>0,
		   'Sprache'=>0,
		   'Rechnen'=>0);
    foreach($testarray as $test) {
      $subject = $test->get_subject();
      $stats[$subject] += 1;
      $marks = $otulea->get_marks($test);
      foreach($marks as $mark) {
          $ts = $mark->get_timestamp();
          $task = $mark->get_task();
          foreach($mark->get_subtasks() as $arr) {
              $alphaids0[$subject][$arr['alphaid']][$task][$arr['subtask']][] = array($ts, $arr['mark']);
          }
      }
    }
    
    $meta = array('timestamp'=>reset($testarray)->get_timestamp(),
		  'stats'=>$stats);

    /* getting latest marks for each subtask */
    $alphaids1 = array();
    foreach($alphaids0 as $subject=>$alphaids) {
      foreach($alphaids as $alphaid=>$tasks) {
	foreach($tasks as $task=>$subtasks) {
	  foreach($subtasks as $subtask=>$marks) {
	    usort($marks, "otulea::cmp_timestamp");
	    $alphaids1[$subject][$alphaid][$task][$subtask] = array(
								    'latest'=>$marks[0][1], 
								    'before'=>$marks[1][1]
								    );
	  }
	}
      }
    }

    /* calculating tendencies, checkmarks and sorting into modes */
    $B1 = array();
    $B2 = array();
    $B3 = array();
    foreach($alphaids1 as $subject=>$alphaids) {
      foreach($alphaids as $alphaid=>$tasks) {
	$cms = array();
	$tendency_positive = false;
	$tendency_negative = false;
	$all_null = true;
	foreach($tasks as $task=>$subtasks) {
	  $score_latest = 0;
	  $n_latest = 0;
	  $score_before = 0;
	  $n_before = 0;
	  foreach($subtasks as $marks) {
	    $score_latest += $marks['latest'];
	    $score_before += $marks['before'];
	    $n_latest += 1;
	    if(!is_null($marks['before']))
	      $n_before += 1;
	  }
	  $cm_latest = $score_latest / $n_latest >= $threshold ? 1 : 0;
	  if($n_before == 0)
	    $cm_before = null;
	  else
	    $cm_before = $score_before / $n_before >= $threshold ? 1 : 0;
	  if(!is_null($cm_before)) {
	    if($cm_latest - $cm_before > 0)
	      $tendency_positive = true;
	    elseif($cm_latest - $cm_before < 0)
	      $tendency_negative = true;
	    $all_null = false;
	  }
	  $all_null = $all_null && is_null($cm_before);
	  $cms[$task] = $cm_latest;
	}
	if($all_null)
	  $tendency = null;
	else {
	  if($tendency_negative == $tendency_positive)
	    $tendency = 0;
	  elseif($tendency_negative)
	    $tendency = -1;
	  else
	    $tendency = 1;
	}
	$a = new alphanode($alphaid, $subject, $tendency, $cms);
	//echo $a->category() . PHP_EOL;
	switch($a->category()) {
	case "B1":
	  $B1[] = $a;
	  break;
	case "B2":
	  $B2[] = $a;
	  break;
	case "B3":
	  $B3[] = $a;
	  break;
	default:
	  break;
	}
      }
    }

    return array(
		 'meta'=>$meta,
		 'eval'=>array(
			       'B1'=>$B1,
			       'B2'=>$B2,
			       'B3'=>$B3
			       )
		 );
  
  }

  static function teacher_ex($markarray) {

    $xml = simplexml_load_file('/home/otuleatest/phplib/dev/demo.xml');
    $ans = array();
    foreach($xml->eval as $e) {
      $an_per_mode = array();
      foreach($e->alphanode as $a) {
	$items = array();
	foreach($a->item as $i) {
	  $items[(string)$i] = (int)$i['cm'];
	}
	$alphanode = new alphanode((string)$a['id'], (string)$a['subject'], (int)$a['tendency'], $items);
	$an_per_mode[] = $alphanode;
      }
      $ans[(string)$e['mode']] = $an_per_mode;
    }
    return $ans;
  }

}


// FIXME 1: shouldn't be hard-coded like this
?>