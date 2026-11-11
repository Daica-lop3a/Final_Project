<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="model.Alert"%>
<%@page import="model.AppUser"%>
<%@page import="java.util.List"%>
<%@page import="model.WasteBin"%>

<%
    String ctx = request.getContextPath();
    Alert alert = (Alert) request.getAttribute("ALERT");
    AppUser user = (AppUser) session.getAttribute("user");

    boolean canManage = user != null
            && ("ADM".equals(user.getRoleId())
            || "MGR".equals(user.getRoleId())
            || "SUP".equals(user.getRoleId())
            || "SAD".equals(user.getRoleId()));

    boolean isEdit = Boolean.TRUE.equals(request.getAttribute("IS_EDIT"));
    if (alert == null) {
        alert = new Alert();
    }

    String nextAlertId = (String) request.getAttribute("NEXT_ALERT_ID");
    String alertID = alert.getAlertID() == null ? "" : alert.getAlertID();
    if (!isEdit && (alertID.isEmpty() || alertID.startsWith("ALT-")) && nextAlertId != null) {
        alertID = nextAlertId;
    }

    String binID = alert.getBinID() == null ? "" : alert.getBinID();
    String alertType = alert.getAlertType() == null ? "" : alert.getAlertType();
    String message = alert.getMessage() == null ? "" : alert.getMessage();

    String error = (String) request.getAttribute("ERROR");
    if (error == null) error = (String) request.getAttribute("error");

    Object binsAttribute = request.getAttribute("BINS");
    List<?> bins = binsAttribute instanceof List ? (List<?>) binsAttribute : null;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "Edit Alert" : "Broadcast System Alert" %> - SmartWaste</title>
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
                        <a href="<%=ctx%>/alert" style="color: var(--color-slate-400);">Alerts</a>
                        <i class="fa-solid fa-chevron-right" style="font-size: 9px;"></i>
                        <span style="color: var(--brand-forest);"><%= isEdit ? "Edit Alert" : "Broadcast Alert" %></span>
                    </div>
                    <h1><%= isEdit ? "Edit Alert " + alertID : "Broadcast System Alert" %></h1>
                </div>

                <% if (!canManage) { %>
                    <div style="padding: 16px 20px; background: #FEE2E2; border: 1px solid #FCA5A5; border-radius: 10px; color: #991B1B; font-size: 14px; font-weight: 600; margin-bottom: 24px;">
                        <i class="fa-solid fa-shield-halved"></i> Access Restricted: You do not possess administrative permissions to issue or modify system alerts.
                    </div>
                    <a href="<%=ctx%>/alert" class="btn-smart-secondary">
                        <i class="fa-solid fa-arrow-left"></i> Return to Alerts
                    </a>
                <% } else { %>

                    <!-- ERROR ALERT -->
                    <% if (error != null && !error.trim().isEmpty()) { %>
                        <div style="padding: 12px 16px; background: #FEE2E2; border: 1px solid #FCA5A5; border-radius: 8px; color: #991B1B; font-size: 13px; font-weight: 600; margin-bottom: 20px; display: flex; align-items: center; gap: 8px;">
                            <i class="fa-solid fa-circle-exclamation"></i>
                            <span><%= error %></span>
                        </div>
                    <% } %>

                    <!-- FORM CARD -->
                    <div class="smartwaste-form-card">
                        <form method="POST" action="<%=ctx%>/alert/save">
                            <input type="hidden" name="isEdit" value="<%= isEdit %>">
                            <% if (isEdit) { %>
                                <input type="hidden" name="alertID" value="<%= alertID %>">
                            <% } %>

                            <div class="form-section-divider">
                                <i class="fa-solid fa-triangle-exclamation"></i>
                                <span>Alert Specification &amp; Distribution</span>
                            </div>

                            <div class="form-grid">
                                
                                <!-- Alert ID (Sequential / Readonly) -->
                                <div class="form-field">
                                    <label class="form-label" for="dispAlertID">
                                        Alert ID <span class="required">*</span>
                                    </label>
                                    <input type="text" id="dispAlertID" class="form-input"
                                           value="<%= alertID %>"
                                           readonly
                                           required>
                                    <span class="form-hint">
                                        <i class="fa-solid fa-lock" style="font-size: 10px;"></i>
                                        Auto-assigned sequential broadcast key (e.g. ALT-004).
                                    </span>
                                </div>

                                <!-- Target Waste Bin ID / Selector -->
                                <div class="form-field">
                                    <label class="form-label" for="binID">
                                        Associated Waste Bin <span class="required">*</span>
                                    </label>
                                    <% if (bins != null && !bins.isEmpty()) { %>
                                        <select id="binID" name="binID" class="form-select" required>
                                            <option value="">-- Select Target Bin --</option>
                                            <% for (Object obj : bins) {
                                                if (obj instanceof WasteBin) {
                                                    WasteBin b = (WasteBin) obj;
                                                    boolean sel = b.getBinID() != null && b.getBinID().equalsIgnoreCase(binID);
                                            %>
                                                <option value="<%= b.getBinID() %>" <%= sel ? "selected" : "" %>>
                                                    <%= b.getBinID() %> &mdash; <%= b.getBinCode() %> (<%= b.getLocation() %>)
                                                </option>
                                            <% } } %>
                                        </select>
                                    <% } else { %>
                                        <input type="text" id="binID" name="binID" class="form-input"
                                               value="<%= binID %>"
                                               placeholder="e.g. BIN-001 or BIN-002"
                                               required>
                                    <% } %>
                                    <span class="form-hint">Campus receptacle triggering or linked to this event.</span>
                                </div>

                                <!-- Alert Type -->
                                <div class="form-field form-grid-full">
                                    <label class="form-label" for="alertType">
                                        Alert Category / Type <span class="required">*</span>
                                    </label>
                                    <select id="alertType" name="alertType" class="form-select" required>
                                        <option value="CRITICAL_OVERFLOW" <%= "CRITICAL_OVERFLOW".equalsIgnoreCase(alertType) ? "selected" : "" %>>CRITICAL_OVERFLOW (Fill level &ge; 90%)</option>
                                        <option value="MULTIPLE_BIN_OVERFLOW" <%= "MULTIPLE_BIN_OVERFLOW".equalsIgnoreCase(alertType) ? "selected" : "" %>>MULTIPLE_BIN_OVERFLOW (Cluster threshold breached)</option>
                                        <option value="HARDWARE_MALFUNCTION" <%= "HARDWARE_MALFUNCTION".equalsIgnoreCase(alertType) ? "selected" : "" %>>HARDWARE_MALFUNCTION (Sensor stuck / offline)</option>
                                        <option value="STUCK_SENSOR" <%= "STUCK_SENSOR".equalsIgnoreCase(alertType) ? "selected" : "" %>>STUCK_SENSOR (Persistent unchanging reading)</option>
                                        <option value="BATTERY_LOW" <%= "BATTERY_LOW".equalsIgnoreCase(alertType) ? "selected" : "" %>>BATTERY_LOW (Power level &lt; 15%)</option>
                                        <option value="FIRE_SMOKE" <%= "FIRE_SMOKE".equalsIgnoreCase(alertType) ? "selected" : "" %>>FIRE_SMOKE (Thermal anomaly)</option>
                                        <option value="MANUAL_OVERRIDE" <%= "MANUAL_OVERRIDE".equalsIgnoreCase(alertType) ? "selected" : "" %>>MANUAL_OVERRIDE (Supervisor dispatch)</option>
                                    </select>
                                </div>

                                <!-- Alert Message -->
                                <div class="form-field form-grid-full">
                                    <label class="form-label" for="message">
                                        Detailed Alert Directive / Message <span class="required">*</span>
                                    </label>
                                    <textarea id="message" name="message" rows="4" class="form-textarea"
                                              maxlength="500"
                                              placeholder="Broadcast instructions, severity details, and requested field staff action..."
                                              required><%= message %></textarea>
                                    <span class="form-hint">Maximum 500 characters. Pushed to supervisor and staff mobile dashboards.</span>
                                </div>

                            </div>

                            <!-- BUTTON ACTIONS -->
                            <div class="form-actions-bar">
                                <a href="<%=ctx%>/alert" class="btn-smart-secondary">
                                    <i class="fa-solid fa-arrow-left"></i> Cancel
                                </a>
                                <button type="submit" class="btn-smart-primary">
                                    <i class="fa-solid fa-bullhorn"></i>
                                    <%= isEdit ? "Save Alert Changes" : "Broadcast Alert" %>
                                </button>
                            </div>

                        </form>
                    </div>

                <% } %>
            </div>
        </main>
    </div>

</body>
</html>
