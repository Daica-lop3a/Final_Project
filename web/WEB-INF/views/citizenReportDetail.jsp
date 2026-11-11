<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Report Dossier - ${report.reportID}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <style>
        .detail-card {
            background: #FFFFFF;
            border-radius: 8px;
            padding: 24px;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
            margin-bottom: 24px;
            border: 1px solid #D1EBCF;
        }
        .badge-status { padding: 5px 12px; border-radius: 999px; font-weight: 700; font-size: 13px; display: inline-block; }
        .badge-submitted, .badge-pending { background: #fef3c7; color: #d97706; }
        .badge-under-review, .badge-under_review { background: #e0f2fe; color: #0284c7; }
        .badge-assigned { background: #e0e7ff; color: #4338ca; }
        .badge-resolved, .badge-verified { background: #d1fae5; color: #059669; }
        .badge-rejected { background: #fee2e2; color: #dc2626; }
        .badge-cancelled { background: #f1f5f9; color: #64748b; }

        .info-row { display: flex; margin-bottom: 12px; font-size: 14px; }
        .info-label { width: 180px; font-weight: 600; color: #64748b; }
        .info-value { flex: 1; color: #1e293b; }

        /* 5-Step Progress Tracker */
        .progress-track {
            display: flex;
            justify-content: space-between;
            position: relative;
            margin-bottom: 28px;
            padding: 0 10px;
        }
        .progress-track::before {
            content: '';
            position: absolute;
            top: 18px;
            left: 30px;
            right: 30px;
            height: 4px;
            background: #e2e8f0;
            z-index: 1;
        }
        .step-item {
            position: relative;
            z-index: 2;
            text-align: center;
            width: 90px;
        }
        .step-circle {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: white;
            border: 3px solid #cbd5e1;
            color: #94a3b8;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 8px;
            font-weight: 700;
            font-size: 13px;
            transition: all 0.3s;
        }
        .step-label {
            font-size: 11px;
            font-weight: 600;
            color: #64748b;
        }
        .step-item.active .step-circle {
            background: #3b82f6;
            border-color: #3b82f6;
            color: white;
            box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.2);
        }
        .step-item.active .step-label {
            color: #1d4ed8;
            font-weight: 700;
        }
        .step-item.completed .step-circle {
            background: #10b981;
            border-color: #10b981;
            color: white;
        }
        .step-item.completed .step-label {
            color: #047857;
        }

        #detailMap {
            height: 200px;
            width: 100%;
            border-radius: 8px;
            border: 1px solid #cbd5e1;
            margin-top: 8px;
        }

        /* Star Rating */
        .rating-stars {
            display: flex;
            gap: 8px;
            font-size: 24px;
            color: #cbd5e1;
            cursor: pointer;
        }
        .rating-stars .star.selected,
        .rating-stars .star:hover,
        .rating-stars .star:hover ~ .star {
            color: #f59e0b;
        }
    </style>
</head>
<body style="background: #EDF8F2; margin: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;">
    <div class="app-shell">
        <jsp:include page="/WEB-INF/views/sidebar.jsp" />

        <div class="main-content" style="background: #EDF8F2;">
            <div style="max-width: 900px; margin: 0 auto;">
                <!-- TOP HEADER -->
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; flex-wrap: wrap; gap: 14px;">
                    <div style="display: flex; align-items: center; gap: 14px;">
                        <button type="button" class="desktop-nav-toggle" onclick="toggleSidebarCollapse()" title="Toggle Sidebar (Expand / Collapse)">
                            <i class="fa-solid fa-bars"></i>
                        </button>
                        <div>
                            <a href="${pageContext.request.contextPath}/citizen-report" style="color: #64748B; text-decoration: none; font-size: 13px; font-weight: 600; display: inline-flex; align-items: center; gap: 4px;">
                                <i class="fa-solid fa-arrow-left"></i> Back to Reports List
                            </a>
                            <h1 style="font-size: 22px; margin: 6px 0 0; color: #0F172A; font-weight: 800;">
                                Feedback Ticket: <span style="color: #0284C7; font-family: monospace;">${report.reportID}</span>
                            </h1>
                        </div>
                    </div>
                    <div style="display: flex; gap: 8px; align-items: center;">
                        <span class="badge-status ${report.statusBadgeClass}">
                            ${report.status}
                        </span>
                        <c:if test="${sessionScope.user.citizen and report.editable}">
                            <a href="${pageContext.request.contextPath}/citizen-report/edit?id=${report.reportID}" style="padding: 6px 14px; background: #fef3c7; color: #b45309; border-radius: 6px; font-size: 13px; font-weight: 600; text-decoration: none; display: inline-flex; align-items: center; gap: 4px;">
                                <i class="fa-solid fa-pen"></i> Edit
                            </a>
                            <form action="${pageContext.request.contextPath}/citizen-report/cancel" method="POST" style="display: inline;" onsubmit="return confirm('Are you sure you want to cancel this submission?');">
                                <input type="hidden" name="reportID" value="${report.reportID}">
                                <button type="submit" style="padding: 6px 14px; background: #fee2e2; color: #dc2626; border: none; border-radius: 6px; font-size: 13px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 4px;">
                                    <i class="fa-solid fa-ban"></i> Cancel
                                </button>
                            </form>
                        </c:if>
                    </div>
                </div>

                <!-- MESSAGES -->
                <c:if test="${param.msg == 'updated'}">
                    <div style="background: #ecfdf5; color: #065f46; padding: 12px 16px; border-radius: 8px; margin-bottom: 20px; border-left: 4px solid #10b981;">
                        <i class="fa-solid fa-circle-check"></i> Report details updated successfully!
                    </div>
                </c:if>
                <c:if test="${param.msg == 'rated'}">
                    <div style="background: #fef9c3; color: #854d0e; padding: 12px 16px; border-radius: 8px; margin-bottom: 20px; border-left: 4px solid #f59e0b;">
                        <i class="fa-solid fa-star"></i> Thank you! Your evaluation and review have been recorded.
                    </div>
                </c:if>

                <!-- 1. FIVE-STAGE STATUS LIFECYCLE PROGRESS BAR -->
                <div class="detail-card">
                    <div style="font-size: 12px; font-weight: 700; color: #64748b; text-transform: uppercase; margin-bottom: 16px;">
                        <i class="fa-solid fa-timeline" style="color: #3b82f6; margin-right: 4px;"></i> Feedback Resolution Lifecycle
                    </div>

                    <c:set var="st" value="${report.status}" />
                    <div class="progress-track">
                        <!-- Step 1: Submitted -->
                        <div class="step-item ${st == 'Submitted' or st == 'Pending' ? 'active' : (st == 'Under Review' or st == 'Assigned' or st == 'Resolved' or st == 'Verified' ? 'completed' : '')}">
                            <div class="step-circle"><i class="fa-solid fa-paper-plane"></i></div>
                            <div class="step-label">Submitted</div>
                        </div>

                        <!-- Step 2: Under Review -->
                        <div class="step-item ${st == 'Under Review' ? 'active' : (st == 'Assigned' or st == 'Resolved' or st == 'Verified' ? 'completed' : '')}">
                            <div class="step-circle"><i class="fa-solid fa-magnifying-glass"></i></div>
                            <div class="step-label">Under Review</div>
                        </div>

                        <!-- Step 3: Assigned -->
                        <div class="step-item ${st == 'Assigned' ? 'active' : (st == 'Resolved' or st == 'Verified' ? 'completed' : '')}">
                            <div class="step-circle"><i class="fa-solid fa-user-check"></i></div>
                            <div class="step-label">Assigned</div>
                        </div>

                        <!-- Step 4: Resolved -->
                        <div class="step-item ${st == 'Resolved' or st == 'Verified' ? 'active completed' : ''}">
                            <div class="step-circle"><i class="fa-solid fa-circle-check"></i></div>
                            <div class="step-label">Resolved</div>
                        </div>

                        <!-- Step 5: Evaluated / Closed -->
                        <div class="step-item ${not empty report.rating and report.rating > 0 ? 'completed' : ''}">
                            <div class="step-circle"><i class="fa-solid fa-star"></i></div>
                            <div class="step-label">Evaluated</div>
                        </div>
                    </div>
                </div>

                <!-- 2. REPORT DETAILS -->
                <div class="detail-card">
                    <h3 style="margin-top: 0; font-size: 16px; border-bottom: 1px solid #f1f5f9; padding-bottom: 10px; color: #334155;">
                        <i class="fa-solid fa-file-lines" style="color: #3b82f6; margin-right: 6px;"></i> Submission Details
                    </h3>

                    <div class="info-row">
                        <div class="info-label">Title:</div>
                        <div class="info-value" style="font-weight: 700; font-size: 15px; color: #0f172a;">${report.title}</div>
                    </div>
                    <div class="info-row">
                        <div class="info-label">Issue Category:</div>
                        <div class="info-value">
                            <c:choose>
                                <c:when test="${report.reportType == 'FULL_BIN'}"><span style="color: #ef4444; font-weight: 600;"><i class="fa-solid fa-triangle-exclamation"></i> Waste Bin Full / Overflowing</span></c:when>
                                <c:when test="${report.reportType == 'DAMAGED_BIN'}"><span style="color: #f59e0b; font-weight: 600;"><i class="fa-solid fa-wrench"></i> Damaged Bin / Broken Mechanism</span></c:when>
                                <c:when test="${report.reportType == 'DIRTY_AREA'}"><span style="color: #8b5cf6; font-weight: 600;"><i class="fa-solid fa-broom"></i> Unhygienic Surrounding Area</span></c:when>
                                <c:otherwise><span style="color: #64748b;"><i class="fa-solid fa-circle-info"></i> Other Cleanliness Concern</span></c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="info-row">
                        <div class="info-label">Campus Zone:</div>
                        <div class="info-value">${report.areaName != null ? report.areaName : 'Campus Grounds'}</div>
                    </div>
                    <c:if test="${not empty report.binCode}">
                        <div class="info-row">
                            <div class="info-label">Associated Smart Bin:</div>
                            <div class="info-value">
                                <a href="${pageContext.request.contextPath}/wastebin/view?id=${report.binID}" style="color: #2563eb; font-weight: 700; text-decoration: none;">
                                    <i class="fa-solid fa-trash-can"></i> ${report.binCode}
                                </a>
                            </div>
                        </div>
                    </c:if>
                    <div class="info-row">
                        <div class="info-label">Submitted By:</div>
                        <div class="info-value">${report.citizenName != null ? report.citizenName : report.citizenID}</div>
                    </div>
                    <div class="info-row">
                        <div class="info-label">Date Submitted:</div>
                        <div class="info-value">
                            <fmt:formatDate value="${report.createdDate}" pattern="yyyy-MM-dd HH:mm:ss"/>
                        </div>
                    </div>
                    <div class="info-row">
                        <div class="info-label">Description:</div>
                        <div class="info-value" style="background: #F8FAFC; padding: 14px 16px; border-radius: 8px; line-height: 1.6; border: 1px solid #CBD5E1; color: #0F172A;">
                            ${report.description}
                        </div>
                    </div>

                    <!-- Photo Attachment -->
                    <c:if test="${not empty report.imageURL}">
                        <div class="info-row">
                            <div class="info-label">Attached Photo:</div>
                            <div class="info-value">
                                <img src="${report.imageURL}" alt="Report photo" style="max-width: 320px; border-radius: 8px; border: 1px solid #e2e8f0; box-shadow: 0 2px 8px rgba(0,0,0,0.05);" />
                            </div>
                        </div>
                    </c:if>

                    <!-- Interactive Pinpoint Map -->
                    <c:if test="${not empty report.latitude and not empty report.longitude}">
                        <div class="info-row" style="margin-top: 14px;">
                            <div class="info-label">Pinpointed Location:</div>
                            <div class="info-value">
                                <span style="font-family: monospace; font-size: 12px; color: #475569;">
                                    <i class="fa-solid fa-crosshairs" style="color: #ef4444;"></i> ${report.latitude}, ${report.longitude}
                                </span>
                                <div id="detailMap"></div>
                            </div>
                        </div>
                    </c:if>
                </div>

                <!-- 3. VERIFICATION & RESOLUTION NOTES -->
                <div class="detail-card">
                    <h3 style="margin-top: 0; font-size: 16px; border-bottom: 1px solid #f1f5f9; padding-bottom: 10px; color: #334155;">
                        <i class="fa-solid fa-clipboard-check" style="color: #10b981; margin-right: 6px;"></i> Campus Staff Actions &amp; Feedback Notes
                    </h3>

                    <c:choose>
                        <c:when test="${not empty report.verifiedBy}">
                            <div class="info-row">
                                <div class="info-label">Processed By:</div>
                                <div class="info-value"><strong>${report.verifierName}</strong> (${report.verifiedBy})</div>
                            </div>
                            <div class="info-row">
                                <div class="info-label">Processing Time:</div>
                                <div class="info-value">
                                    <fmt:formatDate value="${report.verifiedDate}" pattern="yyyy-MM-dd HH:mm:ss"/>
                                </div>
                            </div>
                            <div class="info-row">
                                <div class="info-label">Supervisor Note:</div>
                                <div class="info-value" style="background: #f0fdf4; padding: 12px 14px; border-radius: 6px; color: #166534; border: 1px solid #dcfce7; line-height: 1.6;">
                                    ${report.feedbackNote != null ? report.feedbackNote : 'Action successfully logged.'}
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <p style="color: #94a3b8; font-style: italic; margin: 0; padding: 8px 0;">
                                <i class="fa-solid fa-clock"></i> This report is currently in queue awaiting review by an Area Supervisor.
                            </p>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- 4. CITIZEN EVALUATION & RATING SECTION (WHEN RESOLVED) -->
                <c:if test="${report.status == 'Resolved' or report.status == 'Verified'}">
                    <div class="detail-card" id="rateSection" style="border: 2px solid #fef08a; background: #fffdf5;">
                        <h3 style="margin-top: 0; font-size: 16px; color: #854d0e; display: flex; align-items: center; gap: 8px;">
                            <i class="fa-solid fa-star" style="color: #eab308;"></i> Citizen Service Rating &amp; Review
                        </h3>

                        <c:choose>
                            <c:when test="${not empty report.rating and report.rating > 0}">
                                <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 8px;">
                                    <span style="font-size: 24px; color: #f59e0b;">
                                        <c:forEach begin="1" end="${report.rating}">★</c:forEach>
                                    </span>
                                    <span style="font-size: 14px; font-weight: 700; color: #1e293b;">(${report.rating} / 5 Stars)</span>
                                    <c:if test="${not empty report.ratedDate}">
                                        <span style="font-size: 12px; color: #94a3b8;">
                                            Rated on <fmt:formatDate value="${report.ratedDate}" pattern="yyyy-MM-dd HH:mm"/>
                                        </span>
                                    </c:if>
                                </div>
                                <c:if test="${not empty report.ratingComment}">
                                    <div style="background: white; padding: 10px 14px; border-radius: 6px; border: 1px solid #fef08a; font-size: 13px; color: #475569;">
                                        "${report.ratingComment}"
                                    </div>
                                </c:if>
                            </c:when>

                            <c:when test="${sessionScope.user.citizen}">
                                <p style="font-size: 13px; color: #713f12; margin: 0 0 14px 0;">
                                    The problem has been resolved! Please rate the promptness and cleanliness of the campus response:
                                </p>

                                <form action="${pageContext.request.contextPath}/citizen-report/rate" method="POST">
                                    <input type="hidden" name="reportID" value="${report.reportID}" />

                                    <div style="margin-bottom: 12px;">
                                        <label style="font-size: 13px; font-weight: 600; color: #334155; display: block; margin-bottom: 6px;">Your Rating:</label>
                                        <select name="rating" style="padding: 7px 12px; border-radius: 6px; border: 1px solid #cbd5e1; font-size: 14px; font-weight: 600; color: #d97706;">
                                            <option value="5">⭐⭐⭐⭐⭐ Excellent (5 Stars)</option>
                                            <option value="4">⭐⭐⭐⭐ Good (4 Stars)</option>
                                            <option value="3">⭐⭐⭐ Satisfactory (3 Stars)</option>
                                            <option value="2">⭐⭐ Needs Improvement (2 Stars)</option>
                                            <option value="1">⭐ Poor (1 Star)</option>
                                        </select>
                                    </div>

                                    <div style="margin-bottom: 14px;">
                                        <label style="font-size: 13px; font-weight: 600; color: #334155; display: block; margin-bottom: 6px;">Evaluation Comments (Optional):</label>
                                        <textarea name="ratingComment" rows="2" style="width: 100%; padding: 8px 12px; border-radius: 6px; border: 1px solid #cbd5e1; font-size: 13px; box-sizing: border-box;" placeholder="Share your experience regarding resolution speed, staff courtesy, or cleanliness..."></textarea>
                                    </div>

                                    <button type="submit" style="padding: 8px 20px; background: #eab308; color: #713f12; border: none; border-radius: 6px; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; gap: 6px;">
                                        <i class="fa-solid fa-star"></i> Submit Evaluation
                                    </button>
                                </form>
                            </c:when>

                            <c:otherwise>
                                <p style="font-size: 13px; color: #94a3b8; font-style: italic; margin: 0;">
                                    Awaiting citizen review and rating.
                                </p>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </c:if>

                <!-- 5. SUPERVISOR / MANAGEMENT ACTION CARD -->
                <c:if test="${sessionScope.user.supervisor || sessionScope.user.manager || sessionScope.user.admin || sessionScope.user.superAdmin}">
                    <div class="detail-card" style="background: #FFFFFF; border: 1px solid #CBD5E1;">
                        <h3 style="margin-top: 0; font-size: 16px; color: #0F172A; margin-bottom: 15px;">
                            <i class="fa-solid fa-pen-to-square" style="color: #f59e0b; margin-right: 6px;"></i> Management Verification &amp; Dispatch
                        </h3>

                        <form action="${pageContext.request.contextPath}/citizen-report/verify" method="POST">
                            <input type="hidden" name="reportID" value="${report.reportID}" />

                            <div style="display: flex; gap: 15px; margin-bottom: 15px;">
                                <div style="flex: 1;">
                                    <label style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 6px;">Set New Status:</label>
                                    <select name="status" style="width: 100%; padding: 8px 12px; border-radius: 6px; border: 1px solid #cbd5e1; font-size: 14px;" required>
                                        <option value="Under Review" ${report.status == 'Under Review' ? 'selected' : ''}>Under Review (Supervisor checking)</option>
                                        <option value="Assigned" ${report.status == 'Assigned' ? 'selected' : ''}>Assigned (Staff/Tech dispatched)</option>
                                        <option value="Resolved" ${report.status == 'Resolved' ? 'selected' : ''}>Resolved (Sanitation issue addressed)</option>
                                        <option value="Rejected" ${report.status == 'Rejected' ? 'selected' : ''}>Rejected (Invalid / False Alarm)</option>
                                    </select>
                                </div>
                            </div>

                            <div style="margin-bottom: 15px;">
                                <label style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 6px;">Feedback Note to Citizen:</label>
                                <textarea name="feedbackNote" rows="3" style="width: 100%; padding: 8px 12px; border-radius: 6px; border: 1px solid #cbd5e1; font-size: 14px; box-sizing: border-box;" placeholder="Enter inspection findings or resolution details...">${report.feedbackNote}</textarea>
                            </div>

                            <div style="display: flex; justify-content: space-between; align-items: center;">
                                <div>
                                    <c:if test="${not empty report.binID}">
                                        <a href="${pageContext.request.contextPath}/collection/create?binID=${report.binID}" style="font-size: 13px; color: #2563eb; font-weight: 600; text-decoration: none; margin-right: 15px;">
                                            <i class="fa-solid fa-truck"></i> Dispatch Collection Task
                                        </a>
                                        <a href="${pageContext.request.contextPath}/maintenance/create?binID=${report.binID}" style="font-size: 13px; color: #d97706; font-weight: 600; text-decoration: none;">
                                            <i class="fa-solid fa-screwdriver-wrench"></i> Create Maintenance Ticket
                                        </a>
                                    </c:if>
                                </div>
                                <button type="submit" style="padding: 9px 22px; background: #2563eb; color: white; border: none; border-radius: 6px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 6px;">
                                    <i class="fa-solid fa-check"></i> Update Status
                                </button>
                            </div>
                        </form>
                    </div>
                </c:if>
            </div>
        </div>
    </div>

    <!-- Leaflet Map Initialization for Location Pinpoint -->
    <c:if test="${not empty report.latitude and not empty report.longitude}">
        <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
        <script>
            document.addEventListener("DOMContentLoaded", function () {
                var lat = ${report.latitude};
                var lng = ${report.longitude};
                var map = L.map('detailMap').setView([lat, lng], 17);
                L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                    maxZoom: 19,
                    attribution: '&copy; OpenStreetMap SmartWaste'
                }).addTo(map);

                L.marker([lat, lng]).addTo(map)
                    .bindPopup("<strong>${report.title}</strong><br/>Category: ${report.reportType}")
                    .openPopup();
            });
        </script>
    </c:if>
</body>
</html>
