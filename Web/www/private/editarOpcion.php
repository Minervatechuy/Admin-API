<?php
require('../config/context.php');
require_once('auxiliarfunctions.php');
if (!(isset($_POST["opcion_id"])))  header('Location: dashboard.php');
?>


<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Editar Simulador</title>
    <link rel="icon" type="image/png" href="../favicon.ico" />

    <?php

		require_once('import.html');
		require_once('preloader.php');
		require_once('navbar.php');
		require_once('menu.php');

		echo "<script src='../dist/js/auto-complete.js'></script>";
		echo "<script src='../dist/js/cargar_formulario.js'></script>";
		echo "<script src='https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js'></script>";
		echo "<script src='https://maps.googleapis.com/maps/api/js?key=".GOOGLEAPI."&libraries=places&callback=initAutocomplete' async defer></script>";
        echo "<script src='../dist/js/drag&drop.js'></script>";

    

// PROCESAMIENTO PARA LA EDICION DE UNA OPCIÓN
    if (
        isset($_POST["submit_option"]) AND
        isset($_POST["input_opt_nombre"]) AND
        isset($_POST["input_opt_valor"])
    ){
        // Variables de formulario
        $nombre= $_POST["input_opt_nombre"];
        $valor= $_POST["input_opt_valor"];
        

        $imagen= file_get_contents(addslashes($_FILES['imagen_nueva']['tmp_name']));
        $image_size = getimagesize($_FILES['imagen_nueva']['tmp_name']);
        if($image_size==FALSE) $image = "";
        else $imagen = base64_encode($imagen);

        if ($imagen=='') $imagen=$imagen_antigua;

        if ($imagen_nueva=="") $imagen_nueva= $imagen_antigua;
        // Variables de entrorno
        $etapa_id=$_POST["opcion_id"];
        $usuario= $_SESSION["usuario"];
        
        $url= APIURL.'editOpcion';
        $data= '{
            "usuario": "'.$usuario.'", 
            "etapa_id": "'.$etapa_id.'",
            "nombre": "'.$nombre.'", 
            "valor": "'.$valor.'",
            "imagen": "'.$imagen.'"
        }'; 
        $result= apiQuery($data, $url)['result'];
    }
    ?>

</head>

<body class="hold-transition sidebar-mini layout-fixed">


    <div class="wrapper">

        <!-- Content Wrapper. Contains page content -->
        <div class="content-wrapper">
            <!-- Content Header (Page header) -->
            <div class="content-header">
                <div class="container-fluid">

                    <div class="row mb-2">
                        <div class="col-sm-6">
                            <h1 class="m-0">Editar Opción</h1>
                        </div><!-- /.col -->
                    </div><!-- /.row -->
                </div><!-- /.container-fluid -->
            </div>

            <?php
                $url= APIURL.'getOpcion';
                $identificador=$_POST["opcion_id"];
                $data= '{"identificador": '.$identificador.'}';
                $result_stage_info= apiQuery($data, $url)['result'];
            ?>
            <!-- Main content -->
            <section class="content" style="padding-left: 1em !important; padding-right: 1em !important;">
                <form method="POST" action="editarOpcion.php" enctype="multipart/form-data">
                    <div class="card card-secondary">
                        <!-- card-header -->
                        <div class="card-header">
                            <h3 class="card-title">Editar Opción</h3>
                        </div>
                        <!-- form start -->
                        <div class="card-body">
                            <div class="form-group">
                                <label>Nombre de la opción</label>
                                <input type="text" class="form-control" id="input_opt_nombre" name="input_opt_nombre"
                                    required value="<?php echo $result_stage_info[0][3]?>" />
                            </div>
                            <div class="form-group">
                                <label>Valor de la opción</label>
                                <input type="number" class="form-control" id="input_opt_valor" name="input_opt_valor"
                                    required value="<?php echo $result_stage_info[1][3]?>" />
                            </div>
                            

                            <?php 
                                if ($result_stage_info[2][4]!='') {
                                    $imagen_antigua = $result_stage_info[2][4];
                                    // alert($imagen_antigua);
                                    echo'   <label>Imagen actual</label>
                                            <br/>
                                            <img src="'.$imagen_antigua.'"alt="Imagen antigua" width=200px>
                                            <br/>
                                            <br/>';
                                }
                            ?>
                            <div class="form-group">
                                <label>Insertar nueva imagen</label>
                                <input type="file" class="form-control" id="imagen_nueva" name="imagen_nueva"
                                    style="border: 0px !important" />
                            </div>

                            <input type="hidden" value="<?php echo$_POST["opcion_id"]; ?>" name="etapa_id" />
                            
                            <div class="form-group">
                                <div class="submit_option">
                                    <button type="submit" name="submit_option" id="submit_option"
                                        class="btn btn-primary">
                                        Editar Opción
                                    </button>
                                </div>
                            </div>
                        </div>
                </form>
            </section>
            <!-- /.content -->
        </div>

        <?php
            require_once('footer.php');
        ?>
    </div>

</body>

</html>