<?php
    require('../config/context.php');
    require_once('auxiliarfunctions.php');
    session_start();

    $procesado_edit_entidad=0;
    $procesado_add_usuario=0;

    // Se procesa el formulario de la edicion de la entidad
    if( seteados(["submit_edit", "input_identificacion", "input_nombre", "input_telefono", "input_direccion", "input_tipo_entidad"])){
        $identificador= $_POST["input_identificacion"];
        $nombre= $_POST["input_nombre"];
        $telefono= $_POST["input_telefono"];
        $direccion= $_POST["input_direccion"];
        $entidad= $_POST["input_tipo_entidad"];
        $descripcion= "Sin descripcion";
        
        $result_edit_entidad= apiQueryPro('editEntidad', 
                            ["identificador", "nombre", "telefono", "direccion", "tipo", "descripcion", "usuario"], 
                            [$identificador, $nombre, $telefono, $direccion, $entidad, $descripcion, $_SESSION["usuario"]],
                            1 );
        $tipo_edit_entidad= $result_edit_entidad['tipo'];
        $msg_edit_entidad= $result_edit_entidad['mensaje'];
        $procesado_edit_entidad=1;
    }

    // Se procesa el formulario de añadir u usuario a la entidad
    if (seteados(["submit_add_user", "input_email"]))  {
        $result_add_usuario= apiQueryPro(   'addUsuarioEntidad', 
                                                ['new_user_email', 'entidad_id'], 
                                                [ $_POST["input_email"], $_POST["entidad_id"]],
                                                1 );
        $tipo_add_usuario= $result_add_usuario['tipo'];
        $msg_add_usuario= $result_add_usuario['mensaje'];
        $procesado_add_usuario=1;
    }

    // Se obtiene la informacion de la entidad
    $result= apiQueryPro('getEntidad', ["entidad_id"], [$_POST["entidad_id"]])['result'];
    $identificador= $result[0];
    $nombre= $result[1];
    $telefono= $result[2];
    $direccion= $result[3];
    $tipo_entidad= $result[4];
    $descripcion= $result[6];

    // Se obtiene la iformacion de los compañeros de la entidad
    $compañeros= apiQueryPro('getUsuariosEntidad', ["entidad_id", "email"], [$_POST["entidad_id"], $_SESSION["usuario"]])["result"];
    
?>
<!DOCTYPE html>
<html lang="es">
<meta http-equiv="refresh" content="url=menu.php;2">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Editar entidad</title>
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
        
        
        // Mensajes de error
        if ($procesado_edit_entidad==1) mensaje($tipo_edit_entidad, $msg_edit_entidad);
        if ($procesado_add_usuario==1)  mensaje($tipo_add_usuario, $msg_add_usuario);
    ?>
    <script>
    function formularios() {
        if (document.getElementById("form_edit").classList.contains('mostrar')) {

            document.getElementById("form_edit").classList.remove('mostrar');
            document.getElementById("form_edit").classList.add('ocultar');

            document.getElementById("form_see").classList.remove('ocultar');
            document.getElementById("form_see").classList.add('mostrar');
        } else {
            document.getElementById("form_see").classList.remove('mostrar');
            document.getElementById("form_see").classList.add('ocultar');

            document.getElementById("form_edit").classList.remove('ocultar');
            document.getElementById("form_edit").classList.add('mostrar')
        }
    }
    </script>


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
                            <h1 class="m-0">Editar entidad - <?php echo $nombre; ?></h1>
                        </div><!-- /.col -->
                    </div><!-- /.row -->
                </div><!-- /.container-fluid -->
            </div>

            <!-- Main content -->
            <section class="content" style="padding-left: 1em !important; padding-right: 1em !important;">
                <div class="container-fluid">
                    <div class="row">
                        <div class="col-md-6">
                            <!-- Div para la edicion, modificacion y borrado de entidades -->
                            <div class="card card-secondary">
                                <!-- card-header -->
                                <div class="card-header">
                                    <h3 class="card-title">Modificar Datos</h3>

                                    <div class="card-tools">
                                        <form method="POST" action="eliminarEntidadEspecifica.php">
                                            <input type="hidden" value="<?php echo $_POST["entidad_id"]; ?>"
                                                name="entidad_id">
                                            <button type="submit_edit" class="btn btn-tool">
                                                <i class="fas fa-trash"></i>
                                            </button>
                                        </form>
                                    </div>

                                    <div class="card-tools" style="margin-right: 1em;">
                                        <button type="submit_edit" class="btn btn-tool" onclick="formularios()">
                                            <i class="fas fa-pen"></i>
                                        </button>
                                    </div>

                                </div>

                                <!-- Formulario para la edicion-->
                                <div class="ocultar" id="form_edit">
                                    <form method="POST" action="editarEntidadEspecifica.php">
                                        <!-- form start -->
                                        <div class="card-body">
                                            <div class="form-group">
                                                <label>RUT / CI</label>
                                                <input type="text" class="form-control" id="input_identificacion"
                                                    name="input_identificacion" value="<?php echo $identificador;?>"
                                                    readonly required />
                                            </div>
                                            <div class="form-group">
                                                <label>Nombre</label>
                                                <input class="form-control" id="input_nombre" name="input_nombre"
                                                    value="<?php echo $nombre;?>" required />
                                            </div>
                                            <div class="form-group">
                                                <label>Telefono</label>
                                                <input type="text" class="form-control" id="input_telefono"
                                                    name="input_telefono" value="<?php echo $telefono;?>" required />
                                            </div>
                                            <div class="form-group">
                                                <label>Dirección</label>
                                                <input type="text" class="form-control" id="input_direccion"
                                                    name="input_direccion" value="<?php  echo $direccion;?>" required />
                                            </div>
                                            <div class="form-group">
                                                <label>Tipo de entidad</label>
                                                <select class="form-control" id="input_tipo_entidad"
                                                    name="input_tipo_entidad" required>
                                                    <option disabled selected value="">...</option>
                                                    <option value="Particular"
                                                        <?php if ($tipo_entidad=="Particular") echo "selected";?>>
                                                        Particular</option>
                                                    <option value="Empresa"
                                                        <?php if ($tipo_entidad=="Autónomo") echo "selected";?>>
                                                        Empresa</option>
                                                    <!--<option value="Sociedad Limitada"
                                                        <?php if ($tipo_entidad=="Sociedad Limitada") echo "selected";?>>
                                                        Sociedad
                                                        Limitada
                                                    </option>
                                                    <option value="Sociedad Anónima"
                                                        <?php if ($tipo_entidad=="Sociedad Anónima") echo "selected";?>>
                                                        Sociedad
                                                        Anónima
                                                    </option>
                                                    <option value="Organización sin ánimo de lucro"
                                                        <?php if ($tipo_entidad=="Organización sin ánimo de lucro") echo "selected";?>>
                                                        Organización sin ánimo de lucro</option>
                                                    <option value="Comunidad de Vecinos"
                                                        <?php if ($tipo_entidad=="Comunidad de Vecinos") echo "selected";?>>
                                                        Comunidad de
                                                        Vecinos</option>
                                                    <option value="Sociedad Cooperativa"
                                                        <?php if ($tipo_entidad=="Sociedad Cooperativa") echo "selected";?>>
                                                        Sociedad
                                                        Cooperativa</option>-->
                                                </select>
                                            </div>
                                            <input hidden readonly value="<?php echo $_POST["entidad_id"];?>"
                                                name="entidad_id">
                                            <div class="form-group">
                                                <div>
                                                    <button type="submit" name="submit_edit" id="submit_edit"
                                                        class="btn btn-primary">Guardar
                                                        Entidad</button>
                                                </div>
                                            </div>
                                        </div>
                                    </form>
                                </div>


                                <!-- Formulario para la vista-->
                                <div class="mostrar" id="form_see">
                                    <!-- form start -->
                                    <div class="card-body">
                                        <div class="form-group">
                                            <label>RUT / CI</label>
                                            <input type="text" class="form-control" id="input_identificacion"
                                                name="input_identificacion" value="<?php echo $identificador;?>"
                                                readonly required />
                                        </div>
                                        <div class="form-group">
                                            <label>Nombre</label>
                                            <input class="form-control" id="input_nombre" name="input_nombre"
                                                value="<?php echo $nombre;?>" readonly required />
                                        </div>
                                        <div class="form-group">
                                            <label>Telefono</label>
                                            <input type="text" class="form-control" id="input_telefono"
                                                name="input_telefono" value="<?php echo $telefono;?>" readonly
                                                required />
                                        </div>
                                        <div class="form-group">
                                            <label>Dirección</label>
                                            <input type="text" class="form-control" id="input_direccion"
                                                name="input_direccion" value="<?php  echo $direccion;?>" readonly
                                                required />
                                        </div>
                                        <div class="form-group">
                                            <label>Tipo de entidad</label>
                                            <input type="text" class="form-control" id="input_direccion"
                                                name="input_direccion" value="<?php  echo $tipo_entidad;?>" readonly
                                                required />
                                        </div>
                                        <input hidden readonly value="<?php echo $_POST["entidad_id"];?>"
                                            name="entidad_id">
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <!-- Div para añadir un usuario a una entidad -->
                            <div class="card card-secondary">
                                <!-- card-header -->
                                <div class="card-header">
                                    <h3 class="card-title">Añadir Usuario a Entidad</h3>
                                </div>

                                <form method="POST" action="editarEntidadEspecifica.php">
                                    <!-- form start -->
                                    <div class="card-body">
                                        <div class="form-group">
                                            <label>Email</label>
                                            <input class="form-control" id="input_email" name="input_email"
                                                value="<?php if (isset($_POST["input_email"])) echo $_POST["input_email"];?>"
                                                required />
                                        </div>

                                        <input hidden readonly value="<?php echo $_POST["entidad_id"];?>"
                                            name="entidad_id">
                                        <div class="form-group">
                                            <div>
                                                <button type="submit" name="submit_add_user" id="submit_add_user"
                                                    class="btn btn-primary">Añadir usuario</button>
                                            </div>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <!-- Div para mostrar los usuarios de una entidad -->
                            <div id="usuarios_entidad">
                                <div class="card card-row card-secondary">
                                    <div class="card-header">
                                        <h3 class="card-title">
                                            Usuarios entidad
                                        </h3>
                                    </div>
                                    <div class="card_stages card-body">
                                        <?php
                                        $count_compañeros=0;
                                        foreach($compañeros as $compañero){
                                            $count_compañeros++;
                                            echo ' 
                                                        <div class="box">
                                                            <div class="card_stage card-body" style="padding-top: 0.3rem !important; padding-bottom: 0rem !important;">
                                                                <div class="card card-primary card-outline">
                                                                    <div class="card-header">
                                                                        <div class="card-tools">
                                                                            <form method="POST" action="eliminarUsuarioDeEntidad.php">
                                                                                <input type="hidden" value="'.$identificador.'" name="entidad_id"/>
                                                                                <input type="hidden" value="'.$compañero[0].'" name="email_to_delete"/>
                                                                                <button type="submit_edit" class="btn btn-tool">
                                                                                    <i class="fas fa-trash"></i>
                                                                                </button>
                                                                            </form>
                                                                        </div>
                                                                        <h5 class="card-title"> '.$compañero[2].'</h5>
                                                                        <div class="btn btn-tool btn-link"
                                                                            style="position: absolute; right: 4em; top: 1.5em;">'.$compañero[0].'</div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                    </div>';
                                            }
                                            if ($count_compañeros==0) {
                                                echo '  <script type="text/javascript">
                                                            document.getElementById("usuarios_entidad").style.display = "none";
                                                        </script>';
                                            }else{
                                                echo '<script type="text/javascript">
                                                            document.getElementById("usuarios_entidad").style.display = "block";
                                                </script>';
                                            }
                                    ?>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- Div para mostrar los ultimos presupuestos de las calculadoras de la entidad -->
                <div class="card card-secondary" id="ultimos_presupuestos">
                    <div class="card-header">
                        <h3 class="card-title">Ultimos Presupuestos</h3>
                    </div>

                    <div class="card-body">
                        <table class="table table-bordered">
                            <thead>
                                <tr>
                                    <th>Simulador</th>
                                    <th>Fecha</th>
                                    <th>Email Cliente</th>
                                    <th>Telefono</th>
                                    <th>Nombre</th>
                                    <th>Resultado</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php
                                        $result_entidad_info= apiQueryPro('get_presupuestos_entidad', ['entidad_id'], [$_POST["entidad_id"]])['result'];
                    
                                        $count_presupuestos= 0;
                                        foreach ($result_entidad_info as $presupuesto) {
                                            $count_presupuestos++;
                                            if ($presupuesto[5]==NULL) $resultado= $presupuesto[3];
                                            else $resultado= "Sin finalizar";
                                            echo '
                                            <tr>
                                                <td>'.$presupuesto[2].'</td>
                                                <td>'.$presupuesto[9].'</td>
                                                <td>'.$presupuesto[6].'</td>
                                                <td>'.$presupuesto[7].'</td>
                                                <td>'.$presupuesto[8].'</td>
                                                <td>'.$resultado.'</td>
                                            </tr>';
                                        }
                                        if ($count_presupuestos==0) {
                                            echo '  <script type="text/javascript">
                                                        document.getElementById("ultimos_presupuestos").style.display = "none";
                                                    </script>';
                                        }else{
                                            echo '  <script type="text/javascript">
                                                        document.getElementById("ultimos_presupuestos").style.display = "block";
                                                    </script>';
                                        }
                                    ?>
                            </tbody>
                        </table>
                    </div>

                </div>
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