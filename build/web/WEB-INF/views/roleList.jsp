<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Role"%>
<%@page import="model.Permission"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%
    String ctx = request.getContextPath();
    List<Role> roles = (List<Role>) request.getAttribute("LIST_ROLES");
    String successMsg = (String) request.getAttribute("SUCCESS_MSG");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Role &amp; Permission Matrix - SmartWaste</title>

    <link rel="stylesheet" href="<%=ctx%>/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        .role-page {
            margin-left: 0;
            width: 100%;
            min-height: 100vh;
            padding: 34px 40px;
            box-sizing: border-box;
            background: #EDF8F2;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
        }

        .header-box {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 24px;
        }

        .page-kicker {
            font-size: 11px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            color: #00875A;
            display: flex;
            align-items: center;
            gap: 6px;
            margin-bottom: 4px;
        }

        .page-title {
            font-size: 26px;
            font-weight: 800;
            color: #0A2E20;
            margin: 0 0 6px 0;
        }

        .page-desc {
            font-size: 14px;
            color: #4A6B5D;
            margin: 0;
        }

        .alert-success {
            background: #FFFFFF;
            color: #065F46;
            border: 1px solid #A7F3D0;
            border-left: 5px solid #059669;
            box-shadow: 0 4px 14px rgba(5, 150, 105, 0.12);
            padding: 14px 18px;
            border-radius: 8px;
            margin-bottom: 22px;
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 14px;
            font-weight: 600;
        }

        .table-card {
            background: white;
            border-radius: 12px;
            border: 1px solid #D1EBCF;
            box-shadow: 0 2px 10px rgba(10, 46, 32, 0.04);
            overflow: hidden;
        }

        .custom-table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
            font-size: 13px;
        }

        .custom-table th {
            background: #EDF8F2;
            color: #0A2E20;
            font-weight: 700;
            padding: 14px 18px;
            border-bottom: 1px solid #D1EBCF;
        }

        .custom-table td {
            padding: 16px 18px;
            border-bottom: 1px solid #E2F2E5;
            color: #1C1E21;
            vertical-align: middle;
        }

        .custom-table tr:hover {
            background: #F9FCFA;
        }

        .badge-role {
            display: inline-flex;
            align-items: center;
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 700;
            background: #EDF8F2 !important;
            color: #0A2E20 !important;
            border: 1px solid #D1EBCF !important;
        }

        .btn-edit {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 14px;
            background: #EDF8F2;
            color: #00875A;
            border: 1px solid #D1EBCF;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 700;
            text-decoration: none;
            transition: all 0.15s ease;
        }

        .btn-edit:hover {
            background: #00875A;
            color: white;
            border-color: #00875A;
        }

        .perm-tag {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 4px;
            background: #F1F5F9;
            color: #334155;
            font-size: 11px;
            margin: 2px;
            font-weight: 600;
            border: 1px solid #E2E8F0;
        }

        .badge-locked {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 12px;
            background: #F1F5F9;
            color: #64748B;
            border: 1px solid #CBD5E1;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 700;
            cursor: not-allowed;
        }
    </style>
</head>
<body>

    <jsp:include page="/WEB-INF/views/sidebar.jsp" />

    <main class="role-page">
        <div class="header-box">
            <div>
                <span class="page-kicker">
                    <i class="fa-solid fa-shield-halved"></i> Super Admin Governance
                </span>
                <h1 class="page-title">Role &amp; Permission Matrix</h1>
            </div>
            <div>
                <a href="<%=ctx%>/user" class="btn" style="padding: 10px 16px; background: white; border: 1px solid #cbd5e1; border-radius: 8px; text-decoration: none; font-size: 13px; font-weight: 700; color: #334155; display: inline-flex; align-items: center; gap: 6px;">
                    <i class="fa-solid fa-users"></i> Manage User Accounts
                </a>
            </div>
        </div>

        <% if (successMsg != null) { %>
            <div class="alert-success">
                <i class="fa-solid fa-circle-check" style="font-size: 18px; color: #059669;"></i>
                <span><%= successMsg %></span>
            </div>
        <% } %>

        <div class="table-card">
            <table class="custom-table">
                <thead>
                    <tr>
                        <th style="width: 100px;">Role Code</th>
                        <th style="width: 200px;">Role Name</th>
                        <th>Scope &amp; Core Authority</th>
                        <th style="width: 120px; text-align: center;">Assigned Users</th>
                        <th style="width: 320px;">Granted Permissions</th>
                        <th style="width: 120px; text-align: center;">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (roles != null) { 
                        for (Role r : roles) {
                            List<Permission> pList = r.getPermissions();
                    %>
                    <tr>
                        <td>
                            <span class="badge-role">
                                <%= r.getRoleId() %>
                            </span>
                        </td>
                        <td>
                            <strong><%= r.getRoleName() %></strong>
                        </td>
                        <td style="color: #475569; line-height: 1.5;">
                            <%= r.getDescription() != null ? r.getDescription() : "" %>
                        </td>
                        <td style="text-align: center;">
                            <span style="font-weight: 700; color: #1e293b; background: #e2e8f0; padding: 3px 10px; border-radius: 12px; font-size: 12px;">
                                <%= r.getUserCount() %> users
                            </span>
                        </td>
                        <td>
                            <% if (pList != null && !pList.isEmpty()) { 
                                for (Permission p : pList) { %>
                                    <span class="perm-tag" title="<%= p.getDescription() != null ? p.getDescription() : "" %>">
                                        <%= p.getPermissionName() %>
                                    </span>
                            <%  }
                               } else { %>
                                    <span style="color: #94a3b8; font-style: italic; font-size: 12px;">No permissions granted</span>
                            <% } %>
                        </td>
                        <td style="text-align: center;">
                            <% if ("SAD".equalsIgnoreCase(r.getRoleId())) { %>
                                <span class="badge-locked" title="Super Admin is the root master role and permanently retains all system authorities">
                                    <i class="fa-solid fa-lock"></i> Master Role
                                </span>
                            <% } else { %>
                                <a href="<%=ctx%>/role/edit?id=<%= r.getRoleId() %>" class="btn-edit" title="Configure permissions for <%= r.getRoleName() %>">
                                    <i class="fa-solid fa-sliders"></i> Configure
                                </a>
                            <% } %>
                        </td>
                    </tr>
                    <% } } %>
                </tbody>
            </table>
        </div>
    </main>

</body>
</html>
