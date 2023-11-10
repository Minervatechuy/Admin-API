
<?php
    require('../config/context.php');
    require_once('auxiliarfunctions.php');

    $entidad_id= $_POST["entidad_id"];
    $url = APIURL.'deleteEntidad';
    $data = '{"entidad_id": "'.$entidad_id.'"}';
    $result_delete= apiQuery($data, $url)['result'];
    alert("ID: ".$entidad_id);
    // FIXME: Mandar a editar calculadora
    header ('Location: '.APPPATH.'/tfg/'.APPDASHBOARD);
?>