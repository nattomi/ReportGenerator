<?php

class render_student extends render {
  protected $targets = array("lea_blue_check.png","lea_blue_ladder.png",
			   "lea_green_check.png","lea_green_ladder.png",
			   "lea_red_check.png","lea_red_ladder.png",
			   "lea_yellow_check.png","lea_yellow_ladder.png");

  protected function tex_settings($fname) {
    $fp = fopen($this->dir_tmp . "/" . $fname, 'w');
    
    $content = "";
    $content .= "% user\n";
    $content .= "\\def\\user{" . $this->xml->user . "}\n";
    $content .= "% level\n";
    $content .= "\\def\\level{" . strtolower($this->xml->level) . "}\n";
    $content .= "% subject\n";
    $content .= "\\toggletrue{" . $this->xml->subject . "}\n";
        
    fwrite($fp, $content);
    fclose($fp);
  }

  static function eval2tex($e, $mode) {
    $content = "";
    $rownum = count($e->alphanode);
    $userdescription = array();
    $example = array();
    $nBeispiel = 0;
    foreach($e->alphanode as $a) {
      $userdescription[] = (string)$a['userdescription'];
      $ex = (string)$a['example'];
      $example[] = $ex;
      if($ex!="") 
	$nBeispiel++;
    }
    
    $beispiel = $nBeispiel > 0;
    if($rownum > 0) {
      $content .= "\\begin{tabular}{r";
      $content .= $beispiel ? "p{.4\\textwidth}@{\hspace{2em}}!{\color{TextDark}\\vrule}@{\hspace{2em}}p{.4\\textwidth}" : "p{.8\\textwidth}";
      $content .= "}\n";
      $content .= "& \\textcolor{TextStandard}{\\fontsize{20pt}{1em}\\selectfont ";
      $content .= $mode['title'];
      $content .= "}";
      if($beispiel) 
	$content .= " & \\textcolor{TextStandard}{\\fontsize{20pt}{1em}\\selectfont Beispiel}";
      $content .= "\\\\[-50px]\n"; 
      for($i = 0; $i < $rownum; $i++) {
     	$content .= $mode['icon'];
     	$content .= " & ";
     	$content .= $userdescription[$i];
     	if($beispiel)
     	  $content .= " & " . $example[$i];
     	$content .= "\\\\\n";
      }
      $content .= "\\end{tabular}\n";
    }
   
    //echo $content;
    return $content;
  }

  public function save_xml() {
    $dom = new DOMDocument('1.0', 'UTF-8');
    $results = $dom->appendChild($dom->createElement('results'));
    //$data = $dom->appendChild($dom->createElement('data'));
 
   
    $node = $dom->createElement('print');
    $attr = $dom->createAttribute('file');
    $attr->appendChild($dom->createTextNode($this->pdfname));
    $node->appendChild($attr);
    $results->appendChild($node);
    //$data->appendChild($node);

    $node = $dom->createElement('timestamp');
    $results->appendChild($node);
    $attr = $dom->createAttribute('order');
    $attr->appendChild($dom->createTextNode("YmdHis"));
    $results->appendChild($attr);
    $attr = $dom->createAttribute('value');
    $attr->appendChild($dom->createTextNode($this->timestamp));
    $node->appendChild($attr);

    $node = $dom->createElement('subject');
    $results->appendChild($node);
    $attr = $dom->createAttribute('value');
    $attr->appendChild($dom->createTextNode($this->xml->subject));
    $node->appendChild($attr);

    $node = $dom->createElement('level');
    $results->appendChild($node);
    $attr = $dom->createAttribute('value');
    $attr->appendChild($dom->createTextNode($this->xml->level));
    $node->appendChild($attr);

    foreach($this->xml->xpath("eval") as $node) {
      $dom_node = dom_import_simplexml($node);
      $dom_node = $dom->importNode($dom_node, true);
      $results->appendChild($dom_node);
    }

    //$dom->preserveWhiteSpace = false;
    $dom->formatOutput = true;
    $dom->save($this->dir_root . "/" . $this->xmlname);

    //echo $dom->documentElement->nodeName;
    return $dom;
    
  }

}

?>