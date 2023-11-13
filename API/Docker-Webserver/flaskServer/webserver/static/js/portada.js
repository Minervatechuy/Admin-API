function APIrequest(sig_pos) {
    var direccion_url = encodeURI(window.location.href).replaceAll('/', '!');
    var apiurl = 'https://api.minervatech.uy/show_etapa/' + sig_pos + '/' + direccion_url;

    // Se recogen los valores de la etapa anterior haciendo una especie de isset
    if (document.getElementById("n_presupuesto") !== null &&
        document.getElementById("tipo_ant") !== null &&
        document.getElementById("valor_ant") !== null) {
        var n_presupuesto = document.getElementById("n_presupuesto").value;
        var tipo;
        if (document.getElementById("tipo_ant_geo") !== null) {
            tipo = document.getElementById("tipo_ant_geo").value;
        } else {
            tipo = document.getElementById("tipo_ant").value;
        }
        var valor;
        if (document.getElementById("hidden-value-1") !== null) {
            valor = document.getElementById("hidden-value-1").value;
        } else {
            valor = document.getElementById("valor_ant").value;
        }
        apiurl = apiurl + '/' + n_presupuesto + '/' + tipo + '/' + valor;
    }

    console.log(apiurl)

    if (XMLHttpRequest) {
        var xhr = new XMLHttpRequest();
        xhr.open('GET', apiurl, true);
        xhr.onreadystatechange = function () {
            if (xhr.readyState == 4 && xhr.status == 200) {
                var response = xhr.responseText;
                
                var showMap = response.includes('<div id="map"></div>');

                document.getElementById('div_response').style.display = showMap ? 'none' : 'block';
                document.getElementById('div_response_2').style.display = showMap ? 'block' : 'none';

                if (showMap) {
                    document.getElementById('div_response_2').innerHTML = response;
                    initMap();
                } else {
                    document.getElementById('div_response').innerHTML = response;
                }
            }
        };
        xhr.send('');
    } // Cierra if xmlhttprequest
} // Cierra la función

function updateSlider(pConsumo) {
    jQuery("valor_ant").val(pConsumo);
}

function destacar(btn, tipo, nombreDiv, inputEtapa) {
    var opciones = jQuery("div#" + nombreDiv + " .opcion");

    // Aplicamos la función anonima para cambiarles el estilo a cada uno de ellos
    opciones.each(
        function () {
            this.style.border = "0px solid white";
            this.style['-webkit-filter'] = "grayscale(90%)";
            this.style.opacity = "0.5";

        } //end función anonima
    );

    // Asignamos el valor al hidden input para luego mandarlo por formulario
    document.getElementById('valor_ant').value = tipo;

    // Resaltamos la opcion
    btn.style.opacity = "1";
    btn.style['-webkit-filter'] = "grayscale(0%)";
}