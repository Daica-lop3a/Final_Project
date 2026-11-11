<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.SystemConfig"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%
    String ctx = request.getContextPath();
    List<SystemConfig> configs = (List<SystemConfig>) request.getAttribute("CONFIGS");
    String successMsg = (String) request.getAttribute("SUCCESS_MSG");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>System & IoT Configuration - SmartWaste</title>

    <link rel="stylesheet" href="<%=ctx%>/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        .config-page {
            margin-left: 0;
            width: 100%;
            min-height: 100vh;
            padding: 34px 40px;
            box-sizing: border-box;
            background: #EDF8F2;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            color: #1C1E21;
        }

        .header-box {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 24px;
        }

        .page-kicker {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 1.4px;
            text-transform: uppercase;
            color: #00875A;
            margin-bottom: 6px;
        }

        .page-title {
            margin: 0;
            font-size: 28px;
            font-weight: 800;
            color: #050505;
        }

        .page-desc {
            margin: 6px 0 0;
            color: #65676B;
            font-size: 14px;
        }

        .alert-success {
            background: #dcfce7;
            color: #166534;
            padding: 14px 18px;
            border-radius: 8px;
            border: 1px solid #bbf7d0;
            margin-bottom: 24px;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 10px;
            font-weight: 600;
        }

        .config-card {
            background: #FFFFFF;
            border-radius: 8px;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
            border: 1px solid #D1EBCF;
            padding: 24px;
            margin-bottom: 24px;
        }

        .section-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 20px;
            padding-bottom: 14px;
            border-bottom: 1px solid #E2F2E5;
        }

        .section-icon {
            width: 38px;
            height: 38px;
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 17px;
        }

        .icon-iot { background: #DCF2E4; color: #00875A; }
        .icon-sec { background: #FEE2E2; color: #DC2626; }
        .icon-sys { background: #DCFCE7; color: #166534; }

        .section-title {
            margin: 0;
            font-size: 17px;
            font-weight: 700;
            color: #050505;
        }

        .section-desc {
            margin: 2px 0 0;
            font-size: 12px;
            color: #65676B;
        }

        .grid-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 16px;
        }

        .form-group label {
            display: block;
            margin-bottom: 6px;
            font-size: 13px;
            font-weight: 700;
            color: #334155;
        }

        .form-control {
            width: 100%;
            padding: 10px 14px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font-size: 14px;
            box-sizing: border-box;
            background: white;
        }

        .hint {
            display: block;
            margin-top: 5px;
            font-size: 12px;
            color: #64748b;
        }

        .btn-save {
            background: #10b981;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.25);
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .btn-save:hover {
            background: #059669;
        }
    </style>
</head>
<body>

    <jsp:include page="/WEB-INF/views/sidebar.jsp" />

    <main class="config-page">
        <div class="header-box">
            <div>
                <span class="page-kicker">
                    <i class="fa-solid fa-sliders"></i> System Architecture
                </span>
                <h1 class="page-title">System & IoT Parameter Governance</h1>
            </div>
        </div>

        <% if (successMsg != null) { %>
            <div class="alert-success">
                <i class="fa-solid fa-circle-check" style="font-size: 18px;"></i>
                <span><%= successMsg %></span>
            </div>
        <% } %>

        <form action="<%=ctx%>/system/config" method="POST">

            <!-- 1. IOT SENSOR & TELEMETRY RULES -->
            <div class="config-card">
                <div class="section-header">
                    <div class="section-icon icon-iot">
                        <i class="fa-solid fa-microchip"></i>
                    </div>
                    <div>
                        <h3 class="section-title">IoT Telemetry & Waste Bin Sensor Thresholds</h3>
                        <p class="section-desc">Define ultrasonic fill rate limits, thermal hazard detection, and battery alerts.</p>
                    </div>
                </div>

                <div class="grid-row">
                    <div class="form-group">
                        <label for="BIN_OVERFLOW_THRESHOLD">Overflow Alert Threshold (%)</label>
                        <input type="number" id="BIN_OVERFLOW_THRESHOLD" name="BIN_OVERFLOW_THRESHOLD" class="form-control"
                               value="<% for (SystemConfig c : configs) { if ("BIN_OVERFLOW_THRESHOLD".equals(c.getConfigKey())) { out.print(c.getConfigValue()); } } %>"
                               min="50" max="100" required>
                        <span class="hint"><i class="fa-solid fa-circle-info"></i> Fill percentage that flags bin as "Full" and triggers urgent pickup alert.</span>
                    </div>

                    <div class="form-group">
                        <label for="BIN_WARNING_THRESHOLD">Pre-Full Warning Threshold (%)</label>
                        <input type="number" id="BIN_WARNING_THRESHOLD" name="BIN_WARNING_THRESHOLD" class="form-control"
                               value="<% for (SystemConfig c : configs) { if ("BIN_WARNING_THRESHOLD".equals(c.getConfigKey())) { out.print(c.getConfigValue()); } } %>"
                               min="30" max="90" required>
                        <span class="hint"><i class="fa-solid fa-circle-info"></i> Attention fill percentage highlighted yellow on live Leaflet map.</span>
                    </div>
                </div>

                <div class="grid-row">
                    <div class="form-group">
                        <label for="HIGH_TEMP_THRESHOLD">Fire Risk Thermal Limit (°C)</label>
                        <input type="number" step="0.1" id="HIGH_TEMP_THRESHOLD" name="HIGH_TEMP_THRESHOLD" class="form-control"
                               value="<% for (SystemConfig c : configs) { if ("HIGH_TEMP_THRESHOLD".equals(c.getConfigKey())) { out.print(c.getConfigValue()); } } %>"
                               min="30" max="100" required>
                        <span class="hint"><i class="fa-solid fa-fire"></i> Triggers emergency hazard alarm if sensor detects temperature spike.</span>
                    </div>

                    <div class="form-group">
                        <label for="BATTERY_LOW_THRESHOLD">Sensor Battery Low Alert (%)</label>
                        <input type="number" id="BATTERY_LOW_THRESHOLD" name="BATTERY_LOW_THRESHOLD" class="form-control"
                               value="<% for (SystemConfig c : configs) { if ("BATTERY_LOW_THRESHOLD".equals(c.getConfigKey())) { out.print(c.getConfigValue()); } } %>"
                               min="5" max="50" required>
                        <span class="hint"><i class="fa-solid fa-battery-quarter"></i> Dispatches maintenance notification to IoT Technicians.</span>
                    </div>
                </div>

                <div class="form-group">
                    <label for="SENSOR_POLL_INTERVAL">Telemetry Sync Interval (Seconds)</label>
                    <input type="number" id="SENSOR_POLL_INTERVAL" name="SENSOR_POLL_INTERVAL" class="form-control"
                           value="<% for (SystemConfig c : configs) { if ("SENSOR_POLL_INTERVAL".equals(c.getConfigKey())) { out.print(c.getConfigValue()); } } %>"
                           min="10" max="3600" required>
                    <span class="hint"><i class="fa-solid fa-clock"></i> Frequency of simulated or hardware sensor updates.</span>
                </div>
            </div>

            <!-- 2. SECURITY & SESSION POLICIES -->
            <div class="config-card">
                <div class="section-header">
                    <div class="section-icon icon-sec">
                        <i class="fa-solid fa-shield-halved"></i>
                    </div>
                    <div>
                        <h3 class="section-title">Security Governance & Brute-Force Defense</h3>
                        <p class="section-desc">Configure failed login lockout thresholds and user session timeouts.</p>
                    </div>
                </div>

                <div class="grid-row">
                    <div class="form-group">
                        <label for="MAX_FAILED_LOGINS">Max Failed Logins Before Account Lockout</label>
                        <input type="number" id="MAX_FAILED_LOGINS" name="MAX_FAILED_LOGINS" class="form-control"
                               value="<% for (SystemConfig c : configs) { if ("MAX_FAILED_LOGINS".equals(c.getConfigKey())) { out.print(c.getConfigValue()); } } %>"
                               min="3" max="10" required>
                        <span class="hint"><i class="fa-solid fa-user-lock"></i> Number of failed password attempts before account is automatically locked.</span>
                    </div>

                    <div class="form-group">
                        <label for="SESSION_TIMEOUT_MINUTES">User Session Inactivity Expiry (Minutes)</label>
                        <input type="number" id="SESSION_TIMEOUT_MINUTES" name="SESSION_TIMEOUT_MINUTES" class="form-control"
                               value="<% for (SystemConfig c : configs) { if ("SESSION_TIMEOUT_MINUTES".equals(c.getConfigKey())) { out.print(c.getConfigValue()); } } %>"
                               min="5" max="120" required>
                        <span class="hint"><i class="fa-solid fa-hourglass-half"></i> Idle session expiration limit across all roles.</span>
                    </div>
                </div>
            </div>

            <!-- 3. COLLECTION LOGISTICS AUTOMATION -->
            <div class="config-card">
                <div class="section-header">
                    <div class="section-icon icon-sys">
                        <i class="fa-solid fa-truck-pickup"></i>
                    </div>
                    <div>
                        <h3 class="section-title">Collection Logistics Automation</h3>
                        <p class="section-desc">Configure automated generation of pickup assignments.</p>
                    </div>
                </div>

                <div class="form-group">
                    <label for="AUTO_DISPATCH_COLLECTION">Automated Collection Request Dispatch</label>
                    <select id="AUTO_DISPATCH_COLLECTION" name="AUTO_DISPATCH_COLLECTION" class="form-control">
                        <% 
                            String autoVal = "true";
                            for (SystemConfig c : configs) {
                                if ("AUTO_DISPATCH_COLLECTION".equals(c.getConfigKey())) {
                                    autoVal = c.getConfigValue();
                                }
                            }
                        %>
                        <option value="true" <%= "true".equalsIgnoreCase(autoVal) ? "selected" : "" %>>Enabled (Automatically generate collection tasks when bin overflows)</option>
                        <option value="false" <%= "false".equalsIgnoreCase(autoVal) ? "selected" : "" %>>Disabled (Require Area Supervisor manual dispatch)</option>
                    </select>
                </div>
            </div>

            <div style="text-align: right; margin-bottom: 40px;">
                <button type="submit" class="btn-save" onclick="return confirm('Save and propagate system parameter updates across all services?');">
                    <i class="fa-solid fa-floppy-disk"></i> Apply System & IoT Configurations
                </button>
            </div>

        </form>
    </main>

</body>
</html>
