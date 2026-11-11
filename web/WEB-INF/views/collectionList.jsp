<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="model.CollectionRequest"%>
<%@page import="model.AppUser"%>

<%!
    // Encode query parameter to prevent broken URLs.
    private String enc(String value) throws Exception {
        return URLEncoder.encode(
                value == null ? "" : value, "UTF-8"
        );
    }

    // Basic HTML escaping for values printed into HTML.
    private String esc(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }
%>

<%
    List<CollectionRequest> list
            = (List<CollectionRequest>) request.getAttribute("LIST_COLLECTION");

    String error = (String) request.getAttribute("ERROR");

    AppUser currentUser = (AppUser) session.getAttribute("user");

    String role = currentUser != null
            ? currentUser.getRoleId() : "";

    boolean isSupervisor = "SUP".equals(role);
    boolean isManager = "MGR".equals(role);
    boolean isAdmin = "ADM".equals(role) || "SAD".equals(role);
    boolean canCreate = isAdmin || isManager || isSupervisor;
    boolean canDelete = isAdmin || isManager;
    boolean canEdit = isAdmin || isManager || isSupervisor || "STF".equals(role);
    boolean canSearchStaff = isAdmin || isManager || isSupervisor;
    boolean canVerify = isSupervisor || isManager || isAdmin;

    String searchId = request.getParameter("searchId");
    String staffId = request.getParameter("staffId");
    String sortBy = request.getParameter("sortBy");
    String order = request.getParameter("order");

    if (searchId == null) {
        searchId = "";
    }
    if (staffId == null) {
        staffId = "";
    }
    if (sortBy == null || sortBy.trim().isEmpty()) {
        sortBy = "createdDate";
    }
    if (order == null || order.trim().isEmpty()) {
        order = "DESC";
    }

    Integer cp = (Integer) request.getAttribute("CURRENT_PAGE");
    Integer ps = (Integer) request.getAttribute("PAGE_SIZE");
    Integer tp = (Integer) request.getAttribute("TOTAL_PAGES");
    Integer tr = (Integer) request.getAttribute("TOTAL_RECORDS");

    int currentPage = cp != null ? cp : 1;
    int pageSize = ps != null ? ps : 10;
    int totalPages = tp != null ? tp : 1;
    int totalRecords = tr != null ? tr : (list == null ? 0 : list.size());

    String baseUrl = request.getContextPath() + "/collection";
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Collection Management</title>

        <link rel="stylesheet"
              href="<%=request.getContextPath()%>/css/style.css?v=20261017-v4">

        <style>
            body {
                background: #EDF8F2 !important;
                color: #1C1E21 !important;
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            }

            .collection-page {
                margin-left: 0;
                width: 100%;
                min-height: 100vh;
                padding: 30px 36px;
                box-sizing: border-box;
                background: #EDF8F2;
            }

            .collection-header {
                display: flex;
                justify-content: space-between;
                align-items: flex-start;
                gap: 20px;
                margin-bottom: 24px;
            }

            .page-kicker {
                display: block;
                margin-bottom: 5px;
                color: #65676B;
                font-size: 11px;
                font-weight: 700;
                letter-spacing: 0.8px;
                text-transform: uppercase;
            }

            .page-title {
                margin: 0;
                color: #050505;
                font-size: 26px;
                font-weight: 700;
                letter-spacing: -0.3px;
            }

            .page-description {
                margin: 6px 0 0;
                color: #65676B;
                font-size: 14px;
            }

            .header-actions, .filter-actions {
                display: flex;
                gap: 8px;
                flex-wrap: wrap;
            }

            .collection-btn {
                min-height: 38px;
                padding: 0 16px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                gap: 7px;
                border: 1px solid transparent;
                border-radius: 6px;
                cursor: pointer;
                font-family: inherit;
                font-size: 13px;
                font-weight: 600;
                text-decoration: none;
                box-sizing: border-box;
                transition: background 0.15s ease, border-color 0.15s ease;
            }

            .collection-btn-primary {
                color: #FFFFFF !important;
                background: #00875A !important;
                border-color: #00875A !important;
                box-shadow: none !important;
            }

            .collection-btn-primary:hover {
                background: #006644 !important;
                border-color: #006644 !important;
            }

            .collection-btn-light {
                color: #050505 !important;
                background: #FFFFFF !important;
                border: 1px solid #D1EBCF !important;
            }

            .collection-btn-light:hover {
                background: #EDF8F2 !important;
                border-color: #D1EBCF !important;
                color: #050505 !important;
            }

            .filter-panel {
                margin-bottom: 20px;
                padding: 20px 22px;
                border: 1px solid #D1EBCF;
                border-radius: 8px;
                background: #FFFFFF;
                box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
                box-sizing: border-box;
            }

            .filter-header {
                display: flex;
                justify-content: space-between;
                margin-bottom: 16px;
            }

            .filter-title, .table-title {
                margin: 0;
                color: #050505;
                font-size: 16px;
                font-weight: 700;
            }

            .filter-subtitle {
                margin: 4px 0 0;
                color: #65676B;
                font-size: 13px;
            }

            .filter-grid {
                display: grid;
                grid-template-columns:
                    minmax(180px, 1.5fr)
                    minmax(150px, 1fr)
                    minmax(140px, 1fr)
                    minmax(120px, .8fr)
                    auto;
                gap: 12px;
                align-items: end;
            }

            .filter-field {
                display: flex;
                flex-direction: column;
                gap: 6px;
                min-width: 0;
            }

            .filter-label {
                color: #050505;
                font-size: 12px;
                font-weight: 600;
            }

            .filter-input, .filter-select {
                width: 100%;
                height: 38px;
                padding: 0 12px;
                border: 1px solid #D1EBCF;
                border-radius: 6px;
                outline: none;
                color: #050505;
                background: #FFFFFF;
                font-family: inherit;
                font-size: 13px;
                box-sizing: border-box;
                transition: border-color 0.15s ease, box-shadow 0.15s ease;
            }

            .filter-input:focus, .filter-select:focus {
                border-color: #00875A;
                box-shadow: 0 0 0 2px rgba(0, 135, 90, 0.2);
            }

            .table-panel {
                width: 100%;
                overflow: hidden;
                border: 1px solid #D1EBCF;
                border-radius: 8px;
                background: #FFFFFF;
                box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
                box-sizing: border-box;
            }

            .table-header {
                padding: 16px 20px;
                display: flex;
                align-items: center;
                justify-content: space-between;
                gap: 12px;
                border-bottom: 1px solid #D1EBCF;
                background: #FFFFFF;
            }

            .record-count {
                padding: 4px 10px;
                border-radius: 6px;
                color: #65676B;
                background: #EDF8F2;
                font-size: 12px;
                font-weight: 600;
                border: 1px solid #E2F2E5;
            }

            .collection-table-wrapper {
                width: 100%;
                overflow-x: auto;
            }

            .collection-table {
                width: 100%;
                min-width: 850px;
                border-collapse: collapse;
            }

            .collection-table th {
                padding: 12px 16px;
                text-align: left;
                color: #65676B;
                background: #EDF8F2;
                border-bottom: 1px solid #D1EBCF;
                font-size: 11px;
                font-weight: 700;
                letter-spacing: .5px;
                text-transform: uppercase;
                white-space: nowrap;
            }

            .collection-table td {
                padding: 13px 16px;
                border-bottom: 1px solid #E2F2E5;
                color: #1C1E21;
                font-size: 13px;
                vertical-align: middle;
            }

            .collection-table tbody tr {
                background: #FFFFFF;
                transition: background 0.15s ease;
            }

            .collection-table tbody tr:hover {
                background: #F2F3F5;
            }

            .collection-table tbody tr:last-child td {
                border-bottom: 0;
            }

            .request-id {
                color: #1C1E21;
                font-weight: 700;
                font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
            }

            .bin-id {
                font-weight: 600;
                color: #050505;
            }

            .staff-id, .created-date {
                color: #65676B;
                font-size: 13px;
            }

            .created-date, .action-cell {
                white-space: nowrap;
            }

            .priority-tag {
                display: inline-flex;
                align-items: center;
                padding: 3px 8px;
                border-radius: 4px;
                font-size: 12px;
                font-weight: 600;
                white-space: nowrap;
            }

            .priority-normal {
                background: #EDF8F2;
                color: #143D2D;
                border: 1px solid #D1EBCF;
            }

            .priority-high {
                background: #FEF3C7;
                color: #92400E;
                border: 1px solid #FDE68A;
            }

            .priority-emergency {
                background: #FEE2E2;
                color: #991B1B;
                border: 1px solid #FECACA;
                font-weight: 700;
            }

            .action-link {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                height: 30px;
                padding: 0 10px;
                margin-right: 4px;
                gap: 5px;
                border-radius: 6px;
                border: 1px solid #D1EBCF;
                background: #FFFFFF;
                color: #050505;
                font-size: 12px;
                font-weight: 600;
                text-decoration: none;
                cursor: pointer;
                font-family: inherit;
                box-sizing: border-box;
                transition: all 0.15s ease;
            }

            .action-link:hover {
                background: #EDF8F2;
                border-color: #D1EBCF;
                color: #050505;
            }

            .action-link.action-primary {
                background: #DCF2E4;
                border-color: #00875A;
                color: #00875A;
            }

            .action-link.action-primary:hover {
                background: #00875A;
                color: #FFFFFF;
                border-color: #00875A;
            }

            .action-link.action-delete {
                border-color: #D1EBCF;
                color: #65676B;
            }

            .action-link.action-delete i {
                color: #DC2626;
            }

            .action-link.action-delete:hover {
                background: #FEE2E2;
                border-color: #DC2626;
                color: #DC2626;
            }

            .action-form {
                display: inline;
                margin: 0;
            }

            .empty-state {
                padding: 55px 20px !important;
                text-align: center;
                color: #65676B !important;
            }

            .empty-icon {
                width: 48px;
                height: 48px;
                margin: 0 auto 12px;
                display: grid;
                place-items: center;
                border-radius: 12px;
                color: #65676B;
                background: #EDF8F2;
                font-size: 20px;
            }

            .empty-title {
                display: block;
                margin-bottom: 4px;
                color: #050505;
                font-size: 14px;
                font-weight: 700;
            }

            .error-box {
                margin-bottom: 20px;
                padding: 12px 16px;
                border: 1px solid #FECACA;
                border-radius: 8px;
                color: #991B1B;
                background: #FEF2F2;
                font-size: 13px;
                font-weight: 600;
            }

            @media (max-width: 1200px) {
                .filter-grid {
                    grid-template-columns: 1fr 1fr;
                }
                .filter-actions {
                    grid-column: 1 / -1;
                }
            }

            @media (max-width: 900px) {
                .collection-page {
                    padding: 28px 24px;
                }
                .collection-header {
                    flex-direction: column;
                }
                .header-actions {
                    width: 100%;
                }
            }

            @media (max-width: 800px) {
                .collection-page {
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
                .collection-page {
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
                .collection-table th, .collection-table td {
                    padding-left: 13px;
                    padding-right: 13px;
                }
            }
        </style>
    </head>

    <body>
        <div class="app-shell">

            <jsp:include page="sidebar.jsp" />

            <main class="collection-page">

                <section class="collection-header">
                    <div style="display: flex; align-items: center;">
                        <button type="button" class="desktop-nav-toggle" onclick="toggleSidebarCollapse()" title="Toggle Sidebar (Expand / Collapse)">
                            <i class="fa-solid fa-bars"></i>
                        </button>
                        <div>
                            <span class="page-kicker">OPERATIONS</span>
                            <h1 class="page-title">Collection Management</h1>
                        </div>
                    </div>

                    <div class="header-actions">
                        <% if (isSupervisor) { %>
                        <button type="button" class="collection-btn" style="background: #eff6ff; color: #2563eb; border: 1px solid #bfdbfe;" onclick="openScheduleModal()">
                            <i class="fa-solid fa-calendar-plus"></i>
                            Propose Schedule
                        </button>
                        <% } %>

                        <% if (canCreate) {%>
                        <a class="collection-btn collection-btn-primary"
                           href="<%=request.getContextPath()%>/collection/create">
                            <i class="fa-solid fa-plus"></i>
                            Create Collection
                        </a>
                        <% }%>

                        <a class="collection-btn collection-btn-light"
                           href="<%=request.getContextPath()%>/dashboard">
                            <i class="fa-solid fa-house"></i>
                            Dashboard
                        </a>
                    </div>
                </section>

                <% if ("route_dispatched".equals(request.getParameter("msg"))) { %>
                <div style="margin-bottom: 20px; padding: 13px 18px; border: 1px solid #86efac; border-radius: 12px; color: #166534; background: #dcfce7; font-size: 14px; font-weight: 700; display: flex; align-items: center; gap: 10px;">
                    <i class="fa-solid fa-truck-ramp-box" style="font-size: 18px;"></i>
                    <span>Collection Route successfully dispatched! Created <%= request.getParameter("count") != null ? request.getParameter("count") : "multiple" %> coordinated collection tickets assigned to field staff.</span>
                </div>
                <% } %>

                <% if ("proposal_sent".equals(request.getParameter("msg"))) { %>
                <div style="margin-bottom: 20px; padding: 13px 16px; border: 1px solid #bbf7d0; border-radius: 12px; color: #166534; background: #f0fdf4; font-size: 13px; font-weight: 600;">
                    <i class="fa-solid fa-circle-check" style="margin-right: 6px;"></i>
                    Your collection schedule adjustment proposal has been forwarded to Operations Managers!
                </div>
                <% } %>

                <% if (error != null && !error.trim().isEmpty()) {%>
                <div class="error-box">
                    <i class="fa-solid fa-circle-exclamation"></i>
                    <%=esc(error)%>
                </div>
                <% }%>

                <!-- FILTER -->
                <section class="filter-panel">
                    <div class="filter-header">
                        <div>
                            <h2 class="filter-title">Filter &amp; Search</h2>
                            <p class="filter-subtitle">
                                Search by ID and arrange collection requests.
                            </p>
                        </div>
                    </div>

                    <form method="GET" action="<%=baseUrl%>">
                        <div class="filter-grid">

                            <div class="filter-field">
                                <label class="filter-label" for="searchId">
                                    Search ID
                                </label>
                                <input class="filter-input"
                                       type="text" id="searchId" name="searchId"
                                       value="<%=esc(searchId)%>"
                                       placeholder="Request ID or Bin ID">
                            </div>

                            <% if (canSearchStaff) {%>
                            <div class="filter-field">
                                <label class="filter-label" for="staffId">
                                    Staff ID
                                </label>
                                <input class="filter-input"
                                       type="text" id="staffId" name="staffId"
                                       value="<%=esc(staffId)%>"
                                       placeholder="Enter Staff ID">
                            </div>
                            <% }%>

                            <div class="filter-field">
                                <label class="filter-label" for="sortBy">Sort By</label>
                                <select class="filter-select" id="sortBy" name="sortBy">
                                    <option value="status"
                                            <%="status".equals(sortBy) ? "selected" : ""%>>
                                        Status
                                    </option>
                                    <option value="priority"
                                            <%="priority".equals(sortBy) ? "selected" : ""%>>
                                        Priority
                                    </option>
                                    <option value="createdDate"
                                            <%="createdDate".equals(sortBy) ? "selected" : ""%>>
                                        Created Date
                                    </option>
                                </select>
                            </div>

                            <div class="filter-field">
                                <label class="filter-label" for="order">Order</label>
                                <select class="filter-select" id="order" name="order">
                                    <option value="ASC"
                                            <%="ASC".equalsIgnoreCase(order) ? "selected" : ""%>>
                                        ASC
                                    </option>
                                    <option value="DESC"
                                            <%="DESC".equalsIgnoreCase(order) ? "selected" : ""%>>
                                        DESC
                                    </option>
                                </select>
                            </div>

                            <div class="filter-actions">
                                <button type="submit"
                                        class="collection-btn collection-btn-primary">
                                    <i class="fa-solid fa-filter"></i>
                                    Apply Filter
                                </button>

                                <a href="<%=baseUrl%>"
                                   class="collection-btn collection-btn-light">
                                    <i class="fa-solid fa-rotate-left"></i>
                                    Reset
                                </a>
                            </div>
                        </div>
                    </form>
                </section>

                <!-- TABLE -->
                <section class="table-panel">
                    <div class="table-header">
                        <h2 class="table-title">Collection Requests</h2>
                        <span class="record-count"><%=totalRecords%> records</span>
                    </div>

                    <div class="collection-table-wrapper">
                        <table class="collection-table">
                            <thead>
                                <tr>
                                    <th>Request ID</th>
                                    <th>Bin ID</th>
                                        <% if (canSearchStaff) { %>
                                    <th>Staff ID</th>
                                        <% } %>
                                    <th style="min-width: 140px; white-space: nowrap;">Status</th>
                                    <th style="white-space: nowrap;">Priority</th>
                                    <th style="white-space: nowrap;">Created Date</th>
                                    <th style="white-space: nowrap;">Action</th>
                                </tr>
                            </thead>

                            <tbody>
                                <% if (list != null && !list.isEmpty()) {
                            for (CollectionRequest item : list) {%>
                                <tr>
                                    <td>
                                        <span class="request-id">
                                            <%=esc(item.getRequestID())%>
                                        </span>
                                    </td>

                                    <td>
                                        <span class="bin-id">
                                            <%=esc(item.getBinID())%>
                                        </span>
                                    </td>

                                    <% if (canSearchStaff) {%>
                                    <td>
                                        <span class="staff-id">
                                            <%=esc(item.getStaffID())%>
                                        </span>
                                    </td>
                                    <% }%>

                                    <td style="white-space: nowrap;">
                                        <%
                                            String st = item.getStatus() != null ? item.getStatus() : "Pending";
                                            String stClean = st.replace("_", " ");
                                            String dotColor = "#65676B";
                                            if ("Completed".equalsIgnoreCase(st)) {
                                                dotColor = "#00875A";
                                            } else if ("Verified".equalsIgnoreCase(st)) {
                                                dotColor = "#31A24C";
                                            } else if ("In_Progress".equalsIgnoreCase(st) || "In Progress".equalsIgnoreCase(st)) {
                                                dotColor = "#F59E0B";
                                            } else if ("Failed".equalsIgnoreCase(st)) {
                                                dotColor = "#FA383E";
                                            } else if ("Skipped".equalsIgnoreCase(st)) {
                                                dotColor = "#8A8D91";
                                            }
                                        %>
                                        <div style="display: inline-flex; align-items: center; gap: 8px;">
                                            <span style="display: inline-flex; align-items: center; gap: 6px; font-size: 13px; font-weight: 600; color: #1C1E21;">
                                                <span style="width: 8px; height: 8px; border-radius: 50%; background: <%=dotColor%>; display: inline-block; flex-shrink: 0;"></span>
                                                <%=esc(stClean)%>
                                            </span>
                                            <% if (item.isOverdue()) { %>
                                                <span style="display: inline-flex; align-items: center; gap: 3px; font-size: 11px; font-weight: 700; color: #DC2626; background: #FEE2E2; border: 1px solid #FECACA; padding: 2px 6px; border-radius: 4px;" title="Overdue: <%=item.getHoursElapsed()%>h without completion">
                                                    <i class="fa-regular fa-clock" style="font-size: 10px;"></i> <%=item.getHoursElapsed()%>h
                                                </span>
                                            <% } %>
                                        </div>
                                    </td>

                                    <td style="white-space: nowrap;">
                                        <%
                                            String pri = item.getPriority() != null ? item.getPriority().trim() : "Normal";
                                            if ("Low".equalsIgnoreCase(pri)) {
                                                pri = "Normal";
                                            }
                                            String priClass = "priority-normal";
                                            if ("High".equalsIgnoreCase(pri)) {
                                                priClass = "priority-high";
                                            } else if ("Emergency".equalsIgnoreCase(pri) || "Critical".equalsIgnoreCase(pri) || "Emer".equalsIgnoreCase(pri)) {
                                                priClass = "priority-emergency";
                                                pri = "Emergency";
                                            }
                                        %>
                                        <span class="priority-tag <%=priClass%>">
                                            <%=esc(pri)%>
                                        </span>
                                    </td>

                                    <td>
                                        <span class="created-date">
                                            <%=item.getCreatedDate() == null
                                        ? "" : item.getCreatedDate()%>
                                        </span>
                                    </td>

                                    <td class="action-cell">
                                        <a class="action-link"
                                           href="<%=request.getContextPath()%>/collection/view?id=<%=enc(item.getRequestID())%>">
                                            <i class="fa-regular fa-eye"></i> View
                                        </a>

                                        <% if ("Pending".equalsIgnoreCase(item.getStatus()) && canEdit) { %>
                                        <a class="action-link action-primary"
                                           href="<%=request.getContextPath()%>/collection/start?id=<%=enc(item.getRequestID())%>"
                                           title="Start collection task">
                                            <i class="fa-solid fa-play"></i> Start
                                        </a>
                                        <% } %>

                                        <% if ("Completed".equalsIgnoreCase(item.getStatus()) && canVerify) { %>
                                        <form class="action-form"
                                              action="<%=request.getContextPath()%>/collection/verify"
                                              method="POST"
                                              onsubmit="return confirm('Verify and close collection task <%=esc(item.getRequestID())%>?');">
                                            <input type="hidden" name="requestID" value="<%=esc(item.getRequestID())%>">
                                            <button type="submit" class="action-link action-primary" title="Verify completion">
                                                <i class="fa-solid fa-check-double"></i> Verify
                                            </button>
                                        </form>
                                        <% } %>

                                        <% if (canEdit) {%>
                                        <a class="action-link"
                                           href="<%=request.getContextPath()%>/collection/edit?id=<%=enc(item.getRequestID())%>">
                                            <i class="fa-regular fa-pen-to-square"></i> Edit
                                        </a>
                                        <% } %>

                                        <% if (canDelete) {%>
                                        <form class="action-form"
                                              action="<%=request.getContextPath()%>/collection/delete"
                                              method="POST"
                                              onsubmit="return confirm('Are you sure you want to delete this request?');">
                                            <input type="hidden" name="id"
                                                   value="<%=esc(item.getRequestID())%>">
                                            <button type="submit"
                                                    class="action-link action-delete">
                                                <i class="fa-regular fa-trash-can"></i>
                                                Delete
                                            </button>
                                        </form>
                                        <% } %>
                                    </td>
                                </tr>
                                <%   }
                    } else {%>
                                <tr>
                                    <td colspan="<%=canSearchStaff ? 7 : 6%>"
                                        class="empty-state">
                                        <div class="empty-icon">
                                            <i class="fa-solid fa-arrows-rotate"></i>
                                        </div>
                                        <span class="empty-title">
                                            No collection requests found
                                        </span>
                                        Try changing your search or filter.
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>

                    <!-- Truyen du lieu cho pagination.jsp -->
                    <%
                        request.setAttribute(
                                "PAGINATION_BASE_URL",
                                request.getContextPath() + "/collection"
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

                    <!-- Su dung thanh phan trang dung chung -->
                    <jsp:include page="/WEB-INF/views/common/pagination.jsp" />

                </section>
            </main>
        </div>

        <% if (isSupervisor) { %>
        <div id="scheduleModal" style="display: none; position: fixed; inset: 0; background: rgba(15, 23, 42, 0.55); backdrop-filter: blur(4px); z-index: 9999; align-items: center; justify-content: center;">
            <div style="background: #ffffff; border-radius: 16px; width: 100%; max-width: 520px; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04); overflow: hidden; margin: 20px;">
                <div style="padding: 20px 24px; border-bottom: 1px solid #e2e8f0; display: flex; align-items: center; justify-content: space-between;">
                    <div style="display: flex; align-items: center; gap: 10px;">
                        <div style="width: 36px; height: 36px; border-radius: 10px; background: #eff6ff; color: #2563eb; display: flex; align-items: center; justify-content: center; font-size: 16px;">
                            <i class="fa-solid fa-calendar-plus"></i>
                        </div>
                        <div>
                            <h3 style="margin: 0; font-size: 16px; font-weight: 700; color: #0f172a;">Propose Schedule Adjustment</h3>
                            <p style="margin: 2px 0 0; font-size: 12px; color: #64748b;">Forward route/schedule changes to Operations Manager</p>
                        </div>
                    </div>
                    <button type="button" onclick="closeScheduleModal()" style="border: none; background: transparent; color: #94a3b8; font-size: 18px; cursor: pointer; padding: 4px;">&times;</button>
                </div>
                <form action="<%=request.getContextPath()%>/collection/propose-schedule" method="POST" style="padding: 24px;">
                    <div style="margin-bottom: 16px;">
                        <label style="display: block; font-size: 12px; font-weight: 700; color: #334155; margin-bottom: 6px;">Area / Sector</label>
                        <input type="text" name="areaID" value="<%=currentUser != null && currentUser.getAreaID() != null ? esc(currentUser.getAreaID()) : "AREA-01"%>" required style="width: 100%; height: 40px; padding: 0 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13px; box-sizing: border-box;">
                    </div>
                    <div style="margin-bottom: 16px;">
                        <label style="display: block; font-size: 12px; font-weight: 700; color: #334155; margin-bottom: 6px;">Proposed Adjustment</label>
                        <input type="text" name="proposedChange" placeholder="e.g. Increase collection frequency to 2x daily due to festival" required style="width: 100%; height: 40px; padding: 0 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13px; box-sizing: border-box;">
                    </div>
                    <div style="margin-bottom: 24px;">
                        <label style="display: block; font-size: 12px; font-weight: 700; color: #334155; margin-bottom: 6px;">Operational Reason &amp; Impact</label>
                        <textarea name="reason" rows="3" placeholder="Provide background reasoning (e.g. repeated overflow alerts at Bin-003, traffic congestion between 8-9 AM)..." required style="width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13px; box-sizing: border-box; resize: vertical;"></textarea>
                    </div>
                    <div style="display: flex; justify-content: flex-end; gap: 10px;">
                        <button type="button" onclick="closeScheduleModal()" style="padding: 9px 18px; border: 1px solid #cbd5e1; background: #ffffff; color: #475569; border-radius: 8px; font-size: 13px; font-weight: 600; cursor: pointer;">Cancel</button>
                        <button type="submit" style="padding: 9px 20px; border: none; background: #2563eb; color: #ffffff; border-radius: 8px; font-size: 13px; font-weight: 600; cursor: pointer; display: flex; align-items: center; gap: 6px;">
                            <i class="fa-solid fa-paper-plane"></i> Submit Proposal
                        </button>
                    </div>
                </form>
            </div>
        </div>
        <script>
            function openScheduleModal() {
                var modal = document.getElementById('scheduleModal');
                if (modal) modal.style.display = 'flex';
            }
            function closeScheduleModal() {
                var modal = document.getElementById('scheduleModal');
                if (modal) modal.style.display = 'none';
            }
        </script>
        <% } %>
    </body>
</html>