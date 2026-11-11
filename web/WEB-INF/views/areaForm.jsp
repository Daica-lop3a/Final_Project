x<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="model.Area"%>
<%
    String ctx = request.getContextPath();
    Area area = (Area) request.getAttribute("AREA");
    boolean isEdit = Boolean.TRUE.equals(request.getAttribute("IS_EDIT"));
    String error = (String) request.getAttribute("ERROR");
    String nextAreaId = (String) request.getAttribute("NEXT_AREA_ID");

    String areaIdVal = "";
    if (isEdit && area != null && area.getAreaId() != null) {
        areaIdVal = area.getAreaId();
    } else if (nextAreaId != null && !nextAreaId.isEmpty()) {
        areaIdVal = nextAreaId;
    } else if (area != null && area.getAreaId() != null) {
        areaIdVal = area.getAreaId();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "Edit Area" : "Create Campus Area" %> - SmartWaste</title>
    <link rel="stylesheet" href="<%=ctx%>/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body style="background: var(--page); margin: 0;">

    <!-- APP SHELL -->
    <div class="app-shell">
        
        <!-- SIDEBAR NAVIGATION -->
        <jsp:include page="/WEB-INF/views/sidebar.jsp" />

        <!-- MAIN FORM PAGE -->
        <main class="smartwaste-form-page">
            <div class="smartwaste-form-container">
                
                <!-- HEADER & BREADCRUMB -->
                <div class="form-header-box">
                    <div class="form-breadcrumb">
                        <a href="<%=ctx%>/dashboard" style="color: var(--color-slate-400);">Dashboard</a>
                        <i class="fa-solid fa-chevron-right" style="font-size: 9px;"></i>
                        <a href="<%=ctx%>/area" style="color: var(--color-slate-400);">Campus Areas</a>
                        <i class="fa-solid fa-chevron-right" style="font-size: 9px;"></i>
                        <span style="color: var(--brand-forest);"><%= isEdit ? "Edit Area" : "New Area" %></span>
                    </div>
                    <h1><%= isEdit ? "Edit Campus Area" : "Register Campus Area" %></h1>
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
                    <form action="<%=ctx%>/area/save" method="POST">
                        <input type="hidden" name="isEdit" value="<%= isEdit ? "true" : "false" %>">

                        <div class="form-section-divider">
                            <i class="fa-solid fa-map-pin"></i>
                            <span>Zone Identification &amp; Details</span>
                        </div>

                        <div class="form-grid">
                            
                            <!-- Area ID (Sequential Auto-Generated / Readonly) -->
                            <div class="form-field">
                                <label class="form-label" for="areaId">
                                    Area Identifier <span class="required">*</span>
                                </label>
                                                                <input type="text" id="areaId" name="areaId" class="form-input"
                                       value="<%= areaIdVal %>"
                                       pattern="^AREA-[0-9]{2,}$"
                                       placeholder="e.g. AREA-01"
                                       readonly
                                       required>
                                <span class="form-hint">
                                    <i class="fa-solid fa-lock" style="font-size: 10px;"></i>
                                    Sequential zone code (Format constraint: <strong>AREA-XX</strong>, e.g., AREA-01, AREA-06).
                                </span>
                            </div>

                            <!-- Area Name -->
                            <div class="form-field">
                                <label class="form-label" for="areaName">
                                    Area / Zone Name <span class="required">*</span>
                                </label>
                                <input type="text" id="areaName" name="areaName" class="form-input"
                                       placeholder="e.g. Zone F - Innovation Labs &amp; Tech Hub"
                                       value="<%= isEdit && area != null && area.getAreaName() != null ? area.getAreaName() : "" %>"
                                       maxlength="255"
                                       required>
                                <span class="form-hint">Campus building or outdoor operational sector.</span>
                            </div>

                            <!-- Description -->
                            <div class="form-field form-group-full">
                                <label class="form-label" for="description">
                                    Zone Description &amp; Scope
                                </label>
                                <textarea id="description" name="description" class="form-textarea" rows="4"
                                          placeholder="Provide reference landmarks, building floors, entrance gates or specific collection notes for field workers..."><%= isEdit && area != null && area.getDescription() != null ? area.getDescription() : "" %></textarea>
                                <span class="form-hint">Detailed operational guidance for collection teams and supervisors.</span>
                            </div>

                        </div>

                        <!-- ACTION BUTTONS -->
                        <div class="form-actions-bar">
                            <a href="<%=ctx%>/area" class="btn-smart-secondary">
                                <i class="fa-solid fa-xmark"></i>
                                <span>Cancel</span>
                            </a>
                            <button type="submit" class="btn-smart-primary">
                                <i class="fa-solid fa-check"></i>
                                <span><%= isEdit ? "Update Area" : "Save Area" %></span>
                            </button>
                        </div>

                    </form>
                </div>

            </div>
        </main>
    </div>

</body>
</html>
