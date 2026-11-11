package controller;

import dao.AdminPasswordRequestDAO;
import dao.AuditLogDAO;
import dao.UserDAO;
import model.AdminPasswordRequest;
import model.AppUser;

import java.io.IOException;
import java.security.SecureRandom;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Super Admin Approval Module and Password Management.
 */
@WebServlet("/admin-approval")
public class AdminApprovalServlet extends HttpServlet {

    private final AdminPasswordRequestDAO requestDAO = new AdminPasswordRequestDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        AppUser currentUser = (session != null) ? (AppUser) session.getAttribute("user") : null;

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        if (!currentUser.isSuperAdmin() && !currentUser.isAdmin()) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        List<AdminPasswordRequest> list = requestDAO.getAllRequests();
        req.setAttribute("REQUEST_LIST", list);

        String msg = req.getParameter("msg");
        if ("approved".equals(msg)) {
            String temp = req.getParameter("temp");
            req.setAttribute("SUCCESS_MSG", "Admin password request approved! Generated Temporary Password: " + (temp != null ? temp : ""));
        } else if ("rejected".equals(msg)) {
            req.setAttribute("SUCCESS_MSG", "Admin password request has been rejected.");
        } else if ("requested".equals(msg)) {
            req.setAttribute("SUCCESS_MSG", "Your password reset request has been submitted to Super Admin for approval.");
        }

        req.getRequestDispatcher("/WEB-INF/views/adminApprovalList.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        AppUser currentUser = (session != null) ? (AppUser) session.getAttribute("user") : null;

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");

        // Action 1: Admin submits a password request to Super Admin
        if ("request".equals(action)) {
            String reason = req.getParameter("reason");
            if (reason == null || reason.trim().isEmpty()) {
                reason = "Admin requested password reset via authority channel.";
            }

            requestDAO.createRequest(currentUser.getUserId(), reason);

            AuditLogDAO.log(
                    currentUser.getUserId(),
                    "ADMIN_PASSWORD_REQUEST",
                    "tblAdminPasswordRequests",
                    currentUser.getUserId(),
                    null,
                    "Admin requested password reset approval: " + reason,
                    req.getRemoteAddr()
            );

            resp.sendRedirect(req.getContextPath() + "/profile?msg=request_submitted");
            return;
        }

        // Only Super Admin can approve or reject
        if (!currentUser.isSuperAdmin()) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        int requestId = 0;
        try {
            requestId = Integer.parseInt(req.getParameter("requestId"));
        } catch (Exception ignored) {
        }

        if (requestId <= 0) {
            resp.sendRedirect(req.getContextPath() + "/admin-approval");
            return;
        }

        AdminPasswordRequest targetReq = requestDAO.findById(requestId);
        if (targetReq == null) {
            resp.sendRedirect(req.getContextPath() + "/admin-approval");
            return;
        }

        String note = req.getParameter("note");

        if ("approve".equals(action)) {
            // Generate a secure temporary password
            int randomNum = 100000 + new SecureRandom().nextInt(900000);
            String tempPassword = "Admin@" + randomNum;

            // Update Admin password in tblUsers
            userDAO.resetPassword(targetReq.getAdminId(), tempPassword);

            // Record approval in database
            requestDAO.approve(requestId, currentUser.getUserId(), tempPassword, note);

            AuditLogDAO.log(
                    currentUser.getUserId(),
                    "ADMIN_PASSWORD_APPROVED",
                    "tblAdminPasswordRequests",
                    String.valueOf(requestId),
                    "Pending",
                    "Approved password reset for " + targetReq.getAdminId() + ". Generated temp password.",
                    req.getRemoteAddr()
            );

            resp.sendRedirect(req.getContextPath() + "/admin-approval?msg=approved&temp=" + tempPassword);
            return;

        } else if ("reject".equals(action)) {
            requestDAO.reject(requestId, currentUser.getUserId(), note);

            AuditLogDAO.log(
                    currentUser.getUserId(),
                    "ADMIN_PASSWORD_REJECTED",
                    "tblAdminPasswordRequests",
                    String.valueOf(requestId),
                    "Pending",
                    "Rejected password reset request for " + targetReq.getAdminId() + ": " + note,
                    req.getRemoteAddr()
            );

            resp.sendRedirect(req.getContextPath() + "/admin-approval?msg=rejected");
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/admin-approval");
    }
}
