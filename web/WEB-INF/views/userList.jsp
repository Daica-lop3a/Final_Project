<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.AppUser"%>

<%
    List<AppUser> list
            = (List<AppUser>) request.getAttribute("LIST_USER");

    String keyword
            = (String) request.getAttribute("KEYWORD");

    String roleId
            = (String) request.getAttribute("ROLE_ID");

    String error
            = (String) request.getAttribute("ERROR");

    Object totalRecordsValue
            = request.getAttribute("PAGINATION_TOTAL_RECORDS");

    int totalRecords = totalRecordsValue instanceof Number
            ? ((Number) totalRecordsValue).intValue()
            : (list == null ? 0 : list.size());

    String statusFilter
            = (String) request.getAttribute("STATUS_FILTER");

    if (keyword == null) {
        keyword = "";
    }

    if (roleId == null) {
        roleId = "";
    }

    if (statusFilter == null) {
        statusFilter = "";
    }

    String ctx = request.getContextPath();
    AppUser sessionUser = (AppUser) session.getAttribute("user");
    boolean isSessionSuperAdmin = sessionUser != null && sessionUser.isSuperAdmin();
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <title>User Management</title>

        <link rel="stylesheet" href="<%=ctx%>/css/style.css?v=20261017-v4">

        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            }

            .user-page {
                margin-left: 0;
                width: 100%;
                min-height: 100vh;
                padding: 30px 36px;
                box-sizing: border-box;
                background: #EDF8F2;
            }

            .user-header {
                width: 100%;
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

            .header-actions {
                display: flex;
                gap: 8px;
                flex-wrap: wrap;
            }

            .user-btn {
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
                transition: 0.15s ease;
                box-sizing: border-box;
            }

            .user-btn-primary {
                color: #FFFFFF !important;
                background: #00875A !important;
                border-color: #00875A !important;
                box-shadow: none !important;
            }

            .user-btn-primary:hover {
                background: #006644 !important;
                border-color: #006644 !important;
            }

            .user-btn-light {
                color: #050505 !important;
                background: #FFFFFF !important;
                border: 1px solid #D1EBCF !important;
            }

            .user-btn-light:hover {
                border-color: #D1EBCF !important;
                background: #EDF8F2 !important;
                color: #050505 !important;
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

            .filter-form {
                display: grid;
                grid-template-columns: minmax(220px, 1.5fr)
                    minmax(180px, 1fr)
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

            .user-table-wrapper {
                width: 100%;
                overflow-x: auto;
            }

            .user-table {
                width: 100%;
                min-width: 1000px;
                border-collapse: collapse;
            }

            .user-table th {
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

            .user-table td {
                padding: 15px 18px;
                border-bottom: 1px solid var(--border);
                color: var(--text);
                font-size: 13px;
                vertical-align: middle;
            }

            .user-table tbody tr:hover {
                background: var(--green-pale);
            }

            .user-table tbody tr:last-child td {
                border-bottom: 0;
            }

            .user-id {
                color: #050505;
                font-weight: 600;
                font-family: monospace;
                font-size: 13px;
            }

            .user-name {
                font-weight: 600;
                color: #050505;
            }

            .user-email,
            .user-phone {
                color: #65676B;
            }

            .user-phone {
                white-space: nowrap;
            }

            /* Clean Neutral Facebook Role Badge (Zero rainbow colors) */
            .role-badge {
                display: inline-flex;
                align-items: center;
                padding: 3px 8px;
                border-radius: 4px;
                color: #1C1E21;
                background: #EDF8F2;
                border: 1px solid #D1EBCF;
                font-size: 12px;
                font-weight: 600;
                white-space: nowrap;
            }

            /* Clean Facebook Minimalist Dot Status Indicator */
            .status-indicator {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                font-size: 12.5px;
                font-weight: 600;
                color: #1C1E21;
                white-space: nowrap;
            }

            .status-dot {
                width: 7px;
                height: 7px;
                border-radius: 50%;
                display: inline-block;
                flex-shrink: 0;
            }

            .dot-active {
                background: #31A24C;
            }

            .dot-locked {
                background: #DC2626;
            }

            .action-cell {
                white-space: nowrap;
            }

            .action-form {
                display: inline;
                margin: 0;
            }

            .action-link {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                min-height: 30px;
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
                border-color: #D1EBCF;
                background: #EDF8F2;
                color: #050505;
            }

            .action-link i {
                color: #65676B;
                font-size: 12px;
            }

            .action-link:hover i {
                color: #00875A;
            }

            .action-lock:hover {
                background: #FEE2E2 !important;
                border-color: #DC2626 !important;
                color: #DC2626 !important;
            }

            .action-lock:hover i {
                color: #DC2626 !important;
            }

            .action-delete:hover {
                background: #FEE2E2 !important;
                border-color: #DC2626 !important;
                color: #DC2626 !important;
            }

            .action-delete:hover i {
                color: #DC2626 !important;
            }

            .empty-state {
                padding: 55px 20px !important;
                text-align: center;
                color: #65676B !important;
            }

            .empty-icon {
                width: 52px;
                height: 52px;
                margin: 0 auto 12px;
                display: grid;
                place-items: center;
                border-radius: 15px;
                color: #00875A;
                background: #DCF2E4;
                font-size: 22px;
            }

            .empty-title {
                display: block;
                margin-bottom: 4px;
                color: #050505;
                font-size: 14px;
                font-weight: 800;
            }

            .pagination-container {
                padding: 0 22px 20px;
            }

            /* =========================================
               RESPONSIVE MOBILE OVERFLOW PREVENTION
               ========================================= */
            @media (max-width: 1024px) {
                .filter-form {
                    grid-template-columns: 1fr 1fr;
                }

                .filter-actions {
                    grid-column: 1 / -1;
                }
            }

            @media (max-width: 768px) {
                .user-page {
                    margin-left: 0 !important;
                    width: 100% !important;
                    max-width: 100vw !important;
                    padding: 14px 10px 40px !important;
                    box-sizing: border-box !important;
                    overflow-x: hidden !important;
                }

                .user-header {
                    flex-direction: column !important;
                    align-items: stretch !important;
                    gap: 12px !important;
                    margin-bottom: 16px !important;
                }

                .page-title {
                    font-size: 22px !important;
                }

                .header-actions {
                    width: 100% !important;
                    display: flex !important;
                    flex-direction: column !important;
                    gap: 8px !important;
                }

                .header-actions .user-btn {
                    width: 100% !important;
                    justify-content: center !important;
                }

                .filter-panel {
                    padding: 14px !important;
                    margin-bottom: 14px !important;
                    border-radius: 8px !important;
                    width: 100% !important;
                    box-sizing: border-box !important;
                }

                .filter-form {
                    display: flex !important;
                    flex-direction: column !important;
                    width: 100% !important;
                    gap: 10px !important;
                }

                .filter-field {
                    width: 100% !important;
                }

                .filter-actions {
                    width: 100% !important;
                    display: flex !important;
                    gap: 8px !important;
                }

                .filter-actions .user-btn {
                    flex: 1 !important;
                    justify-content: center !important;
                }

                .table-panel {
                    border-radius: 8px !important;
                    width: 100% !important;
                    max-width: 100% !important;
                    overflow: hidden !important;
                }

                .table-header {
                    padding: 14px !important;
                }

                .user-table-wrapper {
                    width: 100% !important;
                    max-width: 100% !important;
                    overflow-x: auto !important;
                    -webkit-overflow-scrolling: touch !important;
                    display: block !important;
                }

                .user-table {
                    min-width: 720px !important;
                }

                .user-table th,
                .user-table td {
                    padding: 10px 10px !important;
                    font-size: 12px !important;
                }

                .action-link {
                    min-height: 28px !important;
                    padding: 0 8px !important;
                    font-size: 11.5px !important;
                    margin-right: 3px !important;
                }

                .pagination-container {
                    padding: 0 10px 14px !important;
                }
            }
        </style>
    </head>

    <body>
        <div class="app-shell">

            <jsp:include page="sidebar.jsp" />

            <main class="user-page">

                <section class="user-header">
                    <div style="display: flex; align-items: flex-start; gap: 14px;">
                        <button type="button" class="desktop-nav-toggle" onclick="toggleSidebarCollapse()" title="Toggle Sidebar (Expand / Collapse)" style="margin-top: 4px;">
                            <i class="fa-solid fa-bars"></i>
                        </button>
                        <div>
                            <span class="page-kicker">MANAGEMENT</span>

                            <h1 class="page-title">User Management</h1>
                        </div>
                    </div>

                    <div class="header-actions">
                        <% if (sessionUser != null && !sessionUser.isAuditor()) { %>
                        <a class="user-btn user-btn-primary"
                           href="<%=ctx%>/user/create">
                            <i class="fa-solid fa-user-plus"></i>
                            Add User
                        </a>
                        <% } %>

                        <a class="user-btn user-btn-light"
                           href="<%=ctx%>/dashboard">
                            <i class="fa-solid fa-house"></i>
                            Dashboard
                        </a>
                    </div>
                </section>

                <section class="filter-panel">
                    <div class="filter-header">
                        <h2 class="filter-title">User Search</h2>

                        <p class="filter-subtitle">
                            Search users by name, email, phone or role.
                        </p>
                    </div>

                    <form class="filter-form"
                          action="<%=ctx%>/user"
                          method="GET">

                        <div class="filter-field">
                            <label class="filter-label" for="keyword">
                                Keyword
                            </label>

                            <input class="filter-input"
                                   type="text"
                                   id="keyword"
                                   name="keyword"
                                   placeholder="Search user..."
                                   value="<%=keyword%>">
                        </div>

                        <div class="filter-field">
                            <label class="filter-label" for="roleId">
                                Role
                            </label>

                            <select class="filter-select"
                                    id="roleId"
                                    name="roleId">

                                <option value="">All Roles</option>
                                <% if (isSessionSuperAdmin) { %>
                                <option value="SAD" <%="SAD".equals(roleId) ? "selected" : ""%>>Super Admin</option>
                                <% } %>
                                <option value="ADM" <%="ADM".equals(roleId) ? "selected" : ""%>>System Admin</option>
                                <option value="MGR" <%="MGR".equals(roleId) ? "selected" : ""%>>Operations Manager</option>
                                <option value="SUP" <%="SUP".equals(roleId) ? "selected" : ""%>>Area Supervisor</option>
                                <option value="STF" <%="STF".equals(roleId) ? "selected" : ""%>>Collection Staff</option>
                                <option value="TEC" <%="TEC".equals(roleId) ? "selected" : ""%>>Technician</option>
                                <option value="AUD" <%="AUD".equals(roleId) ? "selected" : ""%>>Auditor</option>
                                <option value="USR" <%="USR".equals(roleId) ? "selected" : ""%>>Citizen User</option>
                            </select>
                        </div>

                        <div class="filter-field">
                            <label class="filter-label" for="status">
                                Account Status
                            </label>

                            <select class="filter-select"
                                    id="status"
                                    name="status">

                                <option value="">All Statuses</option>
                                <option value="active" <%="active".equalsIgnoreCase(statusFilter) ? "selected" : ""%>>Active Accounts</option>
                                <option value="inactive" <%="inactive".equalsIgnoreCase(statusFilter) ? "selected" : ""%>>Inactive / Deactivation Risk</option>
                            </select>
                        </div>

                        <div class="filter-actions">
                            <button type="submit"
                                    class="user-btn user-btn-primary">
                                <i class="fa-solid fa-magnifying-glass"></i>
                                Search
                            </button>

                            <a href="<%=ctx%>/user"
                               class="user-btn user-btn-light">
                                <i class="fa-solid fa-rotate-left"></i>
                                Reset
                            </a>
                        </div>
                    </form>
                </section>

                <% if (error != null && !error.trim().isEmpty()) {%>
                <div class="error-box">
                    <i class="fa-solid fa-circle-exclamation"></i>
                    <%=error%>
                </div>
                <% }%>

                <section class="table-panel">

                    <div class="table-header">
                        <h2 class="table-title">System Users</h2>

                        <span class="record-count">
                            <%=totalRecords%> users
                        </span>
                    </div>

                    <div class="user-table-wrapper">
                        <table class="user-table">

                            <thead>
                                <tr>
                                    <th>User ID</th>
                                    <th>Full Name</th>
                                    <th>Email</th>
                                    <th>Phone</th>
                                    <th>Role</th>
                                    <th>Status</th>
                                    <th>Action</th>
                                </tr>
                            </thead>

                            <tbody>
                                <% if (list != null && !list.isEmpty()) {
                                        for (AppUser user : list) {
                                            String userRole = user.getRoleId();

                                            if (userRole == null) {
                                                userRole = "";
                                            }

                                            String roleClass = "role-" + userRole;
                                %>
                                <tr>
                                    <td>
                                        <span class="user-id">
                                            <%=user.getUserId()%>
                                        </span>
                                    </td>

                                    <td>
                                        <span class="user-name">
                                            <%=user.getFullName()%>
                                        </span>
                                    </td>

                                    <td>
                                        <span class="user-email">
                                            <%=user.getEmail()%>
                                        </span>
                                    </td>

                                    <td>
                                        <span class="user-phone">
                                            <%=user.getPhoneNumber()%>
                                        </span>
                                    </td>

                                    <td>
                                        <span class="role-badge">
                                            <%=user.getRoleName()%>
                                        </span>
                                    </td>

                                    <td>
                                        <% if (user.isStatus()) { %>
                                        <span class="status-indicator">
                                            <span class="status-dot dot-active"></span>
                                            Active
                                        </span>
                                        <% } else { %>
                                        <span class="status-indicator">
                                            <span class="status-dot dot-locked"></span>
                                            Locked
                                        </span>
                                        <% }%>
                                    </td>

                                    <td class="action-cell">

                                        <a class="action-link action-view"
                                           href="<%=ctx%>/user/view?id=<%=user.getUserId()%>">
                                            <i class="fa-solid fa-eye"></i>
                                            View
                                        </a>

                                        <%
                                            AppUser currentUser = (AppUser) session.getAttribute("user");
                                            boolean canManage = true;
                                            if (currentUser != null && currentUser.isAuditor()) {
                                                canManage = false;
                                            } else if (currentUser != null && currentUser.isAdmin()) {
                                                if (user.isSuperAdmin() || user.isAdmin()) {
                                                    canManage = false;
                                                }
                                            }
                                        %>

                                        <% if (canManage) { %>
                                        <a class="action-link action-edit"
                                           href="<%=ctx%>/user/edit?id=<%=user.getUserId()%>">
                                            <i class="fa-solid fa-pen"></i>
                                            Edit
                                        </a>

                                        <form class="action-form"
                                               action="<%=ctx%>/user/lock"
                                               method="POST">

                                            <input type="hidden"
                                                   name="id"
                                                   value="<%=user.getUserId()%>">

                                            <button type="submit"
                                                     class="action-link action-lock">

                                                <% if (user.isStatus()) { %>
                                                <i class="fa-solid fa-lock"></i>
                                                Lock
                                                <% } else { %>
                                                <i class="fa-solid fa-lock-open"></i>
                                                Unlock
                                                <% }%>
                                            </button>
                                        </form>

                                        <form class="action-form"
                                               action="<%=ctx%>/user/reset"
                                               method="POST"
                                               onsubmit="return confirm('Reset password for this user?');">

                                            <input type="hidden"
                                                   name="id"
                                                   value="<%=user.getUserId()%>">

                                            <button type="submit"
                                                     class="action-link action-reset">
                                                <i class="fa-solid fa-key"></i>
                                                Reset
                                            </button>
                                        </form>

                                        <form class="action-form"
                                               action="<%=ctx%>/user/delete"
                                               method="POST"
                                               onsubmit="return confirm('Are you sure you want to delete this user?');">

                                            <input type="hidden"
                                                   name="id"
                                                   value="<%=user.getUserId()%>">

                                            <button type="submit"
                                                     class="action-link action-delete">
                                                <i class="fa-solid fa-trash-can"></i>
                                                Delete
                                            </button>
                                        </form>
                                        <% } else { %>
                                        <span class="badge" style="background: #f1f5f9; color: #64748b; font-size: 11px; padding: 4px 8px; border-radius: 6px; border: 1px solid #cbd5e1; display: inline-flex; align-items: center; gap: 4px;">
                                            <i class="fa-solid fa-shield"></i> Protected
                                        </span>
                                        <% } %>

                                    </td>
                                </tr>
                                <%
                                    }
                                } else {
                                %>
                                <tr>
                                    <td colspan="7" class="empty-state">
                                        <div class="empty-icon">
                                            <i class="fa-solid fa-users-slash"></i>
                                        </div>

                                        <span class="empty-title">
                                            No users found
                                        </span>

                                        Try changing your search or role filter.
                                    </td>
                                </tr>
                                <% }%>
                            </tbody>

                        </table>
                    </div>

                    <%-- Shared pagination component --%>
                    <div class="pagination-container">
                        <jsp:include page="/WEB-INF/views/common/pagination.jsp" />
                    </div>

                </section>

            </main>
        </div>
    </body>
</html>