<?php
class mark {
  private $timestamp;
  private $task;
  private $subtasks;

  public function __construct($simple_xml_data) {
    $subtasks = array();
    foreach($simple_xml_data->marking->mark as $mark) {
      $subtask = (string)$mark['itemnumber'];
      $alphaid = (string)$mark['alphalevel'];
      $subtasks[$subtask] = array('alphaid'=>$alphaid, 
				  'mark'=>(int)$mark);
    }
    $this->subtasks = $subtasks;
  }
  
  public function get_timestamp() {
    return $this->timestamp;
  }

  public function set_timestamp($timestamp) {
    $this->timestamp = $timestamp;
  }

  public function set_task($task) {
    $this->task = $task;
  }

  public function get_subtasks() {
    return $this->subtasks;
  }


}

class test {
  private $timestamp;
  private $subject;
  private $level;
  private $prev;
  private $key_prev;
  private $key_next;
  private $items;

  public function __construct($simple_xml_test) {
    $this->timestamp = (string)$simple_xml_test['timestamp'];
    $this->subject = (string)$simple_xml_test['subject'];
    $this->level = (string)$simple_xml_test['level'];
    $this->prev = (string)$simple_xml_test['prev'];
    $items = array();
    foreach($simple_xml_test->item as $item) {
      $items[(string)$item['iname']] = array('timestamp'=>$this->timestamp,
					     'data'=>(string)$item['data']); 
    }
    $this->items = $items;    
  } 

  public function get_timestamp() {
    return $this->timestamp;
  }

  public function get_subject() {
    return $this->subject;
  }

  public function get_level() {
    return $this->level;
  }
  
  public function get_prev() {
    return $this->prev;
  }

  public function get_items() {
    return $this->items;
  }

  public function get_key_prev() {
    return $this->key_prev;
  }

  public function set_key_prev($key) {
    $this->key_prev = $key;
  }

  public function get_key_next() {
    return $this->key_next;
  }

  public function set_key_next($key) {
    $this->key_next = $key;
  }

  public function print_items() {
    foreach(array_keys($this->items) as $item) {
      echo $item . " " . 
	   $this->items[$item]['timestamp'] . " " .
	   $this->items[$item]['data'] . PHP_EOL;
    }
  }

  public function merge($test) {
    $this->prev = $test->prev;
    foreach($this->items as $item=>$values) {
      $this->items[$item] = otulea::merge_items($this->items[$item], $test->items[$item]);
    }
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

  public function get_tests($timestamp="") {
    if(file_exists($this->index)) {
      $xmldoc = simplexml_load_file($this->index);
      $ans = array();
      $key_prev = null;
      $first = true;
      foreach($xmldoc->test as $test) {
	$timestamp_test = (string)$test['timestamp'];
	$t = new test($test);
	$t->set_key_prev($key_prev);
	$ans[$timestamp_test] = $t;
	if(!$first)
	  $ans[$key_prev]->set_key_next($timestamp_test);
	else
	  $first = false;
	if(strcmp($timestamp_test, $timestamp) === 0)
	  break;
	$key_prev = $timestamp_test;
      }
      return array_reverse($ans);
    } else {
      return false;
    }
  }

  public function get_id() {
    return $this->id;
  }
  
}

class otulea {
  private $dir_user;
  private $dir_item;
  private $user;

  public function __construct($dir_data) {
    $this->dir_user = $dir_data . "/" . "user/";
    $this->dir_item = $dir_data . "/" . "item/";
  }

  public function set_user($id) {
    $this->user = new user($this->dir_user, $id);
  }

  public function ls_users() {
    $dh = opendir($this->dir_user);
    $ids = array();
    
    while(false !== ($d = readdir($dh))) {
      if($d != '.' && $d != '..' && is_dir($this->dir_user . '/' . $d)) {
        $ids[] = $d;
      }
    }

    sort($ids);
    return $ids;
   }

  public function get_tests($timestamp="") {
    return $this->user->get_tests($timestamp);
  }

  public function get_marks($test) {
    $marks = array();
    foreach($test->items() as $item=>$value) {
      if(strlen($value['data']) != 0) {
	$xml_data = $this->dir_user       . "/" . 
	            $this->user->get_id() . "/" .
	            $value['data'];
      } else {
	$xml_data = $this->dir_item . "/" .
	            $item           . "/" .
	            $item           . ".xml";
      }
      if(file_exists($xml_data)) {
	$simple_xml_data = simplexml_load_file($xml_data);
      } else {
	return false;
      }
      //  echo $item . PHP_EOL;
      $mark = new mark($simple_xml_data);
      $mark->set_timestamp($value['timestamp']);
      $mark->set_task($item);
      $marks[] = $mark;
    }
    return $marks;
  }

  static function print_testarray(&$testarray) {
    foreach($testarray as $test) {
      echo $test->get_timestamp() . " " .
	   $test->get_subject()   . " " .
	   $test->get_level()     . " " .
	// $test->get_key_prev()  . " " .
	// $test->get_key_next()  . " " .
	   $test->get_prev()  . PHP_EOL;
    }
  }

  static function print_markarray(&$markarray) {
    foreach($markarray as $mark) {
      foreach($mark->get_subtasks() as $subtask=>$value) {
	echo $mark->get_timestamp() . " " .
	     $subtask               . " " .
	     $value['alphaid']      . " " .
	     $value['mark']         . PHP_EOL;
      }
    }
  }

  static function merge_items($item1, $item2) {
    $d1 = $item1['data'];
    $d2 = $item2['data'];
    $c = 2 * (strlen($d1) != 0) + (strlen($d2) != 0);
   
    $timestamp = $item1['timestamp'];
    $data = $d2;
    
    switch ($c) {
    case 0: // 'data' is empty for both items
      break;
    case 1: // 'data' is empty only for the first item
      $timestamp = $item2['timestamp'];
      break;
    case 2: // 'data' is empty only for the second item
      $data = $d1; 
      break;
    }

    return array('timestamp'=>$timestamp,
    		 'data'=>$data);
  }

  static function glue_session(&$testarray, $timestamp) {
    if(strlen($timestamp) == 0)
      $timestamp = reset($testarray)->timestamp();
    $test = $testarray[$timestamp];
    $timestamp_prev = $test->get_prev();
    while(strlen($timestamp_prev) > 0) {
      if(!array_key_exists($timestamp_prev, $testarray))
	return false;
      $test_prev = $testarray[$timestamp_prev];
      $testarray[$timestamp]->merge($test_prev);
      $key_prev = $testarray[$timestamp_prev]->get_key_prev();
      $key_next = $testarray[$timestamp_prev]->get_key_next(); 
      unset($testarray[$timestamp_prev]);
      if(!is_null($key_prev))
	$testarray[$key_prev]->set_key_next($key_next);
      $testarray[$key_next]->set_key_prev($key_prev);
      $timestamp_prev = $testarray[$timestamp]->get_prev();
    }
    return true;
  }

  static function get_next_item($testarray, $timestamp) {
    $currentKey = key($testarray);
    while ($currentKey !== null && $currentKey != $timestamp) {
      next($testarray);
      $currentKey = key($testarray);
    }
    return next($array);
  }

  static function filter_latest(&$testarray) {
    // FIXME: most probably it doesn't work anymore
    $index = array_keys($testarray);
    $timestamp = (string)$testarray[$index[0]]['timestamp'];
    $latest_tests = array();
    do {
      $current_test = $testarray[$timestamp];
      $latest_tests[$timestamp] = $current_test; 
      $timestamp = (string)$current_test['prev']; 
    } while(strlen($timestamp) > 0);
 
    return $latest_tests;
  }

}

?>