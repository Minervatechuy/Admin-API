function updateSlider(pConsumo) {
	jQuery("valor_ant").val(pConsumo);
}

function destacar(btn, tipo, nombreDiv, inputEtapa) {
	var opciones = $("div#" + nombreDiv + " .opcion");

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