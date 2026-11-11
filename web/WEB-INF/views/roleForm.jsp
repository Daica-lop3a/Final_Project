<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.LinkedHashMap"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Set"%>
<%@page import="model.Role"%>
<%@page import="model.Permission"%>

<%
    String ctx = request.getContextPath();
    Role role = (Role) request.getAttribute("ROLE");
    if (role == null) {
        role = new Role();
    }
    List<Permission> allPerms = (List<Permission>) request.getAttribute("ALL_PERMISSIONS");
    if (allPerms == null) {
        allPerms = new ArrayList<Permission>();
    }
    Set<String> activePermSet = role.getPermissionIdSet();
    String error = (String) request.getAttribute("ERROR");

    // Group permissions by category
    Map<String, List<Permission>> grouped = new LinkedHashMap<String, List<Permission>>();
    for (Permission p : allPerms) {
        String cat = p.getCategory() != null ? p.getCategory() : "General";
        List<Permission> list = grouped.get(cat);
        if (list == null) {
            list = new ArrayList<Permission>();
            grouped.put(cat, list);
        }
        list.add(p);
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Role &amp; Permissions - SmartWaste</title>
    <link rel="stylesheet" href="<%=ctx%>/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .smartwaste-form-page {
            width: 100%;
            min-height: 100vh;
            background: #EDF8F2;
            padding: 34px 40px;
            box-sizing: border-box;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
        }

        .form-header-box {
            margin-bottom: 24px;
        }

        .form-breadcrumb {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13px;
            font-weight: 600;
            color: #64748B;
            margin-bottom: 8px;
        }

        .form-breadcrumb a {
            text-decoration: none;
            color: #00875A;
        }

        .form-header-box h1 {
            margin: 0 0 6px 0;
            font-size: 26px;
            font-weight: 800;
            color: #0A2E20;
        }

        .form-header-box p {
            margin: 0;
            color: #4A6B5D;
            font-size: 14px;
        }

        .smartwaste-form-card {
            background: #FFFFFF;
            border-radius: 12px;
            border: 1px solid #D1EBCF;
            padding: 32px;
            box-shadow: 0 4px 16px rgba(10, 46, 32, 0.05);
        }

        .form-section-title {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 16px;
            font-weight: 700;
            color: #0A2E20;
            margin: 28px 0 16px 0;
            padding-bottom: 8px;
            border-bottom: 2px solid #E2F2E5;
        }

        .form-section-title:first-of-type {
            margin-top: 0;
        }

        .form-grid-2 {
            display: grid;
            grid-template-columns: 1fr 2fr;
            gap: 20px;
            margin-bottom: 20px;
        }

        .form-field label {
            display: block;
            font-size: 13px;
            font-weight: 700;
            color: #1C1E21;
            margin-bottom: 6px;
        }

        .form-input, .form-textarea {
            width: 100%;
            padding: 10px 14px;
            border: 1px solid #C4D9C8;
            border-radius: 8px;
            font-size: 14px;
            box-sizing: border-box;
            background: #FFFFFF;
            color: #1C1E21;
            transition: border-color 0.15s;
        }

        .form-input:focus, .form-textarea:focus {
            outline: none;
            border-color: #00875A;
            box-shadow: 0 0 0 3px rgba(0, 135, 90, 0.15);
        }

        .form-input[readonly] {
            background: #F8FAFC;
            color: #475569;
            cursor: not-allowed;
            font-weight: 700;
        }

        /* PERMISSION MATRIX CHECKBOX CARDS */
        .perm-category-card {
            background: #FDFEFE;
            border: 1px solid #E2F2E5;
            border-radius: 10px;
            margin-bottom: 18px;
            overflow: hidden;
        }

        .perm-category-header {
            background: #EDF8F2;
            padding: 10px 16px;
            font-size: 13px;
            font-weight: 800;
            color: #0A2E20;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .perm-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 12px;
            padding: 16px;
        }

        .perm-item {
            display: flex;
            align-items: flex-start;
            gap: 10px;
            padding: 10px 12px;
            background: #FFFFFF;
            border: 1px solid #E2E8F0;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.15s;
        }

        .perm-item:hover {
            border-color: #00875A;
            background: #F9FCFA;
        }

        .perm-item input[type="checkbox"] {
            margin-top: 3px;
            width: 16px;
            height: 16px;
            accent-color: #00875A;
            cursor: pointer;
        }

        .perm-label-box strong {
            display: block;
            font-size: 13px;
            color: #0F172A;
            font-weight: 700;
        }

        .perm-label-box span {
            display: block;
            font-size: 11px;
            color: #64748B;
            margin-top: 2px;
            line-height: 1.4;
        }

        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 12px;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #E2F2E5;
        }

        .btn-save {
            background: #00875A;
            color: #FFFFFF;
            padding: 10px 22px;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: background 0.15s;
        }

        .btn-save:hover {
            background: #006644;
        }

        .btn-cancel {
            background: #F1F5F9;
            color: #475569;
            padding: 10px 20px;
            border: 1px solid #CBD5E1;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .btn-cancel:hover {
            background: #E2E8F0;
        }

        .quick-btn {
            background: #FFFFFF;
            border: 1px solid #CBD5E1;
            padding: 4px 10px;
            font-size: 11px;
            font-weight: 700;
            border-radius: 6px;
            color: #334155;
            cursor: pointer;
        }
        .quick-btn:hover {
            background: #F8FAFC;
            color: #00875A;
        }
    </style>
</head>
<body>

    <jsp:include page="/WEB-INF/views/sidebar.jsp" />

    <main class="smartwaste-form-page">
        <div style="max-width: 1080px; margin: 0 auto;">

            <!-- BREADCRUMB & HEADER -->
            <div class="form-header-box">
                <div class="form-breadcrumb">
                    <a href="<%=ctx%>/dashboard">Dashboard</a>
                    <i class="fa-solid fa-chevron-right" style="font-size: 9px;"></i>
                    <a href="<%=ctx%>/role">Role &amp; Permissions</a>
                    <i class="fa-solid fa-chevron-right" style="font-size: 9px;"></i>
                    <span>Configure Role</span>
                </div>
                <h1>Configure Role: <%= role.getRoleName() != null ? role.getRoleName() : role.getRoleId() %></h1>
            </div>

            <!-- ERROR ALERT -->
            <% if (error != null && !error.trim().isEmpty()) { %>
                <div style="padding: 12px 16px; background: #FEE2E2; border: 1px solid #FCA5A5; border-radius: 8px; color: #991B1B; font-size: 13px; font-weight: 600; margin-bottom: 20px; display: flex; align-items: center; gap: 8px;">
                    <i class="fa-solid fa-circle-exclamation"></i>
                    <span><%= error %></span>
                </div>
            <% } %>

            <div class="smartwaste-form-card">
                <form action="<%=ctx%>/role/save" method="POST">

                    <!-- 1. ROLE METADATA -->
                    <div class="form-section-title">
                        <i class="fa-solid fa-user-shield" style="color: #00875A;"></i>
                        <span>Role Identity &amp; Scope</span>
                    </div>

                    <div class="form-grid-2">
                        <div class="form-field">
                            <label for="roleId">Role Identifier (Code)</label>
                            <input type="text" id="roleId" name="roleId" class="form-input" value="<%= role.getRoleId() %>" readonly>
                            <small style="display: block; margin-top: 4px; font-size: 11px; color: #64748B;">
                                Immutable primary key referenced by system security engine.
                            </small>
                        </div>

                        <div class="form-field">
                            <label for="roleName">Display Name <span style="color: #DC2626;">*</span></label>
                            <input type="text" id="roleName" name="roleName" class="form-input"
                                   value="<%= role.getRoleName() != null ? role.getRoleName() : "" %>"
                                   placeholder="e.g. Operations Manager" required maxlength="50">
                            <small style="display: block; margin-top: 4px; font-size: 11px; color: #64748B;">
                                Human-readable role designation shown across user profiles.
                            </small>
                        </div>
                    </div>

                    <div class="form-field" style="margin-bottom: 24px;">
                        <label for="description">Scope &amp; Core Authority Description</label>
                        <textarea id="description" name="description" class="form-textarea" rows="3"
                                  placeholder="Summarize the core duties, operational zones, and authorities of this role..."><%= role.getDescription() != null ? role.getDescription() : "" %></textarea>
                    </div>

                    <!-- 2. DYNAMIC PERMISSIONS MATRIX -->
                    <div class="form-section-title" style="justify-content: space-between;">
                        <div style="display: flex; align-items: center; gap: 8px;">
                            <i class="fa-solid fa-key" style="color: #00875A;"></i>
                            <span>Granted Functional Permissions (<span id="selectedCount"><%= activePermSet.size() %></span>/<%= allPerms.size() %>)</span>
                        </div>
                        <div style="display: flex; gap: 6px;">
                            <button type="button" class="quick-btn" onclick="toggleAllPerms(true)">Select All</button>
                            <button type="button" class="quick-btn" onclick="toggleAllPerms(false)">Deselect All</button>
                        </div>
                    </div>

                    <% if ("SAD".equals(role.getRoleId())) { %>
                    <div style="padding: 10px 14px; background: #FEF3C7; border: 1px solid #FCD34D; border-radius: 8px; color: #92400E; font-size: 12px; margin-bottom: 16px; display: flex; align-items: center; gap: 8px;">
                        <i class="fa-solid fa-triangle-exclamation"></i>
                        <span><strong>Super Admin Policy:</strong> System Governance permission is protected and cannot be revoked to safeguard administrative continuity.</span>
                    </div>
                    <% } %>

                    <!-- Categorized Permission Checkboxes -->
                    <% for (Map.Entry<String, List<Permission>> entry : grouped.entrySet()) { 
                        String catName = entry.getKey();
                        List<Permission> pList = entry.getValue();
                    %>
                    <div class="perm-category-card">
                        <div class="perm-category-header">
                            <span><i class="fa-solid fa-folder-tree" style="margin-right: 6px; color: #00875A;"></i><%= catName %></span>
                            <span style="font-size: 11px; font-weight: 600; color: #475569;"><%= pList.size() %> permissions</span>
                        </div>
                        <div class="perm-grid">
                            <% for (Permission p : pList) { 
                                boolean isChecked = activePermSet.contains(p.getPermissionId());
                                boolean isLockedSAD = "SAD".equals(role.getRoleId()) && "SYSTEM_CONFIG".equals(p.getPermissionId());
                            %>
                            <label class="perm-item" for="perm_<%= p.getPermissionId() %>">
                                <input type="checkbox"
                                       id="perm_<%= p.getPermissionId() %>"
                                       name="permissions"
                                       value="<%= p.getPermissionId() %>"
                                       <%= isChecked ? "checked" : "" %>
                                       <%= isLockedSAD ? "onclick='return false;'" : "onchange='updateCount()'" %>>
                                <div class="perm-label-box">
                                    <strong><%= p.getPermissionName() %></strong>
                                    <span><%= p.getDescription() != null ? p.getDescription() : p.getPermissionId() %></span>
                                </div>
                            </label>
                            <% } %>
                        </div>
                    </div>
                    <% } %>

                    <!-- ACTIONS -->
                    <div class="form-actions">
                        <a href="<%=ctx%>/role" class="btn-cancel">
                            <i class="fa-solid fa-xmark"></i> Cancel
                        </a>
                        <button type="submit" class="btn-save">
                            <i class="fa-solid fa-floppy-disk"></i> Save Permissions &amp; Role Details
                        </button>
                    </div>

                </form>
            </div>
        </div>
    </main>

    <script>
        function updateCount() {
            const checkboxes = document.querySelectorAll('input[name="permissions"]:checked');
            document.getElementById('selectedCount').innerText = checkboxes.length;
        }

        function toggleAllPerms(check) {
            const checkboxes = document.querySelectorAll('input[name="permissions"]');
            checkboxes.forEach(cb => {
                if (!cb.disabled && cb.getAttribute('onclick') !== 'return false;') {
                    cb.checked = check;
                }
            });
            updateCount();
        }
    </script>
</body>
</html>
