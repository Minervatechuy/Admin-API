<?php
    require_once('../config/context.php');
    require_once('funcionesAuxiliares.php');
    $file = "token.txt";
    $txt = fopen($file, "w") or die("Unable to open file!");
    $result= apiQuery('comprar_token', null, null)['result'];
    //$result= "YbuAaq7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb";
    //echo $result;
    file_put_contents($file, $result);
    
    fclose($txt);
    header('Content-Description: File Transfer');
    header('Content-Disposition: attachment; filename='.basename($file));
    header('Expires: 0');
    header('Cache-Control: must-revalidate');
    header('Pragma: public');
    header('Content-Length: ' . filesize($txt));
    header("Content-Type: text/plain");
    readfile($file);
?>

