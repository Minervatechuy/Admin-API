
<?php
    // Inicia la sesion y se verifica si el usuario esta logueado
    session_start();
    require_once('../config/context.php');

    // Si la sesion existe la borro
    if(isset($_SESSION['usuario'])){
        session_destroy();
    }

    // Redireccion a login, ya estando logeado o sin estarlo
    header("Location: ".APPLOGIN);
?>
