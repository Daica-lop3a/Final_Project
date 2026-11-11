package controller;

import dao.AreaDAO;
import dao.AuditLogDAO;
import dao.CitizenReportDAO;
import dao.NotificationDAO;
import dao.WasteBinDAO;
import model.AppUser;
import model.Area;
import model.CitizenReport;

import model.WasteBin;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Controller for Citizen Reports and Feedback workflows:
 * - User: Submit reports, edit pending reports, cancel, rate resolution, track status
 * - Supervisor/Manager: View area reports, verify and transition status
 */
@WebServlet({"/citizen-report", "/citizen-report/*", "/feedback", "/feedback/*"})
public class CitizenReportServlet extends HttpServlet {

    private final CitizenReportDAO reportDAO = new CitizenReportDAO();
    private final WasteBinDAO binDAO = new WasteBinDAO();
    private final AreaDAO areaDAO = new AreaDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        AppUser currentUser = (session != null) ? (AppUser) session.getAttribute("user") : null;

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String pathInfo = req.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            handleList(req, resp, currentUser);
        } else if (pathInfo.equals("/create")) {
            handleShowCreate(req, resp, currentUser);
        } else if (pathInfo.equals("/detail") || pathInfo.equals("/view")) {
            handleShowDetail(req, resp, currentUser);
        } else if (pathInfo.equals("/edit")) {
            handleShowEdit(req, resp, currentUser);
        } else {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        AppUser currentUser = (session != null) ? (AppUser) session.getAttribute("user") : null;

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String pathInfo = req.getPathInfo();
        if ("/save".equals(pathInfo)) {
            handleSaveReport(req, resp, currentUser);
        } else if ("/update".equals(pathInfo)) {
            handleUpdateReport(req, resp, currentUser);
        } else if ("/cancel".equals(pathInfo)) {
            handleCancelReport(req, resp, currentUser);
        } else if ("/rate".equals(pathInfo)) {
            handleRateReport(req, resp, currentUser);
        } else if ("/verify".equals(pathInfo)) {
            handleVerifyReport(req, resp, currentUser);
        } else {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // Display reports list
    private void handleList(HttpServletRequest req, HttpServletResponse resp, AppUser currentUser)
            throws ServletException, IOException {

        String statusFilter = req.getParameter("status");
        String areaID = req.getParameter("areaID");

        if (currentUser.isCitizen()) {
        // Citizens only view their own submitted reports
            List<CitizenReport> myReports = reportDAO.getReportsByCitizen(currentUser.getUserId());
            req.setAttribute("reports", myReports);
        } else {
        // Management / Supervisor view area reports
            int page = 1;
            int pageSize = 10;
            try {
                if (req.getParameter("page") != null) {
                    page = Math.max(1, Integer.parseInt(req.getParameter("page")));
                }
            } catch (NumberFormatException ignored) {}

        // Scope by assigned area if supervisor or staff
            if ((currentUser.isSupervisor() || currentUser.isStaff()) && (areaID == null || areaID.isEmpty())) {
                areaID = currentUser.getAreaID();
            }

            List<CitizenReport> reports = reportDAO.getReports(areaID, statusFilter, page, pageSize);
            int total = reportDAO.countReports(areaID, statusFilter);
            int totalPages = (int) Math.ceil((double) total / pageSize);

            req.setAttribute("reports", reports);
            req.setAttribute("currentPage", page);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("selectedStatus", statusFilter);
            req.setAttribute("selectedArea", areaID);
            req.setAttribute("areas", areaDAO.getAll());
        }

        req.getRequestDispatcher("/WEB-INF/views/citizenReportList.jsp").forward(req, resp);
    }

    // Display new report form
    private void handleShowCreate(HttpServletRequest req, HttpServletResponse resp, AppUser currentUser)
            throws ServletException, IOException {

        String binID = req.getParameter("binID");
        List<WasteBin> bins = binDAO.getAll();
        List<Area> areas = areaDAO.getAll();

        req.setAttribute("bins", bins);
        req.setAttribute("areas", areas);
        req.setAttribute("preselectedBin", binID);
        req.setAttribute("isEdit", false);
        // Provide next sequential report ID for form preview
        req.setAttribute("NEXT_REPORT_ID", util.IdGenerator.nextCitizenReportId());

        req.getRequestDispatcher("/WEB-INF/views/citizenReportForm.jsp").forward(req, resp);
    }

    // Display edit report form when status is Pending/Submitted
    private void handleShowEdit(HttpServletRequest req, HttpServletResponse resp, AppUser currentUser)
            throws ServletException, IOException {

        String reportID = req.getParameter("id");
        if (reportID == null || reportID.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/citizen-report");
            return;
        }

        CitizenReport report = reportDAO.getReportById(reportID);
        if (report == null || !currentUser.getUserId().equals(report.getCitizenID())) {
            req.getRequestDispatcher("/WEB-INF/views/denied.jsp").forward(req, resp);
            return;
        }

        if (!report.isEditable()) {
            resp.sendRedirect(req.getContextPath() + "/citizen-report/detail?id=" + reportID + "&error=cannot_edit_processed");
            return;
        }

        List<WasteBin> bins = binDAO.getAll();
        List<Area> areas = areaDAO.getAll();

        req.setAttribute("report", report);
        req.setAttribute("bins", bins);
        req.setAttribute("areas", areas);
        req.setAttribute("preselectedBin", report.getBinID());
        req.setAttribute("isEdit", true);

        req.getRequestDispatcher("/WEB-INF/views/citizenReportForm.jsp").forward(req, resp);
    }

    // View report details
    private void handleShowDetail(HttpServletRequest req, HttpServletResponse resp, AppUser currentUser)
            throws ServletException, IOException {

        String reportID = req.getParameter("id");
        if (reportID == null || reportID.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/citizen-report");
            return;
        }

        CitizenReport report = reportDAO.getReportById(reportID);
        if (report == null) {
            resp.sendRedirect(req.getContextPath() + "/citizen-report");
            return;
        }

        // Citizens only view their own submitted reports
        if (currentUser.isCitizen() && !currentUser.getUserId().equals(report.getCitizenID())) {
            req.getRequestDispatcher("/WEB-INF/views/denied.jsp").forward(req, resp);
            return;
        }

        req.setAttribute("report", report);
        req.getRequestDispatcher("/WEB-INF/views/citizenReportDetail.jsp").forward(req, resp);
    }

    // X l gi phn nh mi
    private void handleSaveReport(HttpServletRequest req, HttpServletResponse resp, AppUser currentUser)
            throws IOException {

        String binID = req.getParameter("binID");
        String areaID = req.getParameter("areaID");
        String reportType = req.getParameter("reportType");
        String title = req.getParameter("title");
        String description = req.getParameter("description");
        String imageURL = req.getParameter("imageURL");
        String latStr = req.getParameter("latitude");
        String lngStr = req.getParameter("longitude");

        if (title == null || title.trim().isEmpty() || description == null || description.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/citizen-report/create?error=empty_fields");
            return;
        }

        // Generate next sequential report ID (e.g. REP-003, REP-004)
        String reportID = util.IdGenerator.nextCitizenReportId();
        CitizenReport report = new CitizenReport();
        report.setReportID(reportID);
        report.setCitizenID(currentUser.getUserId());
        report.setBinID(binID);
        report.setAreaID(areaID);
        report.setReportType(reportType != null ? reportType : "OTHER");
        report.setTitle(title.trim());
        report.setDescription(description.trim());
        report.setImageURL(imageURL);
        report.setStatus("Submitted");

        try {
            if (latStr != null && !latStr.trim().isEmpty()) {
                report.setLatitude(Double.parseDouble(latStr.trim()));
            }
            if (lngStr != null && !lngStr.trim().isEmpty()) {
                report.setLongitude(Double.parseDouble(lngStr.trim()));
            }
        } catch (NumberFormatException ignored) {}

        boolean success = reportDAO.createReport(report);
        if (success) {
            // Ghi Audit Log
            AuditLogDAO.log(currentUser.getUserId(), "CITIZEN_REPORT_CREATE", "tblCitizenReports",
                    reportID, null, "title=" + title, req.getRemoteAddr());

            resp.sendRedirect(req.getContextPath() + "/citizen-report?msg=created");
        } else {
            resp.sendRedirect(req.getContextPath() + "/citizen-report/create?error=failed");
        }
    }

    // X l cp nht phn nh (khi cn  Submitted/Pending)
    private void handleUpdateReport(HttpServletRequest req, HttpServletResponse resp, AppUser currentUser)
            throws IOException {

        String reportID = req.getParameter("reportID");
        String binID = req.getParameter("binID");
        String areaID = req.getParameter("areaID");
        String reportType = req.getParameter("reportType");
        String title = req.getParameter("title");
        String description = req.getParameter("description");
        String imageURL = req.getParameter("imageURL");
        String latStr = req.getParameter("latitude");
        String lngStr = req.getParameter("longitude");

        if (reportID == null || title == null || title.trim().isEmpty() || description == null || description.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/citizen-report?error=empty_fields");
            return;
        }

        CitizenReport old = reportDAO.getReportById(reportID);
        if (old == null || !currentUser.getUserId().equals(old.getCitizenID()) || !old.isEditable()) {
            resp.sendRedirect(req.getContextPath() + "/citizen-report?error=cannot_edit");
            return;
        }

        CitizenReport report = new CitizenReport();
        report.setReportID(reportID);
        report.setCitizenID(currentUser.getUserId());
        report.setBinID(binID);
        report.setAreaID(areaID);
        report.setReportType(reportType != null ? reportType : "OTHER");
        report.setTitle(title.trim());
        report.setDescription(description.trim());
        report.setImageURL(imageURL);

        try {
            if (latStr != null && !latStr.trim().isEmpty()) {
                report.setLatitude(Double.parseDouble(latStr.trim()));
            }
            if (lngStr != null && !lngStr.trim().isEmpty()) {
                report.setLongitude(Double.parseDouble(lngStr.trim()));
            }
        } catch (NumberFormatException ignored) {}

        boolean success = reportDAO.updateReport(report);
        if (success) {
            AuditLogDAO.log(currentUser.getUserId(), "CITIZEN_REPORT_UPDATE", "tblCitizenReports",
                    reportID, "oldTitle=" + old.getTitle(), "newTitle=" + title, req.getRemoteAddr());

            resp.sendRedirect(req.getContextPath() + "/citizen-report/detail?id=" + reportID + "&msg=updated");
        } else {
            resp.sendRedirect(req.getContextPath() + "/citizen-report/edit?id=" + reportID + "&error=failed");
        }
    }

    // X l hy phn nh (khi cn  Submitted/Pending)
    private void handleCancelReport(HttpServletRequest req, HttpServletResponse resp, AppUser currentUser)
            throws IOException {

        String reportID = req.getParameter("reportID");
        if (reportID == null || reportID.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/citizen-report");
            return;
        }

        boolean success = reportDAO.cancelReport(reportID, currentUser.getUserId());
        if (success) {
            AuditLogDAO.log(currentUser.getUserId(), "CITIZEN_REPORT_CANCEL", "tblCitizenReports",
                    reportID, null, "Cancelled by citizen", req.getRemoteAddr());

            resp.sendRedirect(req.getContextPath() + "/citizen-report?msg=cancelled");
        } else {
            resp.sendRedirect(req.getContextPath() + "/citizen-report/detail?id=" + reportID + "&error=cancel_failed");
        }
    }

        // Process citizen rating after resolution
    private void handleRateReport(HttpServletRequest req, HttpServletResponse resp, AppUser currentUser)
            throws IOException {

        String reportID = req.getParameter("reportID");
        String ratingStr = req.getParameter("rating");
        String ratingComment = req.getParameter("ratingComment");

        int rating = 5;
        try {
            if (ratingStr != null) {
                rating = Math.max(1, Math.min(5, Integer.parseInt(ratingStr.trim())));
            }
        } catch (NumberFormatException ignored) {}

        boolean success = reportDAO.rateReport(reportID, currentUser.getUserId(), rating, ratingComment);
        if (success) {
            AuditLogDAO.log(currentUser.getUserId(), "CITIZEN_REPORT_RATE", "tblCitizenReports",
                    reportID, null, "rating=" + rating + ", comment=" + ratingComment, req.getRemoteAddr());

            resp.sendRedirect(req.getContextPath() + "/citizen-report/detail?id=" + reportID + "&msg=rated");
        } else {
            resp.sendRedirect(req.getContextPath() + "/citizen-report/detail?id=" + reportID + "&error=rate_failed");
        }
    }

        // Process report verification and status update
    private void handleVerifyReport(HttpServletRequest req, HttpServletResponse resp, AppUser currentUser)
            throws IOException {

        if (currentUser.isCitizen() || currentUser.isStaff() || currentUser.isTechnician() || currentUser.isAuditor()) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String reportID = req.getParameter("reportID");
        String newStatus = req.getParameter("status"); // Under Review, Assigned, Resolved, Rejected, Verified
        String feedbackNote = req.getParameter("feedbackNote");

        if (reportID == null || newStatus == null) {
            resp.sendRedirect(req.getContextPath() + "/citizen-report");
            return;
        }

        CitizenReport oldReport = reportDAO.getReportById(reportID);
        boolean success = reportDAO.verifyReport(reportID, currentUser.getUserId(), newStatus, feedbackNote);

        if (success && oldReport != null) {
            // Ghi Audit Log
            AuditLogDAO.log(currentUser.getUserId(), "VERIFY_REPORT", "tblCitizenReports",
                    reportID, "status=" + oldReport.getStatus(), "status=" + newStatus, req.getRemoteAddr());

            // Dispatch notification to the reporting citizen
            try {
                notificationDAO.insert(oldReport.getCitizenID(), "CITIZEN_REPORT", reportID,
                        "Your feedback report '" + oldReport.getTitle() + "' status has changed to: " + newStatus);
            } catch (Exception ignored) {}

            resp.sendRedirect(req.getContextPath() + "/citizen-report/detail?id=" + reportID + "&msg=updated");
        } else {
            resp.sendRedirect(req.getContextPath() + "/citizen-report?error=failed");
        }
    }
}
