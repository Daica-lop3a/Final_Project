package controller;

import dao.AlertDAO;
import dao.AuditLogDAO;
import dao.CollectionDAO;
import dao.DataQualityDAO;
import dao.DiscrepancyDAO;
import dao.MaintenanceDAO;
import dao.NotificationDAO;
import dao.UserDAO;
import dao.WasteBinDAO;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import model.Alert;
import model.AppUser;
import model.CollectionRequest;
import model.Maintenance;
import model.WasteBin;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    private static final String DASHBOARD =
            "/WEB-INF/views/dashboard.jsp";

    private final MaintenanceDAO maintenanceDAO =
            new MaintenanceDAO();

    private final WasteBinDAO binDAO =
            new WasteBinDAO();

    private final CollectionDAO collectionDAO =
            new CollectionDAO();

    private final AlertDAO alertDAO =
            new AlertDAO();

    private final UserDAO userDAO =
            new UserDAO();

    private final NotificationDAO notificationDAO =
            new NotificationDAO();

    private final AuditLogDAO auditDAO =
            new AuditLogDAO();

    private final DiscrepancyDAO discrepancyDAO =
            new DiscrepancyDAO();

    private final DataQualityDAO dataQualityDAO =
            new DataQualityDAO();

    @Override
    protected void doGet(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        String url = DASHBOARD;

        try {
            // =================================================
            // CHECK LOGIN
            // =================================================
            HttpSession session = req.getSession(false);

            if (session == null
                    || !(session.getAttribute("user")
                    instanceof AppUser)) {

                url = "redirect:"
                        + req.getContextPath() + "/login";

            } else {
                AppUser user =
                        (AppUser) session.getAttribute("user");

                String role = user.getRoleId();
                String userID = user.getUserId();

                // =============================================
                // GET MANAGER / SUPERVISOR AREA(S)
                // =============================================
                List<String> managerAreaIDs = new ArrayList<String>();

                if ("MGR".equals(role) || "SUP".equals(role) || "STF".equals(role) || "TEC".equals(role)) {
                    try {
                        managerAreaIDs.addAll(userDAO.getAssignedAreaIds(userID));
                        AppUser manager = userDAO.findById(userID);
                        if (manager != null && manager.getAreaID() != null && !manager.getAreaID().trim().isEmpty()) {
                            String p = manager.getAreaID().trim();
                            if (!managerAreaIDs.contains(p)) {
                                managerAreaIDs.add(p);
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }

                // =============================================
                // WASTE BINS
                // =============================================
                List<WasteBin> binList;

                if ("MGR".equals(role) || "SUP".equals(role) || "STF".equals(role) || "TEC".equals(role)) {
                    if (managerAreaIDs.isEmpty()) {
                        binList = binDAO.getAll();
                    } else {
                        binList = new ArrayList<WasteBin>();
                        for (String aId : managerAreaIDs) {
                            binList.addAll(getBinsByArea(aId));
                        }
                    }
                } else {
                    binList = binDAO.getAll();
                }

                if (binList == null) {
                    binList = new ArrayList<WasteBin>();
                }

                int activeBins = 0;
                int fullBins = 0;
                int maintenanceBins = 0;

                int highFillCount = 0;
                for (WasteBin bin : binList) {
                    if (bin == null) {
                        continue;
                    }

                    if (bin.getCurrentFill() >= 80) {
                        highFillCount++;
                    }

                    String status = bin.getStatus();

                    if ("Active".equals(status)) {
                        activeBins++;
                    } else if ("Full".equals(status)) {
                        fullBins++;
                    } else if ("Maintenance".equals(status)) {
                        maintenanceBins++;
                    }
                }

                req.setAttribute("totalBins", binList.size());
                req.setAttribute("activeBins", activeBins);
                req.setAttribute("fullBins", fullBins);
                req.setAttribute("maintenanceBins", maintenanceBins);
                req.setAttribute("isAreaHotspot", highFillCount >= 2);
                req.setAttribute("hotspotBinCount", highFillCount);
                req.setAttribute("LIST_BIN", binList);

                // =============================================
                // COLLECTION REQUESTS
                // =============================================
                List<CollectionRequest> requestList;

                if ("STF".equals(role)) {
                    requestList =
                            collectionDAO.getByStaff(userID);

                } else if ("MGR".equals(role) || "SUP".equals(role)) {
                    requestList =
                            collectionDAO.getByManager(userID);

                } else {
                    requestList =
                            collectionDAO.getAll();
                }

                if (requestList == null) {
                    requestList =
                            new ArrayList<CollectionRequest>();
                }

                int pendingRequests = 0;
                int inProgressRequests = 0;
                int completedRequests = 0;
                int overdueRequests = 0;

                for (CollectionRequest collection : requestList) {
                    if (collection == null) {
                        continue;
                    }

                    String status = collection.getStatus();

                    if ("Pending".equals(status)) {
                        pendingRequests++;
                    } else if ("In_Progress".equals(status)) {
                        inProgressRequests++;
                    } else if ("Completed".equals(status) || "Verified".equals(status)) {
                        completedRequests++;
                    }

                    if (collection.isOverdue() && ("Pending".equals(status) || "In_Progress".equals(status))) {
                        overdueRequests++;
                    }
                }

                req.setAttribute(
                        "totalRequests", requestList.size());

                req.setAttribute(
                        "pendingRequests", pendingRequests);

                req.setAttribute(
                        "inProgressRequests", inProgressRequests);

                req.setAttribute(
                        "completedRequests", completedRequests);

                req.setAttribute(
                        "overdueRequests", overdueRequests);

                // =============================================
                // MAINTENANCE
                // =============================================
                List<Maintenance> maintenanceList;

                if ("TEC".equals(role)) {
                    maintenanceList =
                            maintenanceDAO.getByTechnician(userID);

                } else if ("MGR".equals(role) || "SUP".equals(role)) {
                    maintenanceList =
                            maintenanceDAO.getByManager(userID);

                } else {
                    maintenanceList =
                            maintenanceDAO.getAll();
                }

                if (maintenanceList == null) {
                    maintenanceList =
                            new ArrayList<Maintenance>();
                }

                int pendingMaintenance = 0;
                int inProgressMaintenance = 0;
                int completedMaintenance = 0;

                for (Maintenance maintenance : maintenanceList) {
                    if (maintenance == null) {
                        continue;
                    }

                    String status = maintenance.getStatus();

                    if ("Pending".equals(status)) {
                        pendingMaintenance++;
                    } else if ("In_Progress".equals(status)) {
                        inProgressMaintenance++;
                    } else if ("Completed".equals(status)) {
                        completedMaintenance++;
                    }
                }

                req.setAttribute(
                        "totalMaintenance", maintenanceList.size());

                req.setAttribute(
                        "pendingMaintenance", pendingMaintenance);

                req.setAttribute(
                        "inProgressMaintenance", inProgressMaintenance);

                req.setAttribute(
                        "completedMaintenance", completedMaintenance);

                // =============================================
                // ALERTS
                // =============================================
                List<Alert> alertList;

                if ("ADM".equals(role) || "SAD".equals(role)) {
                    alertList = alertDAO.getAll();

                } else if ("MGR".equals(role) || "SUP".equals(role) || "STF".equals(role) || "TEC".equals(role)) {
                    if (managerAreaIDs.isEmpty()) {
                        alertList = alertDAO.getAll();
                    } else {
                        alertList = new ArrayList<Alert>();
                        for (String aId : managerAreaIDs) {
                            alertList.addAll(getAlertsByArea(aId));
                        }
                    }

                } else {
                    alertList = alertDAO.getByRecipient(userID);
                }

                if (alertList == null) {
                    alertList = new ArrayList<Alert>();
                }

                int unresolvedAlerts = 0;

                for (Alert alert : alertList) {
                    if (alert != null && !alert.isResolved()) {
                        unresolvedAlerts++;
                    }
                }

                req.setAttribute(
                        "totalAlerts", alertList.size());

                req.setAttribute(
                        "unresolvedAlerts", unresolvedAlerts);

                // =============================================
                // UNREAD NOTIFICATIONS
                // =============================================
                req.setAttribute(
                        "unreadNotifications",
                        notificationDAO.countUnread(userID));

                // =============================================
                // AUDITOR INTELLIGENCE & QUALITY METRICS
                // =============================================
                if ("AUD".equals(role) || "SAD".equals(role)) {
                    try {
                        req.setAttribute("AUDIT_TOTAL_LOGS", auditDAO.countLogs(null, null, false));
                        req.setAttribute("AUDIT_DISCREPANCY_TOTAL", discrepancyDAO.countTotal());
                        req.setAttribute("AUDIT_DISCREPANCY_OPEN", discrepancyDAO.countByStatus("Open"));
                        req.setAttribute("AUDIT_QUALITY_ANOMALIES", dataQualityDAO.countTotalDataQualityAnomalies());
                        req.setAttribute("RECENT_DISCREPANCIES", discrepancyDAO.getRecent(5));
                    } catch (Exception e) {
                        log("Error loading auditor metrics", e);
                    }
                }
            }

        } catch (SQLException e) {
            log("Database error in DashboardServlet", e);

            req.setAttribute(
                    "ERROR",
                    "Unable to load dashboard data.");

        } catch (Exception e) {
            log("Unexpected error in DashboardServlet", e);

            req.setAttribute(
                    "ERROR",
                    "An unexpected error occurred while loading the dashboard.");
        }

        // =====================================================
        // NAVIGATION
        // =====================================================
        if (!resp.isCommitted()) {
            if (url.startsWith("redirect:")) {
                resp.sendRedirect(
                        url.substring("redirect:".length()));
            } else {
                req.getRequestDispatcher(url)
                        .forward(req, resp);
            }
        }
    }

    // =========================================================
    // GET WASTE BINS BY AREA
    // =========================================================
    private List<WasteBin> getBinsByArea(String areaID)
            throws SQLException {

        List<WasteBin> result =
                new ArrayList<WasteBin>();

        if (areaID == null || areaID.trim().isEmpty()) {
            return result;
        }

        List<WasteBin> allBins = binDAO.getAll();

        if (allBins == null) {
            return result;
        }

        for (WasteBin bin : allBins) {
            if (bin == null || bin.getAreaID() == null) {
                continue;
            }

            if (areaID.equalsIgnoreCase(
                    bin.getAreaID().trim())) {

                result.add(bin);
            }
        }

        return result;
    }

    // =========================================================
    // GET ALERTS BY AREA
    // =========================================================
    private List<Alert> getAlertsByArea(String areaID)
            throws SQLException {

        List<Alert> result =
                new ArrayList<Alert>();

        if (areaID == null || areaID.trim().isEmpty()) {
            return result;
        }

        List<Alert> allAlerts = alertDAO.getAll();

        if (allAlerts == null) {
            return result;
        }

        for (Alert alert : allAlerts) {
            if (alert == null || alert.getBinID() == null) {
                continue;
            }

            WasteBin bin =
                    binDAO.findByID(alert.getBinID());

            if (bin != null
                    && bin.getAreaID() != null
                    && areaID.equalsIgnoreCase(
                            bin.getAreaID().trim())) {

                result.add(alert);
            }
        }

        return result;
    }
}
