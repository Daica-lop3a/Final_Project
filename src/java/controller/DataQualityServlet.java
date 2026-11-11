package controller;

import dao.DataQualityDAO;
import dao.DiscrepancyDAO;
import model.AppUser;
import model.AuditLog;
import model.BinInspection;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Controller for Data Quality Scanner & Anomaly Detection
 * Restricted to Auditor (AUD), Super Admin (SAD) and Admin (ADM).
 */
@WebServlet(urlPatterns = {"/data-quality", "/audit/data-quality"})
public class DataQualityServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/dataQuality.jsp";
    private static final String DENIED = "/WEB-INF/views/denied.jsp";

    private final DataQualityDAO dataQualityDAO = new DataQualityDAO();
    private final DiscrepancyDAO discrepancyDAO = new DiscrepancyDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        AppUser user = (session != null) ? (AppUser) session.getAttribute("user") : null;

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        if (!user.isAuditor() && !user.isSuperAdmin() && !user.isAdmin()) {
            req.getRequestDispatcher(DENIED).forward(req, resp);
            return;
        }

        // 1. Duplicate Collections within 30 mins
        List<Map<String, Object>> duplicateCollections = dataQualityDAO.getDuplicateCollections();

        // 2. Incomplete Collections
        List<Map<String, Object>> incompleteCollections = dataQualityDAO.getIncompleteCollections();

        // 3. High Sensor Deviations (>= 20%)
        List<BinInspection> sensorDeviations = dataQualityDAO.getHighSensorDeviations();

        // 4. Staff Anomaly Rankings
        List<Map<String, Object>> staffRankings = dataQualityDAO.getStaffAnomalyRankings();

        // 5. Device Anomaly Rankings
        List<Map<String, Object>> deviceRankings = dataQualityDAO.getDeviceAnomalyRankings();

        // 6. Threshold & System Config Audit Logs
        List<AuditLog> configLogs = dataQualityDAO.getConfigAuditLogs();

        int totalAnomalies = duplicateCollections.size() + incompleteCollections.size() + sensorDeviations.size();
        int openDiscrepancies = discrepancyDAO.countByStatus("Open");

        req.setAttribute("duplicateCollections", duplicateCollections);
        req.setAttribute("incompleteCollections", incompleteCollections);
        req.setAttribute("sensorDeviations", sensorDeviations);
        req.setAttribute("staffRankings", staffRankings);
        req.setAttribute("deviceRankings", deviceRankings);
        req.setAttribute("configLogs", configLogs);

        req.setAttribute("totalAnomalies", totalAnomalies);
        req.setAttribute("openDiscrepancies", openDiscrepancies);

        req.getRequestDispatcher(VIEW).forward(req, resp);
    }
}
