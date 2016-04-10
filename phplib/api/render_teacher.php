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
    return "demo content";
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

?>