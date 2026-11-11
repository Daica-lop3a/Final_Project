<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.AppUser"%>
<%@page import="model.WasteBin"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>

<%
    String ctx = request.getContextPath();

    Object userObj = session.getAttribute("user");

    String roleId = (userObj instanceof AppUser)
            ? ((AppUser) userObj).getRoleId()
            : "";
    String roleName = "";

    if (userObj instanceof AppUser) {
        AppUser u = (AppUser) userObj;
        roleName = u.getRoleName();
    }
    boolean isAdmin = "ADM".equals(roleId) || "SAD".equals(roleId);
    boolean isAdminOrManager = isAdmin || "MGR".equals(roleId) || "SUP".equals(roleId);

    String displayName = "User";

    if (userObj != null) {
        try {
            Object name = userObj.getClass().getMethod("getFullName").invoke(userObj);
            if (name != null && !name.toString().trim().isEmpty()) {
                displayName = name.toString();
            }
        } catch (Exception ignored) {}
    }

    Object totalBinsObj = request.getAttribute("totalBins");
    Object totalRequestsObj = request.getAttribute("totalRequests");
    Object totalAlertsObj = request.getAttribute("totalAlerts");
    Object totalMaintenanceObj = request.getAttribute("totalMaintenance");

    String totalBins = totalBinsObj != null ? totalBinsObj.toString() : "0";
    String totalRequests = totalRequestsObj != null ? totalRequestsObj.toString() : "0";
    String totalAlerts = totalAlertsObj != null ? totalAlertsObj.toString() : "0";
    String totalMaintenance = totalMaintenanceObj != null ? totalMaintenanceObj.toString() : "0";

    int activeBins = request.getAttribute("activeBins") != null ? (Integer) request.getAttribute("activeBins") : 0;
    int fullBins = request.getAttribute("fullBins") != null ? (Integer) request.getAttribute("fullBins") : 0;
    int maintenanceBins = request.getAttribute("maintenanceBins") != null ? (Integer) request.getAttribute("maintenanceBins") : 0;

    int pendingRequests = request.getAttribute("pendingRequests") != null ? (Integer) request.getAttribute("pendingRequests") : 0;
    int inProgressRequests = request.getAttribute("inProgressRequests") != null ? (Integer) request.getAttribute("inProgressRequests") : 0;
    int completedRequests = request.getAttribute("completedRequests") != null ? (Integer) request.getAttribute("completedRequests") : 0;

    int unresolvedAlerts = request.getAttribute("unresolvedAlerts") != null ? (Integer) request.getAttribute("unresolvedAlerts") : 0;
    int unreadNotifications = request.getAttribute("unreadNotifications") != null ? (Integer) request.getAttribute("unreadNotifications") : 0;
    int pendingMaintenance = request.getAttribute("pendingMaintenance") != null ? (Integer) request.getAttribute("pendingMaintenance") : 0;

    boolean isAreaHotspot = Boolean.TRUE.equals(request.getAttribute("isAreaHotspot"));
    int hotspotBinCount = request.getAttribute("hotspotBinCount") != null ? (Integer) request.getAttribute("hotspotBinCount") : 0;
    int overdueRequests = request.getAttribute("overdueRequests") != null ? (Integer) request.getAttribute("overdueRequests") : 0;

    List<WasteBin> dashBins = (List<WasteBin>) request.getAttribute("LIST_BIN");
    if (dashBins == null) {
        dashBins = new ArrayList<WasteBin>();
    }

    int totalBinsCount = 0;
    try {
        totalBinsCount = Integer.parseInt(totalBins);
    } catch (Exception ignored) {}
    if (totalBinsCount == 0 && dashBins != null) {
        totalBinsCount = dashBins.size();
    }

    int fleetHealthPct = totalBinsCount > 0 ? (activeBins * 100 / totalBinsCount) : 100;
    if (fleetHealthPct > 100) fleetHealthPct = 100;

    int totalReqsCount = 0;
    try {
        totalReqsCount = Integer.parseInt(totalRequests);
    } catch (Exception ignored) {}

    int pendingReqPct = totalReqsCount > 0 ? (pendingRequests * 100 / totalReqsCount) : 0;
    int inProgressReqPct = totalReqsCount > 0 ? (inProgressRequests * 100 / totalReqsCount) : 0;
    int completedReqPct = totalReqsCount > 0 ? (completedRequests * 100 / totalReqsCount) : 0;

    // Normal bins vs warning bins
    int warningBins = totalBinsCount - activeBins - fullBins - maintenanceBins;
    if (warningBins < 0) warningBins = 0;
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>SmartWaste - Executive Telemetry Dashboard</title>

        <!-- CSS chung -->
        <link rel="stylesheet" href="<%=ctx%>/css/style.css?v=20261021-v2">
        <!-- Leaflet CSS for Google Maps -->
        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
        <!-- CSS rieng cho Dashboard Bento Layout -->
        <link rel="stylesheet" href="<%=ctx%>/css/dashboard.css?v=20261021-v2">
    </head>

    <body>
        <div class="app-shell">

            <!-- =========================================
                 SHARED SIDEBAR
                 ========================================= -->
            <jsp:include page="sidebar.jsp" />

            <!-- =========================================
                 MAIN WORKSPACE CONTENT
                 ========================================= -->
            <main class="main-content">

                <!-- TOPBAR -->
                <header class="topbar">
                    <div style="display: flex; align-items: center;">
                        <button type="button" class="desktop-nav-toggle" onclick="toggleSidebarCollapse()" title="Toggle Sidebar (Expand / Collapse)">
                            <i class="fa-solid fa-bars"></i>
                        </button>
                        <div>
                            <span class="eyebrow">CAMPUS OVERVIEW // LIVE TELEMETRY</span>
                            <h1>Dashboard</h1>
                        </div>
                    </div>

                    <div class="topbar-actions">
                        <!-- Notifications -->
                        <a class="icon-button" href="<%=ctx%>/notification" aria-label="Notifications" title="<%=unreadNotifications%> unread notification(s)">
                            <i class="fa-solid fa-bell"></i>
                            <% if (unreadNotifications > 0) { %>
                            <span class="notification-dot"></span>
                            <% } %>
                        </a>

                        <!-- Profile link -->
                        <a href="<%=ctx%>/profile" class="profile" title="Manage your Profile & Password">
                            <div class="avatar">
                                <%=displayName.substring(0, 1).toUpperCase()%>
                            </div>
                            <div class="profile-info">
                                <strong><%=displayName%></strong>
                                <span><%=roleName%></span>
                            </div>
                        </a>
                    </div>
                </header>

                <div class="dash-container">

                    <!-- =========================================
                         1. EXECUTIVE COMMAND STRIP
                         ========================================= -->
                    <section class="dash-command-strip">
                        <div class="command-user-info">
                            <div class="command-avatar">
                                <%=displayName.substring(0, 1).toUpperCase()%>
                            </div>
                            <div class="command-title-group">
                                <h2>
                                    Welcome, <%=displayName%>
                                    <span class="command-role-badge"><%=roleName%></span>
                                </h2>
                                <div class="command-subtitle">
                                    <span class="command-telemetry-status">
                                        <span class="pulse-beacon"></span>
                                        IoT Sensor Array Online
                                    </span>
                                    <span>•</span>
                                    <span>Campus Smart Node Hub #01</span>
                                    <span>•</span>
                                    <span id="liveClock" style="font-variant-numeric: tabular-nums; font-weight: 600;"></span>
                                    <span>•</span>
                                    <span id="dashLivePill" style="display: inline-flex; align-items: center; gap: 5px; padding: 2px 8px; border-radius: 999px; background: #DCFCE7; color: #166534; font-size: 11px; font-weight: 700; border: 1px solid #86EFAC;">
                                        <span style="width: 6px; height: 6px; border-radius: 50%; background: #16A34A; display: inline-block;"></span> LIVE TELEMETRY
                                    </span>
                                </div>
                            </div>
                        </div>

                        <div class="command-quick-actions">
                            <% if (isAdminOrManager) { %>
                            <a href="<%=ctx%>/collection/create" class="btn-cmd btn-cmd-primary">
                                <i class="fa-solid fa-plus"></i> New Collection
                            </a>
                            <% if (isAdmin || "MGR".equals(roleId) || "TEC".equals(roleId)) { %>
                            <a href="<%=ctx%>/wastebin/create" class="btn-cmd btn-cmd-secondary">
                                <i class="fa-solid fa-trash-can"></i> Add Bin
                            </a>
                            <% } %>
                            <% } else if ("STF".equals(roleId)) { %>
                            <a href="<%=ctx%>/collection" class="btn-cmd btn-cmd-primary">
                                <i class="fa-solid fa-truck"></i> My Route Tasks
                            </a>
                            <% } else if ("TEC".equals(roleId)) { %>
                            <a href="<%=ctx%>/maintenance" class="btn-cmd btn-cmd-primary">
                                <i class="fa-solid fa-wrench"></i> My Work Orders
                            </a>
                            <% } else if ("AUD".equals(roleId)) { %>
                            <a href="<%=ctx%>/data-quality" class="btn-cmd btn-cmd-primary">
                                <i class="fa-solid fa-radar"></i> Quality Scanner
                            </a>
                            <a href="<%=ctx%>/discrepancy" class="btn-cmd btn-cmd-secondary">
                                <i class="fa-solid fa-scale-balanced"></i> Discrepancies
                            </a>
                            <% } else if ("USR".equals(roleId)) { %>
                            <a href="<%=ctx%>/citizen-report/create" class="btn-cmd btn-cmd-primary">
                                <i class="fa-solid fa-bullhorn"></i> Submit Feedback
                            </a>
                            <% } %>

                            <a href="<%=ctx%>/map" class="btn-cmd btn-cmd-secondary" title="View Fullscreen Google Maps">
                                <i class="fa-solid fa-map-location-dot"></i> Live Map
                            </a>
                        </div>
                    </section>

                    <!-- =========================================
                         2. EXECUTIVE 4-TILE KPI RIBBON
                         ========================================= -->
                    <section class="dash-kpi-grid">
                        <!-- KPI 1: Monitored Bins -->
                        <div class="kpi-tile kpi-blue">
                            <div class="kpi-tile-top">
                                <span class="kpi-label">Monitored Bins</span>
                                <div class="kpi-icon-bubble">
                                    <i class="fa-solid fa-trash-can"></i>
                                </div>
                            </div>
                            <div class="kpi-number-wrap">
                                <span class="kpi-number"><%=totalBins%></span>
                                <span class="kpi-trend positive"><i class="fa-solid fa-circle-check"></i> <%=fleetHealthPct%>% Active</span>
                            </div>
                            <div class="kpi-footer-subtext">
                                <span><%=activeBins%> Normal</span>
                                <span><%=fullBins%> Full</span>
                                <span><%=maintenanceBins%> Offline</span>
                            </div>
                        </div>

                        <!-- KPI 2: Collection Routes -->
                        <div class="kpi-tile kpi-teal">
                            <div class="kpi-tile-top">
                                <span class="kpi-label">Collection Routes</span>
                                <div class="kpi-icon-bubble">
                                    <i class="fa-solid fa-route"></i>
                                </div>
                            </div>
                            <div class="kpi-number-wrap">
                                <span class="kpi-number"><%=totalRequests%></span>
                                <span class="kpi-trend neutral"><i class="fa-solid fa-clock"></i> <%=pendingRequests%> Pending</span>
                            </div>
                            <div class="kpi-footer-subtext">
                                <span><%=inProgressRequests%> In Progress</span>
                                <span><%=completedRequests%> Completed</span>
                            </div>
                        </div>

                        <!-- KPI 3: Incident Alerts -->
                        <div class="kpi-tile kpi-amber">
                            <div class="kpi-tile-top">
                                <span class="kpi-label">Active Incidents</span>
                                <div class="kpi-icon-bubble">
                                    <i class="fa-solid fa-triangle-exclamation"></i>
                                </div>
                            </div>
                            <div class="kpi-number-wrap">
                                <span class="kpi-number"><%=unresolvedAlerts%></span>
                                <span class="kpi-trend warning"><i class="fa-solid fa-bell"></i> <%=totalAlerts%> Total</span>
                            </div>
                            <div class="kpi-footer-subtext">
                                <span>Unresolved alerts</span>
                                <a href="<%=ctx%>/alert" class="bento-link">Review &rarr;</a>
                            </div>
                        </div>

                        <!-- KPI 4: Hardware Maintenance -->
                        <div class="kpi-tile kpi-purple">
                            <div class="kpi-tile-top">
                                <span class="kpi-label">Hardware Service</span>
                                <div class="kpi-icon-bubble">
                                    <i class="fa-solid fa-screwdriver-wrench"></i>
                                </div>
                            </div>
                            <div class="kpi-number-wrap">
                                <span class="kpi-number"><%=totalMaintenance%></span>
                                <span class="kpi-trend neutral"><i class="fa-solid fa-microchip"></i> <%=pendingMaintenance%> Open</span>
                            </div>
                            <div class="kpi-footer-subtext">
                                <span>IoT telemetry health</span>
                                <% if (!"USR".equals(roleId)) { %>
                                <a href="<%=ctx%>/maintenance" class="bento-link">Tickets &rarr;</a>
                                <% } else { %>
                                <a href="<%=ctx%>/citizen-report" class="bento-link">Feedback &rarr;</a>
                                <% } %>
                            </div>
                        </div>
                    </section>

                    <!-- =========================================
                         3. ASYMMETRIC BENTO GRID (CENTRAL HUB)
                         ========================================= -->
                    <section class="dash-bento-grid">

                        <!-- BENTO 1: CAMPUS SMART NODE GOOGLE MAP (8 COLS) -->
                        <div class="bento-card bento-col-8">
                            <div class="bento-header">
                                <div class="bento-title-wrap">
                                    <i class="fa-solid fa-map-location-dot" style="color: #00875A;"></i>
                                    <div>
                                        <span class="bento-kicker">Module 01 // Interactive Telemetry</span>
                                        <h3>Campus Smart Node Map</h3>
                                    </div>
                                </div>
                                <div style="display: flex; gap: 8px; align-items: center;">
                                    <div class="dash-map-layer-switch">
                                        <button type="button" id="btnDashRoadmap" class="dash-map-layer-btn active" onclick="setDashMapLayer('roadmap')" title="Standard Map">
                                            <i class="fa-solid fa-map"></i> Map
                                        </button>
                                        <button type="button" id="btnDashSatellite" class="dash-map-layer-btn" onclick="setDashMapLayer('satellite')" title="Satellite View">
                                            <i class="fa-solid fa-satellite"></i> Satellite
                                        </button>
                                    </div>
                                    <a href="<%=ctx%>/map" class="bento-link" style="margin-left: 4px;">
                                        Fullscreen Map <i class="fa-solid fa-arrow-up-right-from-square"></i>
                                    </a>
                                </div>
                            </div>

                            <!-- Embedded Interactive Google Map Container -->
                            <div class="dash-map-wrapper">
                                <div id="dashboardMap"></div>
                            </div>

                            <!-- Map Bottom Overlay / Legend -->
                            <div class="radar-overlay-bottom" style="margin-top: 10px;">
                                <div class="radar-legend">
                                    <div class="radar-legend-item green"><span></span> Safe (&lt; 60%)</div>
                                    <div class="radar-legend-item amber"><span></span> Approaching (60-79%)</div>
                                    <div class="radar-legend-item red"><span></span> Critical (&ge; 80%)</div>
                                    <div class="radar-legend-item" style="color: #5F6368;"><span style="background: #5F6368;"></span> Maintenance</div>
                                </div>
                                <div style="display: flex; align-items: center; gap: 12px;">
                                    <span style="font-size: 11.5px; font-weight: 700; color: #4A6B5D;">
                                        <i class="fa-solid fa-trash-can" style="color: #00875A;"></i> <%=totalBins%> Bins Tracked
                                    </span>
                                    <a href="<%=ctx%>/wastebin" class="bento-link" style="font-size: 11.5px;">
                                        Manage Bins Table <i class="fa-solid fa-arrow-right"></i>
                                    </a>
                                </div>
                            </div>
                        </div>

                        <!-- BENTO 2: CAPACITY UTILIZATION CONCENTRIC GAUGE (4 COLS) -->
                        <div class="bento-card bento-col-4">
                            <div class="bento-header">
                                <div class="bento-title-wrap">
                                    <i class="fa-solid fa-chart-pie"></i>
                                    <div>
                                        <span class="bento-kicker">Module 02 // Capacity Analytics</span>
                                        <h3>Fleet Load Index</h3>
                                    </div>
                                </div>
                                <a href="<%=ctx%>/wastebin" class="bento-link">View Bins</a>
                            </div>

                            <div class="gauge-content">
                                <!-- Concentric Gauge SVG -->
                                <div class="gauge-svg-wrap">
                                    <svg viewBox="0 0 100 100" style="width: 100%; height: 100%; transform: rotate(-90deg);">
                                        <!-- Background Circle -->
                                        <circle cx="50" cy="50" r="40" fill="transparent" stroke="#EDF8F2" stroke-width="12"></circle>
                                        <!-- Safe Fill Arc -->
                                        <circle id="dashGaugeCircle" cx="50" cy="50" r="40" fill="transparent" stroke="#00875A" stroke-width="12"
                                                stroke-dasharray="251.2"
                                                stroke-dashoffset="<%= 251.2 - (251.2 * (fleetHealthPct / 100.0)) %>"
                                                stroke-linecap="round"
                                                style="transition: stroke-dashoffset 0.8s ease;"></circle>
                                    </svg>
                                    <div class="gauge-center-readout">
                                        <span id="dashGaugePctText" class="gauge-pct"><%=fleetHealthPct%>%</span>
                                        <span class="gauge-sub">Fleet Healthy</span>
                                    </div>
                                </div>

                                <!-- Capacity Tier Breakdown -->
                                <div class="gauge-breakdown-list">
                                    <div class="gauge-row">
                                        <div class="gauge-row-label">
                                            <span class="gauge-dot normal"></span>
                                            <span>Normal Operation</span>
                                        </div>
                                        <span class="gauge-row-val"><%=activeBins%> bins</span>
                                    </div>
                                    <div class="gauge-row">
                                        <div class="gauge-row-label">
                                            <span class="gauge-dot warning"></span>
                                            <span>Approaching Full</span>
                                        </div>
                                        <span class="gauge-row-val"><%=warningBins%> bins</span>
                                    </div>
                                    <div class="gauge-row">
                                        <div class="gauge-row-label">
                                            <span class="gauge-dot critical"></span>
                                            <span>Critical Overflow</span>
                                        </div>
                                        <span class="gauge-row-val" style="color: #DC2626;"><%=fullBins%> bins</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- BENTO 3: LOGISTICS DISPATCH VELOCITY (6 COLS) -->
                        <div class="bento-card bento-col-6">
                            <div class="bento-header">
                                <div class="bento-title-wrap">
                                    <i class="fa-solid fa-truck-fast"></i>
                                    <div>
                                        <span class="bento-kicker">Module 03 // Route Execution</span>
                                        <h3>Collection Task Progress</h3>
                                    </div>
                                </div>
                                <% if (!"USR".equals(roleId)) { %>
                                <a href="<%=ctx%>/collection" class="bento-link">
                                    Manage Routes <i class="fa-solid fa-arrow-right"></i>
                                </a>
                                <% } %>
                            </div>

                            <div class="velocity-stack">
                                <!-- Pending -->
                                <div class="velocity-bar-item">
                                    <div class="velocity-bar-header">
                                        <span><i class="fa-regular fa-clock" style="color: #D97706; margin-right: 6px;"></i> Pending Route Assignment</span>
                                        <strong><%=pendingRequests%> tasks (<%=pendingReqPct%>%)</strong>
                                    </div>
                                    <div class="velocity-track">
                                        <div class="velocity-fill pending" style="width: <%=pendingReqPct%>%;"></div>
                                    </div>
                                </div>

                                <!-- In Progress -->
                                <div class="velocity-bar-item">
                                    <div class="velocity-bar-header">
                                        <span><i class="fa-solid fa-truck" style="color: #00875A; margin-right: 6px;"></i> Active En Route / In Progress</span>
                                        <strong><%=inProgressRequests%> tasks (<%=inProgressReqPct%>%)</strong>
                                    </div>
                                    <div class="velocity-track">
                                        <div class="velocity-fill progress" style="width: <%=inProgressReqPct%>%;"></div>
                                    </div>
                                </div>

                                <!-- Completed -->
                                <div class="velocity-bar-item">
                                    <div class="velocity-bar-header">
                                        <span><i class="fa-regular fa-circle-check" style="color: #16A34A; margin-right: 6px;"></i> Completed &amp; Verified</span>
                                        <strong><%=completedRequests%> tasks (<%=completedReqPct%>%)</strong>
                                    </div>
                                    <div class="velocity-track">
                                        <div class="velocity-fill completed" style="width: <%=completedReqPct%>%;"></div>
                                    </div>
                                </div>

                                <div style="margin-top: 10px; padding: 12px 14px; background: #EDF8F2; border-radius: 6px; border: 1px solid #D1EBCF; display: flex; justify-content: space-between; align-items: center; font-size: 12px; color: #65676B;">
                                    <span><i class="fa-solid fa-shield-halved" style="color: #00875A; margin-right: 6px;"></i> Route QR Verification Protocol</span>
                                    <strong style="color: #050505;">Enforced On-Site</strong>
                                </div>
                            </div>
                        </div>

                        <!-- BENTO 4: TACTICAL QUICK ACTION DOCK (6 COLS) -->
                        <div class="bento-card bento-col-6">
                            <div class="bento-header">
                                <div class="bento-title-wrap">
                                    <i class="fa-solid fa-bolt"></i>
                                    <div>
                                        <span class="bento-kicker">Module 04 // Direct Launchpad</span>
                                        <h3>Quick Actions</h3>
                                    </div>
                                </div>
                                <span style="font-size: 11px; color: #65676B; font-weight: 600;">ROLE: <%=roleId%></span>
                            </div>

                            <div class="quick-dock-grid">
                                <% if (isAdminOrManager) { %>
                                <a href="<%=ctx%>/collection/create" class="dock-tile">
                                    <div class="dock-icon">
                                        <i class="fa-solid fa-plus"></i>
                                    </div>
                                    <div class="dock-info">
                                        <strong>Dispatch Task</strong>
                                        <small>Assign route to field staff</small>
                                    </div>
                                </a>

                                <% if (isAdmin || "MGR".equals(roleId) || "TEC".equals(roleId)) { %>
                                <a href="<%=ctx%>/wastebin/create" class="dock-tile">
                                    <div class="dock-icon">
                                        <i class="fa-solid fa-trash-can"></i>
                                    </div>
                                    <div class="dock-info">
                                        <strong>Add Waste Bin</strong>
                                        <small>Register new smart node</small>
                                    </div>
                                </a>
                                <% } %>
                                <% } %>

                                <% if ("STF".equals(roleId)) { %>
                                <a href="<%=ctx%>/collection" class="dock-tile">
                                    <div class="dock-icon">
                                        <i class="fa-solid fa-truck"></i>
                                    </div>
                                    <div class="dock-info">
                                        <strong>My Tasks</strong>
                                        <small>View assigned pickups</small>
                                    </div>
                                </a>
                                <% } %>

                                <% if ("TEC".equals(roleId)) { %>
                                <a href="<%=ctx%>/maintenance" class="dock-tile">
                                    <div class="dock-icon">
                                        <i class="fa-solid fa-screwdriver-wrench"></i>
                                    </div>
                                    <div class="dock-info">
                                        <strong>My Work Orders</strong>
                                        <small>Hardware service queue</small>
                                    </div>
                                </a>
                                <% } %>

                                <% if ("AUD".equals(roleId)) { %>
                                <a href="<%=ctx%>/data-quality" class="dock-tile">
                                    <div class="dock-icon">
                                        <i class="fa-solid fa-radar"></i>
                                    </div>
                                    <div class="dock-info">
                                        <strong>Quality Scanner</strong>
                                        <small>Detect sensor anomalies</small>
                                    </div>
                                </a>
                                <a href="<%=ctx%>/discrepancy" class="dock-tile">
                                    <div class="dock-icon">
                                        <i class="fa-solid fa-folder-open"></i>
                                    </div>
                                    <div class="dock-info">
                                        <strong>Discrepancies</strong>
                                        <small>Reconciliation dossiers</small>
                                    </div>
                                </a>
                                <% } %>

                                <% if ("USR".equals(roleId)) { %>
                                <a href="<%=ctx%>/citizen-report/create" class="dock-tile">
                                    <div class="dock-icon">
                                        <i class="fa-solid fa-bullhorn"></i>
                                    </div>
                                    <div class="dock-info">
                                        <strong>Submit Feedback</strong>
                                        <small>Report overflowing or broken bin</small>
                                    </div>
                                </a>
                                <a href="<%=ctx%>/citizen-report" class="dock-tile">
                                    <div class="dock-icon">
                                        <i class="fa-solid fa-list-check"></i>
                                    </div>
                                    <div class="dock-info">
                                        <strong>My Reports</strong>
                                        <small>Track resolution status</small>
                                    </div>
                                </a>
                                <% } %>

                                <a href="<%=ctx%>/map" class="dock-tile">
                                    <div class="dock-icon">
                                        <i class="fa-solid fa-map-location-dot"></i>
                                    </div>
                                    <div class="dock-info">
                                        <strong>Campus Map</strong>
                                        <small>Live geographical nodes</small>
                                    </div>
                                </a>

                                <a href="<%=ctx%>/alert" class="dock-tile">
                                    <div class="dock-icon">
                                        <i class="fa-solid fa-bell"></i>
                                    </div>
                                    <div class="dock-info">
                                        <strong>Alert Log</strong>
                                        <small><%=unresolvedAlerts%> unresolved incidents</small>
                                    </div>
                                </a>
                            </div>
                        </div>

                        <!-- BENTO 5: ROLE-SPECIFIC COMMAND SUITE (12 COLS) -->
                        <% if ("SAD".equals(roleId)) { 
                            dao.AdminPasswordRequestDAO aprDao = new dao.AdminPasswordRequestDAO();
                            int pendingAdminReqs = aprDao.countPending();
                            dao.UserDAO udao = new dao.UserDAO();
                            int totalUsers = udao.countSearch("", "");
                        %>
                        <div class="bento-card bento-col-12" style="border-left: 4px solid #00875A;">
                            <div class="bento-header">
                                <div class="bento-title-wrap">
                                    <i class="fa-solid fa-shield-halved"></i>
                                    <div>
                                        <span class="bento-kicker">Governance &amp; Master Authority</span>
                                        <h3>Super Administrator Security Command</h3>
                                    </div>
                                </div>
                                <div style="display: flex; gap: 8px;">
                                    <a href="<%=ctx%>/role" class="btn-cmd btn-cmd-secondary" style="font-size: 12px; padding: 6px 12px;">
                                        <i class="fa-solid fa-user-lock"></i> Roles Matrix
                                    </a>
                                    <a href="<%=ctx%>/admin-approval" class="btn-cmd btn-cmd-primary" style="font-size: 12px; padding: 6px 12px;">
                                        <i class="fa-solid fa-user-check"></i> Admin Approvals (<%=pendingAdminReqs%>)
                                    </a>
                                    <a href="<%=ctx%>/system/config" class="btn-cmd btn-cmd-secondary" style="font-size: 12px; padding: 6px 12px;">
                                        <i class="fa-solid fa-sliders"></i> Rules
                                    </a>
                                </div>
                            </div>

                            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 14px;">
                                <div style="background: #EDF8F2; padding: 14px 18px; border-radius: 8px; border: 1px solid #D1EBCF;">
                                    <div style="font-size: 11px; font-weight: 700; color: #65676B; text-transform: uppercase;">Total Managed Accounts</div>
                                    <div style="font-size: 24px; font-weight: 800; color: #050505; margin-top: 4px;"><%=totalUsers%> Users</div>
                                    <div style="font-size: 12px; color: #65676B; margin-top: 2px;">Across all 8 hierarchy tiers</div>
                                </div>
                                <div style="background: #EDF8F2; padding: 14px 18px; border-radius: 8px; border: 1px solid #D1EBCF;">
                                    <div style="font-size: 11px; font-weight: 700; color: #65676B; text-transform: uppercase;">Pending Admin Approvals</div>
                                    <div style="font-size: 24px; font-weight: 800; color: <%=pendingAdminReqs > 0 ? "#D97706" : "#16A34A"%>; margin-top: 4px;">
                                        <%=pendingAdminReqs%> Pending
                                    </div>
                                    <div style="font-size: 12px; margin-top: 2px;">
                                        <a href="<%=ctx%>/admin-approval" class="bento-link">Review requests &rarr;</a>
                                    </div>
                                </div>
                                <div style="background: #EDF8F2; padding: 14px 18px; border-radius: 8px; border: 1px solid #D1EBCF;">
                                    <div style="font-size: 11px; font-weight: 700; color: #65676B; text-transform: uppercase;">Security Integrity Defense</div>
                                    <div style="font-size: 24px; font-weight: 800; color: #16A34A; margin-top: 4px;">
                                        <i class="fa-solid fa-circle-check"></i> Active Defense
                                    </div>
                                    <div style="font-size: 12px; color: #65676B; margin-top: 2px;">Brute-force lockout &amp; append-only audit</div>
                                </div>
                            </div>
                        </div>
                        <% } %>

                        <% if ("AUD".equals(roleId)) { 
                            int auditTotalLogs = request.getAttribute("AUDIT_TOTAL_LOGS") != null ? (Integer) request.getAttribute("AUDIT_TOTAL_LOGS") : 0;
                            int auditDiscTotal = request.getAttribute("AUDIT_DISCREPANCY_TOTAL") != null ? (Integer) request.getAttribute("AUDIT_DISCREPANCY_TOTAL") : 0;
                            int auditDiscOpen = request.getAttribute("AUDIT_DISCREPANCY_OPEN") != null ? (Integer) request.getAttribute("AUDIT_DISCREPANCY_OPEN") : 0;
                            int auditQualityAnomalies = request.getAttribute("AUDIT_QUALITY_ANOMALIES") != null ? (Integer) request.getAttribute("AUDIT_QUALITY_ANOMALIES") : 0;
                        %>
                        <div class="bento-card bento-col-12" style="border-left: 4px solid #00875A;">
                            <div class="bento-header">
                                <div class="bento-title-wrap">
                                    <i class="fa-solid fa-scale-balanced"></i>
                                    <div>
                                        <span class="bento-kicker">Auditor Surveillance</span>
                                        <h3>Quality Assurance &amp; Reconciliation Dossiers</h3>
                                    </div>
                                </div>
                                <div style="display: flex; gap: 8px;">
                                    <a href="<%=ctx%>/data-quality" class="btn-cmd btn-cmd-secondary" style="font-size: 12px; padding: 6px 12px;">
                                        <i class="fa-solid fa-radar"></i> Quality Scanner
                                    </a>
                                    <a href="<%=ctx%>/discrepancy" class="btn-cmd btn-cmd-primary" style="font-size: 12px; padding: 6px 12px;">
                                        <i class="fa-solid fa-folder-open"></i> Discrepancies (<%=auditDiscOpen%>)
                                    </a>
                                </div>
                            </div>

                            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 14px;">
                                <div style="background: #EDF8F2; padding: 14px 18px; border-radius: 8px; border: 1px solid #D1EBCF;">
                                    <div style="font-size: 11px; font-weight: 700; color: #65676B; text-transform: uppercase;">Total Audit Logs</div>
                                    <div style="font-size: 24px; font-weight: 800; color: #050505;"><%=auditTotalLogs%></div>
                                </div>
                                <div style="background: #EDF8F2; padding: 14px 18px; border-radius: 8px; border: 1px solid #D1EBCF;">
                                    <div style="font-size: 11px; font-weight: 700; color: #65676B; text-transform: uppercase;">Detected Anomalies</div>
                                    <div style="font-size: 24px; font-weight: 800; color: <%=auditQualityAnomalies > 0 ? "#DC2626" : "#16A34A"%>;"><%=auditQualityAnomalies%></div>
                                </div>
                                <div style="background: #EDF8F2; padding: 14px 18px; border-radius: 8px; border: 1px solid #D1EBCF;">
                                    <div style="font-size: 11px; font-weight: 700; color: #65676B; text-transform: uppercase;">Open Investigations</div>
                                    <div style="font-size: 24px; font-weight: 800; color: #D97706;"><%=auditDiscOpen%></div>
                                </div>
                                <div style="background: #EDF8F2; padding: 14px 18px; border-radius: 8px; border: 1px solid #D1EBCF;">
                                    <div style="font-size: 11px; font-weight: 700; color: #65676B; text-transform: uppercase;">Total Dossiers</div>
                                    <div style="font-size: 24px; font-weight: 800; color: #00875A;"><%=auditDiscTotal%></div>
                                </div>
                            </div>
                        </div>
                        <% } %>

                        <% if ("USR".equals(roleId)) { %>
                        <div class="bento-card bento-col-12" style="border-left: 4px solid #00875A;">
                            <div class="bento-header">
                                <div class="bento-title-wrap">
                                    <i class="fa-solid fa-leaf"></i>
                                    <div>
                                        <span class="bento-kicker">Citizen Engagement</span>
                                        <h3>FPT Green Campus Portal</h3>
                                    </div>
                                </div>
                                <div style="display: flex; gap: 8px;">
                                    <a href="<%=ctx%>/citizen-report/create" class="btn-cmd btn-cmd-primary" style="font-size: 12px; padding: 6px 12px;">
                                        <i class="fa-solid fa-bullhorn"></i> Submit Feedback
                                    </a>
                                    <a href="<%=ctx%>/map" class="btn-cmd btn-cmd-secondary" style="font-size: 12px; padding: 6px 12px;">
                                        <i class="fa-solid fa-map-location-dot"></i> Live Map
                                    </a>
                                </div>
                            </div>

                            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 14px;">
                                <div style="background: #EDF8F2; padding: 16px; border-radius: 8px; border: 1px solid #D1EBCF;">
                                    <div style="font-size: 13.5px; font-weight: 700; color: #00875A; margin-bottom: 4px;">
                                        <i class="fa-solid fa-recycle"></i> Waste Sorting Guidelines
                                    </div>
                                    <div style="font-size: 12px; color: #65676B;">Separate Organic, Recyclable &amp; General waste before disposal at campus receptacles.</div>
                                </div>
                                <div style="background: #EDF8F2; padding: 16px; border-radius: 8px; border: 1px solid #D1EBCF;">
                                    <div style="font-size: 13.5px; font-weight: 700; color: #0284C7; margin-bottom: 4px;">
                                        <i class="fa-solid fa-bell"></i> Instant Feedback Tracking
                                    </div>
                                    <div style="font-size: 12px; color: #65676B;">Receive real-time notifications as soon as facility staff resolve your submitted reports.</div>
                                </div>
                                <div style="background: #EDF8F2; padding: 16px; border-radius: 8px; border: 1px solid #D1EBCF;">
                                    <div style="font-size: 13.5px; font-weight: 700; color: #D97706; margin-bottom: 4px;">
                                        <i class="fa-solid fa-star"></i> Citizen Star Rating
                                    </div>
                                    <div style="font-size: 12px; color: #65676B;">Rate response promptness from 1 to 5 stars once issues are addressed to maintain quality.</div>
                                </div>
                            </div>
                        </div>
                        <% } %>

                    </section>
                </div>

                <!-- FOOTER -->
                <footer class="footer" style="margin-top: 32px;">
                    <span>&copy; SmartWaste Management System • Facebook Clean Architecture</span>
                    <span>Smarter waste • Sustainable campus</span>
                </footer>

            </main>
        </div>

        <!-- Leaflet JS for Google Maps -->
        <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

        <!-- Live Clock Script & Dashboard Google Map Init -->
        <script>
            function updateClock() {
                var el = document.getElementById('liveClock');
                if (el) {
                    var now = new Date();
                    el.textContent = now.toLocaleDateString('en-GB') + ' ' + now.toLocaleTimeString();
                }
            }
            updateClock();
            setInterval(updateClock, 1000);

            // Waste bin coordinates & telemetry data
            var dashBinsData = [
                <% 
                for (int i = 0; i < dashBins.size(); i++) {
                    WasteBin b = dashBins.get(i);
                    if (b == null) continue;
                    String bCode = b.getBinCode() != null ? b.getBinCode().replace("\"", "\\\"") : "";
                    String bLoc = b.getLocation() != null ? b.getLocation().replace("\"", "\\\"").replace("'", "\\'") : "";
                    String bArea = b.getAreaName() != null ? b.getAreaName().replace("\"", "\\\"") : "Campus";
                    String bStatus = b.getStatus() != null ? b.getStatus() : "Active";
                    double bLat = b.getLatitude();
                    double bLng = b.getLongitude();
                    double bCap = b.getCapacity();
                    double bFill = b.getCurrentFill();
                %>
                {
                    binID: "<%=b.getBinID()%>",
                    binCode: "<%=bCode%>",
                    location: "<%=bLoc%>",
                    lat: <%=bLat%>,
                    lng: <%=bLng%>,
                    capacity: <%=bCap%>,
                    fill: <%=Math.round(bFill)%>,
                    status: "<%=bStatus%>",
                    areaName: "<%=bArea%>"
                }<%=(i < dashBins.size() - 1 ? "," : "")%>
                <% } %>
            ];

            var dashMap = null;
            var dashRoadmapLayer = null;
            var dashSatelliteLayer = null;

            function initDashMap() {
                var mapEl = document.getElementById('dashboardMap');
                if (!mapEl) return;

                // Center coordinates (FPT University HCMC default)
                var defaultCenter = [10.841128, 106.809883];
                var validBins = dashBinsData.filter(function(b) {
                    return b.lat && b.lng && b.lat !== 0 && b.lng !== 0;
                });

                if (validBins.length > 0) {
                    defaultCenter = [validBins[0].lat, validBins[0].lng];
                }

                dashMap = L.map('dashboardMap', {
                    zoomControl: true,
                    attributionControl: false
                }).setView(defaultCenter, 16);

                // Google Maps Roadmap & Satellite Layers
                dashRoadmapLayer = L.tileLayer('https://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}', {
                    maxZoom: 20,
                    subdomains: ['mt0', 'mt1', 'mt2', 'mt3']
                });

                dashSatelliteLayer = L.tileLayer('https://{s}.google.com/vt/lyrs=y&x={x}&y={y}&z={z}', {
                    maxZoom: 20,
                    subdomains: ['mt0', 'mt1', 'mt2', 'mt3']
                });

                dashRoadmapLayer.addTo(dashMap);

                // Helper for status colors
                function getDashPinInfo(fill, status) {
                    if (status === 'Maintenance') return { color: '#5F6368', cls: 'pin-gray', label: 'Maintenance' };
                    if (fill >= 80 || status === 'Full') return { color: '#EA4335', cls: 'pin-red', label: 'Critical' };
                    if (fill >= 60) return { color: '#F4B400', cls: 'pin-yellow', label: 'Approaching' };
                    return { color: '#0F9D58', cls: 'pin-green', label: 'Safe' };
                }

                var boundsMarkers = [];
                window.dashMarkerObjects = [];

                validBins.forEach(function (bin) {
                    var pinInfo = getDashPinInfo(bin.fill, bin.status);

                    var iconHtml = '<div class="gmap-pin-container" title="' + bin.binCode + ' (' + bin.fill + '%)">' +
                        '<div class="gmap-pin-badge ' + pinInfo.cls + '">' +
                            '<i class="fa-solid fa-trash-can"></i>' +
                        '</div>' +
                    '</div>';

                    var customIcon = L.divIcon({
                        html: iconHtml,
                        className: 'dash-custom-icon',
                        iconSize: [30, 36],
                        iconAnchor: [15, 34],
                        popupAnchor: [0, -30]
                    });

                    var marker = L.marker([bin.lat, bin.lng], { icon: customIcon }).addTo(dashMap);

                    var popupHtml = '<div class="dash-popup">' +
                        '<div class="dash-popup-header">' +
                            '<span class="dash-popup-title">' +
                                '<i class="fa-solid fa-trash-can" style="color: ' + pinInfo.color + ';"></i> ' +
                                bin.binCode +
                            '</span>' +
                            '<span class="dash-popup-badge ' + pinInfo.cls + '">' + pinInfo.label + '</span>' +
                        '</div>' +
                        '<div class="dash-popup-body">' +
                            '<div class="dash-popup-row"><i class="fa-solid fa-location-dot"></i> ' + (bin.location || 'Campus Point') + '</div>' +
                            '<div class="dash-popup-row"><i class="fa-solid fa-layer-group"></i> ' + (bin.areaName || 'Main Campus') + '</div>' +
                            '<div style="display: flex; justify-content: space-between; font-weight: 700; margin-top: 6px; font-size: 11px;">' +
                                '<span>Fill Level: ' + bin.fill + '%</span>' +
                                '<span style="color: #65676B;">' + (bin.capacity || 100) + ' L</span>' +
                            '</div>' +
                            '<div class="dash-popup-progress">' +
                                '<div class="dash-popup-fill ' + pinInfo.cls + '" style="width: ' + bin.fill + '%;"></div>' +
                            '</div>' +
                        '</div>' +
                        '<div class="dash-popup-actions">' +
                            '<a href="<%=ctx%>/wastebin/detail?binID=' + bin.binID + '" class="dash-popup-btn">' +
                                '<i class="fa-solid fa-circle-info"></i> View Receptacle' +
                            '</a>' +
                        '</div>' +
                    '</div>';

                    marker.bindPopup(popupHtml);
                    boundsMarkers.push(marker);
                    window.dashMarkerObjects.push({ bin: bin, marker: marker });
                });

                if (boundsMarkers.length > 0) {
                    var group = new L.featureGroup(boundsMarkers);
                    dashMap.fitBounds(group.getBounds().pad(0.18));
                }

                window.addEventListener('resize', function () {
                    if (dashMap) dashMap.invalidateSize();
                });
            }

            function setDashMapLayer(type) {
                if (!dashMap) return;
                if (type === 'roadmap') {
                    dashMap.removeLayer(dashSatelliteLayer);
                    dashMap.addLayer(dashRoadmapLayer);
                    document.getElementById('btnDashRoadmap').classList.add('active');
                    document.getElementById('btnDashSatellite').classList.remove('active');
                } else {
                    dashMap.removeLayer(dashRoadmapLayer);
                    dashMap.addLayer(dashSatelliteLayer);
                    document.getElementById('btnDashSatellite').classList.add('active');
                    document.getElementById('btnDashRoadmap').classList.remove('active');
                }
            }

            // Init map on load
            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', initDashMap);
            } else {
                initDashMap();
            }

            // Real-time Dashboard Telemetry Polling (every 4 seconds)
            function pollDashboardTelemetry() {
                fetch('<%=ctx%>/api/bins-location?t=' + Date.now())
                    .then(function(res) {
                        if (!res.ok) throw new Error('Status ' + res.status);
                        return res.json();
                    })
                    .then(function(liveBins) {
                        if (!Array.isArray(liveBins) || !window.dashMarkerObjects || !window.dashMarkerObjects.length) return;

                        var binMap = {};
                        var safeBins = 0;
                        liveBins.forEach(function(b) {
                            binMap[b.binID] = b;
                            var f = Math.round(b.currentFill);
                            if (f < 80 && b.status !== 'Maintenance') safeBins++;
                        });

                        var hasChange = false;
                        window.dashMarkerObjects.forEach(function(obj) {
                            var bin = obj.bin;
                            var live = binMap[bin.binID];
                            if (live) {
                                var newFill = Math.round(live.currentFill);
                                var newStatus = live.status;
                                if (bin.fill !== newFill || bin.status !== newStatus) {
                                    bin.fill = newFill;
                                    bin.status = newStatus;
                                    hasChange = true;

                                    var pinInfo = getDashPinInfo(bin.fill, bin.status);
                                    var newIcon = L.divIcon({
                                        html: '<div class="gmap-pin-container" title="' + bin.binCode + ' (' + bin.fill + '%)">' +
                                            '<div class="gmap-pin-badge ' + pinInfo.cls + '"><i class="fa-solid fa-trash-can"></i></div></div>',
                                        className: 'dash-custom-icon',
                                        iconSize: [30, 36],
                                        iconAnchor: [15, 34],
                                        popupAnchor: [0, -30]
                                    });
                                    obj.marker.setIcon(newIcon);

                                    var newPopup = '<div class="dash-popup">' +
                                        '<div class="dash-popup-header">' +
                                            '<span class="dash-popup-title"><i class="fa-solid fa-trash-can" style="color: ' + pinInfo.color + ';"></i> ' + bin.binCode + '</span>' +
                                            '<span class="dash-popup-badge ' + pinInfo.cls + '">' + pinInfo.label + '</span>' +
                                        '</div>' +
                                        '<div class="dash-popup-body">' +
                                            '<div class="dash-popup-row"><i class="fa-solid fa-location-dot"></i> ' + (bin.location || 'Campus Point') + '</div>' +
                                            '<div class="dash-popup-row"><i class="fa-solid fa-layer-group"></i> ' + (bin.areaName || 'Main Campus') + '</div>' +
                                            '<div style="display: flex; justify-content: space-between; font-weight: 700; margin-top: 6px; font-size: 11px;">' +
                                                '<span>Fill Level: ' + bin.fill + '%</span>' +
                                                '<span style="color: #65676B;">' + (bin.capacity || 100) + ' L</span>' +
                                            '</div>' +
                                            '<div class="dash-popup-progress"><div class="dash-popup-fill ' + pinInfo.cls + '" style="width: ' + bin.fill + '%;"></div></div>' +
                                        '</div>' +
                                        '<div class="dash-popup-actions">' +
                                            '<a href="<%=ctx%>/wastebin/detail?binID=' + bin.binID + '" class="dash-popup-btn"><i class="fa-solid fa-circle-info"></i> View Receptacle</a>' +
                                        '</div>' +
                                    '</div>';
                                    obj.marker.setPopupContent(newPopup);
                                }
                            }
                        });

                        if (hasChange && liveBins.length > 0) {
                            var healthPct = Math.round((safeBins / liveBins.length) * 100);
                            var gaugeArc = document.getElementById('dashGaugeCircle');
                            if (gaugeArc) {
                                gaugeArc.style.strokeDashoffset = (251.2 - (251.2 * (healthPct / 100.0)));
                            }
                            var gaugePctText = document.getElementById('dashGaugePctText');
                            if (gaugePctText) gaugePctText.innerText = healthPct + '%';
                            var pill = document.getElementById('dashLivePill');
                            if (pill) {
                                pill.style.background = '#BBF7D0';
                                setTimeout(function() { pill.style.background = '#DCFCE7'; }, 800);
                            }
                        }
                    })
                    .catch(function(err) {});
            }

            setInterval(pollDashboardTelemetry, 4000);
        </script>
    </body>
</html>
