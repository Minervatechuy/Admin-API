var placeSearch, autocomplete;

function initAutocomplete() {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'https://api.cloud.minervatech.uy', true);
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

// This example requires the Drawing library. Include the libraries=drawing
// parameter when you first load the API. For example:
// <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&libraries=drawing">
let drawingManager = null;
let selectedShape = null;

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
    var area = google.maps.geometry.spherical.computeArea(
    selectedShape.getPath()
    );
    if (parseInt(areaAnterior) - parseInt(area) > 0) {
    document.getElementById("value-1").innerHTML =
        parseInt(areaAnterior) - parseInt(area);
    } else {
    document.getElementById("value-1").innerHTML = 0;
    }
    selectedShape.setMap(null);
}
}

function initMap() {
var latitude = parseFloat(document.getElementById("latitude").value);
var longitude = parseFloat(document.getElementById("longitude").value);
var zoom = parseFloat(document.getElementById("zoom").value);

var posicion = { lat: latitude, lng: longitude };

const map = new google.maps.Map(document.getElementById("map"), {
    zoom: zoom,
    tilt: 0,
    center: posicion,
    mapTypeControl: false,
rotateControl: false,
streetViewControl: false,
    mapTypeId: "hybrid",
});

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

google.maps.event.addListener(
    drawingManager,
    "overlaycomplete",
    function (e) {
    if (e.type != google.maps.drawing.OverlayType.MARKER) {
        // Switch back to non-drawing mode after drawing a shape.
        drawingManager.setDrawingMode(null);
        // Add an event listener that selects the newly-drawn shape when the user mouses down on it.
        var newShape = e.overlay;
        newShape.type = e.type;
        google.maps.event.addListener(newShape, "click", function () {
        setSelection(newShape);
        });
        var area = google.maps.geometry.spherical.computeArea(
        newShape.getPath()
        );
        var areaAnterior = document.getElementById("value-1").innerHTML;
        document.getElementById("value-1").innerHTML =
        parseInt(areaAnterior) + parseInt(area);
        document.getElementById("hidden-value-1").value =
        parseInt(areaAnterior) + parseInt(area);
        setSelection(newShape);
    }
    }
);
google.maps.event.addListener(
    drawingManager,
    "drawingmode_changed",
    clearSelection
);
google.maps.event.addListener(map, "click", clearSelection);
google.maps.event.addDomListener(
    document.getElementById("borrar"),
    "click",
    deleteSelectedShape
);
drawingManager.setMap(map);
}

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