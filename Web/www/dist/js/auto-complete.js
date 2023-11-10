var placeSearch, autocomplete;

function initAutocomplete() {
	var xhr = new XMLHttpRequest();
	autocomplete = new google.maps.places.Autocomplete(
		(document.getElementById('autocomplete')),
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

	initMap();
}


function getDireccion() {
	var place = autocomplete.getPlace();
	if(!place){
		alert("Debe elegir una dirección correcta para la geolocalización.");
	}
}


function initMap() {
	var latitude = parseFloat(document.getElementById("latitude").value);
	var longitude = parseFloat(document.getElementById("longitude").value);

	var zoom = parseInt(document.getElementById("zoom").value);

	document.getElementById('map').innerHTML = "<iframe src='https://maps.google.com/maps?q="+latitude+","+longitude+"&z="+zoom+"&t=h&output=embed' width='100%' height='100%' frameborder='0' style='border:0'></iframe>";
}


window.addEventListener('keydown',function(e){if(e.keyIdentifier=='U+000A'||e.keyIdentifier=='Enter'||e.keyCode==13){if(e.target.nodeName=='INPUT'&&e.target.type=='text'){e.preventDefault();return false;}}},true);
