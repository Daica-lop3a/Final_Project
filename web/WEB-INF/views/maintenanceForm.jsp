<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="model.Maintenance"%>
<%@page import="model.WasteBin"%>
<%@page import="model.AppUser"%>
<%@page import="java.util.List"%>

<%
    String ctx = request.getContextPath();
    Maintenance maintenance = (Maintenance) request.getAttribute("MAINTENANCE");
    List<WasteBin> bins = (List<WasteBin>) request.getAttribute("LIST_BIN");
    List<AppUser> technicians = (List<AppUser>) request.getAttribute("LIST_TECHNICIAN");
    AppUser user = (AppUser) session.getAttribute("user");
    String role = user != null ? user.getRoleId() : "";
    boolean isEdit = "EDIT".equals(request.getAttribute("MODE"));
    boolean isTechnician = "TEC".equals(role);
    String error = (String) request.getAttribute("ERROR");

    String maintenanceID = maintenance != null && maintenance.getMaintenanceID() != null ? maintenance.getMaintenanceID() : "";
    String binID = maintenance != null && maintenance.getBinID() != null ? maintenance.getBinID() : "";
    String technicianID = maintenance != null && maintenance.getTechnicianID() != null ? maintenance.getTechnicianID() : (user != null ? user.getUserId() : "");
    String maintenanceType = maintenance != null && maintenance.getMaintenanceType() != null ? maintenance.getMaintenanceType() : "";
    String status = maintenance != null && maintenance.getStatus() != null ? maintenance.getStatus() : "Pending";

    String scheduledDate = "";
    if (maintenance != null && maintenance.getScheduledDate() != null) {
        scheduledDate = maintenance.getScheduledDate().toString().replace(" ", "T").substring(0, 16);
    }

    String completedDate = "";
    if (maintenance != null && maintenance.getCompletedDate() != null) {
        completedDate = maintenance.getCompletedDate().toString().replace(" ", "T").substring(0, 16);
    }

    String description = maintenance != null && maintenance.getDescription() != null ? maintenance.getDescription() : "";
    String resolutionNotes = maintenance != null && maintenance.getResolutionNotes() != null ? maintenance.getResolutionNotes() : "";
    String rootCause = maintenance != null && maintenance.getRootCause() != null ? maintenance.getRootCause() : "";
    String repairMethod = maintenance != null && maintenance.getRepairMethod() != null ? maintenance.getRepairMethod() : "";
    String replacedParts = maintenance != null && maintenance.getReplacedParts() != null ? maintenance.getReplacedParts() : "";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "Edit Maintenance Ticket" : "Dispatch Maintenance Ticket" %> - SmartWaste</title>
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
                        <a href="<%=ctx%>/maintenance" style="color: var(--color-slate-400);">Maintenance</a>
                        <i class="fa-solid fa-chevron-right" style="font-size: 9px;"></i>
                        <span style="color: var(--brand-forest);"><%= isEdit ? "Edit Ticket" : "New Ticket" %></span>
                    </div>
                    <h1><%= isEdit ? "Maintenance Ticket " + maintenanceID : "Create Maintenance Work Order" %></h1>
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
                    <form method="POST" action="<%=ctx%>/maintenance/save">
                        <input type="hidden" name="maintenanceID" value="<%= maintenanceID %>">

                        <!-- SECTION 1: WORK ORDER SPECIFICATION -->
                        <div class="form-section-divider">
                            <i class="fa-solid fa-wrench"></i>
                            <span>Work Order Specification</span>
                        </div>

                        <div class="form-grid">
                            
                            <!-- Maintenance ID (Sequential / Readonly) -->
                            <div class="form-field">
                                <label class="form-label" for="dispMntID">
                                    Maintenance Ticket ID <span class="required">*</span>
                                </label>
                                <input type="text" id="dispMntID" class="form-input"
                                       value="<%= maintenanceID %>"
                                       readonly
                                       required>
                                <span class="form-hint">
                                    <i class="fa-solid fa-lock" style="font-size: 10px;"></i>
                                    Auto-assigned sequential work order ID (e.g. MNT-007).
                                </span>
                            </div>

                            <!-- Waste Bin -->
                            <div class="form-field">
                                <label class="form-label" for="binID">
                                    Target Waste Bin <span class="required">*</span>
                                </label>
                                <%
                                    WasteBin currentBinObj = null;
                                    if (bins != null && !binID.isEmpty()) {
                                        for (WasteBin b : bins) {
                                            if (b.getBinID() != null && b.getBinID().equalsIgnoreCase(binID)) {
                                                currentBinObj = b;
                                                break;
                                            }
                                        }
                                    }
                                %>
                                <% if (isTechnician && isEdit) { %>
                                    <input type="text" class="form-input" 
                                           value="<%= currentBinObj != null ? ((currentBinObj.getBinCode() != null ? currentBinObj.getBinCode() : currentBinObj.getBinID()) + " — " + currentBinObj.getLocation() + " (" + binID + ")") : binID %>" 
                                           readonly style="background: #F8FAF9; font-weight: 600;">
                                    <input type="hidden" name="binID" value="<%= binID %>">
                                    <span class="form-hint"><i class="fa-solid fa-lock" style="font-size: 10px;"></i> Target receptacle locked during technician resolution.</span>
                                <% } else { %>
                                    <select id="binID" name="binID" class="form-select" required>
                                        <option value="">-- Select Waste Bin --</option>
                                        <% if (bins != null) {
                                            for (WasteBin bin : bins) {
                                                boolean sel = bin.getBinID() != null && bin.getBinID().equalsIgnoreCase(binID);
                                        %>
                                        <option value="<%= bin.getBinID() %>" <%= sel ? "selected" : "" %>>
                                            <%= bin.getBinCode() != null && !bin.getBinCode().isEmpty() ? bin.getBinCode() : bin.getBinID() %> &mdash; <%= bin.getLocation() %> (<%= bin.getBinID() %>)
                                        </option>
                                        <% } } %>
                                    </select>
                                    <span class="form-hint"><i class="fa-solid fa-trash-can" style="font-size: 10px;"></i> Select the target bin (displayed by Physical Code, Location &amp; ID).</span>
                                <% } %>
                            </div>

                            <!-- Assigned Technician -->
                            <div class="form-field">
                                <label class="form-label" for="technicianID">
                                    Assigned Technician <span class="required">*</span>
                                </label>
                                <% if (isTechnician) { %>
                                    <input type="text" class="form-input" value="<%= technicianID %>" readonly>
                                    <input type="hidden" name="technicianID" value="<%= technicianID %>">
                                    <span class="form-hint">Current technician assignment is locked.</span>
                                <% } else { %>
                                    <select id="technicianID" name="technicianID" class="form-select" required>
                                        <option value="">-- Select Technician --</option>
                                        <% if (technicians != null) {
                                            for (AppUser tech : technicians) {
                                                boolean sel = tech.getUserId() != null && tech.getUserId().equals(technicianID);
                                        %>
                                        <option value="<%= tech.getUserId() %>" <%= sel ? "selected" : "" %>>
                                            <%= tech.getUserId() %> &mdash; <%= tech.getFullName() %>
                                        </option>
                                        <% } } %>
                                    </select>
                                    <span class="form-hint">Hardware engineer or technician responsible.</span>
                                <% } %>
                            </div>

                            <!-- Maintenance Type -->
                            <div class="form-field">
                                <label class="form-label" for="maintenanceType">
                                    Maintenance Type <span class="required">*</span>
                                </label>
                                <% if (isTechnician && isEdit) { %>
                                    <input type="text" class="form-input" value="<%= maintenanceType %>" readonly>
                                    <input type="hidden" name="maintenanceType" value="<%= maintenanceType %>">
                                <% } else { %>
                                    <select id="maintenanceType" name="maintenanceType" class="form-select" required>
                                        <option value="">-- Select Type --</option>
                                        <option value="Repair" <%= "Repair".equals(maintenanceType) ? "selected" : "" %>>Repair (Physical structural)</option>
                                        <option value="Inspection" <%= "Inspection".equals(maintenanceType) ? "selected" : "" %>>Inspection (Diagnostic check)</option>
                                        <option value="Replacement" <%= "Replacement".equals(maintenanceType) ? "selected" : "" %>>Replacement (Sensor/Battery swap)</option>
                                        <option value="Sensor_Check" <%= "Sensor_Check".equals(maintenanceType) ? "selected" : "" %>>Sensor Check (Telemetry test)</option>
                                        <option value="Calibration" <%= "Calibration".equals(maintenanceType) ? "selected" : "" %>>Calibration (Sensor recalibration)</option>
                                    </select>
                                <% } %>
                            </div>

                            <!-- Status -->
                            <div class="form-field">
                                <label class="form-label" for="status">
                                    Execution Status <span class="required">*</span>
                                </label>
                                <select id="status" name="status" class="form-select" required>
                                    <option value="Pending" <%= "Pending".equals(status) ? "selected" : "" %>>Pending</option>
                                    <option value="In_Progress" <%= "In_Progress".equals(status) ? "selected" : "" %>>In Progress</option>
                                    <option value="Completed" <%= "Completed".equals(status) ? "selected" : "" %>>Completed</option>
                                    <option value="Cancelled" <%= "Cancelled".equals(status) ? "selected" : "" %>>Cancelled</option>
                                </select>
                            </div>

                            <!-- Scheduled Date -->
                            <div class="form-field">
                                <label class="form-label" for="scheduledDate">Scheduled Window</label>
                                <input type="datetime-local" id="scheduledDate" name="scheduledDate" class="form-input"
                                       value="<%= scheduledDate %>">
                            </div>

                            <!-- Completed Date -->
                            <div class="form-field form-grid-full">
                                <label class="form-label" for="completedDate">Completion Timestamp</label>
                                <input type="datetime-local" id="completedDate" name="completedDate" class="form-input"
                                       value="<%= completedDate %>">
                                <span class="form-hint">If status is set to Completed and this is left empty, the system automatically logs the current timestamp.</span>
                            </div>

                            <!-- Description -->
                            <div class="form-field form-grid-full">
                                <label class="form-label" for="description">Issue Description</label>
                                <textarea id="description" name="description" rows="3" class="form-textarea"
                                          placeholder="Detailed symptom report, e.g. fill sensor stuck at 95% reading or damaged hinge..."><%= description %></textarea>
                            </div>

                        </div>

                        <!-- SECTION 2: TECHNICIAN FIELD DIAGNOSTIC & RESOLUTION -->
                        <div class="form-section-divider" style="margin-top: 32px;">
                            <i class="fa-solid fa-screwdriver-wrench"></i>
                            <span>Technician Diagnostic &amp; Resolution Report</span>
                        </div>

                        <div class="form-grid">
                            
                            <!-- Root Cause -->
                            <div class="form-field">
                                <label class="form-label" for="rootCause">Technical Root Cause</label>
                                <input type="text" id="rootCause" name="rootCause" class="form-input"
                                       value="<%= rootCause %>"
                                       placeholder="e.g. Ultrasonic membrane dirty / Telemetry timeout / Battery depleted">
                                <span class="form-hint">Primary malfunction identified during bench testing or site inspection.</span>
                            </div>

                            <!-- Repair Method -->
                            <div class="form-field">
                                <label class="form-label" for="repairMethod">Repair &amp; Calibration Method</label>
                                <input type="text" id="repairMethod" name="repairMethod" class="form-input"
                                       value="<%= repairMethod %>"
                                       placeholder="e.g. Sensor baseline offset recalibrated / Firmware flashed / Lens wiped">
                                <span class="form-hint">Corrective technical protocol applied.</span>
                            </div>

                            <!-- Replaced Components -->
                            <div class="form-field form-grid-full">
                                <label class="form-label" for="replacedParts">Replaced Hardware Components</label>
                                <input type="text" id="replacedParts" name="replacedParts" class="form-input"
                                       value="<%= replacedParts %>"
                                       placeholder="e.g. 1x Ultrasonic Transceiver Module, 1x 3.7V Li-ion Pack (or None)">
                                <span class="form-hint">Bill of materials or spare parts consumed.</span>
                            </div>

                            <!-- Resolution Notes -->
                            <div class="form-field form-grid-full">
                                <label class="form-label" for="resolutionNotes">Field Resolution Notes</label>
                                <textarea id="resolutionNotes" name="resolutionNotes" rows="3" class="form-textarea"
                                          placeholder="Verified post-calibration variance, technician handover instructions..."><%= resolutionNotes %></textarea>
                            </div>

                        </div>

                        <!-- BUTTON ACTIONS -->
                        <div class="form-actions-bar">
                            <a href="<%=ctx%>/maintenance" class="btn-smart-secondary">
                                <i class="fa-solid fa-arrow-left"></i> Cancel
                            </a>
                            <button type="submit" class="btn-smart-primary">
                                <i class="fa-solid fa-floppy-disk"></i>
                                <%= isEdit ? "Update Work Order" : "Dispatch Maintenance" %>
                            </button>
                        </div>

                    </form>
                </div>
            </div>
        </main>
    </div>

</body>
</html>
