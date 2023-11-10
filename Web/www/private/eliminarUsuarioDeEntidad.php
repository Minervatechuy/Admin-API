<?php
    require('../config/context.php');
    require_once('auxiliarfunctions.php');

    $entidad_id= $_POST["entidad_id"];
    $email= $_POST["email_to_delete"];

    $data= '{
        "entidad_id": "'.$entidad_id.'",
        "email": "'.$email.'"
    }';

    $url = APIURL.'deleteUsuarioEntidad';
    $result= apiQuery($data, $url)['result'];
    
    mensaje('success', 'Usuario eliminado de la entidad');
?>
<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="utf-8">
    <!-- Funcion para hacer autosubmit -->
    <script>
    window.onload = function() {
        // Una vez cargada la página, el formulario se enviara automáticamente.
        document.forms["miformulario"].submit();
    }
    </script>
</head>

<body>

    <form name="miformulario" action="editarEntidadEspecifica.php" method="POST">
        <input type="hidden" name="entidad_id" value="<?php echo $_POST["entidad_id"]; ?>">
    </form>
</body>

</html>