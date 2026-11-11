<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${isEdit ? 'Edit Sanitation Feedback' : 'Submit Sanitation Feedback'} - SmartWaste</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <!-- Leaflet CSS for Interactive Location Pinpoint -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
</head>
<body style="background: var(--page); margin: 0;">

    <div class="app-shell">
        <!-- SIDEBAR NAVIGATION -->
        <jsp:include page="/WEB-INF/views/sidebar.jsp" />

        <!-- MAIN FORM CONTENT -->
        <main class="smartwaste-form-page">
            <div class="smartwaste-form-container">
                
                <!-- BREADCRUMB & HEADER -->
                <div class="form-header-box">
                    <div class="form-breadcrumb">
                        <a href="${pageContext.request.contextPath}/dashboard" style="color: var(--color-slate-400);">Dashboard</a>
                        <i class="fa-solid fa-chevron-right" style="font-size: 9px;"></i>
                        <a href="${pageContext.request.contextPath}/citizen-report" style="color: var(--color-slate-400);">Citizen Feedback</a>
                        <i class="fa-solid fa-chevron-right" style="font-size: 9px;"></i>
                        <span style="color: var(--brand-forest);">${isEdit ? 'Edit Report' : 'Submit Feedback'}</span>
                    </div>
                    <h1>${isEdit ? 'Edit Feedback Report' : 'Submit Sanitation &amp; Waste Report'}</h1>
                </div>

                <c:if test="${param.error == 'empty_fields'}">
                    <div style="padding: 12px 16px; background: #FEE2E2; border: 1px solid #FCA5A5; border-radius: 8px; color: #991B1B; font-size: 13px; font-weight: 600; margin-bottom: 20px; display: flex; align-items: center; gap: 8px;">
                        <i class="fa-solid fa-circle-exclamation"></i>
                        <span>Please fill in all required fields (Issue Category, Title, and Description).</span>
                    </div>
                </c:if>

                <!-- FORM CARD -->
                <div class="smartwaste-form-card">
                    <form action="${pageContext.request.contextPath}${isEdit ? '/citizen-report/update' : '/citizen-report/save'}" method="POST">
                        <c:if test="${isEdit}">
                            <input type="hidden" name="reportID" value="${report.reportID}" />
                        </c:if>

                        <div class="form-section-divider">
                            <i class="fa-solid fa-bullhorn"></i>
                            <span>Sanitation Issue Specification</span>
                        </div>

                        <div class="form-grid">
                            
                            <!-- Sequential Report ID Display -->
                            <div class="form-field">
                                <label class="form-label">
                                    Report Ticket ID <span class="required">*</span>
                                </label>
                                <input type="text" class="form-input"
                                       value="${isEdit ? report.reportID : NEXT_REPORT_ID}"
                                       readonly
                                       required>
                                <span class="form-hint">
                                    <i class="fa-solid fa-lock" style="font-size: 10px;"></i>
                                    Auto-assigned sequential feedback ticket ID.
                                </span>
                            </div>

                            <!-- Issue Category -->
                            <div class="form-field">
                                <label class="form-label" for="reportType">
                                    Issue Category <span class="required">*</span>
                                </label>
                                <select id="reportType" name="reportType" class="form-select" required>
                                    <option value="FULL_BIN" ${report.reportType == 'FULL_BIN' ? 'selected' : ''}>Waste Bin Full / Overflowing</option>
                                    <option value="DAMAGED_BIN" ${report.reportType == 'DAMAGED_BIN' ? 'selected' : ''}>Damaged Receptacle / Broken Pedal</option>
                                    <option value="DIRTY_AREA" ${report.reportType == 'DIRTY_AREA' ? 'selected' : ''}>Unhygienic Surrounding Campus Area</option>
                                    <option value="OTHER" ${report.reportType == 'OTHER' ? 'selected' : ''}>Other Cleanliness Concern</option>
                                </select>
                            </div>

                            <!-- Associated Smart Bin -->
                            <div class="form-field">
                                <label class="form-label" for="binSelect">
                                    Associated Waste Bin (Optional)
                                </label>
                                <select id="binSelect" name="binID" class="form-select" onchange="onBinChange(this)">
                                    <option value="" data-lat="" data-lng="">-- General Campus Area / None --</option>
                                    <c:forEach var="b" items="${bins}">
                                        <option value="${b.binID}" 
                                                data-lat="${b.latitude}" 
                                                data-lng="${b.longitude}"
                                                ${(preselectedBin == b.binID || report.binID == b.binID) ? 'selected' : ''}>
                                            ${b.binCode} (${b.location} - ${b.areaName})
                                        </option>
                                    </c:forEach>
                                </select>
                                <span class="form-hint">Linking a bin automatically snaps map coordinates to it.</span>
                            </div>

                            <!-- Campus Zone -->
                            <div class="form-field">
                                <label class="form-label" for="areaID">
                                    Campus Zone / Facility
                                </label>
                                <select id="areaID" name="areaID" class="form-select">
                                    <option value="">-- Select Campus Zone --</option>
                                    <c:forEach var="a" items="${areas}">
                                        <option value="${a.areaId}" ${(report.areaID == a.areaId) ? 'selected' : ''}>${a.areaName}</option>
                                    </c:forEach>
                                </select>
                            </div>

                            <!-- Report Title -->
                            <div class="form-field form-grid-full">
                                <label class="form-label" for="title">
                                    Report Title / Summary <span class="required">*</span>
                                </label>
                                <input type="text" id="title" name="title" class="form-input"
                                       value="${report.title}"
                                       placeholder="e.g. Alpha Hall main lobby recycling bin is overflowing"
                                       required />
                            </div>

                            <!-- Detailed Description -->
                            <div class="form-field form-grid-full">
                                <label class="form-label" for="description">
                                    Detailed Description <span class="required">*</span>
                                </label>
                                <textarea id="description" name="description" rows="3" class="form-textarea"
                                          placeholder="Describe current condition, exact landmark, odors, or hazard severity..."
                                          required>${report.description}</textarea>
                            </div>

                            <!-- Photo URL & Preview -->
                            <div class="form-field form-grid-full">
                                <label class="form-label" for="imageInput">
                                    <i class="fa-solid fa-camera"></i> Attached Photo Evidence (URL)
                                </label>
                                <div style="display: flex; gap: 10px;">
                                    <input type="url" id="imageInput" name="imageURL" class="form-input" style="flex: 1;"
                                           value="${report.imageURL}"
                                           placeholder="https://images.unsplash.com/... or paste image URL"
                                           oninput="updatePhotoPreview(this.value)" />
                                    <button type="button" class="btn-smart-secondary" style="padding: 0 16px; white-space: nowrap;" onclick="useSamplePhoto()">
                                        <i class="fa-solid fa-camera"></i> Sample Photo
                                    </button>
                                </div>
                                <div id="previewBox" style="display: ${not empty report.imageURL ? 'flex' : 'none'}; align-items: center; gap: 14px; margin-top: 10px; background: var(--color-m0601); padding: 12px 16px; border-radius: 8px; border: 1px dashed var(--color-m0573);">
                                    <img id="photoThumb" src="${report.imageURL}" alt="Preview" style="width: 70px; height: 70px; border-radius: 6px; object-fit: cover; border: 1px solid var(--color-m0573); background: #ffffff;" onerror="this.src='https://placehold.co/70x70?text=No+Image'" />
                                    <div style="font-size: 12px; color: var(--color-slate-600);">
                                        <strong style="color: var(--brand-forest);">Live Image Preview</strong>
                                        <div id="previewUrlText" style="font-size: 11px; color: var(--color-slate-400); word-break: break-all; margin-top: 2px;">${report.imageURL}</div>
                                    </div>
                                </div>
                            </div>

                            <!-- Interactive Map Picker -->
                            <div class="form-field form-grid-full">
                                <label class="form-label" style="display: flex; justify-content: space-between; align-items: center;">
                                    <span><i class="fa-solid fa-map-pin" style="color: #EF4444;"></i> Pinpoint Location on Campus Map</span>
                                    <span style="font-size: 11px; font-weight: 500; color: var(--color-slate-400);">Click on map or drag marker</span>
                                </label>
                                <div id="pickerMap" style="height: 220px; width: 100%; border-radius: 8px; border: 1px solid var(--border-soft); margin-top: 6px;"></div>
                                <div style="display: flex; gap: 12px; margin-top: 8px;">
                                    <div style="flex: 1;">
                                        <label class="form-hint">Latitude</label>
                                        <input type="text" id="latInput" name="latitude" class="form-input" style="padding: 6px 10px; font-size: 12px; font-family: monospace;" value="${report.latitude != null ? report.latitude : 10.841128}" readonly />
                                    </div>
                                    <div style="flex: 1;">
                                        <label class="form-hint">Longitude</label>
                                        <input type="text" id="lngInput" name="longitude" class="form-input" style="padding: 6px 10px; font-size: 12px; font-family: monospace;" value="${report.longitude != null ? report.longitude : 106.809883}" readonly />
                                    </div>
                                </div>
                            </div>

                        </div>

                        <!-- BUTTON ACTIONS -->
                        <div class="form-actions-bar">
                            <a href="${pageContext.request.contextPath}/citizen-report" class="btn-smart-secondary">
                                <i class="fa-solid fa-arrow-left"></i> Cancel
                            </a>
                            <button type="submit" class="btn-smart-primary">
                                <i class="fa-solid fa-paper-plane"></i>
                                ${isEdit ? 'Save Changes' : 'Submit Feedback'}
                            </button>
                        </div>

                    </form>
                </div>
            </div>
        </main>
    </div>

    <!-- Leaflet JS -->
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script>
        var initialLat = ${report.latitude != null ? report.latitude : 10.841128};
        var initialLng = ${report.longitude != null ? report.longitude : 106.809883};

        var map = L.map('pickerMap').setView([initialLat, initialLng], 16);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom: 19,
            attribution: '&copy; OpenStreetMap SmartWaste'
        }).addTo(map);

        var marker = L.marker([initialLat, initialLng], { draggable: true }).addTo(map);

        function updateInputs(lat, lng) {
            document.getElementById('latInput').value = lat.toFixed(6);
            document.getElementById('lngInput').value = lng.toFixed(6);
        }

        map.on('click', function(e) {
            marker.setLatLng(e.latlng);
            updateInputs(e.latlng.lat, e.latlng.lng);
        });

        marker.on('dragend', function(e) {
            var pos = marker.getLatLng();
            updateInputs(pos.lat, pos.lng);
        });

        function onBinChange(select) {
            var selectedOpt = select.options[select.selectedIndex];
            var bLat = parseFloat(selectedOpt.getAttribute('data-lat'));
            var bLng = parseFloat(selectedOpt.getAttribute('data-lng'));
            if (bLat && bLng) {
                marker.setLatLng([bLat, bLng]);
                map.setView([bLat, bLng], 17);
                updateInputs(bLat, bLng);
            }
        }

        function updatePhotoPreview(url) {
            var box = document.getElementById('previewBox');
            var img = document.getElementById('photoThumb');
            var txt = document.getElementById('previewUrlText');
            if (url && url.trim().length > 5) {
                img.src = url.trim();
                txt.textContent = url.trim();
                box.style.display = 'flex';
            } else {
                box.style.display = 'none';
            }
        }

        function useSamplePhoto() {
            var sampleUrl = "https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?auto=format&fit=crop&w=400&q=80";
            document.getElementById('imageInput').value = sampleUrl;
            updatePhotoPreview(sampleUrl);
        }
    </script>
</body>
</html>
