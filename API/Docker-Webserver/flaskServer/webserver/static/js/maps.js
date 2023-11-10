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

  var posicion = { lat: latitude, lng: longitude };

  const map = new google.maps.Map(document.getElementById("map"), {
    zoom: 19,
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