<?php
    require('../config/context.php');
    require_once('auxiliarfunctions.php');
    if (!(isset($_POST["etapa_id"])))  header('Location: dashboard.php');
    $etapa_id= $_POST["etapa_id"];
    $url = APIURL.'deleteEtapa';
    $data = '{"etapa_id": "'.$etapa_id.'"}';
    $result_delete= apiQuery($data, $url)['result'];
    header ('Location: '.APPPATH.'/private/editCalc.php');
?>