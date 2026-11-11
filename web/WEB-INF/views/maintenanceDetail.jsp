<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="model.Maintenance"%>
<%@page import="model.AppUser"%>
<%@page import="java.net.URLEncoder"%>

<%
    Maintenance maintenance = (Maintenance) request.getAttribute("MAINTENANCE");
    AppUser user = (AppUser) session.getAttribute("user");

    String role = user != null ? user.getRoleId() : "";

    boolean canManage = "ADM".equals(role)
            || "MGR".equals(role)
            || "SUP".equals(role)
            || "SAD".equals(role);

    boolean canEdit = canManage
            || ("TEC".equals(role)
            && maintenance != null
            && user.getUserId().equals(maintenance.getTechnicianID()));

    String ctx = request.getContextPath();

    String statusBadgeBg = "#FEF3C7";
    String statusBadgeColor = "#B45309";
    String statusBadgeBorder = "#FDE68A";
    String statusLabel = "Scheduled";

    if (maintenance != null && maintenance.getStatus() != null) {
        String st = maintenance.getStatus();
        if ("In_Progress".equalsIgnoreCase(st) || "In Progress".equalsIgnoreCase(st)) {
            statusBadgeBg = "#E0F2FE";
            statusBadgeColor = "#0369A1";
            statusBadgeBorder = "#BAE6FD";
            statusLabel = "In Progress";
        } else if ("Completed".equalsIgnoreCase(st)) {
            statusBadgeBg = "#DCFCE7";
            statusBadgeColor = "#166534";
            statusBadgeBorder = "#BBF7D0";
            statusLabel = "Completed";
        } else if ("Cancelled".equalsIgnoreCase(st)) {
            statusBadgeBg = "#FEE2E2";
            statusBadgeColor = "#991B1B";
            statusBadgeBorder = "#FECACA";
            statusLabel = "Cancelled";
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Maintenance Details - SmartWaste</title>

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
                        <a href="<%=ctx%>/maintenance">Hardware Maintenance</a>
                        <i class="fa-solid fa-chevron-right"></i>
                        <span>Ticket Details</span>
                    </div>
                    <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px; margin-top: 10px;">
                        <div>
                            <span class="badge-role-pill">IOT HARDWARE &bull; TICKET</span>
                            <h1 style="margin: 6px 0 0; font-size: 26px; font-weight: 800; color: #0F172A;">
                                Maintenance Ticket #<%= maintenance != null && maintenance.getMaintenanceID() != null ? maintenance.getMaintenanceID() : "N/A" %>
                            </h1>
                        </div>
                        <div>
                            <a href="<%=ctx%>/maintenance" class="btn-smart-secondary" style="font-size: 13px;">
                                <i class="fa-solid fa-arrow-left"></i> Back to Maintenance
                            </a>
                        </div>
                    </div>
                </div>

                <!-- CARD -->
                <div class="smartwaste-form-card">
                    <% if (maintenance != null) { %>

                        <div class="form-grid">
                            
                            <!-- Maintenance ID -->
                            <div class="form-field-group">
                                <label class="field-label">Ticket Identifier</label>
                                <div>
                                    <span style="font-family: monospace; font-size: 15px; font-weight: 700; color: #0F172A;">
                                        <%= maintenance.getMaintenanceID() %>
                                    </span>
                                </div>
                            </div>

                            <!-- Target Waste Bin -->
                            <div class="form-field-group">
                                <label class="field-label">Target Waste Bin</label>
                                <div>
                                    <% if (maintenance.getBinID() != null && !maintenance.getBinID().trim().isEmpty()) { %>
                                        <a href="<%=ctx%>/wastebin/detail?id=<%= URLEncoder.encode(maintenance.getBinID(), "UTF-8") %>" style="display: inline-flex; align-items: center; gap: 6px; font-weight: 700; color: #166534; background: #E2F7E9; padding: 6px 14px; border-radius: 8px; text-decoration: none;">
                                            <i class="fa-solid fa-trash-can" style="color: #059669;"></i>
                                            <span><%= maintenance.getBinCode() != null && !maintenance.getBinCode().trim().isEmpty() ? maintenance.getBinCode() : maintenance.getBinID() %></span>
                                            <% if (maintenance.getLocation() != null && !maintenance.getLocation().trim().isEmpty()) { %>
                                                <span style="font-weight: 500; color: #334155;">&mdash; <%= maintenance.getLocation() %></span>
                                            <% } %>
                                            <span style="font-size: 11px; color: #059669; font-weight: 600;">(<%= maintenance.getBinID() %>)</span>
                                        </a>
                                    <% } else { %>
                                        <span style="color: #94A3B8;">General Asset</span>
                                    <% } %>
                                </div>
                            </div>

                            <!-- Technician Assigned -->
                            <div class="form-field-group">
                                <label class="field-label">Assigned Technician</label>
                                <div>
                                    <% if (maintenance.getTechnicianID() != null && !maintenance.getTechnicianID().trim().isEmpty()) { %>
                                        <span style="display: inline-flex; align-items: center; gap: 6px; font-weight: 600; color: #0F172A; background: #F8FAF9; border: 1px solid #E2E8F0; padding: 6px 12px; border-radius: 8px;">
                                            <i class="fa-solid fa-wrench" style="color: #166534;"></i>
                                            <span><%= maintenance.getTechnicianName() != null && !maintenance.getTechnicianName().trim().isEmpty() ? maintenance.getTechnicianName() : maintenance.getTechnicianID() %></span>
                                            <span style="font-size: 11px; color: #64748B; font-family: monospace;">(<%= maintenance.getTechnicianID() %>)</span>
                                        </span>
                                    <% } else { %>
                                        <span style="color: #94A3B8; font-style: italic;">Unassigned (Queue)</span>
                                    <% } %>
                                </div>
                            </div>

                            <!-- Status -->
                            <div class="form-field-group">
                                <label class="field-label">Maintenance Status</label>
                                <div>
                                    <span style="display: inline-flex; align-items: center; gap: 6px; padding: 4px 12px; border-radius: 6px; font-size: 12px; font-weight: 700; background: <%= statusBadgeBg %>; color: <%= statusBadgeColor %>; border: 1px solid <%= statusBadgeBorder %>;">
                                        <%= statusLabel %>
                                    </span>
                                </div>
                            </div>

                            <!-- Scheduled Date -->
                            <div class="form-field-group">
                                <label class="field-label">Scheduled Service Date</label>
                                <div style="font-size: 14px; color: #334155;">
                                    <i class="fa-regular fa-calendar-check" style="color: #64748B; margin-right: 4px;"></i>
                                    <%= maintenance.getScheduledDate() != null ? maintenance.getScheduledDate() : "N/A" %>
                                </div>
                            </div>

                            <!-- Description (Full Width) -->
                            <div class="form-field-group form-field-full">
                                <label class="field-label">Technical Diagnostic &amp; Resolution Log</label>
                                <div style="background: #F8FAF9; border: 1px solid #E2E8F0; border-radius: 8px; padding: 14px 16px; font-size: 14px; color: #1E293B; line-height: 1.6; white-space: pre-wrap;">
                                    <%= maintenance.getDescription() != null && !maintenance.getDescription().trim().isEmpty() ? maintenance.getDescription() : "No technical notes documented." %>
                                </div>
                            </div>

                        </div>

                        <!-- ACTIONS -->
                        <div class="form-actions-bar" style="margin-top: 32px; padding-top: 20px; border-top: 1px solid #E2E8F0; display: flex; flex-wrap: wrap; gap: 12px; align-items: center;">
                            <% if (canEdit) { %>
                                <a class="btn-smart-primary" href="<%= ctx %>/maintenance/edit?id=<%= URLEncoder.encode(maintenance.getMaintenanceID(), "UTF-8") %>">
                                    <i class="fa-solid fa-pen-to-square"></i> Update Maintenance Ticket
                                </a>
                            <% } %>

                            <a class="btn-smart-secondary" href="<%= ctx %>/maintenance" style="margin-left: auto;">
                                Back to Tickets List
                            </a>
                        </div>

                    <% } else { %>

                        <div style="text-align: center; padding: 48px 24px;">
                            <i class="fa-solid fa-triangle-exclamation" style="font-size: 42px; color: #D97706; margin-bottom: 16px;"></i>
                            <h3 style="margin-bottom: 8px;">Maintenance Ticket Not Found</h3>
                            <p style="color: #64748B; max-width: 420px; margin: 0 auto 20px;">
                                The requested maintenance ticket does not exist or has been removed.
                            </p>
                            <a class="btn-smart-primary" href="<%= ctx %>/maintenance">
                                Return to Maintenance List
                            </a>
                        </div>

                    <% } %>
                </div>

            </div>
        </main>
    </div>

</body>
</html>