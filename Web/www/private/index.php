<?php
    session_start();
    if (!isset($_SESSION['email'])) header("Location: ../tfg/public/login.php");

    if (!empty($_SERVER['HTTPS']) && ('on' == $_SERVER['HTTPS'])) {
            $uri = 'https://';
    } else {
        $uri = 'http://';
    }
    $uri .= $_SERVER['HTTP_HOST'];
    header('Location: '.$uri.'/tfg/private/dashboard.php');
    exit;
?>
