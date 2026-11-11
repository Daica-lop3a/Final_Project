<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="model.AppUser"%>
<%
    String ctx = request.getContextPath();
    AppUser user = (AppUser) session.getAttribute("user");

    String targetEntity = (String) request.getAttribute("targetEntity");
    String targetID = (String) request.getAttribute("targetID");
    String discrepancyType = (String) request.getAttribute("discrepancyType");
    String title = (String) request.getAttribute("title");
    String desc = (String) request.getAttribute("description");
    String severity = (String) request.getAttribute("severity");
    String error = (String) request.getAttribute("ERROR");
    String nextDiscId = (String) request.getAttribute("NEXT_DISCREPANCY_ID");
    if (nextDiscId == null) nextDiscId = "DISC-Auto";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Log Audit Discrepancy Finding - SmartWaste</title>
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
                        <a href="<%=ctx%>/discrepancy" style="color: var(--color-slate-400);">Audit Discrepancies</a>
                        <i class="fa-solid fa-chevron-right" style="font-size: 9px;"></i>
                        <span style="color: var(--brand-forest);">New Case</span>
                    </div>
                    <h1>Log Audit Discrepancy &amp; Finding Case</h1>
                </div>

                <!-- ERROR ALERT -->
                <% if (error != null && !error.trim().isEmpty()) { %>
                    <div style="padding: 12px 16px; background: #FEE2E2; border: 1px solid #FCA5A5; border-radius: 8px; color: #991B1B; font-size: 13px; font-weight: 600; margin-bottom: 20px; display: flex; align-items: center; gap: 8px;">
                        <i class="fa-solid fa-circle-exclamation"></i>
                        <span><%= error %></span>
                    </div>
                <% } %>

                <!-- AUDITOR PRINCIPLE NOTICE -->
                <div style="padding: 14px 18px; background: var(--color-m0601); border: 1px solid var(--color-m0573); border-radius: 10px; color: var(--color-slate-900); font-size: 13px; margin-bottom: 24px; display: flex; gap: 12px; align-items: flex-start;">
                    <i class="fa-solid fa-file-shield" style="color: var(--brand-forest); font-size: 18px; margin-top: 2px;"></i>
                    <div>
                        <strong style="color: var(--brand-forest);">Auditor Non-Destructive Integrity Principle:</strong>
                        <div style="margin-top: 2px; color: var(--color-slate-600); line-height: 1.5;">
                            Operational records (telemetry logs, timestamps, field results) remain completely untouched. Logging this case opens a formal verification dossier to track investigation and reconciliation across operational tiers.
                        </div>
                    </div>
                </div>

                <!-- FORM CARD -->
                <div class="smartwaste-form-card">
                    <form method="POST" action="<%=ctx%>/discrepancy/save">

                        <div class="form-section-divider">
                            <i class="fa-solid fa-magnifying-glass-chart"></i>
                            <span>Audit Finding Identification</span>
                        </div>

                        <div class="form-grid">
                            
                            <!-- Sequential ID Display -->
                            <div class="form-field">
                                <label class="form-label" for="dispDiscID">
                                    Discrepancy Case ID <span class="required">*</span>
                                </label>
                                <input type="text" id="dispDiscID" class="form-input"
                                       value="<%= nextDiscId %>"
                                       readonly
                                       required>
                                <span class="form-hint">
                                    <i class="fa-solid fa-lock" style="font-size: 10px;"></i>
                                    Auto-assigned sequential case identifier (e.g. DISC-002).
                                </span>
                            </div>

                            <!-- Severity Level -->
                            <div class="form-field">
                                <label class="form-label" for="severity">
                                    Severity Level <span class="required">*</span>
                                </label>
                                <select id="severity" name="severity" class="form-select" required>
                                    <option value="Low" <%= "Low".equals(severity) ? "selected" : "" %>>Low (Minor record irregularity)</option>
                                    <option value="Medium" <%= "Medium".equals(severity) || severity == null ? "selected" : "" %>>Medium (Telemetry delay or data gap)</option>
                                    <option value="High" <%= "High".equals(severity) ? "selected" : "" %>>High (Sensor failure or missed route)</option>
                                    <option value="Critical" <%= "Critical".equals(severity) ? "selected" : "" %>>Critical (Telemetry tamper / Hardware failure)</option>
                                </select>
                            </div>

                            <!-- Finding Title -->
                            <div class="form-field form-grid-full">
                                <label class="form-label" for="title">
                                    Finding Title <span class="required">*</span>
                                </label>
                                <input type="text" id="title" name="title" class="form-input"
                                       placeholder="e.g. Consecutive duplicate collection logged within 0m for Bin BIN-001"
                                       value="<%= title != null ? title : "" %>"
                                       required>
                                <span class="form-hint">Concise summary of the audit anomaly detected.</span>
                            </div>

                            <!-- Discrepancy Type -->
                            <div class="form-field">
                                <label class="form-label" for="discrepancyType">
                                    Discrepancy Category <span class="required">*</span>
                                </label>
                                <select id="discrepancyType" name="discrepancyType" class="form-select" required>
                                    <option value="Collection_Mismatch" <%= "Collection_Mismatch".equals(discrepancyType) ? "selected" : "" %>>Collection Mismatch</option>
                                    <option value="Duplicate_Collection" <%= "Duplicate_Collection".equals(discrepancyType) ? "selected" : "" %>>Duplicate Collection (&le;30m)</option>
                                    <option value="Incomplete_Data" <%= "Incomplete_Data".equals(discrepancyType) ? "selected" : "" %>>Incomplete Collection Records</option>
                                    <option value="Sensor_Deviation" <%= "Sensor_Deviation".equals(discrepancyType) ? "selected" : "" %>>Sensor vs Field Inspection (&ge;20%)</option>
                                    <option value="Stuck_Sensor" <%= "Stuck_Sensor".equals(discrepancyType) ? "selected" : "" %>>Stuck Telemetry Value</option>
                                    <option value="Config_Change" <%= "Config_Change".equals(discrepancyType) ? "selected" : "" %>>Threshold / Config Modification</option>
                                    <option value="Other" <%= "Other".equals(discrepancyType) ? "selected" : "" %>>Other Operational Inconsistency</option>
                                </select>
                            </div>

                            <!-- Target Entity -->
                            <div class="form-field">
                                <label class="form-label" for="targetEntity">
                                    Target Entity Scope <span class="required">*</span>
                                </label>
                                <select id="targetEntity" name="targetEntity" class="form-select" required>
                                    <option value="Collection" <%= "Collection".equals(targetEntity) ? "selected" : "" %>>Collection Task</option>
                                    <option value="Bin" <%= "Bin".equals(targetEntity) ? "selected" : "" %>>Waste Bin Receptacle</option>
                                    <option value="Device" <%= "Device".equals(targetEntity) ? "selected" : "" %>>IoT Sensor Device</option>
                                    <option value="Inspection" <%= "Inspection".equals(targetEntity) ? "selected" : "" %>>Bin Inspection Record</option>
                                    <option value="User" <%= "User".equals(targetEntity) ? "selected" : "" %>>User Account / Role</option>
                                    <option value="Config" <%= "Config".equals(targetEntity) ? "selected" : "" %>>System Configuration</option>
                                </select>
                            </div>

                            <!-- Target Record ID -->
                            <div class="form-field form-grid-full">
                                <label class="form-label" for="targetID">
                                    Target Record ID
                                </label>
                                <input type="text" id="targetID" name="targetID" class="form-input"
                                       placeholder="e.g. REQ-001, BIN-003, DEV-004, or INSP-002"
                                       value="<%= targetID != null ? targetID : "" %>">
                                <span class="form-hint">Database primary key of the questioned record.</span>
                            </div>

                            <!-- Description -->
                            <div class="form-field form-grid-full">
                                <label class="form-label" for="description">
                                    Detailed Audit Observation &amp; Finding Evidence
                                </label>
                                <textarea id="description" name="description" rows="3" class="form-textarea"
                                          placeholder="Provide contextual evidence, compare timestamps vs sensor readings, and describe the specific flaw observed..."><%= desc != null ? desc : "" %></textarea>
                            </div>

                            <!-- Initial Investigation Directive -->
                            <div class="form-field form-grid-full">
                                <label class="form-label" for="investigationNotes">
                                    Initial Investigation Directive &amp; Remediation Plan
                                </label>
                                <textarea id="investigationNotes" name="investigationNotes" rows="3" class="form-textarea"
                                          placeholder="Specific requests for Supervisor, Area Manager, or Technician verification..."></textarea>
                            </div>

                        </div>

                        <!-- BUTTON ACTIONS -->
                        <div class="form-actions-bar">
                            <a href="<%=ctx%>/discrepancy" class="btn-smart-secondary">
                                <i class="fa-solid fa-arrow-left"></i> Cancel
                            </a>
                            <button type="submit" class="btn-smart-primary">
                                <i class="fa-solid fa-file-circle-check"></i> Open Investigation Case
                            </button>
                        </div>

                    </form>
                </div>
            </div>
        </main>
    </div>

</body>
</html>
