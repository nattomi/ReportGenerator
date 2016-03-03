#!/usr/bin/php
<?php

include '../phplib/config.php';
include '../phplib/api.php';

$ot = new otulea(config::DIR_DATA);
foreach($ot->ls_users() as $id)
  echo $id . PHP_EOL;