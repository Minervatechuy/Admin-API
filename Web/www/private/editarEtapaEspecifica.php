<?php
    require('../config/context.php');
    require_once('auxiliarfunctions.php');
    session_start();
    if (!(isset($_POST["etapa_id"])))  header('Location: dashboard.php');
?>

<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Editar Calculadora</title>
    <link rel="icon" type="image/png" href="../favicon.ico" />

    <?php
        $url= APIURL.'getStageGeneralInfo';
        $etapa_id= $_POST["etapa_id"];
        $data= '{"identificador": '.$etapa_id.'}';
        $result= apiQuery($data, $url)['result'];
        $type= $result[2];
        
        $_SESSION["tmp"]= $etapa_id;
        alert("Llega, ".  $type);
        alert("Siendo de tipo, ".  $_SESSION["tmp"]);

        if ($type=='Cualificada') header("Location: ".APPPATH."/private/editarEtapaEspecificaCualificada.php");

		require_once('import.html');
		require_once('preloader.php');
		require_once('navbar.php');
		require_once('menu.php');

        if  (isset($_POST["submit_general_info"])){
            if (isset($_POST["titulo"]) AND isset($_POST["subtitulo"])){
                $titulo= $_POST["titulo"];
                $subtitulo= $_POST["subtitulo"];
                $etapa_id= $_POST["etapa_id"];
                
                // ETAPA GEOGRAFICA
                if (isset($_POST["autocomplete"]) && 
                    isset($_POST["zoom"]) && 
                    isset($_POST["latitude"]) &&
                    isset($_POST["longitude"]))
                {
                    
                    $direccion= $_POST["autocomplete"];
                    $zoom= $_POST["zoom"];
                    $latitud= $_POST["latitude"];
                    $longitud= $_POST["longitude"];
                    
                    $data= '{
                        "usuario": "'.$_SESSION["usuario"].'", 
                        "etapa_id": "'.$etapa_id.'", 
                        "titulo": "'.$titulo.'", 
                        "subtitulo": "'.$subtitulo.'",
                        "direccion": "'.$direccion.'", 
                        "zoom": "'.$zoom.'", 
                        "latitud": "'.$latitud.'", 
                        "longitud":"'.$longitud.'"
                    }';
                    $url = APIURL.'editEtapa';
                    $result= apiQuery($data, $url)['result'];
                }
                // ETAPA DISCRETA
                else if (isset($_POST["input_min_discreta"]) && 
                        isset($_POST["input_max_discreta"]) &&
                        isset($_POST["input_rangos_discreta"]) &&
                        isset($_POST["input_valor_discreta"]) )
                {
                    $min= $_POST["input_min_discreta"];
                    $max= $_POST["input_max_discreta"];
                    $valor= $_POST["input_valor_discreta"];
                    $rangos= $_POST["input_rangos_discreta"];
                    
                    $data= '{
                        "usuario": "'.$_SESSION["usuario"].'", 
                        "etapa_id": "'.$etapa_id.'", 
                        "titulo": "'.$titulo.'", 
                        "subtitulo": "'.$subtitulo.'",
                        "minimo": "'.$min.'", 
                        "maximo": "'.$max.'", 
                        "valor": "'.$valor.'", 
                        "rangos": "'.$rangos.'"
                    }';
                    $url = APIURL.'editEtapa';
                    $result= apiQuery($data, $url)['result'];
                }

                // ETAPA CONTINUA
                else if (isset($_POST["input_min_continua"]) && 
                isset($_POST["input_max_continua"]) &&
                isset($_POST["input_valor_continua"]) )
                {
                    $min= $_POST["input_min_continua"];
                    $max= $_POST["input_max_continua"];
                    $valor= $_POST["input_valor_continua"];
                    $data= '{
                        "usuario": "'.$_SESSION["usuario"].'", 
                        "etapa_id": "'.$etapa_id.'", 
                        "titulo": "'.$titulo.'", 
                        "subtitulo": "'.$subtitulo.'",
                        "minimo": "'.$min.'", 
                        "maximo": "'.$max.'", 
                        "valor_inicial": "'.$valor.'"
                    }';
                    $url = APIURL.'editEtapa';
                    $result= apiQuery($data, $url)['result'];
                }
            }
            unset($_POST["submit_general_info"]);
            redirect_by_post( [ ["token", $_POST["token"]] ], 'editCalc.php');
        }else {
            
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
                        <div class="col-sm-6">
                            <ol class="breadcrumb float-sm-right">
                                <li class="breadcrumb-item"><a href="#">Home</a></li>
                                <li class="breadcrumb-item active">Editar etapa</li>
                            </ol>
                        </div><!-- /.col -->
                    </div><!-- /.row -->
                </div><!-- /.container-fluid -->
            </div>

            <!-- Main content -->
            <?php
                $url= APIURL.'getStageGeneralInfo';
                $etapa_id= $_POST["etapa_id"];
                $data= '{"identificador": '.$etapa_id.'}';
                $result= apiQuery($data, $url)['result'];
            ?>

            <section class="content">

                <div class="card card-primary">
                    <div class="card-header">
                        <h3 class="card-title"><?php echo $result[3];?></h3>
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

                            <?php
                                $type= $result[2];
                                alert($type);
                                if ($type =='Geografica'){
                                    require_once('editarEtapaEspecificaGeografica.php');
                                }
                                else if ($type=='Discreta'){
                                    require_once('editarEtapaEspecificaDiscreta.php');
                                }
                                else if ($type=='Continua'){
                                    require_once('editarEtapaEspecificaContinua.php');
                                }
                                else if ($type=='Cualificada'){
                                    $_SESSION["tmp"]= $etapa_id;
                                    alert("Se manda, ".  $_SESSION["tmp"]);
                                    if ($type=='Cualificada') header("Location: ".APPPATH."/private/editarEtapaEspecificaCualificada.php");
                                }
                            ?>

                            <input type="hidden" value="<?php echo $_POST["etapa_id"]; ?>" name="etapa_id" />
                            <input type="hidden" value="<?php echo $_POST["token"]; ?>" name="token" />

                            <div class="submit">
                                <button type="submit" id="submit_general_info" name="submit_general_info" class="btn btn-primary">
                                    Guardar cambios
                                </button>
                            </div>
                        </div>
                    </form>
                </div>
            </section>

            <?php
            require_once('footer.php');
        ?>
        </div>


</body>

</html>