<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password - SmartWaste</title>

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
                <a href="<%= request.getContextPath() %>/login" class="btn-topbar-primary">
                    <i class="fa-solid fa-arrow-left"></i> Sign In
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
                    <img src="<%= request.getContextPath() %>/images/logo.png" alt="SmartWaste Logo" style="height: 80px; width: auto; object-fit: contain;">
                </div>
                <div class="intro-eyebrow">
                    <span class="eyebrow-dot"></span>
                    Account Recovery
                </div>
                <h1>Reset Your Password</h1>
                <p>Verify your registered email and phone number to restore account access.</p>
            </div>

            <!-- THE CENTERED CARD -->
            <div class="login-card">
                <header class="login-header">
                    <h2>Password Assistance</h2>
                    <p>Enter your details below to establish a new password.</p>
                </header>

                <!-- FORGOT PASSWORD FORM -->
                <form action="<%= request.getContextPath() %>/forgot-password" method="POST" class="login-form">

                    <!-- EMAIL -->
                    <div class="form-group">
                        <label for="email">Registered Email</label>
                        <div class="input-wrapper">
                            <span class="input-icon">
                                <i class="fa-solid fa-envelope" aria-hidden="true"></i>
                            </span>
                            <input type="email" id="email" name="email"
                                   placeholder="e.g. user@smartwaste.com"
                                   value="<%= request.getAttribute("OLD_EMAIL") != null ? request.getAttribute("OLD_EMAIL") : "" %>"
                                   required autocomplete="email">
                        </div>
                    </div>

                    <!-- PHONE NUMBER (SECURITY CHALLENGE) -->
                    <div class="form-group">
                        <label for="phoneNumber">Registered Phone Number</label>
                        <div class="input-wrapper">
                            <span class="input-icon">
                                <i class="fa-solid fa-phone" aria-hidden="true"></i>
                            </span>
                            <input type="tel" id="phoneNumber" name="phoneNumber"
                                   placeholder="e.g. 0901000008"
                                   pattern="^(0|\+84)[35789][0-9]{8}$"
                                   title="Vietnamese mobile phone: 10 digits starting with 03, 05, 07, 08, 09 or +84"
                                   value="<%= request.getAttribute("OLD_PHONE") != null ? request.getAttribute("OLD_PHONE") : "" %>"
                                   required autocomplete="tel">
                        </div>
                        <small style="display: block; margin-top: 4px; font-size: 11px; color: #5E7E70;">
                            Registered Vietnamese phone number (e.g. 0901000008 or +84901000008).
                        </small>
                    </div>

                    <!-- NEW PASSWORD -->
                    <div class="form-group">
                        <label for="newPassword">New Password</label>
                        <div class="input-wrapper">
                            <span class="input-icon">
                                <i class="fa-solid fa-key" aria-hidden="true"></i>
                            </span>
                            <input type="password" id="newPassword" name="newPassword"
                                   placeholder="Enter new password (min. 6 chars)"
                                   required minlength="6">
                        </div>
                    </div>

                    <!-- CONFIRM NEW PASSWORD -->
                    <div class="form-group">
                        <label for="confirmPassword">Confirm New Password</label>
                        <div class="input-wrapper">
                            <span class="input-icon">
                                <i class="fa-solid fa-lock" aria-hidden="true"></i>
                            </span>
                            <input type="password" id="confirmPassword" name="confirmPassword"
                                   placeholder="Re-type new password"
                                   required minlength="6">
                        </div>
                    </div>

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
                        <span>Reset Password</span>
                        <span class="arrow">
                            <i class="fa-solid fa-arrow-right" aria-hidden="true"></i>
                        </span>
                    </button>
                </form>

                <!-- BACK TO LOGIN -->
                <div class="register-link" style="margin-top: 20px;">
                    Remembered your credentials?
                    <a href="<%= request.getContextPath() %>/login">
                        Back to Sign In
                    </a>
                </div>
            </div>

            <!-- 3. FEATURE HIGHLIGHTS -->
            <div class="login-features-row">
                <div class="login-feature-card">
                    <div class="feature-icon" style="background: #E0F2FE; color: #0284C7;">
                        <i class="fa-solid fa-shield-halved" aria-hidden="true"></i>
                    </div>
                    <div class="feature-text">
                        <h4>Verified Security</h4>
                        <p>Multi-field verification protects your account credentials.</p>
                    </div>
                </div>

                <div class="login-feature-card">
                    <div class="feature-icon" style="background: #DCF2E4; color: #00875A;">
                        <i class="fa-solid fa-lock" aria-hidden="true"></i>
                    </div>
                    <div class="feature-text">
                        <h4>Instant Update</h4>
                        <p>Change takes effect immediately without email delays.</p>
                    </div>
                </div>

                <div class="login-feature-card">
                    <div class="feature-icon" style="background: #EDE9FE; color: #7C3AED;">
                        <i class="fa-solid fa-circle-check" aria-hidden="true"></i>
                    </div>
                    <div class="feature-text">
                        <h4>Seamless Sign In</h4>
                        <p>Direct login after password reset is confirmed.</p>
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
                <span>All Systems Operational &bull; Security Verified</span>
            </div>
        </div>
    </footer>

</div>

</body>
</html>
