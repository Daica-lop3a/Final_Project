<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="model.AppUser"%>
<%@page import="java.util.Map"%>
<%
    String ctx = request.getContextPath();
    AppUser user = (AppUser) request.getAttribute("USER");
    boolean edit = user != null && user.getUserId() != null && !user.getUserId().trim().isEmpty();
    String error = (String) request.getAttribute("ERROR");
    String nextUserId = (String) request.getAttribute("NEXT_USER_ID");
    String defaultRole = (String) request.getAttribute("DEFAULT_ROLE");

    @SuppressWarnings("unchecked")
    Map<String, String> roleNextIds = (Map<String, String>) request.getAttribute("ROLE_NEXT_IDS");

    AppUser loggedInUser = (AppUser) session.getAttribute("user");
    boolean isSuperAdmin = loggedInUser != null && loggedInUser.isSuperAdmin();

    String currentRole = (user != null && user.getRoleId() != null && !user.getRoleId().trim().isEmpty())
            ? user.getRoleId().trim().toUpperCase()
            : (defaultRole != null && !defaultRole.isEmpty() ? defaultRole : (isSuperAdmin ? "SAD" : "STF"));

    String userIdVal = "";
    if (edit && user != null && user.getUserId() != null) {
        userIdVal = user.getUserId();
    } else if (roleNextIds != null && roleNextIds.containsKey(currentRole)) {
        userIdVal = roleNextIds.get(currentRole);
    } else if (nextUserId != null && !nextUserId.trim().isEmpty()) {
        userIdVal = nextUserId.trim();
    } else {
        userIdVal = util.IdGenerator.nextUserId(currentRole);
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= edit ? "Edit User Account" : "Register User Account" %> - SmartWaste</title>
    <link rel="stylesheet" href="<%=ctx%>/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body style="background: var(--page); margin: 0;">

    <div class="app-shell">
        
        <!-- SIDEBAR NAVIGATION -->
        <jsp:include page="/WEB-INF/views/sidebar.jsp" />

        <!-- MAIN FORM PAGE -->
        <main class="smartwaste-form-page">
            <div class="smartwaste-form-container">
                
                <!-- BREADCRUMB & HEADER -->
                <div class="form-header-box">
                    <div class="form-breadcrumb">
                        <a href="<%=ctx%>/dashboard" style="color: var(--color-slate-400);">Dashboard</a>
                        <i class="fa-solid fa-chevron-right" style="font-size: 9px;"></i>
                        <a href="<%=ctx%>/user" style="color: var(--color-slate-400);">User Accounts</a>
                        <i class="fa-solid fa-chevron-right" style="font-size: 9px;"></i>
                        <span style="color: var(--brand-forest);"><%= edit ? "Edit User" : "Create Account" %></span>
                    </div>
                    <h1><%= edit ? "Edit Account: " + user.getFullName() : "Create System Account" %></h1>
                </div>

                <!-- ERROR ALERT -->
                <% if (error != null && !error.trim().isEmpty()) { %>
                    <div style="padding: 12px 16px; background: #FEE2E2; border: 1px solid #FCA5A5; border-radius: 8px; color: #991B1B; font-size: 13px; font-weight: 600; margin-bottom: 20px; display: flex; align-items: center; gap: 8px;">
                        <i class="fa-solid fa-circle-exclamation"></i>
                        <span><%= error %></span>
                    </div>
                <% } %>

                <!-- FORM CARD -->
                <div class="smartwaste-form-card">
                    <form action="<%=ctx%>/user/save" method="POST">
                        <% if (edit) { %>
                            <input type="hidden" name="oldId" value="<%= user.getUserId() %>">
                        <% } %>

                        <div class="form-section-divider">
                            <i class="fa-solid fa-user-shield"></i>
                            <span>Identity &amp; Role Authorization</span>
                        </div>

                        <div class="form-grid">
                            
                            <!-- Role ID (With Strict Hierarchy Protection & Real-time ID Trigger) -->
                            <div class="form-field">
                                <label class="form-label" for="roleId">
                                    System Role <span class="required">*</span>
                                </label>
                                <select id="roleId" name="roleId" class="form-select" onchange="onRoleChange(this.value)" required>
                                    <% if (isSuperAdmin) { %>
                                        <option value="SAD" <%= "SAD".equals(currentRole) ? "selected" : "" %>>Super Administrator</option>
                                        <option value="ADM" <%= "ADM".equals(currentRole) ? "selected" : "" %>>Administrator</option>
                                    <% } %>
                                    <option value="MGR" <%= "MGR".equals(currentRole) ? "selected" : "" %>>Manager</option>
                                    <option value="SUP" <%= "SUP".equals(currentRole) ? "selected" : "" %>>Area Supervisor</option>
                                    <option value="STF" <%= "STF".equals(currentRole) ? "selected" : "" %>>Collection Staff</option>
                                    <option value="TEC" <%= "TEC".equals(currentRole) ? "selected" : "" %>>Technician</option>
                                    <option value="AUD" <%= "AUD".equals(currentRole) ? "selected" : "" %>>Auditor</option>
                                    <option value="USR" <%= "USR".equals(currentRole) ? "selected" : "" %>>Citizen User</option>
                                </select>
                            </div>

                            <!-- User ID (Auto-generated & Role-constrained) -->
                            <div class="form-field">
                                <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 6px;">
                                    <label class="form-label" for="userId" style="margin-bottom: 0;">
                                        User Identifier <span class="required">*</span>
                                    </label>
                                    <% if (!edit) { %>
                                        <span style="display: inline-flex; align-items: center; gap: 4px; padding: 2px 8px; border-radius: 999px; font-size: 11px; font-weight: 700; background: #EFF6FF; color: #00875A; border: 1px solid #BFDBFE;">
                                            <i class="fa-solid fa-wand-magic-sparkles"></i> Auto-generated
                                        </span>
                                    <% } %>
                                </div>
                                <input type="text" id="userId" name="userId" class="form-input"
                                       value="<%= userIdVal %>"
                                       readonly
                                       style="background: #F8FAFC; color: #0F172A; font-family: 'Consolas', 'Courier New', monospace; font-weight: 700; font-size: 14px; letter-spacing: 0.5px; border-color: #CBD5E1; cursor: not-allowed;"
                                       required>
                                <span class="form-hint" id="roleConstraintHint">
                                    <i class="fa-solid fa-shield-halved" style="color: #10B981;"></i>
                                    <%= edit ? "User ID cannot be changed once created." : "Constraint: Auto-assigned sequential ID matching prefix <strong id='rolePrefixHint' style='color: #00875A;'>" + currentRole + "-xxx</strong>" %>
                                </span>
                            </div>

                            <!-- Full Name -->
                            <div class="form-field">
                                <label class="form-label" for="fullName">
                                    Full Name <span class="required">*</span>
                                </label>
                                <input type="text" id="fullName" name="fullName" class="form-input"
                                       placeholder="e.g. Nguyen Van An"
                                       value="<%= edit && user != null && user.getFullName() != null ? user.getFullName() : "" %>"
                                       maxlength="100"
                                       required>
                                <span class="form-hint">Official personnel name.</span>
                            </div>

                            <!-- Email Address -->
                            <div class="form-field">
                                <label class="form-label" for="email">
                                    Official Email Address <span class="required">*</span>
                                </label>
                                <input type="email" id="email" name="email" class="form-input"
                                       placeholder="e.g. an.nguyen@smartwaste.com"
                                       value="<%= edit && user != null && user.getEmail() != null ? user.getEmail() : "" %>"
                                       maxlength="100"
                                       required>
                                <span class="form-hint">Used for sign in and dispatch notifications.</span>
                            </div>

                            <!-- Phone Number -->
                            <div class="form-field">
                                <label class="form-label" for="phoneNumber">
                                    Contact Phone Number <span class="required">*</span>
                                </label>
                                <input type="tel" id="phoneNumber" name="phoneNumber" class="form-input"
                                       placeholder="e.g. 0909123456"
                                       pattern="^(0|\+84)[35789][0-9]{8}$"
                                       title="Vietnamese mobile phone: 10 digits starting with 03, 05, 07, 08, 09 or +84"
                                       value="<%= edit && user != null && user.getPhoneNumber() != null ? user.getPhoneNumber() : "" %>"
                                       maxlength="15"
                                       required>
                                <span class="form-hint">Vietnamese mobile phone: 10 digits starting with 03, 05, 07, 08, 09 (e.g. 0909123456 or +84909123456).</span>
                            </div>

                            <!-- Password Notice for Create -->
                            <% if (!edit) { %>
                            <div class="form-field">
                                <label class="form-label">Default Access Password</label>
                                <input type="text" class="form-input" value="123456" readonly style="background: #F8FAFC; color: #64748B; cursor: not-allowed;">
                                <span class="form-hint">Default password is 123456. User can change it after signing in.</span>
                            </div>
                            <% } %>

                        </div>

                        <!-- ACTIONS -->
                        <div class="form-actions-bar">
                            <a href="<%=ctx%>/user" class="btn-smart-secondary">
                                <i class="fa-solid fa-xmark"></i>
                                <span>Cancel</span>
                            </a>
                            <button type="submit" class="btn-smart-primary">
                                <i class="fa-solid fa-check"></i>
                                <span><%= edit ? "Update User" : "Create Account" %></span>
                            </button>
                        </div>

                    </form>
                </div>

            </div>
        </main>
    </div>

    <!-- REAL-TIME ROLE CONSTRAINT ID GENERATOR SCRIPT -->
    <script>
        const roleNextIds = {
            <% if (roleNextIds != null) {
                for (Map.Entry<String, String> entry : roleNextIds.entrySet()) { %>
                    "<%= entry.getKey() %>": "<%= entry.getValue() %>",
            <%   }
               } %>
        };

        function onRoleChange(selectedRole) {
            <% if (!edit) { %>
            const idInput = document.getElementById('userId');
            const prefixHint = document.getElementById('rolePrefixHint');
            if (!idInput) return;

            // 1. Immediately apply pre-calculated sequential ID
            if (roleNextIds[selectedRole]) {
                idInput.value = roleNextIds[selectedRole];
            } else {
                idInput.value = selectedRole + "-001";
            }

            if (prefixHint) {
                prefixHint.textContent = selectedRole + "-xxx";
            }

            // 2. Real-time background sync with server to ensure up-to-date sequential numbering
            fetch('<%=ctx%>/user/next-id?roleId=' + encodeURIComponent(selectedRole))
                .then(function(res) {
                    if (res.ok) return res.text();
                    throw new Error('Network response not ok');
                })
                .then(function(freshId) {
                    if (freshId && freshId.trim()) {
                        idInput.value = freshId.trim();
                        roleNextIds[selectedRole] = freshId.trim();
                    }
                })
                .catch(function(err) {
                    // Graceful fallback to pre-rendered sequential ID
                });
            <% } %>
        }

        <% if (!edit) { %>
        document.addEventListener('DOMContentLoaded', function() {
            var roleSelect = document.getElementById('roleId');
            if (roleSelect && roleSelect.value) {
                onRoleChange(roleSelect.value);
            }
        });
        <% } %>
    </script>

</body>
</html>
