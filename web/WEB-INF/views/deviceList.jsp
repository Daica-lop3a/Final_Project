<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Device"%>
<%@page import="model.WasteBin"%>
<%@page import="model.AppUser"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%
    String ctx = request.getContextPath();
    List<Device> list = (List<Device>) request.getAttribute("LIST_DEVICE");
    List<WasteBin> unassignedBins = (List<WasteBin>) request.getAttribute("UNASSIGNED_BINS");
    List<String> duplicateBins = (List<String>) request.getAttribute("DUPLICATE_BINS");
    List<String> stuckSensors = (List<String>) request.getAttribute("STUCK_SENSORS");
    List<WasteBin> binList = (List<WasteBin>) request.getAttribute("LIST_BIN");

    String keyword = (String) request.getAttribute("KEYWORD");
    String deviceType = (String) request.getAttribute("DEVICE_TYPE");
    String status = (String) request.getAttribute("STATUS");
    String msg = request.getParameter("msg");
    String count = request.getParameter("count");
    AppUser currentUser = (AppUser) session.getAttribute("user");
    boolean canManage = currentUser != null && (currentUser.isSuperAdmin() || currentUser.isAdmin() || currentUser.isTechnician());
    boolean canDelete = currentUser != null && (currentUser.isSuperAdmin() || currentUser.isAdmin());
    boolean canImport = currentUser != null && (currentUser.isSuperAdmin() || currentUser.isAdmin());
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>IoT Device Management - SmartWaste</title>

    <link rel="stylesheet" href="<%=ctx%>/css/style.css?v=20261017-v4">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        .device-page {
            margin-left: 0;
            width: 100%;
            min-height: 100vh;
            padding: 34px 40px;
            box-sizing: border-box;
            background: #EDF8F2;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            color: #1C1E21;
        }

        .header-box {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 24px;
        }

        .page-kicker {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 1.4px;
            text-transform: uppercase;
            color: #00875A;
            margin-bottom: 6px;
        }

        .page-title {
            margin: 0;
            font-size: 28px;
            font-weight: 800;
            color: #050505;
        }

        .page-desc {
            margin: 6px 0 0;
            color: #65676B;
            font-size: 14px;
        }

        .alert-box {
            padding: 13px 18px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 20px;
        }

        .alert-success { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }
        .alert-warning { background: #fffbeb; color: #92400e; border: 1px solid #fde68a; }
        .alert-danger { background: #fef2f2; color: #991b1b; border: 1px solid #fecaca; }

        .filter-card {
            background: #FFFFFF;
            border-radius: 8px;
            padding: 18px 24px;
            border: 1px solid #D1EBCF;
            margin-bottom: 22px;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
        }

        .filter-form {
            display: flex;
            gap: 15px;
            align-items: flex-end;
            flex-wrap: wrap;
        }

        .filter-group {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }

        .filter-group label {
            font-size: 11px;
            font-weight: 700;
            color: #65676B;
            text-transform: uppercase;
        }

        .filter-group input, .filter-group select {
            padding: 8px 12px;
            border: 1px solid #D1EBCF;
            border-radius: 6px;
            font-size: 13px;
            font-family: inherit;
            background: #FFFFFF;
            color: #1C1E21;
        }

        .table-card {
            background: #FFFFFF;
            border-radius: 8px;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
            border: 1px solid #D1EBCF;
            overflow: hidden;
        }

        .custom-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
            text-align: left;
        }

        .custom-table th {
            background: #EDF8F2;
            color: #65676B;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            font-weight: 700;
            padding: 12px 18px;
            border-bottom: 1px solid #D1EBCF;
        }

        .custom-table td {
            padding: 14px 18px;
            border-bottom: 1px solid #E2F2E5;
            color: #1C1E21;
            vertical-align: middle;
        }

        .custom-table tr:hover td {
            background: #F2F3F5;
        }

        .badge-active { background: #dcfce7; color: #166534; padding: 4px 8px; border-radius: 6px; font-weight: 700; font-size: 11px; }
        .badge-maint { background: #fef3c7; color: #92400e; padding: 4px 8px; border-radius: 6px; font-weight: 700; font-size: 11px; }
        .badge-inact { background: #f1f5f9; color: #64748b; padding: 4px 8px; border-radius: 6px; font-weight: 700; font-size: 11px; }

        .battery-bar {
            width: 80px;
            height: 8px;
            background: #e2e8f0;
            border-radius: 4px;
            overflow: hidden;
            display: inline-block;
            vertical-align: middle;
            margin-right: 6px;
        }

        .battery-fill {
            height: 100%;
            border-radius: 4px;
        }

        .action-btn {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 6px 10px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 600;
            text-decoration: none;
            border: 1px solid #cbd5e1;
            background: white;
            color: #334155;
            cursor: pointer;
        }
        .action-btn:hover { background: #f8fafc; border-color: #94a3b8; }
        .action-btn-danger:hover { color: #dc2626; border-color: #fca5a5; background: #fff5f5; }
    </style>
</head>
<body>

    <jsp:include page="/WEB-INF/views/sidebar.jsp" />

    <main class="device-page">
        <div class="header-box">
            <div style="display: flex; align-items: flex-start; gap: 14px;">
                <button type="button" class="desktop-nav-toggle" onclick="toggleSidebarCollapse()" title="Toggle Sidebar (Expand / Collapse)" style="margin-top: 4px;">
                    <i class="fa-solid fa-bars"></i>
                </button>
                <div>
                    <span class="page-kicker">
                        <i class="fa-solid fa-microchip"></i> Hardware &amp; Telemetry
                    </span>
                    <h1 class="page-title">IoT Device &amp; Sensor Management</h1>
                </div>
            </div>
            <% if (canManage) { %>
            <div style="display: flex; gap: 10px;">
                <% if (canImport) { %>
                <button type="button" onclick="document.getElementById('importModal').style.display='flex'" class="action-btn" style="padding: 10px 16px; background: white; color: #2563eb; border: 1px solid #cbd5e1; font-weight: 700;">
                    <i class="fa-solid fa-file-import"></i> Import CSV
                </button>
                <% } %>
                <a href="<%=ctx%>/device/create" class="action-btn" style="padding: 10px 16px; background: #06b6d4; color: white; border: none; font-weight: 700;">
                    <i class="fa-solid fa-plus"></i> Register Device
                </a>
            </div>
            <% } %>
        </div>

        <% if ("created".equals(msg)) { %>
            <div class="alert-box alert-success"><i class="fa-solid fa-circle-check"></i> Device successfully registered!</div>
        <% } else if ("updated".equals(msg)) { %>
            <div class="alert-box alert-success"><i class="fa-solid fa-circle-check"></i> Device details successfully updated!</div>
        <% } else if ("deleted".equals(msg)) { %>
            <div class="alert-box alert-success"><i class="fa-solid fa-circle-check"></i> Device successfully removed from system.</div>
        <% } else if ("imported".equals(msg)) { %>
            <div class="alert-box alert-success"><i class="fa-solid fa-circle-check"></i> Successfully imported <%= count != null ? count : "" %> IoT devices from CSV!</div>
        <% } %>

        <%-- UNASSIGNED BINS INTEGRITY WARNING --%>
        <% if (unassignedBins != null && !unassignedBins.isEmpty()) { %>
            <div class="alert-box alert-warning" style="justify-content: space-between;">
                <div style="display: flex; align-items: center; gap: 10px;">
                    <i class="fa-solid fa-triangle-exclamation" style="font-size: 18px;"></i>
                    <div>
                        <strong>IoT Coverage Alert:</strong> <%= unassignedBins.size() %> waste bin(s) currently do not have an IoT sensor assigned:
                        <% for (int i = 0; i < unassignedBins.size(); i++) { %>
                            <b><%= unassignedBins.get(i).getBinCode() %></b> (<%= unassignedBins.get(i).getLocation() %>)<%= i < unassignedBins.size() - 1 ? ", " : "" %>
                        <% } %>
                    </div>
                </div>
                <a href="#tableArea" style="font-size: 12px; color: #92400e; font-weight: 700; text-decoration: underline;">Assign below</a>
            </div>
        <% } %>

        <%-- DUPLICATE BINS WARNING --%>
        <% if (duplicateBins != null && !duplicateBins.isEmpty()) { %>
            <div class="alert-box alert-danger">
                <i class="fa-solid fa-circle-exclamation" style="font-size: 18px;"></i>
                <div>
                    <strong>Duplicate Assignment Detected:</strong> Multiple devices mapped to the same bin: <%= duplicateBins.toString() %>.
                </div>
            </div>
        <% } %>

        <%-- STUCK SENSOR ANOMALY DETECTION (TECHNICIAN AUDIT) --%>
        <% if (stuckSensors != null && !stuckSensors.isEmpty()) { %>
            <div class="alert-box alert-danger" style="background: #fdf2f8; color: #9d174d; border-color: #fbcfe8;">
                <i class="fa-solid fa-bolt-lightning" style="font-size: 18px; color: #db2777;"></i>
                <div>
                    <strong>Hardware Telemetry Anomaly (Stuck Sensor):</strong> <%= stuckSensors.size() %> sensor(s) detected reporting identical fill level over consecutive polling cycles:
                    <ul style="margin: 4px 0 0; padding-left: 18px;">
                        <% for (String st : stuckSensors) { %>
                            <li><%= st %></li>
                        <% } %>
                    </ul>
                </div>
            </div>
        <% } %>

        <div class="filter-card">
            <form class="filter-form" action="<%=ctx%>/device" method="GET">
                <div class="filter-group">
                    <label>Keyword</label>
                    <input type="text" name="keyword" value="<%=keyword%>" placeholder="Device ID, Name, Bin...">
                </div>
                <div class="filter-group">
                    <label>Device Type</label>
                    <select name="deviceType">
                        <option value="">All Types</option>
                        <option value="Ultrasonic Fill Sensor" <%="Ultrasonic Fill Sensor".equals(deviceType) ? "selected" : ""%>>Ultrasonic Fill Sensor</option>
                        <option value="Optical Infrared Sensor" <%="Optical Infrared Sensor".equals(deviceType) ? "selected" : ""%>>Optical Infrared Sensor</option>
                        <option value="Weight Load Cell" <%="Weight Load Cell".equals(deviceType) ? "selected" : ""%>>Weight Load Cell</option>
                        <option value="GPS & LoRaWAN Gateway" <%="GPS & LoRaWAN Gateway".equals(deviceType) ? "selected" : ""%>>GPS &amp; LoRaWAN Gateway</option>
                    </select>
                </div>
                <div class="filter-group">
                    <label>Status</label>
                    <select name="status">
                        <option value="">All Statuses</option>
                        <option value="Active" <%="Active".equals(status) ? "selected" : ""%>>Active</option>
                        <option value="Maintenance" <%="Maintenance".equals(status) ? "selected" : ""%>>Maintenance</option>
                        <option value="Inactive" <%="Inactive".equals(status) ? "selected" : ""%>>Inactive</option>
                    </select>
                </div>
                <div>
                    <button type="submit" class="action-btn" style="background: #2563eb; color: white; border: none; padding: 8px 16px;">
                        <i class="fa-solid fa-magnifying-glass"></i> Filter
                    </button>
                    <a href="<%=ctx%>/device" class="action-btn" style="padding: 8px 14px;">Reset</a>
                </div>
            </form>
        </div>

        <div class="table-card" id="tableArea">
            <table class="custom-table">
                <thead>
                    <tr>
                        <th style="width: 130px;">Device ID</th>
                        <th>Device Name</th>
                        <th style="width: 170px;">Type</th>
                        <th style="width: 190px;">Assigned Waste Bin</th>
                        <th style="width: 100px;">Firmware</th>
                        <th style="width: 85px;">Repairs</th>
                        <th style="width: 110px;">Status</th>
                        <th style="width: 140px;">Battery Level</th>
                        <th style="width: 130px;">Last Telemetry</th>
                        <% if (canManage) { %>
                        <th style="width: 120px; text-align: center;">Actions</th>
                        <% } %>
                    </tr>
                </thead>
                <tbody>
                    <% if (list != null && !list.isEmpty()) {
                        for (Device d : list) {
                            String badge = "badge-inact";
                            if ("Active".equalsIgnoreCase(d.getStatus())) badge = "badge-active";
                            else if ("Maintenance".equalsIgnoreCase(d.getStatus())) badge = "badge-maint";

                            String batColor = "#10b981";
                            if (d.getBatteryLevel() < 25) batColor = "#ef4444";
                            else if (d.getBatteryLevel() < 60) batColor = "#f59e0b";
                    %>
                    <tr>
                        <td><strong><%= d.getDeviceId() %></strong></td>
                        <td>
                            <div style="font-weight: 700; color: #1e293b;"><%= d.getDeviceName() %></div>
                        </td>
                        <td><small style="color: #64748b; font-weight: 600;"><%= d.getDeviceType() %></small></td>
                        <td>
                            <% if (d.getBinId() != null && !d.getBinId().trim().isEmpty()) { %>
                                <span style="font-weight: 700; color: #2563eb;"><i class="fa-solid fa-trash-can"></i> <%= d.getBinCode() != null ? d.getBinCode() : d.getBinId() %></span>
                                <div style="font-size: 11px; color: #64748b;"><%= d.getBinLocation() != null ? d.getBinLocation() : "" %></div>
                            <% } else { %>
                                <span style="color: #dc2626; font-style: italic; font-weight: 600;"><i class="fa-solid fa-link-slash"></i> Unassigned</span>
                            <% } %>
                        </td>
                        <td style="font-family: monospace; font-size: 11px;">
                            <span style="background: #f1f5f9; padding: 2px 6px; border-radius: 4px; font-weight: 600; color: #475569;">
                                <%= d.getFirmwareVersion() %>
                            </span>
                        </td>
                        <td>
                            <span style="font-weight: 700; font-size: 12px; color: <%= d.getRepairCount() > 0 ? "#b45309" : "#64748b" %>;">
                                <i class="fa-solid fa-screwdriver-wrench"></i> <%= d.getRepairCount() %>
                            </span>
                        </td>
                        <td><span class="<%= badge %>"><%= d.getStatus() %></span></td>
                        <td>
                            <div class="battery-bar">
                                <div class="battery-fill" style="width: <%= d.getBatteryLevel() %>%; background: <%= batColor %>;"></div>
                            </div>
                            <span style="font-weight: 700; font-size: 11px; color: #475569;"><%= d.getBatteryLevel() %>%</span>
                        </td>
                        <td><small style="color: #64748b;"><%= d.getLastPing() != null ? d.getLastPing().toString().substring(0, 16) : "N/A" %></small></td>
                        <% if (canManage) { %>
                        <td style="text-align: center;">
                            <a href="<%=ctx%>/device/edit?id=<%= d.getDeviceId() %>" class="action-btn" title="Edit / Reassign">
                                <i class="fa-solid fa-pen"></i>
                            </a>
                            <% if (canDelete) { %>
                            <form method="POST" action="<%=ctx%>/device/delete" style="display: inline;" onsubmit="return confirm('Delete this device registration?');">
                                <input type="hidden" name="id" value="<%= d.getDeviceId() %>">
                                <button type="submit" class="action-btn action-btn-danger" title="Delete">
                                    <i class="fa-solid fa-trash"></i>
                                </button>
                            </form>
                            <% } %>
                        </td>
                        <% } %>
                    </tr>
                    <% } } else { %>
                    <tr>
                        <td colspan="10" style="text-align: center; padding: 40px; color: #64748b;">
                            <i class="fa-solid fa-microchip" style="font-size: 32px; color: #cbd5e1; margin-bottom: 10px; display: block;"></i>
                            No IoT devices found. Click "Register Device" or "Import CSV" to add hardware.
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </main>

    <!-- CSV IMPORT MODAL -->
    <% if (canImport) { %>
    <div id="importModal" style="display: none; position: fixed; inset: 0; background: rgba(15,23,42,0.6); z-index: 9999; align-items: center; justify-content: center;">
        <div style="background: white; border-radius: 14px; max-width: 600px; width: 90%; padding: 26px; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.2);">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px;">
                <h3 style="margin: 0; font-size: 18px; color: #0f172a;"><i class="fa-solid fa-file-csv" style="color: #06b6d4;"></i> Import IoT Devices from CSV</h3>
                <button type="button" onclick="document.getElementById('importModal').style.display='none'" style="border: none; background: none; font-size: 24px; cursor: pointer; color: #64748b; line-height: 1;">&times;</button>
            </div>
            <p style="color: #64748b; font-size: 13px; margin: 0 0 14px;">
                Format: <code>deviceID,deviceName,deviceType,binID,status,batteryLevel</code>
            </p>
            <form method="POST" action="<%=ctx%>/device/import">
                <textarea name="csvData" rows="8" style="width: 100%; box-sizing: border-box; border: 1px solid #cbd5e1; border-radius: 8px; padding: 10px; font-family: monospace; font-size: 12px;" placeholder="DEV-BIN-11,Ultrasonic Sensor #11,Ultrasonic Fill Sensor,BIN-009,Active,90&#10;DEV-BIN-12,Optical Sensor #12,Optical Infrared Sensor,BIN-010,Active,95"></textarea>
                <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 14px;">
                    <button type="button" onclick="document.getElementById('importModal').style.display='none'" class="action-btn" style="padding: 8px 16px;">Cancel</button>
                    <button type="submit" class="action-btn" style="padding: 8px 16px; background: #06b6d4; color: white; border: none; font-weight: 700;">Import Now</button>
                </div>
            </form>
        </div>
    </div>
    <% } %>

</body>
</html>
