<?php
$Udir = "../data/user/"; // don't forget the trailing slash 
$odir = "/tmp/" ; // the XML and PDF files are going to be put into the corresponding subfolder whose name is identical to $user) of this directory. 
$threshold = 100; // threshold for fullfilling a competency
$maxListings = 3; // number of ability descriptions listed
$alphalist = "../data/item/alphalist/alphalist.xml"; // path to the alphalist xml file
$dir_template = "../template"; // location of template files
$path_evalMarking = "./evalMarking.R"; // path of evalMarking.R script
// Settings related to pdf generation
$mode_names = array("A1","A2"); // abbreviation of the different evaluation modes in the order they appear in the final pdf document
$mode_strings = array("A1"=>"Das kann ich!","A2"=>"Das kann ich bald wenn ich noch ein wenig übe."); // Title strings associated to the evaluation modes
$graphics = array("A1"=>"\\Check","A2"=>"\\Ladder"); // graphics command associated to the different evaluation modes.
$keinbearbeitet_string = "Es wurden keine Aufgaben bearbeitet"; // this message is displayed when no task were solved
$welldone = array("Einfach"=>"Sehr gut, Sie haben alle Aufgaben gelöst! Machen Sie weiter mit dem mittleren Niveau!", "Mittel"=>"Sehr gut, Sie haben alle Aufgaben gelöst! Machen Sie weiter mit dem schwierigen Niveau!","Schwer"=>"Sehr gut, Sie haben alle Aufgaben gelöst!"); // strings to display when all tasks were solved, sorted by dimension
?>