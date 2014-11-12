<?php
class user {
  public $id='KFCG1'; // property for holding user id

  public function setId($newid) {
    $this->id = $newid;
  }
  
  public function getUserDir() {
    global $Udir;
    return $Udir . $this->id . '/';
  }

  public function getGlobalXML() {
    return $this->getUserDir() . $this->id . ".xml";
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
  
  public function evalA1() {
    if ($this->length() > 0) {
      $performance_by_alphaid = tapply_mean($this->mark,$this->alphaid);
      return $performance_by_alphaid;
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