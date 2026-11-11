<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Alert"%>
<%@page import="model.AppUser"%>

<%
    List<Alert> list = (List<Alert>) request.getAttribute("LIST_ALERT");
    String error = (String) request.getAttribute("ERROR");

    String searchId = (String) request.getAttribute("SEARCH_ID");
    String alertType = (String) request.getAttribute("ALERT_TYPE");
    String status = (String) request.getAttribute("STATUS");
    String sortBy = (String) request.getAttribute("SORT_BY");
    String order = (String) request.getAttribute("ORDER");

    if (searchId == null) {
        searchId = request.getParameter("searchId") == null
                ? "" : request.getParameter("searchId");
    }

    if (alertType == null) {
        alertType = request.getParameter("alertType") == null
                ? "" : request.getParameter("alertType");
    }

    if (status == null || status.isEmpty()) {
        status = request.getParameter("status") == null
                ? "all" : request.getParameter("status");
    }

    if (sortBy == null || sortBy.isEmpty()) {
        sortBy = request.getParameter("sortBy") == null
                ? "createdDate" : request.getParameter("sortBy");
    }

    if (order == null || order.isEmpty()) {
        order = request.getParameter("order") == null
                ? "DESC" : request.getParameter("order");
    }

    // Normalize filter values
    if ("resolved".equalsIgnoreCase(status)) {
        status = "Resolved";
    } else if ("unresolved".equalsIgnoreCase(status)) {
        status = "Unresolved";
    } else if (status == null || status.trim().isEmpty()
            || "all".equalsIgnoreCase(status)) {
        status = "all";
    }

    AppUser currentUser = (AppUser) session.getAttribute("user");

    String role = currentUser != null && currentUser.getRoleId() != null
            ? currentUser.getRoleId().trim().toUpperCase() : "";

    boolean canDelete = "ADM".equals(role) || "MGR".equals(role) || "SAD".equals(role);
    boolean canCreate = canDelete || "SUP".equals(role);
    boolean canEdit = canCreate;
    boolean canResolve = canCreate;
    boolean canDispatchCollection = canCreate;
    boolean canRequestMaintenance = canCreate || "STF".equals(role) || "TEC".equals(role);

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

    // Escape data before displaying it in HTML
    String contextPath = request.getContextPath();
%>

<%!
    public String escapeHtml(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <title>Alert Management | SmartWaste</title>

        <link rel="stylesheet"
              href="<%=contextPath%>/css/style.css?v=20261017-v4">

        <style>
            /* ==============================
               ALERT PAGE - GENERAL
            ============================== */

            .alert-page {
                min-height: 100vh;
                background: var(--page, #f7faf8);
                color: var(--text, #1c2d26);
            }

            .alert-page .main-content {
                min-width: 0;
                box-sizing: border-box;
            }

            .alert-page .page-intro {
                display: flex;
                align-items: flex-end;
                justify-content: space-between;
                gap: 20px;
                flex-wrap: wrap;
                margin-bottom: 22px;
            }

            .alert-page .section-kicker {
                color: var(--green-dark, #123f2b);
                font-size: 10px;
                font-weight: 800;
                letter-spacing: 1.3px;
            }

            .alert-page .page-intro h2 {
                margin: 7px 0;
                color: var(--text, #1c2d26);
                font-size: 27px;
            }

            .alert-page .page-intro p {
                margin: 0;
                color: var(--muted, #718079);
                font-size: 13px;
                line-height: 1.6;
            }

            .alert-page .page-actions {
                display: flex;
                align-items: center;
                gap: 8px;
                flex-wrap: wrap;
            }

            /* ==============================
               BUTTONS
            ============================== */

            .alert-page .btn {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                gap: 6px;
                min-height: 40px;
                padding: 0 14px;
                border: 1px solid transparent;
                border-radius: 10px;
                font-size: 12px;
                font-weight: 800;
                text-decoration: none;
                cursor: pointer;
                box-sizing: border-box;
                transition: background .2s ease, border-color .2s ease;
            }

            .alert-page .btn-primary {
                background: var(--green, #20a45a);
                color: var(--white, #fff);
            }

            .alert-page .btn-primary:hover {
                background: var(--green-dark, #123f2b);
            }

            .alert-page .btn-light {
                background: var(--white, #fff);
                border-color: var(--border, #e5eee9);
                color: var(--text, #1c2d26);
            }

            .alert-page .btn-light:hover {
                background: var(--green-pale, #f2fbf6);
                border-color: var(--green, #20a45a);
            }

            /* ==============================
               PANELS
            ============================== */

            .alert-page .panel {
                min-width: 0;
                box-sizing: border-box;
                padding: 22px;
                background: var(--white, #fff);
                border: 1px solid var(--border, #e5eee9);
                border-radius: var(--radius, 18px);
                box-shadow: var(--shadow, 0 12px 35px rgba(26,74,51,.08));
            }

            .alert-page .panel-header {
                display: flex;
                align-items: center;
                justify-content: space-between;
                gap: 16px;
                flex-wrap: wrap;
            }

            .alert-page .panel-kicker {
                color: var(--muted, #718079);
                font-size: 10px;
                font-weight: 800;
                letter-spacing: 1.3px;
            }

            .alert-page .panel-header h3 {
                margin: 5px 0 0;
                color: var(--text, #1c2d26);
                font-size: 20px;
            }

            .alert-page .record-count {
                color: var(--muted, #718079);
                font-size: 12px;
                font-weight: 700;
            }

            /* ==============================
               FILTER FORM
            ============================== */

            .alert-page .filter-grid {
                display: flex;
                align-items: flex-end;
                gap: 12px;
                flex-wrap: wrap;
                width: 100%;
                margin-top: 18px;
            }

            .alert-page .filter-field {
                display: flex;
                flex-direction: column;
                gap: 6px;
                min-width: 0;
            }

            .alert-page .filter-field label {
                color: var(--muted, #718079);
                font-size: 11px;
                font-weight: 700;
            }

            .alert-page .filter-field input,
            .alert-page .filter-field select {
                box-sizing: border-box;
                min-height: 42px;
                min-width: 145px;
                padding: 0 12px;
                border: 1px solid var(--border, #e5eee9);
                border-radius: 11px;
                outline: none;
                background: var(--white, #fff);
                color: var(--text, #1c2d26);
                font-family: inherit;
                font-size: 12px;
                transition: border-color .2s ease, box-shadow .2s ease;
            }

            .alert-page .filter-field input {
                min-width: 220px;
            }

            .alert-page .filter-field input:focus,
            .alert-page .filter-field select:focus {
                border-color: var(--green, #20a45a);
                box-shadow: 0 0 0 3px rgba(32, 164, 90, .10);
            }

            .alert-page .filter-grid > .page-actions {
                align-self: flex-end;
            }

            /* ==============================
               ERROR MESSAGE
            ============================== */

            .alert-page .alert-error {
                display: flex;
                align-items: center;
                gap: 10px;
                margin: 0 0 18px;
                padding: 13px 15px;
                border: 1px solid #fecaca;
                border-radius: 12px;
                background: #fef2f2;
                color: #b91c1c;
                font-size: 13px;
                overflow-wrap: anywhere;
            }

            .alert-page .error-icon {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                flex: 0 0 22px;
                width: 22px;
                height: 22px;
                border-radius: 50%;
                background: #fee2e2;
                font-weight: 800;
            }

            /* ==============================
               ALERT TABLE
            ============================== */

            .alert-page .alert-table-wrapper {
                width: 100%;
                max-width: 100%;
                overflow-x: auto;
                margin-top: 18px;
            }

            .alert-page .alert-table {
                width: 100%;
                min-width: 900px;
                border-collapse: collapse;
            }

            .alert-page .alert-table th {
                padding: 14px 12px;
                text-align: left;
                color: var(--muted, #718079);
                font-size: 10px;
                font-weight: 800;
                letter-spacing: .8px;
                text-transform: uppercase;
                white-space: nowrap;
                background: var(--green-pale, #f2fbf6);
                border-bottom: 1px solid var(--border, #e5eee9);
            }

            .alert-page .alert-table td {
                padding: 15px 12px;
                vertical-align: middle;
                border-bottom: 1px solid var(--border, #e5eee9);
                color: var(--text, #1c2d26);
                font-size: 12px;
            }

            .alert-page .alert-table tbody tr {
                transition: background .15s ease;
            }

            .alert-page .alert-table tbody tr:hover {
                background: var(--green-pale, #f2fbf6);
            }

            .alert-page .alert-table tbody tr:last-child td {
                border-bottom: none;
            }

            .alert-page .id-pill {
                display: inline-block;
                padding: 6px 9px;
                border-radius: 8px;
                background: var(--green-soft, #e9f8ef);
                color: var(--green-dark, #123f2b);
                font-weight: 800;
                white-space: nowrap;
            }

            .alert-page .type-label {
                font-weight: 800;
                overflow-wrap: anywhere;
            }

            .alert-page .message-cell {
                min-width: 220px;
                max-width: 360px;
                color: var(--muted, #718079);
                line-height: 1.6;
                overflow-wrap: anywhere;
            }

            /* ==============================
               STATUS
            ============================== */

            .alert-page .status-pill {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                padding: 6px 10px;
                border-radius: 999px;
                font-size: 10px;
                font-weight: 800;
                white-space: nowrap;
            }

            .alert-page .status-open {
                color: #92400e;
                background: #fef3c7;
            }

            .alert-page .status-resolved {
                color: #047857;
                background: #d1fae5;
            }

            /* ==============================
               ACTION BUTTONS
            ============================== */

            .alert-page .action-group {
                display: flex;
                gap: 6px;
                align-items: center;
                flex-wrap: wrap;
                min-width: 150px;
            }

            .alert-page .action-btn {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                min-height: 30px;
                padding: 0 9px;
                border: 1px solid var(--border, #e5eee9);
                border-radius: 8px;
                background: var(--white, #fff);
                color: var(--text, #1c2d26);
                font-family: inherit;
                font-size: 11px;
                font-weight: 700;
                text-decoration: none;
                white-space: nowrap;
                cursor: pointer;
                transition: opacity .2s ease, background .2s ease;
            }

            .alert-page .action-btn:hover {
                opacity: .8;
            }

            .alert-page .action-view {
                color: #1d4ed8;
                border-color: #bfdbfe;
                background: #eff6ff;
            }

            .alert-page .action-edit {
                color: #6d28d9;
                border-color: #ddd6fe;
                background: #f5f3ff;
            }

            .alert-page .action-resolve {
                color: #047857;
                border-color: #a7f3d0;
                background: #ecfdf5;
            }

            .alert-page .action-delete {
                color: #b91c1c;
                border-color: #fecaca;
                background: #fef2f2;
            }

            .alert-page .action-group form {
                display: inline-flex;
                margin: 0;
            }

            /* ==============================
               EMPTY STATE
            ============================== */

            .alert-page .empty-state {
                display: flex;
                align-items: center;
                flex-direction: column;
                gap: 7px;
                padding: 35px 15px;
                color: var(--muted, #718079);
                text-align: center;
            }

            .alert-page .empty-state-icon {
                display: flex;
                align-items: center;
                justify-content: center;
                width: 48px;
                height: 48px;
                margin-bottom: 5px;
                border-radius: 15px;
                background: var(--green-soft, #e9f8ef);
                color: var(--green-dark, #123f2b);
                font-size: 24px;
                font-weight: 800;
            }

            .alert-page .empty-state strong {
                color: var(--text, #1c2d26);
                font-size: 14px;
            }

            .alert-page .empty-state span {
                font-size: 12px;
                line-height: 1.6;
            }

            /* ==============================
               FOOTER
            ============================== */

            .alert-page .footer {
                display: flex;
                justify-content: space-between;
                gap: 12px;
                flex-wrap: wrap;
                padding: 22px 2px;
                color: var(--muted, #718079);
                font-size: 11px;
            }

            /* ==============================
               RESPONSIVE
            ============================== */

            @media (max-width: 820px) {
                .alert-page .main-content {
                    min-width: 0;
                }

                .alert-page .page-intro {
                    align-items: flex-start;
                }

                .alert-page .panel {
                    padding: 18px;
                }
            }

            @media (max-width: 600px) {
                .alert-page .panel {
                    padding: 14px;
                }

                .alert-page .page-intro h2 {
                    font-size: 22px;
                }

                .alert-page .filter-grid {
                    flex-direction: column;
                    align-items: stretch;
                }

                .alert-page .filter-field,
                .alert-page .filter-field input,
                .alert-page .filter-field select {
                    width: 100%;
                    min-width: 0;
                }

                .alert-page .filter-grid > .page-actions {
                    width: 100%;
                }

                .alert-page .filter-grid > .page-actions .btn {
                    flex: 1;
                }

                .alert-page .page-intro > .page-actions {
                    width: 100%;
                }

                .alert-page .page-intro > .page-actions .btn {
                    flex: 1;
                }

                .alert-page .alert-table {
                    min-width: 900px;
                }

                .alert-page .footer {
                    flex-direction: column;
                    gap: 6px;
                }
            }
        </style>
    </head>

    <body>

        <div class="app-shell alert-page">

            <!-- SIDEBAR DUNG CHUNG -->
            <jsp:include page="sidebar.jsp" />

            <main class="main-content">

                <!-- TOPBAR -->
                <header class="topbar">
                    <div style="display: flex; align-items: center; gap: 14px;">
                        <button type="button" class="desktop-nav-toggle" onclick="toggleSidebarCollapse()" title="Toggle Sidebar (Expand / Collapse)">
                            <i class="fa-solid fa-bars"></i>
                        </button>
                        <div>
                            <div class="eyebrow">SMARTWASTE MANAGEMENT</div>
                            <h1>Alert Management</h1>
                        </div>
                    </div>

                    <div class="topbar-actions">
                        <div class="profile">
                            <div class="avatar">
                                <%=currentUser != null
                                        && currentUser.getFullName() != null
                                        && !currentUser.getFullName().isEmpty()
                                        ? escapeHtml(currentUser.getFullName()
                                                .substring(0, 1).toUpperCase())
                                        : "U"%>
                            </div>

                            <div class="profile-info">
                                <strong>
                                    <%=currentUser != null
                                            && currentUser.getFullName() != null
                                            ? escapeHtml(currentUser.getFullName())
                                            : ""%>
                                </strong>
                                <span><%=escapeHtml(role)%></span>
                            </div>
                        </div>
                    </div>
                </header>

                <!-- PAGE INTRO -->
                <section class="page-intro">
                    <div>
                        <span class="section-kicker">ALERT MONITORING</span>
                        <h2>Monitor and manage alerts</h2>
                        <p>
                            Search alerts, review their status, and manage unresolved issues.
                        </p>
                    </div>

                    <div class="page-actions">
                        <% if (canCreate) {%>
                        <a class="btn btn-primary"
                           href="<%=contextPath%>/alert/create">
                            + Create Alert
                        </a>
                        <% }%>

                        <a class="btn btn-light"
                           href="<%=contextPath%>/dashboard">
                            Dashboard
                        </a>
                    </div>
                </section>

                <!-- ERROR MESSAGE -->
                <% if (error != null && !error.trim().isEmpty()) {%>
                <div class="alert-error">
                    <span class="error-icon">!</span>
                    <span><%=escapeHtml(error)%></span>
                </div>
                <% }%>

                <!-- FILTER AND SORT -->
                <section class="panel">

                    <div class="panel-header">
                        <div>
                            <span class="panel-kicker">FILTER &amp; SORT</span>
                            <h3>Alert Filters</h3>
                        </div>
                    </div>

                    <form method="GET" action="<%=contextPath%>/alert">

                        <div class="filter-grid">

                            <div class="filter-field">
                                <label for="searchId">Search Alert / Bin ID</label>
                                <input type="text"
                                       id="searchId"
                                       name="searchId"
                                       value="<%=escapeHtml(searchId)%>"
                                       placeholder="Enter alert ID or bin ID">
                            </div>

                            <div class="filter-field">
                                <label for="alertType">Alert Type</label>
                                <input type="text"
                                       id="alertType"
                                       name="alertType"
                                       value="<%=escapeHtml(alertType)%>"
                                       placeholder="All types">
                            </div>

                            <div class="filter-field">
                                <label for="status">Status</label>
                                <select id="status" name="status">

                                    <option value="all"
                                            <%= "all".equalsIgnoreCase(status)
                                                    || status.isEmpty()
                                                    ? "selected" : ""%>>
                                        All statuses
                                    </option>

                                    <option value="Unresolved"
                                            <%= "Unresolved".equalsIgnoreCase(status)
                                                    ? "selected" : ""%>>
                                        Unresolved
                                    </option>

                                    <option value="Resolved"
                                            <%= "Resolved".equalsIgnoreCase(status)
                                                    ? "selected" : ""%>>
                                        Resolved
                                    </option>

                                </select>
                            </div>

                            <div class="filter-field">
                                <label for="sortBy">Sort By</label>
                                <select id="sortBy" name="sortBy">

                                    <option value="createdDate"
                                            <%= "createdDate".equals(sortBy)
                                                    ? "selected" : ""%>>
                                        Created Date
                                    </option>

                                    <option value="alertType"
                                            <%= "alertType".equals(sortBy)
                                                    ? "selected" : ""%>>
                                        Alert Type
                                    </option>

                                    <option value="status"
                                            <%= "status".equals(sortBy)
                                                    ? "selected" : ""%>>
                                        Status
                                    </option>

                                </select>
                            </div>

                            <div class="filter-field">
                                <label for="order">Order</label>
                                <select id="order" name="order">

                                    <option value="ASC"
                                            <%= "ASC".equalsIgnoreCase(order)
                                                    ? "selected" : ""%>>
                                        Ascending
                                    </option>

                                    <option value="DESC"
                                            <%= "DESC".equalsIgnoreCase(order)
                                                    ? "selected" : ""%>>
                                        Descending
                                    </option>

                                </select>
                            </div>

                            <div class="page-actions">
                                <button type="submit" class="btn btn-primary">
                                    Apply Filter
                                </button>

                                <a class="btn btn-light"
                                   href="<%=contextPath%>/alert">
                                    Reset
                                </a>
                            </div>

                        </div>
                    </form>
                </section>

                <!-- ALERT LIST -->
                <section class="panel" style="margin-top:20px;">

                    <div class="panel-header">
                        <div>
                            <span class="panel-kicker">ALERT INVENTORY</span>
                            <h3>Alert List</h3>
                        </div>

                        <span class="record-count">
                            <%=totalRecords%> records
                        </span>
                    </div>

                    <div class="alert-table-wrapper">
                        <table class="alert-table">

                            <thead>
                                <tr>
                                    <th>Alert ID</th>
                                    <th>Bin ID</th>
                                    <th>Alert Type</th>
                                    <th>Message</th>
                                    <th>Created Date</th>
                                    <th>Status</th>
                                    <th>Action</th>
                                </tr>
                            </thead>

                            <tbody>

                                <% if (list != null && !list.isEmpty()) { %>

                                <% for (Alert alert : list) {%>
                                <tr>

                                    <td>
                                        <span class="id-pill">
                                            #<%=escapeHtml(alert.getAlertID())%>
                                        </span>
                                    </td>

                                    <td>
                                        <span class="id-pill">
                                            #<%=escapeHtml(alert.getBinID())%>
                                        </span>
                                    </td>

                                    <td>
                                        <span class="type-label">
                                            <%=escapeHtml(alert.getAlertType())%>
                                        </span>
                                    </td>

                                    <td>
                                        <div class="message-cell">
                                            <%=escapeHtml(alert.getMessage())%>
                                        </div>
                                    </td>

                                    <td>
                                        <%=alert.getCreatedDate() != null
                                                ? escapeHtml(
                                                        alert.getCreatedDate().toString())
                                                : ""%>
                                    </td>

                                    <td>
                                        <% if (alert.isResolved()) { %>
                                        <span class="status-pill status-resolved">
                                            Resolved
                                        </span>
                                        <% } else { %>
                                        <span class="status-pill status-open">
                                            Unresolved
                                        </span>
                                        <% }%>
                                    </td>

                                    <td>
                                        <div class="action-group">

                                            <!-- VIEW -->
                                            <a class="action-btn action-view"
                                               href="<%=contextPath%>/alert/view?id=<%=java.net.URLEncoder.encode(alert.getAlertID(), "UTF-8")%>">
                                                View
                                            </a>

                                            <!-- 1-CLICK QUICK DISPATCH / MAINTENANCE -->
                                            <% if (!alert.isResolved() && alert.getBinID() != null && !alert.getBinID().trim().isEmpty()) {
                                                String at = alert.getAlertType() != null ? alert.getAlertType().toLowerCase() : "";
                                                if ((at.contains("overflow") || at.contains("fill") || at.contains("high")) && canDispatchCollection) { %>
                                                    <a class="action-btn" style="color: #2563eb; background: #eff6ff; border: 1px solid #bfdbfe; font-weight: 600;"
                                                       href="<%=contextPath%>/collection/create?binID=<%=java.net.URLEncoder.encode(alert.getBinID(), "UTF-8")%>"
                                                       title="Dispatch collection for this bin">
                                                        <i class="fa-solid fa-truck"></i> Dispatch
                                                    </a>
                                                <% } else if ((at.contains("sensor") || at.contains("fault") || at.contains("conflict")) && canRequestMaintenance) { %>
                                                    <a class="action-btn" style="color: #d97706; background: #fffbeb; border: 1px solid #fde68a; font-weight: 600;"
                                                       href="<%=contextPath%>/maintenance/create?binID=<%=java.net.URLEncoder.encode(alert.getBinID(), "UTF-8")%>"
                                                       title="Create maintenance ticket for this incident">
                                                        <i class="fa-solid fa-wrench"></i> Maintain
                                                    </a>
                                                <% } %>
                                            <% } %>

                                            <% if (canEdit) { %>
                                            <!-- EDIT -->
                                            <a class="action-btn action-edit"
                                               href="<%=contextPath%>/alert/edit?id=<%=java.net.URLEncoder.encode(alert.getAlertID(), "UTF-8")%>">
                                                Edit
                                            </a>
                                            <% } %>

                                            <% if (canResolve) { %>
                                            <!-- RESOLVE / UNRESOLVE -->
                                            <form action="<%=contextPath%>/alert/resolve"
                                                  method="POST"
                                                  onsubmit="return confirm('Are you sure you want to change this alert status?');">

                                                <input type="hidden"
                                                       name="id"
                                                       value="<%=escapeHtml(alert.getAlertID())%>">

                                                <input type="hidden"
                                                       name="resolved"
                                                       value="<%=!alert.isResolved()%>">

                                                <button type="submit"
                                                        class="action-btn action-resolve">
                                                    <%=alert.isResolved()
                                                            ? "Unresolve"
                                                            : "Resolve"%>
                                                </button>
                                            </form>
                                            <% } %>

                                            <% if (canDelete) { %>
                                            <!-- DELETE -->
                                            <form action="<%=contextPath%>/alert/delete"
                                                  method="POST"
                                                  onsubmit="return confirm('Are you sure you want to delete this alert?');">

                                                <input type="hidden"
                                                       name="id"
                                                       value="<%=escapeHtml(alert.getAlertID())%>">

                                                <button type="submit"
                                                        class="action-btn action-delete">
                                                    Delete
                                                </button>
                                            </form>
                                            <% } %>

                                        </div>
                                    </td>

                                </tr>
                                <% } %>

                                <% } else { %>

                                <tr>
                                    <td colspan="7">
                                        <div class="empty-state">
                                            <div class="empty-state-icon">!</div>
                                            <strong>No alerts found</strong>
                                            <span>
                                                There are currently no alerts matching your filters.
                                            </span>
                                        </div>
                                    </td>
                                </tr>

                                <% } %>

                            </tbody>
                        </table>
                    </div>

                    <!-- SHARED PAGINATION -->
                    <%
                        request.setAttribute(
                                "PAGINATION_BASE_URL",
                                contextPath + "/alert"
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

                <!-- FOOTER -->
                <footer class="footer">
                    <span>SmartWaste Management System</span>
                    <span>Alert Management</span>
                </footer>

            </main>
        </div>

    </body>
</html>

