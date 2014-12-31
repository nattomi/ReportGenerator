<?php
//$user = $_POST['user']; // user id
$id = 'SD5AM';
//$test = $_POST['test']; // timestamp of the test to be evaluated (as specified in the global user file, f.i. 2014_3_3_20_32_49)
//$test = '2014_9_12_11_30_29'; // if $test is not set here then it defaults to the last test
// load settings + function and class definitions
include 'conf_student.php';
include 'functions.php';
include 'classes.php';

// MAIN
// We define wich user and (optionally) which test we wish to evaluate
//$user = new user($_POST['user']); // this is going to be the most common use case
//$user = new user('SD5AM'); // for testing/developing 
//$user = new user('SD5AM','2014_9_12_11_30_29'); // for testing/developing
$user = new user('SD5AM',"2014_9_12_11_15_17");
echo $user->id . "\n";
$performedtests = $user->performedTests(); // parsing the user's global XML file;
$RecentTest = $user->getRecentTest($performedtests); // Either the latest test or a test matching $user->test
$subject = $RecentTest->subject;
$level = $RecentTest->level;
$RecentTests = RecentSession($performedtests,$RecentTest); // starting from $RecentTest, all other referenced tests are traced down 
$marks = $user->getMarks($RecentTests); // all marks received organized into a nice table
$marks->display();
/*
$user = $user->id; // this is a dummy line so I can commit the object oriented initiative - it is to be removed later

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
ob_start();
marks->display();
$contents = ob_get_contents();
ob_end_clean();
file_put_contents($markingfile,$contents);
// we transform the data contained in the just created marking file into an xml result file using the external R script evalMarking.R
$xmlTimestamp = date('YmdHis',$systime); // date/time of evaluation, used in the <timestamp> node of the xml file
$xmlpath = $odir_user . "/" . $baseName;
$rcmd = "$path_evalMarking -m $markingfile -t $threshold -l $maxListings -x $xmlTimestamp -f $xmlpath -a $alphalist";
//echo $rcmd;
exec($rcmd); // this one creates the XML file
// At first we parse the alphalist file
$alphalist = new alphalist($alphalist);
//$alphalist->order();

//var_dump($marks->evalA1($threshold));
//var_dump($marks->evalA2($threshold));

$pdfname = $baseName . ".pdf";
$subject = "Lesen";
$level = "Einfach";
$result = new result($pdfname,$xmlTimestamp,$subject,$level);
$xmlpath_full = $xmlpath . ".xml";
//$result->asXML()->save($xmlpath_full);
//echo $result->asXML()->saveXML();
*/

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
