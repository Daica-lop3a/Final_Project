<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="model.Alert"%>
<%@page import="model.AppUser"%>
<%@page import="java.net.URLEncoder"%>

<%
    Alert alert = (Alert) request.getAttribute("ALERT");
    AppUser user = (AppUser) session.getAttribute("user");

    boolean canManage = user != null
            && ("ADM".equals(user.getRoleId())
            || "MGR".equals(user.getRoleId())
            || "SUP".equals(user.getRoleId())
            || "SAD".equals(user.getRoleId()));

    boolean canDelete = user != null
            && ("ADM".equals(user.getRoleId())
            || "MGR".equals(user.getRoleId())
            || "SAD".equals(user.getRoleId()));

    String ctx = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Alert Details - SmartWaste</title>

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
                        <a href="<%=ctx%>/alert">Alerts</a>
                        <i class="fa-solid fa-chevron-right"></i>
                        <span>Alert Details</span>
                    </div>
                    <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px; margin-top: 10px;">
                        <div>
                            <span class="badge-role-pill">TELEMETRY &bull; INCIDENT</span>
                            <h1 style="margin: 6px 0 0; font-size: 26px; font-weight: 800; color: #0F172A;">
                                Alert #<%= alert != null && alert.getAlertID() != null ? alert.getAlertID() : "Not Found" %>
                            </h1>
                        </div>
                        <div>
                            <a href="<%=ctx%>/alert" class="btn-smart-secondary" style="font-size: 13px;">
                                <i class="fa-solid fa-arrow-left"></i> Back to Alerts
                            </a>
                        </div>
                    </div>
                </div>

                <!-- CARD -->
                <div class="smartwaste-form-card">
                    <% if (alert != null) { %>

                        <div class="form-grid">
                            
                            <!-- Alert ID -->
                            <div class="form-field-group">
                                <label class="field-label">Alert Identifier</label>
                                <div style="display: flex; align-items: center; gap: 8px;">
                                    <span style="font-family: monospace; font-size: 15px; font-weight: 700; color: #0F172A;">
                                        <%= alert.getAlertID() %>
                                    </span>
                                </div>
                            </div>

                            <!-- Waste Bin -->
                            <div class="form-field-group">
                                <label class="field-label">Waste Bin Target</label>
                                <div>
                                    <% if (alert.getBinID() != null && !alert.getBinID().trim().isEmpty()) { %>
                                        <a href="<%=ctx%>/wastebin/detail?id=<%= URLEncoder.encode(alert.getBinID(), "UTF-8") %>" style="display: inline-flex; align-items: center; gap: 6px; font-weight: 700; color: #166534; background: #E2F7E9; padding: 4px 10px; border-radius: 6px; text-decoration: none;">
                                            <i class="fa-solid fa-trash-can"></i> <%= alert.getBinID() %>
                                        </a>
                                    <% } else { %>
                                        <span style="color: #64748B;">Global / System Level</span>
                                    <% } %>
                                </div>
                            </div>

                            <!-- Alert Type -->
                            <div class="form-field-group">
                                <label class="field-label">Alert Classification</label>
                                <div>
                                    <span style="display: inline-block; padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 700; background: #FEF3C7; color: #B45309; border: 1px solid #FDE68A;">
                                        <%= alert.getAlertType() != null ? alert.getAlertType() : "GENERAL" %>
                                    </span>
                                </div>
                            </div>

                            <!-- Status -->
                            <div class="form-field-group">
                                <label class="field-label">Current Status</label>
                                <div>
                                    <% if (alert.isResolved()) { %>
                                        <span style="display: inline-flex; align-items: center; gap: 6px; padding: 4px 12px; border-radius: 6px; font-size: 12px; font-weight: 700; background: #DCFCE7; color: #166534; border: 1px solid #BBF7D0;">
                                            <i class="fa-solid fa-check"></i> Resolved
                                        </span>
                                    <% } else { %>
                                        <span style="display: inline-flex; align-items: center; gap: 6px; padding: 4px 12px; border-radius: 6px; font-size: 12px; font-weight: 700; background: #FEE2E2; color: #991B1B; border: 1px solid #FECACA;">
                                            <i class="fa-solid fa-circle-exclamation"></i> Unresolved &bull; Action Required
                                        </span>
                                    <% } %>
                                </div>
                            </div>

                            <!-- Created Date -->
                            <div class="form-field-group">
                                <label class="field-label">Triggered Timestamp</label>
                                <div style="font-size: 14px; color: #334155;">
                                    <i class="fa-regular fa-clock" style="color: #64748B; margin-right: 4px;"></i>
                                    <%= alert.getCreatedDate() != null ? alert.getCreatedDate() : "N/A" %>
                                </div>
                            </div>

                            <!-- Message (Full Width) -->
                            <div class="form-field-group form-field-full">
                                <label class="field-label">Diagnostic Message</label>
                                <div style="background: #F8FAF9; border: 1px solid #E2E8F0; border-radius: 8px; padding: 14px 16px; font-size: 14px; color: #1E293B; line-height: 1.6;">
                                    <%= alert.getMessage() != null && !alert.getMessage().trim().isEmpty() ? alert.getMessage() : "No additional details provided." %>
                                </div>
                            </div>

                        </div>

                        <!-- ACTIONS -->
                        <div class="form-actions-bar" style="margin-top: 32px; padding-top: 20px; border-top: 1px solid #E2E8F0; display: flex; flex-wrap: wrap; gap: 12px; align-items: center;">
                            <% if (canManage) { %>
                                
                                <a class="btn-smart-primary" href="<%= ctx %>/alert/edit?id=<%= URLEncoder.encode(alert.getAlertID(), "UTF-8") %>">
                                    <i class="fa-solid fa-pen-to-square"></i> Edit Alert
                                </a>

                                <% if (!alert.isResolved()) { %>
                                    <form method="post" action="<%= ctx %>/alert/resolve" style="display: inline; margin: 0;">
                                        <input type="hidden" name="id" value="<%= alert.getAlertID() %>">
                                        <input type="hidden" name="value" value="true">
                                        <button class="btn-smart-secondary" style="background: #E2F7E9; color: #166534; border-color: #D5ECCF;" type="submit">
                                            <i class="fa-solid fa-check"></i> Mark as Resolved
                                        </button>
                                    </form>
                                <% } else { %>
                                    <form method="post" action="<%= ctx %>/alert/resolve" style="display: inline; margin: 0;">
                                        <input type="hidden" name="id" value="<%= alert.getAlertID() %>">
                                        <input type="hidden" name="value" value="false">
                                        <button class="btn-smart-secondary" type="submit">
                                            <i class="fa-solid fa-rotate-left"></i> Re-open Alert
                                        </button>
                                    </form>
                                <% } %>

                                <% if (canDelete) { %>
                                <form method="post" action="<%= ctx %>/alert/delete" onsubmit="return confirm('Are you sure you want to permanently delete this alert?');" style="display: inline; margin: 0;">
                                    <input type="hidden" name="id" value="<%= alert.getAlertID() %>">
                                    <button class="btn-smart-secondary" style="color: #DC2626; border-color: #FCA5A5; background: #FEF2F2;" type="submit">
                                        <i class="fa-solid fa-trash-can"></i> Delete
                                    </button>
                                </form>
                                <% } %>

                            <% } %>

                            <a class="btn-smart-secondary" href="<%= ctx %>/alert" style="margin-left: auto;">
                                Back to Alerts List
                            </a>
                        </div>

                    <% } else { %>

                        <div style="text-align: center; padding: 48px 24px;">
                            <i class="fa-solid fa-triangle-exclamation" style="font-size: 42px; color: #D97706; margin-bottom: 16px;"></i>
                            <h3 style="margin-bottom: 8px;">Alert Record Not Found</h3>
                            <p style="color: #64748B; max-width: 420px; margin: 0 auto 20px;">
                                The requested alert may have been deleted or is no longer available in the database.
                            </p>
                            <a class="btn-smart-primary" href="<%= ctx %>/alert">
                                Return to Alerts List
                            </a>
                        </div>

                    <% } %>
                </div>

            </div>
        </main>
    </div>

</body>
</html>