<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.AppUser"%>
<%@page import="model.Discrepancy"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<%
    String ctx = request.getContextPath();
    AppUser user = (AppUser) session.getAttribute("user");
    boolean isAuditor = user != null && user.isAuditor();
    boolean isSuperAdmin = user != null && user.isSuperAdmin();
    boolean canLogDiscrepancy = isAuditor || isSuperAdmin;

    List<Discrepancy> list = (List<Discrepancy>) request.getAttribute("discrepancies");
    int totalCount = request.getAttribute("totalCount") != null ? (Integer) request.getAttribute("totalCount") : 0;
    int openCount = request.getAttribute("openCount") != null ? (Integer) request.getAttribute("openCount") : 0;
    int investigatingCount = request.getAttribute("investigatingCount") != null ? (Integer) request.getAttribute("investigatingCount") : 0;
    int resolvedCount = request.getAttribute("resolvedCount") != null ? (Integer) request.getAttribute("resolvedCount") : 0;
    int closedCount = request.getAttribute("closedCount") != null ? (Integer) request.getAttribute("closedCount") : 0;

    int currentPage = request.getAttribute("currentPage") != null ? (Integer) request.getAttribute("currentPage") : 1;
    int totalPages = request.getAttribute("totalPages") != null ? (Integer) request.getAttribute("totalPages") : 1;
    int totalRecords = request.getAttribute("totalRecords") != null ? (Integer) request.getAttribute("totalRecords") : 0;

    String selectedType = (String) request.getAttribute("selectedType");
    String selectedStatus = (String) request.getAttribute("selectedStatus");
    String selectedSeverity = (String) request.getAttribute("selectedSeverity");
    String searchKeyword = (String) request.getAttribute("searchKeyword");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Audit Findings &amp; Discrepancies - SmartWaste</title>
    <link rel="stylesheet" href="<%=ctx%>/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .audit-page {
            margin-left: 0;
            width: 100%;
            min-height: 100vh;
            padding: 30px 36px;
            background: #EDF8F2;
            box-sizing: border-box;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            color: #1C1E21;
        }
        .header-section {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 24px;
            flex-wrap: wrap;
            gap: 16px;
        }
        .page-title {
            font-size: 24px;
            font-weight: 800;
            color: #050505;
            margin: 0 0 6px 0;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .page-desc {
            color: #65676B;
            font-size: 13.5px;
            margin: 0;
        }
        .kpi-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 16px;
            margin-bottom: 24px;
        }
        .kpi-card {
            background: #FFFFFF;
            border-radius: 8px;
            padding: 16px 20px;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
            border: 1px solid #D1EBCF;
            border-top: 3px solid #D1EBCF;
        }
        .kpi-card.kpi-total { border-top-color: #00875A; }
        .kpi-card.kpi-open { border-top-color: #DC2626; }
        .kpi-card.kpi-investigating { border-top-color: #D97706; }
        .kpi-card.kpi-resolved { border-top-color: #00875A; }
        .kpi-card.kpi-closed { border-top-color: #16A34A; }
        .kpi-value {
            font-size: 26px;
            font-weight: 800;
            color: #050505;
            margin-bottom: 4px;
            font-variant-numeric: tabular-nums;
        }
        .kpi-label {
            font-size: 11px;
            font-weight: 700;
            color: #65676B;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }
        .filter-panel {
            background: #FFFFFF;
            padding: 18px 24px;
            border-radius: 8px;
            border: 1px solid #D1EBCF;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
            margin-bottom: 24px;
        }
        .filter-form {
            display: flex;
            flex-wrap: wrap;
            gap: 14px;
            align-items: center;
        }
        .filter-group {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }
        .filter-group label {
            font-size: 11px;
            font-weight: 700;
            color: #65676B;
            text-transform: uppercase;
        }
        .filter-input, .filter-select {
            padding: 8px 12px;
            border: 1px solid #D1EBCF;
            border-radius: 6px;
            font-size: 13px;
            background: #FFFFFF;
            color: #1C1E21;
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
            cursor: pointer;
            border: none;
            transition: all 0.15s ease;
        }
        .btn-primary { background: #00875A; color: white; }
        .btn-primary:hover { background: #006644; }
        .btn-success { background: #16A34A; color: white; }
        .btn-success:hover { background: #15803D; }
        .btn-dark { background: #050505; color: white; }
        .btn-dark:hover { background: #1C1E21; }
        .table-panel {
            background: #FFFFFF;
            border-radius: 8px;
            border: 1px solid #D1EBCF;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
            overflow: hidden;
        }
        .table-header {
            padding: 14px 20px;
            background: #EDF8F2;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #D1EBCF;
        }
        .table-title {
            font-size: 15px;
            font-weight: 700;
            color: #050505;
            margin: 0;
        }
        .data-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
            text-align: left;
        }
        .data-table th {
            background: #EDF8F2;
            padding: 12px 18px;
            font-weight: 700;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: #65676B;
            border-bottom: 1px solid #D1EBCF;
        }
        .data-table td {
            padding: 14px 18px;
            border-bottom: 1px solid #E2F2E5;
            color: #1C1E21;
        }
        .data-table tbody tr:hover {
            background: #F2F3F5;
        }
        .badge {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
        }
        .badge-danger { background: #fee2e2; color: #b91c1c; }
        .badge-warning { background: #fef3c7; color: #b45309; }
        .badge-info { background: #e0f2fe; color: #0369a1; }
        .badge-primary { background: #ede9fe; color: #6d28d9; }
        .badge-success { background: #d1fae5; color: #047857; }
        .badge-secondary { background: #f1f5f9; color: #64748b; }
        .pagination {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 16px 24px;
            border-top: 1px solid #e2e8f0;
        }
        .page-link {
            padding: 6px 12px;
            border: 1px solid #cbd5e1;
            border-radius: 4px;
            color: #334155;
            text-decoration: none;
            font-size: 12px;
            margin-right: 4px;
        }
        .page-link.active {
            background: #6366f1;
            color: white;
            border-color: #6366f1;
        }
    </style>
</head>
<body>
    <div class="app-shell">
        <jsp:include page="sidebar.jsp" />

        <main class="audit-page">
            <div class="header-section">
                <div>
                    <h1 class="page-title">
                        <i class="fa-solid fa-scale-balanced" style="color: #6366f1;"></i>
                        Audit Findings &amp; Discrepancy Cases
                    </h1>
                </div>
                <div style="display: flex; gap: 10px;">
                    <a href="<%=ctx%>/data-quality" class="btn-action btn-dark">
                        <i class="fa-solid fa-radar"></i> Quality Scanner
                    </a>
                    <button type="button" onclick="openExportModal('discrepancies')" class="btn-action btn-success" style="cursor: pointer;">
                        <i class="fa-solid fa-file-csv"></i> Export CSV
                    </button>
                    <% if (canLogDiscrepancy) { %>
                    <a href="<%=ctx%>/discrepancy/create" class="btn-action btn-primary">
                        <i class="fa-solid fa-plus-circle"></i> Log Discrepancy
                    </a>
                    <% } %>
                </div>
            </div>

            <!-- KPI STATS -->
            <div class="kpi-grid">
                <div class="kpi-card kpi-total">
                    <div class="kpi-value"><%= totalCount %></div>
                    <div class="kpi-label">Total Findings</div>
                </div>
                <div class="kpi-card kpi-open">
                    <div class="kpi-value" style="color: #ef4444;"><%= openCount %></div>
                    <div class="kpi-label">Open Cases</div>
                </div>
                <div class="kpi-card kpi-investigating">
                    <div class="kpi-value" style="color: #f59e0b;"><%= investigatingCount %></div>
                    <div class="kpi-label">Under Investigation</div>
                </div>
                <div class="kpi-card kpi-resolved">
                    <div class="kpi-value" style="color: #3b82f6;"><%= resolvedCount %></div>
                    <div class="kpi-label">Resolved</div>
                </div>
                <div class="kpi-card kpi-closed">
                    <div class="kpi-value" style="color: #10b981;"><%= closedCount %></div>
                    <div class="kpi-label">Closed &amp; Concluded</div>
                </div>
            </div>

            <!-- FILTER PANEL -->
            <div class="filter-panel">
                <form class="filter-form" method="GET" action="<%=ctx%>/discrepancy">
                    <div class="filter-group">
                        <label>Discrepancy Type</label>
                        <select name="type" class="filter-select">
                            <option value="">-- All Types --</option>
                            <option value="Collection_Mismatch" <%= "Collection_Mismatch".equals(selectedType) ? "selected" : "" %>>Collection Mismatch</option>
                            <option value="Duplicate_Collection" <%= "Duplicate_Collection".equals(selectedType) ? "selected" : "" %>>Duplicate Collection</option>
                            <option value="Incomplete_Data" <%= "Incomplete_Data".equals(selectedType) ? "selected" : "" %>>Incomplete Data</option>
                            <option value="Sensor_Deviation" <%= "Sensor_Deviation".equals(selectedType) ? "selected" : "" %>>Sensor Deviation (>=20%)</option>
                            <option value="Stuck_Sensor" <%= "Stuck_Sensor".equals(selectedType) ? "selected" : "" %>>Stuck Sensor</option>
                            <option value="Config_Change" <%= "Config_Change".equals(selectedType) ? "selected" : "" %>>Config / Threshold Change</option>
                            <option value="Other" <%= "Other".equals(selectedType) ? "selected" : "" %>>Other Finding</option>
                        </select>
                    </div>

                    <div class="filter-group">
                        <label>Status</label>
                        <select name="status" class="filter-select">
                            <option value="">-- All Statuses --</option>
                            <option value="Open" <%= "Open".equals(selectedStatus) ? "selected" : "" %>>Open</option>
                            <option value="Investigating" <%= "Investigating".equals(selectedStatus) ? "selected" : "" %>>Investigating</option>
                            <option value="Resolved" <%= "Resolved".equals(selectedStatus) ? "selected" : "" %>>Resolved</option>
                            <option value="Closed" <%= "Closed".equals(selectedStatus) ? "selected" : "" %>>Closed</option>
                        </select>
                    </div>

                    <div class="filter-group">
                        <label>Severity</label>
                        <select name="severity" class="filter-select">
                            <option value="">-- All Severities --</option>
                            <option value="Low" <%= "Low".equals(selectedSeverity) ? "selected" : "" %>>Low</option>
                            <option value="Medium" <%= "Medium".equals(selectedSeverity) ? "selected" : "" %>>Medium</option>
                            <option value="High" <%= "High".equals(selectedSeverity) ? "selected" : "" %>>High</option>
                            <option value="Critical" <%= "Critical".equals(selectedSeverity) ? "selected" : "" %>>Critical</option>
                        </select>
                    </div>

                    <div class="filter-group" style="flex: 1; min-width: 200px;">
                        <label>Search Keyword</label>
                        <input type="text" name="search" class="filter-input" placeholder="Case ID, title, target ID..." value="<%= searchKeyword != null ? searchKeyword : "" %>">
                    </div>

                    <div class="filter-group" style="align-self: flex-end;">
                        <button type="submit" class="btn-action btn-primary">
                            <i class="fa-solid fa-filter"></i> Apply Filter
                        </button>
                    </div>
                </form>
            </div>

            <!-- TABLE PANEL -->
            <div class="table-panel">
                <div class="table-header">
                    <h2 class="table-title">Audit Investigation Cases (<%= totalRecords %>)</h2>
                </div>
                <div style="overflow-x: auto;">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Case ID</th>
                                <th>Finding Title</th>
                                <th>Type</th>
                                <th>Severity</th>
                                <th>Status</th>
                                <th>Logged By</th>
                                <th>Date Logged</th>
                                <th style="text-align: right;">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (list != null && !list.isEmpty()) {
                                for (Discrepancy d : list) { %>
                                <tr>
                                    <td style="font-family: monospace; font-weight: 700; color: #4338ca;">
                                        <%= d.getDiscrepancyID() %>
                                    </td>
                                    <td style="font-weight: 600; color: #1e293b; max-width: 280px;">
                                        <%= d.getTitle() %>
                                    </td>
                                    <td>
                                        <span style="font-size: 11px; font-weight: 600; color: #475569; background: #f1f5f9; padding: 2px 6px; border-radius: 4px;">
                                            <%= d.getDiscrepancyType() %>
                                        </span>
                                    </td>
                                    <td>
                                        <span class="badge <%= d.getSeverityBadgeClass() %>">
                                            <%= d.getSeverity() %>
                                        </span>
                                    </td>
                                    <td>
                                        <span class="badge <%= d.getStatusBadgeClass() %>">
                                            <%= d.getStatus() %>
                                        </span>
                                    </td>
                                    <td>
                                        <%= d.getDetectedByName() != null ? d.getDetectedByName() : d.getDetectedBy() %>
                                    </td>
                                    <td style="color: #64748b; white-space: nowrap;">
                                        <fmt:formatDate value="<%= d.getDetectedDate() %>" pattern="yyyy-MM-dd HH:mm" />
                                    </td>
                                    <td style="text-align: right;">
                                        <a href="<%=ctx%>/discrepancy/view?id=<%= d.getDiscrepancyID() %>" class="btn-action btn-dark" style="padding: 4px 10px; font-size: 12px;">
                                            <i class="fa-solid fa-magnifying-glass"></i> Review
                                        </a>
                                    </td>
                                </tr>
                            <%  }
                            } else { %>
                                <tr>
                                    <td colspan="8" style="text-align: center; color: #94a3b8; padding: 36px;">
                                        <i class="fa-solid fa-clipboard-check" style="font-size: 32px; color: #cbd5e1; margin-bottom: 8px; display: block;"></i>
                                        No discrepancy audit cases matching current criteria. All data verified consistent!
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>

                <!-- PAGINATION -->
                <% if (totalPages > 1) { %>
                <div class="pagination">
                    <span style="font-size: 12px; color: #64748b;">Page <%= currentPage %> of <%= totalPages %></span>
                    <div>
                        <% for (int p = 1; p <= totalPages; p++) { %>
                            <a class="page-link <%= p == currentPage ? "active" : "" %>" href="<%=ctx%>/discrepancy?page=<%= p %>&type=<%= selectedType != null ? selectedType : "" %>&status=<%= selectedStatus != null ? selectedStatus : "" %>&severity=<%= selectedSeverity != null ? selectedSeverity : "" %>&search=<%= searchKeyword != null ? searchKeyword : "" %>">
                                <%= p %>
                            </a>
                        <% } %>
                    </div>
                </div>
                <% } %>
            </div>
        </main>
    </div>
</body>
</html>
