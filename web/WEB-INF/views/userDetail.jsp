<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="model.AppUser"%>
<%@page import="java.net.URLEncoder"%>

<%
    AppUser viewedUser = (AppUser) request.getAttribute("USER");
    AppUser sessionUser = (AppUser) session.getAttribute("user");

    boolean canManage = false;
    if (sessionUser != null && viewedUser != null) {
        if (sessionUser.isSuperAdmin()) {
            canManage = true;
        } else if (sessionUser.isAdmin()) {
            canManage = !viewedUser.isSuperAdmin() && !viewedUser.isAdmin();
        }
    }

    String ctx = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Profile Details - SmartWaste</title>

    <link rel="stylesheet" href="<%=ctx%>/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body style="background: var(--page); margin: 0;">

    <div class="app-shell">
        <!-- SIDEBAR NAVIGATION -->
        <jsp:include page="/WEB-INF/views/sidebar.jsp" />

        <!-- MAIN CONTENT -->
        <main class="smartwaste-form-page">
            <div class="smartwaste-form-container">
                
                <!-- BREADCRUMB & HEADER -->
                <div class="form-header-box">
                    <div class="form-breadcrumb">
                        <a href="<%=ctx%>/dashboard">Dashboard</a>
                        <i class="fa-solid fa-chevron-right"></i>
                        <a href="<%=ctx%>/user">User Accounts</a>
                        <i class="fa-solid fa-chevron-right"></i>
                        <span>Account Profile</span>
                    </div>
                    <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px; margin-top: 10px;">
                        <div>
                            <span class="badge-role-pill">IDENTITY &bull; DIRECTORY</span>
                            <h1 style="margin: 6px 0 0; font-size: 26px; font-weight: 800; color: #0F172A;">
                                <%= viewedUser != null && viewedUser.getFullName() != null ? viewedUser.getFullName() : "User Profile" %>
                            </h1>
                        </div>
                        <div>
                            <a href="<%=ctx%>/user" class="btn-smart-secondary" style="font-size: 13px;">
                                <i class="fa-solid fa-arrow-left"></i> Back to Accounts
                            </a>
                        </div>
                    </div>
                </div>

                <!-- CARD -->
                <div class="smartwaste-form-card">
                    <% if (viewedUser != null) { %>

                        <div class="form-grid">
                            
                            <!-- User ID -->
                            <div class="form-field-group">
                                <label class="field-label">User Identifier</label>
                                <div>
                                    <span style="font-family: monospace; font-size: 14px; font-weight: 700; color: #0F172A;">
                                        <%= viewedUser.getUserId() %>
                                    </span>
                                </div>
                            </div>

                            <!-- Full Name -->
                            <div class="form-field-group">
                                <label class="field-label">Full Name</label>
                                <div style="font-size: 15px; font-weight: 700; color: #0F172A;">
                                    <%= viewedUser.getFullName() != null ? viewedUser.getFullName() : "N/A" %>
                                </div>
                            </div>

                            <!-- Email Address -->
                            <div class="form-field-group">
                                <label class="field-label">Email Address (Login Username)</label>
                                <div style="font-size: 14px; color: #334155;">
                                    <i class="fa-regular fa-envelope" style="color: #64748B; margin-right: 4px;"></i>
                                    <%= viewedUser.getEmail() != null ? viewedUser.getEmail() : "N/A" %>
                                </div>
                            </div>

                            <!-- Phone Number -->
                            <div class="form-field-group">
                                <label class="field-label">Phone Contact</label>
                                <div style="font-size: 14px; color: #334155;">
                                    <i class="fa-solid fa-phone" style="color: #64748B; margin-right: 4px;"></i>
                                    <%= viewedUser.getPhoneNumber() != null && !viewedUser.getPhoneNumber().trim().isEmpty() ? viewedUser.getPhoneNumber() : "Not provided" %>
                                </div>
                            </div>

                            <!-- Role -->
                            <div class="form-field-group">
                                <label class="field-label">Assigned System Role</label>
                                <div>
                                    <span style="display: inline-flex; align-items: center; gap: 6px; padding: 4px 12px; border-radius: 6px; font-size: 12px; font-weight: 700; background: #E2F7E9; color: #166534; border: 1px solid #D5ECCF;">
                                        <i class="fa-solid fa-id-badge"></i>
                                        <%= viewedUser.getRoleName() != null ? viewedUser.getRoleName() : viewedUser.getRoleId() %>
                                    </span>
                                </div>
                            </div>

                            <!-- Assigned Area -->
                            <div class="form-field-group">
                                <label class="field-label">Assigned Campus Area</label>
                                <div style="font-size: 14px; color: #334155;">
                                    <i class="fa-solid fa-map-pin" style="color: #166534; margin-right: 4px;"></i>
                                    <%= viewedUser.getAreaName() != null ? viewedUser.getAreaName() : (viewedUser.getAreaID() != null ? viewedUser.getAreaID() : "All Campus Areas / Global") %>
                                </div>
                            </div>

                            <!-- Account Status -->
                            <div class="form-field-group">
                                <label class="field-label">Account Status</label>
                                <div>
                                    <% if (viewedUser.isStatus()) { %>
                                        <span style="display: inline-flex; align-items: center; gap: 6px; padding: 4px 12px; border-radius: 6px; font-size: 12px; font-weight: 700; background: #DCFCE7; color: #166534; border: 1px solid #BBF7D0;">
                                            <i class="fa-solid fa-circle-check"></i> Active &bull; Enabled
                                        </span>
                                    <% } else { %>
                                        <span style="display: inline-flex; align-items: center; gap: 6px; padding: 4px 12px; border-radius: 6px; font-size: 12px; font-weight: 700; background: #FEE2E2; color: #991B1B; border: 1px solid #FECACA;">
                                            <i class="fa-solid fa-circle-xmark"></i> Inactive &bull; Suspended
                                        </span>
                                    <% } %>
                                </div>
                            </div>

                        </div>

                        <!-- ACTIONS -->
                        <div class="form-actions-bar" style="margin-top: 32px; padding-top: 20px; border-top: 1px solid #E2E8F0; display: flex; flex-wrap: wrap; gap: 12px; align-items: center;">
                            <% if (canManage) { %>
                                <a class="btn-smart-primary" href="<%= ctx %>/user/edit?id=<%= URLEncoder.encode(viewedUser.getUserId(), "UTF-8") %>">
                                    <i class="fa-solid fa-user-pen"></i> Edit User Account
                                </a>
                            <% } %>

                            <a class="btn-smart-secondary" href="<%= ctx %>/user" style="margin-left: auto;">
                                Back to Accounts Directory
                            </a>
                        </div>

                    <% } else { %>

                        <div style="text-align: center; padding: 48px 24px;">
                            <i class="fa-solid fa-triangle-exclamation" style="font-size: 42px; color: #D97706; margin-bottom: 16px;"></i>
                            <h3 style="margin-bottom: 8px;">User Account Not Found</h3>
                            <p style="color: #64748B; max-width: 420px; margin: 0 auto 20px;">
                                The requested user profile could not be retrieved from the directory.
                            </p>
                            <a class="btn-smart-primary" href="<%= ctx %>/user">
                                Return to Accounts List
                            </a>
                        </div>

                    <% } %>
                </div>

            </div>
        </main>
    </div>

</body>
</html>