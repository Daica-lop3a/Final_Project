<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Audit Logs & Compliance Trail - SmartWaste</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=20261017-v4" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css?v=20261017-v4" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        .badge-action {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 700;
            background: #e2e8f0;
            color: #334155;
            font-family: monospace;
        }
        .action-login { background: #e0f2fe; color: #0369a1; }
        .action-create { background: #dcfce7; color: #15803d; }
        .action-update { background: #fef3c7; color: #b45309; }
        .action-delete { background: #fee2e2; color: #b91c1c; }
    </style>
</head>
<body>
    <div class="app-layout">
        <jsp:include page="/WEB-INF/views/sidebar.jsp" />

        <div class="main-content">
            <div class="content-header" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <div style="display: flex; align-items: flex-start; gap: 14px;">
                    <button type="button" class="desktop-nav-toggle" onclick="toggleSidebarCollapse()" title="Toggle Sidebar (Expand / Collapse)" style="margin-top: 4px;">
                        <i class="fa-solid fa-bars"></i>
                    </button>
                    <div>
                        <h1 style="font-size: 22px; margin: 0; color: #1e293b;">
                            <i class="fa-solid fa-shield-halved" style="color: #6366f1; margin-right: 8px;"></i>
                            System Audit Logs & Security Trail
                        </h1>
                    </div>
                </div>
                <div>
                    <button type="button" onclick="openExportModal('audit')" class="btn" style="padding: 8px 16px; border: 1px solid #cbd5e1; border-radius: 6px; color: #334155; font-size: 13px; font-weight: 600; background: white; cursor: pointer; display: inline-flex; align-items: center; gap: 6px;">
                        <i class="fa-solid fa-file-csv" style="color: #10b981;"></i> Export CSV Audit Trail
                    </button>
                </div>
            </div>

            <!-- Search & Filter Form -->
            <form action="${pageContext.request.contextPath}/audit-log" method="GET" style="display: flex; gap: 15px; margin-bottom: 20px; background: white; padding: 14px 18px; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); align-items: flex-end;">
                <div>
                    <label style="font-size: 12px; font-weight: 600; color: #475569; display: block; margin-bottom: 4px;">Action:</label>
                    <select name="action" style="padding: 7px 12px; border-radius: 6px; border: 1px solid #cbd5e1; font-size: 13px;">
                        <option value="">-- All Actions --</option>
                        <option value="LOGIN" ${selectedAction == 'LOGIN' ? 'selected' : ''}>LOGIN</option>
                        <option value="LOGOUT" ${selectedAction == 'LOGOUT' ? 'selected' : ''}>LOGOUT</option>
                        <option value="CREATE_BIN" ${selectedAction == 'CREATE_BIN' ? 'selected' : ''}>CREATE_BIN</option>
                        <option value="UPDATE_BIN" ${selectedAction == 'UPDATE_BIN' ? 'selected' : ''}>UPDATE_BIN</option>
                        <option value="DISPATCH_TASK" ${selectedAction == 'DISPATCH_TASK' ? 'selected' : ''}>DISPATCH_TASK</option>
                        <option value="VERIFY_REPORT" ${selectedAction == 'VERIFY_REPORT' ? 'selected' : ''}>VERIFY_REPORT</option>
                        <option value="MAINTENANCE_UPDATE" ${selectedAction == 'MAINTENANCE_UPDATE' ? 'selected' : ''}>MAINTENANCE_UPDATE</option>
                    </select>
                </div>
                <div style="flex: 1;">
                    <label style="font-size: 12px; font-weight: 600; color: #475569; display: block; margin-bottom: 4px;">User (UserID / Name):</label>
                    <input type="text" name="user" value="${selectedUser}" placeholder="Search by username or full name..." style="width: 100%; padding: 7px 12px; border-radius: 6px; border: 1px solid #cbd5e1; font-size: 13px; box-sizing: border-box;" />
                </div>
                <button type="submit" style="padding: 7px 16px; background: #6366f1; color: white; border: none; border-radius: 6px; font-size: 13px; font-weight: 600; cursor: pointer;">
                    <i class="fa-solid fa-magnifying-glass"></i> Filter
                </button>
            </form>

            <!-- Audit Logs Table -->
            <div style="background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.05);">
                <table style="width: 100%; border-collapse: collapse; text-align: left; font-size: 13px;">
                    <thead>
                        <tr style="background: #f8fafc; border-bottom: 1px solid #e2e8f0; color: #475569;">
                            <th style="padding: 12px 14px;">Timestamp</th>
                            <th style="padding: 12px 14px;">User</th>
                            <th style="padding: 12px 14px;">Role</th>
                            <th style="padding: 12px 14px;">Action</th>
                            <th style="padding: 12px 14px;">Target Table</th>
                            <th style="padding: 12px 14px;">Record ID</th>
                            <th style="padding: 12px 14px;">Change Details</th>
                            <th style="padding: 12px 14px;">IP Address</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty logs}">
                                <tr>
                                    <td colspan="8" style="padding: 30px; text-align: center; color: #94a3b8;">
                                        No matching audit log records found.
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="l" items="${logs}">
                                    <tr style="border-bottom: 1px solid #f1f5f9;">
                                        <td style="padding: 12px 14px; color: #64748b; white-space: nowrap;">
                                            <fmt:formatDate value="${l.timestamp}" pattern="yyyy-MM-dd HH:mm:ss"/>
                                        </td>
                                        <td style="padding: 12px 14px; font-weight: 600; color: #1e293b;">
                                            ${l.userFullName != null ? l.userFullName : l.userID}
                                        </td>
                                        <td style="padding: 12px 14px;">
                                            <span style="font-size: 11px; padding: 2px 6px; background: #e2e8f0; border-radius: 4px; font-weight: 600;">
                                                ${l.userRole != null ? l.userRole : 'SYSTEM'}
                                            </span>
                                        </td>
                                        <td style="padding: 12px 14px;">
                                            <span class="badge-action ${l.action.startsWith('CREATE') ? 'action-create' : (l.action.startsWith('UPDATE') || l.action.startsWith('VERIFY') ? 'action-update' : (l.action == 'LOGIN' ? 'action-login' : ''))}">
                                                ${l.action}
                                            </span>
                                        </td>
                                        <td style="padding: 12px 14px; color: #64748b; font-family: monospace;">${l.tableName}</td>
                                        <td style="padding: 12px 14px; font-weight: 600; color: #2563eb;">${l.recordID}</td>
                                        <td style="padding: 12px 14px; max-width: 250px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="${l.newValue}">
                                            <c:if test="${not empty l.oldValue}">
                                                <span style="color: #ef4444; text-decoration: line-through;">${l.oldValue}</span> &rarr;
                                            </c:if>
                                            <span style="color: #059669;">${l.newValue}</span>
                                        </td>
                                        <td style="padding: 12px 14px; color: #94a3b8; font-family: monospace;">${l.ipAddress}</td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

            <!-- Pagination -->
            <c:if test="${totalPages > 1}">
                <div style="display: flex; justify-content: center; gap: 8px; margin-top: 20px;">
                    <c:forEach var="p" begin="1" end="${totalPages}">
                        <a href="${pageContext.request.contextPath}/audit-log?page=${p}&action=${selectedAction}&user=${selectedUser}"
                           style="padding: 6px 12px; border-radius: 6px; border: 1px solid #cbd5e1; text-decoration: none; font-size: 13px; font-weight: 600; ${currentPage == p ? 'background: #6366f1; color: white;' : 'background: white; color: #334155;'}">
                            ${p}
                        </a>
                    </c:forEach>
                </div>
            </c:if>
        </div>
    </div>
</body>
</html>
