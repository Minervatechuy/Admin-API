<?php
    require('../config/context.php');
    require_once('auxiliarfunctions.php');

    $token= $_POST["token"];
    $url = APIURL.'deleteCalc';
    $data = '{"token": "'.$token.'"}';
    echo $token;
    $result_delete= apiQuery($data, $url)['result'];
    echo $result_delete;
    header ('Location: '.APPDASHBOARD);
?>