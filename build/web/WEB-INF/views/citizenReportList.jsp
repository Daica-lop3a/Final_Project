<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Citizen Feedback & Reports - SmartWaste</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=20261017-v4" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css?v=20261017-v4" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        .badge-status { padding: 3px 8px; border-radius: 4px; font-weight: 600; font-size: 11.5px; display: inline-block; }
        .badge-submitted, .badge-pending { background: #FEF3C7; color: #92400E; border: 1px solid #FDE68A; }
        .badge-under-review, .badge-under_review { background: #DCF2E4; color: #00875A; border: 1px solid #BFDBFE; }
        .badge-assigned { background: #EDE9FE; color: #6D28D9; border: 1px solid #DDD6FE; }
        .badge-resolved, .badge-verified { background: #DCFCE7; color: #166534; border: 1px solid #BBF7D0; }
        .badge-rejected { background: #FEE2E2; color: #991B1B; border: 1px solid #FECACA; }
        .badge-cancelled { background: #EDF8F2; color: #65676B; border: 1px solid #E2F2E5; }

        .kpi-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-bottom: 20px;
        }
        .kpi-card {
            background: #FFFFFF;
            border-radius: 8px;
            padding: 16px 20px;
            border: 1px solid #D1EBCF;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
        }
        .kpi-title { font-size: 11.5px; font-weight: 700; color: #65676B; margin-bottom: 6px; text-transform: uppercase; letter-spacing: 0.5px; }
        .kpi-value { font-size: 24px; font-weight: 700; color: #050505; }

        .action-link {
            padding: 0 10px;
            min-height: 28px;
            border-radius: 6px;
            text-decoration: none;
            font-size: 12px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 4px;
            background: #FFFFFF;
            border: 1px solid #D1EBCF;
            color: #050505;
            transition: all 0.15s ease;
        }
        .action-link:hover { background: #EDF8F2; border-color: #D1EBCF; }
        .action-view { background: #FFFFFF; color: #050505; }
        .action-edit { background: #FFFFFF; color: #050505; }
        .action-rate { background: #FEF9C3; color: #A16207; border-color: #FDE047; }
        .action-cancel { background: #FFFFFF; color: #65676B; border: 1px solid #D1EBCF; cursor: pointer; }
        .action-cancel i { color: #DC2626; }
        .action-cancel:hover { background: #FEE2E2; border-color: #DC2626; color: #DC2626; }
    </style>
</head>
<body style="background: #EDF8F2; margin: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;">
    <div class="app-shell">
        <jsp:include page="/WEB-INF/views/sidebar.jsp" />

        <div class="main-content" style="background: #EDF8F2;">
            <div class="content-header" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; flex-wrap: wrap; gap: 16px;">
                <div style="display: flex; align-items: flex-start; gap: 14px;">
                    <button type="button" class="desktop-nav-toggle" onclick="toggleSidebarCollapse()" title="Toggle Sidebar (Expand / Collapse)" style="margin-top: 4px;">
                        <i class="fa-solid fa-bars"></i>
                    </button>
                    <div>
                        <h1 style="font-size: 22px; margin: 0; color: #050505; font-weight: 700;">
                            <i class="fa-solid fa-bullhorn" style="color: #00875A; margin-right: 8px;"></i>
                            <c:choose>
                                <c:when test="${sessionScope.user.citizen}">My Feedback &amp; Sanitation Reports</c:when>
                                <c:otherwise>Citizen Reports &amp; Field Feedback Hub</c:otherwise>
                            </c:choose>
                        </h1>
                    </div>
                </div>
                <div style="display: flex; gap: 10px; align-items: center;">
                    <c:if test="${sessionScope.user.citizen}">
                        <a href="${pageContext.request.contextPath}/citizen-report/create" class="btn btn-primary" style="padding: 9px 18px; background: #00875A; color: white; border-radius: 6px; text-decoration: none; font-weight: 600; display: inline-flex; align-items: center; gap: 6px; box-shadow: none;">
                            <i class="fa-solid fa-plus"></i> Submit New Report
                        </a>
                    </c:if>
                    <a href="${pageContext.request.contextPath}/map" class="btn" style="padding: 9px 16px; background: white; color: #050505; border: 1px solid #D1EBCF; border-radius: 6px; text-decoration: none; font-weight: 600; display: inline-flex; align-items: center; gap: 6px;">
                        <i class="fa-solid fa-map-location-dot"></i> Public Map
                    </a>
                </div>
            </div>

            <!-- FLASH ALERTS -->
            <c:if test="${param.msg == 'created'}">
                <div style="background: #ecfdf5; color: #065f46; padding: 12px 16px; border-radius: 8px; margin-bottom: 15px; border-left: 4px solid #10b981;">
                    <i class="fa-solid fa-circle-check"></i> Your feedback report was successfully submitted! An Area Supervisor will review and dispatch staff shortly.
                </div>
            </c:if>
            <c:if test="${param.msg == 'updated'}">
                <div style="background: #eff6ff; color: #1e40af; padding: 12px 16px; border-radius: 8px; margin-bottom: 15px; border-left: 4px solid #3b82f6;">
                    <i class="fa-solid fa-circle-check"></i> Your report details have been updated successfully.
                </div>
            </c:if>
            <c:if test="${param.msg == 'cancelled'}">
                <div style="background: #f1f5f9; color: #475569; padding: 12px 16px; border-radius: 8px; margin-bottom: 15px; border-left: 4px solid #94a3b8;">
                    <i class="fa-solid fa-ban"></i> Report cancelled successfully.
                </div>
            </c:if>

            <!-- FILTERS -->
            <c:if test="${!sessionScope.user.citizen}">
                <form action="${pageContext.request.contextPath}/citizen-report" method="GET" style="display: flex; gap: 12px; margin-bottom: 20px; background: white; padding: 14px 18px; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); align-items: center;">
                    <div>
                        <label style="font-size: 12px; font-weight: 600; color: #475569; display: block; margin-bottom: 4px;">Status Filter:</label>
                        <select name="status" onchange="this.form.submit()" style="padding: 7px 12px; border-radius: 6px; border: 1px solid #cbd5e1; font-size: 13px;">
                            <option value="">-- All Statuses --</option>
                            <option value="Submitted" ${selectedStatus == 'Submitted' ? 'selected' : ''}>Submitted</option>
                            <option value="Under Review" ${selectedStatus == 'Under Review' ? 'selected' : ''}>Under Review</option>
                            <option value="Assigned" ${selectedStatus == 'Assigned' ? 'selected' : ''}>Assigned</option>
                            <option value="Resolved" ${selectedStatus == 'Resolved' ? 'selected' : ''}>Resolved</option>
                            <option value="Rejected" ${selectedStatus == 'Rejected' ? 'selected' : ''}>Rejected</option>
                            <option value="Cancelled" ${selectedStatus == 'Cancelled' ? 'selected' : ''}>Cancelled</option>
                        </select>
                    </div>
                    <div>
                        <label style="font-size: 12px; font-weight: 600; color: #475569; display: block; margin-bottom: 4px;">Campus Zone:</label>
                        <select name="areaID" onchange="this.form.submit()" style="padding: 7px 12px; border-radius: 6px; border: 1px solid #cbd5e1; font-size: 13px;">
                            <option value="">-- All Zones --</option>
                            <c:forEach var="a" items="${areas}">
                                <option value="${a.areaId}" ${selectedArea == a.areaId ? 'selected' : ''}>${a.areaName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <c:if test="${not empty selectedStatus or not empty selectedArea}">
                        <div style="margin-top: 18px;">
                            <a href="${pageContext.request.contextPath}/citizen-report" style="font-size: 12px; color: #ef4444; text-decoration: none; font-weight: 600;">
                                <i class="fa-solid fa-xmark"></i> Clear Filters
                            </a>
                        </div>
                    </c:if>
                </form>
            </c:if>

            <!-- TABLE OF REPORTS -->
            <div style="background: #FFFFFF; border-radius: 8px; overflow: hidden; box-shadow: 0 1px 2px rgba(0,0,0,0.05); border: 1px solid #D1EBCF;">
                <table style="width: 100%; border-collapse: collapse; text-align: left; font-size: 13px;">
                    <thead>
                        <tr style="background: #EDF8F2; border-bottom: 1px solid #D1EBCF; color: #65676B; font-weight: 700;">
                            <th style="padding: 12px 16px; font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px;">Ticket ID</th>
                            <th style="padding: 12px 16px; font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px;">Report Title</th>
                            <th style="padding: 12px 16px; font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px;">Category</th>
                            <th style="padding: 12px 16px; font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px;">Location / Bin</th>
                            <th style="padding: 12px 16px; font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px;">Date Submitted</th>
                            <th style="padding: 12px 16px; font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px;">Status</th>
                            <th style="padding: 12px 16px; font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px;">Citizen Rating</th>
                            <th style="padding: 12px 16px; font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px; text-align: right;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty reports}">
                                <tr>
                                    <td colspan="8" style="padding: 40px; text-align: center; color: #94a3b8;">
                                        <i class="fa-solid fa-inbox" style="font-size: 36px; margin-bottom: 12px; display: block; color: #cbd5e1;"></i>
                                        No feedback reports recorded yet.
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="r" items="${reports}">
                                    <tr style="border-bottom: 1px solid #f1f5f9;">
                                        <td style="padding: 12px 16px; font-family: monospace; font-weight: 700; color: #2563eb;">
                                            ${r.reportID}
                                        </td>
                                        <td style="padding: 12px 16px; font-weight: 600; color: #1e293b; max-width: 250px;">
                                            ${r.title}
                                            <c:if test="${not empty r.imageURL}">
                                                <i class="fa-solid fa-image" style="color: #64748b; font-size: 11px; margin-left: 4px;" title="Has photo attachment"></i>
                                            </c:if>
                                        </td>
                                        <td style="padding: 12px 16px;">
                                            <c:choose>
                                                <c:when test="${r.reportType == 'FULL_BIN'}"><span style="color: #ef4444; font-weight: 500;"><i class="fa-solid fa-triangle-exclamation"></i> Full / Overflow</span></c:when>
                                                <c:when test="${r.reportType == 'DAMAGED_BIN'}"><span style="color: #f59e0b; font-weight: 500;"><i class="fa-solid fa-wrench"></i> Broken Bin</span></c:when>
                                                <c:when test="${r.reportType == 'DIRTY_AREA'}"><span style="color: #8b5cf6; font-weight: 500;"><i class="fa-solid fa-broom"></i> Unhygienic Area</span></c:when>
                                                <c:otherwise><span style="color: #64748b;"><i class="fa-solid fa-circle-info"></i> Other</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="padding: 12px 16px;">
                                            <c:if test="${not empty r.binCode}">
                                                <strong style="color: #0f172a;">${r.binCode}</strong>
                                                <c:if test="${not empty r.areaName}">
                                                    <span style="color: #64748b;">(${r.areaName})</span>
                                                </c:if>
                                            </c:if>
                                            <c:if test="${empty r.binCode}">
                                                <span style="color: #64748b;">${r.areaName != null ? r.areaName : 'Area Pinpoint'}</span>
                                            </c:if>
                                        </td>
                                        <td style="padding: 12px 16px; color: #64748b; white-space: nowrap;">
                                            <fmt:formatDate value="${r.createdDate}" pattern="yyyy-MM-dd HH:mm"/>
                                        </td>
                                        <td style="padding: 12px 16px;">
                                            <span class="badge-status ${r.statusBadgeClass}">
                                                ${r.status}
                                            </span>
                                        </td>
                                        <td style="padding: 12px 16px;">
                                            <c:choose>
                                                <c:when test="${not empty r.rating and r.rating > 0}">
                                                    <span style="color: #f59e0b; font-weight: 700; white-space: nowrap;">
                                                        <c:forEach begin="1" end="${r.rating}">★</c:forEach>
                                                        <span style="font-size: 11px; color: #64748b;">(${r.rating}/5)</span>
                                                    </span>
                                                </c:when>
                                                <c:when test="${r.rateable and sessionScope.user.citizen}">
                                                    <a href="${pageContext.request.contextPath}/citizen-report/detail?id=${r.reportID}#rateSection" class="action-link action-rate">
                                                        <i class="fa-solid fa-star"></i> Rate now
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color: #cbd5e1; font-size: 12px;">--</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="padding: 12px 16px; text-align: right; white-space: nowrap;">
                                            <div style="display: inline-flex; gap: 6px; align-items: center;">
                                                <a href="${pageContext.request.contextPath}/citizen-report/detail?id=${r.reportID}" class="action-link action-view">
                                                    <i class="fa-solid fa-eye"></i> Details
                                                </a>
                                                <c:if test="${sessionScope.user.citizen and r.editable}">
                                                    <a href="${pageContext.request.contextPath}/citizen-report/edit?id=${r.reportID}" class="action-link action-edit" title="Edit this submission">
                                                        <i class="fa-solid fa-pen"></i> Edit
                                                    </a>
                                                    <form action="${pageContext.request.contextPath}/citizen-report/cancel" method="POST" style="display: inline;" onsubmit="return confirm('Are you sure you want to cancel this report?');">
                                                        <input type="hidden" name="reportID" value="${r.reportID}">
                                                        <button type="submit" class="action-link action-cancel" title="Cancel this submission">
                                                            <i class="fa-solid fa-ban"></i> Cancel
                                                        </button>
                                                    </form>
                                                </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
