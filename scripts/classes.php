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
	    foreach ($xmldoc_task->marking->mark as $mark0) {
	      $timestamp[] = $timestamp_test;
	      $subject[] = $subject_test;
	      $level[] = $level_test;
	      $task[] = $taskname;
	      $subtask[] = (string)$mark0['itemnumber'];
	      $alphaid[] = (string)$mark0['alphalevel'];
	      $mark[] = (int)$mark0;
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
  public $timestamp;
  public $subject;
  public $level;
  public $task;
  public $subtask;
  public $alphaid;
  public $mark;
  public $length;

  public function __construct($timestamp,$subject,$level,
			      $task,$subtask,$alphaid,$mark) {
    $this->timestamp = $timestamp;
    $this->subject = $subject;
    $this->level = $level;
    $this->task = $task;
    $this->subtask = $subtask;
    $this->alphaid = $alphaid;
    $this->mark = $mark;
    $this->length = count($timestamp);
  }

  public function display() {
    $content = "timestamp\t" . "subject\t" . "level\t" . "task\t" .
      "subtask\t" . "alphaid\t" . "mark\n";
    if ($this->length > 0) {
      foreach (range(0,$this->length-1) as $i) {
	$content .= $this->timestamp[$i] . "\t" .
	  $this->subject[$i] . "\t" . 
	  $this->level[$i] . "\t" .
	  $this->task[$i] . "\t" . 
	  $this->subtask[$i] . "\t" .
	  $this->alphaid[$i] . "\t" .
	  $this->mark[$i] ."\n";
      }
    }
    echo $content;
  }
  
  public function evalA1($threshold,$head) {
    $above = array();
    if ($this->length > 0) {
      $score_by_alphaid = tapply_mean($this->mark,$this->alphaid);
      $alphas_tested = array_keys($score_by_alphaid);
      foreach($score_by_alphaid as $k => $v) {
	if ($v >= $threshold/100) {
	  $above[] = $k;
	}
      }
    }
    usort($above,"cmpAlphaId"); // sort them increasingly in dictionary-style
    // the last step is truncating the result
    // * the meaning of a positive number is straightforward
    // * 0 results in empty list
    // * a negative number means no truncation at all
    if ($head >= 0) {
      $above = array_slice($above,0,$head);
    }
    return $above;
  }

  public function evalA2($threshold,$head) { // note that this is a dummy function, to be changed later
    $above = array();
    if ($this->length > 0) {
      $score_by_alphaid = tapply_mean($this->mark,$this->alphaid);
      $alphas_tested = array_keys($score_by_alphaid);
      foreach($score_by_alphaid as $k => $v) {
	if ($v >= $threshold/100) {
	  $above[] = $k;
	}
      }
    }
    usort($above,"cmpAlphaId"); // sort them increasingly in dictionary-style
    // the last step is truncating the result
    // * the meaning of a positive number is straightforward
    // * 0 results in empty list
    // * a negative number means no truncation at all
    if ($head >= 0) {
      $above = array_slice($above,0,$head);
    }
    return $above;
  }

}

class eval_ {
  public $mode;
  public $message;
  public $alphanodes;

  public function __construct($mode,$message,$alphanodes) {
    $this->mode = $mode;
    $this->message = $message;
    $this->alphanodes = $alphanodes;
  }

  public function asTex() {
    global $mode_strings;
    global $graphics;
    
    $content ="";
    if (!is_null($this->message)) {
      $content .= $this->message . PHP_EOL;
    }
    $rownum = count($this->alphanodes);
    $userdescription = array();
    $example = array();
    $nBeispiel = 0;
    foreach ($this->alphanodes as $a) {
      $userdescription[] = $a->userdescription;
      $e = $a->example;
      $example[] = $e;
      if ($e!="") $nBeispiel++;
    }
    $beispiel = $nBeispiel > 0;
    if ($rownum > 0) {
      $content .= "\\begin{tabular}{r";
      $content .= $beispiel ? "p{.4\\textwidth}@{\hspace{2em}}!{\color{TextDark}\\vrule}@{\hspace{2em}}p{.4\\textwidth}" : "p{.8\\textwidth}";
      $content .= "}\n";
      $content .= "& \\textcolor{TextStandard}{\\fontsize{20pt}{1em}\\selectfont ";
      $content .= $mode_strings[$this->mode];
      $content .= "}";
      if ($beispiel) $content .= " & \\textcolor{TextStandard}{\\fontsize{20pt}{1em}\\selectfont Beispiel}";
      $content .= "\\\\[-50px]\n";
      for ($i=0; $i < $rownum; $i++) {
	$content .= $graphics[$this->mode];
	$content .= " & ";
	$content .= $userdescription[$i];
	if ($beispiel) {
	  $content .= " & ";
	  $content .= $example[$i];
	}
	$content .= "\\\\\n";
      }
      $content .= "\\end{tabular}\n";
    }
    return $content;
  }
}

class result {
  public $pdfname;
  public $timestamp;
  public $subject;
  public $level;
  public $evals;

  public function __construct($pdfname,$timestamp,$subject,$level,$evals) {
    $this->pdfname = $pdfname;
    $this->timestamp = $timestamp;
    $this->subject = $subject;
    $this->level = $level;
    $this->evals = $evals;
  }
  
  public function asXML() {
    $node_results = new SimpleXMLElement('<?xml version="1.0" encoding="UTF-8"?>' . "<results></results>");
    // print node
    $node_print = $node_results->addChild('print');
    $node_print->addAttribute('file', $this->pdfname);
    // timestamp node
    $node_timestamp = $node_results->addChild('timestamp');
    $node_timestamp->addAttribute('order', 'YmdHis');
    $node_timestamp->addAttribute('value', $this->timestamp);
    // subject node
    $node_subject = $node_results->addChild('subject');
    $node_subject->addAttribute('value', $this->subject);
    // level node
    $node_level = $node_results->addChild('level');
    $node_level->addAttribute('value', $this->level);
    // Adding eval nodes
    foreach ($this->evals as $e) {
      $node_eval = $node_results->addChild('eval');
      $node_eval->addAttribute('mode', $e->mode);
      // message node
      if (!is_null($e->message)) $node_msg = $node_eval->addChild('message',$e->message);
      // alphanodes
      foreach ($e->alphanodes as $an) {
	$node_an = $node_eval->addChild('alphanode');
	$node_an->addAttribute('alphaID',$an->alphaID);
	$node_an->addAttribute('userdescription',$an->userdescription);
	$node_an->addAttribute('example',$an->example);	
      }
    }
    // simple_xml doesn't print out nice so we
    // convert to a DOM object
    $dom = new DOMDocument('1.0');
    $dom = dom_import_simplexml($node_results)->ownerDocument;
    $dom->preserveWhiteSpace = false;
    $dom->formatOutput = true;
    return $dom;
  }

  public function asXML2() {
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

class alphanode {
  public $alphaID;
  public $order;
  public $description;
  public $userdescription;
  public $example;

  public function __construct($alphaID,$order,$description,
			      $userdescription,$example) {
    $this->alphaID = $alphaID;
    $this->order = $order;
    $this->description = $description;
    $this->userdescription = $userdescription;
    $this->example = $example;
  }
}

class alphalist {
  public $alphaid=array();
  public $order=array();
  public $description=array();
  public $userdescription=array();
  public $example=array();

  public function __construct($alphaid,$order,$description,
			      $userdescription,$example) {
    $this->alphaid = $alphaid;
    $this->order = $order;
    $this->description = $description;
    $this->userdescription = $userdescription;
    $this->example = $example;
  }
  
  public function subset($alphaids) {
    $alphaid = array();
    $order = array();
    $description = array();
    $userdescription = array();
    $example = array();
    foreach ($alphaids as $a) {
      $i = array_search($a,$this->alphaid);
      $alphaid[] = $this->alphaid[$i];
      $order[] = $this->order[$i];
      $description[] = $this->description[$i];
      $userdescription[] = $this->userdescription[$i];
      $example[] = $this->example[$i];
    }
    return new alphalist($alphaid,$order,$description,
			 $userdescription,$example);
  } 
  /*
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
    }*/
}


?>