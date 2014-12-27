<?php

class user {
  public $id; // this argument is required (later on I might change it back to protected)
  protected $test; // this argument can be omitted
  
  public function __construct($id,$test=null) {
    $this->id = $id;
    $this->test = $test;
  }

  public function getUserDir() {
    global $Udir;
    return $Udir . $this->id . '/';
  }

  public function getGlobalXML() {
    return $this->getUserDir() . $this->id . ".xml";
  }

  public function getMarks() {
    $guf = $this->getGlobalXML();
    $udir = $this->getUserDir();

    $timestamp = array();
    $subject = array();
    $level = array();
    $task = array();
    $subtask = array();
    $alphaid = array();
    $mark = array();

    if (file_exists($guf)) { // parsing the user's global xml file (if exists)
      $xmldoc = simplexml_load_file($guf);
      $timestamp0 = array();
      $datetime_diff = array();
      $prev = array();
      foreach ($xmldoc->test as $test_test) { //
	$timestamp_test = (string)$test_test['timestamp'];
	$timestamp0[] = $timestamp_test;
	$pieces = explode("_",$timestamp_test);
	$date = new DateTime();
	$date->setDate($pieces[0],$pieces[1],$pieces[2]);
	$date->setTime($pieces[3],$pieces[4],$pieces[5]);
	$unixtime_test = $date->getTimeStamp();
	if (!is_null(($this->test))) {
	  $pieces = explode("_",$this->test);
	  $refdate = new DateTime();
	  $refdate->setDate($pieces[0],$pieces[1],$pieces[2]);
	  $refdate->setTime($pieces[3],$pieces[4],$pieces[5]);
	  $unixtime_test = $date->getTimeStamp();
	  $datetime_diff[] = abs($unixtime_test - $refdate->getTimeStamp());
	} else {
	  $datetime_diff[] = -$unixtime_test;
	}
	$prev[] = (string)$test_test['prev'];
      }
      $index = array_keys($datetime_diff,min($datetime_diff))[0];
      do {
	//echo $index . "\n";
	$current_test = $xmldoc->test[$index];
	$current_test_timestamp = $timestamp0[$index];
	$current_test_subject = (string)$current_test['subject'];
	$current_test_level = (string)$current_test['level'];
	foreach ($current_test->item as $item) {
	  $iname = (string)$item['iname'];
	  $data = (string)$item['data'];
	  if (strlen($data) > 0) {
	    $dataf = $udir . $data;
	    if (file_exists($dataf)) {
	      $xmldoc_item = simplexml_load_file($dataf);
	      foreach ($xmldoc_item->marking->mark as $mark0) {
		$timestamp[] = $current_test_timestamp;
		$subject[] = $current_test_subject;
		$level[] = $current_test_level;
		$task[] = $iname;
		$subtask[] = (string)$mark0['itemnumber'];
		$alphaid[] = (string)$mark0['alphalevel'];
		$mark[] = (int)$mark0;
	      }
	    } else {
	      exit("Failed to open file" . $dataf . "\n");
	    }
	  }
	}
	$prevtimestamp = $prev[$index];
	$stopcond = strlen($prevtimestamp) > 0;
	if ($stopcond) $index = array_keys($timestamp0,$prevtimestamp)[0];
      } while ($stopcond);  
    } else {
      exit("Failed to open the user's global xml file.\n");
    }
    return new marksMatrix($timestamp,$subject,$level,
			   $task,$subtask,$alphaid,$mark);
  }

}

class marksMatrix {
  public function __construct($timestamp,$subject,$level,
			      $task,$subtask,$alphaid,$mark) {
    $this->timestamp = $timestamp;
    $this->subject = $subject;
    $this->level = $level;
    $this->task = $task;
    $this->subtask = $subtask;
    $this->alphaid = $alphaid;
    $this->mark = $mark;
  }

  public function length() {
    return count($this->timestamp);
  }

  public function display() {
    $content = "timestamp\t" . "subject\t" . "level\t" . "task\t" .
      "subtask\t" . "alphaid\t" . "mark\n";
    foreach (range(0,$this->length()-1) as $i) {
      $content .= $this->timestamp[$i] . "\t" .
	$this->subject[$i] . "\t" . 
	$this->level[$i] . "\t" .
	$this->task[$i] . "\t" . 
	$this->subtask[$i] . "\t" .
	$this->alphaid[$i] . "\t" .
	$this->mark[$i] ."\n";
    }
    echo $content;
  }
  
  public function evalA1($threshold) {
    if ($this->length() > 0) {
      $score_by_alphaid = tapply_mean($this->mark,$this->alphaid);
      $alphas_tested = array_keys($score_by_alphaid);
      $above = array();
      //print_r($above);
      foreach($score_by_alphaid as $k => $v) {
	if ($v >= $threshold/100) {
	  $above[] = $k;
	}
      }
      return $above;
    } else {
      return array();
    }
  }
}

class alphalist {

  public $alphaID=array();
  public $order=array();
  public $description=array();
  public $userdescription=array();
  public $example=array();
  
  public function __construct($alphalist) {
    if (file_exists($alphalist)) {
      $xmldoc = simplexml_load_file($alphalist);
      foreach ($xmldoc->alphanode as $alphanode) {
	$alphaID[] = (string)$alphanode['alphaID'];
	$order[] = (int)$alphanode['order'];
	$description[] = (string)$alphanode['description'];
	$userdescription[] = (string)$alphanode['description'];
	$example[] = (string)$alphanode['example'];
      }
      $this->alphaID = $alphaID;
      $this->order = $order;
      $this->description = $description;
      $this->userdescription = $userdescription;
      $this->example = $example;
    } else {
      exit("Creating new alphalist object failed: file not found\n");
    }
  }

  public function order() {
    $a0 = array();
    $a1 = array();
    $a2 = array();
    $a3 = array();
    foreach ($this->alphaID as $alphaID) {
      $pieces = explode(".",$alphaID);
      if (count($pieces) == 3) {
	$pieces[] = 0; 
      }
      $a0[] = (int)$pieces[0];
      $a1[] = (int)$pieces[1];
      $a2[] = (int)$pieces[2];
      $a3[] = (int)$pieces[3];
    }
    array_multisort($a0,$a1,$a2,$a3);
  }
}


?>