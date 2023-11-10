function APIrequest(sig_pos) {
    var direccion_url= (encodeURI(window.location.href)).replaceAll('/', '!');
    var apiurl = 'https://api.minervatech.uy/show_etapa/' + sig_pos +'/'+ direccion_url;
    // Se recogen los valores de la etapa anterior haciendo una especie de isset
    if  (( document.getElementById("n_presupuesto") !== null) &&
        ( document.getElementById("tipo_ant") !== null) &&
        ( document.getElementById("valor_ant") !== null)){
            var n_presupuesto= document.getElementById("n_presupuesto").value;
            var tipo= document.getElementById("tipo_ant").value;
            var valor= document.getElementById("valor_ant").value;
            var apiurl = apiurl + '/' + n_presupuesto +'/'+ tipo + '/' + valor;

            if  (( document.getElementById("area_ant") !== null) && 
            ( document.getElementById("latitud_ant") !== null) &&
            ( document.getElementById("longitud_ant") !== null) ){
                    var area= document.getElementById("area_ant");
                    var latitud= document.getElementById("latitud_ant");
                    var longitud= document.getElementById("longitud_ant");
                    var direccion= document.getElementById("direccion_ant");
                    var apiurl = apiurl + '/' + area + '/' + latitud + '/' +longitud + '/' + direccion;
            }
    }
    if (XMLHttpRequest) {
        xhr = new XMLHttpRequest();
        xhr.open('GET', apiurl, true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState == 4 && xhr.status == 200) {
                document.getElementById('div_response').innerHTML = xhr.responseText;
            }
        }
        xhr.send('');
    } //cierra if xmlhttprequest
} //cierra la función


