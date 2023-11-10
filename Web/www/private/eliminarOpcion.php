<?php
    require('../config/context.php');
    require_once('auxiliarfunctions.php');

    $opcion_id= $_POST["opcion_id"];
    $url = APIURL.'deleteOpcion';
    $data = '{"opcion_id": "'.$opcion_id.'"}';
    $result_delete= apiQuery($data, $url)['result'];
    $_POST["opcion_id"]= $opcion_id;
    alert("Elimina etapa con id ".$_POST["opcion_id"]);
    $_SESSION["tmp"]= $etapa_id;
    alert("Se manda, ".  $_SESSION["tmp"]);
    header("Location: ".APPPATH."/private/editarEtapaEspecificaCualificada.php");
?>