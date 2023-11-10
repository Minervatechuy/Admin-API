function cargar_formulario(){

    var type= document.getElementById("tipo_etapa").value;
    var titulo="<label>Título</label><input type='text' class='form-control' id='titulo' name='titulo' placeholder='Ej: Etapa de eleccion de techos' required>";
    var subtitulo="<label>Subtítulo</label><input type='text' class='form-control' id='subtitulo' name='subtitulo' placeholder='Ej: Elija su techo' required>";

    if (type=="..."){
        
        document.getElementById('form_etapa').innerHTML=" ";
        document.getElementById('div_title').style.display="none";
        document.getElementById('form_etapa').style.display="block";
        document.getElementById('form_etapa-geo').style.display="none";
    } else if (type=="Geografica"){
        
        document.getElementById('form_etapa').style.display="none";
        document.getElementById('form_etapa-geo').style.display="block";
        document.getElementById('div_title').innerHTML=titulo;
        document.getElementById('div_title').style.display="block";
        document.getElementById('div_subtitle').innerHTML=subtitulo;
        document.getElementById('div_subtitle').style.display="block";
                            
    } else {
        var archive= "etapa"+type+".php";
        document.getElementById('form_etapa').style.display="block";
        document.getElementById('form_etapa-geo').style.display="none";
        document.getElementById('div_title').innerHTML=titulo;
        document.getElementById('div_title').style.display="block";
        document.getElementById('div_subtitle').innerHTML=subtitulo;
        document.getElementById('div_subtitle').style.display="block";
        if (XMLHttpRequest){
            xhr= new XMLHttpRequest();
            xhr.open('POST', archive, true);
            xhr.onreadystatechange= function(){
                if (xhr.readyState == 4 && xhr.status==200){
                    document.getElementById('form_etapa').innerHTML=xhr.responseText;
                }
            }
            xhr.send('');
        }
        
    }
}