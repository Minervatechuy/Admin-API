<?php
    require('../config/context.php');
    require_once('auxiliarfunctions.php');
    session_start();

    if( seteados (["submit", "input_identificacion", "input_nombre", "input_telefono", "input_direccion", "input_tipo_entidad"]) ){
        $identificador= $_POST["input_identificacion"];
        $nombre= $_POST["input_nombre"];
        $telefono= $_POST["input_telefono"];
        $direccion= $_POST["input_direccion"];
        $tipo= $_POST["input_tipo_entidad"];     

        $result_crear_entidad= apiQueryPro('createEntidad', ["identificador", "nombre", "telefono", "direccion", "tipo", "descripcion", "usuario"], [$identificador, $nombre, $telefono, $direccion, $tipo, '', $_SESSION["usuario"]], 1);
        $procesado= 1;
    }
?>
<!DOCTYPE html>
<html lang="es">
<meta http-equiv="refresh" content="url=menu.php;2">

<head>
    <?php
        //if (!isset($_SESSION['email'])) header("Location: ../public/login.php");
        require_once('import.html');
        require_once('preloader.php');
        require_once('navbar.php');
        require_once('menu.php');
        
        echo "<script src='../dist/js/auto-complete.js'></script>";
        echo "<script src='../dist/js/cargar_formulario.js'></script>";
        echo "<script src='https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js'></script>";
        echo "<script src='https://maps.googleapis.com/maps/api/js?key=".GOOGLEAPI."&libraries=places&callback=initAutocomplete' async defer></script>";
        echo "<script src='../dist/js/drag&drop.js'></script>";

        if ($procesado==1) mensaje( $result_crear_entidad['tipo'], $result_crear_entidad['mensaje']); 

        ?>

    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Crear entidad</title>
    <link rel="icon" type="image/png" href="../favicon.ico" />
</head>

<body class="hold-transition sidebar-mini layout-fixed" onload= "bloquearReenvioFormulario()">

    <div class="wrapper">

        <!-- Content Wrapper. Contains page content -->
        <div class="content-wrapper">
            <!-- Content Header (Page header) -->
            <div class="content-header">
                <div class="container-fluid">
                    <div class="row mb-2">
                        <div class="col-sm-6">
                            <h1 class="m-0">Crear entidad</h1>
                        </div><!-- /.col -->
                    </div><!-- /.row -->
                </div><!-- /.container-fluid -->
            </div>

            <!-- Main content -->
            <section class="content"
                style="padding-left: 1em !important; padding-right: 1em !important; padding-bottom: 1em !important;">
                <form method="POST" action="crearEntidad.php">
                    <div class="card card-secondary" style="margin: 0 auto;">
                        <!-- card-header -->
                        <div class="card-header">
                            <h3 class="card-title">Nueva Entidad</h3>
                        </div>
                        <!-- form start -->
                        <div class="card-body">
                            <div class="form-group">
                                <label>RUT / CI</label>
                                <input type="text" class="form-control" id="input_identificacion"
                                    name="input_identificacion"
                                    value="<?php if (isset($_POST["input_identificacion"])) echo $_POST["input_identificacion"];?>"
                                    required />
                            </div>
                            <div class="form-group">
                                <label>Nombre</label>
                                <input class="form-control" id="input_nombre" name="input_nombre"
                                    value="<?php if (isset($_POST["input_nombre"])) echo $_POST["input_nombre"];?>"
                                    required />
                            </div>
                            <div class="form-group">
                                <label>Telefono</label>
                                <input type="text" class="form-control" id="input_telefono" name="input_telefono"
                                    value="<?php if (isset($_POST["input_telefono"])) echo $_POST["input_telefono"];?>"
                                    title="Introduce un numero de telefono valido y sin el prefijo."
                                    required />
                            </div>
                            <div class="form-group">
                                <label>Dirección</label>
                                <input type="text" class="form-control" id="input_direccion" name="input_direccion"
                                    value="<?php if (isset($_POST["input_direccion"])) echo $_POST["input_direccion"];?>"
                                    required />
                            </div>
                            <div class="form-group">
                                <label>Tipo de entidad</label>
                                <select class="form-control" id="input_tipo_entidad" name="input_tipo_entidad" required>
                                    <option disabled value selected="">...</option>
                                    <option
                                        <?php if (isset($_POST["input_tipo_entidad"]) && $_POST["input_tipo_entidad"]== "Particular") echo "selected";?>">
                                        Particular</option>
                                    <option
                                        <?php if (isset($_POST["input_tipo_entidad"]) && $_POST["input_tipo_entidad"]== "Autónomo") echo "selected";?>">
                                        Empresa</option>
                                    <!--<option
                                        <?php if (isset($_POST["input_tipo_entidad"]) && $_POST["input_tipo_entidad"]== "Sociedad Limitada") echo "selected";?>">
                                        Sociedad Limitada</option>
                                    <option
                                        <?php if (isset($_POST["input_tipo_entidad"]) && $_POST["input_tipo_entidad"]== "Sociedad Anónima") echo "selected";?>">
                                        Sociedad Anónima</option>
                                    <option
                                        <?php if (isset($_POST["input_tipo_entidad"]) && $_POST["input_tipo_entidad"]== "Organización sin ánimo de lucro") echo "selected";?>">
                                        Organización sin ánimo de lucro</option>
                                    <option
                                        <?php if (isset($_POST["input_tipo_entidad"]) && $_POST["input_tipo_entidad"]== "Comunidad de Vecinos") echo "selected";?>">
                                        Comunidad de Vecinos</option>
                                    <option
                                        <?php if (isset($_POST["input_tipo_entidad"]) && $_POST["input_tipo_entidad"]== "Sociedad Cooperativa") echo "selected";?>">
                                        Sociedad Cooperativa</option>-->
                                </select>

                            </div>
                            <div class="form-group">
                                <div>
                                    <button type="submit" name="submit" id="submit" class="btn btn-primary">Crear
                                        Entidad</button>
                                </div>
                            </div>
                        </div>
                </form>
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