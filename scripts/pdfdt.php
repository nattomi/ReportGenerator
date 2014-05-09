<?php
// SETTINGS
$alphalist_file = "";
//MAIN
$user = $_GET["user"];
//$user = "KFCG1"; // testing
$global_user_file = "" . $user . "/" . $user . ".xml";
// ROUTINES
function sanitize($x) {
  $x = str_replace("μ","$\\mu$",$x);
  $x = str_replace("«","\\guillemotleft ",$x);
  $x = str_replace("»","\\guillemotright ",$x);
  $x = str_replace("„","\"",$x);
  $x = str_replace("“","\"",$x);
  return $x;
}
//MAIN
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
  $abdesc = sanitize($abdesc);
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
    // create temporary directory first
    $dir_tmp = "tmp";
    $path_dir_tmp = $user_dir . "/" . $dir_tmp;
    //$path_dir_tmp = $dir_tmp; //for testing
    $file_tex = $dir_tmp . ".tex";
    $file_pdf = $dir_tmp . ".pdf";
    $path_file_tex = $path_dir_tmp . "/" . $file_tex; //I'm not sure we need this
    $path_file_pdf = $path_dir_tmp . "/" . $file_pdf;
    $path_file_pdf_target = $user_dir . "/" . $file_pdf;
    //$path_file_pdf_target = $file_pdf; //for testing
    if (!file_exists($path_dir_tmp)) mkdir($path_dir_tmp);
    $fp = fopen($path_file_tex,"w");
    fwrite($fp,"\documentclass{article}\n");
    fwrite($fp,"\usepackage[a4paper,landscape,bottom=2.5cm,top=2.5cm,left=2.5cm, right=2.5cm]{geometry}\n");
    fwrite($fp,"\usepackage[T1]{fontenc}\n");
    fwrite($fp,"\usepackage[utf8]{inputenc}\n");
    fwrite($fp,"\usepackage[ngerman]{babel}\n");
    fwrite($fp,"\usepackage{longtable}\n");
    fwrite($fp,"\usepackage{amssymb}\n");
    fwrite($fp,"\usepackage{helvet}\n");
    fwrite($fp,"\\renewcommand{\\familydefault}{\sfdefault}\n");
    fwrite($fp,"\usepackage{fancyhdr}\n\n");
    fwrite($fp,"\pagestyle{fancy}\n\\fancyhf{}\n");
    fwrite($fp,"\\rhead{Teilnehmer/Teilnehmerin: " . $user ."}\n");
    fwrite($fp,"\lhead{Datum: \\today}\n");
    fwrite($fp,"\begin{document}\n");
    fwrite($fp,"\begin{longtable}{c|p{0.75\\textwidth}|c|c|c}\n");
    fwrite($fp,"id & ability description & BA-T & BA-A & KB\\\\\n");
    fwrite($fp,"\hline\n");
    $erfuellt = $erfuellt_2dim[end($timestamp)];
    foreach ($abdesc_id as $abid) {
      $bearbeitet_ntests[$abid] = 0;
      $bearbeitet_all[$abid] = 0;
    }
    $indices = range(0,sizeof($abdesc) - 1);
    foreach ($indices as $i) {
      $a = $abdesc_id[$i];
      $erfuellt_key = array_search($a,array_reverse($alphalevel));
      $erfuellt_ts = array_reverse($timestamp)[$erfuellt_key];
      $erfuellt = $erfuellt_2dim[$erfuellt_ts];
      foreach ($bearbeitet_2dim as $b2dim) {
	if ($b2dim[$a] > 0) $bearbeitet_ntests[$a]++;
	$bearbeitet_all[$a] +=  $b2dim[$a];
      }
      fwrite($fp,$a . " & " . $abdesc[$i] . " & " . $bearbeitet_ntests[$a] . " & " . $bearbeitet_all[$a] . " & ");
      if (array_key_exists($a,$erfuellt)) {
	fwrite($fp,$erfuellt[$a]);
      } else {
      }
      fwrite($fp,"\\\\\n");
    } // foreach ($indices
    fwrite($fp,"\\hline\n");
    fwrite($fp,"\\end{longtable}\n");
    fwrite($fp,"\\end{document}\n");
    fclose($fp);
    //  running pdflatex
    $wd = getcwd();
    chdir($path_dir_tmp);
    $pdflatex = "pdflatex " . $file_tex;
    exec($pdflatex);
    copy($path_file_pdf, $path_file_pdf_target);
    $dh = opendir($path_dir_tmp);
    while (false !== ($filename = readdir($dh))) {
      unlink($filename);
    }
    rmdir($path_dir_tmp);
    copy($path_file_pdf_target,$wd . "/tmp.pdf"); // for testing only
    unlink($path_file_pdf_target); // for testing only
    //echo "eljutunk idáig?\n";
    chdir($wd);
    header("Content-type: application/pdf");
    header("Content-Disposition: inline; filename=dt.pdf");
    @readfile('tmp.pdf');
  } else { // if (file_exists($global_user_file
    exit("Failed to open global user file\n");
  }
} else { // if (file_exists($alphalist_file
  exit("Failed to open alphalist file\n");
}
?>