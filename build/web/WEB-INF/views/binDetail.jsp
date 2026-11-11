<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@page import="model.WasteBin"%>
<%@page import="model.Area"%>
<%@page import="model.Device"%>
<%@page import="model.BinReading"%>
<%@page import="java.util.List"%>

<%
    WasteBin bin = (WasteBin) request.getAttribute("BIN");
    Area area = (Area) request.getAttribute("AREA");
    Device device = (Device) request.getAttribute("DEVICE");
    List<BinReading> readings = (List<BinReading>) request.getAttribute("READINGS");
    
    model.AppUser currentUser = (model.AppUser) session.getAttribute("user");
    String roleId = currentUser != null ? currentUser.getRoleId() : "USR";
    boolean isSuperAdmin = currentUser != null && currentUser.isSuperAdmin();
    boolean isAdmin = currentUser != null && currentUser.isAdmin();
    boolean isManager = currentUser != null && currentUser.isManager();
    boolean isSupervisor = currentUser != null && currentUser.isSupervisor();
    boolean isStaff = currentUser != null && currentUser.isStaff();
    boolean isTechnician = currentUser != null && currentUser.isTechnician();
    boolean isAuditor = currentUser != null && currentUser.isAuditor();
    boolean isCitizen = currentUser != null && currentUser.isCitizen();

    boolean canDispatchCollection = isSuperAdmin || isAdmin || isManager || isSupervisor;
    boolean canRequestMaintenance = isSuperAdmin || isAdmin || isManager || isSupervisor || isStaff || isTechnician;
    boolean canReportIssue = isCitizen || isStaff || isSupervisor || isManager || isAdmin || isSuperAdmin;
    boolean canEditBin = isSuperAdmin || isAdmin || isManager || isSupervisor || isTechnician;

    int fill = bin != null ? (int) Math.round(bin.getCurrentFill()) : 0;
    String fillClass = "fill-normal";
    String fillBadgeBg = "#10b981";
    if (fill >= 85) {
        fillClass = "fill-critical";
        fillBadgeBg = "#ef4444";
    } else if (fill >= 60) {
        fillClass = "fill-warning";
        fillBadgeBg = "#f59e0b";
    }

    String fillRate = (String) request.getAttribute("FILL_RATE");
    Integer f0 = (Integer) request.getAttribute("F0");
    Integer f10 = (Integer) request.getAttribute("F10");
    Integer f20 = (Integer) request.getAttribute("F20");
    Integer f30 = (Integer) request.getAttribute("F30");
    Integer timeTo85 = (Integer) request.getAttribute("TIME_TO_85");
    Integer timeToFull = (Integer) request.getAttribute("TIME_TO_FULL");

    String histLabelsJson = (String) request.getAttribute("HIST_LABELS_JSON");
    String histDataJson = (String) request.getAttribute("HIST_DATA_JSON");
    if (histLabelsJson == null || histLabelsJson.trim().isEmpty()) histLabelsJson = "[]";
    if (histDataJson == null || histDataJson.trim().isEmpty()) histDataJson = "[]";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bin Details - <%= bin != null ? bin.getBinCode() : "SmartWaste" %></title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Local Chart.js for 30-Minute Predictive Forecasting (Offline Compatible) -->
    <script src="${pageContext.request.contextPath}/assets/js/chart.min.js"></script>

    <style>
        .detail-page {
            min-height: 100vh;
            background: #EDF8F2;
            color: #1C1E21;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
        }
        .main-container {
            max-width: 1280px;
            margin: 0 auto;
            padding: 0;
        }
        .top-breadcrumbs {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13px;
            color: #65676B;
            margin-bottom: 0;
        }
        .top-breadcrumbs a {
            color: #00875A;
            text-decoration: none;
            font-weight: 600;
        }
        .top-breadcrumbs a:hover {
            text-decoration: underline;
        }
        .header-card {
            background: #FFFFFF;
            border-radius: 8px;
            padding: 24px;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
            border: 1px solid #D1EBCF;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 16px;
            margin-bottom: 24px;
            border-left: 5px solid <%= fillBadgeBg %>;
        }
        .header-title-group h1 {
            margin: 0 0 6px 0;
            font-size: 24px;
            font-weight: 700;
            color: #050505;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .header-subtitle {
            font-size: 13.5px;
            color: #65676B;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .quick-action-bar {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        .btn-action {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 8px 16px;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.15s ease;
            cursor: pointer;
            border: 1px solid transparent;
        }
        .btn-dispatch {
            background: #00875A;
            color: #FFFFFF;
        }
        .btn-dispatch:hover {
            background: #006644;
            color: #FFFFFF;
        }
        .btn-maintenance {
            background: #D97706;
            color: #FFFFFF;
        }
        .btn-maintenance:hover {
            background: #B45309;
            color: #FFFFFF;
        }
        .btn-secondary {
            background: #FFFFFF;
            color: #050505;
            border-color: #D1EBCF;
        }
        .btn-secondary:hover {
            background: #EDF8F2;
            border-color: #D1EBCF;
            color: #050505;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 16px;
            margin-bottom: 24px;
        }
        .stat-card {
            background: #FFFFFF;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
            border: 1px solid #D1EBCF;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }
        .stat-label {
            font-size: 12px;
            font-weight: 700;
            color: #65676B;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .stat-value {
            font-size: 28px;
            font-weight: 800;
            color: #050505;
            margin-bottom: 8px;
            font-variant-numeric: tabular-nums;
        }
        .stat-subtext {
            font-size: 12px;
            color: #65676B;
        }
        .progress-bar-wrap {
            height: 8px;
            background: #EDF8F2;
            border-radius: 4px;
            border: 1px solid #E2F2E5;
            overflow: hidden;
            margin-top: 10px;
        }
        .progress-bar-fill {
            height: 100%;
            border-radius: 4px;
            transition: width 0.4s ease;
        }
        .chart-section {
            background: #FFFFFF;
            border-radius: 8px;
            padding: 24px;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
            border: 1px solid #D1EBCF;
            margin-bottom: 24px;
        }
        .chart-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
            margin-bottom: 20px;
            padding-bottom: 12px;
            border-bottom: 1px solid #EDF8F2;
        }
        .chart-title {
            font-size: 16px;
            font-weight: 700;
            color: #050505;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .forecast-banner {
            background: #EDF8F2;
            border: 1px solid #D1EBCF;
            border-left: 4px solid #00875A;
            border-radius: 6px;
            padding: 12px 16px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            margin-top: 20px;
            flex-wrap: wrap;
        }
        .data-table-wrap {
            background: #FFFFFF;
            border-radius: 8px;
            padding: 24px;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
            border: 1px solid #D1EBCF;
        }
        .table-responsive {
            width: 100%;
            overflow-x: auto;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }
        th {
            text-align: left;
            padding: 12px 14px;
            background: #EDF8F2;
            color: #65676B;
            font-weight: 700;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            border-bottom: 1px solid #D1EBCF;
        }
        td {
            padding: 12px 14px;
            border-bottom: 1px solid #E2F2E5;
            color: #1C1E21;
        }
        tr:hover td {
            background: #F2F3F5;
        }
    </style>
</head>

<body class="detail-page" style="background: #EDF8F2; margin: 0;">
    <div class="app-shell">
        <!-- Sidebar Navigation -->
        <jsp:include page="/WEB-INF/views/sidebar.jsp" />

        <!-- Main Workspace -->
        <main class="main-content" style="background: #EDF8F2;">
            <div class="main-container">
                <!-- Breadcrumbs & Nav Toggle -->
                <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px;">
                    <div style="display: flex; align-items: center; gap: 12px;">
                        <button type="button" class="desktop-nav-toggle" onclick="toggleSidebarCollapse()" title="Toggle Sidebar (Expand / Collapse)">
                            <i class="fa-solid fa-bars"></i>
                        </button>
                        <div class="top-breadcrumbs">
                            <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                            <i class="fa-solid fa-chevron-right" style="font-size: 10px;"></i>
                            <a href="${pageContext.request.contextPath}/wastebin">Waste Bins</a>
                            <i class="fa-solid fa-chevron-right" style="font-size: 10px;"></i>
                            <span><%= bin != null ? bin.getBinCode() : "Details" %></span>
                        </div>
                    </div>
                </div>

                <!-- Header Card -->
                <div class="header-card">
                    <div class="header-title-group">
                        <h1>
                            <i id="liveHeaderBinIcon" class="fa-solid fa-trash-can" style="color: <%= fillBadgeBg %>;"></i>
                            <%= bin != null ? bin.getBinCode() : "N/A" %>
                            <span id="liveHeaderFillBadge" style="font-size: 12px; padding: 4px 10px; border-radius: 999px; background: <%= fillBadgeBg %>; color: white; font-weight: 700;">
                                <%= fill %>% Full
                            </span>
                            <span id="liveHeaderStatusBadge" style="font-size: 12px; padding: 4px 10px; border-radius: 999px; background: #f1f5f9; color: #475569; font-weight: 600;">
                                <%= bin != null ? bin.getStatus() : "Active" %>
                            </span>
                            <span id="liveTelemetryPill" style="font-size: 11px; padding: 4px 10px; border-radius: 999px; background: #DCFCE7; color: #166534; font-weight: 700; border: 1px solid #86EFAC; display: inline-flex; align-items: center; gap: 5px; vertical-align: middle;">
                                <span style="width: 7px; height: 7px; border-radius: 50%; background: #16A34A; display: inline-block;"></span> LIVE STREAM
                            </span>
                        </h1>
                        <div class="header-subtitle">
                            <span><i class="fa-solid fa-location-dot" style="color: #64748b;"></i> <%= bin != null ? bin.getLocation() : "Campus" %></span>
                            <span>•</span>
                            <span><i class="fa-solid fa-map" style="color: #64748b;"></i> <%= area != null ? area.getAreaName() : "Zone N/A" %></span>
                            <c:if test="${not empty BIN.latitude and not empty BIN.longitude}">
                                <span>•</span>
                                <span><i class="fa-solid fa-crosshairs" style="color: #64748b;"></i> ${BIN.latitude}, ${BIN.longitude}</span>
                            </c:if>
                        </div>
                    </div>

                    <div class="quick-action-bar">
                        <% if (canReportIssue && isCitizen) { %>
                            <!-- Citizen: Report issue with bin -->
                            <a href="${pageContext.request.contextPath}/citizen-report/create?binID=<%= bin != null ? bin.getBinID() : "" %>" class="btn-action" style="background: #f59e0b; color: white;">
                                <i class="fa-solid fa-bullhorn"></i> Report an Issue
                            </a>
                        <% } %>

                        <% if (canDispatchCollection) { %>
                            <!-- Dispatch Collection -->
                            <a href="${pageContext.request.contextPath}/collection/create?binID=<%= bin != null ? bin.getBinID() : "" %>" class="btn-action btn-dispatch">
                                <i class="fa-solid fa-truck-pickup"></i> Dispatch Collection
                            </a>
                        <% } %>

                        <% if (canRequestMaintenance) { %>
                            <!-- Request Maintenance -->
                            <a href="${pageContext.request.contextPath}/maintenance/create?binID=<%= bin != null ? bin.getBinID() : "" %>" class="btn-action btn-maintenance">
                                <i class="fa-solid fa-screwdriver-wrench"></i> Request Maintenance
                            </a>
                        <% } %>

                        <% if (canEditBin) { %>
                            <!-- Edit Bin -->
                            <a href="${pageContext.request.contextPath}/wastebin/edit?id=<%= bin != null ? bin.getBinID() : "" %>" class="btn-action btn-secondary" style="background: #ffffff; color: #00875A; border-color: #D1EBCF;">
                                <i class="fa-solid fa-pen"></i> Edit Node
                            </a>
                        <% } %>

                        <!-- Live Map -->
                        <a href="${pageContext.request.contextPath}/map" class="btn-action btn-secondary">
                            <i class="fa-solid fa-map-location-dot"></i> View on Map
                        </a>
                    </div>
                </div>

                <!-- 4 Top Stat Cards -->
                <div class="stats-grid">
                    <!-- Stat 1: Current Fill -->
                    <div class="stat-card">
                        <div class="stat-label">
                            <span>CURRENT CAPACITY FILL</span>
                            <i class="fa-solid fa-gauge" style="color: <%= fillBadgeBg %>;"></i>
                        </div>
                        <div id="liveStatCurrentFill" class="stat-value" style="color: <%= fillBadgeBg %>; transition: color 0.3s ease;">
                            <%= fill %>%
                        </div>
                        <div class="progress-bar-wrap">
                            <div id="liveStatProgressBar" class="progress-bar-fill" style="width: <%= Math.min(100, fill) %>%; background: <%= fillBadgeBg %>; transition: width 0.5s ease, background 0.3s ease;"></div>
                        </div>
                        <div class="stat-subtext" style="margin-top: 8px;">
                            Capacity: <%= bin != null ? bin.getCapacity() : 100 %> Liters
                        </div>
                    </div>

                    <!-- Stat 2: IoT Sensor Hardware -->
                    <div class="stat-card">
                        <div class="stat-label">
                            <span>ATTACHED IOT SENSOR</span>
                            <i class="fa-solid fa-microchip" style="color: #0284c7;"></i>
                        </div>
                        <% if (device != null) { %>
                            <div class="stat-value" style="font-size: 20px; color: #0284c7;">
                                <%= device.getDeviceId() %>
                            </div>
                            <div style="font-size: 12px; color: #475569; margin: 4px 0;">
                                <%= device.getDeviceName() %> (<%= device.getDeviceType() %>)
                            </div>
                            <div class="stat-subtext" style="display: flex; align-items: center; gap: 8px;">
                                <span><i class="fa-solid fa-battery-half" style="color: #10b981;"></i> <%= device.getBatteryLevel() %>% Battery</span>
                                <span>•</span>
                                <span style="color: #10b981; font-weight: 600;"><%= device.getStatus() %></span>
                            </div>
                        <% } else { %>
                            <div class="stat-value" style="font-size: 18px; color: #ef4444;">
                                Unassigned
                            </div>
                            <div class="stat-subtext" style="color: #ef4444;">
                                <i class="fa-solid fa-triangle-exclamation"></i> No IoT telemetry sensor attached!
                            </div>
                        <% } %>
                    </div>

                    <!-- Stat 3: 30-Min Predictive Trend -->
                    <div class="stat-card">
                        <div class="stat-label">
                            <span>30-MIN FORECAST PROJECTION</span>
                            <i class="fa-solid fa-chart-line" style="color: #f59e0b;"></i>
                        </div>
                        <div id="liveStatF30" class="stat-value" style="color: #d97706;">
                            <%= f30 != null ? f30 : fill %>%
                        </div>
                        <div class="stat-subtext" id="liveStatFillRate">
                            Fill accumulation rate: <strong>+<%= fillRate != null ? fillRate : "0.25" %>% / min</strong>
                        </div>
                        <div id="liveStatF30Risk" style="font-size: 12px; margin-top: 6px; font-weight: 600; color: <%= (f30 != null && f30 >= 85) ? "#ef4444" : "#10b981" %>;">
                            <%= (f30 != null && f30 >= 85) ? "⚠️ High risk of overflow within 30m" : "✅ Within safe operational threshold" %>
                        </div>
                    </div>

                    <!-- Stat 4: Estimated Time to Action -->
                    <div class="stat-card">
                        <div class="stat-label">
                            <span>ESTIMATED TIME TO FULL</span>
                            <i class="fa-solid fa-hourglass-half" style="color: #8b5cf6;"></i>
                        </div>
                        <% if (timeTo85 != null && timeTo85 == 0) { %>
                            <div class="stat-value" style="color: #ef4444; font-size: 22px;">
                                OVERFILL CRITICAL
                            </div>
                            <div class="stat-subtext" style="color: #ef4444; font-weight: 600;">
                                Exceeded 85% - Immediate collection needed!
                            </div>
                        <% } else if (timeTo85 != null && timeTo85 > 0) { %>
                            <div class="stat-value" style="color: #0f172a;">
                                ~<%= timeTo85 %> mins
                            </div>
                            <div class="stat-subtext">
                                Time until 85% alert threshold (~<%= timeToFull != null ? timeToFull : (timeTo85 + 20) %> mins to 100%)
                            </div>
                        <% } else { %>
                            <div class="stat-value" style="color: #10b981; font-size: 22px;">
                                Normal State
                            </div>
                            <div class="stat-subtext">
                                Fill volume is stable or emptying
                            </div>
                        <% } %>
                    </div>
                </div>

                <!-- 30-Minute Forecast Line Chart (PRJ301 Centerpiece Highlight) -->
                <div class="chart-section">
                    <div class="chart-header">
                        <div class="chart-title">
                            <i class="fa-solid fa-chart-area" style="color: #2563eb;"></i>
                            Smart Predictive Fill-Level & 30-Minute Dynamic Forecast
                        </div>
                        <div style="display: flex; align-items: center; gap: 16px; font-size: 12px;">
                            <span style="display: flex; align-items: center; gap: 5px;">
                                <span style="display: inline-block; width: 14px; height: 3px; background: #2563eb;"></span> Actual Telemetry
                            </span>
                            <span style="display: flex; align-items: center; gap: 5px;">
                                <span style="display: inline-block; width: 14px; height: 3px; background: #f59e0b; border-bottom: 2px dashed #f59e0b;"></span> 30-Min Forecast (Projected)
                            </span>
                            <span style="display: flex; align-items: center; gap: 5px;">
                                <span style="display: inline-block; width: 14px; height: 1px; background: #ef4444; border-top: 1px dashed #ef4444;"></span> 85% Alert Limit
                            </span>
                        </div>
                    </div>

                    <div style="height: 320px; position: relative;">
                        <canvas id="predictiveChart"></canvas>
                    </div>

                    <div class="forecast-banner">
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <i class="fa-solid fa-wand-magic-sparkles" style="color: #2563eb; font-size: 18px;"></i>
                            <div>
                                <strong style="color: #1e3a8a; font-size: 13px;">AI Predictive Logistics Summary:</strong>
                                <span style="color: #1e40af; font-size: 13px; margin-left: 5px;">
                                    Based on linear regression of recent sensor telemetry, this bin is accumulating waste at <strong>+<%= fillRate != null ? fillRate : "0.25" %>% / min</strong>.
                                    <% if (f30 != null && f30 >= 85) { %>
                                        It will breach the 85% threshold within approximately <strong><%= timeTo85 %> minutes</strong>. Early dispatch is advised!
                                    <% } else { %>
                                        Projected fill level in 30 minutes is <strong><%= f30 %>%</strong>, maintaining safe operational headroom.
                                    <% } %>
                                </span>
                            </div>
                        </div>
                        <% if (canDispatchCollection && (fill >= 80 || (f30 != null && f30 >= 85))) { %>
                            <a href="${pageContext.request.contextPath}/collection/create?binID=<%= bin != null ? bin.getBinID() : "" %>" style="background: #00875A; color: white; padding: 7px 14px; border-radius: 6px; font-size: 12px; font-weight: 700; text-decoration: none; white-space: nowrap;">
                                <i class="fa-solid fa-truck"></i> Dispatch Early Pickup
                            </a>
                        <% } %>
                    </div>
                </div>

                <!-- Receptacle Physical QR Code Badge Card -->
                <div class="card" style="margin-top: 24px; padding: 24px; background: #FFFFFF; border-radius: 8px; border: 1px solid #D1EBCF; box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);">
                    <div style="display: flex; flex-wrap: wrap; gap: 24px; align-items: center; justify-content: space-between;">
                        <div style="display: flex; gap: 20px; align-items: center; flex-wrap: wrap;">
                            <div style="background: #ffffff; padding: 10px; border-radius: 8px; border: 1px solid #D1EBCF; box-shadow: 0 1px 3px rgba(0,0,0,0.05); text-align: center;">
                                <img id="binQrImage" src="https://api.qrserver.com/v1/create-qr-code/?size=180x180&amp;margin=6&amp;data=<%= bin != null ? bin.getBinCode() : "BIN-001" %>"
                                     onerror="this.onerror=null; this.src='https://quickchart.io/qr?size=180&text=<%= bin != null ? bin.getBinCode() : "BIN-001" %>';"
                                     alt="QR Code for <%= bin != null ? bin.getBinCode() : "Bin" %>"
                                     style="width: 130px; height: 130px; display: block; border-radius: 6px;">
                                <div style="font-size: 12px; font-weight: 800; font-family: monospace; color: #050505; margin-top: 6px;">
                                    <%= bin != null ? bin.getBinCode() : "BIN-001" %>
                                </div>
                            </div>
                            <div>
                                <div style="display: inline-flex; align-items: center; gap: 6px; padding: 3px 10px; border-radius: 20px; background: #DCF2E4; color: #00875A; font-size: 11px; font-weight: 700; text-transform: uppercase;">
                                    <i class="fa-solid fa-qrcode"></i> Physical On-Site Identifier
                                </div>
                                <h3 style="margin: 8px 0 4px; font-size: 18px; color: #050505; font-weight: 800;">
                                    Auto-Generated Receptacle QR Code
                                </h3>
                                <p style="margin: 0 0 10px; font-size: 13px; color: #65676B; max-width: 520px; line-height: 1.5;">
                                    This QR code uniquely identifies this physical receptacle. Scan it with mobile cameras or collection tablets to verify on-site operations.
                                </p>
                                <div style="display: flex; flex-wrap: wrap; gap: 14px; font-size: 12px; color: #1C1E21;">
                                    <span><strong>Bin ID:</strong> <code><%= bin != null ? bin.getBinID() : "" %></code></span>
                                    <span><strong>Location:</strong> <%= bin != null ? bin.getLocation() : "" %></span>
                                    <span><strong>Zone:</strong> <%= bin != null ? bin.getAreaName() : "" %></span>
                                </div>
                            </div>
                        </div>
                        <div style="display: flex; flex-direction: column; gap: 10px;">
                            <button type="button" onclick="printQrBadge()" class="btn-action" style="background: #00875A; color: white; padding: 9px 18px; border-radius: 6px; font-size: 13px; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; gap: 8px;">
                                <i class="fa-solid fa-print"></i> Print QR Sticker
                            </button>
                            <a href="https://api.qrserver.com/v1/create-qr-code/?size=400x400&amp;margin=10&amp;data=<%= bin != null ? bin.getBinCode() : "BIN-001" %>"
                               download="<%= bin != null ? bin.getBinCode() : "BIN" %>-QR.png"
                               target="_blank"
                               class="btn-action btn-secondary" style="padding: 8px 18px; border-radius: 6px; font-size: 13px; font-weight: 600; text-decoration: none; display: inline-flex; align-items: center; gap: 8px; justify-content: center;">
                                <i class="fa-solid fa-download"></i> Download PNG
                            </a>
                        </div>
                    </div>
                </div>

                <!-- Telemetry Readings Table -->
                <div class="data-table-wrap">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                        <h3 style="margin: 0; font-size: 16px; color: #0f172a;">
                            <i class="fa-solid fa-clock-rotate-left" style="color: #64748b; margin-right: 6px;"></i> Sensor Measurement Logs
                        </h3>
                        <span id="liveReadingsCountText" style="font-size: 12px; color: #64748b;">
                            Showing <%= readings != null ? readings.size() : 0 %> historical readings
                        </span>
                    </div>

                    <div class="table-responsive">
                        <table>
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Timestamp</th>
                                    <th>Fill Level</th>
                                    <th>Status Assessment</th>
                                </tr>
                            </thead>
                            <tbody id="liveReadingsTableBody">
                                <c:choose>
                                    <c:when test="${not empty READINGS}">
                                        <c:forEach var="r" items="${READINGS}" varStatus="status">
                                            <tr>
                                                <td>${status.index + 1}</td>
                                                <td>
                                                    <fmt:formatDate value="${r.measuredAt}" pattern="yyyy-MM-dd HH:mm:ss" />
                                                </td>
                                                <td>
                                                    <strong style="color: ${r.fillPercent >= 85 ? '#ef4444' : (r.fillPercent >= 60 ? '#f59e0b' : '#10b981')};">
                                                        ${r.fillPercent}%
                                                    </strong>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${r.fillPercent >= 85}">
                                                            <span style="padding: 3px 8px; border-radius: 4px; background: #fee2e2; color: #b91c1c; font-size: 11px; font-weight: 700;">CRITICAL (FULL)</span>
                                                        </c:when>
                                                        <c:when test="${r.fillPercent >= 60}">
                                                            <span style="padding: 3px 8px; border-radius: 4px; background: #fef3c7; color: #b45309; font-size: 11px; font-weight: 600;">NEAR FULL</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span style="padding: 3px 8px; border-radius: 4px; background: #d1fae5; color: #047857; font-size: 11px; font-weight: 600;">NORMAL</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="4" style="text-align: center; color: #94a3b8; padding: 24px;">
                                                No sensor telemetry recorded yet for this bin.
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- 4. BIN AUDIT & CONFIGURATION HISTORY (MANAGEMENT & AUDITOR ONLY) -->
                <% if (!isCitizen) { 
                    java.util.List<model.AuditLog> binLogs = (java.util.List<model.AuditLog>) request.getAttribute("BIN_LOGS");
                %>
                <div class="card" style="margin-top: 24px;">
                    <div class="card-header">
                        <h2><i class="fa-solid fa-clock-rotate-left" style="color: #6366f1;"></i> Bin Audit &amp; Maintenance Modification History</h2>
                        <span style="font-size: 12px; color: #64748b;"><%= binLogs != null ? binLogs.size() : 0 %> logs</span>
                    </div>
                    <div class="table-container">
                        <table>
                            <thead>
                                <tr>
                                    <th>Timestamp</th>
                                    <th>Action</th>
                                    <th>User / Operator</th>
                                    <th>Change Description</th>
                                    <th>IP Address</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (binLogs != null && !binLogs.isEmpty()) {
                                    for (model.AuditLog bl : binLogs) { %>
                                    <tr>
                                        <td style="color: #64748b; white-space: nowrap;"><%= bl.getFormattedTimestamp() %></td>
                                        <td>
                                            <span style="font-weight: 700; color: #0284c7; padding: 2px 6px; background: #e0f2fe; border-radius: 4px;">
                                                <%= bl.getAction() %>
                                            </span>
                                        </td>
                                        <td style="color: #1e293b; font-weight: 500;">
                                            <%= bl.getUserFullName() != null ? bl.getUserFullName() : bl.getUserID() %>
                                            <small style="color: #94a3b8;">(<%= bl.getUserRole() %>)</small>
                                        </td>
                                        <td style="color: #475569; max-width: 350px;">
                                            <%= bl.getNewValue() != null ? bl.getNewValue() : "-" %>
                                        </td>
                                        <td style="color: #94a3b8; font-family: monospace; font-size: 11px;">
                                            <%= bl.getIpAddress() != null ? bl.getIpAddress() : "-" %>
                                        </td>
                                    </tr>
                                <%  }
                                } else { %>
                                    <tr>
                                        <td colspan="5" style="text-align: center; color: #94a3b8; padding: 24px;">
                                            No audit modification logs found for this waste bin.
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
                <% } %>

            </div>
        </main>
    </div>

    <!-- Chart.js Dual-Dataset Predictive Curve Script -->
    <script>
        document.addEventListener("DOMContentLoaded", function () {
            var rawHistLabels = <%= histLabelsJson %>;
            var rawHistData = <%= histDataJson %>;
            
            var currentFill = <%= f0 != null ? f0 : fill %>;
            var f10 = <%= f10 != null ? f10 : fill %>;
            var f20 = <%= f20 != null ? f20 : fill %>;
            var f30 = <%= f30 != null ? f30 : fill %>;

            // Combine labels: History + 30m Forecast
            var combinedLabels = [];
            var actualSeries = [];
            var forecastSeries = [];

            if (rawHistLabels.length > 0) {
                for (var i = 0; i < rawHistLabels.length; i++) {
                    combinedLabels.push(rawHistLabels[i]);
                    actualSeries.push(rawHistData[i]);
                    forecastSeries.push(null); // No forecast for past points
                }
                // Connect forecast at the last point
                forecastSeries[forecastSeries.length - 1] = actualSeries[actualSeries.length - 1];
            } else {
                combinedLabels.push("Now");
                actualSeries.push(currentFill);
                forecastSeries.push(currentFill);
            }

            // Append +10m, +20m, +30m projection
            combinedLabels.push("+10m (Forecast)");
            actualSeries.push(null);
            forecastSeries.push(f10);

            combinedLabels.push("+20m (Forecast)");
            actualSeries.push(null);
            forecastSeries.push(f20);

            combinedLabels.push("+30m (Forecast)");
            actualSeries.push(null);
            forecastSeries.push(f30);

            var ctx = document.getElementById('predictiveChart').getContext('2d');
            window.predictiveChartInstance = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: combinedLabels,
                    datasets: [
                        {
                            label: 'Actual Telemetry Readings',
                            data: actualSeries,
                            borderColor: '#2563eb',
                            backgroundColor: 'rgba(37, 99, 235, 0.08)',
                            borderWidth: 3,
                            fill: true,
                            tension: 0.25,
                            pointRadius: 5,
                            pointBackgroundColor: '#2563eb'
                        },
                        {
                            label: '30-Minute Projected Fill Curve',
                            data: forecastSeries,
                            borderColor: '#f59e0b',
                            borderWidth: 3,
                            borderDash: [6, 6],
                            fill: false,
                            tension: 0.25,
                            pointRadius: 6,
                            pointBackgroundColor: '#f59e0b',
                            pointHoverRadius: 8
                        },
                        {
                            label: 'Alert Threshold (85%)',
                            data: combinedLabels.map(function() { return 85; }),
                            borderColor: '#ef4444',
                            borderWidth: 1.5,
                            borderDash: [4, 4],
                            pointRadius: 0,
                            fill: false
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: {
                            min: 0,
                            max: 100,
                            title: {
                                display: true,
                                text: 'Fill Percentage (%)',
                                font: { weight: 'bold', size: 12 }
                            },
                            ticks: {
                                callback: function(value) { return value + '%'; }
                            },
                            grid: { color: '#f1f5f9' }
                        },
                        x: {
                            grid: { color: '#f8fafc' },
                            ticks: { font: { size: 11 } }
                        }
                    },
                    plugins: {
                        legend: {
                            display: true,
                            position: 'top',
                            labels: { boxWidth: 14, font: { size: 12 } }
                        },
                        tooltip: {
                            callbacks: {
                                label: function(context) {
                                    if (context.parsed.y !== null) {
                                        return context.dataset.label + ': ' + context.parsed.y + '%';
                                    }
                                    return '';
                                }
                            }
                        }
                    }
                }
            });

            // Real-time Live Sensor Telemetry Polling (every 3 seconds)
            var lastFill = <%= fill %>;
            var currentBinId = "<%= bin != null ? bin.getBinID() : "" %>";

            function pollBinDetailTelemetry() {
                if (!currentBinId) return;

                fetch('${pageContext.request.contextPath}/api/bin/status?binID=' + encodeURIComponent(currentBinId) + '&t=' + Date.now())
                    .then(function(res) {
                        if (!res.ok) throw new Error('Status ' + res.status);
                        return res.json();
                    })
                    .then(function(data) {
                        if (!data || data.currentFill === undefined) return;

                        var newFill = Math.round(data.currentFill);
                        var newStatus = data.status || 'Active';
                        var newReadings = data.readings || [];

                        if (newFill !== lastFill) {
                            lastFill = newFill;

                            // 1. Determine Badge colors
                            var badgeBg = '#10b981';
                            if (newFill >= 85) badgeBg = '#ef4444';
                            else if (newFill >= 60) badgeBg = '#f59e0b';

                            // 2. Update Header
                            var hFill = document.getElementById('liveHeaderFillBadge');
                            if (hFill) {
                                hFill.innerText = newFill + '% Full';
                                hFill.style.background = badgeBg;
                            }
                            var hStatus = document.getElementById('liveHeaderStatusBadge');
                            if (hStatus) hStatus.innerText = newStatus;
                            var hIcon = document.getElementById('liveHeaderBinIcon');
                            if (hIcon) hIcon.style.color = badgeBg;

                            // 3. Update Stat 1 (Current Fill)
                            var statFill = document.getElementById('liveStatCurrentFill');
                            if (statFill) {
                                statFill.innerText = newFill + '%';
                                statFill.style.color = badgeBg;
                            }
                            var statBar = document.getElementById('liveStatProgressBar');
                            if (statBar) {
                                statBar.style.width = Math.min(100, newFill) + '%';
                                statBar.style.background = badgeBg;
                            }

                            // 4. Update Stat 3 (Forecast)
                            var f30 = Math.min(100, Math.round(newFill + 7.5));
                            var statF30 = document.getElementById('liveStatF30');
                            if (statF30) statF30.innerText = f30 + '%';
                            var riskDiv = document.getElementById('liveStatF30Risk');
                            if (riskDiv) {
                                if (f30 >= 85) {
                                    riskDiv.innerText = '⚠️ High risk of overflow within 30m';
                                    riskDiv.style.color = '#ef4444';
                                } else {
                                    riskDiv.innerText = '✅ Within safe operational threshold';
                                    riskDiv.style.color = '#10b981';
                                }
                            }

                            // 5. Update Table
                            var tbody = document.getElementById('liveReadingsTableBody');
                            if (tbody && newReadings.length > 0) {
                                var html = '';
                                newReadings.forEach(function(r, idx) {
                                    var cColor = (r.fillPercent >= 85) ? '#ef4444' : ((r.fillPercent >= 60) ? '#f59e0b' : '#10b981');
                                    var statusTag = '';
                                    if (r.fillPercent >= 85) {
                                        statusTag = '<span style="padding: 3px 8px; border-radius: 4px; background: #fee2e2; color: #b91c1c; font-size: 11px; font-weight: 700;">CRITICAL (FULL)</span>';
                                    } else if (r.fillPercent >= 60) {
                                        statusTag = '<span style="padding: 3px 8px; border-radius: 4px; background: #fef3c7; color: #b45309; font-size: 11px; font-weight: 600;">NEAR FULL</span>';
                                    } else {
                                        statusTag = '<span style="padding: 3px 8px; border-radius: 4px; background: #d1fae5; color: #047857; font-size: 11px; font-weight: 600;">NORMAL</span>';
                                    }
                                    html += '<tr>' +
                                        '<td>' + (idx + 1) + '</td>' +
                                        '<td>' + (r.measuredAt || 'Just now') + '</td>' +
                                        '<td><strong style="color: ' + cColor + ';">' + r.fillPercent + '%</strong></td>' +
                                        '<td>' + statusTag + '</td>' +
                                    '</tr>';
                                });
                                tbody.innerHTML = html;
                            }
                            var countText = document.getElementById('liveReadingsCountText');
                            if (countText) countText.innerText = 'Showing ' + newReadings.length + ' historical readings';

                            // 6. Update Chart
                            if (window.predictiveChartInstance) {
                                var ch = window.predictiveChartInstance;
                                if (ch.data.datasets && ch.data.datasets.length >= 2) {
                                    var d0 = ch.data.datasets[0].data;
                                    var d1 = ch.data.datasets[1].data;
                                    d0[d0.length - 4] = newFill;
                                    d1[d1.length - 4] = newFill;
                                    d1[d1.length - 3] = Math.min(100, Math.round(newFill + 2.5));
                                    d1[d1.length - 2] = Math.min(100, Math.round(newFill + 5.0));
                                    d1[d1.length - 1] = f30;
                                    ch.update();
                                }
                            }

                            // 7. Flash telemetry indicator
                            var pill = document.getElementById('liveTelemetryPill');
                            if (pill) {
                                pill.style.background = '#BBF7D0';
                                pill.innerHTML = '<span style="width: 7px; height: 7px; border-radius: 50%; background: #16A34A; display: inline-block;"></span> TELEMETRY SYNCED (' + newFill + '%)';
                                setTimeout(function() {
                                    pill.style.background = '#DCFCE7';
                                    pill.innerHTML = '<span style="width: 7px; height: 7px; border-radius: 50%; background: #16A34A; display: inline-block;"></span> LIVE STREAM';
                                }, 1500);
                            }
                        }
                    })
                    .catch(function(err) {});
            }

            setInterval(pollBinDetailTelemetry, 3000);
        });

        function printQrBadge() {
            var qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&margin=8&data=<%= bin != null ? bin.getBinCode() : "BIN" %>';
            var win = window.open('', 'PRINT', 'height=650,width=650');
            win.document.write('<!DOCTYPE html><html><head><title>Print QR Badge - <%= bin != null ? bin.getBinCode() : "Bin" %></title>');
            win.document.write('<style>body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; text-align: center; padding: 40px; background: #f8fafc; } .sticker { border: 3px solid #0f172a; border-radius: 18px; padding: 28px; max-width: 320px; margin: 0 auto; background: white; box-shadow: 0 4px 12px rgba(0,0,0,0.1); } img { width: 220px; height: 220px; display: block; margin: 0 auto; } .code { font-size: 26px; font-weight: 900; font-family: monospace; margin: 14px 0 4px; color: #0f172a; } .loc { font-size: 13px; color: #475569; margin-top: 4px; } .zone { font-size: 12px; font-weight: 700; color: #166534; margin-top: 4px; } .brand { font-size: 11px; font-weight: 800; letter-spacing: 2px; color: #64748b; margin-top: 18px; border-top: 1px dashed #cbd5e1; padding-top: 10px; text-transform: uppercase; } @media print { body { background: none; padding: 0; } .sticker { box-shadow: none; } }</style>');
            win.document.write('</head><body>');
            win.document.write('<div class="sticker">');
            win.document.write('<img src="' + qrUrl + '"/>');
            win.document.write('<div class="code"><%= bin != null ? bin.getBinCode() : "" %></div>');
            win.document.write('<div class="loc"><%= bin != null ? bin.getLocation() : "" %></div>');
            win.document.write('<div class="zone">Sector: <%= bin != null ? bin.getAreaName() : "General" %> (ID: <%= bin != null ? bin.getBinID() : "" %>)</div>');
            win.document.write('<div class="brand">SMARTWASTE &bull; FPT CAMPUS IOT</div>');
            win.document.write('</div>');
            win.document.write('</body></html>');
            win.document.close();
            win.focus();
            setTimeout(function() { win.print(); win.close(); }, 600);
        }
    </script>
</body>
</html>