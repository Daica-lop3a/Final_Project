<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.WasteBin"%>
<%@page import="model.Area"%>
<%
    String ctx = request.getContextPath();
    WasteBin bin = (WasteBin) request.getAttribute("BIN");
    List<Area> areaList = (List<Area>) request.getAttribute("LIST_AREA");
    boolean edit = bin != null && bin.getBinID() != null && !bin.getBinID().trim().isEmpty();
    String error = (String) request.getAttribute("ERROR");
    String nextBinId = (String) request.getAttribute("NEXT_BIN_ID");

    String binIDVal = "";
    if (edit && bin != null && bin.getBinID() != null) {
        binIDVal = bin.getBinID();
    } else if (nextBinId != null && !nextBinId.isEmpty()) {
        binIDVal = nextBinId;
    } else if (bin != null && bin.getBinID() != null) {
        binIDVal = bin.getBinID();
    }

    String selectedAreaID = bin != null && bin.getAreaID() != null ? bin.getAreaID() : "";
    String statusVal = bin != null && bin.getStatus() != null ? bin.getStatus() : "Active";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= edit ? "Edit Waste Bin" : "Register Waste Bin" %> - SmartWaste</title>
    <link rel="stylesheet" href="<%=ctx%>/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body style="background: var(--page); margin: 0;">

    <div class="app-shell">
        
        <!-- SIDEBAR NAVIGATION -->
        <jsp:include page="/WEB-INF/views/sidebar.jsp" />

        <!-- MAIN FORM PAGE -->
        <main class="smartwaste-form-page">
            <div class="smartwaste-form-container">
                
                <!-- BREADCRUMB & HEADER -->
                <div class="form-header-box">
                    <div class="form-breadcrumb">
                        <a href="<%=ctx%>/dashboard" style="color: var(--color-slate-400);">Dashboard</a>
                        <i class="fa-solid fa-chevron-right" style="font-size: 9px;"></i>
                        <a href="<%=ctx%>/wastebin" style="color: var(--color-slate-400);">Waste Bins</a>
                        <i class="fa-solid fa-chevron-right" style="font-size: 9px;"></i>
                        <span style="color: var(--brand-forest);"><%= edit ? "Edit Bin" : "Register New Bin" %></span>
                    </div>
                    <h1><%= edit ? "Edit Waste Bin " + bin.getBinCode() : "Register New Waste Bin" %></h1>
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
                    <form action="<%=ctx%>/wastebin/save" method="POST">
                        <input type="hidden" name="action" value="<%= edit ? "edit" : "create" %>">

                        <div class="form-section-divider">
                            <i class="fa-solid fa-trash-can"></i>
                            <span>Bin Hardware &amp; Location Specification</span>
                        </div>

                        <div class="form-grid">
                            
                            <!-- Bin ID (Sequential / Readonly) -->
                            <div class="form-field">
                                <label class="form-label" for="binID">
                                    Bin Primary Key ID <span class="required">*</span>
                                </label>
                                <input type="text" id="binID" name="binID" class="form-input"
                                       value="<%= binIDVal %>"
                                       readonly
                                       required>
                                <span class="form-hint">
                                    <i class="fa-solid fa-lock" style="font-size: 10px;"></i>
                                    Auto-assigned sequential database key (e.g. BIN-011).
                                </span>
                            </div>

                            <!-- Bin Code (Display Code e.g. BIN-A1-02) -->
                            <div class="form-field">
                                <label class="form-label" for="binCode">
                                    Physical Bin Code <span class="required">*</span>
                                </label>
                                <input type="text" id="binCode" name="binCode" class="form-input"
                                       placeholder="e.g. BIN-A1-05"
                                       value="<%= bin != null && bin.getBinCode() != null ? bin.getBinCode() : "" %>"
                                       pattern="^BIN-[A-Za-z0-9]+(-[0-9]+)+$|^BIN-[A-Za-z0-9]{2,15}$"
                                       title="Bin Code must follow the format 'BIN-XX-NN' (e.g. BIN-A1-05)"
                                       style="text-transform: uppercase; font-family: monospace; font-weight: 700;"
                                       oninput="this.value = this.value.toUpperCase();"
                                       maxlength="30"
                                       required>
                                <span class="form-hint">
                                    <i class="fa-solid fa-barcode" style="font-size: 11px;"></i>
                                    Format: <strong>BIN-XX-NN</strong> (e.g. BIN-A1-05). Physical QR/barcode identifier.
                                </span>
                            </div>

                            <!-- Campus Area -->
                            <div class="form-field">
                                <label class="form-label" for="areaID">
                                    Campus Area / Zone <span class="required">*</span>
                                </label>
                                <select id="areaID" name="areaID" class="form-select" required>
                                    <option value="">-- Select Campus Zone --</option>
                                    <% if (areaList != null) {
                                        for (Area a : areaList) { %>
                                        <option value="<%= a.getAreaId() %>" <%= a.getAreaId().equals(selectedAreaID) ? "selected" : "" %>>
                                            <%= a.getAreaName() %> (<%= a.getAreaId() %>)
                                        </option>
                                    <%  }
                                    } %>
                                </select>
                                <span class="form-hint">Designated campus maintenance sector.</span>
                            </div>

                            <!-- Operational Status -->
                            <div class="form-field">
                                <label class="form-label" for="status">
                                    Operational Status <span class="required">*</span>
                                </label>
                                <select id="status" name="status" class="form-select" required>
                                    <option value="Active" <%= "Active".equalsIgnoreCase(statusVal) ? "selected" : "" %>>Active (Online &amp; Monitored)</option>
                                    <option value="Inactive" <%= "Inactive".equalsIgnoreCase(statusVal) ? "selected" : "" %>>Inactive (Offline / Decommissioned)</option>
                                    <option value="Maintenance" <%= "Maintenance".equalsIgnoreCase(statusVal) ? "selected" : "" %>>Under Maintenance / Repair</option>
                                </select>
                                <span class="form-hint">Controls automated sensor polling and public visibility.</span>
                            </div>

                            <!-- Capacity (Liters) -->
                            <div class="form-field">
                                <label class="form-label" for="capacity">
                                    Volume Capacity (Liters) <span class="required">*</span>
                                </label>
                                <input type="number" id="capacity" name="capacity" class="form-input" min="10" max="2000" step="1"
                                       placeholder="e.g. 120"
                                       value="<%= edit && bin != null ? (int) Math.round(bin.getCapacity()) : 120 %>"
                                       required>
                                <span class="form-hint">Standard campus bin sizes: 60L, 120L, 240L, or 660L.</span>
                            </div>

                            <!-- Location Description -->
                            <div class="form-field form-group-full">
                                <label class="form-label" for="location">
                                    Exact Location Description <span class="required">*</span>
                                </label>
                                <textarea id="location" name="location" class="form-textarea" rows="3"
                                          placeholder="e.g. Hall A, 1st Floor, Next to Water Dispenser and Elevators"
                                          required><%= edit && bin != null && bin.getLocation() != null ? bin.getLocation() : "" %></textarea>
                                <span class="form-hint">Clear directions so field staff can quickly pinpoint the bin.</span>
                            </div>

                        </div>

                        <!-- ACTIONS -->
                        <div class="form-actions-bar">
                            <a href="<%=ctx%>/wastebin" class="btn-smart-secondary">
                                <i class="fa-solid fa-xmark"></i>
                                <span>Cancel</span>
                            </a>
                            <button type="submit" class="btn-smart-primary">
                                <i class="fa-solid fa-check"></i>
                                <span><%= edit ? "Update Waste Bin" : "Register Bin" %></span>
                            </button>
                        </div>

                    </form>
                </div>

            </div>
        </main>
    </div>

</body>
</html>