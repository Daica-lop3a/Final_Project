<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SmartWaste | Smart Waste Management System</title>
    
    <!-- Design System CSS -->
    <link rel="stylesheet" href="<%=ctx%>/css/landing.css">
    
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>

    <!-- 1. TOP ANNOUNCEMENT TICKER -->
    <div class="top-ticker">
        <div class="top-ticker-content">
            <span class="top-ticker-pill" style="background: rgba(254, 243, 199, 0.25); color: #FEF3C7;">Live Operations</span>
            <span>Smart Waste Management &bull; Live Bin Tracking &bull; Fast Collection Dispatch</span>
        </div>
    </div>

    <!-- 2. STICKY NAVBAR -->
    <header class="navbar" id="siteNavbar">
        <div class="nav-inner">
            
            <!-- Brand Logo -->
            <a class="brand" href="#overview" style="display: inline-flex; align-items: center; gap: 8px;">
                <img src="<%=ctx%>/images/logo-horizontal.png" alt="SmartWaste Logo" style="height: 42px; width: auto; object-fit: contain;">
            </a>

            <!-- Desktop Nav Links -->
            <nav class="nav-links">
                <a href="#overview" class="active">Overview</a>
                <a href="#features">Features</a>
                <a href="#workflow">How It Works</a>
                <a href="#roles">Roles</a>
            </nav>

            <!-- Action Buttons -->
            <div class="nav-actions">
                <a class="btn-nav-secondary" href="<%=ctx%>/wastebin">
                    <i class="fa-solid fa-map-location-dot" style="color: #00875A;"></i> Public Bins
                </a>
                <a class="btn-nav-primary" href="<%=ctx%>/login">
                    Sign In <i class="fa-solid fa-arrow-right"></i>
                </a>
            </div>

            <!-- Mobile Hamburger Toggle -->
            <button class="menu-toggle-btn" type="button" onclick="toggleMenu()" aria-label="Toggle navigation">
                <i class="fa-solid fa-bars" id="menuIcon"></i>
            </button>
        </div>

        <!-- Mobile Drawer Navigation -->
        <nav class="mobile-nav" id="mobileNav">
            <a href="#overview" onclick="closeMenu()">Overview</a>
            <a href="#features" onclick="closeMenu()">Features</a>
            <a href="#workflow" onclick="closeMenu()">How It Works</a>
            <a href="#roles" onclick="closeMenu()">User Roles</a>
            <a href="<%=ctx%>/forgot-password" onclick="closeMenu()" style="color: #00875A;">
                <i class="fa-solid fa-key"></i> Forgot Password?
            </a>
            
            <div class="mobile-action-group">
                <a href="<%=ctx%>/wastebin" class="btn-hero-secondary" style="text-align: center; justify-content: center;">
                    <i class="fa-solid fa-map-location-dot" style="color: #00875A;"></i> Public Bins Map
                </a>
                <a href="<%=ctx%>/login" class="btn-hero-primary" style="text-align: center; justify-content: center;">
                    Sign In <i class="fa-solid fa-arrow-right"></i>
                </a>
            </div>
        </nav>
    </header>

    <main>
        
        <!-- 3. HERO SECTION -->
        <section class="hero" id="overview">
            <div class="hero-inner">
                
                <!-- Left Column: Copy & Actions -->
                <div class="hero-content">
                    <div class="hero-kicker" style="background: #DCF2E4; color: #00875A; border-color: #D1EBCF;">
                        <span class="hero-kicker-dot" style="background: #00875A;"></span>
                        Smart Waste Management
                    </div>

                    <h1>
                        Smart Waste.<br>
                        <span>Cleaner, Greener Cities.</span>
                    </h1>

                    <p class="hero-subtitle">
                        Real-time bin fill tracking, automated high-fill alerts, 
                        and quick collection assignments for clean university campuses and neighborhoods.
                    </p>

                    <div class="hero-actions">
                        <a class="btn-hero-primary" href="<%=ctx%>/login">
                            Sign In <i class="fa-solid fa-arrow-right"></i>
                        </a>
                        <a class="btn-hero-secondary" href="<%=ctx%>/wastebin">
                            <i class="fa-solid fa-trash-can" style="color: #00875A;"></i> Explore Public Bins
                        </a>
                    </div>

                    <div class="hero-stats">
                        <div class="hero-stat-item">
                            <strong style="color: #00875A;">99.4%</strong>
                            <span>On-Time Pickup</span>
                        </div>
                        <div class="hero-stat-item">
                            <strong style="color: #0284C7;">42%</strong>
                            <span>Route Fuel Saved</span>
                        </div>
                        <div class="hero-stat-item">
                            <strong style="color: #7C3AED;">2,400+</strong>
                            <span>Smart Bins</span>
                        </div>
                    </div>
                </div>

                <!-- Right Column: Interactive Telemetry Card Showcase -->
                <div class="telemetry-card-wrapper" id="telemetry">
                    <div class="telemetry-card">
                        
                        <!-- Header with pulsing beacon -->
                        <div class="telemetry-header">
                            <div class="telemetry-node-title">
                                <div>
                                    <small style="color: #00875A;">Smart Sensor</small>
                                    <strong id="cardBinCode">BIN-Q1-001</strong>
                                </div>
                            </div>
                            <div class="live-beacon">
                                <span class="live-dot"></span>
                                <span id="cardStatusBadge">Live Data</span>
                            </div>
                        </div>

                        <!-- Body with Circular Gauge & Metrics -->
                        <div class="telemetry-body">
                            
                            <div class="fill-telemetry-row">
                                <div class="fill-gauge-circle" id="gaugeCircle" style="background: conic-gradient(#DC2626 0% 84%, #FEE2E2 84% 100%);">
                                    <div class="fill-gauge-inner">
                                        <strong id="gaugePercentText" style="color: #DC2626;">84%</strong>
                                        <small>CAPACITY</small>
                                    </div>
                                </div>

                                <div class="fill-meta-details">
                                    <span class="telemetry-badge-alert" id="levelBadge" style="background: #FEE2E2; color: #991B1B; border-color: #FECACA;">CRITICAL ALERT (&ge; 80%)</span>
                                    <h4 id="locTitle">Central Plaza — Zone A</h4>
                                    <p id="locSub"><i class="fa-solid fa-location-dot" style="color: #0284C7;"></i> Main Campus Corridor</p>
                                </div>
                            </div>

                            <!-- Real-time Specs Chips Grid with Colorful Accents -->
                            <div class="sensor-specs-grid">
                                <div class="sensor-chip" style="background: #EFF6FF; border-color: #BFDBFE;">
                                    <small style="color: #0284C7;"><i class="fa-solid fa-ruler-vertical"></i> Sensor Clearance</small>
                                    <strong id="depthValue" style="color: #1E3A8A;">18 cm / 120 cm</strong>
                                </div>
                                <div class="sensor-chip" style="background: #ECFDF5; border-color: #A7F3D0;">
                                    <small style="color: #059669;"><i class="fa-solid fa-battery-three-quarters"></i> Battery Health</small>
                                    <strong id="batteryValue" style="color: #065F46;">96% (Optimal)</strong>
                                </div>
                                <div class="sensor-chip" style="background: #FFFBEB; border-color: #FDE68A;">
                                    <small style="color: #D97706;"><i class="fa-solid fa-temperature-half"></i> Temperature</small>
                                    <strong id="tempValue" style="color: #92400E;">26.4°C (Normal)</strong>
                                </div>
                                <div class="sensor-chip" style="background: #FAF5FF; border-color: #DDD6FE;">
                                    <small style="color: #7C3AED;"><i class="fa-solid fa-clock-rotate-left"></i> Last Update</small>
                                    <strong style="color: #5B21B6;">Just now &bull; Synced</strong>
                                </div>
                            </div>

                            <!-- Collection Status Bar -->
                            <div class="telemetry-dispatch-bar" style="background: #FFFBEB; border-color: #FDE68A;">
                                <div class="dispatch-icon" style="background: #FEF3C7; color: #D97706;">
                                    <i class="fa-solid fa-truck-fast"></i>
                                </div>
                                <div class="dispatch-info">
                                    <strong id="dispatchCrew" style="color: #92400E;">Staff Assigned: STF-001 (Nguyen Van A)</strong>
                                    <span id="dispatchETA" style="color: #78350F;">Task in progress &bull; Estimated arrival in 8 min</span>
                                </div>
                            </div>

                        </div>

                        <!-- Live Simulator Control Bar -->
                        <div class="telemetry-sim-bar">
                            <span>Test Bin Fill:</span>
                            <div class="sim-btn-group">
                                <button type="button" class="sim-btn" onclick="simulateFill(32, 'Normal Fill', 'LOW', 82, 98, 24.8, 'No collection needed &bull; Bin is safe', this)">Normal (32%)</button>
                                <button type="button" class="sim-btn" onclick="simulateFill(68, 'Moderate Fill', 'WARN', 38, 97, 25.5, 'Monitored &bull; Approaching 70% capacity', this)">Medium (68%)</button>
                                <button type="button" class="sim-btn active" onclick="simulateFill(84, 'High Fill Alert', 'CRIT', 18, 96, 26.4, 'Staff Assigned: STF-001 (ETA: 8 min)', this)">Alert (84%)</button>
                            </div>
                        </div>

                    </div>
                </div>

            </div>
        </section>

        <!-- 4. KEY FEATURES (WITH COLORFUL ACCENTS) -->
        <section class="section" id="features">
            <div class="section-header">
                <span class="section-eyebrow" style="color: #0284C7;">Platform Features</span>
                <h2>Everything You Need to Manage Waste</h2>
                <p>
                    Practical tools for field staff, supervisors, technicians, and auditors 
                    to keep waste operations running smoothly every day.
                </p>
            </div>

            <div class="features-grid">
                
                <!-- Feature 1: Real-time Bin Tracking (Emerald) -->
                <article class="feature-card">
                    <div class="feature-icon-box color-emerald">
                        <i class="fa-solid fa-satellite-dish"></i>
                    </div>
                    <h3>Real-Time Bin Tracking</h3>
                    <p>
                        Ultrasonic sensors check bin fill levels, lid openings, and temperatures 
                        automatically every minute.
                    </p>
                    <span class="feature-tag" style="color: #059669;">Continuous Sensing</span>
                </article>

                <!-- Feature 2: Smart Fill Alerts (Amber) -->
                <article class="feature-card">
                    <div class="feature-icon-box color-amber">
                        <i class="fa-solid fa-bell"></i>
                    </div>
                    <h3>Smart Fill Alerts</h3>
                    <p>
                        When a bin exceeds 80% capacity, an automatic alert is created 
                        immediately to prevent trash overflow and odor.
                    </p>
                    <span class="feature-tag" style="color: #D97706;">Instant Notification</span>
                </article>

                <!-- Feature 3: Task Assignments (Royal Blue) -->
                <article class="feature-card">
                    <div class="feature-icon-box color-blue">
                        <i class="fa-solid fa-truck-pickup"></i>
                    </div>
                    <h3>Collection Tasks</h3>
                    <p>
                        Supervisors can easily create collection tasks, assign responsible staff, 
                        and track progress in real time.
                    </p>
                    <span class="feature-tag" style="color: #2563EB;">Quick Dispatch</span>
                </article>

                <!-- Feature 4: Device Maintenance (Purple) -->
                <article class="feature-card">
                    <div class="feature-icon-box color-purple">
                        <i class="fa-solid fa-screwdriver-wrench"></i>
                    </div>
                    <h3>Equipment &amp; Repairs</h3>
                    <p>
                        Technicians check sensor health, log calibrations, and record 
                        hardware maintenance with spare part tracking.
                    </p>
                    <span class="feature-tag" style="color: #7C3AED;">Reliable Hardware</span>
                </article>

                <!-- Feature 5: Audit & Verification (Teal) -->
                <article class="feature-card">
                    <div class="feature-icon-box color-teal">
                        <i class="fa-solid fa-clipboard-check"></i>
                    </div>
                    <h3>Audit &amp; Reports</h3>
                    <p>
                        Auditors compare physical inspection numbers with sensor readings 
                        to flag variances and ensure accurate data.
                    </p>
                    <span class="feature-tag" style="color: #0D9488;">Data Verification</span>
                </article>

                <!-- Feature 6: Public Reports (Rose) -->
                <article class="feature-card">
                    <div class="feature-icon-box color-rose">
                        <i class="fa-solid fa-bullhorn"></i>
                    </div>
                    <h3>Community Reports</h3>
                    <p>
                        Residents can report damaged or overflowing bins with photos 
                        and track the resolution status live.
                    </p>
                    <span class="feature-tag" style="color: #E11D48;">Citizen Feedback</span>
                </article>

            </div>
        </section>

        <!-- 5. OPERATIONAL WORKFLOW (COLORFUL STEPS) -->
        <section class="section-full" id="workflow">
            <div class="section-inner">
                
                <div class="section-header">
                    <span class="section-eyebrow" style="color: #7C3AED;">How It Works</span>
                    <h2>Simple Steps from Monitoring to Collection</h2>
                    <p>A clear 4-step process to ensure bins are emptied before they overflow.</p>
                </div>

                <div class="workflow-row">
                    
                    <!-- Step 1: Blue -->
                    <div class="workflow-step">
                        <span class="step-num-badge step-blue">Step 01</span>
                        <div class="step-icon-wrap step-blue">
                            <i class="fa-solid fa-wave-square"></i>
                        </div>
                        <h3>Sensor Reading</h3>
                        <p>Ultrasonic soundwaves measure waste depth and send live fill data to the system.</p>
                    </div>

                    <!-- Step 2: Amber -->
                    <div class="workflow-step">
                        <span class="step-num-badge step-amber">Step 02</span>
                        <div class="step-icon-wrap step-amber">
                            <i class="fa-solid fa-bell"></i>
                        </div>
                        <h3>Smart Alert</h3>
                        <p>If fill level reaches 80%, an automated alert ticket is created immediately.</p>
                    </div>

                    <!-- Step 3: Purple -->
                    <div class="workflow-step">
                        <span class="step-num-badge step-purple">Step 03</span>
                        <div class="step-icon-wrap step-purple">
                            <i class="fa-solid fa-user-check"></i>
                        </div>
                        <h3>Assign Staff</h3>
                        <p>Supervisors assign collection duties to on-duty staff with location maps.</p>
                    </div>

                    <!-- Step 4: Green -->
                    <div class="workflow-step">
                        <span class="step-num-badge step-green">Step 04</span>
                        <div class="step-icon-wrap step-green">
                            <i class="fa-solid fa-qrcode"></i>
                        </div>
                        <h3>Collect &amp; Confirm</h3>
                        <p>Staff empty the bin, scan the QR code to verify pickup, and the bin status resets.</p>
                    </div>

                </div>

            </div>
        </section>

        <!-- 6. USER ROLES (COLORFUL CARDS) -->
        <section class="section" id="roles">
            <div class="section-header">
                <span class="section-eyebrow" style="color: #00875A;">User Roles</span>
                <h2>Clear Tools for Every Role</h2>
                <p>Each user sees the exact tools they need for their daily job.</p>
            </div>

            <div class="roles-grid">
                
                <!-- Role 1: Administrator (Navy/Indigo) -->
                <div class="role-card" style="border-top: 3px solid #4338CA;">
                    <div class="role-header">
                        <div class="role-icon role-admin"><i class="fa-solid fa-user-shield"></i></div>
                        <div>
                            <span class="role-code" style="color: #4338CA;">ROLE 01</span>
                            <h3 class="role-title">Administrator</h3>
                        </div>
                    </div>
                    <p class="role-desc">System settings, user accounts, and campus zone management.</p>
                    <ul class="role-responsibilities">
                        <li>Manage user accounts and roles</li>
                        <li>Configure campus areas and catalogs</li>
                        <li>Review system activity and audit logs</li>
                    </ul>
                </div>

                <!-- Role 2: Supervisor (Amber) -->
                <div class="role-card" style="border-top: 3px solid #D97706;">
                    <div class="role-header">
                        <div class="role-icon role-supervisor"><i class="fa-solid fa-clipboard-user"></i></div>
                        <div>
                            <span class="role-code" style="color: #D97706;">ROLE 02</span>
                            <h3 class="role-title">Supervisor</h3>
                        </div>
                    </div>
                    <p class="role-desc">Bin monitoring, alert reviews, and collection task assignments.</p>
                    <ul class="role-responsibilities">
                        <li>Track live bin fill levels and alerts</li>
                        <li>Assign pickup tasks to collection staff</li>
                        <li>Review task completion in their area</li>
                    </ul>
                </div>

                <!-- Role 3: Collection Staff (Blue) -->
                <div class="role-card" style="border-top: 3px solid #2563EB;">
                    <div class="role-header">
                        <div class="role-icon role-staff"><i class="fa-solid fa-truck-pickup"></i></div>
                        <div>
                            <span class="role-code" style="color: #2563EB;">ROLE 03</span>
                            <h3 class="role-title">Collection Staff</h3>
                        </div>
                    </div>
                    <p class="role-desc">Emptying bins on site and updating task status with QR verification.</p>
                    <ul class="role-responsibilities">
                        <li>View assigned pickup tasks on mobile</li>
                        <li>Scan bin QR codes to verify location</li>
                        <li>Update task status when collection is complete</li>
                    </ul>
                </div>

                <!-- Role 4: Technician (Purple) -->
                <div class="role-card" style="border-top: 3px solid #7C3AED;">
                    <div class="role-header">
                        <div class="role-icon role-tech"><i class="fa-solid fa-microchip"></i></div>
                        <div>
                            <span class="role-code" style="color: #7C3AED;">ROLE 04</span>
                            <h3 class="role-title">Technician</h3>
                        </div>
                    </div>
                    <p class="role-desc">Sensor testing, device calibration, and hardware repairs.</p>
                    <ul class="role-responsibilities">
                        <li>Install and configure IoT sensors</li>
                        <li>Test and calibrate fill depth sensors</li>
                        <li>Record repair progress and replacement parts</li>
                    </ul>
                </div>

                <!-- Role 5: Auditor (Teal) -->
                <div class="role-card" style="border-top: 3px solid #0D9488;">
                    <div class="role-header">
                        <div class="role-icon role-auditor"><i class="fa-solid fa-scale-balanced"></i></div>
                        <div>
                            <span class="role-code" style="color: #0D9488;">ROLE 05</span>
                            <h3 class="role-title">Auditor</h3>
                        </div>
                    </div>
                    <p class="role-desc">Data quality reviews and independent inspection checks.</p>
                    <ul class="role-responsibilities">
                        <li>Compare sensor readings with manual checks</li>
                        <li>Record discrepancies and investigation notes</li>
                        <li>Export audit reports for compliance</li>
                    </ul>
                </div>

                <!-- Role 6: Citizen / Resident (Rose) -->
                <div class="role-card" style="border-top: 3px solid #E11D48;">
                    <div class="role-header">
                        <div class="role-icon role-citizen"><i class="fa-solid fa-street-view"></i></div>
                        <div>
                            <span class="role-code" style="color: #E11D48;">ROLE 06</span>
                            <h3 class="role-title">Citizen User</h3>
                        </div>
                    </div>
                    <p class="role-desc">Public bin finder and community problem reporting.</p>
                    <ul class="role-responsibilities">
                        <li>Find nearest public bins on the live map</li>
                        <li>Report full or damaged bins with photos</li>
                        <li>Track report progress until resolved</li>
                    </ul>
                </div>

            </div>
        </section>

        <!-- 7. CALL TO ACTION (CTA) -->
        <section class="cta-banner">
            <div class="cta-inner">
                <div class="cta-copy">
                    <span class="cta-eyebrow" style="color: #FEF3C7;">Get Started</span>
                    <h2>Ready to manage waste smarter?</h2>
                    <p>
                        Sign in to access your role dashboard, check live bin fill levels, 
                        and keep your campus or city clean.
                    </p>
                </div>
                <div class="cta-buttons">
                    <a class="btn-cta-primary" href="<%=ctx%>/login">
                        Sign In <i class="fa-solid fa-arrow-right"></i>
                    </a>
                    <a class="btn-cta-secondary" href="<%=ctx%>/wastebin">
                        Explore Public Bins
                    </a>
                </div>
            </div>
        </section>

    </main>

    <!-- 8. FOOTER WITH FORGOT PASSWORD LINK -->
    <footer class="footer">
        <div class="footer-inner">
            
            <div class="footer-top">
                <div class="footer-brand">
                    <div class="footer-brand-title" style="display: flex; align-items: center; gap: 10px;">
                        <img src="<%=ctx%>/images/logo-icon.png" alt="SmartWaste Logo" style="height: 32px; width: auto; object-fit: contain;">
                        <span>SmartWaste</span>
                    </div>
                    <p>
                        Smart Waste Management System. 
                        Keeping campus and municipal areas clean and sustainable.
                    </p>
                </div>

                <div class="footer-links-group">
                    <div class="footer-col">
                        <h4>Navigation</h4>
                        <ul>
                            <li><a href="#overview">Overview</a></li>
                            <li><a href="#features">Key Features</a></li>
                            <li><a href="#workflow">How It Works</a></li>
                            <li><a href="#roles">User Roles</a></li>
                        </ul>
                    </div>

                    <div class="footer-col">
                        <h4>Quick Access</h4>
                        <ul>
                            <li><a href="<%=ctx%>/login">Sign In</a></li>
                            <li><a href="<%=ctx%>/forgot-password" style="color: #93C5FD;"><i class="fa-solid fa-key" style="font-size: 11px;"></i> Forgot Password</a></li>
                            <li><a href="<%=ctx%>/wastebin">Public Bins Map</a></li>
                            <li><a href="<%=ctx%>/citizen-report">Report an Issue</a></li>
                            <li><a href="#roles">User Roles</a></li>
                        </ul>
                    </div>

                    <div class="footer-col">
                        <h4>System</h4>
                        <ul>
                            <li><a href="#overview">Ultrasonic Sensors</a></li>
                            <li><a href="#overview">LoRaWAN Network</a></li>
                            <li><a href="#overview">Privacy &amp; Terms</a></li>
                        </ul>
                    </div>
                </div>
            </div>

            <div class="footer-bottom">
                <div>
                    &copy; 2026 SmartWaste System. All rights reserved.
                </div>
                <div class="system-status-pill">
                    <span class="system-status-dot"></span>
                    <span>All Systems Operational &bull; 99.98% Sensor Uptime</span>
                </div>
            </div>

        </div>
    </footer>

    <!-- 9. INTERACTIVE SIMULATION & MENU SCRIPT -->
    <script>
        // Toggle mobile drawer menu
        function toggleMenu() {
            var nav = document.getElementById("mobileNav");
            var icon = document.getElementById("menuIcon");
            if (nav.classList.contains("open")) {
                nav.classList.remove("open");
                icon.className = "fa-solid fa-bars";
            } else {
                nav.classList.add("open");
                icon.className = "fa-solid fa-xmark";
            }
        }

        // Close mobile drawer on link click
        function closeMenu() {
            var nav = document.getElementById("mobileNav");
            var icon = document.getElementById("menuIcon");
            if (nav) nav.classList.remove("open");
            if (icon) icon.className = "fa-solid fa-bars";
        }

        // Close mobile menu if clicked outside
        document.addEventListener("click", function(event) {
            var navbar = document.getElementById("siteNavbar");
            if (navbar && !navbar.contains(event.target)) {
                closeMenu();
            }
        });

        // Interactive Telemetry Simulation
        function simulateFill(percent, statusText, statusLevel, depth, battery, temp, dispatchInfo, btnElem) {
            var circle = document.getElementById("gaugeCircle");
            var percentText = document.getElementById("gaugePercentText");
            var levelBadge = document.getElementById("levelBadge");
            var depthValue = document.getElementById("depthValue");
            var batteryValue = document.getElementById("batteryValue");
            var tempValue = document.getElementById("tempValue");
            var dispatchCrew = document.getElementById("dispatchCrew");
            var dispatchETA = document.getElementById("dispatchETA");

            percentText.innerText = percent + "%";
            depthValue.innerText = depth + " cm / 120 cm";
            batteryValue.innerText = battery + "% (Optimal)";
            tempValue.innerText = temp + "°C (Safe)";

            var color = "#00875A";
            var trackColor = "#DCF2E4";
            if (statusLevel === "CRIT") {
                color = "#DC2626";
                trackColor = "#FEE2E2";
                percentText.style.color = "#DC2626";
                levelBadge.style.background = "#FEE2E2";
                levelBadge.style.color = "#991B1B";
                levelBadge.style.borderColor = "#FECACA";
                levelBadge.innerHTML = "CRITICAL ALERT (&ge; 80%)";
                dispatchCrew.innerText = "Staff Assigned: STF-001 (Nguyen Van A)";
                dispatchCrew.style.color = "#991B1B";
                dispatchETA.innerText = "Task in progress • Estimated arrival in 8 min";
            } else if (statusLevel === "WARN") {
                color = "#D97706";
                trackColor = "#FEF3C7";
                percentText.style.color = "#D97706";
                levelBadge.style.background = "#FEF3C7";
                levelBadge.style.color = "#92400E";
                levelBadge.style.borderColor = "#FDE68A";
                levelBadge.innerHTML = "WARNING FILL LEVEL (68%)";
                dispatchCrew.innerText = "Supervisor Monitored • Task Queued";
                dispatchCrew.style.color = "#92400E";
                dispatchETA.innerText = "Threshold approaching • Collection scheduled";
            } else {
                color = "#00875A";
                trackColor = "#DCF2E4";
                percentText.style.color = "#00875A";
                levelBadge.style.background = "#DCF2E4";
                levelBadge.style.color = "#00875A";
                levelBadge.style.borderColor = "#D1EBCF";
                levelBadge.innerHTML = "SAFE CAPACITY (32%)";
                dispatchCrew.innerText = "No collection needed";
                dispatchCrew.style.color = "#00875A";
                dispatchETA.innerText = "Bin operating within normal capacity limits";
            }

            circle.style.background = "conic-gradient(" + color + " 0% " + percent + "%, " + trackColor + " " + percent + "% 100%)";

            var buttons = document.querySelectorAll(".sim-btn");
            buttons.forEach(function(btn) {
                btn.classList.remove("active");
            });
            if (btnElem) {
                btnElem.classList.add("active");
            } else if (typeof event !== 'undefined' && event && event.target) {
                event.target.classList.add("active");
            }
        }
    </script>

</body>
</html>
