<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Maintenance"%>
<%@page import="model.AppUser"%>

<%
    List<Maintenance> list
            = (List<Maintenance>) request.getAttribute("LIST_MAINTENANCE");

    String error
            = (String) request.getAttribute("ERROR");

    AppUser currentUser
            = (AppUser) session.getAttribute("user");

    String role
            = currentUser != null
                    ? currentUser.getRoleId()
                    : "";

    boolean canCreate
            = "ADM".equals(role)
            || "MGR".equals(role)
            || "SUP".equals(role)
            || "SAD".equals(role)
            || "TEC".equals(role)
            || "STF".equals(role);

    boolean canDelete
            = "ADM".equals(role)
            || "MGR".equals(role)
            || "SAD".equals(role);

    boolean canEdit
            = "ADM".equals(role)
            || "MGR".equals(role)
            || "TEC".equals(role)
            || "SUP".equals(role)
            || "SAD".equals(role);

    boolean canSearchTechnician
            = "ADM".equals(role)
            || "MGR".equals(role);

    boolean canSearchAdvanced
            = "ADM".equals(role)
            || "MGR".equals(role);

    String searchId
            = (String) request.getAttribute("SEARCH_ID");

    String technicianID
            = (String) request.getAttribute("TECHNICIAN_ID");

    String maintenanceType
            = (String) request.getAttribute("MAINTENANCE_TYPE");

    String status
            = (String) request.getAttribute("STATUS");

    String sortBy
            = (String) request.getAttribute("SORT_BY");

    String order
            = (String) request.getAttribute("ORDER");

    if (searchId == null) {
        searchId = request.getParameter("searchId");
    }

    if (technicianID == null) {
        technicianID = request.getParameter("technicianID");
    }

    if (maintenanceType == null) {
        maintenanceType = request.getParameter("maintenanceType");
    }

    if (status == null) {
        status = request.getParameter("status");
    }

    if (sortBy == null || sortBy.trim().isEmpty()) {
        sortBy = "scheduledDate";
    }

    if (order == null || order.trim().isEmpty()) {
        order = "DESC";
    }

    if (searchId == null) {
        searchId = "";
    }

    if (technicianID == null) {
        technicianID = "";
    }

    if (maintenanceType == null) {
        maintenanceType = "";
    }

    if (status == null) {
        status = "";
    }

    int currentPage = 1;
    int totalPages = 1;
    int totalRecords = list == null ? 0 : list.size();
    int pageSize = 10;

    Object cp = request.getAttribute("CURRENT_PAGE");
    Object tp = request.getAttribute("TOTAL_PAGES");
    Object tr = request.getAttribute("TOTAL_RECORDS");
    Object ps = request.getAttribute("PAGE_SIZE");

    if (cp instanceof Number) {
        currentPage = ((Number) cp).intValue();
    }

    if (tp instanceof Number) {
        totalPages = ((Number) tp).intValue();
    }

    if (tr instanceof Number) {
        totalRecords = ((Number) tr).intValue();
    }

    if (ps instanceof Number) {
        pageSize = ((Number) ps).intValue();
    }
%>

<!DOCTYPE html>
<html lang="en">

    <head>

        <meta charset="UTF-8">

        <meta
            name="viewport"
            content="width=device-width, initial-scale=1.0">

        <title>Maintenance Management</title>

        <link
            rel="stylesheet"
            href="<%=request.getContextPath()%>/css/style.css?v=20261017-v4">

        <style>

            .maintenance-page {
                margin-left: 0;
                width: 100%;
                min-height: 100vh;
                padding: 34px 38px;
                box-sizing: border-box;
            }

            .maintenance-header {
                width: 100%;
                display: flex;
                justify-content: space-between;
                align-items: flex-start;
                gap: 20px;
                margin-bottom: 24px;
            }

            .page-kicker {
                display: block;
                margin-bottom: 7px;
                color: var(--green);
                font-size: 11px;
                font-weight: 800;
                letter-spacing: 1.4px;
                text-transform: uppercase;
            }

            .page-title {
                margin: 0;
                color: var(--navy);
                font-size: 30px;
                font-weight: 800;
                letter-spacing: -0.7px;
            }

            .page-description {
                margin: 8px 0 0;
                color: var(--muted);
                font-size: 14px;
            }

            .header-actions {
                display: flex;
                gap: 9px;
                flex-wrap: wrap;
            }

            .maintenance-btn {
                min-height: 42px;
                padding: 0 17px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                gap: 7px;
                border: 0;
                border-radius: 11px;
                cursor: pointer;
                font-family: inherit;
                font-size: 13px;
                font-weight: 700;
                text-decoration: none;
                transition: 0.2s ease;
                box-sizing: border-box;
            }

            .maintenance-btn-primary {
                color: var(--white);
                background: var(--green);
                box-shadow: 0 8px 18px rgba(32, 164, 90, 0.18);
            }

            .maintenance-btn-primary:hover {
                background: var(--green-dark);
            }

            .maintenance-btn-light {
                color: var(--text);
                background: var(--white);
                border: 1px solid var(--border);
            }

            .maintenance-btn-light:hover {
                border-color: var(--green);
                color: var(--green-dark);
            }

            .filter-panel {
                width: 100%;
                margin-bottom: 22px;
                padding: 22px;
                border: 1px solid var(--border);
                border-radius: var(--radius);
                background: var(--white);
                box-shadow: var(--shadow);
                box-sizing: border-box;
            }

            .filter-header {
                display: flex;
                align-items: center;
                justify-content: space-between;
                margin-bottom: 17px;
            }

            .filter-title {
                margin: 0;
                color: var(--navy);
                font-size: 16px;
                font-weight: 800;
            }

            .filter-subtitle {
                margin: 4px 0 0;
                color: var(--muted);
                font-size: 12px;
            }

            .filter-grid {
                width: 100%;
                display: grid;
                grid-template-columns:
                    minmax(200px, 1.3fr)
                    minmax(170px, 1fr)
                    minmax(170px, 1fr)
                    minmax(150px, 1fr)
                    minmax(140px, 0.8fr)
                    auto;
                gap: 12px;
                align-items: end;
            }

            .filter-field {
                display: flex;
                flex-direction: column;
                gap: 7px;
                min-width: 0;
            }

            .filter-label {
                color: var(--text);
                font-size: 12px;
                font-weight: 700;
            }

            .filter-input,
            .filter-select {
                width: 100%;
                height: 42px;
                padding: 0 12px;
                border: 1px solid var(--border);
                border-radius: 10px;
                outline: none;
                color: var(--text);
                background: var(--white);
                font-family: inherit;
                font-size: 13px;
                box-sizing: border-box;
            }

            .filter-input:focus,
            .filter-select:focus {
                border-color: var(--green);
                box-shadow: 0 0 0 3px var(--green-soft);
            }

            .filter-actions {
                display: flex;
                gap: 8px;
                flex-wrap: wrap;
            }

            .table-panel {
                width: 100%;
                overflow: hidden;
                border: 1px solid var(--border);
                border-radius: var(--radius);
                background: var(--white);
                box-shadow: var(--shadow);
                box-sizing: border-box;
            }

            .table-header {
                width: 100%;
                padding: 19px 22px;
                display: flex;
                align-items: center;
                justify-content: space-between;
                border-bottom: 1px solid var(--border);
                box-sizing: border-box;
            }

            .table-title {
                margin: 0;
                color: var(--navy);
                font-size: 16px;
                font-weight: 800;
            }

            .record-count {
                padding: 6px 10px;
                border-radius: 999px;
                color: var(--green-dark);
                background: var(--green-pale);
                font-size: 12px;
                font-weight: 700;
            }

            .maintenance-table-wrapper {
                width: 100%;
                overflow-x: auto;
            }

            .maintenance-table {
                width: 100%;
                min-width: 1050px;
                border-collapse: collapse;
            }

            .maintenance-table th {
                padding: 14px 18px;
                text-align: left;
                color: var(--muted);
                background: var(--green-pale);
                border-bottom: 1px solid var(--border);
                font-size: 11px;
                font-weight: 800;
                letter-spacing: 0.5px;
                text-transform: uppercase;
                white-space: nowrap;
            }

            .maintenance-table td {
                padding: 15px 18px;
                border-bottom: 1px solid var(--border);
                color: var(--text);
                font-size: 13px;
                vertical-align: middle;
            }

            .maintenance-table tbody tr:hover {
                background: var(--green-pale);
            }

            .maintenance-table tbody tr:last-child td {
                border-bottom: 0;
            }

            .maintenance-id {
                color: var(--green-dark);
                font-weight: 800;
            }

            .bin-id {
                font-weight: 700;
            }

            .technician-id {
                color: var(--muted);
                font-weight: 600;
            }

            .maintenance-type {
                font-weight: 600;
            }

            .status-badge {
                display: inline-flex;
                align-items: center;
                padding: 6px 10px;
                border-radius: 999px;
                font-size: 11px;
                font-weight: 800;
                white-space: nowrap;
            }

            .status-pending {
                color: #a66a00;
                background: #fff5dc;
            }

            .status-progress {
                color: #2463a6;
                background: #edf5ff;
            }

            .status-completed {
                color: #18794e;
                background: var(--green-soft);
            }

            .status-cancelled {
                color: #b42318;
                background: #fff0f0;
            }

            .scheduled-date,
            .completed-date {
                color: var(--muted);
                white-space: nowrap;
            }

            .action-cell {
                white-space: nowrap;
            }

            .action-link {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                min-height: 34px;
                padding: 0 11px;
                margin-right: 5px;
                gap: 5px;
                border-radius: 9px;
                border: 1px solid var(--border);
                background: var(--white);
                color: var(--text);
                font-size: 11px;
                font-weight: 700;
                text-decoration: none;
                cursor: pointer;
                font-family: inherit;
                box-sizing: border-box;
            }

            .action-link:hover {
                border-color: var(--green);
                color: var(--green-dark);
            }

            .action-edit {
                border-color: var(--green);
                color: var(--green-dark);
            }

            .action-delete {
                border-color: #f0d4d4;
                color: #c84b4b;
                background: #fff8f8;
            }

            .action-delete:hover {
                border-color: #c84b4b;
                color: #a83232;
            }

            .action-form {
                display: inline;
                margin: 0;
            }

            .empty-state {
                padding: 55px 20px !important;
                text-align: center;
                color: var(--muted) !important;
            }

            .empty-icon {
                width: 52px;
                height: 52px;
                margin: 0 auto 12px;
                display: grid;
                place-items: center;
                border-radius: 15px;
                color: var(--green);
                background: var(--green-pale);
                font-size: 22px;
                font-weight: 800;
            }

            .empty-title {
                display: block;
                margin-bottom: 4px;
                color: var(--navy);
                font-size: 14px;
                font-weight: 800;
            }

            .error-box {
                margin-bottom: 20px;
                padding: 13px 16px;
                border: 1px solid #f1d2d2;
                border-radius: 12px;
                color: #a83232;
                background: #fff8f8;
                font-size: 13px;
                font-weight: 600;
            }

            @media (max-width: 1400px) {
                .filter-grid {
                    grid-template-columns:
                        1fr
                        1fr
                        1fr;
                }

                .filter-actions {
                    grid-column: 1 / -1;
                }
            }

            @media (max-width: 900px) {
                .maintenance-page {
                    margin-left: 0;
                    width: 100%;
                    padding: 28px 24px;
                }

                .maintenance-header {
                    flex-direction: column;
                }

                .header-actions {
                    width: 100%;
                }
            }

            @media (max-width: 800px) {
                .maintenance-page {
                    margin-left: 0;
                    width: 100%;
                    padding: 25px 18px;
                }

                .filter-grid {
                    grid-template-columns: 1fr;
                }

                .filter-actions {
                    grid-column: auto;
                }
            }

            @media (max-width: 600px) {
                .maintenance-page {
                    padding: 20px 14px;
                }

                .page-title {
                    font-size: 25px;
                }

                .filter-panel {
                    padding: 17px;
                }

                .table-header {
                    padding: 16px;
                }

                .maintenance-table th,
                .maintenance-table td {
                    padding-left: 13px;
                    padding-right: 13px;
                }
            }

        </style>

    </head>

    <body>

        <div class="app-shell">

            <!-- SIDEBAR DUNG CHUNG -->
            <jsp:include page="sidebar.jsp" />

            <main class="maintenance-page">

                <section class="maintenance-header">

                    <div style="display: flex; align-items: center;">

                        <button type="button" class="desktop-nav-toggle" onclick="toggleSidebarCollapse()" title="Toggle Sidebar (Expand / Collapse)">
                            <i class="fa-solid fa-bars"></i>
                        </button>

                        <div>
                            <span class="page-kicker">
                                MAINTENANCE
                            </span>

                            <h1 class="page-title">
                                Maintenance Management
                            </h1>
                        </div>

                    </div>

                    <div class="header-actions">

                        <% if (canCreate) {%>

                        <a
                            class="maintenance-btn maintenance-btn-primary"
                            href="<%=request.getContextPath()%>/maintenance/create">

                            <i class="fa-solid fa-plus"></i>
                            Create Maintenance

                        </a>

                        <% }%>

                        <a
                            class="maintenance-btn maintenance-btn-light"
                            href="<%=request.getContextPath()%>/dashboard">

                            <i class="fa-solid fa-house"></i>
                            Dashboard

                        </a>

                    </div>

                </section>

                <% if ("TEC".equals(role)) { 
                    Double fixRate = (Double) request.getAttribute("FIX_SUCCESS_RATE");
                    Double mttr = (Double) request.getAttribute("MTTR_HOURS");
                %>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 16px; margin-bottom: 22px;">
                    <div style="background: white; border: 1px solid #e2e8f0; border-radius: 12px; padding: 18px; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                        <div style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase;">Fix Success Rate</div>
                        <div style="font-size: 24px; font-weight: 800; color: #16a34a; margin-top: 4px;">
                            <i class="fa-solid fa-circle-check"></i> <%= fixRate != null ? fixRate : 100.0 %>%
                        </div>
                        <div style="font-size: 11px; color: #94a3b8; margin-top: 2px;">Completed vs assigned tickets</div>
                    </div>
                    <div style="background: white; border: 1px solid #e2e8f0; border-radius: 12px; padding: 18px; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                        <div style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase;">MTTR (Mean Time to Repair)</div>
                        <div style="font-size: 24px; font-weight: 800; color: #0284c7; margin-top: 4px;">
                            <i class="fa-solid fa-clock-rotate-left"></i> <%= mttr != null ? mttr : 1.5 %> hrs
                        </div>
                        <div style="font-size: 11px; color: #94a3b8; margin-top: 2px;">Avg turnaround from schedule to completion</div>
                    </div>
                    <div style="background: white; border: 1px solid #e2e8f0; border-radius: 12px; padding: 18px; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                        <div style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase;">Assigned Work Queue</div>
                        <div style="font-size: 24px; font-weight: 800; color: #8b5cf6; margin-top: 4px;">
                            <i class="fa-solid fa-screwdriver-wrench"></i> <%= list != null ? list.size() : 0 %>
                        </div>
                        <div style="font-size: 11px; color: #94a3b8; margin-top: 2px;">Campus hardware tickets in scope</div>
                    </div>
                </div>
                <% } %>

                <% if (error != null
                            && !error.trim().isEmpty()) {%>

                <div class="error-box">

                    <i class="fa-solid fa-circle-exclamation"></i>
                    <%=error%>

                </div>

                <% }%>

                <section class="filter-panel">

                    <div class="filter-header">

                        <div>

                            <h2 class="filter-title">
                                Filter &amp; Search
                            </h2>

                            <p class="filter-subtitle">
                                Search and arrange maintenance records.
                            </p>

                        </div>

                    </div>

                    <form
                        method="GET"
                        action="<%=request.getContextPath()%>/maintenance">

                        <div class="filter-grid">

                            <div class="filter-field">

                                <label
                                    class="filter-label"
                                    for="searchId">
                                    Search ID
                                </label>

                                <input
                                    class="filter-input"
                                    type="text"
                                    id="searchId"
                                    name="searchId"
                                    value="<%=searchId%>"
                                    placeholder="Maintenance ID or Bin ID">

                            </div>

                            <% if (canSearchTechnician) {%>

                            <div class="filter-field">

                                <label
                                    class="filter-label"
                                    for="technicianID">
                                    Technician ID
                                </label>

                                <input
                                    class="filter-input"
                                    type="text"
                                    id="technicianID"
                                    name="technicianID"
                                    value="<%=technicianID%>"
                                    placeholder="Enter Technician ID">

                            </div>

                            <div class="filter-field">

                                <label
                                    class="filter-label"
                                    for="maintenanceType">
                                    Maintenance Type
                                </label>

                                <select
                                    class="filter-select"
                                    id="maintenanceType"
                                    name="maintenanceType">

                                    <option value="">
                                        All Types
                                    </option>

                                    <option
                                        value="Repair"
                                        <%= "Repair".equals(maintenanceType)
                                                ? "selected" : ""%>>
                                        Repair
                                    </option>

                                    <option
                                        value="Inspection"
                                        <%= "Inspection".equals(maintenanceType)
                                                ? "selected" : ""%>>
                                        Inspection
                                    </option>

                                    <option
                                        value="Replacement"
                                        <%= "Replacement".equals(maintenanceType)
                                                ? "selected" : ""%>>
                                        Replacement
                                    </option>

                                    <option
                                        value="Sensor_Check"
                                        <%= "Sensor_Check".equals(maintenanceType)
                                                ? "selected" : ""%>>
                                        Sensor Check
                                    </option>

                                    <option
                                        value="Calibration"
                                        <%= "Calibration".equals(maintenanceType)
                                                ? "selected" : ""%>>
                                        Calibration
                                    </option>

                                </select>

                            </div>

                            <div class="filter-field">

                                <label
                                    class="filter-label"
                                    for="status">
                                    Status
                                </label>

                                <select
                                    class="filter-select"
                                    id="status"
                                    name="status">

                                    <option value="">
                                        All Status
                                    </option>

                                    <option
                                        value="Pending"
                                        <%= "Pending".equals(status)
                                                ? "selected" : ""%>>
                                        Pending
                                    </option>

                                    <option
                                        value="In_Progress"
                                        <%= "In_Progress".equals(status)
                                                ? "selected" : ""%>>
                                        In Progress
                                    </option>

                                    <option
                                        value="Completed"
                                        <%= "Completed".equals(status)
                                                ? "selected" : ""%>>
                                        Completed
                                    </option>

                                    <option
                                        value="Cancelled"
                                        <%= "Cancelled".equals(status)
                                                ? "selected" : ""%>>
                                        Cancelled
                                    </option>

                                </select>

                            </div>

                            <% }%>

                            <div class="filter-field">

                                <label
                                    class="filter-label"
                                    for="sortBy">
                                    Sort By
                                </label>

                                <select
                                    class="filter-select"
                                    id="sortBy"
                                    name="sortBy">

                                    <option
                                        value="status"
                                        <%= "status".equals(sortBy)
                                                ? "selected" : ""%>>
                                        Status
                                    </option>

                                    <option
                                        value="maintenanceType"
                                        <%= "maintenanceType".equals(sortBy)
                                                ? "selected" : ""%>>
                                        Maintenance Type
                                    </option>

                                    <option
                                        value="scheduledDate"
                                        <%= "scheduledDate".equals(sortBy)
                                                ? "selected" : ""%>>
                                        Scheduled Date
                                    </option>

                                    <option
                                        value="completedDate"
                                        <%= "completedDate".equals(sortBy)
                                                ? "selected" : ""%>>
                                        Completed Date
                                    </option>

                                </select>

                            </div>

                            <div class="filter-field">

                                <label
                                    class="filter-label"
                                    for="order">
                                    Order
                                </label>

                                <select
                                    class="filter-select"
                                    id="order"
                                    name="order">

                                    <option
                                        value="ASC"
                                        <%= "ASC".equalsIgnoreCase(order)
                                                ? "selected" : ""%>>
                                        ASC
                                    </option>

                                    <option
                                        value="DESC"
                                        <%= "DESC".equalsIgnoreCase(order)
                                                ? "selected" : ""%>>
                                        DESC
                                    </option>

                                </select>

                            </div>

                            <div class="filter-actions">

                                <button
                                    type="submit"
                                    class="maintenance-btn maintenance-btn-primary">

                                    <i class="fa-solid fa-filter"></i>
                                    Apply Filter

                                </button>

                                <a
                                    href="<%=request.getContextPath()%>/maintenance"
                                    class="maintenance-btn maintenance-btn-light">

                                    <i class="fa-solid fa-rotate-left"></i>
                                    Reset

                                </a>

                            </div>

                        </div>

                    </form>

                </section>

                <section class="table-panel">

                    <div class="table-header">

                        <h2 class="table-title">
                            Maintenance Records
                        </h2>

                        <span class="record-count">
                            <%=totalRecords%> records
                        </span>

                    </div>

                    <div class="maintenance-table-wrapper">

                        <table class="maintenance-table">

                            <thead>

                                <tr>
                                    <th>Maintenance ID</th>
                                    <th>Bin ID</th>
                                    <th>Technician</th>
                                    <th>Type</th>
                                    <th>Status</th>
                                    <th>Scheduled Date</th>
                                    <th>Completed Date</th>
                                    <th>Action</th>
                                </tr>

                            </thead>

                            <tbody>

                                <% if (list != null && !list.isEmpty()) { %>

                                <% for (Maintenance item : list) { %>

                                <%
                                    String statusClass = "status-pending";

                                    if ("In_Progress".equals(item.getStatus())) {
                                        statusClass = "status-progress";
                                    } else if ("Completed".equals(item.getStatus())) {
                                        statusClass = "status-completed";
                                    } else if ("Cancelled".equals(item.getStatus())) {
                                        statusClass = "status-cancelled";
                                    }
                                %>

                                <tr>

                                    <td>
                                        <span class="maintenance-id">
                                            <%=item.getMaintenanceID()%>
                                        </span>
                                    </td>

                                    <td>
                                        <div style="display: flex; flex-direction: column; gap: 2px;">
                                            <a href="<%=request.getContextPath()%>/wastebin/detail?id=<%=item.getBinID()%>" style="font-weight: 700; color: #166534; text-decoration: none; display: inline-flex; align-items: center; gap: 5px;">
                                                <i class="fa-solid fa-trash-can" style="font-size: 11px; color: #059669;"></i>
                                                <%= item.getBinCode() != null && !item.getBinCode().trim().isEmpty() ? item.getBinCode() : item.getBinID() %>
                                            </a>
                                            <span style="font-size: 11px; color: #64748B;">
                                                <%= item.getLocation() != null && !item.getLocation().trim().isEmpty() ? item.getLocation() : ("ID: " + item.getBinID()) %>
                                            </span>
                                        </div>
                                    </td>

                                    <td>
                                        <div style="display: flex; flex-direction: column; gap: 2px;">
                                            <span style="font-weight: 600; color: #0F172A;">
                                                <%= item.getTechnicianName() != null && !item.getTechnicianName().trim().isEmpty() ? item.getTechnicianName() : (item.getTechnicianID() != null && !item.getTechnicianID().trim().isEmpty() ? item.getTechnicianID() : "Unassigned") %>
                                            </span>
                                            <% if (item.getTechnicianID() != null && !item.getTechnicianID().trim().isEmpty()) { %>
                                            <span style="font-size: 10px; color: #64748B; font-family: monospace;">
                                                ID: <%= item.getTechnicianID() %>
                                            </span>
                                            <% } %>
                                        </div>
                                    </td>

                                    <td>
                                        <span class="maintenance-type">
                                            <%=item.getMaintenanceType() == null
                                                            ? "" : item.getMaintenanceType()%>
                                        </span>
                                    </td>

                                    <td>
                                        <span class="status-badge <%=statusClass%>">
                                            <%=item.getStatus()%>
                                        </span>
                                    </td>

                                    <td>
                                        <span class="scheduled-date">
                                            <%=item.getScheduledDate() == null
                                                            ? "" : item.getScheduledDate()%>
                                        </span>
                                    </td>

                                    <td>
                                        <span class="completed-date">
                                            <%=item.getCompletedDate() == null
                                                            ? "" : item.getCompletedDate()%>
                                        </span>
                                    </td>

                                    <td class="action-cell">

                                        <a
                                            class="action-link"
                                            href="<%=request.getContextPath()%>/maintenance/view?id=<%=item.getMaintenanceID()%>">

                                            <i class="fa-solid fa-eye"></i>
                                            View

                                        </a>

                                        <% if (canEdit
                                                    && ("SAD".equals(role)
                                                    || "ADM".equals(role)
                                                    || "MGR".equals(role)
                                                    || "SUP".equals(role)
                                                    || ("TEC".equals(role)
                                                            && currentUser != null
                                                            && currentUser.getUserId().equals(
                                                                    item.getTechnicianID())))) {%>

                                        <a
                                            class="action-link action-edit"
                                            href="<%=request.getContextPath()%>/maintenance/edit?id=<%=item.getMaintenanceID()%>">

                                            <i class="fa-solid fa-pen"></i>
                                            Edit

                                        </a>

                                        <% } %>

                                        <% if (canDelete) {%>

                                        <form
                                            class="action-form"
                                            action="<%=request.getContextPath()%>/maintenance/delete"
                                            method="POST"
                                            onsubmit="return confirm('Are you sure you want to delete this maintenance?');">

                                            <input
                                                type="hidden"
                                                name="id"
                                                value="<%=item.getMaintenanceID()%>">

                                            <button
                                                type="submit"
                                                class="action-link action-delete">

                                                <i class="fa-solid fa-trash-can"></i>
                                                Delete

                                            </button>

                                        </form>

                                        <% } %>

                                    </td>

                                </tr>

                                <% } %>

                                <% } else { %>

                                <tr>

                                    <td colspan="8" class="empty-state">

                                        <div class="empty-icon">
                                            <i class="fa-solid fa-wrench"></i>
                                        </div>

                                        <span class="empty-title">
                                            No maintenance records found
                                        </span>

                                        Try changing your search or filter.

                                    </td>

                                </tr>

                                <% } %>

                            </tbody>

                        </table>

                    </div>

                    <!-- Phan trang dung chung -->
                    <%
                        request.setAttribute(
                                "PAGINATION_BASE_URL",
                                request.getContextPath() + "/maintenance");

                        request.setAttribute(
                                "PAGINATION_CURRENT_PAGE",
                                currentPage);

                        request.setAttribute(
                                "PAGINATION_TOTAL_PAGES",
                                totalPages);

                        request.setAttribute(
                                "PAGINATION_TOTAL_RECORDS",
                                totalRecords);

                        request.setAttribute(
                                "PAGINATION_PAGE_SIZE",
                                pageSize);
                    %>

                    <jsp:include page="/WEB-INF/views/common/pagination.jsp" />

                </section>

            </main>

        </div>

    </body>

</html>