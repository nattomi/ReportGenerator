<?php
//********************************************************************
// load settings + function and class definitions
//********************************************************************

include 'conf_student.php';
include 'functions.php';
include 'classes.php';

//********************************************************************
// We define wich user and (optionally) which test we wish to evaluate
// by creating a new 'user' object
//********************************************************************

//$user = new user($_POST['user']); // this is going to be the most common use case
//$user = new user('SD5AM'); // for testing/developing 
//$user = new user('SD5AM','2014_9_12_11_30_29'); // for testing/developing
//$user = new user('SD5AM',"2014_9_12_11_15_17"); // test was done in more steps
//$user = new user('SD5AM',"2014_7_9_12_8_50"); // some are 0 some are 1
//$user = new user('SD5AM',"2014_9_24_12_31_13"); // in this test nothing was solved at all (data attributes are empty)
//$user = new user('SD5AM',"2014_7_9_12_36_38"); // with one exception all tasks are solved right
//$user = new user('SD5AM',"2014_9_4_16_24_0"); // everything is solved right
$user = new user('SD5AM',"2014_9_12_11_11_6"); // interrupted test

//********************************************************************
// transforming the 'user' object into a 'marksMatrix' object
// Normally, you do not want to edit below this line!
//********************************************************************

$performedtests = $user->performedTests(); // parsing the user's global XML file;
$RecentTest = $user->getRecentTest($performedtests); // Either the latest test or a test matching $user->test
$RecentTests = RecentSession($performedtests,$RecentTest); // starting from $RecentTest, all other referenced tests are traced down
$marks = $user->getMarks($RecentTests); // all marks received organized into a nice table
//print_r($marks);

//********************************************************************
// transforming the 'marksMatrix' object into a 'result' object
//********************************************************************

$systime = time(); 
$baseName = $user->id . "_" .date('Ymd_H_i_s',$systime) . "_result";
$pdfname = $baseName . ".pdf"; // used in the pdfname property of the result object
$xmlTimestamp = date('YmdHis',$systime); // date/time of evaluation, used in the timestamp property of the result object
$subject = $RecentTest->subject;
$level = $RecentTest->level;
$alphalist = readAlphalist($alphalist_xml); // parsing the alphalist file
if ($marks->length > 0) {
  // mode A1
  if($RecentTest->isInterrupted()) { //evaluation differs if a test is interrupted
    $alphaids_A1 = $marks->evalA1(0,$maxListings_A1); // in that case the threshold doesn't have to be fulfilled. Using evalA1 might be a slight overkill here (or, alternatively, evalA1 could be rewritten to handle $threshold=0 separately
    $alphaids_A2 = $marks->evalA2($threshold_A2,$maxListings_A2);   
  } else {
    $alphaids_A1 = $marks->evalA1($threshold_A1,$maxListings_A1);
    $alphaids_A2 = $marks->evalA2i($threshold_A2,$maxListings_A2);
  }
  $alphalist_A1 = subset_alphalist($alphalist,$alphaids_A1);
  $message_A1 = count($alphaids_A1)==0 ? $allwrong : null;
  // mode A2
  $alphalist_A2 = subset_alphalist($alphalist,$alphaids_A2);
  $message_A2 = count($alphaids_A2)==0 ? $welldone[$level] : null;
} else { // in this case no tasks were solved at all
  $alphalist_A1 = array();
  $message_A1 = $keinbearbeitet_string;
  $alphalist_A2 = array();
  $message_A2 = $keinbearbeitet_string;
}
$eval_A1 = new eval_("A1",$message_A1,$alphalist_A1);
$eval_A2 = new eval_("A2",$message_A2,$alphalist_A2);
$evals = array($eval_A1,$eval_A2);
$result = new result($pdfname,$xmlTimestamp,$subject,$level,$evals);

//********************************************************************
// Writing out the 'result' object into an xml file
//********************************************************************

$odir_user = $odir . $user->id;
$xmlpath = $odir_user . "/" . $baseName;
$xmlpath_full = $xmlpath . ".xml";
if (!file_exists($odir_user)) mkdir($odir_user); // this is most probably not needed in the real application
$result_xml = $result->asXML();
$result_xml->save($xmlpath_full);

//********************************************************************
// Creating a directory for holding temporary files
// associated to compiling the pdf file
//********************************************************************

$tempdir = $odir_user . "/tmp";
if (file_exists($tempdir)) rrmdir($tempdir); // if $tempdir exists we remove it (Alternatively, we could name the temporary directory based on $baseName and delete them in a cronjob...)
mkdir($tempdir);

//********************************************************************
// Translating entries of the array 'evals' into tex files
//********************************************************************

foreach ($evals as $e) {
  $e_as_tex = $e->asTex();
  $fp = fopen($tempdir . "/" . $e->mode . ".tex",'w');
  fwrite($fp, $e_as_tex);
  fclose($fp);
  //echo $e_as_tex // if you want it to be printed on screen
}

//********************************************************************
// Saving a 'settings.tex' file
//********************************************************************

$settings_tex_content = settingsTex($user->id,$subject,$level);
$fp = fopen($tempdir . "/settings.tex",'w'); 
fwrite($fp, $settings_tex_content);
fclose($fp);
//echo $settings_tex_content; // if you want it to be printed on screen


//********************************************************************
// Copying template files to the temporary directory
//********************************************************************

copy($dir_template . "/userfeedback.tex",$tempdir . "/main.tex");
foreach ($graphics_files as $graphics_file) {
  copy($dir_template . "/" . $graphics_file,$tempdir . "/" . $graphics_file);
}

//********************************************************************
// Running pdflatex
//********************************************************************

$wd_orig = getcwd();
chdir($tempdir);
exec("/usr/bin/texi2pdf main.tex");
chdir($wd_orig);
// copying pdf to destination folder
copy($tempdir . "/main.pdf", $odir_user . "/" . $pdfname);
// removing temporary directory
rrmdir($tempdir);

//********************************************************************
// Printing the 'result' object as xml
//********************************************************************

//echo $result_xml->saveXML();
?>
