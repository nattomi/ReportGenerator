<?php
//************************************************
// load settings + function and class definitions
//************************************************

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
$user = new user('SD5AM',"2014_7_9_12_36_38"); // with one exception all tasks are solved

//***********************************************************
// transforming the 'user' object into a 'marksMatrix' object
// Normally, you do not want to edit below this line!
//***********************************************************

$performedtests = $user->performedTests(); // parsing the user's global XML file;
$RecentTest = $user->getRecentTest($performedtests); // Either the latest test or a test matching $user->test
$RecentTests = RecentSession($performedtests,$RecentTest); // starting from $RecentTest, all other referenced tests are traced down 
$marks = $user->getMarks($RecentTests); // all marks received organized into a nice table

//*************************************************************
// transforming the 'marksMatrix' object into a 'result' object
//*************************************************************

$systime = time(); 
$baseName = $user->id . "_" .date('Ymd_H_i_s',$systime) . "_result";
$pdfname = $baseName . ".pdf"; // used in the pdfname property of the result object
$xmlTimestamp = date('YmdHis',$systime); // date/time of evaluation, used in the timestamp property of the result object
$subject = $RecentTest->subject;
$level = $RecentTest->level;
$alphalist = readAlphalist($alphalist_xml); // parsing the alphalist file
if ($marks->length > 0) {
  // mode A1
  $alphaids_A1 = $marks->evalA1($threshold,0);
  $alphalist_A1 = subset_alphalist($alphalist,$alphaids_A1);
  $message_A1 = count($alphaids_A1)==0 ? $allwrong : null;
  // mode A2
  $alphaids_A2 = $marks->evalA2($threshold,2);
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

//*************************************************************
// Writing out the 'result' object into an xml file
//*************************************************************

$odir_user = $odir . $user->id;
$xmlpath = $odir_user . "/" . $baseName;
$xmlpath_full = $xmlpath . ".xml";
if (!file_exists($odir_user)) mkdir($odir_user); // this is most probably not needed in the real application
$result_xml = $result->asXML();
$result_xml->save($xmlpath_full);

//*************************************************************
// Printing the 'result' object as xml
//*************************************************************
echo $result_xml->saveXML();


//$tempdir = $odir_user . "/tmp";
//if (file_exists($tempdir)) rrmdir($tempdir); // if $tempdir exists we remove it (Alternatively, we could name the temporary directory based on $baseName and delete them in a cronjob...)
//mkdir($tempdir);


/*
// writing out marking table into a marking txt file
$odir_user = $odir . $user;
if (!file_exists($odir_user)) mkdir($odir_user); // this is most probably not needed in the real application
// we also generate a timestamp to be used in the name of the XML and PDF files and in the timestamp field of the XML file
*/
/*
$tempdir = $odir_user . "/tmp";
if (file_exists($tempdir)) rrmdir($tempdir); // if $tempdir exists we remove it (Alternatively, we could name the temporary directory based on $baseName and delete them in a cronjob...)
mkdir($tempdir);
$markingfile = $tempdir . "/" . $baseName . ".mar";
ob_start();
marks->display();
$contents = ob_get_contents();
ob_end_clean();
file_put_contents($markingfile,$contents);
// we transform the data contained in the just created marking file into an xml result file using the external R script evalMarking.R
*/
/*
$xmlpath = $odir_user . "/" . $baseName;
$rcmd = "$path_evalMarking -m $markingfile -t $threshold -l $maxListings -x $xmlTimestamp -f $xmlpath -a $alphalist";
//echo $rcmd;
exec($rcmd); // this one creates the XML file
// At first we parse the alphalist file
*/





//var_dump($result);
//echo $result->asXML()->saveXML();
//$xmlpath_full = $xmlpath . ".xml";
//$result->asXML()->save($xmlpath_full);
//echo $result->asXML()->saveXML();


/*
// Here we parse the just created XML and create TEX files
$xmlpath_full = $xmlpath . ".xml";
if (file_exists($xmlpath_full)) {
  $xmldoc_result = simplexml_load_file($xmlpath_full);
  $subject = (string)$xmldoc_result->subject['value'];
  $level = (string)$xmldoc_result->level['value'];
  $pdfname = (string)$xmldoc_result->print['file'];
  // Looping through eval modes. 
  foreach ($xmldoc_result->eval as $eval) { //
    $evalmodes[(string)$eval['mode']] = $eval;
  }
  $keinbearbeitet = sizeof($evalmodes) == 0; 
  foreach ($mode_names as $mode) {
    $fp = fopen($tempdir . "/" . $mode . ".tex",'w');
    if ($keinbearbeitet) {
      fwrite($fp,$keinbearbeitet_string . "\n");
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
  copy($dir_template . "/userfeedback.tex",$tempdir . "/main.tex");
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
  //$file = file_get_contents($xmlpath_full);
  echo $xmldoc_result->asXML();
} else {
    echo "error: not existent".$path." user:".$user." dim:".$dim." count:".$count." script:".$script." result:".$result;
  }
*/
?>
