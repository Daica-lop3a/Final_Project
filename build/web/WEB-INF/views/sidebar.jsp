<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.AppUser"%>
<%
    String ctx = request.getContextPath();
    AppUser user = (AppUser) session.getAttribute("user");
    if (user == null) {
        user = new AppUser();
        user.setFullName("Guest User");
        user.setRoleId("USR");
    }
    
    String uri = (String) request.getAttribute("javax.servlet.forward.request_uri");
    if (uri == null || uri.trim().isEmpty()) {
        uri = request.getRequestURI();
    }
    if (uri == null) uri = "";

    boolean isSuperAdmin = user.isSuperAdmin();
    boolean isAdmin = user.isAdmin();
    boolean isManager = user.isManager();
    boolean isSupervisor = user.isSupervisor();
    boolean isStaff = user.isStaff();
    boolean isTechnician = user.isTechnician();
    boolean isAuditor = user.isAuditor();
    boolean isCitizen = user.isCitizen();
    
    String roleBadge = user.getRoleName();
    String displayName = (user.getFullName() != null && !user.getFullName().trim().isEmpty()) 
            ? user.getFullName() : "User";

    // Dynamic role color badges
    String roleBadgeColor = "#00875A";
    String roleBadgeBg = "#DCF2E4";
    if (isSuperAdmin || isAdmin) {
        roleBadgeColor = "#1E3A8A";
        roleBadgeBg = "#DBEAFE";
    } else if (isSupervisor) {
        roleBadgeColor = "#92400E";
        roleBadgeBg = "#FEF3C7";
    } else if (isStaff) {
        roleBadgeColor = "#0369A1";
        roleBadgeBg = "#E0F2FE";
    } else if (isTechnician) {
        roleBadgeColor = "#6D28D9";
        roleBadgeBg = "#EDE9FE";
    } else if (isAuditor) {
        roleBadgeColor = "#0F766E";
        roleBadgeBg = "#CCFBF1";
    } else if (isCitizen) {
        roleBadgeColor = "#9F1239";
        roleBadgeBg = "#FFE4E6";
    }

    // Notifications count
    int unreadNotifCount = 0;
    try {
        if (user != null && user.getUserId() != null) {
            dao.NotificationDAO nDao = new dao.NotificationDAO();
            unreadNotifCount = nDao.countUnread(user.getUserId());
        }
    } catch (Exception ignored) {}

    // Active state checkers
    boolean isDashActive = uri.endsWith("/dashboard") || uri.endsWith("/dashboard/");
    boolean isOpsActive = uri.contains("/collection") || uri.contains("/inspection") || uri.contains("/staff") || uri.contains("/maintenance");
    boolean isBinsActive = uri.contains("/wastebin") || uri.contains("/area") || uri.contains("/map") || uri.contains("/device");
    boolean isGovActive = uri.contains("/user") || uri.contains("/audit-log") || uri.contains("/discrepancy") || uri.contains("/data-quality") || uri.contains("/role") || uri.contains("/admin-approval") || uri.contains("/system") || uri.contains("/catalog");
    boolean isCitizenActive = uri.contains("/citizen-report") || uri.contains("/feedback") || uri.contains("/help") || uri.contains("/guide");
    boolean isReportsActive = uri.contains("/report") || uri.contains("/export");

    // Dynamically detect active Local Wi-Fi IPv4 address
    String detectedLanIp = "127.0.0.1";
    try {
        java.util.Enumeration<java.net.NetworkInterface> nifs = java.net.NetworkInterface.getNetworkInterfaces();
        while (nifs.hasMoreElements()) {
            java.net.NetworkInterface nif = nifs.nextElement();
            if (nif.isLoopback() || !nif.isUp()) continue;
            java.util.Enumeration<java.net.InetAddress> inets = nif.getInetAddresses();
            while (inets.hasMoreElements()) {
                java.net.InetAddress inet = inets.nextElement();
                if (inet instanceof java.net.Inet4Address && !inet.isLoopbackAddress()) {
                    String ip = inet.getHostAddress();
                    if (!ip.startsWith("169.254")) {
                        detectedLanIp = ip;
                        String dName = (nif.getDisplayName() + " " + nif.getName()).toLowerCase();
                        if (dName.contains("wi-fi") || dName.contains("wireless") || dName.contains("wlan")) {
                            break;
                        }
                    }
                }
            }
            String dName = (nif.getDisplayName() + " " + nif.getName()).toLowerCase();
            if (!"127.0.0.1".equals(detectedLanIp) && (dName.contains("wi-fi") || dName.contains("wireless") || dName.contains("wlan"))) {
                break;
            }
        }
    } catch (Exception ignored) {}
    int serverPort = request.getServerPort() > 0 ? request.getServerPort() : 8080;
    String wifiMobileUrl = "http://" + detectedLanIp + ":" + serverPort + ctx;
%>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

<!-- =========================================================
     PROGRESSIVE WEB APP (PWA) MANIFEST & MOBILE ICONS
     ========================================================= -->

<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="default">
<meta name="apple-mobile-web-app-title" content="SmartWaste">
<meta name="theme-color" content="#00875A">
<link rel="apple-touch-icon" href="<%=ctx%>/images/icon-192.png">

<!-- =========================================================
     TOP NAVIGATION BAR STYLES (FACEBOOK CLEAN HORIZONTAL HEADER)
     ========================================================= -->
<style>
    /* 1. Global Reset to unlock 100% screen width */
    .app-shell, .app-layout {
        display: flex !important;
        flex-direction: column !important;
        min-height: 100vh !important;
        width: 100% !important;
    }

    .sidebar, #appSidebar, .sidebar-top-strip, .desktop-nav-toggle {
        display: none !important;
    }

    .main-content,
    .collection-page,
    .maintenance-page,
    .user-page,
    .audit-page,
    .notification-page,
    .smartwaste-form-page,
    .form-page,
    .detail-page,
    .device-page,
    .role-page,
    .catalog-page,
    .insp-page,
    .staff-page,
    .content-area,
    .app-main,
    .main-container,
    .profile-container,
    .approval-page,
    .config-page {
        margin-left: 0 !important;
        width: 100% !important;
        max-width: 100% !important;
        box-sizing: border-box !important;
        padding-top: 16px !important;
    }

    /* 2. Top Navigation Bar Container */
    .smartwaste-top-nav {
        position: sticky;
        top: 0;
        left: 0;
        right: 0;
        width: 100%;
        height: 62px;
        background: rgba(242, 250, 241, 0.88);
        backdrop-filter: blur(20px);
        -webkit-backdrop-filter: blur(20px);
        border-bottom: 1px solid #D1EBCF;
        box-shadow: 0 4px 16px rgba(11, 110, 79, 0.05);
        z-index: 1000;
        box-sizing: border-box;
    }

    .top-nav-inner {
        max-width: 1440px;
        height: 100%;
        margin: 0 auto;
        padding: 0 20px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 16px;
        box-sizing: border-box;
    }

    /* 3. Brand */
    .top-brand {
        display: flex;
        align-items: center;
        gap: 10px;
        text-decoration: none;
        flex-shrink: 0;
    }

    .top-brand-icon {
        width: 36px;
        height: 36px;
        border-radius: 8px;
        background: #00875A;
        color: #FFFFFF;
        font-size: 16px;
        font-weight: 800;
        display: grid;
        place-items: center;
    }

    .top-brand-text {
        font-size: 18px;
        font-weight: 800;
        letter-spacing: 0.04em;
        color: #0A2E20;
        line-height: 1;
    }

    .top-brand-text b {
        color: #00875A;
    }

    .top-campus-tag {
        font-size: 10px;
        font-weight: 800;
        color: #00875A;
        background: #DCF2E4;
        padding: 3px 8px;
        border-radius: 12px;
        border: 1px solid #D1EBCF;
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }

    /* 4. Center Horizontal Navigation Items */
    .top-nav-menu {
        display: flex;
        align-items: center;
        gap: 6px;
        list-style: none;
        margin: 0;
        padding: 0;
        height: 100%;
    }

    .top-nav-item {
        position: relative;
        height: 100%;
        display: flex;
        align-items: center;
    }

    .top-nav-link {
        display: inline-flex;
        align-items: center;
        gap: 7px;
        padding: 7px 16px;
        border-radius: 20px;
        color: #143D2D;
        font-size: 13.5px;
        font-weight: 600;
        text-decoration: none;
        cursor: pointer;
        transition: all 0.15s ease;
        white-space: nowrap;
        background: transparent;
        border: none;
    }

    .top-nav-link:hover {
        background: #DCF2E4;
        color: #00875A;
    }

    .top-nav-link.active {
        color: #FFFFFF !important;
        background: #00875A !important;
        font-weight: 700;
        box-shadow: 0 2px 8px rgba(0, 135, 90, 0.25);
    }

    .top-nav-link.active i {
        color: #FFFFFF !important;
    }

    .top-nav-link i {
        font-size: 14px;
        color: #00875A;
        transition: color 0.15s ease;
    }

    .top-nav-link:hover i,
    .top-nav-link.active i {
        color: #00875A;
    }

    .top-nav-link .caret {
        font-size: 10px;
        margin-left: 2px;
        color: #5E7E70;
    }

    /* 5. Dropdown Flyout Menus */
    .top-dropdown {
        position: absolute;
        top: calc(100% + 2px);
        left: 0;
        min-width: 230px;
        background: #FFFFFF;
        border: 1px solid #D1EBCF;
        border-radius: 8px;
        box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
        padding: 6px;
        display: none;
        flex-direction: column;
        gap: 2px;
        z-index: 1001;
    }

    .top-nav-item:hover .top-dropdown,
    .top-nav-item:focus-within .top-dropdown {
        display: flex;
    }

    .dropdown-link {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 9px 12px;
        border-radius: 6px;
        color: #143D2D;
        font-size: 13px;
        font-weight: 600;
        text-decoration: none;
        transition: all 0.15s ease;
    }

    .dropdown-link:hover {
        background: #EDF8F2;
        color: #00875A;
    }

    .dropdown-link i {
        font-size: 14px;
        width: 18px;
        text-align: center;
        color: #4A6B5D;
    }

    .dropdown-link:hover i {
        color: #00875A;
    }

    .dropdown-divider {
        height: 1px;
        background: #E2F2E5;
        margin: 4px 6px;
    }

    /* 6. Right Actions */
    .top-actions {
        display: flex;
        align-items: center;
        gap: 10px;
        flex-shrink: 0;
    }

    .top-btn {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 6px 14px;
        border-radius: 20px;
        font-size: 12.5px;
        font-weight: 700;
        cursor: pointer;
        text-decoration: none;
        transition: all 0.15s ease;
        border: 1px solid #D1EBCF;
        background: #FFFFFF;
        color: #0A2E20;
    }

    .top-btn:hover {
        background: #DCF2E4;
        border-color: #00875A;
        color: #00875A;
    }

    .top-btn-wifi {
        color: #00875A;
        border-color: #D1EBCF;
    }

    .top-btn-wifi i {
        color: #00875A;
    }

    .top-icon-btn {
        width: 36px;
        height: 36px;
        border-radius: 50%;
        background: #FFFFFF;
        color: #0A2E20;
        display: grid;
        place-items: center;
        text-decoration: none;
        font-size: 15px;
        position: relative;
        transition: all 0.15s ease;
        border: 1px solid #D1EBCF;
        cursor: pointer;
    }

    .top-icon-btn:hover {
        background: #DCF2E4;
        color: #00875A;
    }

    /* User Profile Pill */
    .top-user-wrap {
        position: relative;
    }

    .top-user-pill {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 4px 12px 4px 4px;
        border-radius: 20px;
        background: #FFFFFF;
        border: 1px solid #D1EBCF;
        cursor: pointer;
        transition: all 0.15s ease;
        text-decoration: none;
    }

    .top-user-pill:hover {
        background: #DCF2E4;
        border-color: #00875A;
    }

    .top-avatar {
        width: 28px;
        height: 28px;
        border-radius: 50%;
        background: #00875A;
        color: #FFFFFF;
        font-size: 12px;
        font-weight: 800;
        display: grid;
        place-items: center;
    }

    .top-user-name {
        font-size: 12.5px;
        font-weight: 700;
        color: #0A2E20;
        max-width: 100px;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
    }

    .top-role-tag {
        font-size: 10px;
        font-weight: 700;
        padding: 2px 6px;
        border-radius: 10px;
        text-transform: uppercase;
        letter-spacing: 0.04em;
    }

    .top-user-dropdown-menu {
        position: absolute;
        top: calc(100% + 8px);
        right: 0;
        min-width: 220px;
        background: #FFFFFF;
        border: 1px solid #D1EBCF;
        border-radius: 8px;
        box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
        padding: 6px;
        display: none;
        flex-direction: column;
        gap: 2px;
        z-index: 1002;
    }

    .top-user-wrap:hover .top-user-dropdown-menu,
    .top-user-wrap:focus-within .top-user-dropdown-menu {
        display: flex;
    }

    /* Mobile Hamburger */
    .mobile-menu-trigger {
        display: none;
        width: 36px;
        height: 36px;
        border-radius: 6px;
        background: #EDF8F2;
        border: 1px solid #D1EBCF;
        color: #0A2E20;
        font-size: 16px;
        place-items: center;
        cursor: pointer;
    }

    /* Mobile Drawer */
    .mobile-drawer {
        position: fixed;
        inset: 60px 0 0 0;
        background: #FFFFFF;
        z-index: 999;
        display: none;
        flex-direction: column;
        padding: 20px;
        overflow-y: auto;
        box-shadow: 0 10px 25px rgba(0,0,0,0.15);
    }

    .mobile-drawer.open {
        display: flex;
    }

    .drawer-section-title {
        font-size: 11px;
        font-weight: 800;
        text-transform: uppercase;
        letter-spacing: 0.08em;
        color: #4A6B5D;
        margin: 14px 0 6px 8px;
    }

    @media (max-width: 1024px) {
        .top-nav-menu { display: none; }
        .top-campus-tag { display: none; }
        .mobile-menu-trigger { display: grid; }
    }
</style>

<!-- =========================================================
     TOP NAVIGATION BAR HTML (100% HORIZONTAL HEADER)
     ========================================================= -->
<header class="smartwaste-top-nav">
    <div class="top-nav-inner">

        <!-- 1. Left: Brand -->
        <a href="<%=ctx%>/dashboard" class="top-brand" title="SmartWaste Dashboard">
            <img src="<%=ctx%>/images/logo-horizontal.png" alt="SmartWaste" style="height: 38px; width: auto; object-fit: contain;">
            <span class="top-campus-tag">FPT CAMPUS</span>
        </a>

        <!-- 2. Center: Horizontal Navigation Menu -->
        <nav>
            <ul class="top-nav-menu">

                <!-- Tab: Dashboard -->
                <li class="top-nav-item">
                    <a href="<%=ctx%>/dashboard" class="top-nav-link <%= isDashActive ? "active" : "" %>">
                        <i class="fa-solid fa-gauge-high"></i>
                        <span>Dashboard</span>
                    </a>
                </li>

                <!-- Tab: Logistics & Operations (Hidden for Citizens) -->
                <% if (!isCitizen) { %>
                <li class="top-nav-item">
                    <button type="button" class="top-nav-link <%= isOpsActive ? "active" : "" %>">
                        <i class="fa-solid fa-truck-pickup"></i>
                        <span>Logistics</span>
                        <i class="fa-solid fa-chevron-down caret"></i>
                    </button>
                    <div class="top-dropdown">
                        <a href="<%=ctx%>/collection" class="dropdown-link">
                            <i class="fa-solid fa-route"></i>
                            <span>Collection Tasks</span>
                        </a>
                        <a href="<%=ctx%>/inspection" class="dropdown-link">
                            <i class="fa-solid fa-clipboard-check"></i>
                            <span>Bin Inspections</span>
                        </a>
                        <a href="<%=ctx%>/maintenance" class="dropdown-link">
                            <i class="fa-solid fa-screwdriver-wrench"></i>
                            <span>Hardware Maintenance</span>
                        </a>
                        <% if (isAdmin || isManager || isSupervisor || isSuperAdmin) { %>
                        <div class="dropdown-divider"></div>
                        <a href="<%=ctx%>/staff" class="dropdown-link">
                            <i class="fa-solid fa-users-gear"></i>
                            <span>Field Staff</span>
                        </a>
                        <% } %>
                    </div>
                </li>
                <% } %>

                <!-- Tab: Infrastructure -->
                <li class="top-nav-item">
                    <button type="button" class="top-nav-link <%= isBinsActive ? "active" : "" %>">
                        <i class="fa-solid fa-trash-can"></i>
                        <span>Assets</span>
                        <i class="fa-solid fa-chevron-down caret"></i>
                    </button>
                    <div class="top-dropdown">
                        <a href="<%=ctx%>/wastebin" class="dropdown-link">
                            <i class="fa-solid fa-trash-can"></i>
                            <span>Waste Bins</span>
                        </a>
                        <a href="<%=ctx%>/map" class="dropdown-link">
                            <i class="fa-solid fa-map-location-dot"></i>
                            <span>Live Campus Map</span>
                        </a>
                        <a href="<%=ctx%>/area" class="dropdown-link">
                            <i class="fa-solid fa-map"></i>
                            <span>Campus Zones</span>
                        </a>
                        <% if (isAdmin || isTechnician || isSuperAdmin) { %>
                        <div class="dropdown-divider"></div>
                        <a href="<%=ctx%>/device" class="dropdown-link">
                            <i class="fa-solid fa-microchip"></i>
                            <span>IoT Devices</span>
                        </a>
                        <% } %>
                    </div>
                </li>

                <!-- Tab: Governance & Security (Admin & Auditor only; Manager/Staff/Citizen hidden) -->
                <% if (isAdmin || isSuperAdmin || isAuditor) { %>
                <li class="top-nav-item">
                    <button type="button" class="top-nav-link <%= isGovActive ? "active" : "" %>">
                        <i class="fa-solid fa-shield-halved"></i>
                        <span>Governance</span>
                        <i class="fa-solid fa-chevron-down caret"></i>
                    </button>
                    <div class="top-dropdown">
                        <a href="<%=ctx%>/user" class="dropdown-link">
                            <i class="fa-solid fa-users"></i>
                            <span>User Accounts</span>
                        </a>
                        <% if (isSuperAdmin) { %>
                        <a href="<%=ctx%>/admin-approval" class="dropdown-link">
                            <i class="fa-solid fa-user-check"></i>
                            <span>Admin Approvals</span>
                        </a>
                        <a href="<%=ctx%>/role" class="dropdown-link">
                            <i class="fa-solid fa-user-lock"></i>
                            <span>Roles &amp; Permissions</span>
                        </a>
                        <% } %>

                        <% if (isAuditor || isSuperAdmin) { %>
                        <div class="dropdown-divider"></div>
                        <a href="<%=ctx%>/data-quality" class="dropdown-link">
                            <i class="fa-solid fa-radar"></i>
                            <span>Quality Scanner</span>
                        </a>
                        <a href="<%=ctx%>/discrepancy" class="dropdown-link">
                            <i class="fa-solid fa-scale-balanced"></i>
                            <span>Audit Discrepancies</span>
                        </a>
                        <% } %>

                        <div class="dropdown-divider"></div>
                        <a href="<%=ctx%>/audit-log" class="dropdown-link">
                            <i class="fa-solid fa-clock-rotate-left"></i>
                            <span>Security Audit Logs</span>
                        </a>
                        <% if (isSuperAdmin || isAdmin) { %>
                        <a href="<%=ctx%>/catalog" class="dropdown-link">
                            <i class="fa-solid fa-tags"></i>
                            <span>Catalogs</span>
                        </a>
                        <% } %>
                        <% if (isSuperAdmin) { %>
                        <a href="<%=ctx%>/system/config" class="dropdown-link">
                            <i class="fa-solid fa-sliders"></i>
                            <span>System Rules</span>
                        </a>
                        <% } %>
                    </div>
                </li>
                <% } %>

                <!-- Tab: Citizen Portal -->
                <li class="top-nav-item">
                    <button type="button" class="top-nav-link <%= isCitizenActive ? "active" : "" %>">
                        <i class="fa-solid fa-bullhorn"></i>
                        <span>Citizen</span>
                        <i class="fa-solid fa-chevron-down caret"></i>
                    </button>
                    <div class="top-dropdown">
                        <% if (!isAuditor && !isTechnician) { %>
                        <a href="<%=ctx%>/citizen-report" class="dropdown-link">
                            <i class="fa-solid fa-bullhorn"></i>
                            <span>Feedback Reports</span>
                        </a>
                        <% } %>
                        <a href="<%=ctx%>/help" class="dropdown-link">
                            <i class="fa-solid fa-circle-question"></i>
                            <span>Waste Guidelines &amp; Hotline</span>
                        </a>
                    </div>
                </li>

                <!-- Tab: Analytics & Reports (Hidden for Staff, Tech & Citizens who have no access) -->
                <% if (isSuperAdmin || isAdmin || isManager || isSupervisor || isAuditor) { %>
                <li class="top-nav-item">
                    <button type="button" class="top-nav-link <%= isReportsActive ? "active" : "" %>">
                        <i class="fa-solid fa-chart-line"></i>
                        <span>Analytics</span>
                        <i class="fa-solid fa-chevron-down caret"></i>
                    </button>
                    <div class="top-dropdown">
                        <a href="<%=ctx%>/report" class="dropdown-link">
                            <i class="fa-solid fa-chart-pie"></i>
                            <span>Analytics Reports</span>
                        </a>
                        <a href="javascript:void(0)" onclick="openExportModal('collections')" class="dropdown-link">
                            <i class="fa-solid fa-file-csv"></i>
                            <span>Export CSV Data</span>
                        </a>
                    </div>
                </li>
                <% } %>

            </ul>
        </nav>

        <!-- 3. Right: Utility Actions & User Profile -->
        <div class="top-actions">

            <!-- Mobile QR / Wi-Fi LAN Connect -->
            <button type="button" class="top-btn top-btn-wifi" onclick="openWifiModal()" title="Connect Mobile Phone via QR Code (<%= detectedLanIp %>)">
                <i class="fa-solid fa-qrcode" style="color: #00875A; font-size: 14px;"></i>
                <span style="font-weight: 700;">Mobile QR</span>
            </button>

            <!-- Notifications -->
            <a href="<%=ctx%>/notification" class="top-icon-btn" title="<%= unreadNotifCount > 0 ? unreadNotifCount + " Unread Notification(s)" : "Notifications" %>" style="position: relative;">
                <i class="fa-solid fa-bell"></i>
                <% if (unreadNotifCount > 0) { %>
                    <span style="position: absolute; top: 6px; right: 6px; width: 8px; height: 8px; background: #DC2626; border-radius: 50%; border: 2px solid #FFFFFF;"></span>
                <% } %>
            </a>

            <!-- User Profile Dropdown -->
            <div class="top-user-wrap">
                <div class="top-user-pill">
                    <div class="top-avatar">
                        <%= displayName.length() > 0 ? displayName.substring(0, 1).toUpperCase() : "U" %>
                    </div>
                    <span class="top-user-name"><%= displayName %></span>
                    <span class="top-role-tag" style="color: <%= roleBadgeColor %>; background: <%= roleBadgeBg %>;"><%= roleBadge %></span>
                    <i class="fa-solid fa-chevron-down" style="font-size: 10px; color: #5E7E70;"></i>
                </div>

                <div class="top-user-dropdown-menu">
                    <div style="padding: 8px 12px; border-bottom: 1px solid #E2F2E5; margin-bottom: 4px;">
                        <strong style="display: block; font-size: 13px; color: #0A2E20;"><%= displayName %></strong>
                        <span style="font-size: 11px; color: #4A6B5D;"><%= user.getEmail() != null ? user.getEmail() : "Active Session" %></span>
                    </div>
                    <a href="<%=ctx%>/profile" class="dropdown-link">
                        <i class="fa-solid fa-user-gear"></i>
                        <span>Account Profile</span>
                    </a>
                    <a href="<%=ctx%>/notification" class="dropdown-link">
                        <i class="fa-solid fa-bell"></i>
                        <span>Notification Center</span>
                    </a>
                    <div class="dropdown-divider"></div>
                    <a href="<%=ctx%>/logout" class="dropdown-link" style="color: #DC2626;">
                        <i class="fa-solid fa-arrow-right-from-bracket" style="color: #DC2626;"></i>
                        <span>Sign Out</span>
                    </a>
                </div>
            </div>

            <!-- Mobile Menu Toggle Button (<= 1024px) -->
            <button type="button" class="mobile-menu-trigger" onclick="toggleMobileDrawer()" title="Open Navigation Menu">
                <i class="fa-solid fa-bars"></i>
            </button>

        </div>

    </div>
</header>

<!-- =========================================================
     MOBILE OFF-CANVAS DRAWER (FOR TABLET & MOBILE)
     ========================================================= -->
<div class="mobile-drawer" id="mobileDrawer">
    <div style="display: flex; justify-content: space-between; align-items: center; padding-bottom: 12px; border-bottom: 1px solid #E2F2E5; margin-bottom: 12px;">
        <span style="font-size: 16px; font-weight: 800; color: #0A2E20;">Menu Navigation</span>
        <button type="button" onclick="toggleMobileDrawer()" style="border: none; background: none; font-size: 20px; color: #4A6B5D; cursor: pointer;">
            <i class="fa-solid fa-xmark"></i>
        </button>
    </div>

    <a href="<%=ctx%>/dashboard" class="dropdown-link <%= isDashActive ? "active" : "" %>"><i class="fa-solid fa-gauge-high"></i> Dashboard</a>

    <% if (!isCitizen) { %>
    <div class="drawer-section-title">Logistics & Operations</div>
    <a href="<%=ctx%>/collection" class="dropdown-link"><i class="fa-solid fa-route"></i> Collection Tasks</a>
    <a href="<%=ctx%>/inspection" class="dropdown-link"><i class="fa-solid fa-clipboard-check"></i> Bin Inspections</a>
    <a href="<%=ctx%>/maintenance" class="dropdown-link"><i class="fa-solid fa-screwdriver-wrench"></i> Hardware Maintenance</a>
    <% if (isAdmin || isManager || isSupervisor || isSuperAdmin) { %>
    <a href="<%=ctx%>/staff" class="dropdown-link"><i class="fa-solid fa-users-gear"></i> Field Staff</a>
    <% } %>
    <% } %>

    <div class="drawer-section-title">Infrastructure Assets</div>
    <a href="<%=ctx%>/wastebin" class="dropdown-link"><i class="fa-solid fa-trash-can"></i> Waste Bins</a>
    <a href="<%=ctx%>/map" class="dropdown-link"><i class="fa-solid fa-map-location-dot"></i> Live Map</a>
    <a href="<%=ctx%>/area" class="dropdown-link"><i class="fa-solid fa-map"></i> Campus Zones</a>
    <% if (isAdmin || isTechnician || isSuperAdmin) { %>
    <a href="<%=ctx%>/device" class="dropdown-link"><i class="fa-solid fa-microchip"></i> IoT Devices</a>
    <% } %>

    <% if (isAdmin || isSuperAdmin || isAuditor) { %>
    <div class="drawer-section-title">Governance & Security</div>
    <a href="<%=ctx%>/user" class="dropdown-link"><i class="fa-solid fa-users"></i> User Accounts</a>
    <% if (isSuperAdmin) { %>
    <a href="<%=ctx%>/admin-approval" class="dropdown-link"><i class="fa-solid fa-user-check"></i> Admin Approvals</a>
    <a href="<%=ctx%>/role" class="dropdown-link"><i class="fa-solid fa-user-lock"></i> Roles & Permissions</a>
    <% } %>
    <% if (isAuditor || isSuperAdmin) { %>
    <a href="<%=ctx%>/data-quality" class="dropdown-link"><i class="fa-solid fa-radar"></i> Quality Scanner</a>
    <a href="<%=ctx%>/discrepancy" class="dropdown-link"><i class="fa-solid fa-scale-balanced"></i> Discrepancies</a>
    <% } %>
    <a href="<%=ctx%>/audit-log" class="dropdown-link"><i class="fa-solid fa-clock-rotate-left"></i> Security Audit Logs</a>
    <% if (isSuperAdmin || isAdmin) { %>
    <a href="<%=ctx%>/catalog" class="dropdown-link"><i class="fa-solid fa-tags"></i> Catalogs</a>
    <% } %>
    <% if (isSuperAdmin) { %>
    <a href="<%=ctx%>/system/config" class="dropdown-link"><i class="fa-solid fa-sliders"></i> System Rules</a>
    <% } %>
    <% } %>

    <% if (isSuperAdmin || isAdmin || isManager || isSupervisor || isAuditor) { %>
    <div class="drawer-section-title">Analytics & Reports</div>
    <a href="<%=ctx%>/report" class="dropdown-link"><i class="fa-solid fa-chart-pie"></i> Analytics Reports</a>
    <a href="javascript:void(0)" onclick="toggleMobileDrawer(); openExportModal('collections');" class="dropdown-link"><i class="fa-solid fa-file-csv"></i> Export CSV Data</a>
    <% } %>

    <div class="drawer-section-title">Citizen & Feedback</div>
    <% if (!isAuditor && !isTechnician) { %>
    <a href="<%=ctx%>/citizen-report" class="dropdown-link"><i class="fa-solid fa-bullhorn"></i> Submit Feedback</a>
    <% } %>
    <a href="<%=ctx%>/help" class="dropdown-link"><i class="fa-solid fa-circle-question"></i> Guidelines & Hotline</a>

    <div class="drawer-section-title">Connectivity &amp; Device</div>
    <button type="button" onclick="toggleMobileDrawer(); openWifiModal();" class="dropdown-link" style="border: none; background: none; width: 100%; text-align: left; cursor: pointer; font-size: 13.5px; font-weight: 600; color: #00875A;">
        <i class="fa-solid fa-qrcode" style="color: #00875A;"></i> Mobile QR Access (<%= detectedLanIp %>)
    </button>

    <div class="drawer-section-title">Account</div>
    <a href="<%=ctx%>/profile" class="dropdown-link"><i class="fa-solid fa-user-gear"></i> Profile Settings</a>
    <a href="<%=ctx%>/logout" class="dropdown-link" style="color: #DC2626;"><i class="fa-solid fa-arrow-right-from-bracket" style="color: #DC2626;"></i> Sign Out</a>
</div>

<!-- =========================================================
     WI-FI MOBILE CONNECT MODAL (PRESERVED 100%)
     ========================================================= -->
<div id="wifiAccessModal" style="display: none; position: fixed; inset: 0; background: rgba(5,5,5,0.6); backdrop-filter: blur(4px); z-index: 99999; align-items: center; justify-content: center;">
    <div style="background: #ffffff; border-radius: 10px; padding: 24px; width: 90%; max-width: 360px; text-align: center; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.3); position: relative; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; border: 1px solid #D1EBCF;">
        <button type="button" onclick="closeWifiModal()" style="position: absolute; top: 12px; right: 12px; border: none; background: none; font-size: 22px; color: #4A6B5D; cursor: pointer;">&times;</button>
        <div style="width: 44px; height: 44px; border-radius: 50%; background: #DCF2E4; color: #00875A; font-size: 20px; display: grid; place-items: center; margin: 0 auto 12px;">
            <i class="fa-solid fa-qrcode"></i>
        </div>
        <h3 style="margin: 0 0 6px; font-size: 18px; font-weight: 800; color: #0A2E20;">Mobile Phone QR Access</h3>
        <p style="margin: 0 0 16px; font-size: 13px; color: #4A6B5D; line-height: 1.5;">
            Scan QR code with your phone camera to quickly access SmartWaste.
        </p>

        <!-- QR Code Image -->
        <div style="background: #ffffff; padding: 10px; border-radius: 8px; display: inline-block; border: 1px solid #D1EBCF; box-shadow: 0 1px 3px rgba(0,0,0,0.06); margin-bottom: 14px;">
            <img id="wifiQrImage"
                 src="https://api.qrserver.com/v1/create-qr-code/?size=200x200&amp;margin=6&amp;data=<%= java.net.URLEncoder.encode(wifiMobileUrl, "UTF-8") %>"
                 onerror="this.onerror=null; this.src='https://quickchart.io/qr?size=200&amp;text=' + encodeURIComponent('<%= wifiMobileUrl %>');"
                 alt="Wi-Fi Mobile URL QR Code"
                 style="display: block; width: 180px; height: 180px; border-radius: 4px;">
        </div>

        <!-- Hidden URL for copying (No raw link displayed) -->
        <span id="wifiUrlText" style="display: none;"><%= wifiMobileUrl %></span>

        <!-- Network Advisory Note for Campus/Enterprise Wi-Fi -->
        <div style="background: #FFFBEB; border: 1px solid #FDE68A; border-radius: 6px; padding: 8px 10px; margin-bottom: 12px; text-align: left; font-size: 11.5px; color: #92400E; line-height: 1.4;">
            <div style="font-weight: 700; display: flex; align-items: center; gap: 5px; margin-bottom: 3px;">
                <i class="fa-solid fa-triangle-exclamation"></i> Note for Campus / Public Wi-Fi:
            </div>
            Campus Wi-Fi often enforces AP Isolation (cross-device traffic blocked).<br>
            <strong>Tip:</strong> Enable a <strong>Mobile Hotspot</strong> on your phone/laptop to share the same local network, then update the Server IP below.
        </div>

        <!-- Server IP input -->
        <div style="margin-bottom: 14px; display: flex; align-items: center; justify-content: center; gap: 8px;">
            <span style="font-size: 12px; color: #4A6B5D; font-weight: 600;">Server IP / URL:</span>
            <input type="text" id="customWifiIpInput" value="<%= detectedLanIp %>"
                   style="width: 150px; padding: 5px 8px; font-size: 12.5px; font-weight: 700; font-family: monospace; border: 1px solid #D1EBCF; border-radius: 6px; text-align: center; color: #00875A; background: #EDF8F2;"
                   oninput="onWifiIpChange(this.value)" placeholder="192.168.x.x">
        </div>

        <div style="display: flex; gap: 8px;">
            <button type="button" onclick="copyWifiUrl()" style="flex: 1; padding: 9px; border-radius: 6px; background: #FFFFFF; color: #0A2E20; font-weight: 700; cursor: pointer; border: 1px solid #D1EBCF; font-size: 13px;">
                <i class="fa-regular fa-copy"></i> Copy Link
            </button>
            <button type="button" onclick="closeWifiModal()" style="flex: 1; padding: 9px; border-radius: 6px; background: #00875A; color: white; font-weight: 700; cursor: pointer; border: none; font-size: 13px;">
                Close
            </button>
        </div>
    </div>
</div>

<!-- =========================================================
     ENTERPRISE DATA EXPORT MODAL (DATE RANGE & ENTITY SCOPE)
     ========================================================= -->
<div id="exportDataModal" style="display: none; position: fixed; inset: 0; background: rgba(10, 46, 32, 0.45); backdrop-filter: blur(4px); z-index: 9999; align-items: center; justify-content: center; padding: 20px;">
    <div style="background: white; border-radius: 12px; width: 100%; max-width: 480px; box-shadow: 0 10px 30px rgba(0,0,0,0.18); overflow: hidden; border: 1px solid #D1EBCF; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;">
        <!-- Header -->
        <div style="background: #EDF8F2; padding: 18px 22px; border-bottom: 1px solid #D1EBCF; display: flex; justify-content: space-between; align-items: center;">
            <div style="display: flex; align-items: center; gap: 10px;">
                <div style="width: 36px; height: 36px; border-radius: 8px; background: #00875A; color: white; display: flex; align-items: center; justify-content: center; font-size: 16px;">
                    <i class="fa-solid fa-file-csv"></i>
                </div>
                <div>
                    <h3 style="margin: 0; font-size: 16px; font-weight: 800; color: #0A2E20;">Export CSV Data</h3>
                    <p style="margin: 2px 0 0; font-size: 12px; color: #4A6B5D;">Specify dataset &amp; targeted date range</p>
                </div>
            </div>
            <button type="button" onclick="closeExportModal()" style="background: none; border: none; font-size: 18px; color: #64748B; cursor: pointer; padding: 4px;">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>

        <!-- Form -->
        <form method="GET" action="<%=ctx%>/export" style="padding: 22px;" onsubmit="setTimeout(closeExportModal, 600);">
            <!-- Data Type -->
            <div style="margin-bottom: 16px;">
                <label style="display: block; font-size: 12px; font-weight: 700; color: #1E293B; margin-bottom: 6px;">
                    <i class="fa-solid fa-database" style="color: #00875A;"></i> Data Type to Export:
                </label>
                <select id="exportModalType" name="type" style="width: 100%; padding: 10px 12px; border-radius: 8px; border: 1px solid #CBD5E1; font-size: 13px; font-weight: 600; color: #0A2E20; background: #F8FAFC;">
                    <option value="collections">Collection Operations &amp; Dispatch History</option>
                    <option value="bins">Smart Waste Bins &amp; Fill Status</option>
                    <option value="reports">Citizen Reports &amp; Issues</option>
                    <option value="audit">System Audit Trail &amp; Access Logs</option>
                    <option value="discrepancies">Audit Discrepancies &amp; Findings</option>
                </select>
            </div>

            <!-- Quick Presets -->
            <div style="margin-bottom: 16px;">
                <label style="display: block; font-size: 12px; font-weight: 700; color: #1E293B; margin-bottom: 6px;">
                    <i class="fa-solid fa-bolt" style="color: #F59E0B;"></i> Quick Range Presets:
                </label>
                <div style="display: flex; gap: 6px; flex-wrap: wrap;">
                    <button type="button" onclick="setExportPreset(0)" style="padding: 5px 10px; font-size: 11px; font-weight: 600; border-radius: 6px; border: 1px solid #CBD5E1; background: white; color: #334155; cursor: pointer;">Today</button>
                    <button type="button" onclick="setExportPreset(7)" style="padding: 5px 10px; font-size: 11px; font-weight: 600; border-radius: 6px; border: 1px solid #CBD5E1; background: white; color: #334155; cursor: pointer;">Last 7 Days</button>
                    <button type="button" onclick="setExportPreset(30)" style="padding: 5px 10px; font-size: 11px; font-weight: 600; border-radius: 6px; border: 1px solid #CBD5E1; background: white; color: #334155; cursor: pointer;">Last 30 Days</button>
                    <button type="button" onclick="setExportPreset(-1)" style="padding: 5px 10px; font-size: 11px; font-weight: 600; border-radius: 6px; border: 1px solid #CBD5E1; background: white; color: #334155; cursor: pointer;">This Month</button>
                    <button type="button" onclick="setExportPreset(-99)" style="padding: 5px 10px; font-size: 11px; font-weight: 600; border-radius: 6px; border: 1px solid #CBD5E1; background: white; color: #334155; cursor: pointer;">All Time</button>
                </div>
            </div>

            <!-- Date Inputs -->
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 18px;">
                <div>
                    <label style="display: block; font-size: 12px; font-weight: 700; color: #1E293B; margin-bottom: 6px;">
                        <i class="fa-regular fa-calendar"></i> From Date (Từ ngày):
                    </label>
                    <input type="date" id="exportModalFrom" name="fromDate" style="width: 100%; box-sizing: border-box; padding: 9px 12px; border-radius: 8px; border: 1px solid #CBD5E1; font-size: 13px; color: #0A2E20;">
                </div>
                <div>
                    <label style="display: block; font-size: 12px; font-weight: 700; color: #1E293B; margin-bottom: 6px;">
                        <i class="fa-regular fa-calendar"></i> To Date (Đến ngày):
                    </label>
                    <input type="date" id="exportModalTo" name="toDate" style="width: 100%; box-sizing: border-box; padding: 9px 12px; border-radius: 8px; border: 1px solid #CBD5E1; font-size: 13px; color: #0A2E20;">
                </div>
            </div>
            <p style="margin: -8px 0 18px 0; font-size: 11px; color: #64748B;">
                <i class="fa-solid fa-circle-info"></i> Leave dates empty if you wish to export all historical records.
            </p>

            <!-- Actions -->
            <div style="display: flex; justify-content: flex-end; gap: 10px; padding-top: 14px; border-top: 1px solid #E2E8F0;">
                <button type="button" onclick="closeExportModal()" style="padding: 9px 16px; border-radius: 8px; border: 1px solid #CBD5E1; background: #F1F5F9; color: #475569; font-size: 13px; font-weight: 700; cursor: pointer;">
                    Cancel
                </button>
                <button type="submit" style="padding: 9px 20px; border-radius: 8px; border: none; background: #00875A; color: white; font-size: 13px; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; gap: 6px;">
                    <i class="fa-solid fa-download"></i> Download CSV
                </button>
            </div>
        </form>
    </div>
</div>

<!-- =========================================================
     JAVASCRIPT LOGIC
     ========================================================= -->
<script>
    function toggleMobileDrawer() {
        var drawer = document.getElementById("mobileDrawer");
        if (drawer) {
            drawer.classList.toggle("open");
        }
    }

    function openWifiModal() {
        var modal = document.getElementById("wifiAccessModal");
        if (modal) modal.style.display = "flex";
    }

    function closeWifiModal() {
        var modal = document.getElementById("wifiAccessModal");
        if (modal) modal.style.display = "none";
    }

    function copyWifiUrl() {
        var text = document.getElementById("wifiUrlText").innerText;
        if (navigator.clipboard) {
            navigator.clipboard.writeText(text).then(function() {
                alert("Link copied: " + text);
            });
        } else {
            prompt("Link:", text);
        }
    }

    function onWifiIpChange(val) {
        val = (val || '').trim();
        if (!val) return;
        var port = "<%= serverPort %>";
        var context = "<%= ctx %>";
        var newUrl = "";
        if (val.startsWith("http://") || val.startsWith("https://")) {
            newUrl = val;
        } else if (val.indexOf(":") !== -1) {
            newUrl = "http://" + val + (val.indexOf(context) === -1 ? context : "");
        } else {
            newUrl = "http://" + val + ":" + port + context;
        }
        var urlText = document.getElementById("wifiUrlText");
        if (urlText) urlText.innerText = newUrl;
        var qr = document.getElementById("wifiQrImage");
        if (qr) {
            qr.src = "https://api.qrserver.com/v1/create-qr-code/?size=200x200&margin=6&data=" + encodeURIComponent(newUrl);
            qr.onerror = function() {
                this.onerror = null;
                this.src = "https://quickchart.io/qr?size=200&text=" + encodeURIComponent(newUrl);
            };
        }
    }

    // =========================================================
    // EXPORT MODAL LOGIC
    // =========================================================
    function openExportModal(type, fromDate, toDate) {
        var modal = document.getElementById("exportDataModal");
        if (!modal) return;

        if (type) {
            var typeSelect = document.getElementById("exportModalType");
            if (typeSelect) typeSelect.value = type;
        }

        var fromInput = document.getElementById("exportModalFrom");
        var toInput = document.getElementById("exportModalTo");

        if (fromDate !== undefined && fromDate !== null && fromDate.trim() !== "") {
            fromInput.value = fromDate.trim();
        } else if (!fromInput.value) {
            setExportPreset(30);
        }

        if (toDate !== undefined && toDate !== null && toDate.trim() !== "") {
            toInput.value = toDate.trim();
        }

        modal.style.display = "flex";
    }

    function closeExportModal() {
        var modal = document.getElementById("exportDataModal");
        if (modal) modal.style.display = "none";
    }

    function setExportPreset(days) {
        var fromInput = document.getElementById("exportModalFrom");
        var toInput = document.getElementById("exportModalTo");
        var now = new Date();

        function pad(n) { return n < 10 ? '0' + n : n; }
        function formatDate(d) {
            return d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate());
        }

        if (days === -99) {
            fromInput.value = "";
            toInput.value = "";
        } else if (days === 0) {
            var s = formatDate(now);
            fromInput.value = s;
            toInput.value = s;
        } else if (days === -1) {
            var firstDay = new Date(now.getFullYear(), now.getMonth(), 1);
            fromInput.value = formatDate(firstDay);
            toInput.value = formatDate(now);
        } else {
            var past = new Date();
            past.setDate(now.getDate() - days);
            fromInput.value = formatDate(past);
            toInput.value = formatDate(now);
        }
    }

    window.openExportModal = openExportModal;
    window.closeExportModal = closeExportModal;
    window.setExportPreset = setExportPreset;
    window.openWifiModal = openWifiModal;
    window.closeWifiModal = closeWifiModal;
    window.copyWifiUrl = copyWifiUrl;
    window.onWifiIpChange = onWifiIpChange;
    window.toggleMobileDrawer = toggleMobileDrawer;
</script>
