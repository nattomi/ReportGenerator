<?php
// SETTINGS
$alphalist_file = "../otulea/inst/data/item/alphalist/alphalist.XML";
$global_user_file = "../otulea/inst/data/user/KFCG1/KFCG1.xml";
// MAIN
if (file_exists($alphalist_file)) { // parsing and sorting alphalist file first
  $alphalist = simplexml_load_file($alphalist_file);
  foreach ($alphalist->alphanode as $alphanode) {
    $abdesc_0 = (string)$alphanode['description'];
    $abdesc [] = $abdesc_0;
    $abdesc_id_0 = (string)$alphanode['alphaID'];
    $abdesc_id_split = split("\.",$abdesc_id_0);
    $abdesc_id [] = $abdesc_id_0;
    // these arrays are needed for proper sorting
    $abdesc_id_1 [] = (int)$abdesc_id_split[0];
    $abdesc_id_2 [] = (int)$abdesc_id_split[1];
    $abdesc_id_3 [] = (int)$abdesc_id_split[2];
    if (sizeof($abdesc_id_split) > 3) { //sometimes the 4th part is missing
      $abdesc_id_4 [] = (int)$abdesc_id_split[3];
    } else {
      $abdesc_id_4 [] = 0;
    }
  }
  // we sort things by ability description id in increasing order
  array_multisort($abdesc_id_1,$abdesc_id_2,$abdesc_id_3,$abdesc_id_4,$abdesc_id,$abdesc);
  if (file_exists($global_user_file)) { // parsing global user file
    $user_dir = dirname($global_user_file);
    $global_user = simplexml_load_file($global_user_file);
    //initializing array for counting how many times an ability description was tested
    foreach ($abdesc_id as $abid) $bearbeitet[$abid] = 0;
    foreach ($global_user->test as $test) {
      $timestamp0 = (string)$test['timestamp'];
      $subject0 = (string)$test['subject'];
      $level0 = (string)$test['level'];
      // in order to be able to sort by date/time, I define some more arrays
      $timestamp0_split = split("_",$timestamp0);
      $Y0 = (int)$timestamp0_split[0];
      $m0 = (int)$timestamp0_split[1];
      $d0 = (int)$timestamp0_split[2];
      $H0 = (int)$timestamp0_split[3];
      $M0 = (int)$timestamp0_split[4];
      $S0 = (int)$timestamp0_split[5];
      foreach ($test->item as $item) {
	$iname0 = (string)$item['iname'];
	$test_result_file = $user_dir . "/" . $item['data'];
	if (file_exists($test_result_file)) {
	  $test_result = simplexml_load_file($test_result_file);
	  foreach ($test_result->marking->mark as $mark0) {
	    $timestamp [] = $timestamp0;
	    $subject [] = $subject0;
	    $level [] = $level0;
	    $Y [] = $Y0;
	    $m [] = $m0;
	    $d [] = $d0;
	    $H [] = $H0;
	    $M [] = $M0;
	    $S [] = $S0;
	    $iname [] = $iname0;
	    $itemnumber [] = (string)$mark0['itemnumber'];
	    $alphalevel0 = (string)$mark0['alphalevel'];
	    $alphalevel [] = $alphalevel0; 
	    $mark [] = (int)$mark0[0];
	    // incrementing corresponding entry in bearbeitet
	    $bearbeitet[$alphalevel0]++;
	  } // foreach ($test_result
	} else { // if (file_exists($test_result_file
	  exit("Failed to open test result file\n");
	}
      } // foreach ($test
    } // foreach ($global_user
    array_multisort($Y,$m,$d,$H,$M,$S,$timestamp,$subject,$level,$iname,
		    $itemnumber,$alphalevel,$mark);
    $indices = range(0,sizeof($Y) - 1);
    foreach ($indices as $i) {
      $erfuellt[$alphalevel[$i]] = $mark[$i];
      echo $Y[$i] . " " . $m[$i] . " " . $d[$i] . " " . $H[$i] . " " . $M[$i] . " " . $S[$i] . " " . $timestamp[$i] . " " . $subject[$i] . " " . $level[$i] . " " . $iname[$i] . " " . $itemnumber[$i] . " " . $alphalevel[$i] . " " . $mark[$i] . "\n";
    }
    // final data report
    // KB erfuellt
    $indices = range(0,sizeof($abdesc) - 1);
    echo "ability_description_id, bearbeitet, erfuellt\n";
    foreach ($indices as $i) {
      $a = $abdesc_id[$i];
      echo $a . ", " . 
	//$abdesc[$i] .
	$bearbeitet[$a] . ", ";
      if (array_key_exists($a,$erfuellt)) echo $erfuellt[$a]; 
      echo "\n";
    } 
  } else { // if (file_exists($global_user_file
    exit("Failed to open global user file\n");
  }
} else { // if (file_exists($alphalist_file
  exit("Failed to open alphalist file\n");
}
?>