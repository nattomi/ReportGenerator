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
?>