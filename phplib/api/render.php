<?php

class render {
  protected $xml;
  private $dir_root;
  protected $dir_tmp;
  private $dir_template;
  private $systime;
  protected $timestamp;
  protected $date; // FIXME 1
  private $basename;
  protected $pdfname;
  private $xmlname;
  private $dev_mode = false;

  public function __construct($xmldoc) {
    $this->xml = $xmldoc;
  }

  public function toggle_dev_mode() {
    $this->dev_mode = !$this->dev_mode;
  }

  public function configure_paths($paths) {
    $this->dir_root = $paths['dir_out'] . "/" . $this->xml->user;
    $this->dir_tmp = $this->dir_root . "/tmp_" . $this->xml->type;
    $this->dir_template = $paths['dir_template'];
    $this->systime = time();
    $this->timestamp = date('YmdHis', $this->systime);
    $this->date = date('d.m.Y', $this->systime);
    $this->basename = $this->xml->user . "_" .
      date('Ymd_H_i_s', $this->systime) .
      "_result_" . $this->xml->type;
    $this->pdfname = $this->basename . ".pdf";
    $this->xmlname = $this->basename . ".xml";

    if(!file_exists($this->dir_root)) {
      if($this->dev_mode)
  	mkdir($this->dir_root);
      else
  	return false;
    }

    return true;
  }

  public function render_pdf($modes) {
    if(file_exists($this->dir_tmp))
      render::rrmdir($this->dir_tmp);
    mkdir($this->dir_tmp);
    
    $this->tex_eval($modes);
    $this->tex_settings('settings.tex');
    $this->create_symlinks();
    $this->compile(getcwd());
  }

  private function tex_eval($modes) {
    foreach($this->xml->eval as $e) {
      $fp = fopen($this->dir_tmp . "/" . $e['mode'] . ".tex", 'w');
      $mode = $modes[(string)$e['mode']];
      $content = $this::eval2tex($e, $mode);
      fwrite($fp, $content);
      fclose($fp);
    }
  }

  private function create_symlinks() {
    symlink($this->dir_template . "/" . $this->xml->type . ".tex",
  	    $this->dir_tmp . "/main.tex");

    $targets = $this->targets;
    $targets[] = "logo.pdf";

    foreach($targets as $target) {
      symlink($this->dir_template . "/" . $target,
  	      $this->dir_tmp . "/" . $target);
    }

  }

  private function compile($wd) {
    chdir($this->dir_tmp);
    exec("/usr/bin/texi2pdf main.tex");
    chdir($wd);
    // copying pdf to destination folder
    copy($this->dir_tmp . "/main.pdf",
  	 $this->dir_root . "/" . $this->pdfname);
    // removing temporary directory
    if(!$this->dev_mode)
      $this::rrmdir($this->dir_tmp);
  }

  static function rrmdir($dir) { // FIXME 2
    if(is_dir($dir)) {
      $objects = scandir($dir);
      foreach($objects as $object) {
  	if($object != "." && $object != "..") {
  	  if(filetype($dir."/".$object) == "dir")
  	    rmdir($dir."/".$object);
  	  else
  	    unlink($dir."/".$object);
  	}
      }
      reset($objects);
      rmdir($dir);
    }
  }

  static function sanitize($x) {
    $x = str_replace("μ", "$\\mu$", $x);
    $x = str_replace("«","\\guillemotleft ", $x);
    $x = str_replace("»","\\guillemotright ", $x);
    return $x;
  }
  
}

// FIXME 1: maybe it's enough to define this in the child class render_teacher;

// FIXME 2: this function has nothing to do with the specific class really. Maybe its better to include it in other segments of the api.
?>