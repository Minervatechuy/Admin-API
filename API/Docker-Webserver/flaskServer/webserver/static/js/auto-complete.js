var placeSearch, autocomplete;

function initAutocomplete() {
	var xhr = new XMLHttpRequest();
	autocomplete = new google.maps.places.Autocomplete(
		/** @type {!HTMLInputElement} */(document.getElementById('autocomplete')),
		{types: ['geocode']});

	// When the user selects an address from the dropdown, populate the address
	// fields in the form.
	autocomplete.addListener('place_changed', fillInAddress);
}


function fillInAddress() {
	var place = autocomplete.getPlace();
	// get lat
	var lat = place.geometry.location.lat();
	document.getElementById('latitude').value=lat;
	// get lng
	var lng = place.geometry.location.lng();
	document.getElementById('longitude').value=lng;
}


function getDireccion() {
	var place = autocomplete.getPlace();
	if(!place){
		alert("Debe elegir una dirección correcta para la geolocalización.");
	}
}


window.addEventListener('keydown',function(e){if(e.keyIdentifier=='U+000A'||e.keyIdentifier=='Enter'||e.keyCode==13){if(e.target.nodeName=='INPUT'&&e.target.type=='text'){e.preventDefault();return false;}}},true);

