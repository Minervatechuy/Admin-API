<?php
    $url= APIURL.'getStageInfo';
    $identificador= $_POST["etapa_id"];
    $data= '{"identificador": '.$identificador.'}';
    $result_stage_info= apiQuery($data, $url)['result'];
?>
<div>
    <div class="form-group">
        <label>Mínimo</label>
        <input type="number" value="<?php echo $result_stage_info[0][3] ?>" class="form-control" id="input_min_discreta" name="input_min_discreta" placeholder="Ej: 7" required>
    </div>
    
    <div class="form-group">
        <label>Máximo</label>
        <input type="number" value="<?php echo $result_stage_info[1][3] ?>" class="form-control" id="input_max_discreta" name="input_max_discreta" placeholder="Ej: 120" required>
    </div>
    
    <div class="form-group">
        <label>Valor Inicial</label>
        <input type="number" value="<?php echo $result_stage_info[2][3] ?>" class="form-control" id="input_valor_discreta" name="input_valor_discreta" placeholder="Ej: 10" required>
    </div>
    
    <div class="form-group">
        <label>Intervalo de salto</label>
        <input type="number" value="<?php echo $result_stage_info[3][3] ?>" class="form-control" id="" name="input_rangos_discreta" placeholder="Ej: 4" required>
    </div>
</div>