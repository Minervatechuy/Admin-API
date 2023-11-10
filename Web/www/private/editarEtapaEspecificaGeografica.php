<?php
    include('../config/context.php');
    echo "<script src='../dist/js/auto-complete.js'></script>";
    echo "<script src='https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js'></script>";
    echo "<script src='https://maps.googleapis.com/maps/api/js?key=".GOOGLEAPI."&libraries=places&callback=initAutocomplete' async defer></script>";


    $url= APIURL.'getStageInfo';
    $identificador= $_POST["etapa_id"];
    $data= '{"identificador": '.$identificador.'}';
    $result_stage_info= apiQuery($data, $url)['result'];
?>
<div id="form_etapa-geo">
    <div class="form-group">
        <label>Dirección inical del mapa </label>
        <input id="autocomplete" name="autocomplete" class="form-control" type="text" aria-autocomplete="both"
            aria-controls="listbox--1" aria-expanded="false" aria-haspopup="listbox"
            aria-label="Introducir la dirección del sitio..." role="combobox" id="address-search" name="direccion"
            label="address-search" autocomplete="off" placeholder="Escribe tu dirección"
            data-reach-combobox-input="<?php echo $result1[3];?>" data-gaconnector-tracked="true"
            onchange="initMap()" value="<?php echo $result_stage_info[0][3];?>" />
    </div>

    <div class="form-group">
        <label>Zoom</label>
        <input type="range" class="form-control" id="zoom" name="zoom" min="10" max="22" value="<?php echo $result_stage_info[1][3];?>" step="1"
            oninput="this.nextElementSibling.value = this.value" onchange="initMap()" />
        <output>20</output>
    </div>

    <div class="form-group">
        <label>Previsualización</label>
        <div id="map" class="form-control" style="height:500px;padding:0px !important; margin:0px!important;" readonly>
        </div>
    </div>
    <input type='hidden' id='latitude' name='latitude' value="<?php echo $result_stage_info[2][3];?>" readonly />
    <input type='hidden' id='longitude' name='longitude' value="<?php echo $result_stage_info[3][3];?>" readonly />
</div>

<script>
    $('.autocomplete').ready(function() {
        initMap();
    });
</script>