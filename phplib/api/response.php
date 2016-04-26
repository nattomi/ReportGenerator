<?php

class api {
  static function response($status, $status_message, $domdocument=null) {
    $dom = new DomDocument('1.0', 'UTF-8');
    $results = $dom->appendChild($dom->createElement('response'));
    $results->appendChild($dom->createElement('status', $status));
    $results->appendChild($dom->createElement('status_message', $status_message));

    if(is_null($domdocument)) {
      $domdocument = new DomDocument('1.0', 'UTF-8');
      $domdocument->appendChild($domdocument->createElement('data'));
    }

    if($domdocument->documentElement->nodeName === 'data')
      $newdom = $domdocument;
    else {
      $newdom = new DOMDocument('1.0', 'UTF-8');
      $data = $newdom->appendChild($newdom->createElement('data'));
      foreach ($domdocument->documentElement->childNodes as $domElement){
    	$domNode = $newdom->importNode($domElement, true);
        $data->appendChild($domNode);
      }
    }
    $import = $dom->importNode($newdom->documentElement, TRUE);
    $results->appendChild($import);
    $dom->formatOutput = true;
    echo $dom->saveXML();
  }
}

?>