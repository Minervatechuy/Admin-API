<?php

require_once('../config/context.php');

function apiQuery($data, $url){
	$additional_headers = array(
		'Accept: application/json',
		'Content-Type: application/json'
	);

	$ch = curl_init($url);

	curl_setopt($ch, CURLOPT_URL, $url);
	curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "POST");
	curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_HTTPHEADER, $additional_headers);

	$server_output = curl_exec ($ch);
	$jsondec = json_decode($server_output, true);
	return $jsondec;
}

// Realiza una Query a la API
function apiQueryPro($funcion, $claves, $valores){
    $context_JSON= generateContextJSON(1);
    $data= addArrayDataToSend($context_JSON, $claves, $valores);
    $url = APIURL.$funcion;
    return apiQuery($data, $url);
}

// Simplifacion del mostrado de alertas
function alert($info) {
	if (DEBUG) echo "<script>alert('".$info."')</script>";
}

// Para ver si los datos estan seteados
function seteados($array){
    foreach ($array as $elemento) {
        if (!(isset($_POST[$elemento])))  {
            return false;
        }
    }   
    return true;
}

// Mensajes fin de formulario
function mensaje($tipo, $mensaje){
    // TIPOS: SUCCCESS, ERROR, INFO y WARNING
    echo "
    <script>    
        $(function() {
            var Toast = Swal.mixin({
                toast: true,
                position: 'top-end',
                showConfirmButton: false,
                timer: 7000
            });
            toastr.".$tipo."('".$mensaje."');
        });
    </script>
    ";
}

// Funciones para la manipulacion de JSON
function addDataToSend($json, $key, $value){
    $json = json_decode($json, true);
    $json[$key] = $value;
    $json = json_encode($json);
    return $json;
}
function addArrayDataToSend($json, $keys, $values){
    $json = json_decode($json, true);
    if (count($keys) != count($values)) {
        alert("Numero distinto de claves y valores");
    }
    for ($i=0; $i<count($keys); ++$i){
        $json[$keys[$i]] = $values[$i];
    }
    $json = json_encode($json);
    return $json;
}

// JSON de base sobre el que se carga la demas informacion
function generateContextJSON($debug){
    $usuario= $_SESSION["usuario"];
    if ($usuario=="") $usuario="Sin loggear";
    $url= "http://$_SERVER[HTTP_HOST]$_SERVER[REQUEST_URI]";
    $json = '{
        "usuario_context": "'.$usuario.'",
        "url_context": "'.$url.'",
        "debug_context": "'.$debug.'"
    }';
    return $json;
}


function redirect_by_post($post_variables, $pagina){
    echo '  <head>
                <meta charset="utf-8">
                <!-- Funcion para hacer autosubmit -->
                <script>
                window.onload = function() {
                    // Una vez cargada la página, el formulario se enviara automáticamente.
                    document.forms["miformulario"].submit();
                }
                </script>
            </head>

            <body>

            <form name="miformulario" action="'.$pagina.'" method="POST">';
                foreach ($post_variables as $var){
                    var_dump($var);
                    echo '<input type="hidden" name="'.$var[0].'" value="'.$var[1].'">';
                }
            echo '</form>
        </body>

        </html>';
}
?>