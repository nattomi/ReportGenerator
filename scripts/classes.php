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
}

?>