<?php

$game = file_get_contents(__DIR__.DIRECTORY_SEPARATOR.'game.json');

header("Content-Type: application/json;charset=utf-8");

print_r($game);

exit;
