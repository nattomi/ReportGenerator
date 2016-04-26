<?php

class request {
  private $api_uri;

  public function __construct($api_uri) {
    $this->api_uri = $api_uri;
  }
  
  public function send_request($data) {
    $ch = curl_init();

    curl_setopt($ch, CURLOPT_HEADER, 0);
    curl_setopt($ch, CURLOPT_URL, $this->api_uri);
    curl_setopt($ch, CURLOPT_POST, 1);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

    $string = curl_exec($ch);
    curl_close($ch);

    //$string = preg_replace('/(\>)\s*(\<)/m', '$1$2', $string);
    $xml = simplexml_load_string($string);

    return $xml;
  }
}

class pdffactory {
  private $user;
  private $testid;
  private $type;
  private $data;

  public function __construct($user, $testid, $type) {
    $this->user = $user;
    $this->testid = $testid;
    $this->type = $type;
  }

  public function get_results($request) {
    $data = array('method'=>'eval',
  		  'user'=>$this->user,
  		  'testid'=>$this->testid,
  		  'type'=>$this->type,
  		  'save'=>1);
    $response = $request->send_request(http_build_query($data));
    if((int)$response->status[0] == 200) {
      $this->data = $response->data;
    }
  }

  public function get_data() {
    return $this->data;
  }

  public function render_results($request) {
    $data = "method=render&data=" . $this->data;
    $response = $request->send_request($data);
    //print_r($response);
    if((int)$response->status[0] != 200)
      return false;
    $node = dom_import_simplexml($response->data);
    $dom = new DOMDocument('1.0', 'UTF-8');
    $node = $dom->importNode($node, true);
    $dom->appendChild($node);
    $dom->formatOutput = true;
    return $dom->saveXML($node);
  }
  
}

?>