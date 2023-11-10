<?php
    require_once('../config/context.php');
    require_once('auxiliarfunctions.php');

    session_start();
    if (!(isset($_POST["token"]))) $_POST["token"]= $_SESSION["temp_calc_token"];
    else {
        $_SESSION["temp_calc_token"]= $_POST["token"];
    }
    // Procecimiento para editar la posicion de una etapa
    $url = APIURL.'getStagesGeneralInfo';
    $token= $_POST["token"];
    $data= '{"token": "'.$token.'"}';
    $result1= apiQuery($data, $url)['result'];

    
    if (isset($_POST["submit_edit_pos_calc"])){
        foreach($result1 as $stage){
            if (isset($_POST["stageId_".$stage[0]])){
                $url= APIURL.'editStagePos';
                $stage_id= $stage[0];
                $form_id= "stageId_$stage[0]";
                $pos= $_POST[$form_id];
                $data= '{\'form_id\': \'".$form_id."\', \"pos\': ".$pos."}';
                $data= '{"stage_id": "'.$stage_id.'", "pos": "'.$pos.'"}';
                // TODO: Falta mostrar los mensajes
                $result_edit_pos_calc= apiQuery($data, $url)['result'];
            }
        }
    }
    // Procesamiento para crear una etapa
    $etapa_creada= 0;
    $notValidInsertEtapaDiscreta=0;
    if (isset($_POST["submit"]) AND (isset($_POST["tipo_etapa"])) ) {
        $tipo_etapa= $_POST["tipo_etapa"];
        if ($tipo_etapa!="Sin etapa"){
            if (isset($_SESSION["usuario"]) AND isset($_POST["titulo"]) AND isset($_POST["subtitulo"])){
                $url = APIURL.'createStage';
                $usuario= $_SESSION["usuario"];
                $token= $_POST["token"];
                $titulo= $_POST["titulo"];
                $subtitulo= $_POST["subtitulo"];
                
                if($tipo_etapa=="Geografica" AND isset($_POST["autocomplete"]) AND isset($_POST["zoom"])){
                    $direccion= $_POST["autocomplete"];
                    $zoom= $_POST["zoom"];
                    $latitud= $_POST["latitude"];
                    $longitud= $_POST["longitude"];
                    
                    $data= '{
                        "usuario": "'.$usuario.'", 
                        "token": "'.$token.'", 
                        "tipo": "'.$tipo_etapa.'",  
                        "titulo": "'.$titulo.'", 
                        "subtitulo": "'.$subtitulo.'",
                        "direccion": "'.$direccion.'", 
                        "zoom": "'.$zoom.'", 
                        "latitud": "'.$latitud.'", 
                        "longitud":"'.$longitud.'"}';
                        $result= apiQuery($data, $url)['result'];
                }
                
                elseif($tipo_etapa=="Cualificada"){
                    $data= '{
                        "usuario": "'.$usuario.'", 
                        "token": "'.$token.'", 
                        "tipo": "'.$tipo_etapa.'",  
                        "titulo": "'.$titulo.'", 
                        "subtitulo": "'.$subtitulo.'"
                    }';
                        
                        $APIresult= apiQuery($data, $url);
                        $etapa_id= $APIresult["id_etapa"];
                        $data_opcion= '{
                            "id_etapa": "'.$id_etapa.'", 
                            "imagen": "'.$imagen.'", 
                            "texto": "'.$texto.'", 
                            "valor": "'.$valor.'"}';  
                            //header('Location: '.$APPPATH.'/private/crearOpcion.php');
                    }
                    
                elseif(($tipo_etapa=="Continua") AND 
                        isset($_POST["minimo"]) AND 
                        isset($_POST["maximo"]) AND 
                        isset($_POST["valor_inicial"])){

                    $valor_inicial= $_POST["valor_inicial"];
                    $titulo= $_POST["titulo"];
                    $maximo= $_POST["maximo"];
                    $minimo= $_POST["minimo"];
                    $data= '{
                        "usuario": "'.$usuario.'", 
                        "token": "'.$token.'", 
                        "tipo": "'.$tipo_etapa.'",  
                        "titulo": "'.$titulo.'", 
                        "subtitulo": "'.$subtitulo.'", 
                        "maximo": "'.$maximo.'", 
                        "minimo": "'.$minimo.'",
                        "valor_inicial": "'.$valor_inicial.'"}';
                    $APIresult= apiQuery($data, $url);
                }
                elseif (($tipo_etapa=="Discreta") AND 
                        isset($_POST["minimo"]) AND 
                        isset($_POST["maximo"]) AND 
                        isset($_POST["valor_inicial"]) AND 
                        isset($_POST["rangos"])){
                    
                    $valor_inicial= $_POST["valor_inicial"];
                    $titulo= $_POST["titulo"];
                    $maximo= $_POST["maximo"];
                    $minimo= $_POST["minimo"];
                    $rangos= $_POST["rangos"];
                    $data= '{
                        "usuario": "'.$usuario.'", 
                        "token": "'.$token.'", 
                        "tipo": "'.$tipo_etapa.'",  
                        "titulo": "'.$titulo.'", 
                        "subtitulo": "'.$subtitulo.'", 
                        "maximo": "'.$maximo.'", 
                        "minimo": "'.$minimo.'",
                        "valor_inicial": "'.$valor_inicial.'",
                        "rangos": "'.$rangos.'"
                    }';
                    // TODO: Falta hacer comprobacion de los datos

                    if ($minimo<$maximo && $valor_inicial>=$minimo && $valor_inicial<=$maximo && $rangos<=$maximo){
                        $result= apiQuery($data, $url)['result'];
                        $etapa_creada=1;
                    }
                    else $notValidInsertEtapaDiscreta=1;
                }
            }
        } 
    }

    $calculadora_editada= 0;
    // Procedimiento para editar una calc

    if (seteados(["token","submit_edit_calc", "input_nombre_edit_calc", "input_url_edit_calc", "input_entidad_edit_calc"])){
        $nombre= $_POST["input_nombre_edit_calc"];
        $url= $_POST["input_url_edit_calc"];
        $entidad= $_POST["input_entidad_edit_calc"];
        $token= $_POST["token"];
        $email= $_SESSION["usuario"];
        $IP = "0.0.0.0";

        $result_create_calculator= apiQueryPro('edit_calulator', ["token", "url", "entidad_id", "nombre", "email", "ip"], [$token,$url,$entidad,$nombre,$email,$ip]);
        $tipo_calculadora_editada= $result_create_calculator;
        $msg_calculadora_editada= $result_create_calculator;
        $calculadora_editada= 1;
    }


    // Consultas de informacion a la API
    $calc_info= apiQueryPro('getSpecificCalculatorInfo', ["token"],[$_POST["token"]])['result'];
    $etapas_info= apiQueryPro('getStagesGeneralInfo', ["token"],[$_POST["token"]])['result'];
    $result_Formula= $calc_info[3];
    $nEtapas= count($etapas_info);

    
    
    $token= $_POST["token"];
    
    if (!isset($_SESSION["recargar"])){
        alert("Recarga");
        $_SESSION["recargar"]= 0;
        header("Location:editCalc.php");
    }
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

        require_once('../config/publicImports.php');
        if ($etapa_creada==1) echo mensaje('success', 'La etapa ha sido creada correctamente.');
        if ($calculadora_editada==1) mensaje($tipo_calculadora_editada, $msg_calculadora_editada);
        if ($notValidInsertEtapaDiscreta==1) mensaje('error', 'Los parametros introducidos al crear la etapa no son correctos. Revise el minimo maximo y el intervalo de salto.');

        
    ?>
    <script>
    function bloquearReenvioFormulario() {
        if (window.history.replaceState) { // verificamos disponibilidad
            window.history.replaceState(null, null, window.location.href);
        }
    }

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
                            <h1 class="m-0">Editar Simulador</h1>
                        </div><!-- /.col -->
                    </div><!-- /.row -->
                </div><!-- /.container-fluid -->
            </div>


            <!-- Main content -->
            <section class="content" style="padding-left: 1em !important; padding-right: 1em !important;">

                <div class="container-fluid">
                    <div class="row">
                        <div class="col-md-6">
                            <!-- Div para mostrar, editar y eliminar la calculadora -->
                            <div class="card card-secondary">
                                <!-- card-header -->
                                <div class="card-header">
                                    <h3 class="card-title">Editar Simulador</h3>
                                    <div class="card-tools">
                                        <form method="POST" action="eliminarCalculadoraEspecifica.php">
                                            <input hidden readonly value="<?php echo $token;?>" name="token">
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


                                <div class="ocultar" id="form_edit"">
                                    <form method=" POST" action="editCalc.php" enctype="multipart/form-data">
                                    <div class="card-body">
                                        <div class="form-group">
                                            <label>Nombre</label>
                                            <input type="text" class="form-control" id="input_nombre_edit_calc"
                                                name="input_nombre_edit_calc" value="<?php echo $calc_info[0];?>"
                                                required />
                                        </div>
                                        <div class="form-group">
                                            <label>Token</label>
                                            <input class="form-control" id="input_token_edit_calc"
                                                name="input_token_edit_calc" value="<?php echo $calc_info[7];?>"
                                                required disabled />
                                        </div>
                                        <div class="form-group">
                                            <label>URL (Lugar exacto donde se usara el simulador)</label>
                                            <input type="text" class="form-control" id="input_url_edit_calc"
                                                name="input_url_edit_calc" value="<?php echo $calc_info[1];?>"
                                                pattern="[Hh][Tt][Tt][Pp][Ss]?:\/\/(?:(?:[a-zA-Z\u00a1-\uffff0-9]+-?)*[a-zA-Z\u00a1-\uffff0-9]+)(?:\.(?:[a-zA-Z\u00a1-\uffff0-9]+-?)*[a-zA-Z\u00a1-\uffff0-9]+)*(?:\.(?:[a-zA-Z\u00a1-\uffff]{2,}))(?::\d{2,5})?(?:\/[^\s]*)?"
                                                title="Tiene que ser una url completa." required />
                                        </div>
                                        <div class="form-group">
                                            <label>Entidad</label>
                                            <select class="form-control" required id="input_entidad_edit_calc"
                                                name="input_entidad_edit_calc">
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
                                            <div class="submit_edit_calc">
                                                <button type="submit" name="submit_edit_calc" id="submit_edit_calc"
                                                    class="btn btn-primary">Guardar Cambios</button>
                                            </div>
                                        </div>
                                    </div>
                                    </form>
                                </div>


                                <div class="mostrar" id="form_see">
                                    <div class="card-body">
                                        <div class="form-group">
                                            <label>Nombre</label>
                                            <input type="text" class="form-control" id="input_nombre_see_calc"
                                                name="input_nombre_see_calc" value="<?php echo $calc_info[0];?>"
                                                required disabled />
                                        </div>
                                        <div class="form-group">
                                            <label>Token</label>
                                            <input class="form-control" id="input_token_see_calc"
                                                name="input_token_see_calc" value="<?php echo $calc_info[7];?>" required
                                                disabled />
                                        </div>
                                        <div class="form-group">
                                            <label>URL (Lugar exacto donde se usara el simulador)</label>
                                            <input type="text" class="form-control" id="input_url_see_calc"
                                                name="input_url_see_calc" value="<?php echo $calc_info[1];?>"
                                                pattern="[Hh][Tt][Tt][Pp][Ss]?:\/\/(?:(?:[a-zA-Z\u00a1-\uffff0-9]+-?)*[a-zA-Z\u00a1-\uffff0-9]+)(?:\.(?:[a-zA-Z\u00a1-\uffff0-9]+-?)*[a-zA-Z\u00a1-\uffff0-9]+)*(?:\.(?:[a-zA-Z\u00a1-\uffff]{2,}))(?::\d{2,5})?(?:\/[^\s]*)?"
                                                title="Tiene que ser una url completa." required disabled />
                                        </div>
                                        <?php 
                                            $entidad_id= $calc_info[4];
                                            $url = APIURL.'getEntidad';
                                            $data = '{"entidad_id": "'.$entidad_id.'"}';
                                            $result= apiQuery($data, $url)['result'];
                                        ?>
                                        <div class="form-group">
                                            <label>Entidad</label>
                                            <input type="text" class="form-control" id="input_url_see_calc"
                                                name="input_url_see_calc" disabled value="<?php echo $result[1]; ?>" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <!-- Card para editar la formula -->
                            <div class="card card-row card-secondary" id="introducirFormula"> 
                                
                                        <?php 
                                            if ($nEtapas>0) {
                                                echo '
                                                <div class="card-header">
                                                    <h3 class="card-title">
                                                        Editar Formula
                                                    </h3>
                                                </div>
                                                <div class="card_stages card-body">
                                                    <div class="container">
                                                ';
                                                if ($result_Formula != '') {
                                                    echo  ' <div class="callout callout-success">
                                                                <h5>Formula Activa</h5>
                                                                <p>'.$result_Formula.'</p>
                                                            </div>
                                                            <form method="POST" action="editarFormulaEspecifica.php">
                                                                <input type=hidden name=calc  value='.$token.' >
                                                                <input type="submit" name="submit_edit_stage" class="btn btn-primary" value="Editar Formula"/>
                                                            </form>';
                                                }
                                                else {
                                                    echo  ' <div class="callout callout-danger">
                                                                <h5>Formula Inactiva</h5>
                                                                <p>
                                                                    No hay ninguna formula activa por favor crea una para poder hacer el calculo final.
                                                                </p>
                                                            </div>
                                                            <form method="POST" action="editarFormulaEspecifica.php">
                                                                <input type=hidden name=calc  value='.$token.' >
                                                                <input type="submit" name="submit_edit_stage" class="btn btn-primary" value="Editar Formula"/>
                                                            </form>';
                                                }
                                                echo '</div>
                                                </div>';
                                            }
                                        ?>
                            </div>

                            <!-- Card para ver el estado de la calculadora -->
                            <!-- TODO: No esta terminado falta el metodo que comprueba si la calculadora es corecta -->
                            <div class="card card-row card-secondary">
                                <div class="card-header">
                                    <h3 class="card-title">
                                        Estado del simulador
                                    </h3>

                                </div>
                                <div class="card_stages card-body">
                                    <div class="container">
                                        <?php 
                                                        /*if ($result_Formula != '') {
                                                            echo  ' <div class="callout callout-success">
                                                                        <h5>Formula Activa</h5>
                                                                        <p> Todo correcto </p>
                                                                    </div>';
                                                        }
                                                        else {*/

                                                        $opcionesCorrectas=TRUE;
                                                        foreach ($etapas_info as $stage) {
                                                            if ($stage[2]=="Cualificada"){
                                                                $n_opciones_etapa= apiQueryPro('getOpciones', ['identificador'], [$stage[0]])['result'];
                                                                if (count($n_opciones_etapa) ==0){
                                                                    $opcionesCorrectas=FALSE;
                                                                    break;
                                                                }
                                                            }
                                                        }
                                                        alert("Etapas corectas ".$opcionesCorrectas);
                                                        if ($result_Formula != '' && $nEtapas>0 && $opcionesCorrectas){
                                                            echo  ' <div class="callout callout-success">
                                                                        <h5>Simulador activo</h5>
                                                                        <p>
                                                                            El simulador esta lista para su exportación.
                                                                        </p>
                                                                    </div>';
                                                        }
                                                        else {
                                                            if ($nEtapas<=0){
                                                                $mensaje= "No existe ninguna etapa para este simulador.";
                                                            }
                                                            elseif (!$opcionesCorrectas){
                                                                $mensaje= "Alguna de sus etapas con opciones no tiene ninguna opción.";
                                                            }
                                                            elseif ($result_Formula == ''){
                                                                $mensaje= "Debe introducir una formula valida.";
                                                            }
                                                            elseif ($result_Formula == ''){
                                                                $mensaje= "Ha ocurrido un error inesperado, intentelo de nuevo";
                                                            }
                                                            
                                                            echo  ' <div class="callout callout-danger">
                                                                        <h5>Simulador Incompleto</h5>
                                                                        <p>
                                                                            '.$mensaje.'
                                                                        </p>
                                                                    </div>';
                                                        }
                                                    ?>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>


                    <!-- Card para crear etapas -->
                    <div class="card card-secondary">
                        <!-- card-header -->
                        <div class="card-header">
                            <h3 class="card-title">Crear Etapa</h3>
                        </div>
                        <!-- form start -->
                        <form action="editCalc.php" method="POST">
                            <input type="hidden" readonly value="<?php echo $token;?>" name="calc_id" />
                            <div class="card-body" style="padding-bottom: 0em;">
                                <div class="form-group">
                                    <label>Tipo de etapa</label>
                                    <select class="form-control" required id="tipo_etapa" name="tipo_etapa"
                                        onchange="cargar_formulario()">
                                        <option disabled selected value="Sin valor">...</option>
                                        <option value="Cualificada">Opciones</option>
                                        <option value="Discreta">Intevalo</option>
																 <option value="Geografica">Geografica</option>
                                    </select>
                                </div>
                                <input type='hidden' id='token' name='token' value="<?php echo $token;?>" readonly />

                                <div id='div_title' class='form-group'>
                                </div>

                                <div id='div_subtitle' class='form-group'>
                                </div>

                                <div id="form_etapa">
                                </div>

                                <div id="form_etapa-geo" style="display:none;">
                                    <div class="form-group">
                                        <label>Dirección inical del mapa </label>
                                        <input id="autocomplete" name="autocomplete" class="form-control" type="text"
                                            aria-autocomplete="both" aria-controls="listbox--1" aria-expanded="false"
                                            aria-haspopup="listbox" aria-label="Introducir la dirección del sitio..."
                                            role="combobox" id="address-search" name="direccion" label="address-search"
                                            autocomplete="off" placeholder="Escribe tu dirección"
                                            data-reach-combobox-input="" value="" data-gaconnector-tracked="true" />
                                    </div>

                                    <div class="form-group">
                                        <label>Zoom</label>
                                        <input type="range" class="form-control" id="zoom" name="zoom" min="10" max="22"
                                            value=20 step="1" oninput="this.nextElementSibling.value = this.value"
                                            onchange="initMap()" />
                                        <output>20</output>
                                    </div>

                                    <div class="form-group">
                                        <label>Previsualización</label>
                                        <div id="map" class="form-control"
                                            style="height:500px;padding:0px !important; margin:0px!important;" readonly>
                                        </div>
                                    </div>

                                    <input type='hidden' id='latitude' name='latitude' readonly />
                                    <input type='hidden' id='longitude' name='longitude' readonly />
                                    <input type='hidden' id='token' name='token' value="<?php echo $token;?>"
                                        readonly />
                                </div>

                            </div>
                            <!-- /.card-body -->
                            <div class="form-group">

                                <div class="submit_stages">
                                    <button type="submit" name="submit" class="btn btn-primary">Crear
                                        Etapa</button>
                                </div>
                            </div>
                        </form>
                    </div>

                    <div class="row">
                        <!-- Card para mostrar las etapas de la calculadora, borarrlas y acceder a la pagina para editarlas -->
                        <div class="col-md-8">
                            <div class="card card-row card-secondary" id="edicion_etapas">
                                <div class="card-header">
                                    <h3 class="card-title">
                                        Editar etapas
                                    </h3>
                                </div>
                                <div class="card_stages card-body">
                                    <table class="table table-bordered">
                                        <thead>
                                            <tr>
                                                <th>Pos.</th>
                                                <th>Nombre etapa</th>
                                                <th>Tipo etapa</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <?php
                                                    $url = APIURL.'getStagesGeneralInfo';
                                                    $token= $token;
                                                    $data= '{"token": "'.$token.'"}';
                                                    $result_stage_info= apiQuery($data, $url)['result'];
                                
                                                    $pos= 0;
                                                    foreach ($etapas_info as $stage) {
                                                        if ($stage[2]=="Discreta") $e= "Intervalo";
                                                        else if ($stage[2]=="Cualificada") $e= "Opciones"; 
                                                        else $e= $stage[2];
                                
                                                        $pos++;
                                                        echo '
                                                        <tr>
                                                            <td>'.$pos.'</td>
                                                            <td>'.$stage[3].'</td>
                                                            <td>'.$e.'</td>
                                                            <td>
                                                                <form method="POST" action="editarEtapaEspecifica.php">
                                                                    <input type="hidden" value="'.$stage[0].'" name="etapa_id" />
                                                                    <input type="hidden" value="'.$_POST["token"].'" name="token" />
                                                                    <button type="submit" class="badge bg-primary" style="border: 0px;">Editar</button>
                                                                </form>
                                                            </td>
                                                            <td>
                                                                <form method="POST" action="eliminarEtapaEspecifica.php">
                                                                    <input type="hidden" value="'.$stage[0].'" name="etapa_id" />
                                                                    <input type="hidden" value="'.$_POST["token"].'" name="token" />
                                                                    <button type="submit" class="badge bg-danger" style="border: 0px;">Eliminar</button>
                                                                </form>
                                                            </td>
                                                        </tr>';
                                                    }
                                                    if ($pos==0) {
                                                        echo    '<script type="text/javascript">
                                                                    document.getElementById("edicion_etapas").style.display = "none"; 
                                                                </script>';
                                                    }else{
                                                        echo    '<script type="text/javascript">
                                                                    document.getElementById("edicion_etapas").style.display = "block"; 
                                                                </script>';
                                                    }
                                                ?>

                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>

                        <!-- Card para editar las posiciones de las etapas -->
                        <div class="col-md-4">
                            <div>
                                <?php 
                                            $url = APIURL.'getStagesGeneralInfo';
                                            $token= $_POST["token"];
                                            $data= '{"token": "'.$token.'"}';
                                            $result1= apiQuery($data, $url)['result'];
                                        
                                            
                                            
                                        
                                            $url = APIURL.'getStagesGeneralInfo';
                                            $token= $_POST["token"];
                                            $data= '{"token": "'.$token.'"}';
                                            $result1= apiQuery($data, $url)['result'];
                                        
                                            if ($result1!=[]){
                                                echo '
                                                <div class="card card-row card-secondary" >
                                                    <div class="card-header">
                                                        <h3 class="card-title">
                                                            Editar posicion etapas
                                                        </h3>
                                                    </div>
                                                <div class="card_stages card-body">
                                                    <form action="editCalc.php" method="POST">
                                                ';
                                                
                                                $pos= 0;
                                                foreach ($result1 as $stage) {
                                                    echo    '   <div class="container">
                                                                    <div class="box" draggable="true">
                                                                        <div class="card_stage card-body" style="padding-top: 0.3rem !important; padding-bottom: 0rem !important;">
                                                                            <div class="card card-primary card-outline">
                                                                                <div class="card-header">
                                                                                    <h5 class="card-title">&nbsp;&nbsp;'.$stage[3].'</h5>
                                                                                    <input type="hidden" id="stageId_'.$stage[0].'" data-position='.$pos.' name="stageId_'.$stage[0].'" value="'.$pos.'" readonly />
                                                                                    <input type="hidden" value="'.$_POST["token"].'" name="token" />
                                                                                </div>
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                </div>';
                                                    $pos++;
                                                            }
                                                echo '  <div class="submit_stages edit_stages_submit">
                                                            <button type="submit" name="submit_edit_pos_calc" class="btn btn-primary">Guardar cambios</button>
                                                        </div>
                                                    </form>
                                                </div>
                                            </div>';
                                        
                                            }
                                        ?>
                                <div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Card para mostrar los presupuestos actuales de la calculadora -->
                    <div class="card card-secondary" id="presupuestos_calculadora">
                        <div class="card-header">
                            <h3 class="card-title">Presupuestos Simulador</h3>
                        </div>

                        <div class="card-body" style="display:none">
                            <table class="table table-bordered">
                                <thead>
                                    <tr>
                                       c
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php
                                                $result_entidad_info= apiQueryPro('get_presupuestos_calculadora', ['token'], [$token])['result'];
                            
                                                $pos= 0;
                                                foreach ($result_entidad_info as $presupuesto) {
                                                    $pos++;
                                                    if ($presupuesto[3]==NULL) $resultado= $presupuesto[1];
                                                    else $resultado= "Sin finalizar";
                                                    echo '
                                                    <tr>
                                                        <td>'.$presupuesto[4].'</td>
                                                        <td>'.$presupuesto[6].'</td>
                                                        <td>'.$presupuesto[5].'</td>
                                                        <td>'.$presupuesto[7].'</td>
                                                        <td>'.$resultado.'</td>
                                                    </tr>';
                                                }
                                                if ($pos==0) {
                                                    echo    '<script type="text/javascript">
                                                                document.getElementById("presupuestos_calculadora").style.display = "none"; 
                                                            </script>';
                                                }else{
                                                    echo    '<script type="text/javascript">
                                                                document.getElementById("presupuestos_calculadora").style.display = "block"; 
                                                            </script>';
                                                }
                                            ?>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
        </div>
    </div>


    </section>
    <!-- /.content -->
    </div>
    <?php
            require_once('footer.php');
        ?>
    <script>
    if (window.history.replaceState) {
        window.history.replaceState(null, null, window.location.href);
    }
    </script>
    </div>

</body>

</html>