#!/usr/bin/php
<?php

include '../phplib/api.php';

$ot = new otulea("../data");
foreach($ot->ls_users() as $id)
  echo $id . PHP_EOL;