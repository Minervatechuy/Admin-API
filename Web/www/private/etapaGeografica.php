<?php 
    include('../config/context.php');
    echo "<script src='../dist/js/auto-complete.js'></script>";
    echo "<script src='https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js'></script>";
    echo "<script src='https://maps.googleapis.com/maps/api/js?key=".GOOGLEAPI."&libraries=places&callback=initAutocomplete' async defer></script>";
?>
    <div class="form-group">
        <label>Dirección inical del mapa </label>
        <!--input type="text" class="form-control" id="direccion" name="direccion" placeholder="Ej: Calle Iñigo de Loyola, Lasarte-Oria"/-->
        <input id="autocomplete" class="form-control" type="text" aria-autocomplete="both" aria-controls="listbox--1"
            aria-expanded="false" aria-haspopup="listbox" aria-label="Introducir la dirección del sitio..."
            role="combobox" id="address-search" name="direccion" label="address-search" autocomplete="off"
            placeholder="Escribe tu dirección" data-reach-combobox-input="" value="" data-gaconnector-tracked="true" required/>
    </div>

    <div class="form-group">
        <label>Zoom</label>
        <input type="range" class="form-control" id="zoom" name="zoom" min="10" max="22" value=20 step="1"
            oninput="this.nextElementSibling.value = this.value" />
        <output>20</output>
    </div>

    <div class="form-group">
        <label>Previsualización</label>
        <div id="map" class="form-control" style="background-color: #ced4da;" readonly>
        </div>
    </div>


    <input type='hidden' id='latitude' name='latitude' readonly />
    <input type='hidden' id='longitude' name='longitude' readonly />