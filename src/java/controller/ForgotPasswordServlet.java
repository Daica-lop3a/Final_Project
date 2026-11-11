package controller;

import dao.AuditLogDAO;
import dao.UserDAO;
import model.AppUser;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * COM-03: Forgot Password and Self-Service Password Reset
 * Allows users across all 8 roles to reset their password with verified phone challenge.
 */
@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {

    private static final String FORGOT_PAGE = "/WEB-INF/views/forgotPassword.jsp";
    private final UserDAO users = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher(FORGOT_PAGE).forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String email = req.getParameter("email");
        String phoneNumber = req.getParameter("phoneNumber");
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        if (email != null) email = email.trim();
        if (phoneNumber != null) phoneNumber = phoneNumber.trim();

        if (email == null || email.isEmpty()
                || phoneNumber == null || phoneNumber.isEmpty()
                || newPassword == null || newPassword.isEmpty()
                || confirmPassword == null || confirmPassword.isEmpty()) {
            req.setAttribute("ERROR", "Please fill in all required fields.");
            req.setAttribute("OLD_EMAIL", email);
            req.setAttribute("OLD_PHONE", phoneNumber);
            req.getRequestDispatcher(FORGOT_PAGE).forward(req, resp);
            return;
        }

        try {
            AppUser user = users.findByEmail(email);

            if (user == null) {
                req.setAttribute("ERROR", "No registered account found with this email address.");
                req.setAttribute("OLD_EMAIL", email);
                req.setAttribute("OLD_PHONE", phoneNumber);
                req.getRequestDispatcher(FORGOT_PAGE).forward(req, resp);
                return;
            }

            if (!user.isStatus()) {
                req.setAttribute("ERROR", "This account is currently locked. Please contact your Super Administrator.");
                req.setAttribute("OLD_EMAIL", email);
                req.setAttribute("OLD_PHONE", phoneNumber);
                req.getRequestDispatcher(FORGOT_PAGE).forward(req, resp);
                return;
            }

            // Security verification: verify Vietnamese phone number format
            if (!phoneNumber.matches("^(?:\\+84|0)[35789]\\d{8}$")) {
                req.setAttribute("ERROR", "Invalid Vietnamese phone number format (e.g. 0901234567 or +84901234567).");
                req.setAttribute("OLD_EMAIL", email);
                req.setAttribute("OLD_PHONE", phoneNumber);
                req.getRequestDispatcher(FORGOT_PAGE).forward(req, resp);
                return;
            }

            // Security verification: verify phone number
            String inputDigits = phoneNumber.replaceAll("[^0-9]", "");
            String userDigits = (user.getPhoneNumber() != null) ? user.getPhoneNumber().replaceAll("[^0-9]", "") : "";
            if (inputDigits.startsWith("84") && inputDigits.length() == 11) {
                inputDigits = "0" + inputDigits.substring(2);
            }
            if (userDigits.startsWith("84") && userDigits.length() == 11) {
                userDigits = "0" + userDigits.substring(2);
            }

            if (inputDigits.isEmpty() || !inputDigits.equals(userDigits)) {
                req.setAttribute("ERROR", "Verification failed: Registered phone number does not match our records.");
                req.setAttribute("OLD_EMAIL", email);
                req.setAttribute("OLD_PHONE", phoneNumber);
                req.getRequestDispatcher(FORGOT_PAGE).forward(req, resp);
                return;
            }

            // Password strength & match check
            if (newPassword.length() < 6) {
                req.setAttribute("ERROR", "New password must be at least 6 characters long.");
                req.setAttribute("OLD_EMAIL", email);
                req.setAttribute("OLD_PHONE", phoneNumber);
                req.getRequestDispatcher(FORGOT_PAGE).forward(req, resp);
                return;
            }

            if (!newPassword.equals(confirmPassword)) {
                req.setAttribute("ERROR", "New password and confirm password do not match.");
                req.setAttribute("OLD_EMAIL", email);
                req.setAttribute("OLD_PHONE", phoneNumber);
                req.getRequestDispatcher(FORGOT_PAGE).forward(req, resp);
                return;
            }

            // Update password in DB
            boolean success = users.resetPassword(user.getUserId(), newPassword);

            if (success) {
                // Clear any failed login lockout count
                LoginServlet.FAILED_ATTEMPTS.remove(user.getUserId());

                // COM-09 Audit log
                AuditLogDAO.log(user.getUserId(), "PASSWORD_RESET_FORGOT", "tblUsers",
                        user.getUserId(), null, "Self-service password reset successfully completed", req.getRemoteAddr());

                resp.sendRedirect(req.getContextPath() + "/login?msg=reset_success");
                return;
            } else {
                req.setAttribute("ERROR", "System error while resetting password. Please try again.");
                req.setAttribute("OLD_EMAIL", email);
                req.setAttribute("OLD_PHONE", phoneNumber);
                req.getRequestDispatcher(FORGOT_PAGE).forward(req, resp);
            }

        } catch (Exception e) {
            log("Error in ForgotPasswordServlet", e);
            req.setAttribute("ERROR", "An unexpected error occurred. Please try again later.");
            req.getRequestDispatcher(FORGOT_PAGE).forward(req, resp);
        }
    }
}
