<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="model.AppUser"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%
    String ctx = request.getContextPath();
    AppUser user = (AppUser) session.getAttribute("user");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Citizen Help & Support Center - SmartWaste</title>
    <link rel="stylesheet" href="<%=ctx%>/css/style.css?v=20261017-v4">
    <link rel="stylesheet" href="<%=ctx%>/css/dashboard.css?v=20261017-v4">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .help-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 24px;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            color: #1C1E21;
        }
        .help-hero {
            background: #FFFFFF;
            border: 1px solid #D1EBCF;
            border-left: 4px solid #00875A;
            color: #050505;
            padding: 28px 30px;
            border-radius: 8px;
            margin-bottom: 24px;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .help-hero-text h1 {
            margin: 0 0 8px 0;
            font-size: 24px;
            font-weight: 800;
            color: #050505;
        }
        .help-hero-text p {
            margin: 0;
            font-size: 13.5px;
            color: #65676B;
            max-width: 650px;
            line-height: 1.6;
        }
        .grid-3 {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-bottom: 28px;
        }
        .info-card {
            background: #FFFFFF;
            border-radius: 8px;
            padding: 24px;
            border: 1px solid #D1EBCF;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
            transition: transform 0.15s, box-shadow 0.15s;
        }
        .info-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.06);
        }
        .info-icon {
            width: 44px;
            height: 44px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            margin-bottom: 16px;
            background: #DCF2E4;
            color: #00875A;
        }
        .info-title {
            font-size: 16px;
            font-weight: 700;
            color: #050505;
            margin-bottom: 8px;
        }
        .info-desc {
            font-size: 13px;
            color: #65676B;
            line-height: 1.6;
            margin-bottom: 16px;
        }
        .sort-guide-box {
            background: #FFFFFF;
            border-radius: 8px;
            padding: 24px;
            border: 1px solid #D1EBCF;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
            margin-bottom: 28px;
        }
        .sort-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-top: 16px;
        }
        .sort-col {
            border-radius: 6px;
            padding: 16px;
            border: 1px solid #D1EBCF;
            background: #EDF8F2;
        }
        .sort-col.organic { border-left: 3px solid #16A34A; }
        .sort-col.recycle { border-left: 3px solid #00875A; }
        .sort-col.general { border-left: 3px solid #D97706; }
        .sort-col.hazard  { border-left: 3px solid #DC2626; }

        .sort-header {
            display: flex;
            align-items: center;
            gap: 8px;
            font-weight: 700;
            font-size: 14px;
            margin-bottom: 8px;
            color: #050505;
        }

        .sort-items {
            font-size: 12px;
            color: #65676B;
            line-height: 1.6;
            margin: 0;
            padding-left: 18px;
        }

        .faq-box {
            background: #FFFFFF;
            border-radius: 8px;
            padding: 24px;
            border: 1px solid #D1EBCF;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
            margin-bottom: 28px;
        }
        .faq-item {
            border-bottom: 1px solid #E2F2E5;
            padding: 14px 0;
        }
        .faq-item:last-child {
            border-bottom: none;
        }
        .faq-question {
            font-size: 14px;
            font-weight: 700;
            color: #1e293b;
            cursor: pointer;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .faq-answer {
            margin-top: 8px;
            font-size: 13px;
            color: #64748b;
            line-height: 1.6;
        }
        .contact-box {
            background: #f8fafc;
            border: 1px dashed #cbd5e1;
            border-radius: 10px;
            padding: 24px;
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
        }
        .contact-item {
            display: flex;
            align-items: flex-start;
            gap: 12px;
        }
        .contact-icon {
            font-size: 20px;
            color: #10b981;
            margin-top: 2px;
        }
        .contact-item h4 {
            margin: 0 0 4px 0;
            font-size: 14px;
            color: #1e293b;
        }
        .contact-item p {
            margin: 0;
            font-size: 13px;
            color: #64748b;
        }
    </style>
</head>
<body>
<div class="dashboard-container">
    <jsp:include page="sidebar.jsp"/>

    <main class="main-content">
        <header class="top-bar" style="display: flex; align-items: center; justify-content: space-between;">
            <div style="display: flex; align-items: center; gap: 14px;">
                <button type="button" class="desktop-nav-toggle" onclick="toggleSidebarCollapse()" title="Toggle Sidebar (Expand / Collapse)">
                    <i class="fa-solid fa-bars"></i>
                </button>
                <div class="user-greeting">
                    <i class="fa-solid fa-circle-question" style="color: #10b981; margin-right: 8px; font-size: 18px;"></i>
                    <strong>Help & Public Support Center</strong>
                </div>
            </div>
            <div class="user-profile">
                <span style="font-size: 13px; color: #64748b;">Role: <strong><%= user != null ? user.getRoleName() : "Public User" %></strong></span>
            </div>
        </header>

        <div class="help-container">
            <!-- HERO BANNER -->
            <div class="help-hero">
                <div class="help-hero-text">
                    <h1>SmartWaste Public Assistance & Guide</h1>
                    <p>
                        Welcome to FPT University Smart Waste Management Portal. Here you can find guidance on locating public smart waste bins, classifying waste properly at source, submitting citizen feedback, and tracking issue resolution.
                    </p>
                </div>
                <div>
                    <a href="<%=ctx%>/citizen-report/create" style="display: inline-flex; align-items: center; gap: 8px; padding: 10px 18px; background: white; color: #047857; font-weight: 700; border-radius: 8px; text-decoration: none; box-shadow: 0 4px 10px rgba(0,0,0,0.1);">
                        <i class="fa-solid fa-bullhorn"></i> Submit Feedback
                    </a>
                </div>
            </div>

            <!-- 3 KEY PILLARS -->
            <div class="grid-3">
                <div class="info-card">
                    <div class="info-icon" style="background: #ecfdf5; color: #10b981;">
                        <i class="fa-solid fa-map-location-dot"></i>
                    </div>
                    <div class="info-title">1. Interactive Public Map</div>
                    <div class="info-desc">
                        Explore real-time fill levels and locations of all IoT-enabled waste bins across Campus. Find the nearest available bin instantly.
                    </div>
                    <a href="<%=ctx%>/map" style="color: #10b981; font-weight: 600; font-size: 13px; text-decoration: none;">
                        Open Public Map &rarr;
                    </a>
                </div>

                <div class="info-card">
                    <div class="info-icon" style="background: #fffbeb; color: #f59e0b;">
                        <i class="fa-solid fa-bullhorn"></i>
                    </div>
                    <div class="info-title">2. Citizen Incident Reporting</div>
                    <div class="info-desc">
                        Spot an overflowing bin, broken pedal mechanism, or dirty area? Submit a report with optional photo and pin your location on map.
                    </div>
                    <a href="<%=ctx%>/citizen-report" style="color: #f59e0b; font-weight: 600; font-size: 13px; text-decoration: none;">
                        My Reports &rarr;
                    </a>
                </div>

                <div class="info-card">
                    <div class="info-icon" style="background: #eff6ff; color: #3b82f6;">
                        <i class="fa-solid fa-bell"></i>
                    </div>
                    <div class="info-title">3. Live Status & Rating</div>
                    <div class="info-desc">
                        Receive instant notifications as campus supervisors review and dispatch staff. Rate the resolution quality from 1 to 5 stars!
                    </div>
                    <a href="<%=ctx%>/notification" style="color: #3b82f6; font-weight: 600; font-size: 13px; text-decoration: none;">
                        View Notifications &rarr;
                    </a>
                </div>
            </div>

            <!-- WASTE SORTING GUIDELINES -->
            <div class="sort-guide-box">
                <h3 style="margin: 0; font-size: 18px; color: #1e293b; display: flex; align-items: center; gap: 8px;">
                    <i class="fa-solid fa-recycle" style="color: #10b981;"></i> Campus Waste Classification Guide
                </h3>
                <p style="margin: 6px 0 0 0; font-size: 13px; color: #64748b;">
                    Please place waste into the corresponding color-coded bin to protect campus ecology and facilitate clean recycling:
                </p>

                <div class="sort-grid">
                    <div class="sort-col organic">
                        <div class="sort-header">
                            <i class="fa-solid fa-apple-whole"></i> Organic Waste
                        </div>
                        <ul class="sort-items">
                            <li>Leftover food & rice</li>
                            <li>Fruit peels, tea leaves</li>
                            <li>Vegetable scraps</li>
                            <li>Fallen leaves & flowers</li>
                        </ul>
                    </div>

                    <div class="sort-col recycle">
                        <div class="sort-header">
                            <i class="fa-solid fa-bottle-water"></i> Recyclable Waste
                        </div>
                        <ul class="sort-items">
                            <li>PET plastic bottles</li>
                            <li>Aluminum cans & tins</li>
                            <li>Cardboard boxes & paper</li>
                            <li>Glass containers</li>
                        </ul>
                    </div>

                    <div class="sort-col general">
                        <div class="sort-header">
                            <i class="fa-solid fa-trash-can"></i> General / Inorganic Waste
                        </div>
                        <ul class="sort-items">
                            <li>Styrofoam cups & trays</li>
                            <li>Snack wrappers, plastics</li>
                            <li>Medical face masks</li>
                            <li>Tissue paper, napkins</li>
                        </ul>
                    </div>

                    <div class="sort-col hazard">
                        <div class="sort-header">
                            <i class="fa-solid fa-triangle-exclamation"></i> Hazardous Waste
                        </div>
                        <ul class="sort-items">
                            <li>Used batteries & accumulators</li>
                            <li>Fluorescent light bulbs</li>
                            <li>Chemical / ink containers</li>
                            <li>Electronic components</li>
                        </ul>
                    </div>
                </div>
            </div>

            <!-- FREQUENTLY ASKED QUESTIONS -->
            <div class="faq-box">
                <h3 style="margin: 0 0 16px 0; font-size: 18px; color: #1e293b;">
                    <i class="fa-solid fa-circle-question" style="color: #6366f1; margin-right: 6px;"></i> Frequently Asked Questions (FAQ)
                </h3>

                <div class="faq-item">
                    <div class="faq-question">
                        <span>How does the 5-stage feedback lifecycle work?</span>
                        <i class="fa-solid fa-chevron-down" style="font-size: 12px; color: #94a3b8;"></i>
                    </div>
                    <div class="faq-answer">
                        When you submit feedback, its status begins as <strong>Submitted</strong>. An Area Supervisor reviews it (<strong>Under Review</strong>), dispatches field staff for collection or technician for repair (<strong>Assigned</strong>), and marks it <strong>Resolved</strong> once verified complete. If the report was duplicate or invalid, it will be marked <strong>Rejected</strong> with explanation.
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">
                        <span>Can I edit or cancel my feedback report after submitting?</span>
                        <i class="fa-solid fa-chevron-down" style="font-size: 12px; color: #94a3b8;"></i>
                    </div>
                    <div class="faq-answer">
                        Yes! As long as your report is still in <strong>Submitted</strong> status and has not yet been processed by campus staff, you can click <strong>Edit</strong> to modify the title, description, or location, or click <strong>Cancel</strong> to withdraw your report.
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">
                        <span>How often do IoT sensor fill levels update on the public map?</span>
                        <i class="fa-solid fa-chevron-down" style="font-size: 12px; color: #94a3b8;"></i>
                    </div>
                    <div class="faq-answer">
                        Ultrasonic sensors on each SmartWaste bin transmit real-time telemetry every 5 to 10 minutes. In case a bin rapidly reaches urgent capacity (&ge; 85%), an immediate high-priority alert is broadcast to the supervisory team.
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">
                        <span>Can public users view internal staff details or maintenance logs?</span>
                        <i class="fa-solid fa-chevron-down" style="font-size: 12px; color: #94a3b8;"></i>
                    </div>
                    <div class="faq-answer">
                        No. In strict compliance with privacy and enterprise security principles, public accounts (Role 8 - Citizen) only have access to public maps, public bin fill levels, personal feedback history, and user profile settings. Internal user rosters, technician telemetry tools, and audit logs are strictly protected.
                    </div>
                </div>
            </div>

            <!-- EMERGENCY CONTACTS -->
            <div class="contact-box">
                <div class="contact-item">
                    <div class="contact-icon"><i class="fa-solid fa-phone-volume"></i></div>
                    <div>
                        <h4>24/7 Environmental Hotline</h4>
                        <p><strong>028.7300.5588</strong> (Ext: 104)</p>
                        <p style="font-size: 11px; color: #94a3b8;">Direct dispatch for campus overflow</p>
                    </div>
                </div>

                <div class="contact-item">
                    <div class="contact-icon"><i class="fa-solid fa-envelope"></i></div>
                    <div>
                        <h4>Email Support & Feedback</h4>
                        <p><strong>greencampus@fpt.edu.vn</strong></p>
                        <p style="font-size: 11px; color: #94a3b8;">Average response time: &le; 2 hours</p>
                    </div>
                </div>

                <div class="contact-item">
                    <div class="contact-icon"><i class="fa-solid fa-building"></i></div>
                    <div>
                        <h4>Office of Campus Services</h4>
                        <p><strong>Room 204, Alpha Building</strong></p>
                        <p style="font-size: 11px; color: #94a3b8;">Saigon Hi-Tech Park, Thu Duc City</p>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>
</body>
</html>
