<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.AdminPasswordRequest"%>
<%@page import="model.AppUser"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%
    String ctx = request.getContextPath();
    List<AdminPasswordRequest> list = (List<AdminPasswordRequest>) request.getAttribute("REQUEST_LIST");
    String successMsg = (String) request.getAttribute("SUCCESS_MSG");
    AppUser currentUser = (AppUser) session.getAttribute("user");
    boolean isSuperAdmin = currentUser != null && currentUser.isSuperAdmin();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Password Approvals - SmartWaste</title>

    <link rel="stylesheet" href="<%=ctx%>/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
        }

        .approval-page {
            margin-left: 0;
            width: 100%;
            min-height: 100vh;
            padding: 30px 36px;
            box-sizing: border-box;
            background: #EDF8F2;
        }

        .header-box {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 24px;
        }

        .page-kicker {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 0.8px;
            text-transform: uppercase;
            color: #65676B;
            margin-bottom: 6px;
        }

        .page-title {
            margin: 0;
            font-size: 26px;
            font-weight: 700;
            color: #050505;
        }

        .page-desc {
            margin: 6px 0 0;
            color: #65676B;
            font-size: 14px;
        }

        .alert-success {
            background: #DCF2E4;
            color: #00875A;
            padding: 12px 16px;
            border-radius: 6px;
            border: 1px solid #BFDBFE;
            margin-bottom: 20px;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 10px;
            font-weight: 600;
        }

        .table-card {
            background: #FFFFFF;
            border-radius: 8px;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
            border: 1px solid #D1EBCF;
            overflow: hidden;
        }

        .custom-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
            text-align: left;
        }

        .custom-table th {
            background: #EDF8F2;
            color: #65676B;
            font-weight: 700;
            font-size: 11px;
            letter-spacing: 0.5px;
            text-transform: uppercase;
            padding: 12px 16px;
            border-bottom: 1px solid #D1EBCF;
        }

        .custom-table td {
            padding: 14px 16px;
            border-bottom: 1px solid #E2F2E5;
            color: #1C1E21;
            vertical-align: middle;
        }

        .custom-table tbody tr {
            background: #FFFFFF;
            transition: background 0.15s ease;
        }

        .custom-table tbody tr:hover {
            background: #F2F3F5;
        }

        .badge-status {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 11.5px;
            font-weight: 600;
        }

        .badge-pending { background: #FEF3C7; color: #92400E; border: 1px solid #FDE68A; }
        .badge-approved { background: #DCFCE7; color: #166534; border: 1px solid #BBF7D0; }
        .badge-rejected { background: #FEE2E2; color: #991B1B; border: 1px solid #FECACA; }

        .btn-action {
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 600;
            border: 1px solid transparent;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 4px;
            transition: 0.15s ease;
        }

        .btn-approve {
            background: #00875A;
            color: white;
            border-color: #00875A;
        }
        .btn-approve:hover { background: #006644; }

        .btn-reject {
            background: #FFFFFF;
            color: #DC2626;
            border: 1px solid #D1EBCF;
            margin-left: 4px;
        }
        .btn-reject:hover { background: #FEE2E2; border-color: #DC2626; }

        .temp-pass {
            font-family: monospace;
            background: #f1f5f9;
            border: 1px dashed #cbd5e1;
            padding: 3px 8px;
            border-radius: 4px;
            font-weight: 700;
            color: #2563eb;
        }
    </style>
</head>
<body>

    <jsp:include page="/WEB-INF/views/sidebar.jsp" />

    <main class="approval-page">
        <div class="header-box">
            <div>
                <span class="page-kicker">
                    <i class="fa-solid fa-user-shield"></i> Master System Authority
                </span>
                <h1 class="page-title">Admin Password Reset Approvals</h1>
            </div>
            <% if (!isSuperAdmin) { %>
            <div>
                <!-- Admin view trigger -->
                <button type="button" onclick="document.getElementById('requestModal').style.display='flex'" class="btn" style="padding: 10px 16px; background: #2563eb; color: white; border: none; border-radius: 8px; font-weight: 700; cursor: pointer;">
                    <i class="fa-solid fa-paper-plane"></i> Submit Password Request
                </button>
            </div>
            <% } %>
        </div>

        <% if (successMsg != null) { %>
            <div class="alert-success">
                <i class="fa-solid fa-circle-check" style="font-size: 18px;"></i>
                <span><%= successMsg %></span>
            </div>
        <% } %>

        <div class="table-card">
            <table class="custom-table">
                <thead>
                    <tr>
                        <th style="width: 80px;">Req #</th>
                        <th style="width: 200px;">Admin Account</th>
                        <th>Reason / Justification</th>
                        <th style="width: 140px;">Request Time</th>
                        <th style="width: 110px;">Status</th>
                        <th style="width: 180px;">Temporary Password</th>
                        <th style="width: 200px;">Resolution Note</th>
                        <% if (isSuperAdmin) { %>
                        <th style="width: 160px; text-align: center;">Decision Action</th>
                        <% } %>
                    </tr>
                </thead>
                <tbody>
                    <% if (list != null && !list.isEmpty()) {
                        for (AdminPasswordRequest r : list) {
                            String stClass = "badge-pending";
                            if ("Approved".equalsIgnoreCase(r.getStatus())) stClass = "badge-approved";
                            else if ("Rejected".equalsIgnoreCase(r.getStatus())) stClass = "badge-rejected";
                    %>
                    <tr>
                        <td><strong>#<%= r.getRequestId() %></strong></td>
                        <td>
                            <div style="font-weight: 700; color: #1e293b;"><%= r.getAdminName() %></div>
                            <small style="color: #64748b;"><%= r.getAdminEmail() %> (<%= r.getAdminId() %>)</small>
                        </td>
                        <td style="color: #334155;"><%= r.getReason() %></td>
                        <td style="color: #64748b; font-size: 12px;"><%= r.getRequestDate() %></td>
                        <td>
                            <span class="badge-status <%= stClass %>">
                                <%= r.getStatus() %>
                            </span>
                        </td>
                        <td>
                            <% if (r.getTemporaryPassword() != null) { %>
                                <span class="temp-pass"><%= r.getTemporaryPassword() %></span>
                            <% } else { %>
                                <span style="color: #94a3b8; font-style: italic;">None</span>
                            <% } %>
                        </td>
                        <td style="color: #475569; font-size: 12px;">
                            <%= r.getResolutionNote() != null ? r.getResolutionNote() : "-" %>
                        </td>
                        <% if (isSuperAdmin) { %>
                        <td style="text-align: center;">
                            <% if (r.isPending()) { %>
                                <form action="<%=ctx%>/admin-approval" method="POST" style="display: inline;" onsubmit="return confirm('Approve password reset and issue temporary credentials for <%= r.getAdminId() %>?');">
                                    <input type="hidden" name="action" value="approve">
                                    <input type="hidden" name="requestId" value="<%= r.getRequestId() %>">
                                    <input type="hidden" name="note" value="Approved by Super Admin">
                                    <button type="submit" class="btn-action btn-approve">
                                        <i class="fa-solid fa-check"></i> Approve
                                    </button>
                                </form>
                                <form action="<%=ctx%>/admin-approval" method="POST" style="display: inline;" onsubmit="return confirm('Reject this password reset request?');">
                                    <input type="hidden" name="action" value="reject">
                                    <input type="hidden" name="requestId" value="<%= r.getRequestId() %>">
                                    <input type="hidden" name="note" value="Declined by Super Admin">
                                    <button type="submit" class="btn-action btn-reject">
                                        <i class="fa-solid fa-xmark"></i> Reject
                                    </button>
                                </form>
                            <% } else { %>
                                <span style="color: #94a3b8; font-size: 12px;"><i class="fa-solid fa-lock"></i> Resolved</span>
                            <% } %>
                        </td>
                        <% } %>
                    </tr>
                    <% } } else { %>
                    <tr>
                        <td colspan="8" style="text-align: center; padding: 36px; color: #94a3b8;">
                            <i class="fa-solid fa-clipboard-check" style="font-size: 32px; margin-bottom: 8px; display: block; color: #cbd5e1;"></i>
                            No admin password approval requests logged in the system.
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </main>

</body>
</html>
