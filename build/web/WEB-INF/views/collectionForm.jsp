<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.CollectionRequest"%>
<%@page import="model.WasteBin"%>
<%@page import="model.AppUser"%>
<%@page import="model.Area"%>

<%
    String ctx = request.getContextPath();
    CollectionRequest collection = (CollectionRequest) request.getAttribute("REQUEST");
    List<Area> areaList = (List<Area>) request.getAttribute("LIST_AREA");
    String selectedAreaId = (String) request.getAttribute("SELECTED_AREA_ID");
    List<WasteBin> binList = (List<WasteBin>) request.getAttribute("LIST_BIN");
    List<WasteBin> allAreaBins = (List<WasteBin>) request.getAttribute("LIST_ALL_AREA_BINS");
    List<AppUser> staffList = (List<AppUser>) request.getAttribute("LIST_STAFF");
    AppUser currentUser = (AppUser) session.getAttribute("user");
    String role = currentUser != null ? currentUser.getRoleId() : "";
    String error = (String) request.getAttribute("ERROR");

    boolean isCreate = !Boolean.FALSE.equals(request.getAttribute("IS_CREATE")) && (request.getParameter("id") == null || request.getParameter("id").trim().isEmpty());
    boolean edit = !isCreate;
    boolean isStaff = "STF".equals(role);
    boolean isSupervisor = "SUP".equals(role) || "MGR".equals(role);
    boolean isAdmin = "ADM".equals(role) || "SAD".equals(role);
    boolean canEditStatus = edit && (isStaff || isSupervisor || isAdmin);
    String reqIdVal = collection != null && collection.getRequestID() != null ? collection.getRequestID() : "";

    boolean isRouteMode = Boolean.TRUE.equals(request.getAttribute("IS_ROUTE_MODE")) || "route".equalsIgnoreCase(request.getParameter("mode")) || "1".equals(request.getParameter("hotspot"));
    boolean isHotspot = Boolean.TRUE.equals(request.getAttribute("IS_HOTSPOT")) || "1".equals(request.getParameter("hotspot"));

    String curStatus = collection != null && collection.getStatus() != null ? collection.getStatus() : "Pending";
    String curStatusClean = curStatus.replace("_", " ");
    String badgeBg = "#FEF3C7";
    String badgeColor = "#B45309";
    if ("In_Progress".equalsIgnoreCase(curStatus)) {
        badgeBg = "#E0F2FE";
        badgeColor = "#0369A1";
    } else if ("Completed".equalsIgnoreCase(curStatus)) {
        badgeBg = "#DCFCE7";
        badgeColor = "#166534";
    } else if ("Failed".equalsIgnoreCase(curStatus)) {
        badgeBg = "#FEE2E2";
        badgeColor = "#991B1B";
    } else if ("Skipped".equalsIgnoreCase(curStatus)) {
        badgeBg = "#F3F4F6";
        badgeColor = "#4B5563";
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= edit ? "Edit Collection Task" : "Dispatch Collection Task" %> - SmartWaste</title>
    <link rel="stylesheet" href="<%=ctx%>/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body style="background: var(--page); margin: 0;">

    <div class="app-shell">
        <!-- SIDEBAR NAVIGATION -->
        <jsp:include page="/WEB-INF/views/sidebar.jsp" />

        <!-- MAIN FORM CONTENT -->
        <main class="smartwaste-form-page">
            <div class="smartwaste-form-container">
                
                <!-- BREADCRUMB & HEADER -->
                <div class="form-header-box">
                    <div class="form-breadcrumb">
                        <a href="<%=ctx%>/dashboard" style="color: var(--color-slate-400);">Dashboard</a>
                        <i class="fa-solid fa-chevron-right" style="font-size: 9px;"></i>
                        <a href="<%=ctx%>/collection" style="color: var(--color-slate-400);">Collection Tasks</a>
                        <i class="fa-solid fa-chevron-right" style="font-size: 9px;"></i>
                        <span style="color: var(--brand-forest);"><%= edit ? "Edit Task" : "New Task" %></span>
                    </div>
                    <h1><%= edit ? "Edit Collection Task " + reqIdVal : "Dispatch Collection Task" %></h1>
                </div>

                <!-- ERROR ALERT -->
                <% if (error != null && !error.trim().isEmpty()) { %>
                    <div style="padding: 12px 16px; background: #FEE2E2; border: 1px solid #FCA5A5; border-radius: 8px; color: #991B1B; font-size: 13px; font-weight: 600; margin-bottom: 20px; display: flex; align-items: center; gap: 8px;">
                        <i class="fa-solid fa-circle-exclamation"></i>
                        <span><%= error %></span>
                    </div>
                <% } %>

                <% if (isStaff) { %>
                    <div style="padding: 12px 16px; background: var(--color-m0601); border: 1px solid var(--color-m0573); border-radius: 8px; color: var(--brand-forest); font-size: 13px; font-weight: 600; margin-bottom: 20px; display: flex; align-items: center; gap: 8px;">
                        <i class="fa-solid fa-circle-info"></i>
                        <span>Collection Staff Mode: Update live collection status, scan QR verification upon arrival, and upload field completion proof.</span>
                    </div>
                <% } %>

                <!-- FORM CARD -->
                <div class="smartwaste-form-card">
                    <form action="<%=ctx%>/collection/save" method="POST">
                        <input type="hidden" name="requestID" value="<%= reqIdVal %>">
                        <input type="hidden" name="isCreate" value="<%= isCreate ? "true" : "false" %>">
                        <input type="hidden" name="dispatchMode" id="dispatchModeInput" value="<%= isRouteMode ? "route" : "single" %>">

                        <div class="form-section-divider">
                            <i class="fa-solid fa-truck-ramp-box"></i>
                            <span>Task Assignment &amp; Routing</span>
                        </div>

                        <% if (!edit && !isStaff) { %>
                        <!-- DISPATCH MODE SWITCHER -->
                        <div style="background: #F8FAFC; border: 1px solid #E2E8F0; border-radius: 12px; padding: 14px 18px; margin-bottom: 22px; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px;">
                            <div>
                                <div style="font-size: 14px; font-weight: 800; color: #0F172A;">
                                    <i class="fa-solid fa-route" style="color: #166534; margin-right: 6px;"></i>
                                    Operational Dispatch Mode
                                </div>
                                <div style="font-size: 12px; color: #64748B; margin-top: 2px;">
                                    Choose single receptacle collection or multi-bin route coordination.
                                </div>
                            </div>
                            <div style="display: flex; gap: 8px;">
                                <button type="button" id="btnModeSingle" onclick="switchDispatchMode('single')"
                                        style="padding: 8px 16px; border-radius: 8px; font-size: 12px; font-weight: 700; cursor: pointer; border: 1px solid <%= isRouteMode ? "#CBD5E1" : "#166534" %>; background: <%= isRouteMode ? "#FFFFFF" : "#166534" %>; color: <%= isRouteMode ? "#475569" : "#FFFFFF" %>;">
                                    <i class="fa-solid fa-trash-can"></i> Single Receptacle
                                </button>
                                <button type="button" id="btnModeRoute" onclick="switchDispatchMode('route')"
                                        style="padding: 8px 16px; border-radius: 8px; font-size: 12px; font-weight: 700; cursor: pointer; border: 1px solid <%= isRouteMode ? "#166534" : "#CBD5E1" %>; background: <%= isRouteMode ? "#166534" : "#FFFFFF" %>; color: <%= isRouteMode ? "#FFFFFF" : "#475569" %>;">
                                    <i class="fa-solid fa-truck-moving"></i> Multi-Bin Route Dispatch
                                </button>
                            </div>
                        </div>
                        <% } %>

                        <div class="form-grid">
                            
                            <!-- Request ID (Sequential / Readonly) -->
                            <div class="form-field" id="requestIdGroup">
                                <label class="form-label" for="dispReqID">
                                    Collection Request ID <span class="required">*</span>
                                </label>
                                <input type="text" id="dispReqID" class="form-input"
                                       value="<%= isRouteMode ? "Auto-generated (1 ticket per bin)" : reqIdVal %>"
                                       readonly
                                       style="<%= isRouteMode ? "font-style: italic; color: #166534; font-weight: 600;" : "" %>"
                                       required>
                                <span class="form-hint" id="reqIdHint">
                                    <% if (isRouteMode) { %>
                                        <i class="fa-solid fa-list-ol" style="font-size: 10px;"></i>
                                        Sequential ticket IDs will be auto-assigned to each route stop.
                                    <% } else { %>
                                        <i class="fa-solid fa-lock" style="font-size: 10px;"></i>
                                        Auto-assigned sequential task ticket (e.g. <%= reqIdVal %>).
                                    <% } %>
                                </span>
                            </div>

                            <!-- Target Campus Area Selector -->
                            <div class="form-field" id="targetAreaField">
                                <label class="form-label" for="areaID">
                                    Target Campus Area <span class="required">*</span>
                                </label>
                                <% if (edit || isStaff) { %>
                                    <input type="text" class="form-input"
                                           value="<%= selectedAreaId != null ? selectedAreaId : "" %>"
                                           readonly>
                                    <input type="hidden" name="areaID" id="areaID"
                                           value="<%= selectedAreaId != null ? selectedAreaId : "" %>">
                                    <span class="form-hint">Designated campus zone for this collection mission.</span>
                                <% } else { %>
                                    <select name="areaID" id="areaID" class="form-select" onchange="onAreaChange(this.value)" required>
                                        <option value="">-- Select Target Area --</option>
                                        <% if (areaList != null) {
                                            for (Area a : areaList) {
                                                boolean sel = selectedAreaId != null && a.getAreaId().equalsIgnoreCase(selectedAreaId);
                                        %>
                                        <option value="<%= a.getAreaId() %>" <%= sel ? "selected" : "" %>>
                                            <%= a.getAreaId() %> &mdash; <%= a.getAreaName() %>
                                        </option>
                                        <% } } %>
                                    </select>
                                    <span class="form-hint"><i class="fa-solid fa-location-dot"></i> Select area to load bins needing collection and assigned staff.</span>
                                <% } %>
                            </div>

                            <!-- Target Waste Bin (Single Mode) -->
                            <div class="form-field" id="singleBinField" style="<%= isRouteMode ? "display: none;" : "" %>">
                                <label class="form-label" for="binID">
                                    Target Waste Bin <span class="required">*</span>
                                </label>
                                <% if (isStaff) { %>
                                    <input type="text" class="form-input"
                                           value="<%= collection != null && collection.getBinID() != null ? collection.getBinID() : "" %>"
                                           readonly>
                                    <input type="hidden" name="binID" id="binID"
                                           value="<%= collection != null && collection.getBinID() != null ? collection.getBinID() : "" %>">
                                    <span class="form-hint">Designated receptacle for this collection task.</span>
                                <% } else { %>
                                    <select name="binID" id="binID" class="form-select" <%= isRouteMode ? "" : "required" %>>
                                        <option value="">Select waste bin</option>
                                        <% if (binList != null && !binList.isEmpty()) {
                                            for (WasteBin bin : binList) {
                                                boolean sel = collection != null && bin.getBinID().equals(collection.getBinID());
                                        %>
                                        <option value="<%= bin.getBinID() %>" data-code="<%= bin.getBinCode() %>" data-fill="<%= (int)bin.getCurrentFill() %>" <%= sel ? "selected" : "" %>>
                                            <%= bin.getBinCode() %> &mdash; <%= (int)bin.getCurrentFill() %>% (<%= bin.getStatus() %>) &bull; <%= bin.getLocation() %>
                                        </option>
                                        <% } } else { %>
                                        <option value="" disabled>No bins need to collect</option>
                                        <% } %>
                                    </select>
                                <% } %>
                            </div>

                            <!-- Assigned Staff -->
                            <div class="form-field">
                                <label class="form-label" for="staffID">
                                    Assigned Collection Staff <span class="required">*</span>
                                </label>
                                <% if (isStaff) { %>
                                    <input type="text" class="form-input"
                                           value="<%= collection != null && collection.getStaffID() != null ? collection.getStaffID() : "" %>"
                                           readonly>
                                    <input type="hidden" name="staffID" id="staffID"
                                           value="<%= collection != null && collection.getStaffID() != null ? collection.getStaffID() : "" %>">
                                    <span class="form-hint">Assigned operator responsible for task.</span>
                                <% } else { %>
                                    <select name="staffID" id="staffID" class="form-select" required>
                                        <option value="">-- Select Staff --</option>
                                        <% if (staffList != null && !staffList.isEmpty()) {
                                            for (AppUser staff : staffList) {
                                                boolean sel = collection != null && staff.getUserId().equals(collection.getStaffID());
                                        %>
                                        <option value="<%= staff.getUserId() %>" <%= sel ? "selected" : "" %>>
                                            <%= staff.getUserId() %> &mdash; <%= staff.getFullName() %>
                                        </option>
                                        <% } } else { %>
                                        <option value="" disabled>No staff assigned to this area</option>
                                        <% } %>
                                    </select>
                                    <span class="form-hint" id="staffHintText">Personnel assigned to this campus area.</span>
                                <% } %>
                            </div>

                            <!-- Multi-Bin Route Dispatch Selector (Route Mode) -->
                            <% if (!edit && !isStaff) { %>
                            <div class="form-field form-grid-full" id="routeBinsField" style="<%= isRouteMode ? "" : "display: none;" %>">
                                <div style="background: #F8FAFC; border: 1px solid #CBD5E1; border-radius: 12px; padding: 18px;">
                                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; flex-wrap: wrap; gap: 10px;">
                                        <div>
                                            <label class="form-label" style="color: #0F172A; margin: 0; font-size: 14px; font-weight: 800;">
                                                <i class="fa-solid fa-list-check" style="color: #166534;"></i>
                                                Select Receptacles for Collection Route
                                            </label>
                                            <div style="font-size: 12px; color: #64748B; margin-top: 2px;">
                                                Check all bins needing collection in the target campus area.
                                            </div>
                                        </div>
                                        <div style="display: flex; gap: 8px;">
                                            <button type="button" onclick="selectAllHotspot()" class="btn-smart-secondary" style="padding: 6px 12px; font-size: 11px; background: #FEE2E2; color: #991B1B; border-color: #FCA5A5;">
                                                <i class="fa-solid fa-fire"></i> Select Critical Bins
                                            </button>
                                            <button type="button" onclick="selectAllRouteBins(true)" class="btn-smart-secondary" style="padding: 6px 12px; font-size: 11px;">
                                                Select All
                                            </button>
                                            <button type="button" onclick="selectAllRouteBins(false)" class="btn-smart-secondary" style="padding: 6px 12px; font-size: 11px;">
                                                Clear
                                            </button>
                                        </div>
                                    </div>

                                    <!-- Table of Bins -->
                                    <div style="max-height: 260px; overflow-y: auto; border: 1px solid #E2E8F0; border-radius: 8px; background: #FFFFFF;">
                                        <table id="routeBinsTable" style="width: 100%; border-collapse: collapse; font-size: 12px;">
                                            <thead>
                                                <tr style="background: #F1F5F9; border-bottom: 1px solid #CBD5E1; text-align: left; color: #475569; position: sticky; top: 0; z-index: 2;">
                                                    <th style="padding: 8px 12px; width: 36px; text-align: center;">Pick</th>
                                                    <th style="padding: 8px 12px;">Receptacle</th>
                                                    <th style="padding: 8px 12px;">Location / Zone</th>
                                                    <th style="padding: 8px 12px;">Capacity</th>
                                                    <th style="padding: 8px 12px;">Current Fill</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <% if (binList != null) {
                                                    for (WasteBin b : binList) {
                                                        boolean autoCheck = isHotspot && b.getCurrentFill() >= 80;
                                                        double fillVal = b.getCurrentFill();
                                                        String fColor = fillVal >= 80 ? "#DC2626" : (fillVal >= 60 ? "#D97706" : "#166534");
                                                        String fBg = fillVal >= 80 ? "#FEE2E2" : (fillVal >= 60 ? "#FEF3C7" : "#DCFCE7");
                                                %>
                                                <tr style="border-bottom: 1px solid #F1F5F9;" onmouseover="this.style.background='#F8FAFC'" onmouseout="this.style.background='white'">
                                                    <td style="padding: 8px 12px; text-align: center;">
                                                        <input type="checkbox" name="binIDs" value="<%= b.getBinID() %>"
                                                               class="route-bin-cb"
                                                               data-code="<%= b.getBinCode() %>"
                                                               data-fill="<%= b.getCurrentFill() %>"
                                                               data-cap="<%= b.getCapacity() %>"
                                                               <%= autoCheck ? "checked" : "" %>
                                                               onchange="updateRouteStats()"
                                                               style="width: 16px; height: 16px; cursor: pointer;">
                                                    </td>
                                                    <td style="padding: 8px 12px; font-weight: 700; font-family: monospace; color: #0F172A;">
                                                        <%= b.getBinCode() %>
                                                        <small style="color: #64748B; font-weight: 400; font-family: sans-serif;">(#<%= b.getBinID() %>)</small>
                                                    </td>
                                                    <td style="padding: 8px 12px; color: #334155;">
                                                        <%= b.getLocation() %>
                                                        <span style="font-size: 10px; padding: 2px 6px; background: #E2E8F0; border-radius: 4px; margin-left: 4px;"><%= b.getAreaID() %></span>
                                                    </td>
                                                    <td style="padding: 8px 12px; color: #64748B;"><%= b.getCapacity() %> L</td>
                                                    <td style="padding: 8px 12px;">
                                                        <span style="padding: 2px 8px; border-radius: 6px; font-weight: 700; font-size: 11px; background: <%= fBg %>; color: <%= fColor %>;">
                                                            <%= (int)fillVal %>%
                                                        </span>
                                                    </td>
                                                </tr>
                                                <%  }
                                                } %>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                            <% } %>

                            <!-- Priority -->
                            <div class="form-field">
                                <label class="form-label" for="priority">
                                    Dispatch Priority <span class="required">*</span>
                                </label>
                                <% if (isStaff) { %>
                                    <input type="text" class="form-input"
                                           value="<%= collection != null && collection.getPriority() != null ? collection.getPriority() : "Normal" %>"
                                           readonly>
                                    <input type="hidden" name="priority"
                                           value="<%= collection != null && collection.getPriority() != null ? collection.getPriority() : "Normal" %>">
                                <% } else { %>
                                    <select name="priority" id="priority" class="form-select" required>
                                        <option value="Normal" <%= collection == null || "Normal".equalsIgnoreCase(collection.getPriority()) || "Low".equalsIgnoreCase(collection.getPriority()) ? "selected" : "" %>>Normal</option>
                                        <option value="High" <%= collection != null && "High".equalsIgnoreCase(collection.getPriority()) ? "selected" : "" %>>High</option>
                                        <option value="Emergency" <%= collection != null && ("Emergency".equalsIgnoreCase(collection.getPriority()) || "Emer".equalsIgnoreCase(collection.getPriority())) ? "selected" : "" %>>Emergency</option>
                                    </select>
                                <% } %>
                            </div>

                            <!-- Execution Status -->
                            <div class="form-field">
                                <label class="form-label" for="statusSelect">
                                    Execution Status <span class="required">*</span>
                                </label>
                                <% if (!edit) { %>
                                    <!-- Creation mode: Strictly Locked to Pending -->
                                    <div style="display: flex; align-items: center; justify-content: space-between; padding: 10px 14px; background: #F8FAFC; border: 1px solid #CBD5E1; border-radius: 8px;">
                                        <div style="display: flex; align-items: center; gap: 8px;">
                                            <span style="background: #FEF3C7; color: #92400E; padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 700; display: inline-flex; align-items: center; gap: 6px;">
                                                <i class="fa-solid fa-clock-rotate-left"></i> Pending
                                            </span>
                                            <span style="font-size: 12px; color: #64748B;">(Locked upon dispatch)</span>
                                        </div>
                                        <i class="fa-solid fa-lock" style="color: #94A3B8;"></i>
                                    </div>
                                    <input type="hidden" name="status" id="statusSelect" value="Pending">
                                    <span class="form-hint"><i class="fa-solid fa-lock" style="font-size: 10px;"></i> Status defaults to Pending upon dispatch. Assigned collection staff updates execution status during pickup.</span>
                                <% } else if (canEditStatus) { %>
                                    <!-- Editable status for Collection Staff, Supervisor, and Admin -->
                                    <select name="status" id="statusSelect" class="form-select" onchange="toggleFailureReason()" required>
                                        <option value="Pending" <%= collection != null && "Pending".equals(collection.getStatus()) ? "selected" : "" %>>Pending</option>
                                        <option value="In_Progress" <%= collection != null && ("In_Progress".equals(collection.getStatus()) || "In Progress".equals(collection.getStatus())) ? "selected" : "" %>>In Progress</option>
                                        <option value="Completed" <%= collection != null && "Completed".equals(collection.getStatus()) ? "selected" : "" %>>Completed</option>
                                        <% if (isSupervisor || isAdmin) { %>
                                            <option value="Verified" <%= collection != null && "Verified".equals(collection.getStatus()) ? "selected" : "" %>>Verified</option>
                                            <option value="Cancelled" <%= collection != null && "Cancelled".equals(collection.getStatus()) ? "selected" : "" %>>Cancelled</option>
                                        <% } %>
                                        <option value="Failed" <%= collection != null && "Failed".equals(collection.getStatus()) ? "selected" : "" %>>Failed (Cannot Collect)</option>
                                        <option value="Skipped" <%= collection != null && "Skipped".equals(collection.getStatus()) ? "selected" : "" %>>Skipped</option>
                                    </select>
                                    <span class="form-hint">
                                        <%= isStaff ? "Collection staff: Update real-time status as pickup progresses (In Progress -> Completed)." : "Supervisor/Admin: Update collection lifecycle status." %>
                                    </span>
                                <% } else { %>
                                    <div style="display: flex; align-items: center; justify-content: space-between; padding: 10px 14px; background: #F8FAFC; border: 1px solid #CBD5E1; border-radius: 8px;">
                                        <div style="display: flex; align-items: center; gap: 8px;">
                                            <span style="background: <%= badgeBg %>; color: <%= badgeColor %>; padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 700;">
                                                <%= curStatusClean %>
                                            </span>
                                        </div>
                                    </div>
                                    <input type="hidden" name="status" id="statusSelect" value="<%= curStatus %>">
                                <% } %>
                            </div>

                            <!-- Failure / Skip Reason -->
                            <div class="form-field" id="failureReasonGroup" style="<%= (collection != null && ("Failed".equals(collection.getStatus()) || "Skipped".equals(collection.getStatus()))) ? "" : "display:none;" %>">
                                <label class="form-label" for="failureReason" style="color: #991B1B;">
                                    <i class="fa-solid fa-triangle-exclamation"></i> Failure / Skip Reason
                                </label>
                                <select name="failureReason" id="failureReason" class="form-select" style="border-color: #FCA5A5;">
                                    <option value="">-- Select Reason --</option>
                                    <option value="Bin Unreachable (Locked/Road blocked)" <%= collection != null && "Bin Unreachable (Locked/Road blocked)".equals(collection.getFailureReason()) ? "selected" : "" %>>Bin Unreachable (Locked/Road blocked)</option>
                                    <option value="Damaged Bin structure / Lid broken" <%= collection != null && "Damaged Bin structure / Lid broken".equals(collection.getFailureReason()) ? "selected" : "" %>>Damaged Bin structure / Lid broken</option>
                                    <option value="Hazardous / Prohibited waste" <%= collection != null && "Hazardous / Prohibited waste".equals(collection.getFailureReason()) ? "selected" : "" %>>Hazardous / Prohibited waste</option>
                                    <option value="Sensor / Hardware Malfunction" <%= collection != null && "Sensor / Hardware Malfunction".equals(collection.getFailureReason()) ? "selected" : "" %>>Sensor / Hardware Malfunction</option>
                                    <option value="Severe weather / Force majeure" <%= collection != null && "Severe weather / Force majeure".equals(collection.getFailureReason()) ? "selected" : "" %>>Severe weather / Force majeure</option>
                                    <option value="Other" <%= collection != null && "Other".equals(collection.getFailureReason()) ? "selected" : "" %>>Other field obstacle</option>
                                </select>
                            </div>

                            <% if (edit && isStaff) { %>
                            <!-- QR Code Bin Verification Box (Collection Staff On-Site Only) -->
                            <div class="form-field form-grid-full">
                                <div style="background: var(--color-m0601); border: 1px dashed var(--brand-forest); border-radius: 10px; padding: 18px;">
                                    <label class="form-label" style="display: flex; align-items: center; justify-content: space-between; color: var(--brand-forest); font-size: 14px; font-weight: 700; margin-bottom: 6px;">
                                        <span style="display: flex; align-items: center; gap: 8px;">
                                            <i class="fa-solid fa-qrcode" style="font-size: 16px;"></i>
                                            Field Receptacle Verification (QR / Bin Code)
                                        </span>
                                        <span style="font-size: 11px; font-weight: 700; color: #166534; background: #DCFCE7; padding: 3px 8px; border-radius: 4px; border: 1px solid #86EFAC;">
                                            Staff On-Site Verification
                                        </span>
                                    </label>
                                    <p style="font-size: 12px; color: #475569; margin: 0 0 10px; line-height: 1.4;">
                                        Confirm physical arrival by verifying the assigned bin code before marking the task as completed.
                                    </p>
                                    <div style="display: flex; gap: 8px; margin-top: 8px; flex-wrap: wrap;">
                                        <input type="text" name="qrData" id="qrDataInput" placeholder="Scan QR code or enter Bin Code (e.g. BIN-A1-01)..."
                                               class="form-input" oninput="autoVerifyQR()" style="flex: 1; min-width: 180px; font-family: monospace; font-weight: 700;">
                                        <button type="button" onclick="scanTargetBin()" class="btn-smart-primary" style="padding: 0 16px; background: #166534; border-color: #166534; white-space: nowrap;">
                                            <i class="fa-solid fa-qrcode"></i> Scan QR Code
                                        </button>
                                        <button type="button" onclick="showTargetBinQr()" class="btn-smart-secondary" style="padding: 0 14px; white-space: nowrap;">
                                            <i class="fa-solid fa-eye"></i> View QR
                                        </button>
                                    </div>
                                    <div id="qrFeedback" style="margin-top: 10px;"></div>
                                </div>
                            </div>

                            <!-- Field Evidence Photos (Collection Staff) -->
                            <div class="form-field">
                                <label class="form-label" for="photoBeforeInput">
                                    <i class="fa-solid fa-camera"></i> Photo Before Emptying
                                </label>
                                <input type="text" name="photoBefore" id="photoBeforeInput" class="form-input"
                                       value="<%= collection != null && collection.getPhotoBefore() != null ? collection.getPhotoBefore() : "" %>"
                                       placeholder="Image URL or photo link"
                                       oninput="previewImg('photoBeforeInput', 'previewBefore')">
                                <div style="margin-top: 6px;">
                                    <button type="button" onclick="setSamplePhoto('photoBeforeInput', 'previewBefore', 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?auto=format&fit=crop&w=400&q=80')"
                                            class="btn-smart-secondary" style="padding: 4px 10px; font-size: 11px;">
                                        Sample Full Bin
                                    </button>
                                </div>
                                <img id="previewBefore" src="<%= collection != null && collection.getPhotoBefore() != null ? collection.getPhotoBefore() : "" %>"
                                     style="max-width: 100%; height: 90px; object-fit: cover; border-radius: 6px; margin-top: 8px; <%= (collection != null && collection.getPhotoBefore() != null && !collection.getPhotoBefore().isEmpty()) ? "" : "display:none;" %>" />
                            </div>

                            <div class="form-field">
                                <label class="form-label" for="photoAfterInput">
                                    <i class="fa-solid fa-camera"></i> Photo After Emptying
                                </label>
                                <input type="text" name="photoAfter" id="photoAfterInput" class="form-input"
                                       value="<%= collection != null && collection.getPhotoAfter() != null ? collection.getPhotoAfter() : "" %>"
                                       placeholder="Image URL or photo link"
                                       oninput="previewImg('photoAfterInput', 'previewAfter')">
                                <div style="margin-top: 6px;">
                                    <button type="button" onclick="setSamplePhoto('photoAfterInput', 'previewAfter', 'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=400&q=80')"
                                            class="btn-smart-secondary" style="padding: 4px 10px; font-size: 11px;">
                                        Sample Clean Bin
                                    </button>
                                </div>
                                <img id="previewAfter" src="<%= collection != null && collection.getPhotoAfter() != null ? collection.getPhotoAfter() : "" %>"
                                     style="max-width: 100%; height: 90px; object-fit: cover; border-radius: 6px; margin-top: 8px; <%= (collection != null && collection.getPhotoAfter() != null && !collection.getPhotoAfter().isEmpty()) ? "" : "display:none;" %>" />
                            </div>
                            <% } else if (edit && collection != null && ((collection.getPhotoBefore() != null && !collection.getPhotoBefore().isEmpty()) || (collection.getPhotoAfter() != null && !collection.getPhotoAfter().isEmpty()))) { %>
                            <!-- Manager / Admin Viewing Existing Field Photos -->
                            <div class="form-field form-grid-full">
                                <label class="form-label">Field Completion Photos</label>
                                <div style="display: flex; gap: 16px; flex-wrap: wrap;">
                                    <% if (collection.getPhotoBefore() != null && !collection.getPhotoBefore().isEmpty()) { %>
                                        <div>
                                            <div style="font-size: 11px; color: #64748B; margin-bottom: 4px;">Before Emptying:</div>
                                            <img src="<%= collection.getPhotoBefore() %>" style="width: 140px; height: 100px; object-fit: cover; border-radius: 8px; border: 1px solid #CBD5E1;">
                                        </div>
                                    <% } %>
                                    <% if (collection.getPhotoAfter() != null && !collection.getPhotoAfter().isEmpty()) { %>
                                        <div>
                                            <div style="font-size: 11px; color: #64748B; margin-bottom: 4px;">After Emptying:</div>
                                            <img src="<%= collection.getPhotoAfter() %>" style="width: 140px; height: 100px; object-fit: cover; border-radius: 8px; border: 1px solid #CBD5E1;">
                                        </div>
                                    <% } %>
                                </div>
                            </div>
                            <% } %>

                            <!-- Timestamp Summary If Available -->
                            <% if (collection != null && (collection.getStartedDate() != null || collection.getCompletedDate() != null)) { %>
                                <div class="form-field form-grid-full">
                                    <div style="display: flex; gap: 20px; background: var(--color-m0571); border: 1px solid var(--color-m0573); padding: 12px 18px; border-radius: 8px; font-size: 13px;">
                                        <% if (collection.getStartedDate() != null) { %>
                                            <div><i class="fa-solid fa-stopwatch" style="color: var(--brand-forest);"></i> <strong>Started:</strong> <%= collection.getStartedDate() %></div>
                                        <% } %>
                                        <% if (collection.getCompletedDate() != null) { %>
                                            <div><i class="fa-solid fa-flag-checkered" style="color: #059669;"></i> <strong>Completed:</strong> <%= collection.getCompletedDate() %></div>
                                        <% } %>
                                    </div>
                                </div>
                            <% } %>

                            <!-- Field Notes -->
                            <div class="form-field form-grid-full">
                                <label class="form-label" for="notes">Operational Notes</label>
                                <textarea id="notes" name="notes" rows="3" class="form-textarea"
                                          placeholder="Enter details about collection route, volume collected, or impediments..."><%= collection != null && collection.getNotes() != null ? collection.getNotes() : "" %></textarea>
                            </div>

                        </div>

                        <!-- BUTTON ACTIONS -->
                        <div class="form-actions-bar">
                            <a href="<%=ctx%>/collection" class="btn-smart-secondary">
                                <i class="fa-solid fa-arrow-left"></i> Cancel
                            </a>
                            <button type="submit" class="btn-smart-primary" id="btnSubmitDispatch">
                                <i class="fa-solid fa-paper-plane"></i>
                                <span id="submitBtnText"><%= isStaff ? "Update Field Status" : (edit ? "Save Changes" : (isRouteMode ? "Dispatch Collection Route" : "Dispatch Task")) %></span>
                            </button>
                        </div>

                    </form>
                </div>
            </div>
        </main>
    </div>

    <script>
        var currentAreaBins = [];
        var currentAreaAllBins = [];
        var currentAreaStaff = [];
        var showingAllBins = false;

        function onAreaChange(areaID) {
            var binSelect = document.getElementById("binID");
            var staffSelect = document.getElementById("staffID");
            if (!areaID) {
                if (binSelect) binSelect.innerHTML = '<option value="">-- Select Target Area First --</option>';
                if (staffSelect) staffSelect.innerHTML = '<option value="">-- Select Target Area First --</option>';
                renderRouteTable([]);
                return;
            }

            if (binSelect) binSelect.innerHTML = '<option value="">Loading bins needing collection...</option>';
            if (staffSelect) staffSelect.innerHTML = '<option value="">Loading assigned staff...</option>';

            var contextPath = "<%= ctx %>";
            fetch(contextPath + "/collection/area-data?areaID=" + encodeURIComponent(areaID))
                .then(function (res) {
                    if (!res.ok) throw new Error("Failed to load area data");
                    return res.json();
                })
                .then(function (data) {
                    currentAreaBins = data.bins || [];
                    currentAreaAllBins = data.allBins || [];
                    currentAreaStaff = data.staff || [];
                    showingAllBins = false;

                    // 1. Populate Bin Select
                    populateBinSelect();

                    // 2. Populate Staff Select
                    if (staffSelect) {
                        staffSelect.innerHTML = '<option value="">-- Select Staff --</option>';
                        if (currentAreaStaff.length === 0) {
                            var disabledOpt = document.createElement("option");
                            disabledOpt.value = "";
                            disabledOpt.disabled = true;
                            disabledOpt.textContent = "No staff assigned to this area";
                            staffSelect.appendChild(disabledOpt);
                        } else {
                            currentAreaStaff.forEach(function (s) {
                                var opt = document.createElement("option");
                                opt.value = s.userID;
                                opt.textContent = s.userID + " - " + s.fullName;
                                staffSelect.appendChild(opt);
                            });
                        }
                    }

                    // 3. Render Route Mode Table
                    renderRouteTable(currentAreaBins);
                })
                .catch(function (err) {
                    console.error("Error loading area data:", err);
                    if (binSelect) binSelect.innerHTML = '<option value="">Unable to load bins</option>';
                    if (staffSelect) staffSelect.innerHTML = '<option value="">Unable to load staff</option>';
                });
        }

        function populateBinSelect() {
            var binSelect = document.getElementById("binID");
            if (!binSelect) return;

            binSelect.innerHTML = '<option value="">Select waste bin</option>';
            var listToRender = currentAreaBins;

            if (!listToRender || listToRender.length === 0) {
                var opt = document.createElement("option");
                opt.value = "";
                opt.disabled = true;
                opt.textContent = "No bins need to collect";
                binSelect.appendChild(opt);
            } else {
                listToRender.forEach(function (b) {
                    var opt = document.createElement("option");
                    opt.value = b.binID;
                    opt.setAttribute("data-code", b.binCode);
                    opt.setAttribute("data-fill", b.currentFill);
                    opt.textContent = b.binCode + " - " + b.currentFill + "% (" + b.status + ") | " + b.location;
                    binSelect.appendChild(opt);
                });
            }
        }

        function toggleAllAreaBins() {
            populateBinSelect();
            renderRouteTable(currentAreaBins);
        }

        function renderRouteTable(bins) {
            var tbody = document.querySelector("#routeBinsTable tbody");
            if (!tbody) return;
            tbody.innerHTML = "";

            if (!bins || bins.length === 0) {
                tbody.innerHTML = '<tr><td colspan="5" style="padding: 16px; text-align: center; color: #64748B;">No bins need to collect</td></tr>';
                updateRouteStats();
                return;
            }

            bins.forEach(function (b) {
                var fill = b.currentFill || 0;
                var fColor = fill >= 80 ? "#DC2626" : (fill >= 60 ? "#D97706" : "#166534");
                var fBg = fill >= 80 ? "#FEE2E2" : (fill >= 60 ? "#FEF3C7" : "#DCFCE7");
                var tr = document.createElement("tr");
                tr.style.borderBottom = "1px solid #F1F5F9";
                tr.innerHTML = '<td style="padding: 8px 12px; text-align: center;">' +
                    '<input type="checkbox" name="binIDs" value="' + b.binID + '" class="route-bin-cb" data-code="' + b.binCode + '" data-fill="' + fill + '" data-cap="' + (b.capacity || 100) + '" checked onchange="updateRouteStats()" style="width: 16px; height: 16px; cursor: pointer;">' +
                    '</td>' +
                    '<td style="padding: 8px 12px; font-weight: 700; font-family: monospace; color: #0F172A;">' + b.binCode + ' <small style="color: #64748B; font-weight: 400; font-family: sans-serif;">(#' + b.binID + ')</small></td>' +
                    '<td style="padding: 8px 12px; color: #334155;">' + b.location + '</td>' +
                    '<td style="padding: 8px 12px; color: #64748B;">' + (b.capacity || 100) + ' L</td>' +
                    '<td style="padding: 8px 12px;"><span style="padding: 2px 8px; border-radius: 6px; font-weight: 700; font-size: 11px; background: ' + fBg + '; color: ' + fColor + ';">' + fill + '%</span></td>';
                tbody.appendChild(tr);
            });
            updateRouteStats();
        }

        function toggleFailureReason() {
            var stElem = document.getElementById('statusSelect');
            if (!stElem) return;
            var st = stElem.value;
            var group = document.getElementById('failureReasonGroup');
            if (group) {
                if (st === 'Failed' || st === 'Skipped') {
                    group.style.display = 'block';
                } else {
                    group.style.display = 'none';
                }
            }
        }

        function scanTargetBin() {
            var binSelect = document.getElementById('binID');
            var code = "";
            if (binSelect && binSelect.value) {
                var selText = binSelect.options ? (binSelect.selectedIndex >= 0 ? binSelect.options[binSelect.selectedIndex].text : "") : binSelect.value;
                var match = selText ? selText.match(/BIN-[A-Za-z0-9-]+/) : null;
                code = match ? match[0] : binSelect.value;
            } else {
                var checked = document.querySelector('.route-bin-cb:checked');
                if (checked) {
                    code = checked.getAttribute('data-code') || checked.value;
                }
            }
            if (!code) {
                code = "<%= collection != null && collection.getBinID() != null ? collection.getBinID() : "" %>";
            }
            if (!code) {
                code = "BIN-A1-03";
            }
            var input = document.getElementById('qrDataInput');
            if (input) {
                input.value = code;
            }
            // Automatically verify immediately upon scanning
            verifyQR();
        }

        function autoVerifyQR() {
            var input = document.getElementById('qrDataInput');
            if (!input) return;
            var val = input.value.trim();
            if (val.length >= 3) {
                verifyQR();
            } else {
                var feedback = document.getElementById('qrFeedback');
                if (feedback) feedback.innerHTML = "";
            }
        }

        function showTargetBinQr() {
            var binSelect = document.getElementById('binID');
            var code = "";
            var loc = "Designated Campus Receptacle";
            if (binSelect && binSelect.value) {
                var selText = binSelect.options[binSelect.selectedIndex].text;
                var match = selText.match(/BIN-[A-Za-z0-9-]+/);
                code = match ? match[0] : binSelect.value;
                loc = selText;
            } else {
                var checked = document.querySelector('.route-bin-cb:checked');
                if (checked) {
                    code = checked.getAttribute('data-code') || checked.value;
                } else {
                    var firstCb = document.querySelector('.route-bin-cb');
                    if (firstCb) {
                        code = firstCb.getAttribute('data-code') || firstCb.value;
                    }
                }
            }
            if (!code) {
                code = "BIN-001";
            }
            document.getElementById('modalTargetBinCode').innerText = code;
            document.getElementById('modalTargetBinLoc').innerText = loc;
            document.getElementById('modalTargetQrImg').src = 'https://api.qrserver.com/v1/create-qr-code/?size=250x250&margin=8&data=' + encodeURIComponent(code);
            document.getElementById('targetBinQrModal').style.display = 'flex';
        }

        function verifyQR() {
            var input = document.getElementById('qrDataInput').value.trim();
            var binSelect = document.getElementById('binID');
            var feedback = document.getElementById('qrFeedback');
            if (!input) {
                feedback.innerHTML = '<div style="color: #DC2626; font-size: 12px; font-weight: 600;"><i class="fa-solid fa-circle-exclamation"></i> Please scan or input a QR code value.</div>';
                return;
            }

            var targetBin = binSelect ? binSelect.value : '<%= collection != null && collection.getBinID() != null ? collection.getBinID() : "" %>';
            var selText = (binSelect && binSelect.selectedIndex >= 0) ? binSelect.options[binSelect.selectedIndex].text : "";

            var isMatch = false;
            var matchedName = input;

            if (targetBin && (input.toUpperCase() === targetBin.toUpperCase() || input.toUpperCase().indexOf(targetBin.toUpperCase()) !== -1)) {
                isMatch = true;
                matchedName = targetBin;
            } else if (selText && selText.toUpperCase().indexOf(input.toUpperCase()) !== -1) {
                isMatch = true;
                matchedName = input.toUpperCase();
            } else {
                var cbs = document.querySelectorAll('.route-bin-cb:checked');
                for (var i = 0; i < cbs.length; i++) {
                    var cbCode = cbs[i].getAttribute('data-code');
                    var cbVal = cbs[i].value;
                    if ((cbCode && cbCode.toUpperCase() === input.toUpperCase()) || (cbVal && cbVal.toUpperCase() === input.toUpperCase())) {
                        isMatch = true;
                        matchedName = cbCode || cbVal;
                        break;
                    }
                }
            }

            if (isMatch) {
                feedback.innerHTML = '<div style="margin-top: 8px; padding: 10px 14px; background: #DCFCE7; border: 1px solid #86EFAC; border-radius: 8px; color: #166534; font-size: 13px; font-weight: 700; display: flex; align-items: center; gap: 8px;">' +
                    '<i class="fa-solid fa-circle-check" style="font-size: 16px;"></i>' +
                    '<span>QR Code Verified! Physical receptacle successfully matched (' + matchedName + ').</span>' +
                    '</div>';
            } else {
                feedback.innerHTML = '<div style="margin-top: 8px; padding: 10px 14px; background: #FEE2E2; border: 1px solid #FCA5A5; border-radius: 8px; color: #991B1B; font-size: 13px; font-weight: 700; display: flex; align-items: center; gap: 8px;">' +
                    '<i class="fa-solid fa-triangle-exclamation" style="font-size: 16px;"></i>' +
                    '<span>Mismatch: Scanned code (' + input + ') does not match selected target bin.</span>' +
                    '</div>';
            }
        }

        // DISPATCH MODE SWITCHER
        function switchDispatchMode(mode) {
            var isRoute = (mode === 'route');
            var btnSingle = document.getElementById('btnModeSingle');
            var btnRoute = document.getElementById('btnModeRoute');
            var singleBinField = document.getElementById('singleBinField');
            var routeBinsField = document.getElementById('routeBinsField');
            var binSelect = document.getElementById('binID');

            if (btnSingle && btnRoute) {
                btnSingle.style.background = isRoute ? '#FFFFFF' : '#166534';
                btnSingle.style.color = isRoute ? '#475569' : '#FFFFFF';
                btnSingle.style.borderColor = isRoute ? '#CBD5E1' : '#166534';

                btnRoute.style.background = isRoute ? '#166534' : '#FFFFFF';
                btnRoute.style.color = isRoute ? '#FFFFFF' : '#475569';
                btnRoute.style.borderColor = isRoute ? '#166534' : '#CBD5E1';
            }

            if (singleBinField) singleBinField.style.display = isRoute ? 'none' : 'block';
            if (routeBinsField) routeBinsField.style.display = isRoute ? 'block' : 'none';

            if (binSelect) {
                if (isRoute) {
                    binSelect.removeAttribute('required');
                } else {
                    binSelect.setAttribute('required', 'required');
                }
            }

            var dispReqInput = document.getElementById('dispReqID');
            if (dispReqInput) {
                dispReqInput.value = isRoute ? "Auto-generated (1 ticket per bin)" : "<%= reqIdVal %>";
                dispReqInput.style.fontStyle = isRoute ? "italic" : "normal";
                dispReqInput.style.color = isRoute ? "#166534" : "";
                dispReqInput.style.fontWeight = isRoute ? "600" : "normal";
            }

            var dispatchModeInput = document.getElementById('dispatchModeInput');
            if (dispatchModeInput) {
                dispatchModeInput.value = mode;
            }

            var submitBtnText = document.getElementById('submitBtnText');
            if (submitBtnText) {
                submitBtnText.innerText = isRoute ? "Dispatch Collection Route" : "Dispatch Task";
            }

            var reqIdHint = document.getElementById('reqIdHint');
            if (reqIdHint) {
                reqIdHint.innerHTML = isRoute 
                    ? '<i class="fa-solid fa-list-ol" style="font-size: 10px;"></i> Sequential ticket IDs will be auto-assigned to each route stop.'
                    : '<i class="fa-solid fa-lock" style="font-size: 10px;"></i> Auto-assigned sequential task ticket (e.g. <%= reqIdVal %>).';
            }

            if (isRoute) {
                updateRouteStats();
            }
        }

        function updateRouteStats() {
            var cbs = document.querySelectorAll('.route-bin-cb:checked');
            var count = cbs.length;
            var totalVol = 0;
            cbs.forEach(function (cb) {
                var cap = parseFloat(cb.getAttribute('data-cap')) || 100;
                var fill = parseFloat(cb.getAttribute('data-fill')) || 80;
                totalVol += Math.round(cap * (fill / 100));
            });
            var stCount = document.getElementById('routeStopsCount');
            var volCount = document.getElementById('routeVolumeCount');
            if (stCount) stCount.innerText = count;
            if (volCount) volCount.innerText = totalVol;
        }

        function selectAllHotspot() {
            var cbs = document.querySelectorAll('.route-bin-cb');
            cbs.forEach(function (cb) {
                var fill = parseFloat(cb.getAttribute('data-fill')) || 0;
                cb.checked = (fill >= 80);
            });
            updateRouteStats();
        }

        function selectAllRouteBins(check) {
            var cbs = document.querySelectorAll('.route-bin-cb');
            cbs.forEach(function (cb) {
                cb.checked = check;
            });
            updateRouteStats();
        }

        document.addEventListener("DOMContentLoaded", function () {
            <% if (isRouteMode) { %>
                switchDispatchMode('route');
                updateRouteStats();
            <% } %>
        });

        function previewImg(inputId, imgId) {
            var val = document.getElementById(inputId).value;
            var img = document.getElementById(imgId);
            if (val && val.trim().length > 0) {
                img.src = val;
                img.style.display = 'block';
            } else {
                img.style.display = 'none';
            }
        }

        function setSamplePhoto(inputId, imgId, url) {
            document.getElementById(inputId).value = url;
            previewImg(inputId, imgId);
        }
    </script>

    <!-- TARGET BIN QR BADGE MODAL -->
    <div id="targetBinQrModal" style="display: none; position: fixed; inset: 0; background: rgba(15, 23, 42, 0.65); backdrop-filter: blur(4px); z-index: 9999; align-items: center; justify-content: center;">
        <div style="background: #ffffff; border-radius: 12px; padding: 24px; width: 90%; max-width: 360px; text-align: center; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.25); position: relative;">
            <button type="button" onclick="document.getElementById('targetBinQrModal').style.display='none'" style="position: absolute; top: 12px; right: 12px; border: none; background: none; font-size: 22px; color: #94a3b8; cursor: pointer;">&times;</button>
            <div style="font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: #166534; margin-bottom: 6px;">Target Waste Bin QR Badge</div>
            <h3 id="modalTargetBinCode" style="margin: 0 0 12px; font-size: 20px; font-family: monospace; font-weight: 800; color: #0f172a;"></h3>
            <div style="background: #ffffff; padding: 10px; border-radius: 10px; border: 2px solid #0f172a; display: inline-block; margin-bottom: 12px;">
                <img id="modalTargetQrImg" src="" alt="Target Bin QR Code" style="width: 180px; height: 180px; display: block;">
            </div>
            <p id="modalTargetBinLoc" style="font-size: 12px; color: #64748b; margin: 0 0 16px;"></p>
            <div style="display: flex; gap: 8px; justify-content: center;">
                <button type="button" onclick="scanTargetBin(); document.getElementById('targetBinQrModal').style.display='none';" class="btn-smart-primary" style="padding: 8px 16px; background: #166534; border-color: #166534;">
                    <i class="fa-solid fa-qrcode"></i> Scan this QR
                </button>
                <button type="button" onclick="document.getElementById('targetBinQrModal').style.display='none'" class="btn-smart-secondary" style="padding: 8px 16px;">Close</button>
            </div>
        </div>
    </div>
</body>
</html>
