    <?php 
        require_once('../config/context.php');
        $etapa_creada= 0;
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
                                header('Location: '.$APPPATH.'/private/crearOpcion.php');
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
                        
                        $result= apiQuery($data, $url)['result'];
                    }
                    alert("Etapa creada");
                    $etapa_creada=1;
                    mensaje('error', 'Las credenciales son incorrectas por favor intentelo de nuevo.');
                }
            }
        }
        unset($_POST["submit"]);
    ?>
    
    <div class="card card-primary">
        <!-- card-header -->
        <div class="card-header">
            <h3 class="card-title">Crear Etapa</h3>
        </div>
        <!-- form start -->
        <form action="editCalc.php" method="POST">
            <input type="hidden" readonly value="<?php echo $_POST["token"];?>" name="calc_id"/>
            <div class="card-body" style="padding-bottom: 0em;">
                <div class="form-group">
                    <label>Tipo de etapa</label>
                    <select class="form-control" required id="tipo_etapa" name="tipo_etapa"
                        onchange="cargar_formulario()">
                        <option disabled selected value="Sin valor">...</option>
                        <option value="Geografica">Geográfica</option>
                        <option value="Cualificada">Opciones</option>
                        <option value="Continua">Continua</option>
                        <option value="Discreta">Discreta</option>
                    </select>
                </div>
                <input type='hidden' id='token' name='token' value="<?php echo $_POST["token"];?>" readonly />

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
                            aria-haspopup="listbox" aria-label="Introducir la dirección del sitio..." role="combobox"
                            id="address-search" name="direccion" label="address-search" autocomplete="off"
                            placeholder="Escribe tu dirección" data-reach-combobox-input="" value=""
                            data-gaconnector-tracked="true" />
                    </div>

                    <div class="form-group">
                        <label>Zoom</label>
                        <input type="range" class="form-control" id="zoom" name="zoom" min="10" max="22" value=20
                            step="1" oninput="this.nextElementSibling.value = this.value" onchange="initMap()" />
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
                    <input type='hidden' id='token' name='token' value="<?php echo $_POST["token"];?>" readonly />
                </div>

            </div>
            <!-- /.card-body -->
            <div class="form-group">

                <div class="submit_stages">
                    <button type="submit" name="submit" class="btn btn-primary">Crear Etapa</button>
                </div>
            </div>
        </form>
    </div>