<?php

class item {
  public $task;
  public $data;
  
  public function __construct($iname,$data) {
    $this->task = $iname;
    $this->data = $data;
  }
}

class test {
  public $timestamp;
  public $subject;
  public $level;
  public $prev;
  public $items;
  
  public function __construct($timestamp,$subject,$level,$prev,$items) {
    $this->timestamp = $timestamp;
    $this->subject = $subject;
    $this->level = $level;
    $this->prev = $prev;
    $this->items = $items;
  }
}

class mark {
  public $subtask;
  public $alphaid;
  public $mark;

  public function __construct($subtask,$alphaid,$mark) {
    $this->subtask = $subtask;
    $this->alphaid = $alphaid;
    $this->mark = $mark;
  }
}

class user {
  public $id; // this argument is required (later on I might change it back to protected)
  public $test; // this argument can be omitted
  
  public function __construct($id,$test=null) {
    $this->id = $id;
    $this->test = $test;
  }

  public function getUserDir() { // Wouldn't it be better to define it as a property?
    global $Udir;
    return $Udir . $this->id . '/';
  }

  public function getGlobalXML() { // Wouldn't it be better to define it as a proeprty?
    return $this->getUserDir() . $this->id . ".xml";
  }

  public function performedTests() {
    $guf = $this->getGlobalXML();
    if (file_exists($guf)) {
      $xmldoc = simplexml_load_file($guf);
      $performedtests = array();
      foreach ($xmldoc->test as $test) {
	$items = array();
	foreach ($test->item as $item) {
	  $items[] = new item((string)$item['iname'],(string)$item['data']);
	}
	$timestamp_test = (string)$test['timestamp'];
	$performedtests[] = new test($timestamp_test,(string)$test['subject'],(string)$test['level'],(string)$test['prev'],$items);
      }
    } else {
      exit("Failed to open the user's global xml file.\n");
    }
    return $performedtests;
  }

  public function getRecentTestIndex($performedtests) { // Do we need this at all?
    return matchTimestamp($performedtests,$this->test);
  } 

  public function getRecentTest($performedtests) {
    $index = matchTimestamp($performedtests,$this->test);
    return $performedtests[$index];
  }

  public function getMarks($tests) {
    $udir = $this->getUserDir();

    $timestamp = array();
    $subject = array();
    $level = array();
    $task = array();
    $subtask = array();
    $alphaid = array();
    $mark = array();
    foreach ($tests as $test) {
      $timestamp_test = $test->timestamp;
      $subject_test = $test->subject;
      $level_test = $test->level;
      foreach ($test->items as $item) {
	$basename_task = $item->data;
	$taskname = $item->task;
	if (strlen($basename_task)>0) {
	  $file_task = $udir . $item->data;
	  if (file_exists($file_task)) {
	    $xmldoc_task = simplexml_load_file($file_task);
	    foreach ($xmldoc_task->marking->mark as $mark) {
	      $timestamp[] = $timestamp_test;
	      $subject[] = $subject_test;
	      $level[] = $level_test;
	      $task[] = $taskname;
	      $subtask[] = (string)$mark['itemnumber'];
	      $alphaid[] = (string)$mark['alphalevel'];
	      $mark[] = (int)$mark;
	    }
	  } else {
	    exit("Failed to open file " . $basename_task . "\n");
	  }
	}
      }
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

  public function evalA2($threshold) { // note that at the moment it is a dummy function
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

class result {
  public $pdfname;
  public $timestamp;
  public $subject;
  public $level;

  public function __construct($pdfname,$timestamp,$subject,$level) {
    $this->pdfname = $pdfname;
    $this->timestamp = $timestamp;
    $this->subject = $subject;
    $this->level = $level;
  }
  
  public function asXML() {
    $dom = new DomDocument('1.0','UTF-8');
    $results = $dom->appendChild($dom->createElement('results'));
    // print node
    $resultsPrint = $dom->createElement('print');
    $results->appendChild($resultsPrint);
    $attr = $dom->createAttribute('file');
    $attr->appendChild($dom->createTextNode($this->pdfname));
    $resultsPrint->appendChild($attr);
    // timestamp node
    $resultsTimestamp = $dom->createElement('timestamp');
    $results->appendChild($resultsTimestamp);
    $attr = $dom->createAttribute('order');
    $attr->appendChild($dom->createTextNode('YmdHis'));
    $resultsTimestamp->appendChild($attr);
    $attr = $dom->createAttribute('value');
    $attr->appendChild($dom->createTextNode($this->timestamp));
    $resultsTimestamp->appendChild($attr);
    // subject node
    $resultsSubject = $dom->createElement('subject');
    $results->appendChild($resultsSubject);
    $attr = $dom->createAttribute('value');
    $attr->appendChild($dom->createTextNode($this->subject));
    $resultsSubject->appendChild($attr);
    // level node
    $resultsLevel = $dom->createElement('level');
    $results->appendChild($resultsLevel);
    $attr = $dom->createAttribute('value');
    $attr->appendChild($dom->createTextNode($this->level));
    $resultsLevel->appendChild($attr);
    // it's also needed
    $dom->formatOutput = true;
    return $dom;
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