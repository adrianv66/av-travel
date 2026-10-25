// Draws numbered pins joined by a dashed line on a Leaflet map.
// points: [{ lat, lng, label, popup }]
window.avMap = function (elementId, points) {
  var el = document.getElementById(elementId);
  if (!el || !window.L) return;
  points = (points || []).filter(function (p) {
    return p && typeof p.lat === 'number' && typeof p.lng === 'number';
  });
  if (points.length === 0) { el.style.display = 'none'; return; }

  var map = L.map(el, { scrollWheelZoom: false });
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attribution: '&copy; OpenStreetMap contributors'
  }).addTo(map);

  var line = [];
  points.forEach(function (p) {
    var ll = [p.lat, p.lng];
    line.push(ll);
    L.marker(ll, {
      icon: L.divIcon({ className: 'stop-pin', html: String(p.label), iconSize: [26, 26] })
    }).addTo(map).bindPopup(p.popup || '');
  });

  if (line.length > 1) {
    L.polyline(line, { color: '#c2562b', weight: 3, dashArray: '6 6' }).addTo(map);
    map.fitBounds(line, { padding: [30, 30] });
  } else {
    map.setView(line[0], 15);
  }
};

window.avEscape = function (s) {
  return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
    return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
  });
};
