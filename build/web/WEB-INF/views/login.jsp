<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign In - SmartWaste</title>

    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/login.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- PROGRESSIVE WEB APP (PWA) -->
    <meta name="mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="default">
    <meta name="apple-mobile-web-app-title" content="SmartWaste">
    <meta name="theme-color" content="#00875A">
    <link rel="apple-touch-icon" href="<%= request.getContextPath() %>/images/icon-192.png">
</head>

<body>
<div class="login-page">

    <!-- 1. TOP MINIMALIST HEADER -->
    <header class="login-topbar">
        <div class="login-topbar-inner">
            <a class="brand" href="<%= request.getContextPath() %>/">
                <img src="<%= request.getContextPath() %>/images/logo-horizontal.png" alt="SmartWaste Logo" style="height: 38px; width: auto; object-fit: contain;">
            </a>

            <div class="topbar-actions">
                <a href="<%= request.getContextPath() %>/wastebin" class="btn-topbar-secondary">
                    <i class="fa-solid fa-map-location-dot"></i> Public Bins
                </a>
                <a href="<%= request.getContextPath() %>/" class="btn-topbar-primary">
                    <i class="fa-solid fa-arrow-left"></i> Back to Home
                </a>
            </div>
        </div>
    </header>

    <!-- 2. MAIN CENTERED STAGE -->
    <main class="login-main-stage">
        <div class="login-container">
            
            <!-- Hero intro above the card -->
            <div class="login-intro-header">
                <div style="margin-bottom: 14px;">
                    <img src="<%= request.getContextPath() %>/images/logo.png" alt="SmartWaste Logo" style="height: 84px; width: auto; object-fit: contain;">
                </div>
                <div class="intro-eyebrow">
                    <span class="eyebrow-dot"></span>
                    Smart Waste System
                </div>
                <h1>Smart Waste. Cleaner City.</h1>
                <p>Sign in to monitor bin fill levels, manage alerts, and dispatch collection tasks in real time.</p>
            </div>

            <!-- THE CENTERED LOGIN CARD -->
            <div class="login-card">
                <header class="login-header">
                    <h2>Welcome Back</h2>
                    <p>Please enter your email and password to sign in.</p>
                </header>

                <!-- LOGIN FORM -->
                <form action="<%= request.getContextPath() %>/login" method="POST" class="login-form">

                    <!-- USERNAME / EMAIL -->
                    <div class="form-group">
                        <label for="username">Email or Username</label>
                        <div class="input-wrapper">
                            <span class="input-icon">
                                <i class="fa-solid fa-envelope" aria-hidden="true"></i>
                            </span>
                            <input
                                type="text"
                                id="username"
                                name="username"
                                value="<%= request.getAttribute("OLD_USERNAME") != null ? request.getAttribute("OLD_USERNAME") : "" %>"
                                placeholder="name@smartwaste.com"
                                autocomplete="username"
                                required>
                        </div>
                    </div>

                    <!-- PASSWORD -->
                    <div class="form-group">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
                            <label for="password" style="margin-bottom: 0;">Password</label>
                            <a href="<%= request.getContextPath() %>/forgot-password" style="color: #00875A; font-size: 13px; font-weight: 600; text-decoration: none; display: inline-flex; align-items: center; gap: 4px;">
                                <i class="fa-solid fa-key" style="font-size: 11px;"></i> Forgot password?
                            </a>
                        </div>

                        <div class="input-wrapper">
                            <span class="input-icon">
                                <i class="fa-solid fa-lock" aria-hidden="true"></i>
                            </span>

                            <input
                                type="password"
                                id="password"
                                name="password"
                                placeholder="Enter your password"
                                autocomplete="current-password"
                                required>

                            <button
                                type="button"
                                class="password-toggle"
                                id="togglePassword"
                                aria-label="Show password"
                                aria-pressed="false">
                                <i class="fa-solid fa-eye" aria-hidden="true"></i>
                            </button>
                        </div>
                    </div>

                    <!-- SUCCESS MESSAGE -->
                    <%
                        String success = (String) request.getAttribute("SUCCESS");
                        if (success != null && !success.trim().isEmpty()) {
                    %>
                        <div class="success-message" role="status">
                            <i class="fa-solid fa-circle-check" aria-hidden="true"></i>
                            <%= success %>
                        </div>
                    <%
                        }
                    %>

                    <!-- ERROR MESSAGE -->
                    <%
                        String error = (String) request.getAttribute("ERROR");
                        if (error != null && !error.trim().isEmpty()) {
                    %>
                        <div class="error-message" role="alert">
                            <i class="fa-solid fa-circle-exclamation" aria-hidden="true"></i>
                            <%= error %>
                        </div>
                    <%
                        }
                    %>

                    <!-- SUBMIT BUTTON -->
                    <button type="submit" class="login-button">
                        <span>Sign In</span>
                        <span class="arrow">
                            <i class="fa-solid fa-arrow-right" aria-hidden="true"></i>
                        </span>
                    </button>
                </form>

                <!-- REGISTER LINK -->
                <div class="register-link" style="margin-top: 24px;">
                    Don't have an account?
                    <a href="<%= request.getContextPath() %>/register">
                        Sign up
                    </a>
                </div>
            </div>

            <!-- 3. FEATURE HIGHLIGHTS (REDESIGNED LAYOUT) -->
            <div class="login-features-row">
                <div class="login-feature-card">
                    <div class="feature-icon" style="background: #E0F2FE; color: #0284C7;">
                        <i class="fa-solid fa-satellite-dish" aria-hidden="true"></i>
                    </div>
                    <div class="feature-text">
                        <h4>Real-Time Tracking</h4>
                        <p>Live ultrasonic fill depth &amp; temperature monitoring.</p>
                    </div>
                </div>

                <div class="login-feature-card">
                    <div class="feature-icon" style="background: #FEF3C7; color: #D97706;">
                        <i class="fa-solid fa-bell" aria-hidden="true"></i>
                    </div>
                    <div class="feature-text">
                        <h4>Automated Alerts</h4>
                        <p>Instant tickets created when bins reach 80% capacity.</p>
                    </div>
                </div>

                <div class="login-feature-card">
                    <div class="feature-icon" style="background: #EDE9FE; color: #7C3AED;">
                        <i class="fa-solid fa-truck-pickup" aria-hidden="true"></i>
                    </div>
                    <div class="feature-text">
                        <h4>Fast Task Dispatch</h4>
                        <p>Field assignments with maps and QR verification.</p>
                    </div>
                </div>
            </div>

        </div>
    </main>

    <!-- 4. BOTTOM FOOTER -->
    <footer class="login-footer">
        <div class="login-footer-inner">
            <div>
                &copy; 2026 SmartWaste Management System. All rights reserved.
            </div>
            <div class="system-status-pill">
                <span class="system-status-dot"></span>
                <span>All Systems Operational &bull; Live Telemetry Active</span>
            </div>
        </div>
    </footer>

</div>

<!-- SHOW / HIDE PASSWORD SCRIPT -->
<script>
    document.addEventListener("DOMContentLoaded", function () {
        const password = document.getElementById("password");
        const button = document.getElementById("togglePassword");

        if (!password || !button) {
            return;
        }

        button.addEventListener("click", function () {
            const showPassword = password.type === "password";

            password.type = showPassword ? "text" : "password";
            button.setAttribute(
                "aria-label",
                showPassword ? "Hide password" : "Show password"
            );
            button.setAttribute(
                "aria-pressed",
                showPassword ? "true" : "false"
            );

            button.innerHTML = showPassword
                ? '<i class="fa-solid fa-eye-slash" aria-hidden="true"></i>'
                : '<i class="fa-solid fa-eye" aria-hidden="true"></i>';
        });
    });
</script>

</body>
</html>
