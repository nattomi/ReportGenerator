<html>
<head>
<meta charset="utf-8"> 
<title>DT report</title>
</head>
<body>
<?php
// SETTINGS
$alphalist_file = "";
//MAIN
$user = $_GET["user"];
//$user = "KFCG1"; // testing
$type = $_GET["type"];
//$type = ""; // testing
$israw = $type == "raw";
$global_user_file = "" . $user . "/" . $user . ".xml";
//echo $global_user_file;
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
    //foreach ($abdesc_id as $abid) $bearbeitet[$abid] = 0;
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
      foreach ($abdesc_id as $abid) $bearbeitet0[$abid] = 0;
      $erfuellt0 = array();
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
	    $mark_current = (int)$mark0[0];
	    $mark [] = $mark_current;
	    // incrementing corresponding entry in bearbeitet
	    $bearbeitet0[$alphalevel0]++;
	    if (!array_key_exists($alphalevel0,$erfuellt0)) {
	      $erfuellt0[$alphalevel0] = $mark_current;
	    } else {
	      $erfuellt0[$alphalevel0] *= $mark_current;
	    }
	  } // foreach ($test_result
	} else { // if (file_exists($test_result_file
	  exit("Failed to open test result file\n");
	}
	$bearbeitet_2dim[$timestamp0] = $bearbeitet0;
	$erfuellt_2dim[$timestamp0] = $erfuellt0;
      } // foreach ($test
    } // foreach ($global_user
    array_multisort($Y,$m,$d,$H,$M,$S,$timestamp,$subject,$level,$iname,
		    $itemnumber,$alphalevel,$mark);
    $indices = range(0,sizeof($Y) - 1);
    echo "<pre><table style=\"border-collapse:collapse;\">\n";
    if ($israw) {
      echo "<tr><td style=\"border:1px solid black;\"><b>timestamp</b></td><td style=\"border:1px solid black;background-color: azure;\"><b>subject</b></td><td style=\"border:1px solid black;\"><b>level</b></td><td style=\"border:1px solid black;background-color: azure;\"><b>iname</b></td><td style=\"border:1px solid black;\"><b>itemnumber</b></td><td style=\"border:1px solid black;background-color: azure;\"><b>alphalevel</b></td><td style=\"border:1px solid black;\"><b>mark</b></td></tr>\n";
      foreach ($indices as $i) {
	//$erfuellt[$alphalevel[$i]] = $mark[$i];
	echo "<tr><td style=\"border:1px solid black;\">" . $timestamp[$i] . "</td><td style=\"border:1px solid black;background-color: azure;\">" . $subject[$i] . "</td><td style=\"border:1px solid black;\">" . $level[$i] . "</td><td style=\"border:1px solid black;background-color: azure;\">" . $iname[$i] . "</td><td style=\"border:1px solid black;\">" . $itemnumber[$i] . "</td><td style=\"border:1px solid black;background-color: azure;\">" . $alphalevel[$i] . "</td><td style=\"border:1px solid black;\">" . $mark[$i] . "</td></tr>\n";
      }
    } else {
      $erfuellt = $erfuellt_2dim[end($timestamp)];
      echo "<tr><td style=\"border:1px solid black;\"><b>ability_description_id</b></td><td style=\"border:1px solid black;background-color: azure;\"><b>ability_description</b></td><td style=\"border:1px solid black;\"><b>bearbeitet (# tests)</b></td><td style=\"border:1px solid black;background-color: azure;\"><b>bearbeitet (# all occurrence)</b></td><td style=\"border:1px solid black;\"><b>KB erfüllt</b></td></tr>\n";
      foreach ($abdesc_id as $abid) {
	$bearbeitet_ntests[$abid] = 0;
	$bearbeitet_all[$abid] = 0;
      }
      $indices = range(0,sizeof($abdesc) - 1);
      foreach ($indices as $i) {
	$a = $abdesc_id[$i];  
	foreach ($bearbeitet_2dim as $b2dim) {
	  if ($b2dim[$a] > 0) $bearbeitet_ntests[$a]++;
	  $bearbeitet_all[$a] +=  $b2dim[$a];
	}
	echo "<tr><td style=\"border:1px solid black;\">" . $a . "</td><td style=\"border:1px solid black;background-color: azure;\">" . $abdesc[$i] . "</td><td style=\"border:1px solid black;\">" . $bearbeitet_ntests[$a] . "</td><td style=\"border:1px solid black;background-color: azure;\">" . $bearbeitet_all[$a] . "</td><td style=\"border: 1px solid black;\">";
	if (array_key_exists($a,$erfuellt)) {
	  echo $erfuellt[$a];
	} else echo "&nbsp;";
	echo "</td></tr>\n"; 
      }
    }
    echo "</table></pre>\n";
  } else { // if (file_exists($global_user_file
    exit("Failed to open global user file\n");
  }
} else { // if (file_exists($alphalist_file
  exit("Failed to open alphalist file\n");
}
//print_r($erfuellt_2dim);
?>
</body>
</html>