async function APIrequest(sig_pos) {
    var direccion_url = encodeURIComponent(window.location.href).replaceAll('/', '!');
    var apiurl = 'https://api.cloud.minervatech.uy/show_etapa/' + sig_pos + '/' + direccion_url;

    // Se recogen los valores de la etapa anterior haciendo una especie de isset
    if (document.getElementById("n_presupuesto") !== null &&
        document.getElementById("tipo_ant") !== null &&
        document.getElementById("valor_ant") !== null) {
        var n_presupuesto = document.getElementById("n_presupuesto").value;
        var tipo;
        if (document.getElementById("tipo_ant_geo") !== null) {
            tipo = document.getElementById("tipo_ant_geo").value;
            n_presupuesto = document.getElementById("n_presupuesto_geo").value;
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

    console.log(apiurl);

    try {
        const response = await fetch(apiurl);
        if (!response.ok) {
            throw new Error('Network response was not ok');
        }

        const responseBody = await response.text();

        if (tipo === 'geografica') {
            logInformation(direccion_url, n_presupuesto);
        }

        var showMap = responseBody.includes('<div id="map"></div>');

        document.getElementById('div_response').style.display = showMap ? 'none' : 'block';
        document.getElementById('div_response_2').style.display = showMap ? 'block' : 'none';

        if (showMap) {
            document.getElementById('div_response_2').innerHTML = responseBody;
            initMap();
        } else {
            document.getElementById('div_response').innerHTML = responseBody;
        }
    } catch (error) {
        console.error('Error:', error);
    }
}

function updateSlider(pConsumo) {
    $("valor_ant").val(pConsumo);
}

function destacar(btn, tipo, nombreDiv, inputEtapa) {
    var opciones = $("div#" + nombreDiv + " .opcion");

    // Aplicamos la función anónima para cambiarles el estilo a cada uno de ellos
    opciones.each(function () {
        this.style.border = "0px solid white";
        this.style['-webkit-filter'] = "grayscale(90%)";
        this.style.opacity = "0.5";
    });

    // Asignamos el valor al hidden input para luego mandarlo por formulario
    document.getElementById('valor_ant').value = tipo;

    // Resaltamos la opción
    btn.style.opacity = "1";
    btn.style['-webkit-filter'] = "grayscale(0%)";
}

async function logInformation(apiurl, n_presupuesto) {
    var logWebhookUrl = 'https://api.cloud.minervatech.uy/insert_logs';
    var direccionAutocomplete = document.getElementById('autocomplete').value;
    var direccionHidden = document.getElementById('direccion').value;
    var direccion = direccionAutocomplete ? direccionAutocomplete : direccionHidden;

    var variablesToLog = [
        { name: 'area', elementId: 'hidden-value-1' },
        { name: 'latitud', elementId: 'latitude' },
        { name: 'longitud', elementId: 'longitude' },
        { name: 'direccion', elementId: 'direccion' },
    ];

    try {
        for (const variable of variablesToLog) {
            var element = document.getElementById(variable.elementId);

            var logData = {
                procedure: apiurl,
                presupuesto_id: n_presupuesto,
                in: variable.name,
                out: variable.name === 'direccion' ? direccion : element.value,
            };

            const logResponse = await fetch(logWebhookUrl, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(logData),
            });

            console.log('Log Response:', await logResponse.text());
        }
    } catch (error) {
        console.error('Error calling Log:', error);
    }
}
