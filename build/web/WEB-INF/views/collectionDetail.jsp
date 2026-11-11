<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="model.CollectionRequest"%>
<%@page import="model.AppUser"%>
<%@page import="java.net.URLEncoder"%>

<%
    CollectionRequest collection = (CollectionRequest) request.getAttribute("REQUEST");
    AppUser currentUser = (AppUser) session.getAttribute("user");

    String role = currentUser != null ? currentUser.getRoleId() : "";

    boolean isStaff = "STF".equals(role);
    boolean isSupervisor = "SUP".equals(role) || "MGR".equals(role);
    boolean isAdmin = "ADM".equals(role) || "SAD".equals(role);
    boolean isAssignedStaff = isStaff && collection != null && currentUser != null && currentUser.getUserId().equals(collection.getStaffID());
    boolean canEdit = isAdmin || isSupervisor || isAssignedStaff;
    boolean canDelete = isAdmin || isSupervisor;
    String ctx = request.getContextPath();

    String statusBadgeBg = "#FEF3C7";
    String statusBadgeColor = "#B45309";
    String statusBadgeBorder = "#FDE68A";
    String statusLabel = "Pending";

    if (collection != null && collection.getStatus() != null) {
        String st = collection.getStatus();
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
        } else if ("Verified".equalsIgnoreCase(st)) {
            statusBadgeBg = "#DCFCE7";
            statusBadgeColor = "#166534";
            statusBadgeBorder = "#86EFAC";
            statusLabel = "Verified";
        } else if ("Failed".equalsIgnoreCase(st)) {
            statusBadgeBg = "#FEE2E2";
            statusBadgeColor = "#991B1B";
            statusBadgeBorder = "#FCA5A5";
            statusLabel = "Failed";
        } else if ("Skipped".equalsIgnoreCase(st)) {
            statusBadgeBg = "#F1F5F9";
            statusBadgeColor = "#475569";
            statusBadgeBorder = "#CBD5E1";
            statusLabel = "Skipped";
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
    <title>Collection Request Details - SmartWaste</title>

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
                        <a href="<%=ctx%>/collection">Collection Tasks</a>
                        <i class="fa-solid fa-chevron-right"></i>
                        <span>Task Details</span>
                    </div>
                    <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px; margin-top: 10px;">
                        <div>
                            <span class="badge-role-pill">FIELD LOGISTICS &bull; TASK</span>
                            <h1 style="margin: 6px 0 0; font-size: 26px; font-weight: 800; color: #0F172A;">
                                Collection Task #<%= collection != null && collection.getRequestID() != null ? collection.getRequestID() : "N/A" %>
                            </h1>
                        </div>
                        <div>
                            <a href="<%=ctx%>/collection" class="btn-smart-secondary" style="font-size: 13px;">
                                <i class="fa-solid fa-arrow-left"></i> Back to Tasks
                            </a>
                        </div>
                    </div>
                </div>

                <!-- CARD -->
                <div class="smartwaste-form-card">
                    <% if (collection != null) { %>

                        <div class="form-grid">
                            
                            <!-- Request ID -->
                            <div class="form-field-group">
                                <label class="field-label">Task Identifier</label>
                                <div>
                                    <span style="font-family: monospace; font-size: 15px; font-weight: 700; color: #0F172A;">
                                        <%= collection.getRequestID() %>
                                    </span>
                                </div>
                            </div>

                            <!-- Waste Bin Target -->
                            <div class="form-field-group">
                                <label class="field-label">Target Waste Bin</label>
                                <div>
                                    <a href="<%=ctx%>/wastebin/detail?id=<%= URLEncoder.encode(collection.getBinID(), "UTF-8") %>" style="display: inline-flex; align-items: center; gap: 6px; font-weight: 700; color: #166534; background: #E2F7E9; padding: 4px 12px; border-radius: 6px; text-decoration: none;">
                                        <i class="fa-solid fa-trash-can"></i> <%= collection.getBinID() %>
                                    </a>
                                </div>
                            </div>

                            <!-- Assigned Staff -->
                            <div class="form-field-group">
                                <label class="field-label">Assigned Collection Staff</label>
                                <div>
                                    <% if (collection.getStaffID() != null && !collection.getStaffID().trim().isEmpty()) { %>
                                        <span style="display: inline-flex; align-items: center; gap: 6px; font-weight: 600; color: #0F172A; background: #F8FAF9; border: 1px solid #E2E8F0; padding: 4px 10px; border-radius: 6px;">
                                            <i class="fa-solid fa-person-walking-luggage" style="color: #166534;"></i>
                                            <%= collection.getStaffID() %>
                                        </span>
                                    <% } else { %>
                                        <span style="color: #94A3B8; font-style: italic;">Unassigned (Queue)</span>
                                    <% } %>
                                </div>
                            </div>

                            <!-- Status -->
                            <div class="form-field-group">
                                <label class="field-label">Operational Status</label>
                                <div>
                                    <span style="display: inline-flex; align-items: center; gap: 6px; padding: 4px 12px; border-radius: 6px; font-size: 12px; font-weight: 700; background: <%= statusBadgeBg %>; color: <%= statusBadgeColor %>; border: 1px solid <%= statusBadgeBorder %>;">
                                        <%= statusLabel %>
                                    </span>
                                </div>
                            </div>

                            <!-- Priority -->
                            <div class="form-field-group">
                                <label class="field-label">Dispatch Priority</label>
                                <div>
                                    <span style="font-size: 13px; font-weight: 700; color: #0F172A;">
                                        <%= collection.getPriority() != null ? collection.getPriority() : "Normal" %>
                                    </span>
                                </div>
                            </div>

                            <!-- Created Date -->
                            <div class="form-field-group">
                                <label class="field-label">Creation Timestamp</label>
                                <div style="font-size: 14px; color: #334155;">
                                    <i class="fa-regular fa-clock" style="color: #64748B; margin-right: 4px;"></i>
                                    <%= collection.getCreatedDate() != null ? collection.getCreatedDate() : "N/A" %>
                                </div>
                            </div>

                            <!-- Notes (Full Width) -->
                            <div class="form-field-group form-field-full">
                                <label class="field-label">Field Notes &amp; Route Instructions</label>
                                <div style="background: #F8FAF9; border: 1px solid #E2E8F0; border-radius: 8px; padding: 14px 16px; font-size: 14px; color: #1E293B; line-height: 1.6; white-space: pre-wrap;">
                                    <%= collection.getNotes() != null && !collection.getNotes().trim().isEmpty() ? collection.getNotes() : "No additional instructions noted." %>
                                </div>
                            </div>

                            <% if (collection != null && ((collection.getPhotoBefore() != null && !collection.getPhotoBefore().trim().isEmpty()) || (collection.getPhotoAfter() != null && !collection.getPhotoAfter().trim().isEmpty()))) { %>
                            <!-- Field Verification Photos -->
                            <div class="form-field-group form-field-full">
                                <label class="field-label">Field Completion Photos</label>
                                <div style="display: flex; gap: 16px; flex-wrap: wrap;">
                                    <% if (collection.getPhotoBefore() != null && !collection.getPhotoBefore().trim().isEmpty()) { %>
                                        <div>
                                            <div style="font-size: 12px; color: #64748B; margin-bottom: 4px; font-weight: 600;">Before Emptying:</div>
                                            <img src="<%= collection.getPhotoBefore() %>" alt="Before Emptying" style="width: 180px; height: 120px; object-fit: cover; border-radius: 8px; border: 1px solid #CBD5E1;">
                                        </div>
                                    <% } %>
                                    <% if (collection.getPhotoAfter() != null && !collection.getPhotoAfter().trim().isEmpty()) { %>
                                        <div>
                                            <div style="font-size: 12px; color: #64748B; margin-bottom: 4px; font-weight: 600;">After Emptying:</div>
                                            <img src="<%= collection.getPhotoAfter() %>" alt="After Emptying" style="width: 180px; height: 120px; object-fit: cover; border-radius: 8px; border: 1px solid #CBD5E1;">
                                        </div>
                                    <% } %>
                                </div>
                            </div>
                            <% } %>

                        </div>

                        <!-- ACTIONS -->
                        <div class="form-actions-bar" style="margin-top: 32px; padding-top: 20px; border-top: 1px solid #E2E8F0; display: flex; flex-wrap: wrap; gap: 12px; align-items: center;">
                            <% if (isAssignedStaff && "Pending".equalsIgnoreCase(collection.getStatus())) { %>
                                <a class="btn-smart-primary" href="<%= ctx %>/collection/start?id=<%= URLEncoder.encode(collection.getRequestID(), "UTF-8") %>">
                                    <i class="fa-solid fa-play"></i> Start Mission
                                </a>
                            <% } %>

                            <% if (canEdit) { %>
                                <a class="btn-smart-primary" href="<%= ctx %>/collection/edit?id=<%= URLEncoder.encode(collection.getRequestID(), "UTF-8") %>">
                                    <i class="fa-solid fa-pen-to-square"></i> <%= isStaff ? "Update Field Status" : "Edit Task" %>
                                </a>
                            <% } %>

                            <% if ((isSupervisor || isAdmin) && "Completed".equalsIgnoreCase(collection.getStatus())) { %>
                                <form method="post" action="<%= ctx %>/collection/verify" onsubmit="return confirm('Verify and close collection task <%= collection.getRequestID() %>?');" style="display: inline; margin: 0;">
                                    <input type="hidden" name="requestID" value="<%= collection.getRequestID() %>">
                                    <button class="btn-smart-primary" style="background: #166534;" type="submit">
                                        <i class="fa-solid fa-check-double"></i> Verify Completion
                                    </button>
                                </form>
                            <% } %>

                            <% if (canDelete) { %>
                                <form method="post" action="<%= ctx %>/collection/delete" onsubmit="return confirm('Are you sure you want to delete this collection request?');" style="display: inline; margin: 0;">
                                    <input type="hidden" name="id" value="<%= collection.getRequestID() %>">
                                    <button class="btn-smart-secondary" style="color: #DC2626; border-color: #FCA5A5; background: #FEF2F2;" type="submit">
                                        <i class="fa-solid fa-trash-can"></i> Delete Task
                                    </button>
                                </form>
                            <% } %>

                            <a class="btn-smart-secondary" href="<%= ctx %>/collection" style="margin-left: auto;">
                                Back to Collection List
                            </a>
                        </div>

                    <% } else { %>

                        <div style="text-align: center; padding: 48px 24px;">
                            <i class="fa-solid fa-triangle-exclamation" style="font-size: 42px; color: #D97706; margin-bottom: 16px;"></i>
                            <h3 style="margin-bottom: 8px;">Collection Task Not Found</h3>
                            <p style="color: #64748B; max-width: 420px; margin: 0 auto 20px;">
                                The requested collection task does not exist or has been archived.
                            </p>
                            <a class="btn-smart-primary" href="<%= ctx %>/collection">
                                Return to Tasks List
                            </a>
                        </div>

                    <% } %>
                </div>

            </div>
        </main>
    </div>

</body>
</html>