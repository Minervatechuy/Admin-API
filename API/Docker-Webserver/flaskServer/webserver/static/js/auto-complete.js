function initAutocomplete() {
	autocomplete = new google.maps.places.Autocomplete(
		document.getElementById('autocomplete'),
		{ types: ['geocode'] });

	autocomplete.addListener('place_changed', fillInAddress);
}

function fillInAddress() {
    var place = autocomplete.getPlace();

    // Check if a valid place is selected
    if (place && place.geometry && place.geometry.location) {
        // Update the map or perform other actions
        var lat = place.geometry.location.lat();
        document.getElementById('latitude').value = lat;

        var lng = place.geometry.location.lng();
        document.getElementById('longitude').value = lng;

        // Set the map center to the selected location
        var newPosition = { lat: lat, lng: lng };
        map.setCenter(newPosition);
    } else {
        // Handle the case when a valid place is not selected
        alert("Please choose a valid address for geolocation.");
    }
}

function getDireccion() {
	var place = autocomplete.getPlace();
	if (!place) {
		alert("Debe elegir una dirección correcta para la geolocalización.");
	}
}

google.maps.event.addDomListener(window, 'keydown', function (e) {
	if (e.keyIdentifier == 'U+000A' || e.keyIdentifier == 'Enter' || e.keyCode == 13) {
		if (e.target.nodeName == 'INPUT' && e.target.type == 'text') {
			e.preventDefault();
			return false;
		}
	}
  });
