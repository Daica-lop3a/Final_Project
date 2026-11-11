package controller;

import dao.AuditLogDAO;
import dao.UserDAO;
import dao.AreaDAO;
import model.AppUser;
import model.Area;
import util.PasswordUtil;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Unified Profile and Password Management Servlet
 * Shared across all 8 roles (SAD, ADM, MGR, SUP, STF, TEC, AUD, USR).
 * 
 * Enforces role security:
 * - Users can only update their personal profile info (Full Name, Email, Phone Number).
 * - Role ID, Account Status, and User ID are strictly immutable.
 * - Self-service password change requires current password verification.
 */
@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

    private static final String PROFILE_PAGE = "/WEB-INF/views/profile.jsp";
    private final UserDAO userDAO = new UserDAO();
    private final AreaDAO areaDAO = new AreaDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        AppUser sessionUser = (session != null) ? (AppUser) session.getAttribute("user") : null;

        if (sessionUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Always fetch fresh user record from DB
        AppUser profileUser = userDAO.findById(sessionUser.getUserId());
        if (profileUser == null) {
            profileUser = sessionUser;
        } else {
            session.setAttribute("user", profileUser);
        }

        req.setAttribute("profileUser", profileUser);

        // Retrieve assigned area name or list of areas
        List<String> assignedAreaIds = userDAO.getAssignedAreaIds(profileUser.getUserId());
        List<Area> assignedAreas = new ArrayList<>();
        if (assignedAreaIds != null && !assignedAreaIds.isEmpty()) {
            for (String aid : assignedAreaIds) {
                Area a = areaDAO.findById(aid);
                if (a != null) {
                    assignedAreas.add(a);
                }
            }
        } else if (profileUser.getAreaId() != null && !profileUser.getAreaId().trim().isEmpty()) {
            Area a = areaDAO.findById(profileUser.getAreaId());
            if (a != null) {
                assignedAreas.add(a);
            }
        }
        req.setAttribute("assignedAreas", assignedAreas);

        // Flash / query messages
        String success = req.getParameter("success");
        if ("profile_updated".equals(success)) {
            req.setAttribute("SUCCESS_MSG", "Your profile details have been successfully updated.");
        } else if ("password_updated".equals(success)) {
            req.setAttribute("SUCCESS_MSG", "Your password has been changed successfully.");
        }

        req.getRequestDispatcher(PROFILE_PAGE).forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        AppUser sessionUser = (session != null) ? (AppUser) session.getAttribute("user") : null;

        if (sessionUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        if (action == null) {
            action = "update_profile";
        }

        if ("update_profile".equals(action)) {
            handleUpdateProfile(req, resp, sessionUser);
        } else if ("change_password".equals(action)) {
            handleChangePassword(req, resp, sessionUser);
        } else {
            resp.sendRedirect(req.getContextPath() + "/profile");
        }
    }

    private void handleUpdateProfile(HttpServletRequest req, HttpServletResponse resp, AppUser sessionUser)
            throws ServletException, IOException {

        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String phoneNumber = req.getParameter("phoneNumber");

        if (fullName != null) fullName = fullName.trim();
        if (email != null) email = email.trim();
        if (phoneNumber != null) phoneNumber = phoneNumber.trim();

        if (fullName == null || fullName.isEmpty()
                || email == null || email.isEmpty()
                || phoneNumber == null || phoneNumber.isEmpty()) {
            req.setAttribute("ERROR_PROFILE", "Please fill in all required profile fields.");
            forwardToProfile(req, resp, sessionUser);
            return;
        }

        if (fullName.length() > 100) {
            req.setAttribute("ERROR_PROFILE", "Full name cannot exceed 100 characters.");
            forwardToProfile(req, resp, sessionUser);
            return;
        }

        if (!email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            req.setAttribute("ERROR_PROFILE", "Please provide a valid email address.");
            forwardToProfile(req, resp, sessionUser);
            return;
        }

        if (!phoneNumber.matches("^(?:\\+84|0)[35789]\\d{8}$")) {
            req.setAttribute("ERROR_PROFILE", "Invalid Vietnamese phone number. Format: 03x, 05x, 07x, 08x, 09x (e.g. 0901234567 or +84901234567).");
            forwardToProfile(req, resp, sessionUser);
            return;
        }

        // Email uniqueness check
        AppUser checkEmailUser = userDAO.findByEmail(email);
        if (checkEmailUser != null && !checkEmailUser.getUserId().equalsIgnoreCase(sessionUser.getUserId())) {
            req.setAttribute("ERROR_PROFILE", "This email address is already in use by another account.");
            forwardToProfile(req, resp, sessionUser);
            return;
        }

        // IMMUTABLE ROLE PRINCIPLE: Only update personal contact info (fullName, email, phoneNumber).
        // RoleID, Status, and UserID CANNOT be altered by the user!
        boolean ok = userDAO.updateProfile(sessionUser.getUserId(), fullName, email, phoneNumber);

        if (ok) {
            sessionUser.setFullName(fullName);
            sessionUser.setEmail(email);
            sessionUser.setPhoneNumber(phoneNumber);
            req.getSession().setAttribute("user", sessionUser);

            AuditLogDAO.log(
                    sessionUser.getUserId(),
                    "UPDATE_PROFILE",
                    "tblUsers",
                    sessionUser.getUserId(),
                    null,
                    "Updated profile details: " + fullName + " (" + email + ")",
                    req.getRemoteAddr()
            );

            resp.sendRedirect(req.getContextPath() + "/profile?success=profile_updated");
        } else {
            req.setAttribute("ERROR_PROFILE", "Unable to update profile. Please try again.");
            forwardToProfile(req, resp, sessionUser);
        }
    }

    private void handleChangePassword(HttpServletRequest req, HttpServletResponse resp, AppUser sessionUser)
            throws ServletException, IOException {

        String oldPassword = req.getParameter("oldPassword");
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        if (oldPassword == null || oldPassword.isEmpty()
                || newPassword == null || newPassword.isEmpty()
                || confirmPassword == null || confirmPassword.isEmpty()) {
            req.setAttribute("ERROR_PASSWORD", "Please fill in all password fields.");
            forwardToProfile(req, resp, sessionUser);
            return;
        }

        // Fetch user from DB to verify old password
        AppUser dbUser = userDAO.findById(sessionUser.getUserId());
        if (dbUser == null || !PasswordUtil.verify(oldPassword, dbUser.getPassword())) {
            req.setAttribute("ERROR_PASSWORD", "Current password does not match our records.");
            forwardToProfile(req, resp, sessionUser);
            return;
        }

        if (newPassword.length() < 6) {
            req.setAttribute("ERROR_PASSWORD", "New password must be at least 6 characters long.");
            forwardToProfile(req, resp, sessionUser);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            req.setAttribute("ERROR_PASSWORD", "New password and confirmation do not match.");
            forwardToProfile(req, resp, sessionUser);
            return;
        }

        if (newPassword.equals(oldPassword)) {
            req.setAttribute("ERROR_PASSWORD", "New password must be different from your current password.");
            forwardToProfile(req, resp, sessionUser);
            return;
        }

        boolean ok = userDAO.resetPassword(sessionUser.getUserId(), newPassword);

        if (ok) {
            AuditLogDAO.log(
                    sessionUser.getUserId(),
                    "CHANGE_PASSWORD",
                    "tblUsers",
                    sessionUser.getUserId(),
                    null,
                    "Self-service password update successful",
                    req.getRemoteAddr()
            );

            resp.sendRedirect(req.getContextPath() + "/profile?success=password_updated");
        } else {
            req.setAttribute("ERROR_PASSWORD", "Failed to update password. Please try again.");
            forwardToProfile(req, resp, sessionUser);
        }
    }

    private void forwardToProfile(HttpServletRequest req, HttpServletResponse resp, AppUser sessionUser)
            throws ServletException, IOException {
        AppUser profileUser = userDAO.findById(sessionUser.getUserId());
        if (profileUser == null) {
            profileUser = sessionUser;
        }
        req.setAttribute("profileUser", profileUser);

        List<String> assignedAreaIds = userDAO.getAssignedAreaIds(profileUser.getUserId());
        List<Area> assignedAreas = new ArrayList<>();
        if (assignedAreaIds != null && !assignedAreaIds.isEmpty()) {
            for (String aid : assignedAreaIds) {
                Area a = areaDAO.findById(aid);
                if (a != null) {
                    assignedAreas.add(a);
                }
            }
        } else if (profileUser.getAreaId() != null && !profileUser.getAreaId().trim().isEmpty()) {
            Area a = areaDAO.findById(profileUser.getAreaId());
            if (a != null) {
                assignedAreas.add(a);
            }
        }
        req.setAttribute("assignedAreas", assignedAreas);

        req.getRequestDispatcher(PROFILE_PAGE).forward(req, resp);
    }
}
