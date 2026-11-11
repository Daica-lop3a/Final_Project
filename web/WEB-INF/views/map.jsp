<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Google-Style Smart Waste Map - SmartWaste</title>
    
    <!-- Leaflet CSS -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=20261019-v1" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            background: #EDF8F2;
            margin: 0;
        }

        .map-wrapper {
            position: relative;
            height: calc(100vh - 120px);
            width: 100%;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
            border: 1px solid #dadce0;
            background: #e5e3df;
        }

        #map {
            height: 100%;
            width: 100%;
            z-index: 1;
        }

        /* Google Maps Floating Search Bar */
        .gmap-search-bar {
            position: absolute;
            top: 14px;
            left: 14px;
            z-index: 1000;
            display: flex;
            align-items: center;
            background: #ffffff;
            border-radius: 8px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.3);
            width: calc(100% - 28px);
            max-width: 440px;
            height: 48px;
            padding: 0 12px;
            box-sizing: border-box;
            transition: box-shadow 0.2s ease;
        }

        .gmap-search-bar:focus-within {
            box-shadow: 0 4px 12px rgba(0,0,0,0.25);
        }

        .gmap-search-input {
            flex: 1;
            border: none;
            outline: none;
            font-size: 15px;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            color: #202124;
            padding: 0 8px;
            background: transparent;
        }

        .gmap-search-btn {
            background: none;
            border: none;
            color: #5f6368;
            cursor: pointer;
            padding: 8px;
            display: grid;
            place-items: center;
            font-size: 16px;
        }

        .gmap-search-btn:hover {
            color: #1a73e8;
        }

        /* Google Maps Style Layer Switcher (Map / Satellite) */
        .gmap-layer-switch {
            position: absolute;
            top: 72px;
            left: 14px;
            z-index: 1000;
            display: flex;
            background: #ffffff;
            border-radius: 6px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.25);
            overflow: hidden;
            border: 1px solid #dadce0;
        }

        .gmap-layer-btn {
            background: #ffffff;
            border: none;
            padding: 7px 14px;
            font-size: 12px;
            font-weight: 600;
            color: #3c4043;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 6px;
            transition: all 0.15s ease;
        }

        .gmap-layer-btn.active {
            background: #e8f0fe;
            color: #1a73e8;
            font-weight: 700;
        }

        /* Google Maps Filter Chips Bar */
        .gmap-filter-chips {
            position: absolute;
            top: 14px;
            right: 14px;
            z-index: 1000;
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
            justify-content: flex-end;
            max-width: 60%;
        }

        .gmap-chip {
            background: #ffffff;
            border: 1px solid #dadce0;
            border-radius: 18px;
            padding: 6px 14px;
            font-size: 12px;
            font-weight: 600;
            color: #3c4043;
            box-shadow: 0 1px 4px rgba(0,0,0,0.15);
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: all 0.15s ease;
            text-decoration: none;
        }

        .gmap-chip:hover, .gmap-chip.active {
            background: #e8f0fe;
            color: #1a73e8;
            border-color: #1a73e8;
        }

        .gmap-chip-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
        }

        /* Google Maps Floating Action Controls (Bottom Right) */
        .gmap-controls {
            position: absolute;
            bottom: 24px;
            right: 16px;
            z-index: 1000;
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .gmap-btn-group {
            display: flex;
            flex-direction: column;
            background: #ffffff;
            border-radius: 6px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.3);
            border: 1px solid #dadce0;
            overflow: hidden;
        }

        .gmap-ctrl-btn {
            width: 40px;
            height: 40px;
            background: #ffffff;
            border: none;
            color: #5f6368;
            font-size: 16px;
            display: grid;
            place-items: center;
            cursor: pointer;
            transition: background 0.15s ease, color 0.15s ease;
        }

        .gmap-ctrl-btn:hover {
            background: #f1f3f4;
            color: #202124;
        }

        .gmap-ctrl-btn + .gmap-ctrl-btn {
            border-top: 1px solid #e8eaed;
        }

        .gmap-single-btn {
            width: 40px;
            height: 40px;
            background: #ffffff;
            border-radius: 6px;
            border: 1px solid #dadce0;
            box-shadow: 0 2px 6px rgba(0,0,0,0.3);
            color: #5f6368;
            font-size: 16px;
            display: grid;
            place-items: center;
            cursor: pointer;
            transition: background 0.15s ease, color 0.15s ease;
        }

        .gmap-single-btn:hover {
            background: #f1f3f4;
            color: #1a73e8;
        }

        /* Google Maps Style Teardrop Markers */
        .gmap-pin-container {
            display: flex;
            flex-direction: column;
            align-items: center;
            cursor: pointer;
            filter: drop-shadow(0 2px 5px rgba(0,0,0,0.35));
            transition: transform 0.15s ease;
        }

        .gmap-pin-container:hover {
            transform: scale(1.18) translateY(-4px);
        }

        .gmap-pin-badge {
            width: 32px;
            height: 32px;
            border-radius: 50% 50% 50% 0;
            transform: rotate(-45deg);
            display: grid;
            place-items: center;
            border: 2px solid #ffffff;
            color: #ffffff;
            font-size: 13px;
        }

        .gmap-pin-badge i {
            transform: rotate(45deg);
        }

        .pin-green { background: #0F9D58; }
        .pin-yellow { background: #F4B400; }
        .pin-red { background: #EA4335; }
        .pin-gray { background: #5F6368; }

        /* Google Maps Infowindow (Popup) */
        .leaflet-popup-content-wrapper {
            padding: 0 !important;
            border-radius: 8px !important;
            box-shadow: 0 3px 14px rgba(0,0,0,0.28) !important;
            overflow: hidden;
        }

        .leaflet-popup-content {
            margin: 0 !important;
            line-height: 1.4 !important;
            width: 280px !important;
        }

        .gmap-infowindow {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            color: #202124;
        }

        .gmap-info-header {
            padding: 14px 16px 12px;
            border-bottom: 1px solid #f1f3f4;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .gmap-info-title {
            font-size: 16px;
            font-weight: 700;
            color: #202124;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .gmap-info-badge {
            font-size: 11px;
            font-weight: 700;
            padding: 2px 6px;
            border-radius: 4px;
            color: white;
        }

        .gmap-info-body {
            padding: 12px 16px;
            font-size: 13px;
            color: #3c4043;
        }

        .gmap-info-row {
            display: flex;
            align-items: flex-start;
            gap: 8px;
            margin-bottom: 6px;
        }

        .gmap-info-row i {
            color: #5f6368;
            margin-top: 2px;
            width: 14px;
            text-align: center;
        }

        .gmap-info-progress {
            margin: 8px 0;
            height: 8px;
            background: #e8eaed;
            border-radius: 4px;
            overflow: hidden;
        }

        .gmap-info-fill {
            height: 100%;
            border-radius: 4px;
        }

        .gmap-info-actions {
            padding: 10px 16px;
            background: #f8f9fa;
            border-top: 1px solid #f1f3f4;
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }

        .leaflet-popup-content .gmap-btn,
        .gmap-btn {
            padding: 7px 14px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 700;
            text-decoration: none !important;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            cursor: pointer;
            border: 1px solid transparent;
            box-sizing: border-box;
            line-height: 1.4;
            transition: all 0.2s ease;
        }

        .leaflet-container a.gmap-btn-primary,
        .leaflet-popup-content a.gmap-btn-primary,
        .leaflet-popup-content .gmap-btn-primary,
        a.gmap-btn-primary,
        .gmap-btn-primary {
            background: #1a73e8 !important;
            color: #ffffff !important;
        }

        .leaflet-container a.gmap-btn-primary i,
        .leaflet-popup-content a.gmap-btn-primary i,
        .gmap-btn-primary i {
            color: #ffffff !important;
        }

        .leaflet-container a.gmap-btn-primary:hover,
        .leaflet-popup-content a.gmap-btn-primary:hover,
        .gmap-btn-primary:hover {
            background: #1557b0 !important;
            color: #ffffff !important;
        }

        .leaflet-popup-content .gmap-btn-qr,
        button.gmap-btn-qr,
        .gmap-btn-qr {
            background: #166534 !important;
            color: #ffffff !important;
        }

        .leaflet-popup-content .gmap-btn-qr i,
        button.gmap-btn-qr i,
        .gmap-btn-qr i {
            color: #ffffff !important;
        }

        .leaflet-popup-content .gmap-btn-qr:hover,
        button.gmap-btn-qr:hover,
        .gmap-btn-qr:hover {
            background: #14532d !important;
            color: #ffffff !important;
        }

        .leaflet-container a.gmap-btn-secondary,
        .leaflet-popup-content a.gmap-btn-secondary,
        .gmap-btn-secondary {
            background: #ffffff !important;
            border: 1px solid #dadce0 !important;
            color: #3c4043 !important;
        }

        .leaflet-container a.gmap-btn-secondary i,
        .leaflet-popup-content a.gmap-btn-secondary i,
        .gmap-btn-secondary i {
            color: #e37400 !important;
        }

        .leaflet-container a.gmap-btn-secondary:hover,
        .leaflet-popup-content a.gmap-btn-secondary:hover,
        .gmap-btn-secondary:hover {
            background: #f1f3f4 !important;
            color: #202124 !important;
        }
    </style>
</head>
<body>
    <div class="app-layout">
        <jsp:include page="/WEB-INF/views/sidebar.jsp" />

        <div class="main-content" style="padding: 16px 20px;">
            <div class="content-header" style="margin-bottom: 12px; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 10px;">
                <div style="display: flex; align-items: center; gap: 12px;">
                    <button type="button" class="desktop-nav-toggle" onclick="toggleSidebarCollapse()" title="Toggle Sidebar">
                        <i class="fa-solid fa-bars"></i>
                    </button>
                    <div>
                        <h1 style="font-size: 20px; font-weight: 800; margin: 0; color: #1e293b; display: flex; align-items: center; gap: 8px;">
                            <i class="fa-solid fa-map-location-dot" style="color: #1a73e8;"></i>
                            Live Waste Monitoring Map
                        </h1>
                        <span style="font-size: 12px; color: #64748b;">
                            Google-powered geospatial tracking &amp; receptacle telemetry
                        </span>
                    </div>
                </div>

                <div style="display: flex; align-items: center; gap: 10px;">
                    <div id="liveTelemetryIndicator" style="display: inline-flex; align-items: center; gap: 6px; padding: 6px 12px; background: #DCFCE7; border: 1px solid #86EFAC; border-radius: 999px; font-size: 11.5px; font-weight: 700; color: #166534; transition: all 0.3s ease;">
                        <span style="width: 8px; height: 8px; border-radius: 50%; background: #16A34A; display: inline-block; box-shadow: 0 0 0 2px rgba(22,163,74,0.3);"></span>
                        <span>LIVE SENSOR STREAM</span>
                    </div>
                    <a href="${pageContext.request.contextPath}/wastebin" class="btn" style="padding: 7px 14px; font-size: 13px; text-decoration: none; border-radius: 6px; border: 1px solid #cbd5e1; background: #ffffff; color: #334155;">
                        <i class="fa-solid fa-table-list"></i> Table View
                    </a>
                </div>
            </div>

            <!-- Map Container -->
            <div class="map-wrapper" id="mapWrapper">
                <div id="map"></div>

                <!-- Google Maps Floating Search Bar -->
                <div class="gmap-search-bar">
                    <button type="button" class="gmap-search-btn" title="Search"><i class="fa-solid fa-magnifying-glass"></i></button>
                    <input type="text" id="gmapSearchInput" class="gmap-search-input" placeholder="Search bin code, zone, or address..." oninput="filterMarkers()">
                    <button type="button" class="gmap-search-btn" onclick="clearSearch()" title="Clear search"><i class="fa-solid fa-xmark"></i></button>
                </div>

                <!-- Google Maps Style Layer Switcher -->
                <div class="gmap-layer-switch">
                    <button type="button" id="btnRoadmap" class="gmap-layer-btn active" onclick="setMapLayer('roadmap')">
                        <i class="fa-solid fa-map"></i> Map
                    </button>
                    <button type="button" id="btnSatellite" class="gmap-layer-btn" onclick="setMapLayer('satellite')">
                        <i class="fa-solid fa-satellite"></i> Satellite
                    </button>
                </div>

                <!-- Google Maps Filter Chips -->
                <div class="gmap-filter-chips">
                    <button type="button" class="gmap-chip active" onclick="setFilter('all', this)">
                        All (<span id="countTotal">0</span>)
                    </button>
                    <button type="button" class="gmap-chip" onclick="setFilter('urgent', this)">
                        <span class="gmap-chip-dot" style="background: #EA4335;"></span> Urgent: <span id="countUrgent">0</span>
                    </button>
                    <button type="button" class="gmap-chip" onclick="setFilter('attention', this)">
                        <span class="gmap-chip-dot" style="background: #F4B400;"></span> Attention: <span id="countAttention">0</span>
                    </button>
                    <button type="button" class="gmap-chip" onclick="setFilter('normal', this)">
                        <span class="gmap-chip-dot" style="background: #0F9D58;"></span> Normal: <span id="countNormal">0</span>
                    </button>
                </div>

                <!-- Google Maps Floating Controls -->
                <div class="gmap-controls">
                    <button type="button" class="gmap-single-btn" onclick="locateUserPosition()" title="Your Location (GPS)">
                        <i class="fa-solid fa-crosshairs"></i>
                    </button>
                    <button type="button" class="gmap-single-btn" onclick="toggleMapFullscreen()" title="Toggle Fullscreen">
                        <i class="fa-solid fa-expand"></i>
                    </button>
                    <div class="gmap-btn-group">
                        <button type="button" class="gmap-ctrl-btn" onclick="zoomIn()" title="Zoom In"><i class="fa-solid fa-plus"></i></button>
                        <button type="button" class="gmap-ctrl-btn" onclick="zoomOut()" title="Zoom Out"><i class="fa-solid fa-minus"></i></button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- RECEPTACLE QR MODAL (INSTANT ON-SITE SCANNING) -->
    <div id="mapBinQrModal" style="display: none; position: fixed; inset: 0; background: rgba(5, 5, 5, 0.6); backdrop-filter: blur(4px); z-index: 99999; align-items: center; justify-content: center;">
        <div style="background: #ffffff; border-radius: 12px; padding: 26px; width: 90%; max-width: 360px; text-align: center; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.25); position: relative; border: 1px solid #D1EBCF;">
            <button type="button" onclick="closeMapQrModal()" style="position: absolute; top: 12px; right: 12px; border: none; background: none; font-size: 22px; color: #65676B; cursor: pointer;">&times;</button>
            <div style="font-size: 11px; font-weight: 800; text-transform: uppercase; letter-spacing: 1px; color: #00875A; margin-bottom: 6px;">Smart Receptacle QR Badge</div>
            <h3 id="mapModalBinCode" style="margin: 0 0 12px; font-size: 22px; font-family: monospace; font-weight: 800; color: #050505;"></h3>
            <div style="background: #ffffff; padding: 10px; border-radius: 8px; border: 1px solid #D1EBCF; display: inline-block; margin-bottom: 12px;">
                <img id="mapModalQrImg" src="" alt="Bin QR Code" style="width: 190px; height: 190px; display: block;">
            </div>
            <div id="mapModalBinId" style="font-size: 12px; font-weight: 700; color: #65676B; margin-bottom: 4px;"></div>
            <p id="mapModalBinLoc" style="font-size: 13px; color: #1C1E21; margin: 0 0 16px;"></p>
            <div style="display: flex; gap: 8px; justify-content: center;">
                <button type="button" onclick="printMapQr()" class="btn btn-primary" style="padding: 8px 16px; font-size: 13px; background: #00875A; color: white; border: none; border-radius: 6px; font-weight: 700; cursor: pointer;">
                    <i class="fa-solid fa-print"></i> Print Sticker
                </button>
                <button type="button" onclick="closeMapQrModal()" class="btn btn-light" style="padding: 8px 16px; font-size: 13px; border: 1px solid #D1EBCF; border-radius: 6px; cursor: pointer; background: #FFFFFF; color: #050505;">
                    Close
                </button>
            </div>
        </div>
    </div>

    <!-- Leaflet JS -->
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script>
        // Waste bin data from server
        var rawBins = [
            <c:forEach var="b" items="${bins}" varStatus="loop">
            {
                binID: "${b.binID}",
                binCode: "${b.binCode}",
                location: "${b.location}",
                lat: ${b.latitude != null ? b.latitude : 0},
                lng: ${b.longitude != null ? b.longitude : 0},
                capacity: ${b.capacity},
                fill: ${b.currentFill},
                status: "${b.status}",
                areaName: "${b.areaName}"
            }<c:if test="${!loop.last}">,</c:if>
            </c:forEach>
        ];

        // Default coordinate: FPT University HCMC (Saigon Hi-Tech Park)
        var defaultCenter = [10.841128, 106.809883];
        var validBins = rawBins.filter(function(b) { return b.lat && b.lng && b.lat !== 0 && b.lng !== 0; });
        if (validBins.length > 0) {
            defaultCenter = [validBins[0].lat, validBins[0].lng];
        }

        document.getElementById('countTotal').innerText = validBins.length;

        // Initialize Leaflet with Google Maps options
        var map = L.map('map', {
            zoomControl: false // Using custom Google Maps controls
        }).setView(defaultCenter, 16);

        // Google Maps Tile Layers
        var googleRoadmap = L.tileLayer('https://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}', {
            maxZoom: 20,
            subdomains: ['mt0', 'mt1', 'mt2', 'mt3'],
            attribution: 'Map data &copy; <a href="https://maps.google.com" target="_blank">Google</a>'
        });

        var googleSatellite = L.tileLayer('https://{s}.google.com/vt/lyrs=y&x={x}&y={y}&z={z}', {
            maxZoom: 20,
            subdomains: ['mt0', 'mt1', 'mt2', 'mt3'],
            attribution: 'Map data &copy; <a href="https://maps.google.com" target="_blank">Google</a>'
        });

        // Add default roadmap layer
        googleRoadmap.addTo(map);

        function setMapLayer(type) {
            if (type === 'roadmap') {
                map.removeLayer(googleSatellite);
                map.addLayer(googleRoadmap);
                document.getElementById('btnRoadmap').classList.add('active');
                document.getElementById('btnSatellite').classList.remove('active');
            } else {
                map.removeLayer(googleRoadmap);
                map.addLayer(googleSatellite);
                document.getElementById('btnSatellite').classList.add('active');
                document.getElementById('btnRoadmap').classList.remove('active');
            }
        }

        function zoomIn() { map.zoomIn(); }
        function zoomOut() { map.zoomOut(); }

        function toggleMapFullscreen() {
            var el = document.getElementById('mapWrapper');
            if (!document.fullscreenElement) {
                el.requestFullscreen().catch(function(){});
            } else {
                document.exitFullscreen().catch(function(){});
            }
        }

        function locateUserPosition() {
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(function (position) {
                    var userLat = position.coords.latitude;
                    var userLng = position.coords.longitude;
                    map.setView([userLat, userLng], 17);

                    L.circleMarker([userLat, userLng], {
                        radius: 8,
                        fillColor: '#1a73e8',
                        color: '#ffffff',
                        weight: 3,
                        opacity: 1,
                        fillOpacity: 1
                    }).addTo(map).bindPopup("<b>Your Current Location</b>").openPopup();
                }, function (err) {
                    alert("Unable to retrieve location: " + err.message);
                });
            } else {
                alert("Geolocation is not supported by your browser.");
            }
        }

        // Marker rendering with Google Maps teardrop pins
        var markerObjects = [];

        function getPinColor(fill, status) {
            if (status === 'Maintenance') return { color: '#5F6368', cls: 'pin-gray', label: 'Maintenance' };
            if (fill >= 85) return { color: '#EA4335', cls: 'pin-red', label: 'Urgent' };
            if (fill >= 60) return { color: '#F4B400', cls: 'pin-yellow', label: 'Attention' };
            return { color: '#0F9D58', cls: 'pin-green', label: 'Normal' };
        }

        function renderMarkers() {
            // Clear existing
            markerObjects.forEach(function(m) { map.removeLayer(m.marker); });
            markerObjects = [];

            validBins.forEach(function (bin) {
                var pinInfo = getPinColor(bin.fill, bin.status);

                var iconHtml = '<div class="gmap-pin-container">' +
                    '<div class="gmap-pin-badge ' + pinInfo.cls + '">' +
                        '<i class="fa-solid fa-trash-can"></i>' +
                    '</div>' +
                '</div>';

                var customIcon = L.divIcon({
                    html: iconHtml,
                    className: 'gmap-custom-div-icon',
                    iconSize: [32, 38],
                    iconAnchor: [16, 36],
                    popupAnchor: [0, -32]
                });

                var marker = L.marker([bin.lat, bin.lng], { icon: customIcon }).addTo(map);

                // Google Maps styled InfoWindow
                var popupHtml = '<div class="gmap-infowindow">' +
                    '<div class="gmap-info-header">' +
                        '<span class="gmap-info-title">' +
                            '<i class="fa-solid fa-trash-can" style="color: ' + pinInfo.color + ';"></i>' +
                            bin.binCode +
                        '</span>' +
                        '<span class="gmap-info-badge ' + pinInfo.cls + '">' + pinInfo.label + '</span>' +
                    '</div>' +
                    '<div class="gmap-info-body">' +
                        '<div class="gmap-info-row">' +
                            '<i class="fa-solid fa-location-dot"></i>' +
                            '<span>' + bin.location + '</span>' +
                        '</div>' +
                        '<div class="gmap-info-row">' +
                            '<i class="fa-solid fa-layer-group"></i>' +
                            '<span>' + (bin.areaName || 'General Campus Zone') + '</span>' +
                        '</div>' +
                        '<div class="gmap-info-row" style="margin-top: 8px; justify-content: space-between; font-weight: 700;">' +
                            '<span>Current Fill: ' + bin.fill + '%</span>' +
                            '<span style="color: #5f6368;">' + (bin.capacity || 100) + ' L</span>' +
                        '</div>' +
                        '<div class="gmap-info-progress">' +
                            '<div class="gmap-info-fill ' + pinInfo.cls + '" style="width: ' + bin.fill + '%;"></div>' +
                        '</div>' +
                    '</div>' +
                    '<div class="gmap-info-actions">' +
                        '<a href="${pageContext.request.contextPath}/wastebin/view?id=' + bin.binID + '" class="gmap-btn gmap-btn-primary" style="color: #ffffff !important; text-decoration: none !important;">' +
                            '<i class="fa-solid fa-circle-info" style="color: #ffffff !important;"></i> Details' +
                        '</a>' +
                        '<button type="button" onclick="openMapBinQr(\'' + bin.binCode + '\', \'' + bin.binID + '\', \'' + (bin.location || '').replace(/'/g, "\\'") + '\')" class="gmap-btn gmap-btn-qr" style="color: #ffffff !important;">' +
                            '<i class="fa-solid fa-qrcode" style="color: #ffffff !important;"></i> Show QR' +
                        '</button>' +
                        <c:if test="${sessionScope.user.citizen}">
                        '<a href="${pageContext.request.contextPath}/citizen-report/create?binID=' + bin.binID + '" class="gmap-btn gmap-btn-secondary" style="color: #3c4043 !important; text-decoration: none !important;">' +
                            '<i class="fa-solid fa-bullhorn" style="color: #e37400 !important;"></i> Report' +
                        '</a>' +
                        </c:if>
                    '</div>' +
                '</div>';

                marker.bindPopup(popupHtml);
                markerObjects.push({ bin: bin, marker: marker });
            });

            if (markerObjects.length > 0) {
                var group = new L.featureGroup(markerObjects.map(function(m){ return m.marker; }));
                map.fitBounds(group.getBounds().pad(0.15));
            }
        }

        renderMarkers();

        // Real-time Sensor Polling (every 3.5 seconds)
        function pollLiveTelemetry() {
            fetch('${pageContext.request.contextPath}/api/bins-location?t=' + Date.now())
                .then(function(res) {
                    if (!res.ok) throw new Error('Status ' + res.status);
                    return res.json();
                })
                .then(function(liveBins) {
                    if (!Array.isArray(liveBins)) return;

                    var hasChange = false;
                    var binMap = {};
                    liveBins.forEach(function(b) { binMap[b.binID] = b; });

                    var urgent = 0, attention = 0, normal = 0;

                    markerObjects.forEach(function(obj) {
                        var bin = obj.bin;
                        var live = binMap[bin.binID];
                        if (live) {
                            var newFill = Math.round(live.currentFill);
                            var newStatus = live.status;
                            if (bin.fill !== newFill || bin.status !== newStatus) {
                                bin.fill = newFill;
                                bin.status = newStatus;
                                hasChange = true;

                                var pinInfo = getPinColor(bin.fill, bin.status);
                                var newIcon = L.divIcon({
                                    html: '<div class="gmap-pin-container"><div class="gmap-pin-badge ' + pinInfo.cls + '"><i class="fa-solid fa-trash-can"></i></div></div>',
                                    className: 'gmap-custom-div-icon',
                                    iconSize: [32, 38],
                                    iconAnchor: [16, 36],
                                    popupAnchor: [0, -32]
                                });
                                obj.marker.setIcon(newIcon);

                                var updatedPopup = '<div class="gmap-infowindow" id="popup-bin-' + bin.binID + '">' +
                                    '<div class="gmap-info-header">' +
                                        '<span class="gmap-info-title"><i class="fa-solid fa-trash-can" style="color: ' + pinInfo.color + ';"></i> ' + bin.binCode + '</span>' +
                                        '<span class="gmap-info-badge ' + pinInfo.cls + '">' + pinInfo.label + '</span>' +
                                    '</div>' +
                                    '<div class="gmap-info-body">' +
                                        '<div class="gmap-info-row"><i class="fa-solid fa-location-dot"></i><span>' + (bin.location || 'Campus Receptacle') + '</span></div>' +
                                        '<div class="gmap-info-row"><i class="fa-solid fa-layer-group"></i><span>' + (bin.areaName || 'General Campus Zone') + '</span></div>' +
                                        '<div class="gmap-info-row" style="margin-top: 8px; justify-content: space-between; font-weight: 700;">' +
                                            '<span>Current Fill: ' + bin.fill + '%</span>' +
                                            '<span style="color: #5f6368;">' + (bin.capacity || 100) + ' L</span>' +
                                        '</div>' +
                                        '<div class="gmap-info-progress"><div class="gmap-info-fill ' + pinInfo.cls + '" style="width: ' + bin.fill + '%;"></div></div>' +
                                    '</div>' +
                                    '<div class="gmap-info-actions">' +
                                        '<a href="${pageContext.request.contextPath}/wastebin/detail?binID=' + bin.binID + '" class="gmap-btn gmap-btn-primary" style="color: #ffffff !important; text-decoration: none !important;">' +
                                            '<i class="fa-solid fa-circle-info" style="color: #ffffff !important;"></i> Details' +
                                        '</a>' +
                                        '<button type="button" onclick="openMapBinQr(\'' + bin.binCode + '\', \'' + bin.binID + '\', \'' + (bin.location || '').replace(/'/g, "\\'") + '\')" class="gmap-btn gmap-btn-qr" style="color: #ffffff !important;">' +
                                            '<i class="fa-solid fa-qrcode" style="color: #ffffff !important;"></i> Show QR' +
                                        '</button>' +
                                    '</div>' +
                                '</div>';
                                obj.marker.setPopupContent(updatedPopup);
                            }
                        }

                        if (bin.status !== 'Maintenance') {
                            if (bin.fill >= 85) urgent++;
                            else if (bin.fill >= 60) attention++;
                            else normal++;
                        }
                    });

                    var urgentChip = document.getElementById('countUrgent');
                    if (urgentChip) urgentChip.innerText = urgent;
                    var attnChip = document.getElementById('countAttention');
                    if (attnChip) attnChip.innerText = attention;
                    var normChip = document.getElementById('countNormal');
                    if (normChip) normChip.innerText = normal;

                    if (hasChange) {
                        filterMarkers();
                        var pill = document.getElementById('liveTelemetryIndicator');
                        if (pill) {
                            pill.style.background = '#BBF7D0';
                            setTimeout(function() { pill.style.background = '#DCFCE7'; }, 800);
                        }
                    }
                })
                .catch(function(err) {});
        }

        setInterval(pollLiveTelemetry, 3500);

        // Search & Filter
        var currentFilter = 'all';

        function setFilter(type, btn) {
            currentFilter = type;
            document.querySelectorAll('.gmap-chip').forEach(function(c) { c.classList.remove('active'); });
            if (btn) btn.classList.add('active');
            filterMarkers();
        }

        function filterMarkers() {
            var query = document.getElementById('gmapSearchInput').value.trim().toLowerCase();

            markerObjects.forEach(function (obj) {
                var bin = obj.bin;
                var matchesQuery = !query || 
                    (bin.binCode && bin.binCode.toLowerCase().indexOf(query) !== -1) ||
                    (bin.location && bin.location.toLowerCase().indexOf(query) !== -1) ||
                    (bin.areaName && bin.areaName.toLowerCase().indexOf(query) !== -1);

                var matchesFilter = true;
                if (currentFilter === 'urgent') matchesFilter = (bin.fill >= 85 && bin.status !== 'Maintenance');
                else if (currentFilter === 'attention') matchesFilter = (bin.fill >= 60 && bin.fill < 85 && bin.status !== 'Maintenance');
                else if (currentFilter === 'normal') matchesFilter = (bin.fill < 60 && bin.status !== 'Maintenance');

                if (matchesQuery && matchesFilter) {
                    if (!map.hasLayer(obj.marker)) map.addLayer(obj.marker);
                } else {
                    if (map.hasLayer(obj.marker)) map.removeLayer(obj.marker);
                }
            });
        }

        function clearSearch() {
            document.getElementById('gmapSearchInput').value = '';
            filterMarkers();
        }

        // QR Code Badge Preview & Print
        var curMapQrCode = "";
        var curMapQrLoc = "";

        function openMapBinQr(binCode, binId, location) {
            curMapQrCode = binCode;
            curMapQrLoc = location;
            document.getElementById('mapModalBinCode').innerText = binCode;
            document.getElementById('mapModalBinId').innerText = "Internal Receptacle ID: #" + binId;
            document.getElementById('mapModalBinLoc').innerText = location;
            var mapQrImg = document.getElementById('mapModalQrImg');
            mapQrImg.onerror = function() {
                this.onerror = null;
                this.src = 'https://quickchart.io/qr?size=250&text=' + encodeURIComponent(binCode);
            };
            mapQrImg.src = 'https://api.qrserver.com/v1/create-qr-code/?size=250x250&margin=8&data=' + encodeURIComponent(binCode);
            document.getElementById('mapBinQrModal').style.display = 'flex';
        }

        function closeMapQrModal() {
            document.getElementById('mapBinQrModal').style.display = 'none';
        }

        function printMapQr() {
            var qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&margin=8&data=' + encodeURIComponent(curMapQrCode);
            var win = window.open('', 'PRINT', 'height=650,width=650');
            win.document.write('<!DOCTYPE html><html><head><title>Print QR Badge - ' + curMapQrCode + '</title>');
            win.document.write('<style>body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; text-align: center; padding: 40px; background: #f8fafc; } .sticker { border: 3px solid #0f172a; border-radius: 18px; padding: 28px; max-width: 320px; margin: 0 auto; background: white; box-shadow: 0 4px 12px rgba(0,0,0,0.1); } img { width: 220px; height: 220px; display: block; margin: 0 auto; } .code { font-size: 26px; font-weight: 900; font-family: monospace; margin: 14px 0 4px; color: #0f172a; } .loc { font-size: 13px; color: #475569; margin-top: 4px; } .brand { font-size: 11px; font-weight: 800; letter-spacing: 2px; color: #64748b; margin-top: 18px; border-top: 1px dashed #cbd5e1; padding-top: 10px; text-transform: uppercase; } @media print { body { background: none; padding: 0; } .sticker { box-shadow: none; } }</style>');
            win.document.write('</head><body><div class="sticker">');
            win.document.write('<img src="' + qrUrl + '"/>');
            win.document.write('<div class="code">' + curMapQrCode + '</div>');
            win.document.write('<div class="loc">' + curMapQrLoc + '</div>');
            win.document.write('<div class="brand">SmartWaste • IoT Receptacle Verification</div>');
            win.document.write('</div></body></html>');
            win.document.close();
            win.focus();
            setTimeout(function() { win.print(); win.close(); }, 400);
        }
    </script>
</body>
</html>
