<?php
$url = APIURL.'getStageInfo';
$identificador = $_POST["etapa_id"];
$data = '{"identificador": '.$identificador.'}';
$result_stage_info = apiQuery($data, $url);

// Check if the API call was successful and the result is set
if(isset($result_stage_info['result'])) {
    $result_stage_info = $result_stage_info['result'];

    // Initialize variables
    $minimo = $maximo = $valor_inicial = $intervalo = '';

    // Iterate over the 'result' array to extract values
    foreach ($result_stage_info as $item) {
        switch ($item[2]) {
            case 'minimo':
                $minimo = $item[3];
                break;
            case 'maximo':
                $maximo = $item[3];
                break;
            case 'valor_inicial':
                $valor_inicial = $item[3];
                break;
            case 'rangos':
                $intervalo = $item[3];
                break;
        }
    }
} else {
    // Handle the case where the API call was not successful
    // You might want to provide default values or show an error message
    $minimo = $maximo = $valor_inicial = $intervalo = '';
}
?>

<div>
    <div class="form-group">
        <label>Mínimo</label>
        <input type="number" value="<?php echo $minimo ?>" class="form-control" id="input_min_discreta" name="input_min_discreta" placeholder="Ej: 7" required>
    </div>
    
    <div class="form-group">
        <label>Máximo</label>
        <input type="number" value="<?php echo $maximo ?>" class="form-control" id="input_max_discreta" name="input_max_discreta" placeholder="Ej: 120" required>
    </div>
    
    <div class="form-group">
        <label>Valor Inicial</label>
        <input type="number" value="<?php echo $valor_inicial ?>" class="form-control" id="input_valor_discreta" name="input_valor_discreta" placeholder="Ej: 10" required>
    </div>
    
    <div class="form-group">
        <label>Intervalo de salto</label>
        <input type="number" value="<?php echo $intervalo ?>" class="form-control" id="" name="input_rangos_discreta" placeholder="Ej: 4" required>
    </div>
</div>