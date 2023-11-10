<?php

require('../config/context.php');
require_once('auxiliarfunctions.php');
session_start();
?>

<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Editar Calculadora</title>
    <link rel="icon" type="image/png" href="../favicon.ico" />

    <?php
		require_once('import.html');
		require_once('preloader.php');
		require_once('navbar.php');
		require_once('menu.php');

		if (isset($_SESSION["tmp"])){
			$_POST["etapa_id"]= $_SESSION["tmp"];
			$etapa_id= $_POST["etapa_id"];
		}

		// Procedimiento para la edicion de la etapa
		if  (isset($_POST["submit_editar_etapa"])){
			if (isset($_POST["titulo"]) AND isset($_POST["subtitulo"])){
				$titulo= $_POST["titulo"];
				$subtitulo= $_POST["subtitulo"];

				$data= '{
                    "usuario": "'.$_SESSION["usuario"].'", 
                    "etapa_id": "'.$etapa_id.'", 
                    "titulo": "'.$titulo.'", 
                    "subtitulo": "'.$subtitulo.'"
                }';
				$url = APIURL.'editEtapa';
				$result= apiQuery($data, $url)['result'];
			}
		}

		if (seteados(["input_opt_nombre", "input_opt_valor", "submit_option"])){
			// Variables de formulario
			$nombre= $_POST["input_opt_nombre"];
			$valor= $_POST["input_opt_valor"];

			// Variables de entrorno
			$etapa_id= $_POST["etapa_id"];
			$usuario= $_SESSION["usuario"];

			if($_FILES!=null && $_POST!=null){

				$imgInp = file_get_contents(addslashes($_FILES['input_opt_imagen']['tmp_name']));
				$image_size = getimagesize($_FILES['input_opt_imagen']['tmp_name']);

				if($image_size==FALSE){
					$imagen = "";
				} else {
					$imagen = "data:image;base64,".base64_encode($imgInp);
				}
			} else {
				$imagen = "";
			}
			$result= apiQueryPro('insertOpcion', ["usuario", "etapa_id", "nombre", "valor", "imagen"], [$usuario, $etapa_id, $nombre, $valor, $imagen])["result"];
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
                            <h1 class="m-0">Editar etapa</h1>
                        </div><!-- /.col -->
                    </div><!-- /.row -->
                </div><!-- /.container-fluid -->
            </div>

            <!-- Main content -->

            <section class="content">
                <div class="content-fluid">
                <!-- Modificacion de datos de la etapa -->
                    <div class="row">
                        <div class="col-md-6">
                            <div class="card card-secondary">
                                <div class="card-header">
                                    <?php
                                        $url= APIURL.'getStageGeneralInfo';
                                        $identificador= $_POST["etapa_id"];
                                        $data= '{"identificador": '.$identificador.'}';
                                        $result= apiQuery($data, $url)['result'];
                                        ?>
                                    <h3 class="card-title">Modificar datos</h3>
                                </div>
                                <form method="POST">
                                    <div class="card-body">
                                        <div class="form-group">
                                            <label for="titulo">Titulo</label>
                                            <input type="text" id="titulo" name="titulo" class="form-control"
                                                value="<?php echo $result[3];?>">
                                        </div>
                                        <div class="form-group">
                                            <label for="subtitulo">Subtitulo</label>
                                            <input type="text" id="subtitulo" name="subtitulo" class="form-control"
                                                value="<?php echo $result[4];?>">
                                        </div>
                                        <div class="submit">
                                            <button type="submit" id="submit_editar_etapa" name="submit_editar_etapa"
                                                class="btn btn-primary">
                                                Editar Etapa
                                            </button>
                                        </div>
                                    </div>
                                </form>
                            </div>

                            <!-- Modificacion de opciones de la etapa -->
                            <div class="card card-secondary">
                                <!-- card-header -->
                                <div class="card-header">
                                    <h3 class="card-title">Crear opción</h3>
                                </div>
                                <!-- form start -->
                                <div class="card-body">
                                    <form method="POST" action="editarEtapaEspecificaCualificada.php" enctype="multipart/form-data">
                                        <div class="form-group">
                                            <label>Nombre de la opción</label>
                                            <input type="text" class="form-control" id="input_opt_nombre" name="input_opt_nombre"
                                                required />
                                        </div>
                                        <div class="form-group">
                                            <label>Valor de la opción</label>
                                            <input type="number" class="form-control" id="input_opt_valor" name="input_opt_valor"
                                                required />
                                        </div>
                                        <div class="form-group">
                                            <label>Imagen de la opción</label>
                                            <input type="file" class="form-control" id="input_opt_imagen" name="input_opt_imagen"
                                                style="border: 0px !important" accept="image/*" required />
                                        </div>
                                        <div class="form-group">
                                            <div class="submit_option">
                                                <button type="submit" name="submit_option" id="submit_option"
                                                    class="btn btn-primary">Crear
                                                    Opción</button>
                                            </div>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <?php require_once('editarOpciones.php'); ?>
                        </div>
                    </div>
                </div>
            </section>

        </div>
        <?php
			require_once('footer.php');
			?>
    </div>

</body>

</html>