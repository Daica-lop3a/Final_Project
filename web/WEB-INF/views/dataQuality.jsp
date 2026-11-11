<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="model.AppUser"%>
<%@page import="model.AuditLog"%>
<%@page import="model.BinInspection"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<%
    String ctx = request.getContextPath();
    AppUser user = (AppUser) session.getAttribute("user");
    boolean canLog = user != null && (user.isAuditor() || user.isSuperAdmin());

    List<Map<String, Object>> duplicateCollections = (List<Map<String, Object>>) request.getAttribute("duplicateCollections");
    List<Map<String, Object>> incompleteCollections = (List<Map<String, Object>>) request.getAttribute("incompleteCollections");
    List<BinInspection> sensorDeviations = (List<BinInspection>) request.getAttribute("sensorDeviations");
    List<Map<String, Object>> staffRankings = (List<Map<String, Object>>) request.getAttribute("staffRankings");
    List<Map<String, Object>> deviceRankings = (List<Map<String, Object>>) request.getAttribute("deviceRankings");
    List<AuditLog> configLogs = (List<AuditLog>) request.getAttribute("configLogs");

    int totalAnomalies = request.getAttribute("totalAnomalies") != null ? (Integer) request.getAttribute("totalAnomalies") : 0;
    int openDiscrepancies = request.getAttribute("openDiscrepancies") != null ? (Integer) request.getAttribute("openDiscrepancies") : 0;
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Data Quality Scanner &amp; Anomaly Detection - SmartWaste</title>
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
        .kpi-card.kpi-danger { border-top-color: #DC2626; }
        .kpi-card.kpi-warning { border-top-color: #D97706; }
        .kpi-card.kpi-info { border-top-color: #00875A; }
        .kpi-card.kpi-purple { border-top-color: #7C3AED; }
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
        .section-card {
            background: #FFFFFF;
            border-radius: 8px;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
            border: 1px solid #D1EBCF;
            margin-bottom: 24px;
            overflow: hidden;
        }
        .section-header {
            padding: 14px 20px;
            background: #EDF8F2;
            border-bottom: 1px solid #D1EBCF;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .section-title {
            margin: 0;
            font-size: 15px;
            font-weight: 700;
            color: #050505;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .badge-count {
            background: #E2F2E5;
            color: #65676B;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 700;
        }
        .badge-count.danger { background: #FEE2E2; color: #991B1B; }
        .badge-count.warning { background: #FEF3C7; color: #92400E; }
        .badge-count.info { background: #DCF2E4; color: #00875A; }
        .data-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
            text-align: left;
        }
        .data-table th {
            background: #EDF8F2;
            color: #65676B;
            padding: 12px 18px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            border-bottom: 1px solid #D1EBCF;
        }
        .data-table td {
            padding: 12px 18px;
            border-bottom: 1px solid #E2F2E5;
            color: #1C1E21;
        }
        .data-table tr:hover td {
            background: #F2F3F5;
        }
        .btn-log {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 4px 10px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 700;
            background: #6366f1;
            color: white;
            text-decoration: none;
            transition: background 0.2s;
        }
        .btn-log:hover { background: #4f46e5; }
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
            transition: all 0.2s;
        }
        .btn-primary { background: #6366f1; color: white; }
        .btn-primary:hover { background: #4f46e5; }
        .btn-dark { background: #1e293b; color: white; }
        .btn-dark:hover { background: #0f172a; }
    </style>
</head>
<body>
    <div class="app-shell">
        <jsp:include page="sidebar.jsp" />

        <main class="audit-page">
            <div class="header-section">
                <div>
                    <h1 class="page-title">
                        <i class="fa-solid fa-radar" style="color: #6366f1;"></i>
                        Data Quality Scanner &amp; Anomaly Analysis
                    </h1>
                </div>
                <div style="display: flex; gap: 10px;">
                    <a href="<%=ctx%>/discrepancy" class="btn-action btn-dark">
                        <i class="fa-solid fa-scale-balanced"></i> Discrepancy Dossiers (<%= openDiscrepancies %>)
                    </a>
                    <% if (canLog) { %>
                    <a href="<%=ctx%>/discrepancy/create" class="btn-action btn-primary">
                        <i class="fa-solid fa-plus-circle"></i> Log Finding
                    </a>
                    <% } %>
                </div>
            </div>

            <!-- KPI SUMMARY -->
            <div class="kpi-grid">
                <div class="kpi-card kpi-danger">
                    <div class="kpi-value" style="color: #ef4444;"><%= totalAnomalies %></div>
                    <div class="kpi-label">Active Anomalies Detected</div>
                </div>
                <div class="kpi-card kpi-warning">
                    <div class="kpi-value" style="color: #f59e0b;"><%= duplicateCollections != null ? duplicateCollections.size() : 0 %></div>
                    <div class="kpi-label">Duplicate Collections (&le;30m)</div>
                </div>
                <div class="kpi-card kpi-warning">
                    <div class="kpi-value" style="color: #f59e0b;"><%= incompleteCollections != null ? incompleteCollections.size() : 0 %></div>
                    <div class="kpi-label">Incomplete Log Records</div>
                </div>
                <div class="kpi-card kpi-danger">
                    <div class="kpi-value" style="color: #dc2626;"><%= sensorDeviations != null ? sensorDeviations.size() : 0 %></div>
                    <div class="kpi-label">Sensor Deviations (&ge;20%)</div>
                </div>
                <div class="kpi-card kpi-purple">
                    <div class="kpi-value" style="color: #8b5cf6;"><%= configLogs != null ? configLogs.size() : 0 %></div>
                    <div class="kpi-label">Threshold Config Logs</div>
                </div>
            </div>

            <!-- 1. DUPLICATE COLLECTIONS -->
            <div class="section-card">
                <div class="section-header">
                    <h3 class="section-title">
                        <i class="fa-solid fa-clone" style="color: #f59e0b;"></i>
                        Duplicate Collection Tasks Logged Within &le; 30 Minutes
                    </h3>
                    <span class="badge-count <%= (duplicateCollections != null && !duplicateCollections.isEmpty()) ? "warning" : "" %>">
                        <%= duplicateCollections != null ? duplicateCollections.size() : 0 %> issues
                    </span>
                </div>
                <div style="overflow-x: auto;">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Bin ID / Code</th>
                                <th>Area / Zone</th>
                                <th>First Request</th>
                                <th>Duplicate Request</th>
                                <th>Collector Staff</th>
                                <th>Interval (Minutes)</th>
                                <th style="text-align: right;">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (duplicateCollections != null && !duplicateCollections.isEmpty()) {
                                for (Map<String, Object> dup : duplicateCollections) { %>
                                <tr>
                                    <td>
                                        <strong style="color: #0284c7;"><%= dup.get("binCode") %></strong>
                                        <small style="color: #94a3b8;">(<%= dup.get("binID") %>)</small>
                                    </td>
                                    <td><%= dup.get("areaName") %></td>
                                    <td>
                                        <span style="font-family: monospace; font-size: 12px;"><%= dup.get("req1") %></span><br/>
                                        <small style="color: #64748b;"><%= dup.get("date1") != null ? sdf.format((java.util.Date)dup.get("date1")) : "" %></small>
                                    </td>
                                    <td>
                                        <span style="font-family: monospace; font-size: 12px; color: #b91c1c; font-weight: 700;"><%= dup.get("req2") %></span><br/>
                                        <small style="color: #64748b;"><%= dup.get("date2") != null ? sdf.format((java.util.Date)dup.get("date2")) : "" %></small>
                                    </td>
                                    <td><%= dup.get("staffName") %></td>
                                    <td>
                                        <span style="color: #b91c1c; font-weight: 700; background: #fee2e2; padding: 2px 6px; border-radius: 4px;">
                                            <%= dup.get("diffMinutes") %> mins apart
                                        </span>
                                    </td>
                                    <td style="text-align: right;">
                                        <% if (canLog) { %>
                                        <a href="<%=ctx%>/discrepancy/create?targetEntity=Collection&targetID=<%= dup.get("req2") %>&type=Duplicate_Collection&severity=High&title=Duplicate+Collection+Recorded+Within+<%= dup.get("diffMinutes") %>m+for+<%= dup.get("binCode") %>" class="btn-log">
                                            <i class="fa-solid fa-flag"></i> Log Discrepancy
                                        </a>
                                        <% } %>
                                    </td>
                                </tr>
                            <%  }
                            } else { %>
                                <tr>
                                    <td colspan="7" style="text-align: center; color: #94a3b8; padding: 20px;">
                                        <i class="fa-solid fa-check" style="color: #10b981;"></i> No duplicate collections detected within 30-minute interval.
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- 2. INCOMPLETE COLLECTIONS -->
            <div class="section-card">
                <div class="section-header">
                    <h3 class="section-title">
                        <i class="fa-solid fa-triangle-exclamation" style="color: #ef4444;"></i>
                        Incomplete Collection Records (Missing Failure Reason or Timestamp)
                    </h3>
                    <span class="badge-count <%= (incompleteCollections != null && !incompleteCollections.isEmpty()) ? "danger" : "" %>">
                        <%= incompleteCollections != null ? incompleteCollections.size() : 0 %> issues
                    </span>
                </div>
                <div style="overflow-x: auto;">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Task ID</th>
                                <th>Bin Code</th>
                                <th>Status</th>
                                <th>Collector Staff</th>
                                <th>Data Omission Issue</th>
                                <th>Created Date</th>
                                <th style="text-align: right;">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (incompleteCollections != null && !incompleteCollections.isEmpty()) {
                                for (Map<String, Object> inc : incompleteCollections) { %>
                                <tr>
                                    <td style="font-family: monospace; font-weight: 700;"><%= inc.get("requestID") %></td>
                                    <td><%= inc.get("binCode") != null ? inc.get("binCode") : inc.get("binID") %></td>
                                    <td>
                                        <span style="font-weight: 700; color: #475569;"><%= inc.get("status") %></span>
                                    </td>
                                    <td><%= inc.get("staffName") != null ? inc.get("staffName") : "Unassigned" %></td>
                                    <td>
                                        <span style="color: #b91c1c; font-weight: 600; background: #fee2e2; padding: 2px 6px; border-radius: 4px;">
                                            <%= inc.get("issueDescription") %>
                                        </span>
                                    </td>
                                    <td style="color: #64748b;">
                                        <%= inc.get("createdDate") != null ? sdf.format((java.util.Date)inc.get("createdDate")) : "" %>
                                    </td>
                                    <td style="text-align: right;">
                                        <% if (canLog) { %>
                                        <a href="<%=ctx%>/discrepancy/create?targetEntity=Collection&targetID=<%= inc.get("requestID") %>&type=Incomplete_Data&severity=Medium&title=<%= inc.get("issueDescription") %>+in+Task+<%= inc.get("requestID") %>" class="btn-log">
                                            <i class="fa-solid fa-flag"></i> Log Discrepancy
                                        </a>
                                        <% } %>
                                    </td>
                                </tr>
                            <%  }
                            } else { %>
                                <tr>
                                    <td colspan="7" style="text-align: center; color: #94a3b8; padding: 20px;">
                                        <i class="fa-solid fa-check" style="color: #10b981;"></i> All collection records contain full timestamps and mandatory failure reasons.
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- 3. SENSOR VS INSPECTION DEVIATIONS -->
            <div class="section-card">
                <div class="section-header">
                    <h3 class="section-title">
                        <i class="fa-solid fa-gauge" style="color: #dc2626;"></i>
                        Telemetry vs Physical Dipstick Deviations (&ge; 20%)
                    </h3>
                    <span class="badge-count <%= (sensorDeviations != null && !sensorDeviations.isEmpty()) ? "danger" : "" %>">
                        <%= sensorDeviations != null ? sensorDeviations.size() : 0 %> issues
                    </span>
                </div>
                <div style="overflow-x: auto;">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Inspection ID</th>
                                <th>Bin Code</th>
                                <th>Area / Zone</th>
                                <th>Sensor Fill</th>
                                <th>Actual Physical Fill</th>
                                <th>Discrepancy (&Delta;)</th>
                                <th>Physical Condition</th>
                                <th>Inspector</th>
                                <th style="text-align: right;">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (sensorDeviations != null && !sensorDeviations.isEmpty()) {
                                for (BinInspection insp : sensorDeviations) { %>
                                <tr>
                                    <td style="font-family: monospace; font-weight: 700;"><%= insp.getInspectionID() %></td>
                                    <td><strong style="color: #0284c7;"><%= insp.getBinCode() %></strong></td>
                                    <td><%= insp.getAreaName() %></td>
                                    <td><%= insp.getSensorFill() %>%</td>
                                    <td><strong><%= insp.getActualFill() %>%</strong></td>
                                    <td>
                                        <span style="font-weight: 800; color: #b91c1c; background: #fee2e2; padding: 2px 6px; border-radius: 4px;">
                                            <%= insp.getDiscrepancy() > 0 ? "+" : "" %><%= insp.getDiscrepancy() %>%
                                        </span>
                                    </td>
                                    <td><%= insp.getPhysicalStatus() %></td>
                                    <td><%= insp.getInspectorName() %></td>
                                    <td style="text-align: right;">
                                        <% if (canLog) { %>
                                        <a href="<%=ctx%>/discrepancy/create?targetEntity=Inspection&targetID=<%= insp.getInspectionID() %>&type=Sensor_Deviation&severity=High&title=Sensor+Telemetry+Deviation+of+<%= insp.getDiscrepancy() %>%+at+<%= insp.getBinCode() %>" class="btn-log">
                                            <i class="fa-solid fa-flag"></i> Log Discrepancy
                                        </a>
                                        <% } %>
                                    </td>
                                </tr>
                            <%  }
                            } else { %>
                                <tr>
                                    <td colspan="9" style="text-align: center; color: #94a3b8; padding: 20px;">
                                        <i class="fa-solid fa-check" style="color: #10b981;"></i> No high sensor telemetry deviations detected.
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- 4. STAFF & DEVICE ANOMALY RANKINGS -->
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 24px;">
                <!-- Staff Rankings -->
                <div class="section-card" style="margin-bottom: 0;">
                    <div class="section-header">
                        <h3 class="section-title">
                            <i class="fa-solid fa-user-xmark" style="color: #f59e0b;"></i>
                            Staff Anomaly &amp; Failure Rates
                        </h3>
                    </div>
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Staff Name</th>
                                <th>Total Tasks</th>
                                <th>Failed / Skipped</th>
                                <th>Duplicate Flags</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (staffRankings != null && !staffRankings.isEmpty()) {
                                for (Map<String, Object> sr : staffRankings) { %>
                                <tr>
                                    <td>
                                        <strong><%= sr.get("fullName") %></strong><br/>
                                        <small style="color: #94a3b8;"><%= sr.get("userID") %></small>
                                    </td>
                                    <td><%= sr.get("totalTasks") %></td>
                                    <td>
                                        <% int failed = (Integer)sr.get("failedTasks"); %>
                                        <span style="<%= failed > 0 ? "color: #b91c1c; font-weight: 700;" : "color: #166534;" %>">
                                            <%= failed %>
                                        </span>
                                    </td>
                                    <td>
                                        <% int dups = (Integer)sr.get("duplicateWarnings"); %>
                                        <span style="<%= dups > 0 ? "color: #b45309; font-weight: 700;" : "color: #64748b;" %>">
                                            <%= dups %>
                                        </span>
                                    </td>
                                </tr>
                            <%  }
                            } %>
                        </tbody>
                    </table>
                </div>

                <!-- Device Rankings -->
                <div class="section-card" style="margin-bottom: 0;">
                    <div class="section-header">
                        <h3 class="section-title">
                            <i class="fa-solid fa-screwdriver-wrench" style="color: #0284c7;"></i>
                            Device Hardware Anomaly &amp; Repair Frequency
                        </h3>
                    </div>
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Device ID</th>
                                <th>Bin Code</th>
                                <th>Status</th>
                                <th>Battery</th>
                                <th>Repair Count</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (deviceRankings != null && !deviceRankings.isEmpty()) {
                                for (Map<String, Object> dr : deviceRankings) { %>
                                <tr>
                                    <td style="font-family: monospace; font-weight: 700;"><%= dr.get("deviceID") %></td>
                                    <td><%= dr.get("binCode") != null ? dr.get("binCode") : "Unassigned" %></td>
                                    <td><%= dr.get("status") %></td>
                                    <td>
                                        <% int bat = (Integer)dr.get("batteryLevel"); %>
                                        <span style="<%= bat < 20 ? "color: #b91c1c; font-weight: 700;" : "color: #166534;" %>">
                                            <%= bat %>%
                                        </span>
                                    </td>
                                    <td>
                                        <% int reps = (Integer)dr.get("repairCount"); %>
                                        <span style="<%= reps >= 2 ? "color: #b45309; font-weight: 700;" : "color: #64748b;" %>">
                                            <%= reps %> repairs
                                        </span>
                                    </td>
                                </tr>
                            <%  }
                            } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- 5. CONFIG AUDIT LOGS -->
            <div class="section-card">
                <div class="section-header">
                    <h3 class="section-title">
                        <i class="fa-solid fa-sliders" style="color: #8b5cf6;"></i>
                        System Threshold &amp; Configuration Modification History
                    </h3>
                    <span class="badge-count info">
                        <%= configLogs != null ? configLogs.size() : 0 %> logs
                    </span>
                </div>
                <div style="overflow-x: auto;">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Timestamp</th>
                                <th>Action</th>
                                <th>Administrator</th>
                                <th>Config Key / Parameter</th>
                                <th>Change Details</th>
                                <th>IP Address</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (configLogs != null && !configLogs.isEmpty()) {
                                for (AuditLog cl : configLogs) { %>
                                <tr>
                                    <td style="color: #64748b; white-space: nowrap;"><%= cl.getFormattedTimestamp() %></td>
                                    <td><span style="font-weight: 700; color: #8b5cf6;"><%= cl.getAction() %></span></td>
                                    <td><%= cl.getUserFullName() != null ? cl.getUserFullName() : cl.getUserID() %></td>
                                    <td><strong style="color: #0284c7;"><%= cl.getRecordID() %></strong></td>
                                    <td style="color: #334155;"><%= cl.getNewValue() != null ? cl.getNewValue() : "-" %></td>
                                    <td style="font-family: monospace; font-size: 11px; color: #94a3b8;"><%= cl.getIpAddress() %></td>
                                </tr>
                            <%  }
                            } else { %>
                                <tr>
                                    <td colspan="6" style="text-align: center; color: #94a3b8; padding: 20px;">
                                        <i class="fa-solid fa-shield" style="color: #10b981;"></i> No threshold configuration changes recorded yet.
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

        </main>
    </div>
</body>
</html>
