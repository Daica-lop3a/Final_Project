<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Device"%>
<%@page import="model.WasteBin"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%
    String ctx = request.getContextPath();
    Device dev = (Device) request.getAttribute("DEVICE");
    if (dev == null) dev = new Device();
    boolean isEdit = Boolean.TRUE.equals(request.getAttribute("IS_EDIT"));
    List<WasteBin> bins = (List<WasteBin>) request.getAttribute("LIST_BIN");
    String error = (String) request.getAttribute("ERROR");
    String nextDeviceId = (String) request.getAttribute("NEXT_DEVICE_ID");

    String deviceIdVal = "";
    if (isEdit && dev.getDeviceId() != null) {
        deviceIdVal = dev.getDeviceId();
    } else if (nextDeviceId != null && !nextDeviceId.isEmpty()) {
        deviceIdVal = nextDeviceId;
    } else if (dev.getDeviceId() != null) {
        deviceIdVal = dev.getDeviceId();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "Edit IoT Sensor" : "Register IoT Sensor" %> - SmartWaste</title>
    <link rel="stylesheet" href="<%=ctx%>/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
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
                        <a href="<%=ctx%>/dashboard" style="color: var(--color-slate-400);">Dashboard</a>
                        <i class="fa-solid fa-chevron-right" style="font-size: 9px;"></i>
                        <a href="<%=ctx%>/device" style="color: var(--color-slate-400);">IoT Devices</a>
                        <i class="fa-solid fa-chevron-right" style="font-size: 9px;"></i>
                        <span style="color: var(--brand-forest);"><%= isEdit ? "Edit Device" : "Register Device" %></span>
                    </div>
                    <h1><%= isEdit ? "Edit IoT Sensor " + dev.getDeviceId() : "Register New Smart Sensor" %></h1>
                </div>

                <!-- ERROR ALERT -->
                <% if (error != null && !error.trim().isEmpty()) { %>
                    <div style="padding: 12px 16px; background: #FEE2E2; border: 1px solid #FCA5A5; border-radius: 8px; color: #991B1B; font-size: 13px; font-weight: 600; margin-bottom: 20px; display: flex; align-items: center; gap: 8px;">
                        <i class="fa-solid fa-circle-exclamation"></i>
                        <span><%= error %></span>
                    </div>
                <% } %>

                <!-- FORM CARD -->
                <div class="smartwaste-form-card">
                    <form method="POST" action="<%=ctx%>/device/save">
                        <input type="hidden" name="isEdit" value="<%= isEdit %>">

                        <div class="form-section-divider">
                            <i class="fa-solid fa-microchip"></i>
                            <span>Hardware Identity &amp; Telemetry Profile</span>
                        </div>

                        <div class="form-grid">
                            
                            <!-- Device Serial ID (Sequential / Readonly) -->
                            <div class="form-field">
                                <label class="form-label" for="deviceId">
                                    Device Serial ID <span class="required">*</span>
                                </label>
                                <input type="text" id="deviceId" name="deviceId" class="form-input"
                                       value="<%= deviceIdVal %>"
                                       readonly
                                       required>
                                <span class="form-hint">
                                    <i class="fa-solid fa-lock" style="font-size: 10px;"></i>
                                    Auto-assigned sequential hardware identifier (e.g. DEV-011).
                                </span>
                            </div>

                            <!-- Device Name / Label -->
                            <div class="form-field">
                                <label class="form-label" for="deviceName">
                                    Device Name / Label <span class="required">*</span>
                                </label>
                                <input type="text" id="deviceName" name="deviceName" class="form-input"
                                       value="<%= dev.getDeviceName() != null ? dev.getDeviceName() : "" %>"
                                       placeholder="e.g. Ultrasonic Fill Sensor #11"
                                       required>
                                <span class="form-hint">Descriptive label for technician field recognition.</span>
                            </div>

                            <!-- Device Sensor Type -->
                            <div class="form-field">
                                <label class="form-label" for="deviceType">
                                    Sensor Technology Type <span class="required">*</span>
                                </label>
                                <select id="deviceType" name="deviceType" class="form-select">
                                    <option value="Ultrasonic Fill Sensor" <%= "Ultrasonic Fill Sensor".equals(dev.getDeviceType()) ? "selected" : "" %>>Ultrasonic Fill Sensor (Distance-level)</option>
                                    <option value="Optical Infrared Sensor" <%= "Optical Infrared Sensor".equals(dev.getDeviceType()) ? "selected" : "" %>>Optical Infrared Sensor</option>
                                    <option value="Weight Load Cell" <%= "Weight Load Cell".equals(dev.getDeviceType()) ? "selected" : "" %>>Weight Load Cell (Strain Gauge)</option>
                                    <option value="GPS & LoRaWAN Gateway" <%= "GPS & LoRaWAN Gateway".equals(dev.getDeviceType()) ? "selected" : "" %>>GPS &amp; LoRaWAN Telemetry Gateway</option>
                                </select>
                            </div>

                            <!-- Assigned Waste Bin -->
                            <div class="form-field">
                                <label class="form-label" for="binId">
                                    Assigned Waste Bin (FPT HCM Campus)
                                </label>
                                <select id="binId" name="binId" class="form-select">
                                    <option value="">-- Unassigned (Spare Inventory) --</option>
                                    <% if (bins != null) {
                                        for (WasteBin b : bins) {
                                            boolean sel = b.getBinID().equals(dev.getBinId());
                                    %>
                                    <option value="<%= b.getBinID() %>" <%= sel ? "selected" : "" %>>
                                        <%= b.getBinCode() %> &mdash; <%= b.getLocation() %>
                                    </option>
                                    <% } } %>
                                </select>
                                <span class="form-hint">Link this sensor to an active campus waste receptacle.</span>
                            </div>

                            <!-- Operational Status -->
                            <div class="form-field">
                                <label class="form-label" for="status">
                                    Operational Status <span class="required">*</span>
                                </label>
                                <select id="status" name="status" class="form-select">
                                    <option value="Active" <%= "Active".equalsIgnoreCase(dev.getStatus()) ? "selected" : "" %>>Active (Live telemetry)</option>
                                    <option value="Maintenance" <%= "Maintenance".equalsIgnoreCase(dev.getStatus()) ? "selected" : "" %>>Maintenance (Offline inspection)</option>
                                    <option value="Inactive" <%= "Inactive".equalsIgnoreCase(dev.getStatus()) ? "selected" : "" %>>Inactive (Decommissioned)</option>
                                </select>
                            </div>

                            <!-- Battery Level -->
                            <div class="form-field">
                                <label class="form-label" for="batteryLevel">
                                    Initial Battery Level (%)
                                </label>
                                <input type="number" id="batteryLevel" name="batteryLevel" class="form-input"
                                       min="0" max="100"
                                       value="<%= dev.getBatteryLevel() > 0 ? dev.getBatteryLevel() : 100 %>">
                                <span class="form-hint">Percentage indicator (0 - 100%).</span>
                            </div>

                            <!-- Firmware Version -->
                            <div class="form-field form-grid-full">
                                <label class="form-label" for="firmwareVersion">
                                    Firmware Build / Revision
                                </label>
                                <input type="text" id="firmwareVersion" name="firmwareVersion" class="form-input"
                                       value="<%= dev.getFirmwareVersion() != null ? dev.getFirmwareVersion() : "v1.2.0" %>"
                                       placeholder="e.g. v1.2.0 or v2.0.1-rc">
                                <span class="form-hint">Telemetry protocol build and hardware firmware version.</span>
                            </div>

                        </div>

                        <!-- BUTTON ACTIONS -->
                        <div class="form-actions-bar">
                            <a href="<%=ctx%>/device" class="btn-smart-secondary">
                                <i class="fa-solid fa-arrow-left"></i> Cancel
                            </a>
                            <button type="submit" class="btn-smart-primary">
                                <i class="fa-solid fa-floppy-disk"></i>
                                <%= isEdit ? "Update Device" : "Register Sensor" %>
                            </button>
                        </div>

                    </form>
                </div>
            </div>
        </main>
    </div>

</body>
</html>
