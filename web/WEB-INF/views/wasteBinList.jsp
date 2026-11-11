<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="model.WasteBin"%>
<%@page import="model.Area"%>
<%@page import="model.AppUser"%>

<%
    List<WasteBin> list
            = (List<WasteBin>) request.getAttribute("LIST_BIN");

    List<Area> areaList
            = (List<Area>) request.getAttribute("LIST_AREA");

    String error
            = (String) request.getAttribute("ERROR");

    String search
            = (String) request.getAttribute("SEARCH");

    String selectedArea
            = (String) request.getAttribute("AREA_ID");

    String selectedStatus
            = (String) request.getAttribute("STATUS");

    String selectedFillLevel
            = (String) request.getAttribute("FILL_LEVEL");

    String selectedSort
            = (String) request.getAttribute("SORT");

    String selectedOrder
            = (String) request.getAttribute("ORDER");

    if (search == null) {
        search = "";
    }

    if (selectedArea == null) {
        selectedArea = "";
    }

    if (selectedStatus == null) {
        selectedStatus = "";
    }

    if (selectedFillLevel == null) {
        selectedFillLevel = "";
    }

    if (selectedSort == null || selectedSort.isEmpty()) {
        selectedSort = "binID";
    }

    if (selectedOrder == null || selectedOrder.isEmpty()) {
        selectedOrder = "ASC";
    }

    AppUser currentUser
            = (AppUser) session.getAttribute("user");

    String role = currentUser != null
            ? currentUser.getRoleId()
            : "";

    boolean canCreateBin
            = "SAD".equals(role)
            || "ADM".equals(role)
            || "MGR".equals(role)
            || "TEC".equals(role);

    boolean canEditBin
            = "SAD".equals(role)
            || "ADM".equals(role)
            || "MGR".equals(role)
            || "SUP".equals(role)
            || "TEC".equals(role);

    boolean canDeleteBin
            = "SAD".equals(role)
            || "ADM".equals(role)
            || "MGR".equals(role);

    boolean isUSR = "USR".equals(role);
    boolean hasSelectedArea = !selectedArea.trim().isEmpty();

    String ctx = request.getContextPath();

    int currentPage = 1;
    int totalPages = 1;
    int totalRecords = 0;
    int pageSize = 10;
    int activeCount = 0;
    int highFillCount = 0;

    Object cp = request.getAttribute("CURRENT_PAGE");
    Object tp = request.getAttribute("TOTAL_PAGES");
    Object tr = request.getAttribute("TOTAL_RECORDS");
    Object ps = request.getAttribute("PAGE_SIZE");
    Object ac = request.getAttribute("ACTIVE_COUNT");
    Object hfc = request.getAttribute("HIGH_FILL_COUNT");

    if (cp instanceof Number) {
        currentPage = ((Number) cp).intValue();
    }

    if (tp instanceof Number) {
        totalPages = ((Number) tp).intValue();
    }

    if (tr instanceof Number) {
        totalRecords = ((Number) tr).intValue();
    } else if (list != null) {
        totalRecords = list.size();
    }

    if (ps instanceof Number) {
        pageSize = ((Number) ps).intValue();
    }

    if (ac instanceof Number) {
        activeCount = ((Number) ac).intValue();
    }

    if (hfc instanceof Number) {
        highFillCount = ((Number) hfc).intValue();
    }

    if (currentPage < 1) {
        currentPage = 1;
    }

    if (totalPages < 1) {
        totalPages = 1;
    }

    if (currentPage > totalPages) {
        currentPage = totalPages;
    }

    if (pageSize < 1) {
        pageSize = 10;
    }

    List<WasteBin> unassignedBins = (List<WasteBin>) request.getAttribute("UNASSIGNED_BINS");
    List<String> duplicateBins = (List<String>) request.getAttribute("DUPLICATE_BINS");
    String msgParam = request.getParameter("msg");
    String countParam = request.getParameter("count");
%>

<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="UTF-8">

        <meta name="viewport"
              content="width=device-width, initial-scale=1.0">

        <title>Waste Bin Management</title>

        <link rel="stylesheet"
              href="<%=ctx%>/css/style.css?v=20261017-v4">

        <link rel="stylesheet"
              href="<%=ctx%>/css/wastebin.css?v=20261017-v4">

        <style>
            .bin-filter-panel {
                width: 100%;
                box-sizing: border-box;
            }

            .bin-filter-form {
                display: flex;
                align-items: flex-end;
                flex-wrap: wrap;
                gap: 14px;
                width: 100%;
                box-sizing: border-box;
            }

            .bin-filter-form .filter-field {
                display: flex;
                flex-direction: column;
                gap: 6px;
                margin: 0;
            }

            .bin-filter-form .filter-field label {
                margin: 0;
                color: var(--text);
                font-size: 12px;
                font-weight: 700;
            }

            .bin-filter-form .filter-field input,
            .bin-filter-form .filter-field select {
                height: 42px;
                box-sizing: border-box;
                border: 1px solid var(--border);
                border-radius: 10px;
                padding: 0 12px;
                color: var(--text);
                background: var(--white);
                font-family: inherit;
                font-size: 13px;
                outline: none;
            }

            .bin-filter-form .filter-field input:focus,
            .bin-filter-form .filter-field select:focus {
                border-color: var(--green);
                box-shadow: 0 0 0 3px rgba(32, 164, 90, 0.10);
            }

            .bin-filter-form .filter-field input {
                width: 210px;
            }

            .bin-filter-form .filter-field select {
                min-width: 125px;
            }

            .bin-filter-form .filter-field:nth-child(2) select {
                min-width: 160px;
            }

            .bin-filter-form .filter-field:nth-child(3) select {
                min-width: 125px;
            }

            .bin-filter-form .filter-field:nth-child(4) select {
                min-width: 135px;
            }

            .bin-filter-form .filter-field:nth-child(5) select {
                min-width: 135px;
            }

            .bin-filter-form .filter-field:nth-child(6) select {
                min-width: 105px;
            }

            .bin-filter-form .filter-actions {
                display: flex;
                align-items: center;
                gap: 8px;
                margin: 0;
                padding: 0;
            }

            .bin-filter-form .filter-actions .btn {
                height: 42px;
                box-sizing: border-box;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                margin: 0;
                white-space: nowrap;
            }

            .area-required-notice {
                margin-bottom: 16px;
                padding: 14px 16px;
                border: 1px solid var(--border);
                border-radius: 10px;
                color: var(--text);
                background: var(--white);
            }

            @media (max-width: 1200px) {
                .bin-filter-form {
                    align-items: flex-end;
                }

                .bin-filter-form .filter-field input {
                    width: 180px;
                }

                .bin-filter-form .filter-field select {
                    min-width: 115px;
                }
            }

            @media (max-width: 900px) {
                .bin-filter-form {
                    display: grid;
                    grid-template-columns: repeat(2, minmax(0, 1fr));
                    gap: 14px;
                }

                .bin-filter-form .filter-field input,
                .bin-filter-form .filter-field select {
                    width: 100%;
                    min-width: 0;
                }

                .bin-filter-form .filter-actions {
                    grid-column: 1 / -1;
                }
            }

            @media (max-width: 560px) {
                .bin-filter-form {
                    grid-template-columns: 1fr;
                }

                .bin-filter-form .filter-actions {
                    grid-column: auto;
                }
            }
        </style>
    </head>

    <body>

        <div class="app-shell">

            <jsp:include page="sidebar.jsp" />

            <main class="main-content">

                <header class="topbar">
                    <div style="display: flex; align-items: center;">
                        <button type="button" class="desktop-nav-toggle" onclick="toggleSidebarCollapse()" title="Toggle Sidebar (Expand / Collapse)">
                            <i class="fa-solid fa-bars"></i>
                        </button>
                        <div>
                            <div class="eyebrow">
                                SMARTWASTE MANAGEMENT
                            </div>

                            <h1>Waste Bin Management</h1>
                        </div>
                    </div>

                    <div class="topbar-actions">
                        <div class="profile">
                            <div class="avatar">
                                <%=currentUser != null
                                        && currentUser.getFullName() != null
                                        && !currentUser.getFullName().isEmpty()
                                        ? currentUser.getFullName()
                                                .substring(0, 1)
                                                .toUpperCase()
                                        : "U"%>
                            </div>

                            <div class="profile-info">
                                <strong>
                                    <%=currentUser != null
                                            ? currentUser.getFullName()
                                            : ""%>
                                </strong>

                                <span><%=role%></span>
                            </div>
                        </div>
                    </div>
                </header>

                <section class="page-intro">
                    <div>
                        <span class="section-kicker">
                            WASTE BIN MONITORING
                            <span id="binListLivePill" style="display: inline-flex; align-items: center; gap: 5px; padding: 2px 8px; border-radius: 999px; background: #DCFCE7; color: #166534; font-size: 11px; font-weight: 700; border: 1px solid #86EFAC; margin-left: 8px; vertical-align: middle;">
                                <span style="width: 6px; height: 6px; border-radius: 50%; background: #16A34A; display: inline-block;"></span> LIVE STREAM
                            </span>
                        </span>

                        <h2>Monitor and manage waste bins</h2>

                        <p>
                            Track bin capacity, location, status and current
                            fill level across the waste management system.
                        </p>
                    </div>

                    <div class="page-actions">
                        <a class="btn btn-success" style="background: #10b981; color: white; text-decoration: none;"
                           href="<%=ctx%>/map">
                            <i class="fa-solid fa-map-location-dot"></i>
                            View on Map
                        </a>

                        <a class="btn btn-light" style="border: 1px solid #cbd5e1; text-decoration: none;"
                           href="<%=ctx%>/export?type=bins">
                            <i class="fa-solid fa-file-excel" style="color: #10b981;"></i>
                            Export CSV
                        </a>

                        <% if (canCreateBin) {%>
                        <button type="button" class="btn btn-light" style="border: 1px solid #cbd5e1; cursor: pointer;"
                                onclick="document.getElementById('importModal').style.display='flex'">
                            <i class="fa-solid fa-file-import" style="color: #2563eb;"></i>
                            Import CSV
                        </button>

                        <a class="btn btn-primary"
                           href="<%=ctx%>/wastebin/create">
                            <i class="fa-solid fa-plus"></i>
                            Add Waste Bin
                        </a>
                        <% }%>

                        <a class="btn btn-light"
                           href="<%=ctx%>/dashboard">
                            <i class="fa-solid fa-house"></i>
                            Dashboard
                        </a>
                    </div>
                </section>

                <% if ("imported".equals(msgParam)) { %>
                <div style="background: #dcfce7; color: #166534; padding: 13px 18px; border-radius: 10px; border: 1px solid #bbf7d0; margin-bottom: 20px; font-size: 14px; font-weight: 600; display: flex; align-items: center; gap: 10px;">
                    <i class="fa-solid fa-circle-check" style="font-size: 18px;"></i>
                    <span>Successfully imported <%= countParam != null ? countParam : "" %> waste bins from CSV!</span>
                </div>
                <% } %>

                <% if (unassignedBins != null && !unassignedBins.isEmpty()) { %>
                <div style="background: #fffbeb; border: 1px solid #fde68a; color: #92400e; padding: 14px 18px; border-radius: 10px; margin-bottom: 20px; font-size: 13px; display: flex; align-items: center; justify-content: space-between; gap: 15px;">
                    <div style="display: flex; align-items: center; gap: 12px;">
                        <i class="fa-solid fa-triangle-exclamation" style="font-size: 20px; color: #d97706;"></i>
                        <div>
                            <strong>IoT Hardware Warning:</strong> <%= unassignedBins.size() %> waste bin(s) currently do not have an attached IoT sensor 
                            (<% for (int i = 0; i < unassignedBins.size(); i++) { %><%= unassignedBins.get(i).getBinCode() %><%= i < unassignedBins.size() - 1 ? ", " : "" %><% } %>).
                        </div>
                    </div>
                    <a href="<%=ctx%>/device" class="btn" style="background: #d97706; color: white; padding: 6px 14px; border-radius: 6px; text-decoration: none; font-weight: 700; font-size: 12px; white-space: nowrap;">
                        <i class="fa-solid fa-microchip"></i> Device Management
                    </a>
                </div>
                <% } %>

                <% if (duplicateBins != null && !duplicateBins.isEmpty()) { %>
                <div style="background: #fef2f2; border: 1px solid #fecaca; color: #991b1b; padding: 14px 18px; border-radius: 10px; margin-bottom: 20px; font-size: 13px; display: flex; align-items: center; gap: 12px;">
                    <i class="fa-solid fa-circle-exclamation" style="font-size: 20px;"></i>
                    <div>
                        <strong>Duplicate Sensor Warning:</strong> Detected duplicate device assignments for: <%= duplicateBins.toString() %>.
                    </div>
                </div>
                <% } %>

                <% if (error != null) {%>
                <div class="alert-error">
                    <span class="alert-error-icon">
                        <i class="fa-solid fa-circle-exclamation"></i>
                    </span>

                    <span><%=error%></span>
                </div>
                <% }%>

                <section class="bin-summary">

                    <div class="summary-card">
                        <div class="summary-icon summary-icon-total">
                            <i class="fa-solid fa-trash-can"></i>
                        </div>

                        <div>
                            <span>Total Bins</span>
                            <strong><%=totalRecords%></strong>
                        </div>
                    </div>

                    <div class="summary-card">
                        <div class="summary-icon summary-icon-active">
                            <i class="fa-solid fa-circle-check"></i>
                        </div>

                        <div>
                            <span>Active</span>
                            <strong><%=activeCount%></strong>
                        </div>
                    </div>

                    <div class="summary-card">
                        <div class="summary-icon summary-icon-warning">
                            <i class="fa-solid fa-triangle-exclamation"></i>
                        </div>

                        <div>
                            <span>High Fill</span>
                            <strong><%=highFillCount%></strong>
                        </div>
                    </div>

                </section>

                <section class="panel bin-filter-panel">

                    <div class="panel-header">
                        <div>
                            <span class="panel-kicker">FILTER &amp; SORT</span>
                            <h3>Waste Bin Filters</h3>
                        </div>
                    </div>

                    <form method="GET"
                          action="<%=ctx%>/wastebin"
                          class="bin-filter-form">

                        <% if (!isUSR || hasSelectedArea) {%>
                        <div class="filter-field">
                            <label for="search">Search</label>

                            <input type="text"
                                   id="search"
                                   name="search"
                                   value="<%=search%>"
                                   placeholder="Bin Code / Location">
                        </div>
                        <% }%>

                        <div class="filter-field">
                            <label for="areaID">Area</label>

                            <select id="areaID"
                                    name="areaID"
                                    <%=isUSR ? "required" : ""%>
                                    <%=isUSR ? "onchange=\"this.form.submit()\"" : ""%>>

                                <% if (!isUSR) { %>
                                <option value="">All</option>
                                <% } else { %>
                                <option value="">Select Area</option>
                                <% } %>

                                <%
                                    if (areaList != null) {
                                        for (Area area : areaList) {
                                            boolean selected
                                                    = area.getAreaId() != null
                                                    && area.getAreaId().equals(selectedArea);
                                %>
                                <option value="<%=area.getAreaId()%>"
                                        <%=selected ? "selected" : ""%>>
                                    <%=area.getAreaId()%> &mdash; <%=area.getAreaName()%>
                                </option>
                                <%
                                        }
                                    }
                                %>
                            </select>
                        </div>

                        <% if (!isUSR || hasSelectedArea) {%>

                        <div class="filter-field">
                            <label for="status">Status</label>

                            <select id="status" name="status">
                                <option value=""
                                        <%=selectedStatus.isEmpty()
                                        ? "selected" : ""%>>
                                    All
                                </option>

                                <option value="Active"
                                        <%= "Active".equalsIgnoreCase(selectedStatus)
                                        ? "selected" : ""%>>
                                    Active
                                </option>

                                <option value="Full"
                                        <%= "Full".equalsIgnoreCase(selectedStatus)
                                        ? "selected" : ""%>>
                                    Full
                                </option>
                            </select>
                        </div>

                        <div class="filter-field">
                            <label for="fillLevel">Fill Level</label>

                            <select id="fillLevel" name="fillLevel">
                                <option value=""
                                        <%=selectedFillLevel.isEmpty()
                                        ? "selected" : ""%>>
                                    All
                                </option>

                                <option value="Low"
                                        <%= "Low".equalsIgnoreCase(selectedFillLevel)
                                        ? "selected" : ""%>>
                                    Low
                                </option>

                                <option value="Medium"
                                        <%= "Medium".equalsIgnoreCase(selectedFillLevel)
                                        ? "selected" : ""%>>
                                    Medium
                                </option>

                                <option value="High"
                                        <%= "High".equalsIgnoreCase(selectedFillLevel)
                                        ? "selected" : ""%>>
                                    High
                                </option>
                            </select>
                        </div>

                        <div class="filter-field">
                            <label for="sort">Sort by</label>

                            <select id="sort" name="sort">
                                <option value="binID"
                                        <%= "binID".equals(selectedSort)
                                        ? "selected" : ""%>>
                                    Bin ID
                                </option>

                                <option value="binCode"
                                        <%= "binCode".equals(selectedSort)
                                        ? "selected" : ""%>>
                                    Bin Code
                                </option>

                                <option value="capacity"
                                        <%= "capacity".equals(selectedSort)
                                        ? "selected" : ""%>>
                                    Capacity
                                </option>

                                <option value="currentFill"
                                        <%= "currentFill".equals(selectedSort)
                                        ? "selected" : ""%>>
                                    Current Fill
                                </option>
                            </select>
                        </div>

                        <div class="filter-field">
                            <label for="order">Order</label>

                            <select id="order" name="order">
                                <option value="ASC"
                                        <%= "ASC".equalsIgnoreCase(selectedOrder)
                                        ? "selected" : ""%>>
                                    ASC
                                </option>

                                <option value="DESC"
                                        <%= "DESC".equalsIgnoreCase(selectedOrder)
                                        ? "selected" : ""%>>
                                    DESC
                                </option>
                            </select>
                        </div>

                        <div class="filter-actions">
                            <button type="submit" class="btn btn-primary">
                                <i class="fa-solid fa-filter"></i>
                                Apply Filter
                            </button>

                            <a href="<%=ctx%>/wastebin<%=isUSR && hasSelectedArea
                                    ? "?areaID=" + URLEncoder.encode(selectedArea, "UTF-8")
                                    : ""%>"
                               class="btn btn-light">
                                <i class="fa-solid fa-rotate-left"></i>
                                Reset
                            </a>
                        </div>

                        <% } else {%>

                        <div class="filter-actions">
                            <a href="<%=ctx%>/wastebin"
                               class="btn btn-light">
                                <i class="fa-solid fa-rotate-left"></i>
                                Reset
                            </a>
                        </div>

                        <% } %>

                    </form>

                </section>

                <% if (isUSR && !hasSelectedArea) { %>

                <div class="area-required-notice" style="margin-top:20px;">
                    Please select an Area to view its waste bins.
                </div>

                <% } else {%>

                <section class="panel bin-panel"
                         style="margin-top:20px;">

                    <div class="panel-header">
                        <div>
                            <span class="panel-kicker">BIN INVENTORY</span>
                            <h3>Waste Bin List</h3>
                        </div>

                        <span class="record-count">
                            <%=totalRecords%> records
                        </span>
                    </div>

                    <div class="table-wrapper">
                        <table class="data-table">

                            <thead>
                                <tr>
                                    <th>Bin ID</th>
                                    <th>Bin Code</th>
                                    <th>Location</th>
                                    <th>Capacity</th>
                                    <th>Current Fill</th>
                                    <th>Status</th>
                                    <th>Area</th>
                                    <th>Action</th>
                                </tr>
                            </thead>

                            <tbody>

                                <% if (list != null && !list.isEmpty()) {
                                        for (WasteBin bin : list) {

                                            double fill = bin.getCurrentFill();

                                            String fillClass = "fill-green";
                                            String fillLabel = "Low";

                                            if (fill >= 80) {
                                                fillClass = "fill-red";
                                                fillLabel = "High";
                                            } else if (fill >= 50) {
                                                fillClass = "fill-yellow";
                                                fillLabel = "Medium";
                                            }
                                %>

                                <tr id="bin-row-<%=bin.getBinID()%>" style="transition: background-color 0.4s ease;">
                                    <td>
                                        <span class="bin-id">
                                            #<%=bin.getBinID()%>
                                        </span>
                                    </td>

                                    <td>
                                        <span class="bin-code">
                                            <%=bin.getBinCode()%>
                                        </span>
                                    </td>

                                    <td>
                                        <div class="location-cell">
                                            <span class="location-icon">
                                                <i class="fa-solid fa-location-dot"></i>
                                            </span>

                                            <span><%=bin.getLocation()%></span>
                                        </div>
                                    </td>

                                    <td>
                                        <span class="capacity-value">
                                            <%=bin.getCapacity()%>
                                        </span>
                                    </td>

                                    <td>
                                        <div class="fill-cell">
                                            <div class="fill-info">
                                                <strong class="<%=fillClass%>">
                                                    <%=fill%>%
                                                </strong>

                                                <span class="<%=fillClass%>">
                                                    <%=fillLabel%>
                                                </span>
                                            </div>

                                            <div class="fill-bar">
                                                <div class="fill-progress <%=fillClass%>"
                                                     style="width: <%=Math.min(fill, 100)%>%;">
                                                </div>
                                            </div>
                                        </div>
                                    </td>

                                    <td>
                                        <%
                                            String binSt = bin.getStatus() != null ? bin.getStatus() : "Active";
                                            String stClass = "status-" + binSt.toLowerCase().replace(" ", "_");
                                        %>
                                        <span class="status-badge <%= stClass %>">
                                            <span class="status-dot"></span>
                                            <%= binSt %>
                                        </span>
                                    </td>

                                    <td>
                                        <span class="area-badge">
                                            <i class="fa-solid fa-map-pin" style="color: #00875A; font-size: 11px; margin-right: 4px;"></i>
                                            <%= bin.getAreaID() != null ? bin.getAreaID() : "N/A" %>
                                        </span>
                                    </td>

                                    <td>
                                        <div class="action-group">

                                            <a class="action-btn action-view"
                                               href="<%=ctx%>/wastebin/view?id=<%=bin.getBinID()%><%=isUSR ? "&amp;areaID=" + URLEncoder.encode(selectedArea, "UTF-8") : ""%>">
                                                <i class="fa-solid fa-eye"></i>
                                                View
                                            </a>

                                            <button type="button" class="action-btn" style="background: #DCF2E4; color: #00875A; border: 1px solid #D1EBCF; cursor: pointer; font-weight: 700;"
                                                    onclick="previewBinQr('<%=bin.getBinCode()%>', '<%=bin.getBinID()%>', '<%=bin.getLocation() != null ? bin.getLocation().replace("'", "\\'") : ""%>')"
                                                    title="View, Scan &amp; Print QR Badge">
                                                <i class="fa-solid fa-qrcode" style="color: #00875A;"></i>
                                                QR Code
                                            </button>

                                            <% if (isUSR) { %>
                                            <a class="action-btn" style="background: #f59e0b; color: white; border: none; text-decoration: none;"
                                               href="<%=ctx%>/citizen-report/create?binID=<%=bin.getBinID()%>" title="Report issue with this bin">
                                                <i class="fa-solid fa-bullhorn"></i>
                                                Report
                                            </a>
                                            <% } %>

                                            <% if (canEditBin) {%>

                                            <a class="action-btn action-edit"
                                               href="<%=ctx%>/wastebin/edit?id=<%=bin.getBinID()%>">
                                                <i class="fa-solid fa-pen"></i>
                                                Edit
                                            </a>
                                            <% } %>

                                            <% if (canDeleteBin) { %>
                                            <form action="<%=ctx%>/wastebin/delete"
                                                  method="POST"
                                                  onsubmit="return confirm('Are you sure you want to delete this waste bin?');">

                                                <input type="hidden"
                                                       name="id"
                                                       value="<%=bin.getBinID()%>">

                                                <button type="submit"
                                                        class="action-btn action-delete">
                                                    <i class="fa-solid fa-trash-can"></i>
                                                    Delete
                                                </button>
                                            </form>
                                            <% } %>

                                        </div>
                                    </td>
                                </tr>

                                <%
                                    }
                                } else {
                                %>

                                <tr>
                                    <td colspan="8">
                                        <div class="empty-state">
                                            <div class="empty-icon">
                                                <i class="fa-solid fa-trash-can"></i>
                                            </div>

                                            <strong>No waste bins found</strong>

                                            <span>
                                                There are currently no waste
                                                bins available in the system.
                                            </span>
                                        </div>
                                    </td>
                                </tr>

                                <% } %>

                            </tbody>
                        </table>
                    </div>

                    <%
                        request.setAttribute(
                                "PAGINATION_BASE_URL",
                                ctx + "/wastebin"
                        );

                        request.setAttribute(
                                "PAGINATION_CURRENT_PAGE",
                                currentPage
                        );

                        request.setAttribute(
                                "PAGINATION_TOTAL_PAGES",
                                totalPages
                        );

                        request.setAttribute(
                                "PAGINATION_TOTAL_RECORDS",
                                totalRecords
                        );

                        request.setAttribute(
                                "PAGINATION_PAGE_SIZE",
                                pageSize
                        );
                    %>

                    <jsp:include page="/WEB-INF/views/common/pagination.jsp" />

                </section>

                <% }%>

                <footer class="footer">
                    <span>SmartWaste Management System</span>
                    <span>Waste Bin Monitoring</span>
                </footer>

            </main>
        </div>

        <!-- CSV IMPORT MODAL -->
        <div id="importModal" style="display: none; position: fixed; inset: 0; background: rgba(15,23,42,0.6); z-index: 9999; align-items: center; justify-content: center;">
            <div style="background: white; border-radius: 14px; max-width: 600px; width: 90%; padding: 26px; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.2);">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px;">
                    <h3 style="margin: 0; font-size: 18px; color: #0f172a;"><i class="fa-solid fa-file-csv" style="color: #2563eb;"></i> Import Waste Bins from CSV</h3>
                    <button type="button" onclick="document.getElementById('importModal').style.display='none'" style="border: none; background: none; font-size: 24px; cursor: pointer; color: #64748b; line-height: 1;">&times;</button>
                </div>
                <p style="color: #64748b; font-size: 13px; margin: 0 0 14px;">
                    Enter CSV rows with format: <code>binCode,location,latitude,longitude,capacity,areaID</code>
                </p>
                <form method="POST" action="<%=ctx%>/wastebin/import">
                    <textarea name="csvData" rows="8" style="width: 100%; box-sizing: border-box; border: 1px solid #cbd5e1; border-radius: 8px; padding: 10px; font-family: monospace; font-size: 12px;" placeholder="BIN-A1-04,Innovation 3rd Floor,10.841500,106.810100,120,AREA-01&#10;BIN-B1-04,Dormitory C Entrance,10.840700,106.809300,120,AREA-02"></textarea>
                    <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 14px;">
                        <button type="button" onclick="document.getElementById('importModal').style.display='none'" class="btn btn-light" style="padding: 8px 16px; border: 1px solid #cbd5e1; border-radius: 8px; cursor: pointer;">Cancel</button>
                        <button type="submit" class="btn btn-primary" style="padding: 8px 16px; background: #2563eb; color: white; border: none; border-radius: 8px; font-weight: 700; cursor: pointer;">Import Now</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- QR CODE PREVIEW & PRINT MODAL -->
        <div id="binQrModal" style="display: none; position: fixed; inset: 0; background: rgba(5, 5, 5, 0.6); backdrop-filter: blur(4px); z-index: 99999; align-items: center; justify-content: center;">
            <div style="background: #ffffff; border-radius: 12px; padding: 26px; width: 90%; max-width: 380px; text-align: center; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.25); position: relative; border: 1px solid #D1EBCF;">
                <button type="button" onclick="document.getElementById('binQrModal').style.display='none'" style="position: absolute; top: 12px; right: 12px; border: none; background: none; font-size: 22px; color: #65676B; cursor: pointer;">&times;</button>
                <div style="font-size: 11px; font-weight: 800; text-transform: uppercase; letter-spacing: 1px; color: #00875A; margin-bottom: 6px;">SmartWaste QR Identifier</div>
                <h3 id="modalBinCode" style="margin: 0 0 14px; font-size: 22px; font-family: monospace; font-weight: 800; color: #050505;"></h3>
                <div style="background: #ffffff; padding: 10px; border-radius: 8px; border: 1px solid #D1EBCF; display: inline-block; margin-bottom: 12px;">
                    <img id="modalQrImg" src="" alt="Bin QR Code" style="width: 190px; height: 190px; display: block;"
                         onerror="this.onerror=null; this.src='https://quickchart.io/qr?size=250&text=' + encodeURIComponent(curBinCode);">
                </div>
                <div id="modalBinId" style="font-size: 12px; font-weight: 700; color: #65676B; margin-bottom: 4px;"></div>
                <p id="modalBinLoc" style="font-size: 13px; color: #1C1E21; margin: 0 0 18px;"></p>
                <div style="display: flex; gap: 8px; justify-content: center;">
                    <button type="button" onclick="printModalQr()" class="btn btn-primary" style="padding: 9px 18px; font-size: 13px; font-weight: 700; background: #00875A; color: white; border: none; border-radius: 6px; cursor: pointer;">
                        <i class="fa-solid fa-print"></i> Print Sticker
                    </button>
                    <button type="button" onclick="document.getElementById('binQrModal').style.display='none'" class="btn btn-light" style="padding: 9px 18px; font-size: 13px; border: 1px solid #D1EBCF; border-radius: 6px; cursor: pointer; background: #FFFFFF; color: #050505;">
                        Close
                    </button>
                </div>
            </div>
        </div>

        <script>
            var curBinCode = "";
            var curBinId = "";
            var curBinLoc = "";

            function previewBinQr(binCode, binId, location) {
                curBinCode = binCode;
                curBinId = binId;
                curBinLoc = location;
                document.getElementById('modalBinCode').innerText = binCode;
                document.getElementById('modalBinId').innerText = "Internal ID: #" + binId;
                document.getElementById('modalBinLoc').innerText = location;
                var qrImg = document.getElementById('modalQrImg');
                qrImg.onerror = function() {
                    this.onerror = null;
                    this.src = 'https://quickchart.io/qr?size=250&text=' + encodeURIComponent(binCode);
                };
                qrImg.src = 'https://api.qrserver.com/v1/create-qr-code/?size=250x250&margin=8&data=' + encodeURIComponent(binCode);
                document.getElementById('binQrModal').style.display = 'flex';
            }

            function printModalQr() {
                var qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&margin=8&data=' + encodeURIComponent(curBinCode);
                var win = window.open('', 'PRINT', 'height=650,width=650');
                win.document.write('<!DOCTYPE html><html><head><title>Print QR Badge - ' + curBinCode + '</title>');
                win.document.write('<style>body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; text-align: center; padding: 40px; background: #f8fafc; } .sticker { border: 3px solid #0f172a; border-radius: 18px; padding: 28px; max-width: 320px; margin: 0 auto; background: white; box-shadow: 0 4px 12px rgba(0,0,0,0.1); } img { width: 220px; height: 220px; display: block; margin: 0 auto; } .code { font-size: 26px; font-weight: 900; font-family: monospace; margin: 14px 0 4px; color: #0f172a; } .loc { font-size: 13px; color: #475569; margin-top: 4px; } .zone { font-size: 12px; font-weight: 700; color: #166534; margin-top: 4px; } .brand { font-size: 11px; font-weight: 800; letter-spacing: 2px; color: #64748b; margin-top: 18px; border-top: 1px dashed #cbd5e1; padding-top: 10px; text-transform: uppercase; } @media print { body { background: none; padding: 0; } .sticker { box-shadow: none; } }</style>');
                win.document.write('</head><body><div class="sticker">');
                win.document.write('<img src="' + qrUrl + '"/>');
                win.document.write('<div class="code">' + curBinCode + '</div>');
                win.document.write('<div class="loc">' + curBinLoc + '</div>');
                win.document.write('<div class="zone">ID: #' + curBinId + '</div>');
                win.document.write('<div class="brand">SMARTWASTE &bull; FPT CAMPUS IOT</div>');
                win.document.write('</div></body></html>');
                win.document.close();
                win.focus();
                setTimeout(function() { win.print(); win.close(); }, 600);
            }

            // Real-time Waste Bin List Polling (every 4 seconds)
            function pollWasteBinTable() {
                fetch('<%=ctx%>/api/bins-location?t=' + Date.now())
                    .then(function(res) {
                        if (!res.ok) throw new Error('Status ' + res.status);
                        return res.json();
                    })
                    .then(function(liveBins) {
                        if (!Array.isArray(liveBins)) return;

                        var anyUpdated = false;
                        liveBins.forEach(function(b) {
                            var row = document.getElementById('bin-row-' + b.binID);
                            if (row) {
                                var fill = Math.round(b.currentFill);
                                var fillCell = row.querySelector('.fill-cell');
                                var statusCell = row.querySelector('.status-badge');

                                var currentFillText = fillCell ? fillCell.querySelector('strong') : null;
                                var prevFillVal = currentFillText ? parseInt(currentFillText.innerText) : -1;

                                if (prevFillVal !== -1 && prevFillVal !== fill) {
                                    anyUpdated = true;
                                    var fillClass = fill >= 80 ? 'fill-red' : (fill >= 60 ? 'fill-yellow' : 'fill-green');
                                    var fillLabel = fill >= 80 ? 'High' : (fill >= 60 ? 'Medium' : 'Low');

                                    fillCell.innerHTML = '<div class="fill-info">' +
                                        '<strong class="' + fillClass + '">' + fill + '%</strong>' +
                                        '<span class="' + fillClass + '">' + fillLabel + '</span>' +
                                        '</div>' +
                                        '<div class="fill-bar">' +
                                        '<div class="fill-progress ' + fillClass + '" style="width: ' + Math.min(fill, 100) + '%; transition: width 0.5s ease;"></div>' +
                                        '</div>';

                                    if (statusCell && b.status) {
                                        var stClass = 'status-' + b.status.toLowerCase().replace(/ /g, '_');
                                        statusCell.className = 'status-badge ' + stClass;
                                        statusCell.innerHTML = '<span class="status-dot"></span> ' + b.status;
                                    }

                                    // Subtle row highlight flash
                                    row.style.backgroundColor = '#DCFCE7';
                                    setTimeout(function() {
                                        row.style.backgroundColor = '';
                                    }, 1200);
                                }
                            }
                        });

                        if (anyUpdated) {
                            var pill = document.getElementById('binListLivePill');
                            if (pill) {
                                pill.style.background = '#BBF7D0';
                                setTimeout(function() { pill.style.background = '#DCFCE7'; }, 800);
                            }
                        }
                    })
                    .catch(function(err) {});
            }

            setInterval(pollWasteBinTable, 4000);
        </script>
    </body>
</html>