<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="model.Area"%>
<%@page import="model.AppUser"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.util.Locale"%>

<%!
    private String escapeHtml(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>

<%
    Area area = (Area) request.getAttribute("AREA");
    if (area == null) {
        area = (Area) request.getAttribute("area");
    }

    AppUser currentUser = (AppUser) session.getAttribute("user");
    String role = currentUser != null && currentUser.getRoleId() != null
            ? currentUser.getRoleId().trim().toUpperCase(Locale.ROOT)
            : "";

    boolean isAdmin = "ADM".equals(role) || "SAD".equals(role) || "MGR".equals(role);
    String ctx = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Area Details - SmartWaste</title>

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
                        <a href="<%=ctx%>/area">Campus Areas</a>
                        <i class="fa-solid fa-chevron-right"></i>
                        <span>Area Details</span>
                    </div>
                    <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px; margin-top: 10px;">
                        <div>
                            <span class="badge-role-pill">GEOGRAPHIC ZONE &bull; DETAILS</span>
                            <h1 style="margin: 6px 0 0; font-size: 26px; font-weight: 800; color: #0F172A;">
                                <%= area != null ? escapeHtml(area.getAreaName()) : "Area Not Found" %>
                            </h1>
                        </div>
                        <div>
                            <a href="<%=ctx%>/area" class="btn-smart-secondary" style="font-size: 13px;">
                                <i class="fa-solid fa-arrow-left"></i> Back to Areas
                            </a>
                        </div>
                    </div>
                </div>

                <!-- CARD -->
                <div class="smartwaste-form-card">
                    <% if (area != null) { %>

                        <div class="form-grid">
                            
                            <!-- Area ID -->
                            <div class="form-field-group">
                                <label class="field-label">Area Code</label>
                                <div>
                                    <span style="display: inline-flex; align-items: center; gap: 6px; font-family: monospace; font-size: 14px; font-weight: 700; color: #166534; background: #E2F7E9; padding: 4px 12px; border-radius: 6px;">
                                        <i class="fa-solid fa-map-pin"></i> <%= escapeHtml(area.getAreaId()) %>
                                    </span>
                                </div>
                            </div>

                            <!-- Area Name -->
                            <div class="form-field-group">
                                <label class="field-label">Zone Name</label>
                                <div style="font-size: 16px; font-weight: 700; color: #0F172A;">
                                    <%= escapeHtml(area.getAreaName()) %>
                                </div>
                            </div>

                            <!-- Description (Full Width) -->
                            <div class="form-field-group form-field-full">
                                <label class="field-label">Zone Description &amp; Scope</label>
                                <div style="background: #F8FAF9; border: 1px solid #E2E8F0; border-radius: 8px; padding: 14px 16px; font-size: 14px; color: #1E293B; line-height: 1.6;">
                                    <%= area.getDescription() != null && !area.getDescription().trim().isEmpty()
                                            ? escapeHtml(area.getDescription())
                                            : "No detailed description registered for this area." %>
                                </div>
                            </div>

                        </div>

                        <!-- ACTIONS -->
                        <div class="form-actions-bar" style="margin-top: 32px; padding-top: 20px; border-top: 1px solid #E2E8F0; display: flex; flex-wrap: wrap; gap: 12px; align-items: center;">
                            <% if (isAdmin && area.getAreaId() != null) { %>
                                <a class="btn-smart-primary" href="<%=ctx%>/area/edit?id=<%=URLEncoder.encode(area.getAreaId(), "UTF-8")%>">
                                    <i class="fa-solid fa-pen-to-square"></i> Edit Area Details
                                </a>
                            <% } %>

                            <a class="btn-smart-secondary" href="<%=ctx%>/wastebin?areaId=<%=URLEncoder.encode(area.getAreaId(), "UTF-8")%>">
                                <i class="fa-solid fa-trash-can"></i> View Bins in this Zone
                            </a>

                            <a class="btn-smart-secondary" href="<%=ctx%>/area" style="margin-left: auto;">
                                Back to All Areas
                            </a>
                        </div>

                    <% } else { %>

                        <div style="text-align: center; padding: 48px 24px;">
                            <i class="fa-solid fa-triangle-exclamation" style="font-size: 42px; color: #D97706; margin-bottom: 16px;"></i>
                            <h3 style="margin-bottom: 8px;">Area Not Found</h3>
                            <p style="color: #64748B; max-width: 420px; margin: 0 auto 20px;">
                                The requested campus area does not exist or has been removed.
                            </p>
                            <a class="btn-smart-primary" href="<%=ctx%>/area">
                                Return to Areas List
                            </a>
                        </div>

                    <% } %>
                </div>

            </div>
        </main>
    </div>

</body>
</html>
