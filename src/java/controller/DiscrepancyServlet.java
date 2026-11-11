package controller;

import dao.AuditLogDAO;
import dao.DiscrepancyDAO;
import model.AppUser;
import model.Discrepancy;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Controller for Audit Discrepancy Case Management (tblDiscrepancies)
 * Restricted to Auditor (AUD) and Super Admin (SAD).
 */
@WebServlet(urlPatterns = {
    "/discrepancy",
    "/discrepancy/view",
    "/discrepancy/create",
    "/discrepancy/save",
    "/discrepancy/investigate",
    "/discrepancy/close"
})
public class DiscrepancyServlet extends HttpServlet {

    private static final String LIST_VIEW = "/WEB-INF/views/discrepancyList.jsp";
    private static final String DETAIL_VIEW = "/WEB-INF/views/discrepancyDetail.jsp";
    private static final String FORM_VIEW = "/WEB-INF/views/discrepancyForm.jsp";
    private static final String DENIED = "/WEB-INF/views/denied.jsp";

    private final DiscrepancyDAO discrepancyDAO = new DiscrepancyDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        AppUser user = getCurrentUser(req);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Auditor, Super Admin and Admin have read permissions
        if (!user.isAuditor() && !user.isSuperAdmin() && !user.isAdmin()) {
            req.getRequestDispatcher(DENIED).forward(req, resp);
            return;
        }

        String path = req.getServletPath();
        if ("/discrepancy/create".equals(path)) {
        // Only Auditor and Super Admin can open new investigations
            if (!user.isAuditor() && !user.isSuperAdmin()) {
                req.setAttribute("ERROR", "Only Auditor or Super Admin can create discrepancy findings.");
                req.getRequestDispatcher(DENIED).forward(req, resp);
                return;
            }
            showCreateForm(req, resp);
        } else if ("/discrepancy/view".equals(path)) {
            showDetail(req, resp);
        } else {
            showList(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        AppUser user = getCurrentUser(req);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Only Auditor and Super Admin can modify discrepancy cases
        if (!user.isAuditor() && !user.isSuperAdmin()) {
            req.setAttribute("ERROR", "Only Auditor or Super Admin can record or update discrepancy cases.");
            req.getRequestDispatcher(DENIED).forward(req, resp);
            return;
        }

        String path = req.getServletPath();
        if ("/discrepancy/save".equals(path)) {
            saveDiscrepancy(req, resp, user);
        } else if ("/discrepancy/investigate".equals(path)) {
            updateInvestigation(req, resp, user);
        } else if ("/discrepancy/close".equals(path)) {
            closeCase(req, resp, user);
        } else {
            resp.sendRedirect(req.getContextPath() + "/discrepancy");
        }
    }

    // ==========================================
    // 1. HIN TH DANH SCH H S SAI LCH
    // ==========================================
    private void showList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String type = req.getParameter("type");
        String status = req.getParameter("status");
        String severity = req.getParameter("severity");
        String search = req.getParameter("search");

        int page = 1;
        int pageSize = 15;
        try {
            if (req.getParameter("page") != null) {
                page = Math.max(1, Integer.parseInt(req.getParameter("page")));
            }
        } catch (NumberFormatException ignored) {}

        List<Discrepancy> list = discrepancyDAO.getFiltered(type, status, severity, search, page, pageSize);
        int totalRecords = discrepancyDAO.countFiltered(type, status, severity, search);
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);

        int totalCount = discrepancyDAO.countTotal();
        int openCount = discrepancyDAO.countByStatus("Open");
        int investigatingCount = discrepancyDAO.countByStatus("Investigating");
        int resolvedCount = discrepancyDAO.countByStatus("Resolved");
        int closedCount = discrepancyDAO.countByStatus("Closed");

        req.setAttribute("discrepancies", list);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalRecords", totalRecords);
        req.setAttribute("selectedType", type);
        req.setAttribute("selectedStatus", status);
        req.setAttribute("selectedSeverity", severity);
        req.setAttribute("searchKeyword", search);

        req.setAttribute("totalCount", totalCount);
        req.setAttribute("openCount", openCount);
        req.setAttribute("investigatingCount", investigatingCount);
        req.setAttribute("resolvedCount", resolvedCount);
        req.setAttribute("closedCount", closedCount);

        req.getRequestDispatcher(LIST_VIEW).forward(req, resp);
    }

    // ==========================================
        // 2. Display case details
    // ==========================================
    private void showDetail(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String id = req.getParameter("id");
        if (id == null || id.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/discrepancy");
            return;
        }

        Discrepancy d = discrepancyDAO.getByID(id.trim());
        if (d == null) {
            req.setAttribute("ERROR", "Discrepancy record not found: " + id);
            resp.sendRedirect(req.getContextPath() + "/discrepancy");
            return;
        }

        req.setAttribute("discrepancy", d);
        req.getRequestDispatcher(DETAIL_VIEW).forward(req, resp);
    }

    // ==========================================
        // 3. Display new case form
    // ==========================================
    private void showCreateForm(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Prefill parameters from Data Quality Scanner
        String targetEntity = req.getParameter("targetEntity");
        String targetID = req.getParameter("targetID");
        String discrepancyType = req.getParameter("type");
        String title = req.getParameter("title");
        String desc = req.getParameter("description");
        String severity = req.getParameter("severity");

        req.setAttribute("targetEntity", targetEntity != null ? targetEntity : "Collection");
        req.setAttribute("targetID", targetID);
        req.setAttribute("discrepancyType", discrepancyType != null ? discrepancyType : "Collection_Mismatch");
        req.setAttribute("title", title);
        req.setAttribute("description", desc);
        req.setAttribute("severity", severity != null ? severity : "Medium");
        req.setAttribute("NEXT_DISCREPANCY_ID", util.IdGenerator.nextDiscrepancyId());

        req.getRequestDispatcher(FORM_VIEW).forward(req, resp);
    }

    // ==========================================
        // 4. Save new discrepancy case
    // ==========================================
    private void saveDiscrepancy(HttpServletRequest req, HttpServletResponse resp, AppUser user)
            throws ServletException, IOException {
        String title = req.getParameter("title");
        String discrepancyType = req.getParameter("discrepancyType");
        String targetEntity = req.getParameter("targetEntity");
        String targetID = req.getParameter("targetID");
        String severity = req.getParameter("severity");
        String description = req.getParameter("description");
        String investigationNotes = req.getParameter("investigationNotes");

        if (title == null || title.trim().isEmpty() || discrepancyType == null || targetEntity == null) {
            req.setAttribute("ERROR", "Title, Type, and Target Entity are mandatory fields.");
            showCreateForm(req, resp);
            return;
        }

        // Generate next sequential discrepancy ID (e.g. DISC-002)
        String id = util.IdGenerator.nextDiscrepancyId();

        Discrepancy d = new Discrepancy();
        d.setDiscrepancyID(id);
        d.setTitle(title.trim());
        d.setDiscrepancyType(discrepancyType.trim());
        d.setTargetEntity(targetEntity.trim());
        d.setTargetID(targetID != null ? targetID.trim() : "");
        d.setSeverity(severity != null ? severity.trim() : "Medium");
        d.setStatus("Open");
        d.setDetectedBy(user.getUserId());
        d.setDescription(description);
        d.setInvestigationNotes(investigationNotes);

        boolean success = discrepancyDAO.create(d);
        if (success) {
            AuditLogDAO.log(
                    user.getUserId(),
                    "CREATE_DISCREPANCY",
                    "tblDiscrepancies",
                    id,
                    null,
                    "Logged audit discrepancy finding: " + title + " (" + discrepancyType + ")",
                    req.getRemoteAddr()
            );
            resp.sendRedirect(req.getContextPath() + "/discrepancy/view?id=" + id + "&msg=created");
        } else {
            req.setAttribute("ERROR", "Failed to save discrepancy finding to database.");
            showCreateForm(req, resp);
        }
    }

    // ==========================================
        // 5. Update investigation progress
    // ==========================================
    private void updateInvestigation(HttpServletRequest req, HttpServletResponse resp, AppUser user)
            throws ServletException, IOException {
        String id = req.getParameter("discrepancyID");
        String status = req.getParameter("status");
        String severity = req.getParameter("severity");
        String investigationNotes = req.getParameter("investigationNotes");

        if (id == null || id.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/discrepancy");
            return;
        }

        Discrepancy d = discrepancyDAO.getByID(id.trim());
        if (d == null) {
            resp.sendRedirect(req.getContextPath() + "/discrepancy");
            return;
        }

        if (status != null && !status.trim().isEmpty()) {
            d.setStatus(status.trim());
        }
        if (severity != null && !severity.trim().isEmpty()) {
            d.setSeverity(severity.trim());
        }
        if (investigationNotes != null) {
            d.setInvestigationNotes(investigationNotes.trim());
        }

        boolean success = discrepancyDAO.update(d);
        if (success) {
            AuditLogDAO.log(
                    user.getUserId(),
                    "UPDATE_DISCREPANCY",
                    "tblDiscrepancies",
                    id,
                    d.getStatus(),
                    "Updated investigation status to " + status + " for case " + id,
                    req.getRemoteAddr()
            );
            resp.sendRedirect(req.getContextPath() + "/discrepancy/view?id=" + id + "&msg=updated");
        } else {
            resp.sendRedirect(req.getContextPath() + "/discrepancy/view?id=" + id + "&error=update_failed");
        }
    }

    // ==========================================
        // 6. Close discrepancy case
    // ==========================================
    private void closeCase(HttpServletRequest req, HttpServletResponse resp, AppUser user)
            throws ServletException, IOException {
        String id = req.getParameter("discrepancyID");
        String conclusionNotes = req.getParameter("conclusionNotes");

        if (id == null || id.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/discrepancy");
            return;
        }

        if (conclusionNotes == null || conclusionNotes.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/discrepancy/view?id=" + id + "&error=empty_conclusion");
            return;
        }

        boolean success = discrepancyDAO.closeCase(id.trim(), conclusionNotes.trim(), user.getUserId());
        if (success) {
            AuditLogDAO.log(
                    user.getUserId(),
                    "CLOSE_DISCREPANCY",
                    "tblDiscrepancies",
                    id,
                    "Open/Investigating",
                    "Concluded and closed discrepancy audit case " + id,
                    req.getRemoteAddr()
            );
            resp.sendRedirect(req.getContextPath() + "/discrepancy/view?id=" + id + "&msg=closed");
        } else {
            resp.sendRedirect(req.getContextPath() + "/discrepancy/view?id=" + id + "&error=close_failed");
        }
    }

    private AppUser getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return (session != null) ? (AppUser) session.getAttribute("user") : null;
    }
}
