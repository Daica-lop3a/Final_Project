<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <title>SmartWaste Register</title>

        <link rel="stylesheet"
              href="<%= request.getContextPath()%>/css/register.css">

        <!-- FONT AWESOME LOCAL -->
        <script defer
        src="<%= request.getContextPath()%>/assets/fontawesome/fontawesome.js"></script>
        <script defer
        src="<%= request.getContextPath()%>/assets/fontawesome/solid.js"></script>
    </head>

    <body>
        <div class="register-page">

            <!-- LEFT SIDE -->
            <section class="register-intro">
                <a class="brand" href="<%= request.getContextPath()%>/login">
                    <img src="<%= request.getContextPath()%>/images/logo-horizontal.png" alt="SmartWaste Logo" style="height: 42px; width: auto; object-fit: contain;">
                </a>

                <div class="intro-content">
                    <div class="eyebrow">SMART WASTE MANAGEMENT</div>

                    <h1>Small Steps.<br>Greener Future.</h1>

                    <p>
                        Create your SmartWaste account and be part of a smarter,
                        cleaner and more sustainable community.
                    </p>

                    <div class="intro-features">
                        <div class="intro-feature">
                            <span class="feature-icon">
                                <i class="fa-solid fa-check" aria-hidden="true"></i>
                            </span>
                            <span>Manage your account easily</span>
                        </div>

                        <div class="intro-feature">
                            <span class="feature-icon">
                                <i class="fa-solid fa-check" aria-hidden="true"></i>
                            </span>
                            <span>Support responsible waste management</span>
                        </div>

                        <div class="intro-feature">
                            <span class="feature-icon">
                                <i class="fa-solid fa-check" aria-hidden="true"></i>
                            </span>
                            <span>Take a step toward a greener future</span>
                        </div>
                    </div>
                </div>

                <div class="intro-footer">SmartWaste Management System</div>
            </section>

            <!-- RIGHT SIDE -->
            <main class="register-side">
                <div class="register-card">

                    <!-- MOBILE LOGO -->
                    <a class="mobile-logo"
                       href="<%= request.getContextPath()%>/login">

                        <span class="brand-icon">
                            <i class="fa-solid fa-recycle" aria-hidden="true"></i>
                        </span>

                        <span>SmartWaste</span>
                    </a>

                    <!-- REGISTER HEADER -->
                    <header class="register-header">
                        <div class="register-eyebrow">GET STARTED</div>
                        <h2>Create account</h2>
                        <p>Enter your details to join SmartWaste.</p>
                    </header>

                    <!-- ERROR MESSAGE -->
                    <%
                        String error = (String) request.getAttribute("ERROR");
                        if (error != null && !error.trim().isEmpty()) {
                    %>
                    <div class="register-error" role="alert">
                        <i class="fa-solid fa-circle-exclamation"
                           aria-hidden="true"></i>
                        <span><%= error%></span>
                    </div>
                    <%
                        }
                    %>

                    <!-- REGISTER FORM -->
                    <form action="<%= request.getContextPath()%>/register"
                          method="POST">

                        <!-- FULL NAME -->
                        <div class="form-group">
                            <label for="fullName">Full Name</label>

                            <div class="input-wrapper">
                                <span class="input-icon">
                                    <i class="fa-solid fa-user" aria-hidden="true"></i>
                                </span>

                                <input
                                    type="text"
                                    id="fullName"
                                    name="fullName"
                                    placeholder="Enter your full name"
                                    autocomplete="name"
                                    required>
                            </div>
                        </div>

                        <!-- EMAIL -->
                        <div class="form-group">
                            <label for="email">Email Address</label>

                            <div class="input-wrapper">
                                <span class="input-icon">
                                    <i class="fa-solid fa-envelope" aria-hidden="true"></i>
                                </span>

                                <input
                                    type="email"
                                    id="email"
                                    name="email"
                                    placeholder="you@example.com"
                                    autocomplete="email"
                                    required>
                            </div>
                        </div>

                        <!-- PHONE -->
                        <div class="form-group">
                            <label for="phoneNumber">Phone Number</label>

                            <div class="input-wrapper">
                                <span class="input-icon">
                                    <i class="fa-solid fa-phone" aria-hidden="true"></i>
                                </span>

                                <input
                                    type="tel"
                                    id="phoneNumber"
                                    name="phoneNumber"
                                    placeholder="e.g. 0901234567"
                                    pattern="^(0|\+84)[35789][0-9]{8}$"
                                    title="Vietnamese mobile phone: 10 digits starting with 03, 05, 07, 08, 09 or +84"
                                    autocomplete="tel"
                                    required>
                            </div>
                            <small style="display: block; margin-top: 4px; font-size: 11px; color: #5E7E70;">Vietnamese mobile number (e.g. 0901234567 or +84901234567)</small>
                        </div>

                        <!-- PASSWORD -->
                        <div class="form-group">
                            <label for="password">Password</label>

                            <div class="input-wrapper">
                                <span class="input-icon">
                                    <i class="fa-solid fa-lock" aria-hidden="true"></i>
                                </span>

                                <input
                                    type="password"
                                    id="password"
                                    name="password"
                                    placeholder="Create a password"
                                    autocomplete="new-password"
                                    required>

                                <button
                                    type="button"
                                    class="password-toggle"
                                    data-target="password"
                                    aria-label="Show password"
                                    aria-pressed="false">
                                    <i class="fa-solid fa-eye" aria-hidden="true"></i>
                                </button>
                            </div>
                        </div>

                        <!-- CONFIRM PASSWORD -->
                        <div class="form-group">
                            <label for="confirmPassword">Confirm Password</label>

                            <div class="input-wrapper">
                                <span class="input-icon">
                                    <i class="fa-solid fa-shield-halved"
                                       aria-hidden="true"></i>
                                </span>

                                <input
                                    type="password"
                                    id="confirmPassword"
                                    name="confirmPassword"
                                    placeholder="Enter your password again"
                                    autocomplete="new-password"
                                    required>

                                <button
                                    type="button"
                                    class="password-toggle"
                                    data-target="confirmPassword"
                                    aria-label="Show password"
                                    aria-pressed="false">
                                    <i class="fa-solid fa-eye" aria-hidden="true"></i>
                                </button>
                            </div>
                        </div>

                        <!-- SUBMIT BUTTON -->
                        <button type="submit" class="register-button">
                            <span>Create Account</span>
                            <i class="fa-solid fa-arrow-right" aria-hidden="true"></i>
                        </button>
                    </form>

                    <!-- DIVIDER -->
                    <div class="register-divider">
                        <span>SMARTWASTE</span>
                    </div>

                    <!-- LOGIN LINK -->
                    <p class="register-login-link">
                        Already have an account?
                        <a href="<%= request.getContextPath()%>/login">Sign in</a>
                    </p>

                    <!-- NOTE -->
                    <p class="register-note">
                        Create your account and start your SmartWaste journey.
                    </p>
                </div>
            </main>
        </div>

        <!-- SHOW / HIDE PASSWORD -->
        <script>
            document.addEventListener("DOMContentLoaded", function () {
                document.querySelectorAll(".password-toggle").forEach(function (button) {
                    button.addEventListener("click", function () {
                        const targetId = button.getAttribute("data-target");
                        const input = document.getElementById(targetId);

                        if (!input) {
                            return;
                        }

                        const showPassword = input.type === "password";

                        input.type = showPassword ? "text" : "password";

                        button.innerHTML = showPassword
                                ? '<i class="fa-solid fa-eye-slash" aria-hidden="true"></i>'
                                : '<i class="fa-solid fa-eye" aria-hidden="true"></i>';

                        button.setAttribute(
                                "aria-label",
                                showPassword ? "Hide password" : "Show password"
                                );

                        button.setAttribute(
                                "aria-pressed",
                                showPassword ? "true" : "false"
                                );
                    });
                });
            });
        </script>

    </body>
</html>
