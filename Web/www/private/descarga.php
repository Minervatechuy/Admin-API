<?php
    //then send the headers to force download the zip file
    header("Content-type: application/zip"); 
    header("Content-Disposition: attachment; filename=MinervaTech-Simulador.zip");
    header("Content-length: " . filesize("MinervaTech-Simulador.zip"));
    header("Pragma: no-cache"); 
    header("Expires: 0"); 
    readfile("MinervaTech-Simulador.zip");
    exit;
    header("Location: ".APPDASHBOARD);
?>