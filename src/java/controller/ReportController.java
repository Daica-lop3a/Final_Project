package controller;

import dao.AreaDAO;
import dao.ReportDAO;
import dao.UserDAO;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import model.AppUser;
import model.Area;
import model.CollectionRequest;
import model.ReportSummary;
import model.WasteBin;

@WebServlet("/report")
public class ReportController extends HttpServlet {

    private final ReportDAO reportDAO
            = new ReportDAO();

    private final AreaDAO areaDAO
            = new AreaDAO();

    private final UserDAO userDAO
            = new UserDAO();

    @Override
    protected void doGet(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);

        if (session == null
                || !(session.getAttribute("user") instanceof AppUser)) {

            resp.sendRedirect(
                    req.getContextPath() + "/login");
            return;
        }

        AppUser user
                = (AppUser) session.getAttribute("user");

        String role = user.getRoleId();

        if (!"ADM".equals(role)
                && !"MGR".equals(role)
                && !"SUP".equals(role)
                && !"SAD".equals(role)) {

            req.getRequestDispatcher(
                    "/WEB-INF/views/denied.jsp")
                    .forward(req, resp);

            return;
        }

        // Load the list of areas available to the current user
        List<Area> allAreas = areaDAO.getAll();
        List<Area> areaOptions = new ArrayList<Area>();

        // Null means there is no area restriction, which applies to Admin
        List<String> allowedAreaIds = null;

        if ("MGR".equals(role) || "SUP".equals(role)) {

            allowedAreaIds = new ArrayList<String>();
            allowedAreaIds.addAll(userDAO.getAssignedAreaIds(user.getUserId()));
            AppUser dbUser = userDAO.findById(user.getUserId());
            if (dbUser != null && dbUser.getAreaID() != null && !dbUser.getAreaID().trim().isEmpty()) {
                String pArea = dbUser.getAreaID().trim();
                if (!allowedAreaIds.contains(pArea)) {
                    allowedAreaIds.add(pArea);
                }
            }

            for (Area area : allAreas) {
                for (String aId : allowedAreaIds) {
                    if (aId.equalsIgnoreCase(area.getAreaId())) {
                        areaOptions.add(area);
                        break;
                    }
                }
            }

        } else {

            // Admin can select any area
            areaOptions = allAreas;
        }

        // Read filter parameters
        String fromDate = trim(req.getParameter("fromDate"));
        String toDate = trim(req.getParameter("toDate"));
        String areaId = trim(req.getParameter("areaId"));

        Timestamp from = parseStartOfDay(fromDate);
        Timestamp to = parseStartOfNextDay(toDate);

        if (from == null) {
            fromDate = "";
        }

        if (to == null) {
            toDate = "";
        }

        if (from != null
                && to != null
                && !from.before(to)) {

            req.setAttribute(
                    "ERROR",
                    "From date must not be after To date.");

            from = null;
            to = null;
            fromDate = "";
            toDate = "";
        }

        // Determine the permitted area scope
        List<String> scope;

        if (!areaId.isEmpty()) {

            // Prevent a Manager from selecting an unauthorized area
            if (allowedAreaIds != null
                    && !containsAreaId(allowedAreaIds, areaId)) {

                areaId = "";
                scope = allowedAreaIds;

            } else {

                scope = new ArrayList<String>();
                scope.add(areaId);
            }

        } else {

            // Admin has no area restriction; Manager is restricted to their assigned area
            scope = allowedAreaIds;
        }

        // A Manager or Supervisor without a valid assigned area must not see system-wide data
        boolean noArea = ("MGR".equals(role) || "SUP".equals(role))
                && (scope == null || scope.isEmpty());

        ReportSummary summary;
        Map<String, Integer> collectionStats;
        Map<String, Integer> binStats;
        List<CollectionRequest> detailedCollections;
        List<WasteBin> detailedBins;

        if (noArea) {

            summary = new ReportSummary();

            collectionStats
                    = new LinkedHashMap<String, Integer>();

            binStats
                    = new LinkedHashMap<String, Integer>();

            detailedCollections = new ArrayList<CollectionRequest>();
            detailedBins = new ArrayList<WasteBin>();

        } else {

            summary = reportDAO.getSummary(
                    from, to, scope);

            collectionStats
                    = reportDAO.getCollectionStatistics(
                            from, to, scope);

            binStats
                    = reportDAO.getBinStatistics(scope);

            detailedCollections
                    = reportDAO.getDetailedCollections(
                            from, to, scope);

            detailedBins
                    = reportDAO.getDetailedBins(scope);
        }

        // Pass report data and filters to the JSP
        req.setAttribute("SUMMARY", summary);
        req.setAttribute("COLLECTION_STATS", collectionStats);
        req.setAttribute("BIN_STATS", binStats);
        req.setAttribute("DETAILED_COLLECTIONS", detailedCollections);
        req.setAttribute("DETAILED_BINS", detailedBins);

        req.setAttribute("LIST_AREA", areaOptions);
        req.setAttribute("FROM_DATE", fromDate);
        req.setAttribute("TO_DATE", toDate);
        req.setAttribute("AREA_ID", areaId);

        req.getRequestDispatcher(
                "/WEB-INF/views/report.jsp")
                .forward(req, resp);
    }

    // =====================================================
    // Normalize String Values
    // =====================================================
    private String trim(String s) {
        return s == null ? "" : s.trim();
    }

    // =====================================================
    // Check Whether an Area ID Exists in the Allowed List
    // =====================================================
    private boolean containsAreaId(
            List<String> areaIds,
            String areaId) {

        if (areaIds == null || areaId == null) {
            return false;
        }

        for (String id : areaIds) {

            if (id != null
                    && id.equalsIgnoreCase(areaId.trim())) {

                return true;
            }
        }

        return false;
    }

    // =====================================================
    // Parse a Date as the Start of the Day
    // Example: "2026-10-01" becomes "2026-10-01 00:00:00"
    // =====================================================
    private Timestamp parseStartOfDay(String date) {

        if (date.isEmpty()) {
            return null;
        }

        try {
            return Timestamp.valueOf(date + " 00:00:00");
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    // =====================================================
    // Parse a Date as the Start of the Following Day
    // Used with an exclusive upper-bound condition
    // =====================================================
    private Timestamp parseStartOfNextDay(String date) {

        Timestamp timestamp = parseStartOfDay(date);

        if (timestamp == null) {
            return null;
        }

        return new Timestamp(
                timestamp.getTime() + 24L * 60 * 60 * 1000);
    }
}