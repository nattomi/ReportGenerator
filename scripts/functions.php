<?php
function rrmdir($dir) { // this is for recursively deleting a folder            
  if (is_dir($dir)) {                                                           
    $objects = scandir($dir);                                                   
    foreach ($objects as $object) {                                             
      if ($object != "." && $object != "..") {                                  
        if (filetype($dir."/".$object) == "dir") rmdir($dir."/".$object); else \
unlink($dir."/".$object);                                                       
      }                                                                         
    }                                                                           
    reset($objects);                                                            
    rmdir($dir);                                                                
  }                                                                             
}

function ifelse($condition,$value_true,$value_false) { // resembles R's ifelse function
  if ($condition) {
    return $value_true; 
  } else {
    return $value_false;
  }
}
 
?>