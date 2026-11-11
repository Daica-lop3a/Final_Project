<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.BinInspection"%>
<%@page import="model.WasteBin"%>
<%@page import="model.AppUser"%>

<%!
    private String esc(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }
%>

<%
    String ctx = request.getContextPath();
    BinInspection inspection = (BinInspection) request.getAttribute("INSPECTION");
    List<WasteBin> bins = (List<WasteBin>) request.getAttribute("LIST_BINS");
    String mode = (String) request.getAttribute("MODE");
    String error = (String) request.getAttribute("ERROR");
    boolean isCreate = "CREATE".equalsIgnoreCase(mode);
    String inspId = inspection != null && inspection.getInspectionID() != null ? inspection.getInspectionID() : "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isCreate ? "Record Bin Inspection" : "Edit Bin Inspection" %> - SmartWaste</title>
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
                        <a href="<%=ctx%>/inspection" style="color: var(--color-slate-400);">Inspections</a>
                        <i class="fa-solid fa-chevron-right" style="font-size: 9px;"></i>
                        <span style="color: var(--brand-forest);"><%= isCreate ? "New Inspection" : "Edit Inspection" %></span>
                    </div>
                    <h1><%= isCreate ? "Record Physical Bin Inspection" : "Edit Inspection " + inspId %></h1>
                </div>

                <!-- ERROR ALERT -->
                <% if (error != null && !error.trim().isEmpty()) { %>
                    <div style="padding: 12px 16px; background: #FEE2E2; border: 1px solid #FCA5A5; border-radius: 8px; color: #991B1B; font-size: 13px; font-weight: 600; margin-bottom: 20px; display: flex; align-items: center; gap: 8px;">
                        <i class="fa-solid fa-circle-exclamation"></i>
                        <span><%= esc(error) %></span>
                    </div>
                <% } %>

                <!-- FORM CARD -->
                <div class="smartwaste-form-card">
                    <form action="<%=ctx%>/inspection/save" method="POST">
                        <input type="hidden" name="inspectionID" value="<%= esc(inspId) %>">

                        <div class="form-section-divider">
                            <i class="fa-solid fa-clipboard-check"></i>
                            <span>Field Ground-Truth Verification</span>
                        </div>

                        <div class="form-grid">
                            
                            <!-- Inspection Primary Key (Sequential / Readonly) -->
                            <div class="form-field">
                                <label class="form-label" for="dispInspectionID">
                                    Inspection ID <span class="required">*</span>
                                </label>
                                <input type="text" id="dispInspectionID" class="form-input"
                                       value="<%= esc(inspId) %>"
                                       readonly
                                       required>
                                <span class="form-hint">
                                    <i class="fa-solid fa-lock" style="font-size: 10px;"></i>
                                    Auto-assigned sequential inspection record identifier.
                                </span>
                            </div>

                            <!-- Target Waste Bin -->
                            <div class="form-field">
                                <label class="form-label" for="binID">
                                    Target Waste Bin <span class="required">*</span>
                                </label>
                                <select id="binID" name="binID" class="form-select" required onchange="onBinChanged()">
                                    <%
                                        if (bins != null) {
                                            for (WasteBin b : bins) {
                                                boolean selected = inspection != null && b.getBinID().equals(inspection.getBinID());
                                    %>
                                    <option value="<%=esc(b.getBinID())%>" data-fill="<%=b.getCurrentFill()%>" <%=selected ? "selected" : ""%>>
                                        <%=esc(b.getBinCode() != null ? b.getBinCode() : b.getBinID())%> &mdash; <%=esc(b.getLocation())%> (IoT: <%=b.getCurrentFill()%>%)
                                    </option>
                                    <%
                                            }
                                        }
                                    %>
                                </select>
                                <span class="form-hint">Select the campus receptacle undergoing physical audit.</span>
                            </div>

                            <!-- Live IoT Sensor Reading -->
                            <div class="form-field">
                                <label class="form-label" for="sensorFillPercent">
                                    Live IoT Sensor Reading (%)
                                </label>
                                <input type="number" id="sensorFillPercent" name="sensorFillPercent" class="form-input"
                                       value="<%= inspection != null ? inspection.getSensorFillPercent() : 0 %>"
                                       readonly
                                       style="background: var(--color-m0601); font-weight: 700; color: var(--brand-forest);">
                                <span class="form-hint">Telemetry level currently reported by ultrasound/weight sensor.</span>
                            </div>

                            <!-- Physical Ground-Truth Fill Level -->
                            <div class="form-field">
                                <label class="form-label" for="actualFillPercent">
                                    Physical Ground-Truth Fill Level (%) <span class="required">*</span>
                                </label>
                                <input type="number" id="actualFillPercent" name="actualFillPercent" class="form-input"
                                       min="0" max="100"
                                       value="<%= inspection != null ? inspection.getActualFillPercent() : 0 %>"
                                       required
                                       oninput="calculateDiscrepancy()">
                                <span class="form-hint">Actual waste volume percentage visually observed by staff.</span>
                            </div>

                            <!-- Variance Indicator Card -->
                            <div class="form-field form-grid-full">
                                <div id="discrepancyContainer" style="background: var(--color-m0601); border: 1px solid var(--color-m0573); border-radius: 10px; padding: 14px 18px; display: flex; align-items: center; justify-content: space-between; transition: all 0.2s;">
                                    <div>
                                        <div style="font-size: 11px; font-weight: 800; color: var(--color-slate-400); text-transform: uppercase; letter-spacing: 0.06em;">Observed Telemetry Variance</div>
                                        <div style="font-size: 13px; font-weight: 600; margin-top: 3px; color: var(--color-slate-900);" id="discrepancyNotice">Discrepancy within normal operational threshold.</div>
                                    </div>
                                    <div id="discrepancyValue" style="font-size: 24px; font-weight: 800; color: var(--brand-forest);">0%</div>
                                </div>
                            </div>

                            <!-- Physical Condition -->
                            <div class="form-field">
                                <label class="form-label" for="physicalCondition">
                                    Physical Bin Condition
                                </label>
                                <select id="physicalCondition" name="physicalCondition" class="form-select">
                                    <%
                                        String cond = inspection != null ? inspection.getPhysicalCondition() : "Good";
                                        String[] conds = {"Good", "Damaged", "Obstructed Lid", "Sensor Dirty", "Odor Leak", "Vandalized"};
                                        for (String c : conds) {
                                    %>
                                    <option value="<%=c%>" <%=c.equalsIgnoreCase(cond) ? "selected" : ""%>><%=c%></option>
                                    <% } %>
                                </select>
                            </div>

                            <!-- Action Taken -->
                            <div class="form-field">
                                <label class="form-label" for="actionTaken">
                                    Action Taken On Site
                                </label>
                                <select id="actionTaken" name="actionTaken" class="form-select">
                                    <%
                                        String act = inspection != null ? inspection.getActionTaken() : "None";
                                        String[] acts = {"None", "Cleaned Sensor / Lid", "Dispatched Collector", "Reported Vandalism", "Requested Technician"};
                                        for (String a : acts) {
                                    %>
                                    <option value="<%=a%>" <%=a.equalsIgnoreCase(act) ? "selected" : ""%>><%=a%></option>
                                    <% } %>
                                </select>
                            </div>

                            <!-- Maintenance Dispatch Checkbox -->
                            <div class="form-field form-grid-full">
                                <label style="display: flex; align-items: center; gap: 10px; cursor: pointer; font-size: 13px; font-weight: 600; color: var(--color-slate-900);">
                                    <input type="checkbox" name="createMaintenance" value="true" checked style="width: 17px; height: 17px; accent-color: var(--brand-forest);">
                                    <span>Automatically dispatch Maintenance Ticket to Area Technician if discrepancy &ge; 20% or bin is Damaged</span>
                                </label>
                            </div>

                            <!-- Notes -->
                            <div class="form-field form-grid-full">
                                <label class="form-label" for="notes">
                                    Field Notes &amp; Observations
                                </label>
                                <textarea id="notes" name="notes" rows="3" class="form-textarea"
                                          placeholder="Enter observational details, e.g., plastic wrap covering ultrasonic sensor, deformed lid..."><%= inspection != null ? esc(inspection.getNotes()) : "" %></textarea>
                            </div>

                        </div>

                        <!-- BUTTON ACTIONS -->
                        <div class="form-actions-bar">
                            <a href="<%=ctx%>/inspection" class="btn-smart-secondary">
                                <i class="fa-solid fa-arrow-left"></i> Cancel
                            </a>
                            <button type="submit" class="btn-smart-primary">
                                <i class="fa-solid fa-floppy-disk"></i>
                                <%= isCreate ? "Save Inspection" : "Update Record" %>
                            </button>
                        </div>

                    </form>
                </div>
            </div>
        </main>
    </div>

    <script>
        function onBinChanged() {
            var binSelect = document.getElementById('binID');
            var selectedOption = binSelect.options[binSelect.selectedIndex];
            if (selectedOption) {
                var fill = selectedOption.getAttribute('data-fill') || 0;
                document.getElementById('sensorFillPercent').value = fill;
                calculateDiscrepancy();
            }
        }

        function calculateDiscrepancy() {
            var sensor = parseInt(document.getElementById('sensorFillPercent').value) || 0;
            var actual = parseInt(document.getElementById('actualFillPercent').value) || 0;
            var disc = actual - sensor;
            var valEl = document.getElementById('discrepancyValue');
            var noticeEl = document.getElementById('discrepancyNotice');
            var container = document.getElementById('discrepancyContainer');

            valEl.innerText = (disc > 0 ? "+" : "") + disc + "%";

            if (Math.abs(disc) >= 20) {
                container.style.background = "#FEE2E2";
                container.style.borderColor = "#FCA5A5";
                valEl.style.color = "#DC2626";
                noticeEl.innerText = "High sensor drift detected (>= 20%). Sensor recalibration or inspection needed!";
                noticeEl.style.color = "#991B1B";
            } else {
                container.style.background = "var(--color-m0601)";
                container.style.borderColor = "var(--color-m0573)";
                valEl.style.color = "var(--brand-forest)";
                noticeEl.innerText = "Telemetry variance is within acceptable operational tolerance.";
                noticeEl.style.color = "var(--color-slate-900)";
            }
        }

        window.addEventListener('DOMContentLoaded', function() {
            calculateDiscrepancy();
        });
    </script>
</body>
</html>
