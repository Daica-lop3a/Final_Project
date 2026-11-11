<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="model.AppUser"%>
<%@page import="model.Area"%>
<%@page import="java.util.List"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%
    String ctx = request.getContextPath();
    AppUser profileUser = (AppUser) request.getAttribute("profileUser");
    if (profileUser == null) {
        profileUser = (AppUser) session.getAttribute("user");
    }
    if (profileUser == null) {
        response.sendRedirect(ctx + "/login");
        return;
    }

    List<Area> assignedAreas = (List<Area>) request.getAttribute("assignedAreas");
    String successMsg = (String) request.getAttribute("SUCCESS_MSG");
    String errorProfile = (String) request.getAttribute("ERROR_PROFILE");
    String errorPassword = (String) request.getAttribute("ERROR_PASSWORD");

    String roleId = profileUser.getRoleId() != null ? profileUser.getRoleId().toUpperCase() : "USR";
    String roleBadgeClass = "badge-role-usr";
    if ("SAD".equals(roleId)) roleBadgeClass = "badge-role-sad";
    else if ("ADM".equals(roleId)) roleBadgeClass = "badge-role-adm";
    else if ("MGR".equals(roleId)) roleBadgeClass = "badge-role-mgr";
    else if ("SUP".equals(roleId)) roleBadgeClass = "badge-role-sup";
    else if ("STF".equals(roleId)) roleBadgeClass = "badge-role-stf";
    else if ("TEC".equals(roleId)) roleBadgeClass = "badge-role-tec";
    else if ("AUD".equals(roleId)) roleBadgeClass = "badge-role-aud";

    String avatarLetter = (profileUser.getFullName() != null && !profileUser.getFullName().trim().isEmpty())
            ? profileUser.getFullName().trim().substring(0, 1).toUpperCase() : "U";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile & Security - SmartWaste</title>

    <link rel="stylesheet" href="<%=ctx%>/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        :root {
            --primary: #00875A;
            --primary-dark: #006644;
            --navy: #050505;
            --slate: #1C1E21;
            --muted: #65676B;
            --border: #D1EBCF;
            --bg-light: #EDF8F2;
            --card-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
        }

        body {
            margin: 0;
            background: #EDF8F2;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            color: #1C1E21;
        }

        .profile-container {
            margin-left: 0;
            width: 100%;
            min-height: 100vh;
            padding: 30px 36px;
            box-sizing: border-box;
            background: #EDF8F2;
        }

        .header-title-box {
            margin-bottom: 24px;
        }

        .header-kicker {
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
            letter-spacing: -0.3px;
        }

        .page-desc {
            margin: 6px 0 0;
            color: #65676B;
            font-size: 14px;
        }

        /* Hero Profile Card */
        .profile-hero {
            background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
            border-radius: 16px;
            padding: 28px 32px;
            color: white;
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 28px;
            box-shadow: 0 10px 25px -5px rgba(15, 23, 42, 0.2);
            position: relative;
            overflow: hidden;
        }

        .profile-hero::before {
            content: "";
            position: absolute;
            top: -50px;
            right: -50px;
            width: 200px;
            height: 200px;
            background: radial-gradient(circle, rgba(16, 185, 129, 0.2) 0%, transparent 70%);
            border-radius: 50%;
        }

        .hero-left {
            display: flex;
            align-items: center;
            gap: 24px;
            z-index: 1;
        }

        .avatar-circle {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background: linear-gradient(135deg, #10b981 0%, #047857 100%);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 32px;
            font-weight: 800;
            border: 4px solid rgba(255, 255, 255, 0.2);
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
        }

        .hero-name {
            font-size: 24px;
            font-weight: 800;
            margin: 0 0 6px 0;
            letter-spacing: -0.3px;
        }

        .hero-meta {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
            font-size: 13px;
        }

        .badge-role-sad,
        .badge-role-adm,
        .badge-role-mgr,
        .badge-role-sup,
        .badge-role-stf,
        .badge-role-tec,
        .badge-role-aud,
        .badge-role-usr {
            background: #EDF8F2 !important;
            color: #1C1E21 !important;
            border: 1px solid #D1EBCF !important;
        }

        .role-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 0.3px;
        }

        .status-pill {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 4px 10px;
            border-radius: 20px;
            background: rgba(16, 185, 129, 0.2);
            color: #34d399;
            font-size: 12px;
            font-weight: 600;
        }

        .hero-right-meta {
            text-align: right;
            z-index: 1;
            font-size: 13px;
            color: #94a3b8;
        }

        .hero-right-meta strong {
            display: block;
            color: #f1f5f9;
            font-size: 15px;
            margin-top: 2px;
        }

        /* Feedback Alerts */
        .alert-box {
            padding: 14px 18px;
            border-radius: 10px;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 14px;
            font-weight: 500;
        }

        .alert-success {
            background: #dcfce7;
            color: #166534;
            border: 1px solid #bbf7d0;
        }

        .alert-danger {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fecaca;
        }

        /* Two-Column Grid */
        .profile-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 28px;
        }

        .card {
            background: white;
            border-radius: 16px;
            padding: 28px;
            box-shadow: var(--card-shadow);
            border: 1px solid var(--border);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .card-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 22px;
            padding-bottom: 16px;
            border-bottom: 1px solid #f1f5f9;
        }

        .card-icon {
            width: 42px;
            height: 42px;
            border-radius: 10px;
            background: #ecfdf5;
            color: #10b981;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
        }

        .card-icon-warning {
            background: #eff6ff;
            color: #3b82f6;
        }

        .card-title {
            margin: 0;
            font-size: 18px;
            font-weight: 700;
            color: var(--navy);
        }

        .card-subtitle {
            margin: 3px 0 0;
            font-size: 12px;
            color: var(--muted);
        }

        .form-group {
            margin-bottom: 18px;
        }

        .form-group label {
            display: block;
            margin-bottom: 6px;
            font-size: 13px;
            font-weight: 700;
            color: #334155;
        }

        .form-control {
            width: 100%;
            padding: 11px 14px;
            border: 1px solid var(--border);
            border-radius: 8px;
            font-size: 14px;
            box-sizing: border-box;
            background: white;
            color: #1e293b;
            transition: border-color 0.15s ease, box-shadow 0.15s ease;
        }

        .form-control:focus {
            outline: none;
            border-color: #10b981;
            box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.15);
        }

        .form-control:disabled,
        .form-control[readonly] {
            background: #f8fafc;
            color: #64748b;
            cursor: not-allowed;
            border-color: #e2e8f0;
        }

        .field-hint {
            display: block;
            margin-top: 5px;
            font-size: 11px;
            color: #64748b;
        }

        .field-hint i {
            margin-right: 3px;
        }

        .security-notes {
            background: #f8fafc;
            border: 1px dashed #cbd5e1;
            border-radius: 8px;
            padding: 12px 14px;
            margin-bottom: 20px;
            font-size: 12px;
            color: #475569;
        }

        .security-notes ul {
            margin: 6px 0 0 16px;
            padding: 0;
        }

        .security-notes li {
            margin-bottom: 3px;
        }

        .btn-submit {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 12px 20px;
            border: none;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.2s ease;
            width: 100%;
        }

        .btn-save {
            background: #10b981;
            color: white;
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.25);
        }

        .btn-save:hover {
            background: #059669;
            transform: translateY(-1px);
        }

        .btn-security {
            background: #2563eb;
            color: white;
            box-shadow: 0 4px 12px rgba(37, 99, 235, 0.25);
        }

        .btn-security:hover {
            background: #1d4ed8;
            transform: translateY(-1px);
        }

        @media (max-width: 1024px) {
            .profile-grid {
                grid-template-columns: 1fr;
            }
            .profile-container {
                padding: 20px;
            }
        }
    </style>
</head>
<body>

    <!-- Unified Navigation Sidebar -->
    <jsp:include page="/WEB-INF/views/sidebar.jsp" />

    <main class="profile-container">

        <!-- Header -->
        <div class="header-title-box">
            <span class="header-kicker">
                <i class="fa-solid fa-user-shield"></i> Unified User Portal
            </span>
            <h1 class="page-title">My Profile & Security</h1>
        </div>

        <!-- Feedback Alert Messages -->
        <% if (successMsg != null) { %>
            <div class="alert-box alert-success">
                <i class="fa-solid fa-circle-check" style="font-size: 18px;"></i>
                <span><%= successMsg %></span>
            </div>
        <% } %>

        <% if (errorProfile != null) { %>
            <div class="alert-box alert-danger">
                <i class="fa-solid fa-triangle-exclamation" style="font-size: 18px;"></i>
                <span><%= errorProfile %></span>
            </div>
        <% } %>

        <% if (errorPassword != null) { %>
            <div class="alert-box alert-danger">
                <i class="fa-solid fa-triangle-exclamation" style="font-size: 18px;"></i>
                <span><%= errorPassword %></span>
            </div>
        <% } %>

        <!-- User Identity Hero Card -->
        <section class="profile-hero">
            <div class="hero-left">
                <div class="avatar-circle">
                    <%= avatarLetter %>
                </div>
                <div>
                    <h2 class="hero-name"><%= profileUser.getFullName() != null ? profileUser.getFullName() : "User" %></h2>
                    <div class="hero-meta">
                        <span class="role-pill <%= roleBadgeClass %>">
                            <i class="fa-solid fa-shield-halved"></i> <%= profileUser.getRoleName() %>
                        </span>
                        <span class="status-pill">
                            <i class="fa-solid fa-circle" style="font-size: 8px;"></i> Active Account
                        </span>
                        <span style="color: #94a3b8; font-size: 13px;">
                            <i class="fa-solid fa-fingerprint"></i> ID: <strong><%= profileUser.getUserId() %></strong>
                        </span>
                    </div>
                </div>
            </div>

            <div class="hero-right-meta">
                <div>Assigned Jurisdiction / Zone</div>
                <strong>
                    <% if (assignedAreas != null && !assignedAreas.isEmpty()) { %>
                        <%= assignedAreas.get(0).getAreaName() %>
                        <% if (assignedAreas.size() > 1) { %>
                            (+<%= assignedAreas.size() - 1 %> more)
                        <% } %>
                    <% } else if (profileUser.getAreaName() != null && !profileUser.getAreaName().trim().isEmpty()) { %>
                        <%= profileUser.getAreaName() %>
                    <% } else { %>
                        System-Wide Access
                    <% } %>
                </strong>
            </div>
        </section>

        <!-- Two-Column Cards: Profile vs Password -->
        <div class="profile-grid">

            <!-- Card 1: Personal Information -->
            <div class="card">
                <div>
                    <div class="card-header">
                        <div class="card-icon">
                            <i class="fa-solid fa-id-card"></i>
                        </div>
                        <div>
                            <h3 class="card-title">Personal Information</h3>
                            <p class="card-subtitle">Keep your personal contact details current</p>
                        </div>
                    </div>

                    <form action="<%=ctx%>/profile" method="POST">
                        <input type="hidden" name="action" value="update_profile">

                        <!-- System User ID (Read-only) -->
                        <div class="form-group">
                            <label>User Identifier (Account ID)</label>
                            <input type="text" class="form-control" value="<%= profileUser.getUserId() %>" readonly disabled>
                            <span class="field-hint">
                                <i class="fa-solid fa-lock"></i> Fixed system identifier assigned upon account creation.
                            </span>
                        </div>

                        <!-- Role & Authority (Read-only) -->
                        <div class="form-group">
                            <label>Assigned System Role</label>
                            <input type="text" class="form-control" value="<%= profileUser.getRoleName() %> (<%= profileUser.getRoleId() %>)" readonly disabled>
                            <span class="field-hint">
                                <i class="fa-solid fa-shield"></i> Security permissions can only be altered by Super Admin.
                            </span>
                        </div>

                        <!-- Jurisdiction (Read-only) -->
                        <div class="form-group">
                            <label>Assigned Operational Area</label>
                            <input type="text" class="form-control" value="<% if (assignedAreas != null && !assignedAreas.isEmpty()) { %><%= assignedAreas.get(0).getAreaName() %><% if (assignedAreas.size() > 1) { %> (+<%= assignedAreas.size() - 1 %> more)<% } %><% } else if (profileUser.getAreaName() != null) { %><%= profileUser.getAreaName() %><% } else { %>System-Wide / All Areas<% } %>" readonly disabled>
                            <span class="field-hint">
                                <i class="fa-solid fa-location-dot"></i> Assigned by Administrator or Operations Management.
                            </span>
                        </div>

                        <!-- Editable: Full Name -->
                        <div class="form-group">
                            <label for="fullName">Full Name</label>
                            <input type="text" id="fullName" name="fullName" class="form-control"
                                   value="<%= profileUser.getFullName() != null ? profileUser.getFullName() : "" %>"
                                   required maxlength="100" placeholder="e.g. Tran Dai Nam">
                        </div>

                        <!-- Editable: Email -->
                        <div class="form-group">
                            <label for="email">Email Address</label>
                            <input type="email" id="email" name="email" class="form-control"
                                   value="<%= profileUser.getEmail() != null ? profileUser.getEmail() : "" %>"
                                   required maxlength="100" placeholder="e.g. user@smartwaste.vn">
                        </div>

                        <!-- Editable: Phone -->
                        <div class="form-group">
                            <label for="phoneNumber">Phone Number</label>
                            <input type="tel" id="phoneNumber" name="phoneNumber" class="form-control"
                                   value="<%= profileUser.getPhoneNumber() != null ? profileUser.getPhoneNumber() : "" %>"
                                   pattern="^(0|\+84)[35789][0-9]{8}$"
                                   title="Vietnamese mobile phone: 10 digits starting with 03, 05, 07, 08, 09 or +84"
                                   required maxlength="15" placeholder="e.g. 0912345678">
                            <small style="display: block; margin-top: 4px; font-size: 11px; color: #5E7E70;">Vietnamese mobile phone (10 digits starting with 03, 05, 07, 08, 09 or +84).</small>
                        </div>

                        <div style="margin-top: 26px;">
                            <button type="submit" class="btn-submit btn-save">
                                <i class="fa-solid fa-floppy-disk"></i> Save Profile Details
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Card 2: Security & Password -->
            <div class="card">
                <div>
                    <div class="card-header">
                        <div class="card-icon card-icon-warning">
                            <i class="fa-solid fa-key"></i>
                        </div>
                        <div>
                            <h3 class="card-title">Security & Password</h3>
                            <p class="card-subtitle">Change your password to keep your account safe</p>
                        </div>
                    </div>

                    <div class="security-notes">
                        <strong><i class="fa-solid fa-shield-halved"></i> Password Requirements:</strong>
                        <ul>
                            <li>Minimum length of 6 characters.</li>
                            <li>Must not match your current password.</li>
                            <li>Both new password and confirm fields must match exactly.</li>
                        </ul>
                    </div>

                    <form action="<%=ctx%>/profile" method="POST">
                        <input type="hidden" name="action" value="change_password">

                        <!-- Current Password -->
                        <div class="form-group">
                            <label for="oldPassword">Current Password</label>
                            <input type="password" id="oldPassword" name="oldPassword" class="form-control"
                                   required placeholder="Enter your current password">
                            <span class="field-hint">
                                <i class="fa-solid fa-asterisk"></i> Required to verify your identity.
                            </span>
                        </div>

                        <!-- New Password -->
                        <div class="form-group">
                            <label for="newPassword">New Password</label>
                            <input type="password" id="newPassword" name="newPassword" class="form-control"
                                   required minlength="6" placeholder="Enter new password (min. 6 characters)">
                        </div>

                        <!-- Confirm New Password -->
                        <div class="form-group">
                            <label for="confirmPassword">Confirm New Password</label>
                            <input type="password" id="confirmPassword" name="confirmPassword" class="form-control"
                                   required minlength="6" placeholder="Re-type new password">
                        </div>

                        <div style="margin-top: 26px;">
                            <button type="submit" class="btn-submit btn-security">
                                <i class="fa-solid fa-lock"></i> Update Password
                            </button>
                        </div>
                    </form>

                    <% if (profileUser.isAdmin()) { %>
                    <div style="margin-top: 24px; padding-top: 18px; border-top: 1px dashed #cbd5e1;">
                        <div style="font-size: 13px; font-weight: 700; color: #1e293b; margin-bottom: 6px;">
                            <i class="fa-solid fa-user-shield" style="color: #7c3aed;"></i> Need a Super Admin Reset?
                        </div>
                        <p style="font-size: 12px; color: #64748b; margin: 0 0 10px 0;">
                            Per security governance, System Admins may submit an official credential reset request for Super Admin approval.
                        </p>
                        <form action="<%=ctx%>/admin-approval" method="POST" onsubmit="return confirm('Submit formal password reset request to Super Admin?');">
                            <input type="hidden" name="action" value="request">
                            <input type="hidden" name="reason" value="Admin requested credential renewal via profile portal">
                            <button type="submit" style="width: 100%; padding: 10px 14px; background: #f5f3ff; border: 1px solid #c084fc; border-radius: 8px; color: #7c3aed; font-weight: 700; font-size: 12px; cursor: pointer;">
                                <i class="fa-solid fa-paper-plane"></i> Request Super Admin Password Reset
                            </button>
                        </form>
                    </div>
                    <% } %>
                </div>
            </div>

        </div>

    </main>

</body>
</html>
