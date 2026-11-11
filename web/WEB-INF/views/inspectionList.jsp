<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="model.BinInspection"%>
<%@page import="model.AppUser"%>

<%!
    private String enc(String value) throws Exception {
        return URLEncoder.encode(value == null ? "" : value, "UTF-8");
    }

    private String esc(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }
%>

<%
    String ctx = request.getContextPath();
    List<BinInspection> list = (List<BinInspection>) request.getAttribute("LIST_INSPECTIONS");
    String error = (String) request.getAttribute("ERROR");
    Integer totalCountObj = (Integer) request.getAttribute("TOTAL_COUNT");
    Integer discrepancyCountObj = (Integer) request.getAttribute("DISCREPANCY_COUNT");
    int totalCount = totalCountObj != null ? totalCountObj : (list != null ? list.size() : 0);
    int discrepancyCount = discrepancyCountObj != null ? discrepancyCountObj : 0;

    AppUser currentUser = (AppUser) session.getAttribute("user");
    String role = currentUser != null ? currentUser.getRoleId() : "";
    boolean canCreate = "ADM".equals(role) || "MGR".equals(role) || "SUP".equals(role) || "SAD".equals(role) || "STF".equals(role) || "TEC".equals(role);
    boolean canManage = "ADM".equals(role) || "MGR".equals(role) || "SUP".equals(role) || "SAD".equals(role);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bin Inspections &amp; Sensor Calibration - SmartWaste</title>
    <link rel="stylesheet" href="<%=ctx%>/css/style.css?v=20261017-v4">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        .insp-page {
            margin-left: 0;
            width: 100%;
            min-height: 100vh;
            padding: 34px 40px;
            box-sizing: border-box;
            background: var(--page);
            animation: pageEnter 0.25s ease-out;
        }

        .insp-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 24px;
            flex-wrap: wrap;
            gap: 16px;
        }

        .insp-kicker {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 0.12em;
            text-transform: uppercase;
            color: var(--brand-forest);
            margin-bottom: 6px;
        }

        .insp-title {
            margin: 0;
            font-size: 26px;
            font-weight: 800;
            color: var(--color-slate-900);
            letter-spacing: -0.02em;
        }

        .insp-desc {
            margin: 6px 0 0;
            font-size: 14px;
            color: var(--color-slate-600);
        }

        .insp-actions {
            display: flex;
            gap: 10px;
            align-items: center;
        }

        /* KPI STATS CARDS */
        .kpi-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 16px;
            margin-bottom: 26px;
        }

        .kpi-card {
            background: var(--color-white);
            border: 1px solid var(--border-soft);
            border-radius: 12px;
            padding: 20px 22px;
            display: flex;
            align-items: center;
            gap: 16px;
            box-shadow: var(--shadow-sm);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .kpi-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.04);
        }

        .kpi-icon {
            width: 48px;
            height: 48px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
        }

        .kpi-icon.blue { background: #EFF6FF; color: #2563EB; }
        .kpi-icon.amber { background: #FEF3C7; color: #D97706; }
        .kpi-icon.green { background: var(--color-m0602); color: var(--brand-forest); }

        .kpi-num {
            font-size: 24px;
            font-weight: 800;
            color: var(--color-slate-900);
            line-height: 1.1;
        }

        .kpi-label {
            font-size: 12px;
            font-weight: 600;
            color: var(--color-slate-400);
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-top: 4px;
        }

        /* TABLE CONTAINER */
        .table-card {
            background: var(--color-white);
            border-radius: 12px;
            border: 1px solid var(--border-soft);
            box-shadow: var(--shadow-sm);
            overflow: hidden;
        }

        .table-card-header {
            padding: 18px 24px;
            border-bottom: 1px solid var(--border-soft);
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: var(--color-white);
        }

        .table-card-title {
            margin: 0;
            font-size: 15px;
            font-weight: 700;
            color: var(--color-slate-900);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .table-wrap {
            overflow-x: auto;
        }

        table.insp-table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
            font-size: 13px;
        }

        table.insp-table th {
            padding: 14px 20px;
            background: var(--color-m0571);
            color: var(--color-slate-600);
            font-weight: 700;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            border-bottom: 1px solid var(--border-soft);
        }

        table.insp-table td {
            padding: 16px 20px;
            border-bottom: 1px solid var(--border-soft);
            color: var(--color-slate-900);
            vertical-align: middle;
        }

        table.insp-table tr:last-child td {
            border-bottom: none;
        }

        table.insp-table tr:hover td {
            background: var(--color-m0601);
        }

        .badge-pill {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
        }

        .badge-green { background: #DCFCE7; color: #166534; }
        .badge-red { background: #FEE2E2; color: #991B1B; }
        .badge-amber { background: #FEF3C7; color: #92400E; }
        .badge-slate { background: #F1F5F9; color: #475569; }

        .row-action-btn {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 6px 10px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 600;
            text-decoration: none;
            color: var(--color-slate-600);
            background: #F1F5F9;
            border: 1px solid var(--border-soft);
            transition: all 0.2s ease;
        }

        .row-action-btn:hover {
            background: var(--color-m0602);
            color: var(--brand-forest);
            border-color: var(--color-m0573);
        }

        .row-del-btn {
            padding: 6px 9px;
            border-radius: 6px;
            font-size: 12px;
            color: #DC2626;
            background: #FEE2E2;
            border: 1px solid #FCA5A5;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .row-del-btn:hover {
            background: #DC2626;
            color: #FFFFFF;
        }
    </style>
</head>
<body style="background: var(--page); margin: 0;">

    <div class="app-shell">
        <!-- SIDEBAR NAVIGATION -->
        <jsp:include page="/WEB-INF/views/sidebar.jsp" />

        <!-- MAIN CONTENT AREA -->
        <main class="insp-page">
            
            <!-- HEADER -->
            <header class="insp-header">
                <div style="display: flex; align-items: flex-start; gap: 14px;">
                    <button type="button" class="desktop-nav-toggle" onclick="toggleSidebarCollapse()" title="Toggle Sidebar (Expand / Collapse)" style="margin-top: 4px;">
                        <i class="fa-solid fa-bars"></i>
                    </button>
                    <div>
                        <div class="insp-kicker">
                            <i class="fa-solid fa-clipboard-check"></i>
                            <span>Quality Control &amp; Calibration</span>
                        </div>
                        <h1 class="insp-title">Bin Physical Inspections</h1>
                    </div>
                </div>
                <div class="insp-actions">
                    <% if (canCreate) { %>
                    <a href="<%=ctx%>/inspection/create" class="btn-smart-primary">
                        <i class="fa-solid fa-plus"></i> New Inspection
                    </a>
                    <% } %>
                    <a href="<%=ctx%>/dashboard" class="btn-smart-secondary">
                        <i class="fa-solid fa-arrow-left"></i> Dashboard
                    </a>
                </div>
            </header>

            <% if ("saved".equals(request.getParameter("msg"))) { %>
            <div style="padding: 12px 18px; background: #DCFCE7; border: 1px solid #86EFAC; border-radius: 8px; color: #166534; font-size: 13px; font-weight: 600; margin-bottom: 22px; display: flex; align-items: center; gap: 8px;">
                <i class="fa-solid fa-circle-check"></i>
                <span>Inspection record saved successfully! Corrective tickets were updated accordingly.</span>
            </div>
            <% } %>

            <!-- KPI STATS CARDS -->
            <section class="kpi-grid">
                <div class="kpi-card">
                    <div class="kpi-icon blue"><i class="fa-solid fa-clipboard-list"></i></div>
                    <div>
                        <div class="kpi-num"><%= totalCount %></div>
                        <div class="kpi-label">Audited Inspections</div>
                    </div>
                </div>
                <div class="kpi-card">
                    <div class="kpi-icon amber"><i class="fa-solid fa-triangle-exclamation"></i></div>
                    <div>
                        <div class="kpi-num"><%= discrepancyCount %></div>
                        <div class="kpi-label">Sensor Drift Alerts (&ge;20%)</div>
                    </div>
                </div>
                <div class="kpi-card">
                    <div class="kpi-icon green"><i class="fa-solid fa-satellite-dish"></i></div>
                    <div>
                        <div class="kpi-num"><%= Math.max(0, totalCount - discrepancyCount) %></div>
                        <div class="kpi-label">Accurate Telemetry Matches</div>
                    </div>
                </div>
            </section>

            <!-- INSPECTIONS TABLE CARD -->
            <section class="table-card">
                <div class="table-card-header">
                    <h2 class="table-card-title">
                        <i class="fa-solid fa-list-check" style="color: var(--brand-forest);"></i>
                        Field Inspection Records
                    </h2>
                    <span style="font-size: 12px; color: var(--color-slate-400); font-weight: 600;">
                        <%= list != null ? list.size() : 0 %> records in view
                    </span>
                </div>
                
                <div class="table-wrap">
                    <table class="insp-table">
                        <thead>
                            <tr>
                                <th>Inspection ID</th>
                                <th>Target Bin</th>
                                <th>Inspector</th>
                                <th>Audit Date</th>
                                <th>Actual vs Sensor</th>
                                <th>Discrepancy</th>
                                <th>Condition</th>
                                <th>Action Taken</th>
                                <% if (canManage) { %><th>Actions</th><% } %>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (list != null && !list.isEmpty()) {
                                    for (BinInspection insp : list) {
                                        boolean highDiscrepancy = insp.isHighDiscrepancy();
                                        int disc = insp.getDiscrepancyPercent();
                            %>
                            <tr>
                                <td>
                                    <strong style="color: var(--color-slate-900); font-family: monospace; font-size: 13px;">
                                        <%= esc(insp.getInspectionID()) %>
                                    </strong>
                                </td>
                                <td>
                                    <div style="font-weight: 700; color: var(--color-slate-900);">
                                        <%= esc(insp.getBinCode() != null ? insp.getBinCode() : insp.getBinID()) %>
                                    </div>
                                    <div style="font-size: 11px; color: var(--color-slate-400); margin-top: 2px;">
                                        <%= esc(insp.getLocation()) %> &bull; <%= esc(insp.getAreaName()) %>
                                    </div>
                                </td>
                                <td>
                                    <span style="font-weight: 600;">
                                        <%= esc(insp.getInspectorName() != null ? insp.getInspectorName() : insp.getInspectorID()) %>
                                    </span>
                                </td>
                                <td>
                                    <span style="font-size: 12px; color: var(--color-slate-600);">
                                        <%= insp.getInspectionDate() != null ? insp.getInspectionDate().toString().substring(0, 16) : "" %>
                                    </span>
                                </td>
                                <td>
                                    <div style="font-weight: 700; font-size: 13px;">
                                        Actual: <span style="color: var(--brand-forest);"><%= insp.getActualFillPercent() %>%</span>
                                        <span style="color: var(--color-slate-400); margin: 0 4px;">|</span>
                                        Sensor: <span style="color: #2563EB;"><%= insp.getSensorFillPercent() %>%</span>
                                    </div>
                                </td>
                                <td>
                                    <% if (highDiscrepancy) { %>
                                    <span class="badge-pill badge-red">
                                        <i class="fa-solid fa-triangle-exclamation"></i>
                                        <%= disc > 0 ? "+" + disc : disc %>% (High)
                                    </span>
                                    <% } else { %>
                                    <span class="badge-pill badge-green">
                                        <i class="fa-solid fa-circle-check"></i>
                                        <%= disc > 0 ? "+" + disc : disc %>% (Normal)
                                    </span>
                                    <% } %>
                                </td>
                                <td>
                                    <%
                                        String cond = insp.getPhysicalCondition();
                                        String condClass = "badge-slate";
                                        if ("Good".equalsIgnoreCase(cond)) condClass = "badge-green";
                                        else if ("Damaged".equalsIgnoreCase(cond)) condClass = "badge-red";
                                        else if ("Obstructed".equalsIgnoreCase(cond) || "Sensor Dirty".equalsIgnoreCase(cond)) condClass = "badge-amber";
                                    %>
                                    <span class="badge-pill <%= condClass %>"><%= esc(cond) %></span>
                                </td>
                                <td>
                                    <span style="font-size: 12px; color: var(--color-slate-600);"><%= esc(insp.getActionTaken()) %></span>
                                </td>
                                <% if (canManage) { %>
                                <td>
                                    <div style="display: flex; gap: 6px; align-items: center;">
                                        <a href="<%=ctx%>/inspection/edit?id=<%=enc(insp.getInspectionID())%>" class="row-action-btn" title="Edit Record">
                                            <i class="fa-solid fa-pen"></i> Edit
                                        </a>
                                        <form action="<%=ctx%>/inspection/delete" method="POST" style="margin: 0;" onsubmit="return confirm('Are you sure you want to delete this inspection record?');">
                                            <input type="hidden" name="id" value="<%= esc(insp.getInspectionID()) %>">
                                            <button type="submit" class="row-del-btn" title="Delete inspection">
                                                <i class="fa-solid fa-trash-can"></i>
                                            </button>
                                        </form>
                                    </div>
                                </td>
                                <% } %>
                            </tr>
                            <%
                                    }
                                } else {
                            %>
                            <tr>
                                <td colspan="<%= canManage ? 9 : 8 %>" style="text-align: center; padding: 48px 20px; color: var(--color-slate-400);">
                                    <i class="fa-solid fa-clipboard-check" style="font-size: 36px; color: var(--color-slate-300); margin-bottom: 12px; display: block;"></i>
                                    <strong>No Physical Inspections Found</strong>
                                    <div style="font-size: 12px; margin-top: 4px;">Inspect campus bins to cross-verify physical ground truth with IoT readings.</div>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </section>
        </main>
    </div>

</body>
</html>
