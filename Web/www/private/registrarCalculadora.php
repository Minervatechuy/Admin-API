<?php
require('../config/context.php');
require_once('auxiliarfunctions.php');

session_start();
$procesado=0;
if(
    isset($_POST["submit"]) &&
    isset($_POST["input_nombre"]) &&
    isset($_POST["input_token"]) &&
    isset($_POST["input_url"]) &&
    isset($_POST["input_entidad"])
){
    
    $nombre= $_POST["input_nombre"];
    $token= $_POST["input_token"];
    $entidad= $_POST["input_entidad"];
    $email = $_SESSION["usuario"];
    $url= $_POST["input_url"];
    $https = substr("$webUrl", 0, 8);
    $http = substr("$webUrl", 0, 7);
    if ($https=="https://")$webUrl= "www.".substr("$webUrl", 8, strlen($webUrl));
    else if($http=="http://")$webUrl= "www.".substr("$webUrl", 7, strlen($webUrl));

    $IP = gethostbyname($webUrl);
    
    $result_create_calculator= apiQueryPro('createCalculator', ["token", "url", "entidad", "nombre", "email", "ip"], [$token,$url,$entidad,$nombre,$email,$ip]);
    $procesado= 1;
    
}
?>
<!DOCTYPE html>
<html lang="es">
<meta http-equiv="refresh" content="url=menu.php;2">
<link rel="icon" type="image/png" href="../favicon.ico" />

<head>
    <?php
        require_once('auxiliarfunctions.php');
        require_once('import.html');
        require_once('preloader.php');
        require_once('navbar.php');
        require_once('menu.php');
    ?>

    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Registrar Simulador</title>

        <?php

		echo "<script src='../dist/js/auto-complete.js'></script>";
		echo "<script src='../dist/js/cargar_formulario.js'></script>";
		echo "<script src='https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js'></script>";
		echo "<script src='https://maps.googleapis.com/maps/api/js?key=".GOOGLEAPI."&libraries=places&callback=initAutocomplete' async defer></script>";
        echo "<script src='../dist/js/drag&drop.js'></script>";

        if ($procesado==1) mensaje( $result_create_calculator['tipo'], $result_create_calculator['mensaje']); 

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
                            <h1 class="m-0">Registrar Simulador</h1>
                        </div><!-- /.col -->
                    </div><!-- /.row -->
                </div><!-- /.container-fluid -->
            </div>

            <!-- Main content -->
            <section class="content" style="padding-left: 1em !important; padding-right: 1em !important;">
                <div class="card card-secondary">
                    <!-- card-header -->
                    <div class="card-header">
                        <h3 class="card-title">Nuevo Simulador</h3>
                    </div>
                    <!-- form start -->
                    <form method="POST" action="registrarCalculadora.php" enctype="multipart/form-data">
                        <div class="card-body">
                            <div class="form-group">
                                <label>Nombre</label>
                                <input type="text" class="form-control" id="input_nombre" name="input_nombre"
                                    value="<?php if (isset($_POST["input_nombre"])) echo $_POST["input_nombre"];?>"
                                    required />
                            </div>
                            <div class="form-group">
                                <label>Token</label>
                                <input class="form-control" id="input_token" name="input_token"
                                    value="<?php if (isset($_POST["input_token"])) echo $_POST["input_token"];?>"
                                    required />
                            </div>
                            <div class="form-group">
                                <label>URL (Lugar exacto donde se usara el simulador)</label>
                                <input type="text" class="form-control" id="input_url" name="input_url"
                                    value="<?php if (isset($_POST["input_url"])) echo $_POST["input_url"];?>"
                                    pattern="[Hh][Tt][Tt][Pp][Ss]?:\/\/(?:(?:[a-zA-Z\u00a1-\uffff0-9]+-?)*[a-zA-Z\u00a1-\uffff0-9]+)(?:\.(?:[a-zA-Z\u00a1-\uffff0-9]+-?)*[a-zA-Z\u00a1-\uffff0-9]+)*(?:\.(?:[a-zA-Z\u00a1-\uffff]{2,}))(?::\d{2,5})?(?:\/[^\s]*)?"
                                    title="Tiene que ser una url completa." required />
                            </div>
                            <div class="form-group">
                                <label>Entidad</label>
                                <select class="form-control" required id="entidad" name="input_entidad">
                                    <option selected disabled value="">...</option>
                                    <?php
                                        $usuario= $_SESSION["usuario"];
                                        $url = APIURL.'getUserEntities';
                                        $data = '{"usuario": "'.$usuario.'"}';
                                        $result= apiQuery($data, $url)['result'];
    
                                        foreach ($result as $entidad) {
                                            $nif = $entidad[5];
                                            if (isset($_POST["input_entidad"]) && $entidad[0].' ['.$nif.']' == $_POST["input_entidad"]) {
                                                echo '<option selected value='.$nif.'>'.$entidad[0].' ['.$nif.']</option>';
                                            }
                                            echo '<option value='.$nif.'>'.$entidad[0].' ['.$nif.']</option>';
                                        }
                                    ?>
                                </select>

                            </div>
                            <div class="form-group">
                                <div class="submit_option">
                                    <button type="submit" name="submit" id="submit" class="btn btn-primary">Crear
                                        Simulador</button>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>
            </section>
            <!-- /.content -->
        </div>

        <?php
	require_once('footer.php');
			?>
    </div>

</body>

</html>