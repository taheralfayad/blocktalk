import maplibregl from 'maplibre-gl';

let map = null;

export function initMap(container) {

  const ORLANDO = [-81.3792, 28.5383];

  const stored = localStorage.getItem("userLocation");
  const center = stored ? (() => {
    const { lng, lat } = JSON.parse(stored);
    return [lng, lat];
  })() : ORLANDO;

  map = new maplibregl.Map({
    container,
    style: 'https://tiles.openfreemap.org/styles/liberty',
    center: center,
    zoom: 10,
    attributionControl: false,
    dragRotate: false,
    touchZoomRotate: true
  });

  map.addControl(new maplibregl.NavigationControl({ showCompass: false }), 'top-right');

  map.addControl(new maplibregl.GeolocateControl({
    positionOptions: { enableHighAccuracy: true },
    trackUserLocation: true,
    showAccuracyCircle: true
  }), 'top-right');

  map.on('load', () => {
    map.touchZoomRotate.disableRotation();
  })

  return map;
}

export function getMap() {
  return map;
}

export function destroyMap() {
  if (map) {
    map.remove();
    map = null;
  }
}
