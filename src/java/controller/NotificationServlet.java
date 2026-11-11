package controller;

import dao.CollectionDAO;
import dao.NotificationDAO;
import dao.UserDAO;
import dao.WasteBinDAO;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.AppUser;
import model.CollectionRequest;
import model.WasteBin;
import util.Web;

/**
 * Notification Center Controller
 * Manages user notifications and surfaces real-time operational capacity/SLA alerts.
 */
@WebServlet({"/notification", "/notification/*"})
public class NotificationServlet extends HttpServlet {

    private final NotificationDAO notifications = new NotificationDAO();
    private final WasteBinDAO binDAO = new WasteBinDAO();
    private final CollectionDAO collectionDAO = new CollectionDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        AppUser user = Web.currentUser(req);

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String userID = user.getUserId();
        String role = user.getRoleId();

        // 1. Calculate Active Operational System Alerts for this user
        boolean isOperational = user.isSuperAdmin() || user.isAdmin() || user.isManager() || user.isSupervisor() || user.isStaff();
        boolean isAreaHotspot = false;
        int highFillCount = 0;
        int overdueRequests = 0;

        if (isOperational) {
            try {
                // Check Hotspot Bins
                List<WasteBin> allBins = binDAO.getAll();
                List<String> assignedAreas = new ArrayList<String>();
                if ("MGR".equals(role) || "SUP".equals(role) || "STF".equals(role) || "TEC".equals(role)) {
                    assignedAreas.addAll(userDAO.getAssignedAreaIds(userID));
                    if (user.getAreaID() != null && !user.getAreaID().trim().isEmpty()) {
                        String p = user.getAreaID().trim();
                        if (!assignedAreas.contains(p)) {
                            assignedAreas.add(p);
                        }
                    }
                }

                if (allBins != null) {
                    for (WasteBin bin : allBins) {
                        if (bin == null) continue;
                        boolean inJurisdiction = assignedAreas.isEmpty() || assignedAreas.contains(bin.getAreaID());
                        if (inJurisdiction && (bin.getCurrentFill() >= 80 || "Full".equalsIgnoreCase(bin.getStatus()))) {
                            highFillCount++;
                        }
                    }
                }
                isAreaHotspot = (highFillCount >= 2);

                // Check Overdue SLA Collection Requests
                List<CollectionRequest> requestList;
                if ("STF".equals(role)) {
                    requestList = collectionDAO.getByStaff(userID);
                } else if ("MGR".equals(role) || "SUP".equals(role)) {
                    requestList = collectionDAO.getByManager(userID);
                } else {
                    requestList = collectionDAO.getAll();
                }

                if (requestList != null) {
                    for (CollectionRequest cr : requestList) {
                        if (cr == null) continue;
                        String st = cr.getStatus();
                        if (cr.isOverdue() && ("Pending".equals(st) || "In_Progress".equals(st))) {
                            overdueRequests++;
                        }
                    }
                }
            } catch (Exception e) {
                log("Error loading system alerts: " + e.getMessage());
            }
        }

        req.setAttribute("isAreaHotspot", isAreaHotspot);
        req.setAttribute("hotspotBinCount", highFillCount);
        req.setAttribute("overdueRequests", overdueRequests);
        req.setAttribute("LIST_NOTIFICATION", notifications.getByUser(userID));

        req.getRequestDispatcher("/WEB-INF/views/notificationList.jsp")
                .forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        AppUser user = Web.currentUser(req);

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String path = req.getPathInfo();

        if ("/read".equals(path)) {

            int id = Web.intParam(req, "id", -1);

            if (id > 0) {
                notifications.markRead(id, user.getUserId());
            }

        } else if ("/readall".equals(path)) {

            notifications.markAllRead(user.getUserId());
        }

        resp.sendRedirect(req.getContextPath() + "/notification");
    }
}
