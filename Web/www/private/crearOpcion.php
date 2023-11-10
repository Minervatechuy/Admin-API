<?php
    // PROCESAMIENTO PARA LA EDICION DE LA ETAPA CUALIFICADA
    if  (isset($_POST["submit_form"])){
        if (isset($_POST["titulo"]) && isset($_POST["subtitulo"])){

            $titulo= $_POST["titulo"];
            $subtitulo= $_POST["subtitulo"];
            $etapa_id= $_POST["etapa_id"];
            
            $data= '{
                "usuario": "'.$_SESSION["usuario"].'", 
                "identificador": "'.$etapa_id.'", 
                "titulo": "'.$titulo.'", 
                "subtitulo": "'.$subtitulo.'"
            }';
            $url = APIURL.'editEtapa';
            $result= apiQuery($data, $url)['result'];
        }
    }
		

    if ( isset($_POST["submit_option"]) && isset($_POST["input_opt_nombre"]) && isset($_POST["input_opt_valor"]) ){
        // Variables de formulario
        $nombre= $_POST["input_opt_nombre"];
        $valor= $_POST["input_opt_valor"];
        
        // The profile image is processed
        $imagen= file_get_contents(addslashes($_FILES['input_opt_imagen']['tmp_name']));
        $image_size = getimagesize($_FILES['input_opt_imagen']['tmp_name']);
        if($image_size==FALSE) $image = "";
        else $imagen = base64_encode($imagen);
        
        // Variables de entrorno
        $etapa_id= $_POST["etapa_id"];
        $usuario= $_SESSION["usuario"];
        
        $url= APIURL.'insertOpcion';
        $data= '{
            "usuario": "'.$usuario.'", 
            "etapa_id": "'.$etapa_id.'",
            "nombre": "'.$nombre.'", 
            "valor": "'.$valor.'",
            "imagen": "'.$imagen.'"
        }'; 
        $result= apiQuery($data, $url)['result'];
        $_SESSION["tmp"]= $etapa_id;
        header('Location: '.APPPATH.'/tfg/private/editarEtapaEspecificaCualificada.php');
    }
    unset($_POST["submit_form"]);
    unset($_POST["titulo"]);
    unset($_POST["subtitulo"]);
?>

<form method="POST" action="editarEtapaEspecificaCualificada.php" enctype="multipart/form-data">
    <div class="card card-primary">
        <!-- card-header -->
        <div class="card-header">
            <h3 class="card-title">Crear opción</h3>
        </div>
        <!-- form start -->
        <div class="card-body">
            <div class="form-group">
                <label>Nombre de la opción</label>
                <input type="text" class="form-control" id="input_opt_nombre" name="input_opt_nombre" required/>
            </div>
            <div class="form-group">
                <label>Valor de la opción</label>
                <input type="number" class="form-control" id="input_opt_valor" name="input_opt_valor" required/>
            </div>
            <div class="form-group">
                <label>Imagen de la opción</label>
                <input type="file" class="form-control" id="input_opt_imagen" name="input_opt_imagen"
                    style="border: 0px !important"/>
            </div>
            <div class="form-group">
                <div class="submit_option">
                    <button type="submit" name="submit_option" id="submit_option" class="btn btn-primary">Crear
                        Opción</button>
                </div>
            </div>
        </div>
</form>