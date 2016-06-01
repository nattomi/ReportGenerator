<?php

class render_teacher extends render {
  protected $targets = array("arrow_grey_down.png", "arrow_grey_right.png",
			     "arrow_grey_up.png", "dot_grey.png");
  
  protected function tex_settings($fname) {
    $fp = fopen($this->dir_tmp . "/" . $fname, 'w');
    
    $content = "";
    $content .= "% user\n";
    $content .= "\\def\\user{" . $this->xml->user . "}\n";
    $content .= "% date\n";
    $content .= "\\def\\date{" . $this->date . "}\n";
    $content .= "% background image\n";
    $content .= "\\newcommand\\thisbg{\mybg";
    foreach($this->xml->stats->subject as $subject) {
      $content .= "{" . $subject . "}";
    }
    $content .= "}\n";
    
    fwrite($fp, $content);
    fclose($fp);
  }

  static function eval2tex($e, $mode) {
    $subjects = array("Lesen", "Schreiben", "Sprache", "Rechnen"); // FIXME 1;

    $content = "\lhead{\large \\textcolor{white}{" . 
               $mode . "}}\\vspace*{.5em}\n";
    $content .= "\\begin{paracol}{4}\n";
    $switchc = false;
    foreach($subjects as $subject) {
      if($switchc)
	$content .= "\\switchcolumn\n";
      else
	$switchc = true;
      $content .= "\\noindent\n";
      $alphanodes = $e->xpath('alphanode[@subject="' . $subject . '"]');
      //print_r($alphanodes);
      foreach($alphanodes as $a) {
	$content .= "\\entry{"; 
	switch($a['tendency']) {
	case -1:
	  $content .= "\\arrowdown";
	  break;
	case 0:
	  $content .= "\\arrowright";
	  break;
	case 1:
	  $content .= "\\arrowup";
	  break;
	default:
	  break;
	}
	$content .= "}{" . $a['id'] . "}{" . self::sanitize($a['description']) . "}{";
	foreach($a->item as $item) {
	  $content .= "{\\scriptsize " . str_replace("_", "\_", $item);
	  if((int)$item['cm'])
	    $content .= "\\cm";
	  $content .= "}\\\\[-1ex]";
	}
	$content .= "}\n";
	
      }
      
    }
    $content .= "\\end{paracol}\n";
    return $content;
  }

  public function save_xml() {
    $dom = new DOMDocument('1.0', 'UTF-8');
    $results = $dom->appendChild($dom->createElement('data', $this->pdfname));
 
    //$dom->preserveWhiteSpace = false;
    $dom->formatOutput = true;
    $dom->save($this->dir_root . "/" . $this->xmlname);

    //echo $dom->documentElement->nodeName;
    return $dom;
    
  }

}

//FIXME 1: shouldn't be hard-coded like this;

?>