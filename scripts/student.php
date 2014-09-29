<?php
//$user = $_POST['user']; // user id
$user = 'SD5AM';
//$test = $_POST['test']; // timestamp of the test to be evaluated (as specified in the global user file, f.i. 2014_3_3_20_32_49)
$test = '2014_9_12_11_30_29'; // if $test is not set here then it defaults to the last test
// load settings and helper functions
include 'conf_student.php';
include 'functions.php';

$udir = $Udir . $user . '/'; // path to the specific user's data directory
$guf = $udir . $user . ".xml"; // path of the user's "global file"
// parsing the user's global xml file (if exists)
//exit("dsd" . $guf . "\n")
$markingtable = "timestamp\t" . "subject\t" . "level\t" . "task\t" .
  "subtask\t" . "alphaid\t" . "mark\n";
if (file_exists($guf)) {
  $xmldoc = simplexml_load_file($guf);
  $timestamp = array();
  $datetime_diff = array();
  $prev = array();
  foreach ($xmldoc->test as $test_test) { //
    $timestamp_test = (string)$test_test['timestamp'];
    $timestamp[] = $timestamp_test;
    $pieces = explode("_",$timestamp_test);
    $date = new DateTime();
    $date->setDate($pieces[0],$pieces[1],$pieces[2]);
    $date->setTime($pieces[3],$pieces[4],$pieces[5]);
    $unixtime_test = $date->getTimeStamp();
    if (isset($test)) {
      $pieces = explode("_",$test);
      $refdate = new DateTime();
      $refdate->setDate($pieces[0],$pieces[1],$pieces[2]);
      $refdate->setTime($pieces[3],$pieces[4],$pieces[5]);
      $unixtime_test = $date->getTimeStamp();
      $datetime_diff[] = abs($unixtime_test - $refdate->getTimeStamp());
    } else {
      $datetime_diff[] = -$unixtime_test;
    }
    $prev[] = (string)$test_test['prev'];
  }
  $index = array_keys($datetime_diff,min($datetime_diff))[0];
  do {
    //echo $index . "\n";
    $current_test = $xmldoc->test[$index];
    $current_test_timestamp = $timestamp[$index];
    $current_test_subject = (string)$current_test['subject'];
    $current_test_level = (string)$current_test['level'];
    foreach ($current_test->item as $item) {
      $iname = (string)$item['iname'];
      $data = (string)$item['data'];
      if (strlen($data) > 0) {
	$dataf = $udir . $data;
	if (file_exists($dataf)) {
	  $xmldoc_item = simplexml_load_file($dataf);
	  foreach ($xmldoc_item->marking->mark as $mark) {
	    $markingtable .= $current_test_timestamp . "\t" .
	      $current_test_subject . "\t" . 
	      $current_test_level . "\t" .
	      $iname . "\t" . 
	      (string)$mark['itemnumber'] . "\t" .
	      (string)$mark['alphalevel'] . "\t" .
	      $mark ."\n";
	  }
	} else {
	  exit("Failed to open file" . $dataf . "\n");
	}
      }
    }
    $prevtimestamp = $prev[$index];
    $stopcond = strlen($prevtimestamp) > 0;
    if ($stopcond) $index = array_keys($timestamp,$prevtimestamp)[0];
  } while ($stopcond);  
} else {
  exit("Failed to open the user's global xml file.\n");
}

// writing out marking table into a marking txt file
$odir_user = $odir . $user;
if (!file_exists($odir_user)) mkdir($odir_user); // this is most probably not needed in the real application
// we also generate a timestamp to be used in the name of the XML and PDF files and in the timestamp field of the XML file
$systime = time(); 
$baseName = $user . "_" .date('Ymd_H_i_s',$systime) . "_result";
$tempdir = $odir_user . "/tmp";
if (file_exists($tempdir)) rrmdir($tempdir); // if $tempdir exists we remove it (Alternatively, we could name the temporary directory based on $baseName and delete them in a cronjob...)
mkdir($tempdir);
$markingfile = $tempdir . "/" . $baseName . ".mar";
file_put_contents($markingfile,$markingtable);
// we transform the data contained in the just created marking file into an xml result file using the external R script evalMarking.R
$xmlTimestamp = date('YmdHis',$systime); // date/time of evaluation, used in the <timestamp> node of the xml file
$xmlpath = $tempdir . "/" . $baseName;
$rcmd = "$path_evalMarking -m $markingfile -t $threshold -l $maxListings -x $xmlTimestamp -f $xmlpath -a $alphalist";
//echo $rcmd;
exec($rcmd); // this one creates the XML file

// Here we parse the just created XML and create TEX files
$xmlpath_full = $xmlpath . ".xml";
if (file_exists($xmlpath_full)) {
  $tempdir = $odir_user . "/tmp";
  rrmdir($tempdir); // if $tempdir exists we remove it (Alternatively, we could name the temporary directory based on $baseName and delete them in a cronjob...)
  mkdir($tempdir);
  $xmldoc = simplexml_load_file($xmlpath_full);
  $subject = (string)$xmldoc->subject['value'];
  $level = (string)$xmldoc->level['value'];
  $pdfname = (string)$xmldoc->print['file'];
  // Looping through eval modes. 
  foreach ($xmldoc->eval as $eval) { //
    $evalmodes[(string)$eval['mode']] = $eval;
  }
  $keinbearbeitet = sizeof($evalmodes) == 0;
  $mode_names = array("A1","A2");
  $mode_strings = array(A1=>"Das kann ich!",A2=>"Das kann ich bald wenn ich noch ein wenig übe.");
  $graphics = array(A1=>"\\Check",A2=>"\\Ladder");
  foreach ($mode_names as $mode) {
    $fp = fopen($tempdir . "/" . $mode . ".tex",'w');
    if ($keinbearbeitet) {
      fwrite($fp,"Es wurden keine Aufgaben bearbeitet\n");
    } else {
      $evalmode = $evalmodes[$mode];
      //print_r($evalmode);
      $rownum = sizeof($evalmode);
      $userdescription = array();
      $example = array();
      $nBeispiel = 0;
      foreach ($evalmode->alphanode as $alphanode) {
	$userdescription[] = (string)$alphanode['userdescription'];
	$e = (string)$alphanode['example'];
	$example[] = $e;
	if ($e!="") $nBeispiel++;
      }
      $beispiel = $nBeispiel > 0;
      if ($rownum > 0) {
	fwrite($fp,"\\begin{tabular}{r");
	fwrite($fp,ifelse($beispiel,"p{.4\\textwidth}@{\hspace{2em}}!{\color{TextDark}\\vrule}@{\hspace{2em}}p{.4\\textwidth}","p{.8\\textwidth}"));
	fwrite($fp,"}\n");
	fwrite($fp,"& \\textcolor{TextStandard}{\\fontsize{20pt}{1em}\\selectfont ");
	fwrite($fp,$mode_strings[$mode]);
	fwrite($fp,"}");
	if ($beispiel) fwrite($fp," & \\textcolor{TextStandard}{\\fontsize{20pt}{1em}\\selectfont Beispiel}");
	fwrite($fp,"\\\\[-50px]\n");
	for ($i=0; $i < $rownum; $i++) {
          fwrite($fp,$graphics[$mode]);
	  fwrite($fp," & ");
	  fwrite($fp,$userdescription[$i]);
          if ($beispiel) {
	    fwrite($fp," & ");
	    fwrite($fp,$example[$i]);
	  }
          fwrite($fp,"\\\\\n");
        }
        fwrite($fp,"\\end{tabular}");
      } else {
	if ($mode=="A2") {
	  fwrite($fp,$welldone[$level]);
	}
      };
    }
    fclose($fp);
  }
  // I must create a 'settings.tex' file too
  $fp = fopen($tempdir . "/settings.tex",'w');
  fwrite($fp,"% subject\n");
  fwrite($fp,"\\toggletrue{" . $subject . "}\n");
  fwrite($fp,"% user\n");
  fwrite($fp,"\\def\\user{" . $user . "}\n");
  fwrite($fp,"% level\n");
  fwrite($fp,"\\def\\level{" . strtolower($level) . "}\n");
  fclose($fp);
  // copying template files to temporary directory 
  copy($dir_template . "/userfeedback_dev.tex",$tempdir . "/main.tex");
  foreach ($graphics_files as $graphics_file) {
    copy($dir_template . "/" . $graphics_file,$tempdir . "/" . $graphics_file);
  }
  // running pdflatex
  $wd_orig = getcwd();
  chdir($tempdir);
  exec("/usr/bin/texi2pdf main.tex");
  chdir($wd_orig);
  // copying pdf to destination folder
  copy($tempdir . "/main.pdf", $odir_user . "/" . $pdfname);
  rrmdir($tempdir); // removing temporary directory
 
  if (file_exists($xmlpath_full)) 
    {
      $file = file_get_contents($xmlpath_full);
      echo $file;
    } else {
    echo "error: not existent".$path." user:".$user." dim:".$dim." count:".$count." script:".$script." result:".$result;
  }
}

?>
