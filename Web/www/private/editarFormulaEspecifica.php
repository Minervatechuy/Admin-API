<?php
require('../config/context.php');
require_once('auxiliarfunctions.php');
if (!(isset($_POST["calc"])))  header('Location: dashboard.php');
?>

<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Editar Formula</title>
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


        if (isset($_POST["submit_formula"])){
            if (isset($_POST["input_formula"])){
                $formula= $_POST["input_formula"];
                $token= $_POST["calc"];
                $url= APIURL.'updateFormula';
                $data= '{"token": "'.$token.'", "formula": "'.$formula.'"}';
                $result= apiQuery($data, $url)['result'];
            }
        }
        $url = APIURL.'getStagesGeneralInfo';
        $token= $_POST["calc"];
        $data= '{"token": "'.$token.'"}';
        $result1= apiQuery($data, $url)['result'];
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
                            <h1 class="m-0">Editar Formula</h1>
                        </div><!-- /.col -->
                    </div><!-- /.row -->
                </div><!-- /.container-fluid -->
            </div>

            <!-- Main content -->
            <section class="content" style="padding-left: 1em !important; padding-right: 1em !important;">

                <div class="edit_stages card card-row card-secondary col-sm-5">
                    <div class="card-header">
                        <h3 class="card-title">
                            Informacion de datos para la formula
                        </h3>
                    </div>

                    <div class="card_stages card-body">
                        <?php
                            foreach ($result1 as $stage) {
                                echo '
                                    <div class="card card-primary collapsed-card">
                                        <div class="card-header">
                                            <h3 class="card-title">'.$stage[3].'</h3>
                                            <div class="card-tools">
                                                <button type="button" class="btn btn-tool" data-card-widget="collapse"><i
                                                        class="fas fa-plus"></i>
                                                </button>
                                            </div>
                                        </div>
                                        <!-- /.card-header -->
                                        <div class="card-body">';
                                        
                                            echo '  <p style="text-align:left;">
                                                        Valor introducido por el cliente
                                                        <span style="float:right; opacity:0.8;">
                                                            ['.$stage[0].']
                                                        </span>
                                                    </p>';
                                        
                                echo'   </div>
                                    </div>
                                ';
                            }
                        ?>
                    </div>
                </div>

                <div class="edit_stages card card-row card-primary col-sm-5">
                    <div class="card-header">
                        <h3 class="card-title">
                            Editar Formula
                        </h3>
                    </div>
                    <div class="card_stages card-body">
                        <div class="container">
                            <?php 
                                    $token= $_POST["calc"];
                                    $url = APIURL.'getCalcFormula';
                                    $data = '{"token": "'.$token.'"}';
                                    
                                    // The stored procedure is executed
                                    $result_Formula= apiQuery($data, $url)['result'];
                                    if ($result_Formula != '') {
                                        echo  '<div class="callout callout-success">
                                        <h5>Formula Activa</h5>
                                        <p>'.$result_Formula.'</p>
                                        </div>';
                                    }
                                    else {
                                        echo  '<div class="callout callout-danger">
                                        <h5>Formula Inactiva</h5>
                                        <p>
                                        No hay ninguna formula activa por favor crea una para poder hacer el calculo final.
                                        </p>
                                        </div>';
                                    }
                                    ?>

                            <form method="POST" action="editarFormulaEspecifica.php">
                                <div class="callout callout-info">
                                    <h5>Nueva Formula</h5>
                                    <input class="form-control" rows="3" name="input_formula"
                                        placeholder="Introduce formula ..." pattern="^[0-9()\]\\[\+\-*.\/]*$"
                                        title="Formula Invalida"></input>
                                </div>
                                <input type="hidden" name="calc" value="<?php echo $token; ?>">
                                <input type="submit" name="submit_formula" class="btn btn-primary"
                                    value="Guardar Formula" />
                            </form>
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