<?php

class item {
  public $task;
  public $data;
  
  public function __construct($iname, $data) {
    $this->task = $iname;
    $this->data = $data;
  }

  public function isempty() {
    return strlen($this->data) == 0 ? true : false;
  }
}

class test {
  public $timestamp;
  public $subject;
  public $level;
  public $prev;
  public $items;
  
  public function __construct($timestamp, $subject, $level, $prev, $items) {
    $this->timestamp = $timestamp;
    $this->subject = $subject;
    $this->level = $level;
    $this->prev = $prev;
    $this->items = $items;
  }

  public function tasks() {
    $tasks = array();
    foreach($this->items as $item) {
      $tasks[$item->task] = $item->task;
    }
    return $tasks;
  }

}

class user {
  private $dir;
  private $id;
  private $index;

  public function __construct($dir_user, $id) {
    $this->dir = $dir_user . "/" . $id;
    $this->id = $id;
    $this->index = $this->dir . "/" . $id . ".xml"; 
  }

  private function get_tests() {
    if (file_exists($this->index)) {
      $xmldoc = simplexml_load_file($this->index);
      $tests = array();
      foreach ($xmldoc->test as $test) {
	$items = array();
	foreach ($test->item as $item) {
	  $items[(string)$item['iname']] = (string)$item['data'];
	}
	$timestamp_test = otulea::normalize((string)$test['timestamp']);
	$prev_test = (string)$test['prev'];
	if (strlen($prev_test) > 0) {
	  $prev_test = otulea::normalize($prev_test);
	}
	$tests[$timestamp_test] = new test($timestamp_test, (string)$test['subject'], (string)$test['level'], $prev_test, $items);
      }
      ksort($tests);
      return $tests;
    } else {
      throw new Exception("Couldn't reach testindex file");
    }
  }

  public function get_latest_tests($timestamp=null) {
    $tests = $this->get_tests();
    $timestamps = array_keys($tests);
    if (is_null($timestamp)) {
      $timestamp = end($timestamps);
    }
    if (!isset($tests[$timestamp])) {
      throw new Exception("No test found for the requested timestamp");
    } else {
      $latest_tests = array();
      do {
	$current_test = $tests[$timestamp];
	$latest_tests[$timestamp] = $current_test;
	$timestamp = $current_test->prev;
      } while (strlen($timestamp) > 0);
      return $latest_tests;
    }
  }

}

class otulea {
  protected $dir_user;
  public $dir_item;
  
  public function __construct($dir_data) {
    $this->dir_user = $dir_data . "/" . "user/";
    $this->dir_item = $dir_data . "/" . "item/";
  }

  public function get_user($id) {
    return new user($this->dir_user, $id);
  }

  public function users($id) {
    $id_len = strlen($id);
    if ($id_len < 2) {
      throw new Exception("At least 2 characters must be specified");
    } else {
      $pattern = substr($id, 0, 5);
    }     
    $users = array();
    if ($handle = opendir($this->dir_user)) {
      while (false !== ($file = readdir($handle))) {
	$dir_user_user = $this->dir_user . "/" . $file;
	  if ($file != "." && $file != ".." && is_dir($dir_user_user)) {
	    if (strcmp($pattern, substr($file, 0, $id_len)) === 0) {
	      $users[] = new user($this->dir_user, $file);
	    }
	  }
      }
      closedir($handle);
    }
    sort($users);
    return $users;
  }

  static function normalize($timestamp) {
    $parts = explode("_", $timestamp);
    foreach ($parts as $k=>$v) {
      $parts[$k] = str_pad($v, 2, "0", STR_PAD_LEFT);
    }
    return implode("_", $parts);
  }
  
}

?>