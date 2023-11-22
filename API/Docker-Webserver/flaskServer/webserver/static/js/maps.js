let drawingManager = null;
let selectedShape = null;
let map;

function clearSelection() {
  if (selectedShape) {
    selectedShape.setEditable(false);
    selectedShape = null;
  }
}

function setSelection(shape) {
  clearSelection();
  selectedShape = shape;
  shape.setEditable(true);
}

function deleteSelectedShape() {
  if (selectedShape) {
    var areaAnterior = document.getElementById("value-1").innerHTML;
    var area = google.maps.geometry.spherical.computeArea(selectedShape.getPath());
    if (parseInt(areaAnterior) - parseInt(area) > 0) {
      document.getElementById("value-1").innerHTML = parseInt(areaAnterior) - parseInt(area);
    } else {
      document.getElementById("value-1").innerHTML = 0;
    }
    selectedShape.setMap(null);
  }
}

function initMap() {
  var latitudeElement = document.getElementById('latitude');
  var longitudeElement = document.getElementById('longitude');
  var zoomElement = document.getElementById('zoom');

  var latitude = parseFloat(latitudeElement.value);
  var longitude = parseFloat(longitudeElement.value);
  var zoom = parseInt(zoomElement.value);
  
  if (isNaN(latitude) || isNaN(longitude) || isNaN(zoom)) {
      latitude = -34.9011;
      longitude = -56.1915; 
      zoom = 20; 
  }
  
  var posicion = { lat: latitude, lng: longitude };
  
  map = new google.maps.Map(document.getElementById("map"), {
      zoom: zoom,
      center: posicion,
      mapTypeControl: false,
      mapTypeId: 'hybrid',
  });

  // Initialize address autocomplete
  initAutocomplete();

  drawingManager = new google.maps.drawing.DrawingManager({
    drawingMode: google.maps.drawing.OverlayType.POLYGON,
    drawingControl: true,
    drawingControlOptions: {
      position: google.maps.ControlPosition.TOP_CENTER,
      drawingModes: [google.maps.drawing.OverlayType.POLYGON],
    },
    polygonOptions: {
      fillColor: "#FF2D00",
      fillOpacity: 0.5,
      strokeWeight: 2,
      strokeColor: "#FF0000",
      clickable: true,
      editable: true,
      zIndex: 3,
    },
  });

  google.maps.event.addListener(drawingManager, "overlaycomplete", function (e) {
    if (e.type != google.maps.drawing.OverlayType.MARKER) {
      drawingManager.setDrawingMode(null);
      var newShape = e.overlay;
      newShape.type = e.type;
      google.maps.event.addListener(newShape, "click", function () {
        setSelection(newShape);
      });
      var area = google.maps.geometry.spherical.computeArea(newShape.getPath());
      var areaAnterior = document.getElementById("value-1").innerHTML;
      document.getElementById("value-1").innerHTML = parseInt(areaAnterior) + parseInt(area);
      document.getElementById("hidden-value-1").value = parseInt(areaAnterior) + parseInt(area);
      setSelection(newShape);
    }
  });

  google.maps.event.addListener(drawingManager, "drawingmode_changed", clearSelection);
  google.maps.event.addListener(map, "click", clearSelection);
  google.maps.event.addDomListener(document.getElementById("borrar"), "click", deleteSelectedShape);

  drawingManager.setMap(map);
}

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
      // Get lat
      var lat = place.geometry.location.lat();
      document.getElementById('latitude').value = lat;
      
      // Get lng
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

window.addEventListener('keydown', function (e) {
  if (e.keyIdentifier == 'U+000A' || e.keyIdentifier == 'Enter' || e.keyCode == 13) {
    if (e.target.nodeName == 'INPUT' && e.target.type == 'text') {
      e.preventDefault();
      return false;
    }
  }
}, true);
