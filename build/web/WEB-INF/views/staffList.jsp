<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.net.URLEncoder"%>
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
    List<AppUser> list = (List<AppUser>) request.getAttribute("LIST_STAFF");
    Map<String, Integer> activeTasksMap = (Map<String, Integer>) request.getAttribute("ACTIVE_TASKS_MAP");
    Map<String, Integer> completedTasksMap = (Map<String, Integer>) request.getAttribute("COMPLETED_TASKS_MAP");
    String search = (String) request.getAttribute("SEARCH");
    if (search == null) search = "";

    AppUser currentUser = (AppUser) session.getAttribute("user");
    String role = currentUser != null ? currentUser.getRoleId() : "";
    boolean isSupervisor = "SUP".equals(role);
    boolean isAdminOrMgr = "ADM".equals(role) || "MGR".equals(role) || "SAD".equals(role);

    int totalStaff = list != null ? list.size() : 0;
    int totalActiveTasks = 0;
    int activeStaffCount = 0;
    if (list != null) {
        for (AppUser u : list) {
            if (u.isStatus()) activeStaffCount++;
            if (activeTasksMap != null && activeTasksMap.containsKey(u.getUserId())) {
                totalActiveTasks += activeTasksMap.get(u.getUserId());
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Area Field Staff - SmartWaste</title>
    <link rel="stylesheet" href="<%=ctx%>/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        .staff-page {
            margin-left: 0;
            width: 100%;
            min-height: 100vh;
            padding: 34px 40px;
            box-sizing: border-box;
            background: var(--page);
            animation: pageEnter 0.25s ease-out;
        }

        .staff-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 24px;
            flex-wrap: wrap;
            gap: 16px;
        }

        .staff-kicker {
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

        .staff-title {
            margin: 0;
            font-size: 26px;
            font-weight: 800;
            color: var(--color-slate-900);
            letter-spacing: -0.02em;
        }

        .staff-desc {
            margin: 6px 0 0;
            font-size: 14px;
            color: var(--color-slate-600);
        }

        /* KPI STATS CARDS */
        .kpi-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 16px;
            margin-bottom: 24px;
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
        .kpi-icon.green { background: var(--color-m0602); color: var(--brand-forest); }
        .kpi-icon.amber { background: #FEF3C7; color: #D97706; }

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

        /* FILTER BAR */
        .filter-panel {
            background: var(--color-white);
            padding: 16px 20px;
            border-radius: 12px;
            border: 1px solid var(--border-soft);
            margin-bottom: 22px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: var(--shadow-sm);
            flex-wrap: wrap;
            gap: 12px;
        }

        .search-form {
            display: flex;
            gap: 10px;
            align-items: center;
            flex: 1;
            max-width: 440px;
        }

        .search-field {
            flex: 1;
            height: 40px;
            padding: 0 14px;
            border: 1px solid var(--border-soft);
            border-radius: 8px;
            font-size: 13px;
            background: var(--color-m0571);
            color: var(--color-slate-900);
            outline: none;
            transition: all 0.2s ease;
        }

        .search-field:focus {
            background: var(--color-white);
            border-color: var(--brand-forest);
            box-shadow: 0 0 0 3px var(--color-m0602);
        }

        /* TABLE CARD */
        .table-card {
            background: var(--color-white);
            border-radius: 12px;
            border: 1px solid var(--border-soft);
            box-shadow: var(--shadow-sm);
            overflow: hidden;
        }

        .table-wrap {
            overflow-x: auto;
        }

        table.staff-table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
            font-size: 13px;
        }

        table.staff-table th {
            padding: 14px 20px;
            background: var(--color-m0571);
            color: var(--color-slate-600);
            font-weight: 700;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            border-bottom: 1px solid var(--border-soft);
        }

        table.staff-table td {
            padding: 16px 20px;
            border-bottom: 1px solid var(--border-soft);
            color: var(--color-slate-900);
            vertical-align: middle;
        }

        table.staff-table tr:last-child td {
            border-bottom: none;
        }

        table.staff-table tr:hover td {
            background: var(--color-m0601);
        }

        .badge-pill {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 600;
            background: #EDF8F2;
            color: #1C1E21;
            border: 1px solid #D1EBCF;
        }

        .badge-active { background: #F0FDF4; color: #166534; border: 1px solid #BBF7D0; }
        .badge-inactive { background: #FEF2F2; color: #991B1B; border: 1px solid #FECACA; }

        .workload-idle { background: #EDF8F2; color: #1C1E21; border: 1px solid #D1EBCF; }
        .workload-busy { background: #FFFBEB; color: #92400E; border: 1px solid #FDE68A; }
        .workload-heavy { background: #FEF2F2; color: #991B1B; border: 1px solid #FECACA; }

        .row-action-link {
            padding: 6px 12px;
            font-size: 12px;
            border-radius: 6px;
            text-decoration: none;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 5px;
            border: 1px solid var(--border-soft);
            background: var(--color-white);
            color: var(--color-slate-600);
            transition: all 0.2s ease;
        }

        .row-action-link:hover {
            background: var(--color-m0602);
            color: var(--brand-forest);
            border-color: var(--color-m0573);
        }
    </style>
</head>
<body style="background: var(--page); margin: 0;">

    <div class="app-shell">
        <!-- SIDEBAR NAVIGATION -->
        <jsp:include page="/WEB-INF/views/sidebar.jsp" />

        <!-- MAIN CONTENT -->
        <main class="staff-page">
            
            <!-- HEADER -->
            <header class="staff-header">
                <div>
                    <div class="staff-kicker">
                        <i class="fa-solid fa-users-gear"></i>
                        <span>Field Operations Personnel</span>
                    </div>
                    <h1 class="staff-title">Area Field Staff Directory</h1>
                </div>
                <div style="display: flex; gap: 10px;">
                    <a href="<%=ctx%>/collection/create" class="btn-smart-primary">
                        <i class="fa-solid fa-plus"></i> Dispatch Task
                    </a>
                    <a href="<%=ctx%>/dashboard" class="btn-smart-secondary">
                        <i class="fa-solid fa-arrow-left"></i> Dashboard
                    </a>
                </div>
            </header>

            <!-- KPI METRICS -->
            <section class="kpi-grid">
                <div class="kpi-card">
                    <div class="kpi-icon blue"><i class="fa-solid fa-users"></i></div>
                    <div>
                        <div class="kpi-num"><%= totalStaff %></div>
                        <div class="kpi-label">Assigned Field Staff</div>
                    </div>
                </div>
                <div class="kpi-card">
                    <div class="kpi-icon green"><i class="fa-solid fa-user-check"></i></div>
                    <div>
                        <div class="kpi-num"><%= activeStaffCount %></div>
                        <div class="kpi-label">Active &amp; Available</div>
                    </div>
                </div>
                <div class="kpi-card">
                    <div class="kpi-icon amber"><i class="fa-solid fa-truck-ramp-box"></i></div>
                    <div>
                        <div class="kpi-num"><%= totalActiveTasks %></div>
                        <div class="kpi-label">Active Collection Tasks</div>
                    </div>
                </div>
            </section>

            <!-- SEARCH FILTER -->
            <div class="filter-panel">
                <form action="<%=ctx%>/staff" method="GET" class="search-form">
                    <input type="text" name="search" class="search-field" value="<%= esc(search) %>" placeholder="Search staff by name, email or ID...">
                    <button type="submit" class="btn-smart-secondary" style="padding: 0 16px; height: 40px;">
                        <i class="fa-solid fa-magnifying-glass"></i> Search
                    </button>
                    <% if (search != null && !search.trim().isEmpty()) { %>
                    <a href="<%=ctx%>/staff" class="btn-smart-secondary" style="padding: 0 12px; height: 40px; display: inline-flex; align-items: center;" title="Clear Search">
                        <i class="fa-solid fa-xmark"></i>
                    </a>
                    <% } %>
                </form>
                <span style="font-size: 13px; color: var(--color-slate-400); font-weight: 600;">
                    Showing <%= totalStaff %> field personnel
                </span>
            </div>

            <!-- TABLE -->
            <section class="table-card">
                <div class="table-wrap">
                    <table class="staff-table">
                        <thead>
                            <tr>
                                <th>Staff Member</th>
                                <th>Contact Information</th>
                                <th>Designated Area</th>
                                <th>Account Status</th>
                                <th>Current Tasks</th>
                                <th>Completed History</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (list != null && !list.isEmpty()) {
                                    for (AppUser u : list) {
                                        int activeTasks = (activeTasksMap != null && activeTasksMap.containsKey(u.getUserId()))
                                                ? activeTasksMap.get(u.getUserId()) : 0;
                                        int completedTasks = (completedTasksMap != null && completedTasksMap.containsKey(u.getUserId()))
                                                ? completedTasksMap.get(u.getUserId()) : 0;

                                        String workloadClass = "workload-idle";
                                        String workloadText = "Available (Idle)";
                                        if (activeTasks >= 3) {
                                            workloadClass = "workload-heavy";
                                            workloadText = activeTasks + " Tasks (Heavy)";
                                        } else if (activeTasks > 0) {
                                            workloadClass = "workload-busy";
                                            workloadText = activeTasks + " In Progress";
                                        }
                            %>
                            <tr>
                                <td>
                                    <div style="font-weight: 700; color: var(--color-slate-900);">
                                        <%= esc(u.getFullName()) %>
                                    </div>
                                    <div style="font-size: 11px; color: var(--color-slate-400); font-family: monospace; margin-top: 2px;">
                                        <%= esc(u.getUserId()) %>
                                    </div>
                                </td>
                                <td>
                                    <div style="font-size: 13px; color: var(--color-slate-900);">
                                        <i class="fa-solid fa-envelope" style="color: var(--color-slate-400); font-size: 11px; margin-right: 4px;"></i>
                                        <%= esc(u.getEmail()) %>
                                    </div>
                                    <div style="font-size: 11px; color: var(--color-slate-400); margin-top: 2px;">
                                        <i class="fa-solid fa-phone" style="font-size: 10px; margin-right: 4px;"></i>
                                        <%= esc(u.getPhoneNumber() != null ? u.getPhoneNumber() : "None") %>
                                    </div>
                                </td>
                                <td>
                                    <% if (u.getAreaName() != null && !u.getAreaName().trim().isEmpty()) { %>
                                    <span style="font-weight: 600; color: var(--color-slate-900);">
                                        <i class="fa-solid fa-location-dot" style="color: var(--brand-forest); margin-right: 4px;"></i>
                                        <%= esc(u.getAreaName()) %>
                                    </span>
                                    <% } else { %>
                                    <span style="color: var(--color-slate-400); font-style: italic;">Unassigned</span>
                                    <% } %>
                                </td>
                                <td>
                                    <% if (u.isStatus()) { %>
                                    <span class="badge-pill badge-active">
                                        <i class="fa-solid fa-circle-check"></i> Active
                                    </span>
                                    <% } else { %>
                                    <span class="badge-pill badge-inactive">
                                        <i class="fa-solid fa-circle-xmark"></i> Inactive
                                    </span>
                                    <% } %>
                                </td>
                                <td>
                                    <span class="badge-pill <%= workloadClass %>">
                                        <%= workloadText %>
                                    </span>
                                </td>
                                <td>
                                    <strong style="color: var(--brand-forest); font-size: 14px;">
                                        <%= completedTasks %>
                                    </strong>
                                    <span style="font-size: 11px; color: var(--color-slate-400);"> jobs done</span>
                                </td>
                                <td>
                                    <div style="display: flex; gap: 6px;">
                                        <a href="<%=ctx%>/collection?keyword=<%=enc(u.getUserId())%>" class="row-action-link" title="View Assigned Tasks">
                                            <i class="fa-solid fa-list-check"></i> Tasks
                                        </a>
                                        <% if ("ADM".equals(role) || "SAD".equals(role)) { %>
                                        <a href="<%=ctx%>/user/edit?id=<%=enc(u.getUserId())%>" class="row-action-link" title="Edit Profile &amp; Area Assignment">
                                            <i class="fa-solid fa-user-pen"></i> Manage
                                        </a>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                            <%
                                    }
                                } else {
                            %>
                            <tr>
                                <td colspan="7" style="text-align: center; padding: 48px 20px; color: var(--color-slate-400);">
                                    <i class="fa-solid fa-users" style="font-size: 36px; color: var(--color-slate-300); margin-bottom: 12px; display: block;"></i>
                                    <strong>No Field Staff Found</strong>
                                    <div style="font-size: 12px; margin-top: 4px;">Try searching with a different keyword or assign staff to this Area.</div>
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
