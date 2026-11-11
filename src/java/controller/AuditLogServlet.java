package controller;

import dao.AuditLogDAO;
import model.AppUser;
import model.AuditLog;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet displaying Security Audit Logs (tblAuditLogs)
 * Restricted to Super Admin (SAD), Admin (ADM) and Auditor (AUD)
 */
@WebServlet("/audit-log")
public class AuditLogServlet extends HttpServlet {

    private final AuditLogDAO auditDAO = new AuditLogDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        AppUser currentUser = (session != null) ? (AppUser) session.getAttribute("user") : null;

        // Allow Super Admin, Admin and Auditor access
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        if (!currentUser.isSuperAdmin() && !currentUser.isAuditor() && !currentUser.isAdmin()) {
            req.getRequestDispatcher("/WEB-INF/views/denied.jsp").forward(req, resp);
            return;
        }

        // Admin cannot view Super Admin security actions
        boolean excludeSuperAdmin = currentUser.isAdmin();

        String actionFilter = req.getParameter("action");
        String userFilter = req.getParameter("user");

        int page = 1;
        int pageSize = 15;
        try {
            if (req.getParameter("page") != null) {
                page = Math.max(1, Integer.parseInt(req.getParameter("page")));
            }
        } catch (NumberFormatException ignored) {}

        List<AuditLog> logs = auditDAO.getLogs(page, pageSize, actionFilter, userFilter, excludeSuperAdmin);
        int totalRecords = auditDAO.countLogs(actionFilter, userFilter, excludeSuperAdmin);
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);

        req.setAttribute("logs", logs);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalRecords", totalRecords);
        req.setAttribute("selectedAction", actionFilter);
        req.setAttribute("selectedUser", userFilter);

        req.getRequestDispatcher("/WEB-INF/views/auditLogList.jsp").forward(req, resp);
    }
}
