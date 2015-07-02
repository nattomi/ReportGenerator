<?php
include "api.php";

class config {
  const DIR_DATA = "data/";
  const DIR_OUT = "/tmp/";
}

class parse {                                                                 
  static function id() {
    if (!array_key_exists('user', $_POST)) {
      // trying to set user from the command line                              
      global $argv;
      if (!is_null($argv[1])) {
        return $argv[1];
      } else {
        throw new Exception("User id haven't received neither via POST nor via command line");
      }
    } else {
      return $_POST['user'];
    }
  }

  static function timestamp() {
    global $argv;
    global $argc;

    if (is_null($argc)) {
      return null;
    } else {
      if ($argc < 3) {
	return null;
      } else {
        return $argv[2];
      };
    };
  }

}

/* main */
$ot = new otulea(config::DIR_DATA);
$user = $ot->get_user(parse::id());
print_r($user->get_latest_tests(parse::timestamp()));
?>