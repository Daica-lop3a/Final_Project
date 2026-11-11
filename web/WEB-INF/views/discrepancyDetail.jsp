<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="model.AppUser"%>
<%@page import="model.Discrepancy"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<%
    String ctx = request.getContextPath();
    AppUser user = (AppUser) session.getAttribute("user");
    boolean isAuditor = user != null && user.isAuditor();
    boolean isSuperAdmin = user != null && user.isSuperAdmin();
    boolean canManage = isAuditor || isSuperAdmin;

    Discrepancy d = (Discrepancy) request.getAttribute("discrepancy");
    String msg = request.getParameter("msg");
    String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Discrepancy Case <%= d != null ? d.getDiscrepancyID() : "" %> - SmartWaste</title>
    <link rel="stylesheet" href="<%=ctx%>/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .audit-page {
            margin-left: 0;
            width: 100%;
            min-height: 100vh;
            padding: 30px 36px;
            background: #EDF8F2;
            box-sizing: border-box;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            color: #1C1E21;
        }
        .detail-container {
            max-width: 900px;
            margin: 0 auto;
        }
        .top-nav {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .case-card {
            background: #FFFFFF;
            border-radius: 8px;
            border: 1px solid #D1EBCF;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
            margin-bottom: 24px;
            overflow: hidden;
        }
        .case-header {
            padding: 20px 24px;
            border-bottom: 1px solid #E2F2E5;
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            flex-wrap: wrap;
            gap: 16px;
        }
        .case-title {
            margin: 0 0 8px 0;
            font-size: 20px;
            font-weight: 800;
            color: #050505;
        }
        .case-id-badge {
            font-family: monospace;
            font-size: 13px;
            font-weight: 700;
            color: #00875A;
            background: #DCF2E4;
            padding: 4px 8px;
            border-radius: 4px;
            border: 1px solid #D1EBCF;
        }
        .meta-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
            padding: 20px 24px;
            background: #EDF8F2;
            border-bottom: 1px solid #D1EBCF;
        }
        .meta-item {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }
        .meta-label {
            font-size: 11px;
            font-weight: 700;
            color: #65676B;
            text-transform: uppercase;
        }
        .meta-val {
            font-size: 13px;
            font-weight: 600;
            color: #1C1E21;
        }
        .case-body {
            padding: 24px;
        }
        .section-title {
            font-size: 15px;
            font-weight: 700;
            color: #050505;
            margin: 0 0 12px 0;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .finding-desc {
            background: #EDF8F2;
            border: 1px solid #D1EBCF;
            border-radius: 6px;
            padding: 16px 20px;
            font-size: 13px;
            color: #1C1E21;
            line-height: 1.6;
            margin-bottom: 24px;
        }
        .investigation-box {
            background: #FFFFFF;
            border: 1px solid #D1EBCF;
            border-radius: 6px;
            padding: 20px;
            margin-bottom: 24px;
        }
        .conclusion-box {
            background: #F0FDF4;
            border: 1px solid #BBF7D0;
            border-radius: 6px;
            padding: 20px;
            margin-bottom: 24px;
        }
        .badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
        }
        .badge-danger { background: #fee2e2; color: #b91c1c; }
        .badge-warning { background: #fef3c7; color: #b45309; }
        .badge-info { background: #e0f2fe; color: #0369a1; }
        .badge-primary { background: #ede9fe; color: #6d28d9; }
        .badge-success { background: #d1fae5; color: #047857; }
        .badge-secondary { background: #f1f5f9; color: #64748b; }
        .btn {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 8px 16px;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 600;
            text-decoration: none;
            cursor: pointer;
            border: none;
        }
        .btn-primary { background: #6366f1; color: white; }
        .btn-primary:hover { background: #4f46e5; }
        .btn-success { background: #10b981; color: white; }
        .btn-success:hover { background: #059669; }
        .btn-secondary { background: #64748b; color: white; }
        .btn-secondary:hover { background: #475569; }
        .alert-success {
            background: #d1fae5;
            color: #065f46;
            padding: 12px 18px;
            border-radius: 6px;
            margin-bottom: 20px;
            font-size: 13px;
            border: 1px solid #a7f3d0;
        }
    </style>
</head>
<body>
    <div class="app-shell">
        <jsp:include page="sidebar.jsp" />

        <main class="audit-page">
            <div class="detail-container">
                <div class="top-nav">
                    <a href="<%=ctx%>/discrepancy" class="btn btn-secondary">
                        <i class="fa-solid fa-arrow-left"></i> Back to Discrepancy List
                    </a>
                    <div style="display: flex; gap: 8px;">
                        <a href="<%=ctx%>/data-quality" class="btn btn-secondary">
                            <i class="fa-solid fa-radar"></i> Quality Scanner
                        </a>
                        <a href="<%=ctx%>/export?type=discrepancies" class="btn btn-secondary">
                            <i class="fa-solid fa-file-csv"></i> Export Dossier
                        </a>
                    </div>
                </div>

                <% if ("created".equals(msg)) { %>
                    <div class="alert-success">
                        <i class="fa-solid fa-check-circle"></i> Audit discrepancy investigation dossier successfully created.
                    </div>
                <% } else if ("updated".equals(msg)) { %>
                    <div class="alert-success">
                        <i class="fa-solid fa-check-circle"></i> Investigation progress and status updated.
                    </div>
                <% } else if ("closed".equals(msg)) { %>
                    <div class="alert-success">
                        <i class="fa-solid fa-check-circle"></i> Audit discrepancy case concluded and closed.
                    </div>
                <% } %>

                <div class="case-card">
                    <div class="case-header">
                        <div>
                            <span class="case-id-badge"><%= d.getDiscrepancyID() %></span>
                            <h1 class="case-title" style="margin-top: 8px;"><%= d.getTitle() %></h1>
                            <span style="font-size: 13px; color: #64748b;">
                                Type: <strong><%= d.getDiscrepancyType() %></strong>
                            </span>
                        </div>
                        <div style="display: flex; gap: 8px; align-items: center;">
                            <span class="badge <%= d.getSeverityBadgeClass() %>"><%= d.getSeverity() %></span>
                            <span class="badge <%= d.getStatusBadgeClass() %>"><%= d.getStatus() %></span>
                        </div>
                    </div>

                    <div class="meta-grid">
                        <div class="meta-item">
                            <span class="meta-label">Target Entity</span>
                            <span class="meta-val" style="color: #0284c7;">
                                <%= d.getTargetEntity() %> (<%= d.getTargetID() != null ? d.getTargetID() : "N/A" %>)
                            </span>
                        </div>
                        <div class="meta-item">
                            <span class="meta-label">Logged By Auditor</span>
                            <span class="meta-val"><%= d.getDetectedByName() != null ? d.getDetectedByName() : d.getDetectedBy() %></span>
                        </div>
                        <div class="meta-item">
                            <span class="meta-label">Date Discovered</span>
                            <span class="meta-val"><fmt:formatDate value="<%= d.getDetectedDate() %>" pattern="yyyy-MM-dd HH:mm" /></span>
                        </div>
                        <div class="meta-item">
                            <span class="meta-label">Current Status</span>
                            <span class="meta-val"><%= d.getStatus() %></span>
                        </div>
                    </div>

                    <div class="case-body">
                        <!-- 1. OBSERVATION -->
                        <h3 class="section-title">
                            <i class="fa-solid fa-magnifying-glass" style="color: #6366f1;"></i>
                            Audit Finding &amp; Anomaly Observation
                        </h3>
                        <div class="finding-desc">
                            <%= d.getDescription() != null && !d.getDescription().trim().isEmpty() 
                                    ? d.getDescription() : "No detailed description entered." %>
                        </div>

                        <!-- 2. INVESTIGATION NOTES & STATUS UPDATE -->
                        <h3 class="section-title">
                            <i class="fa-solid fa-list-check" style="color: #f59e0b;"></i>
                            Investigation Verification Notes &amp; Status
                        </h3>

                        <% if (d.getInvestigationNotes() != null && !d.getInvestigationNotes().trim().isEmpty()) { %>
                            <div style="background: #fffbeb; border: 1px solid #fde68a; border-radius: 8px; padding: 14px 18px; font-size: 13px; color: #92400e; margin-bottom: 20px;">
                                <strong>Recorded Investigation Directives:</strong><br/>
                                <%= d.getInvestigationNotes() %>
                            </div>
                        <% } %>

                        <% if (!d.isClosed() && canManage) { %>
                            <div class="investigation-box">
                                <h4 style="margin: 0 0 14px 0; font-size: 14px; color: #1e293b;">Update Investigation Progress</h4>
                                <form method="POST" action="<%=ctx%>/discrepancy/investigate">
                                    <input type="hidden" name="discrepancyID" value="<%= d.getDiscrepancyID() %>">
                                    
                                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 14px;">
                                        <div>
                                            <label style="display: block; font-size: 12px; font-weight: 600; color: #475569; margin-bottom: 4px;">Update Status</label>
                                            <select name="status" style="width: 100%; padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px;">
                                                <option value="Open" <%= d.isOpen() ? "selected" : "" %>>Open</option>
                                                <option value="Investigating" <%= d.isInvestigating() ? "selected" : "" %>>Investigating</option>
                                                <option value="Resolved" <%= d.isResolved() ? "selected" : "" %>>Resolved</option>
                                            </select>
                                        </div>
                                        <div>
                                            <label style="display: block; font-size: 12px; font-weight: 600; color: #475569; margin-bottom: 4px;">Update Severity</label>
                                            <select name="severity" style="width: 100%; padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px;">
                                                <option value="Low" <%= "Low".equals(d.getSeverity()) ? "selected" : "" %>>Low</option>
                                                <option value="Medium" <%= "Medium".equals(d.getSeverity()) ? "selected" : "" %>>Medium</option>
                                                <option value="High" <%= "High".equals(d.getSeverity()) ? "selected" : "" %>>High</option>
                                                <option value="Critical" <%= "Critical".equals(d.getSeverity()) ? "selected" : "" %>>Critical</option>
                                            </select>
                                        </div>
                                    </div>

                                    <div style="margin-bottom: 14px;">
                                        <label style="display: block; font-size: 12px; font-weight: 600; color: #475569; margin-bottom: 4px;">Investigation Notes &amp; Verification Progress</label>
                                        <textarea name="investigationNotes" rows="3" style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px;" placeholder="Add ongoing findings from staff interviews, hardware checks, or telemetry audit..."><%= d.getInvestigationNotes() != null ? d.getInvestigationNotes() : "" %></textarea>
                                    </div>

                                    <button type="submit" class="btn btn-primary">
                                        <i class="fa-solid fa-arrows-rotate"></i> Update Case Progress
                                    </button>
                                </form>
                            </div>
                        <% } %>

                        <!-- 3. CONCLUSION & CLOSURE -->
                        <h3 class="section-title">
                            <i class="fa-solid fa-stamp" style="color: #10b981;"></i>
                            Audit Conclusion &amp; Case Closure
                        </h3>

                        <% if (d.isClosed()) { %>
                            <div class="conclusion-box">
                                <div style="display: flex; align-items: center; gap: 8px; color: #166534; font-weight: 700; margin-bottom: 8px;">
                                    <i class="fa-solid fa-circle-check" style="font-size: 18px;"></i> Case Closed &amp; Formally Concluded
                                </div>
                                <p style="font-size: 13px; color: #14532d; line-height: 1.6; margin: 0 0 12px 0;">
                                    <%= d.getConclusionNotes() %>
                                </p>
                                <div style="font-size: 12px; color: #166534; border-top: 1px solid #bbf7d0; padding-top: 8px;">
                                    Closed by: <strong><%= d.getClosedByName() != null ? d.getClosedByName() : d.getClosedBy() %></strong> |
                                    Closed on: <strong><fmt:formatDate value="<%= d.getClosedDate() %>" pattern="yyyy-MM-dd HH:mm" /></strong>
                                </div>
                            </div>
                        <% } else if (canManage) { %>
                            <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 20px;">
                                <h4 style="margin: 0 0 8px 0; font-size: 14px; color: #1e293b;">Formal Case Closure</h4>
                                <p style="font-size: 12px; color: #64748b; margin: 0 0 14px 0;">
                                    When operational discrepancies have been clarified or rectified according to the audit process, submit your formal conclusion notes to close this dossier.
                                </p>
                                <form method="POST" action="<%=ctx%>/discrepancy/close">
                                    <input type="hidden" name="discrepancyID" value="<%= d.getDiscrepancyID() %>">
                                    <div style="margin-bottom: 14px;">
                                        <label style="display: block; font-size: 12px; font-weight: 600; color: #475569; margin-bottom: 4px;">Final Audit Conclusion Notes <span style="color: #ef4444;">*</span></label>
                                        <textarea name="conclusionNotes" rows="3" required style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px;" placeholder="Document final audit determination (e.g. verified sensor recalibrated by Technician tech1; duplicate collection flagged as accidental double-tap and training provided)..."></textarea>
                                    </div>
                                    <button type="submit" class="btn btn-success" onclick="return confirm('Confirm concluding and closing this discrepancy dossier?');">
                                        <i class="fa-solid fa-stamp"></i> Conclude &amp; Close Case
                                    </button>
                                </form>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </main>
    </div>
</body>
</html>
