<?php
    $entidad_id= $_POST["entidad_id"];
    $url = APIURL.'deleteEntidad';
    $data = '{"entidad_id": "'.$entidad_id.'"}';
    $result_delete= apiQuery($data, $url)['result'];
    header ('Location: '.APPDASHBOARD);
?>