package controller;

import dao.AlertDAO;
import dao.AreaDAO;
import dao.AuditLogDAO;
import dao.CollectionDAO;
import dao.NotificationDAO;
import dao.UserDAO;
import dao.WasteBinDAO;

import model.AppUser;
import model.Area;
import model.CollectionRequest;
import model.Notification;
import model.WasteBin;
import service.NotificationService;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;


import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/collection/*")
public class CollectionServlet extends HttpServlet {

    private static final String LIST =
            "/WEB-INF/views/collectionList.jsp";
    private static final String FORM =
            "/WEB-INF/views/collectionForm.jsp";
    private static final String DETAIL =
            "/WEB-INF/views/collectionDetail.jsp";
    private static final String DENIED =
            "/WEB-INF/views/denied.jsp";

    private static final String REDIRECT = "redirect:";

    private final CollectionDAO collections = new CollectionDAO();
    private final WasteBinDAO bins = new WasteBinDAO();
    private final UserDAO users = new UserDAO();
    private final AreaDAO areas = new AreaDAO();
    private final AlertDAO alerts = new AlertDAO();
    private final NotificationDAO notificationDAO =
            new NotificationDAO();
    private final NotificationService notifier =
            new NotificationService();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        processRequest(request, response);
    }

    // =========================================================
    // PROCESS REQUEST
    // =========================================================
    private void processRequest(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String url = null;

        try {
            AppUser user = getCurrentUser(request);

            if (user == null) {
                url = REDIRECT
                        + request.getContextPath() + "/login";

            } else if (isCitizen(user)) {
                response.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "You do not have permission to access Collection Requests.");
                return;

            } else {
                String path = request.getPathInfo();
                String method = request.getMethod();

                if ("GET".equalsIgnoreCase(method)) {

                    if (path == null || "/".equals(path)) {
                        url = showList(request);

                    } else if ("/start".equals(path)) {
                        url = startCollection(request, user);

                    } else if ("/create".equals(path)) {
                        url = createForm(request, user);

                    } else if ("/view".equals(path)) {
                        url = view(request, user);

                    } else if ("/edit".equals(path)) {
                        url = editForm(request, user);

                    } else if ("/staff-by-bin".equals(path)) {
                        staffByBin(request, response);
                        return;

                    } else if ("/area-data".equals(path)) {
                        areaData(request, response);
                        return;

                    } else {
                        url = showList(request);
                    }

                } else if ("POST".equalsIgnoreCase(method)) {

                    if ("/save".equals(path)) {
                        url = save(request, user);

                    } else if ("/start".equals(path)) {
                        url = startCollection(request, user);

                    } else if ("/delete".equals(path)) {
                        url = delete(request, user);

                    } else if ("/verify".equals(path)) {
                        url = verify(request, user);

                    } else if ("/propose-schedule".equals(path)) {
                        url = proposeSchedule(request, user);

                    } else {
                        url = showList(request);
                    }

                } else {
                    response.sendError(
                            HttpServletResponse.SC_METHOD_NOT_ALLOWED);
                    return;
                }
            }

        } catch (Exception e) {
            log("Error processing CollectionServlet", e);

            if (response.isCommitted()) {
                return;
            }

            response.resetBuffer();
            response.setStatus(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR);

            request.setAttribute(
                    "ERROR",
                    "An error occurred while processing the collection request.");

            /*
             * Do not forward to a JSP without the list attributes.
             * Display the error page instead.
             */
            url = DENIED;

        }

        /*
         * Navigation is handled only here.
         * The JSON endpoint returns before reaching this section.
         */
        if (url != null && !response.isCommitted()) {
            if (url.startsWith(REDIRECT)) {
                response.sendRedirect(
                        url.substring(REDIRECT.length()));
            } else {
                request.getRequestDispatcher(url)
                        .forward(request, response);
            }
        }
    }

    // =========================================================
    // STAFF BY BIN: JSON API
    // =========================================================
    private void staffByBin(
            HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException, ClassNotFoundException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        AppUser user = getCurrentUser(request);

        if (user == null) {
            response.setStatus(
                    HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("[]");
            return;
        }

        String role = user.getRoleId();

        if (!"ADM".equals(role) && !"MGR".equals(role) && !"SAD".equals(role) && !"SUP".equals(role)) {
            response.setStatus(
                    HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("[]");
            return;
        }

        String binID = safe(request.getParameter("binID"));

        if (binID.isEmpty()) {
            response.getWriter().write("[]");
            return;
        }

        WasteBin bin = bins.findByID(binID);

        if (bin == null || safe(bin.getAreaID()).isEmpty()) {
            response.getWriter().write("[]");
            return;
        }

        String areaID = bin.getAreaID().trim();

        if ("MGR".equals(role)
                && !isManagerOfArea(user.getUserId(), areaID)) {
            response.setStatus(
                    HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("[]");
            return;
        }

        List<AppUser> staffList = getStaffByArea(areaID);
        StringBuilder json = new StringBuilder("[");

        for (int i = 0; i < staffList.size(); i++) {
            AppUser staff = staffList.get(i);

            if (i > 0) {
                json.append(",");
            }

            json.append("{")
                    .append("\"userID\":\"")
                    .append(jsonEscape(staff.getUserId()))
                    .append("\",")
                    .append("\"fullName\":\"")
                    .append(jsonEscape(staff.getFullName()))
                    .append("\"}");
        }

        json.append("]");
        response.getWriter().write(json.toString());
    }

    // =========================================================
    // AREA DATA: BINS NEEDING COLLECTION & ASSIGNED STAFF (JSON API)
    // =========================================================
    private void areaData(
            HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException, ClassNotFoundException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        AppUser user = getCurrentUser(request);

        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{}");
            return;
        }

        String areaID = safe(request.getParameter("areaID"));

        if (areaID.isEmpty()) {
            response.getWriter().write("{\"bins\":[],\"allBins\":[],\"staff\":[]}");
            return;
        }

        List<WasteBin> needingBins = new ArrayList<WasteBin>();
        List<WasteBin> allAreaBins = new ArrayList<WasteBin>();
        List<WasteBin> allBins = bins.getAll();

        if (allBins != null) {
            for (WasteBin b : allBins) {
                if (b != null && b.getAreaID() != null && areaID.equalsIgnoreCase(b.getAreaID().trim())) {
                    allAreaBins.add(b);
                    if (!"Maintenance".equalsIgnoreCase(b.getStatus()) && !"Inactive".equalsIgnoreCase(b.getStatus())) {
                        // High fill level rule: only bins at High level (>= 80% or status = 'Full') require collection
                        if (b.getCurrentFill() >= 80 || "Full".equalsIgnoreCase(b.getStatus())) {
                            needingBins.add(b);
                        }
                    }
                }
            }
        }

        List<AppUser> staffList = getStaffByArea(areaID);

        StringBuilder json = new StringBuilder("{");

        json.append("\"bins\":[");
        for (int i = 0; i < needingBins.size(); i++) {
            WasteBin b = needingBins.get(i);
            if (i > 0) {
                json.append(",");
            }
            json.append("{")
                    .append("\"binID\":\"").append(jsonEscape(b.getBinID())).append("\",")
                    .append("\"binCode\":\"").append(jsonEscape(b.getBinCode())).append("\",")
                    .append("\"location\":\"").append(jsonEscape(b.getLocation())).append("\",")
                    .append("\"currentFill\":").append((int) b.getCurrentFill()).append(",")
                    .append("\"capacity\":").append((int) b.getCapacity()).append(",")
                    .append("\"status\":\"").append(jsonEscape(b.getStatus())).append("\"")
                    .append("}");
        }
        json.append("],");

        json.append("\"allBins\":[");
        for (int i = 0; i < allAreaBins.size(); i++) {
            WasteBin b = allAreaBins.get(i);
            if (i > 0) {
                json.append(",");
            }
            json.append("{")
                    .append("\"binID\":\"").append(jsonEscape(b.getBinID())).append("\",")
                    .append("\"binCode\":\"").append(jsonEscape(b.getBinCode())).append("\",")
                    .append("\"location\":\"").append(jsonEscape(b.getLocation())).append("\",")
                    .append("\"currentFill\":").append((int) b.getCurrentFill()).append(",")
                    .append("\"capacity\":").append((int) b.getCapacity()).append(",")
                    .append("\"status\":\"").append(jsonEscape(b.getStatus())).append("\"")
                    .append("}");
        }
        json.append("],");

        json.append("\"staff\":[");
        for (int i = 0; i < staffList.size(); i++) {
            AppUser s = staffList.get(i);
            if (i > 0) {
                json.append(",");
            }
            json.append("{")
                    .append("\"userID\":\"").append(jsonEscape(s.getUserId())).append("\",")
                    .append("\"fullName\":\"").append(jsonEscape(s.getFullName())).append("\"")
                    .append("}");
        }
        json.append("]");

        json.append("}");
        response.getWriter().write(json.toString());
    }

    private String jsonEscape(String value) {
        if (value == null) {
            return "";
        }

        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "\\r")
                .replace("\n", "\\n")
                .replace("\t", "\\t");
    }

    // =========================================================
    // LIST AND PAGINATION
    // =========================================================
    private String showList(HttpServletRequest request)
            throws SQLException, ClassNotFoundException {

        AppUser user = getCurrentUser(request);

        if (user == null) {
            return REDIRECT + request.getContextPath() + "/login";
        }

        String role = user.getRoleId();

        if (!"ADM".equals(role)
                && !"MGR".equals(role)
                && !"STF".equals(role)
                && !"SUP".equals(role)
                && !"SAD".equals(role)
                && !"TEC".equals(role)) {
            return DENIED;
        }

        String searchId = safe(request.getParameter("searchId"));
        String staffId = safe(request.getParameter("staffId"));
        String sortBy = safe(request.getParameter("sortBy"));
        String order = safe(request.getParameter("order"));
        String pageParam = request.getParameter("page");

        if (sortBy.isEmpty()) {
            sortBy = "createdDate";
        }

        if (!"status".equals(sortBy)
                && !"priority".equals(sortBy)
                && !"createdDate".equals(sortBy)) {
            sortBy = "createdDate";
        }

        if (!"ASC".equalsIgnoreCase(order)
                && !"DESC".equalsIgnoreCase(order)) {
            order = "DESC";
        }

        int currentPage = 1;

        try {
            if (pageParam != null && !pageParam.trim().isEmpty()) {
                currentPage = Integer.parseInt(pageParam.trim());
            }
        } catch (NumberFormatException e) {
            currentPage = 1;
        }

        if (currentPage < 1) {
            currentPage = 1;
        }

        int pageSize = 10;
        int totalRecords;

        if ("STF".equals(role)) {
            staffId = "";
            totalRecords = collections.countFilteredByStaff(
                    user.getUserId(), searchId);

        } else if ("TEC".equals(role)) {
            totalRecords = collections.countFilteredByStaff(
                    user.getUserId(), searchId);
            if (totalRecords == 0) {
                totalRecords = collections.countFiltered(
                        searchId, staffId);
            }

        } else if ("MGR".equals(role) || "SUP".equals(role)) {
            totalRecords = collections.countFilteredByManager(
                    user.getUserId(), searchId, staffId);

        } else {
            totalRecords = collections.countFiltered(
                    searchId, staffId);
        }

        int totalPages = (int) Math.ceil(
                (double) totalRecords / pageSize);

        if (totalPages < 1) {
            totalPages = 1;
        }

        if (currentPage > totalPages) {
            currentPage = totalPages;
        }

        int offset = (currentPage - 1) * pageSize;
        List<CollectionRequest> collectionList;

        if ("STF".equals(role)) {
            collectionList = collections.getFilteredByStaffPaged(
                    user.getUserId(),
                    searchId, sortBy, order, offset, pageSize);

        } else if ("TEC".equals(role)) {
            collectionList = collections.getFilteredByStaffPaged(
                    user.getUserId(),
                    searchId, sortBy, order, offset, pageSize);
            if (collectionList == null || collectionList.isEmpty()) {
                collectionList = collections.getFilteredPaged(
                        searchId, staffId, sortBy, order, offset, pageSize);
            }

        } else if ("MGR".equals(role) || "SUP".equals(role)) {
            collectionList = collections.getFilteredByManagerPaged(
                    user.getUserId(),
                    searchId, staffId, sortBy, order, offset, pageSize);

        } else {
            collectionList = collections.getFilteredPaged(
                    searchId, staffId, sortBy, order, offset, pageSize);
        }

        request.setAttribute("LIST_COLLECTION", collectionList);
        request.setAttribute("SEARCH_ID", searchId);
        request.setAttribute("STAFF_ID", staffId);
        request.setAttribute("SORT_BY", sortBy);
        request.setAttribute("ORDER", order);
        request.setAttribute("CURRENT_PAGE", currentPage);
        request.setAttribute("TOTAL_PAGES", totalPages);
        request.setAttribute("TOTAL_RECORDS", totalRecords);
        request.setAttribute("PAGE_SIZE", pageSize);

        return LIST;
    }

    // =========================================================
    // CREATE FORM
    // =========================================================
    private String createForm(
            HttpServletRequest request,
            AppUser user)
            throws SQLException, ClassNotFoundException {

        String role = user.getRoleId();

        if (!"ADM".equals(role) && !"MGR".equals(role) && !"SAD".equals(role) && !"SUP".equals(role)) {
            return REDIRECT
                    + request.getContextPath() + "/collection";
        }

        CollectionRequest collection = new CollectionRequest();
        // Prefill next sequential collection request ID (e.g. REQ-009)
        collection.setRequestID(util.IdGenerator.nextCollectionRequestId());
        collection.setStatus("Pending");
        collection.setPriority("Normal");
        collection.setCreatedDate(
                new Timestamp(System.currentTimeMillis()));

        String binID = safe(request.getParameter("binID"));

        if (!binID.isEmpty()) {
            collection.setBinID(binID);
        }

        String mode = safe(request.getParameter("mode"));
        boolean isRoute = "route".equalsIgnoreCase(mode) || "1".equals(request.getParameter("hotspot"));
        request.setAttribute("IS_ROUTE_MODE", isRoute);
        request.setAttribute("IS_HOTSPOT", "1".equals(request.getParameter("hotspot")));
        request.setAttribute("IS_CREATE", Boolean.TRUE);

        prepareForm(request, collection, user);
        return FORM;
    }

    // =========================================================
    // VIEW DETAILS
    // =========================================================
    private String view(
            HttpServletRequest request,
            AppUser user)
            throws SQLException, ClassNotFoundException {

        String requestID = safe(request.getParameter("id"));

        if (requestID.isEmpty()) {
            return REDIRECT
                    + request.getContextPath() + "/collection";
        }

        CollectionRequest collection =
                collections.findByID(requestID);

        if (collection == null) {
            return REDIRECT
                    + request.getContextPath() + "/collection";
        }

        String role = user.getRoleId();

        if ("STF".equals(role)
                && !user.getUserId().equals(collection.getStaffID())) {
            return REDIRECT
                    + request.getContextPath() + "/collection";
        }

        if (("MGR".equals(role) || "SUP".equals(role))
                && !isManagerOfBin(
                        user.getUserId(), collection.getBinID())) {
            return REDIRECT
                    + request.getContextPath() + "/collection";
        }

        if (!"ADM".equals(role)
                && !"MGR".equals(role)
                && !"STF".equals(role)
                && !"SUP".equals(role)
                && !"SAD".equals(role)
                && !"TEC".equals(role)) {
            return DENIED;
        }

        notificationDAO.markReadByRef(
                user.getUserId(),
                Notification.TYPE_COLLECTION,
                collection.getRequestID());

        request.setAttribute("REQUEST", collection);
        return DETAIL;
    }

    // =========================================================
    // EDIT FORM
    // =========================================================
    private String editForm(
            HttpServletRequest request,
            AppUser user)
            throws SQLException, ClassNotFoundException {

        String requestID = safe(request.getParameter("id"));

        if (requestID.isEmpty()) {
            return REDIRECT
                    + request.getContextPath() + "/collection";
        }

        CollectionRequest collection =
                collections.findByID(requestID);

        if (collection == null) {
            return REDIRECT
                    + request.getContextPath() + "/collection";
        }

        String role = user.getRoleId();

        if ("STF".equals(role)
                && !user.getUserId().equals(collection.getStaffID())) {
            return REDIRECT
                    + request.getContextPath() + "/collection";
        }

        if (("MGR".equals(role) || "SUP".equals(role))
                && !isManagerOfBin(
                        user.getUserId(), collection.getBinID())) {
            return REDIRECT
                    + request.getContextPath() + "/collection";
        }

        if (!"ADM".equals(role)
                && !"MGR".equals(role)
                && !"STF".equals(role)
                && !"SUP".equals(role)
                && !"SAD".equals(role)
                && !"TEC".equals(role)) {
            return DENIED;
        }

        request.setAttribute("IS_CREATE", Boolean.FALSE);
        prepareForm(request, collection, user);
        return FORM;
    }

    // =========================================================
    // PREPARE FORM DROPDOWNS
    // =========================================================
    private void prepareForm(
            HttpServletRequest request,
            CollectionRequest collection,
            AppUser user)
            throws SQLException, ClassNotFoundException {

        request.setAttribute("REQUEST", collection);

        String role = user == null ? "" : user.getRoleId();

        // 1. Available Target Areas
        List<Area> areaList = new ArrayList<Area>();
        if ("MGR".equals(role) || "SUP".equals(role)) {
            List<String> managerAreaIDs = getManagerAreaIDs(user.getUserId());
            if (managerAreaIDs.isEmpty()) {
                areaList = areas.getAll();
            } else {
                for (String aId : managerAreaIDs) {
                    Area a = areas.findById(aId);
                    if (a != null) {
                        areaList.add(a);
                    }
                }
            }
        } else {
            areaList = areas.getAll();
        }
        request.setAttribute("LIST_AREA", areaList);

        // 2. Selected Target Area
        String selectedAreaID = safe(request.getParameter("areaID"));
        String binID = safe(collection != null ? collection.getBinID() : null);

        if (binID.length() > 0) {
            WasteBin bin = bins.findByID(binID);
            if (bin != null && bin.getAreaID() != null && !bin.getAreaID().trim().isEmpty()) {
                selectedAreaID = bin.getAreaID().trim();
            }
        }

        if (selectedAreaID.isEmpty() && areaList != null && !areaList.isEmpty()) {
            selectedAreaID = areaList.get(0).getAreaId();
        }
        request.setAttribute("SELECTED_AREA_ID", selectedAreaID);

        // 3. Filter bins in selectedAreaID that need collection
        List<WasteBin> needingBins = new ArrayList<WasteBin>();
        List<WasteBin> allAreaBins = new ArrayList<WasteBin>();

        if (!selectedAreaID.isEmpty()) {
            List<WasteBin> allBins = bins.getAll();
            if (allBins != null) {
                for (WasteBin b : allBins) {
                    if (b != null && b.getAreaID() != null && selectedAreaID.equalsIgnoreCase(b.getAreaID().trim())) {
                        allAreaBins.add(b);
                        if (!"Maintenance".equalsIgnoreCase(b.getStatus()) && !"Inactive".equalsIgnoreCase(b.getStatus())) {
                            // High fill level rule: only bins at High level (>= 80% or status = 'Full') require collection
                            if (b.getCurrentFill() >= 80 || "Full".equalsIgnoreCase(b.getStatus())) {
                                needingBins.add(b);
                            }
                        }
                    }
                }
            }
        }

        // If creating with a preselected bin that is below High fill level (< 80%), set notice warning
        if (!binID.isEmpty()) {
            WasteBin preselectedBin = bins.findByID(binID);
            if (preselectedBin != null) {
                if (Boolean.TRUE.equals(request.getAttribute("IS_CREATE"))
                        && preselectedBin.getCurrentFill() < 80
                        && !"Full".equalsIgnoreCase(preselectedBin.getStatus())) {
                    request.setAttribute("FILL_WARNING", "Notice: Selected receptacle "
                            + preselectedBin.getBinCode() + " is currently at " + (int) preselectedBin.getCurrentFill()
                            + "% fill level. Collection requests only need to be dispatched when waste reaches High level (80% or above).");
                }
            }
        }

        // If existing collection has a binID that isn't in needingBins, ensure it's included
        if (!binID.isEmpty()) {
            boolean found = false;
            for (WasteBin nb : needingBins) {
                if (binID.equalsIgnoreCase(nb.getBinID())) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                WasteBin currentBin = bins.findByID(binID);
                if (currentBin != null) {
                    needingBins.add(0, currentBin);
                }
            }
        }

        request.setAttribute("LIST_BIN", needingBins);
        request.setAttribute("LIST_ALL_AREA_BINS", allAreaBins);

        // 4. Staff assigned to the selected target area
        List<AppUser> staffList = new ArrayList<AppUser>();
        if (!selectedAreaID.isEmpty()) {
            staffList = getStaffByArea(selectedAreaID);
        }
        request.setAttribute("LIST_STAFF", staffList);
    }

    // =========================================================
    // START COLLECTION TASK (STAFF / SUPERVISOR / MANAGER)
    // =========================================================
    private String startCollection(
            HttpServletRequest request,
            AppUser user)
            throws SQLException, ClassNotFoundException {

        String id = safe(request.getParameter("id"));
        if (id.isEmpty()) {
            id = safe(request.getParameter("requestID"));
        }

        if (id.isEmpty()) {
            return REDIRECT + request.getContextPath() + "/collection";
        }

        CollectionRequest cr = collections.findByID(id);
        if (cr == null) {
            return REDIRECT + request.getContextPath() + "/collection";
        }

        String role = user.getRoleId();
        if ("STF".equals(role)) {
            if (!user.getUserId().equals(cr.getStaffID())) {
                return DENIED;
            }
        } else if ("MGR".equals(role) || "SUP".equals(role)) {
            if (!isManagerOfBin(user.getUserId(), cr.getBinID())) {
                return DENIED;
            }
        }

        collections.startTask(id);

        AuditLogDAO.log(
                user.getUserId(),
                "START_COLLECTION",
                "tblCollectionRequests",
                id,
                cr.getStatus(),
                "Started collection for Bin " + cr.getBinID(),
                request.getRemoteAddr()
        );

        return REDIRECT + request.getContextPath() + "/collection/edit?id=" + id + "&started=1";
    }

    // =========================================================
    // SAVE: CREATE OR UPDATE
    // =========================================================
    private String save(
            HttpServletRequest request,
            AppUser user)
            throws SQLException, ClassNotFoundException,
                   ServletException, IOException {

        String role = user.getRoleId();

        if (!"ADM".equals(role)
                && !"MGR".equals(role)
                && !"STF".equals(role)
                && !"SUP".equals(role)
                && !"SAD".equals(role)
                && !"TEC".equals(role)) {
            return DENIED;
        }

        String requestID = safe(request.getParameter("requestID"));
        String binID = safe(request.getParameter("binID"));
        String staffID = safe(request.getParameter("staffID"));
        String status = safe(request.getParameter("status"));
        String priority = safe(request.getParameter("priority"));
        String notes = request.getParameter("notes");
        String qrData = safe(request.getParameter("qrData"));
        String photoBefore = safe(request.getParameter("photoBefore"));
        String photoAfter = safe(request.getParameter("photoAfter"));
        String failureReason = safe(request.getParameter("failureReason"));

        String isCreateParam = safe(request.getParameter("isCreate"));
        boolean creating = "true".equalsIgnoreCase(isCreateParam)
                || requestID.isEmpty()
                || collections.findByID(requestID) == null;

        CollectionRequest oldRequest = null;

        if (!creating) {
            oldRequest = collections.findByID(requestID);

            if (oldRequest == null) {
                return formError(
                        request, requestID, binID, staffID,
                        status, priority, notes,
                        "Collection Request does not exist.");
            }
        }

        if (creating && ("STF".equals(role) || "TEC".equals(role))) {
            return formError(
                    request, "", binID, staffID,
                    status, priority, notes,
                    "Field operators cannot create collection requests.");
        }

        String dispatchMode = safe(request.getParameter("dispatchMode"));
        String[] binIDs = request.getParameterValues("binIDs");
        if ((binIDs == null || binIDs.length == 0) && !binID.isEmpty()) {
            binIDs = new String[] { binID };
        }

        // =========================================================
        // MULTI-BIN ROUTE DISPATCH (WHEN CREATING IN ROUTE MODE OR WITH MULTIPLE BINS)
        // =========================================================
        boolean isRouteDispatch = creating && ("route".equalsIgnoreCase(dispatchMode) || (binIDs != null && binIDs.length > 1));
        if (isRouteDispatch) {
            if (binIDs == null || binIDs.length == 0) {
                return formError(request, "", "", staffID, status, priority, notes, "Please select at least one waste bin for the route.");
            }
            if (staffID.isEmpty()) {
                return formError(request, "", "", staffID, status, priority, notes, "Staff assignment is required for route dispatch.");
            }
            AppUser staff = users.findById(staffID);
            if (staff == null || !"STF".equals(staff.getRoleId())) {
                return formError(request, "", "", staffID, status, priority, notes, "Selected Staff is invalid.");
            }
            if (priority == null || priority.trim().isEmpty() || "Low".equalsIgnoreCase(priority)) {
                priority = "Normal";
            }
            if ("Emer".equalsIgnoreCase(priority)) {
                priority = "Emergency";
            }

            List<WasteBin> validBins = new ArrayList<WasteBin>();
            for (String bId : binIDs) {
                if (bId == null || bId.trim().isEmpty()) continue;
                WasteBin b = bins.findByID(bId.trim());
                if (b == null) {
                    return formError(request, "", "", staffID, status, priority, notes, "Waste bin " + bId + " does not exist.");
                }
                if (("MGR".equals(role) || "SUP".equals(role)) && !isManagerOfArea(user.getUserId(), b.getAreaID())) {
                    return formError(request, "", "", staffID, status, priority, notes, "You do not have permission to manage bin " + b.getBinCode() + " in area " + b.getAreaID() + ".");
                }
                // High fill level rule: only bins at High level (>= 80% or status = 'Full') can be dispatched
                if (b.getCurrentFill() < 80 && !"Full".equalsIgnoreCase(b.getStatus())) {
                    return formError(request, "", "", staffID, status, priority, notes,
                            "Waste bin " + b.getBinCode() + " is currently at " + (int) b.getCurrentFill() + "%. Only bins at High fill level (80% or above) need collection.");
                }
                validBins.add(b);
            }

            if (validBins.isEmpty()) {
                return formError(request, "", "", staffID, status, priority, notes, "Please select at least one valid waste bin for the route.");
            }

            int createdCount = 0;
            for (int i = 0; i < validBins.size(); i++) {
                WasteBin b = validBins.get(i);
                String newReqId = util.IdGenerator.nextCollectionRequestId();
                CollectionRequest req = new CollectionRequest();
                req.setRequestID(newReqId);
                req.setBinID(b.getBinID());
                req.setStaffID(staffID);
                req.setStatus("Pending");
                req.setPriority(priority);
                req.setCreatedDate(new Timestamp(System.currentTimeMillis()));
                String routeNotes = (notes != null && !notes.trim().isEmpty() ? notes.trim() + " " : "")
                        + "[Route Stop #" + (i + 1) + " of " + validBins.size() + " (" + b.getBinCode() + ")]";
                req.setNotes(routeNotes);

                boolean ok = collections.insert(req);
                if (ok) {
                    createdCount++;
                    AuditLogDAO.log(
                            user.getUserId(),
                            "DISPATCH_ROUTE_STOP",
                            "tblCollectionRequests",
                            newReqId,
                            null,
                            "Assigned route stop for Bin " + b.getBinCode() + " (" + b.getBinID() + ") to Staff " + staffID,
                            request.getRemoteAddr()
                    );
                    try {
                        notifier.collectionAssigned(req);
                    } catch (Exception ignored) {}
                }
            }
            AuditLogDAO.log(
                    user.getUserId(),
                    "DISPATCH_ROUTE",
                    "tblCollectionRequests",
                    "ROUTE-" + System.currentTimeMillis(),
                    null,
                    "Dispatched multi-bin collection route covering " + createdCount + " bins to Staff " + staffID,
                    request.getRemoteAddr()
            );
            return REDIRECT + request.getContextPath() + "/collection?msg=route_dispatched&count=" + createdCount;
        }

        if (binIDs != null && binIDs.length == 1 && binID.isEmpty()) {
            binID = binIDs[0];
        }

        if (binID.isEmpty()) {
            return formError(
                    request, requestID, binID, staffID,
                    status, priority, notes,
                    "Waste Bin is required.");
        }

        WasteBin bin = bins.findByID(binID);

        if (bin == null) {
            return formError(
                    request, requestID, binID, staffID,
                    status, priority, notes,
                    "Waste Bin does not exist.");
        }

        // High fill level rule: single receptacle creation is strictly restricted to High fill level (>= 80% or status = 'Full')
        if (creating && bin.getCurrentFill() < 80 && !"Full".equalsIgnoreCase(bin.getStatus())) {
            return formError(
                    request, requestID, binID, staffID,
                    status, priority, notes,
                    "Waste bin " + bin.getBinCode() + " is currently at " + (int) bin.getCurrentFill() + "%. Only bins at High fill level (80% or above) need collection.");
        }

        if (!qrData.isEmpty()) {
            boolean match = qrData.equalsIgnoreCase(bin.getBinCode())
                    || qrData.equalsIgnoreCase(bin.getBinID())
                    || qrData.toUpperCase().contains(bin.getBinCode().toUpperCase())
                    || qrData.toUpperCase().contains(bin.getBinID().toUpperCase());
            if (!match) {
                return formError(
                        request, requestID, binID, staffID,
                        status, priority, notes,
                        "QR Code validation failed: Scanned code '" + qrData + "' does not match assigned Bin " + bin.getBinCode() + " (" + bin.getBinID() + ").");
            }
        }

        if (("MGR".equals(role) || "SUP".equals(role))
                && !isManagerOfArea(user.getUserId(), bin.getAreaID())) {
            return formError(
                    request, requestID, binID, staffID,
                    status, priority, notes,
                    "You can only manage bins in your area.");
        }

        if (!creating && ("MGR".equals(role) || "SUP".equals(role))
                && !isManagerOfBin(
                        user.getUserId(), oldRequest.getBinID())) {
            return REDIRECT
                    + request.getContextPath() + "/collection";
        }

        // Business Rule: On create, status is STRICTLY "Pending"
        if (creating) {
            status = "Pending";
        } else {
            // Business Rule: On update, Collection Staff (assigned to request) or Supervisor/Admin can edit execution status
            boolean canEditStatus = "STF".equals(role) || "SUP".equals(role) || "MGR".equals(role) || "ADM".equals(role) || "SAD".equals(role);
            if (!canEditStatus) {
                status = oldRequest.getStatus();
            } else if (status.isEmpty()) {
                status = oldRequest.getStatus();
            }
        }

        /*
         * These values match CK_Req_Status in the database.
         */
        if (!"Pending".equals(status)
                && !"In_Progress".equals(status)
                && !"Completed".equals(status)
                && !"Verified".equals(status)
                && !"Failed".equals(status)
                && !"Skipped".equals(status)
                && !"Cancelled".equals(status)) {
            return formError(
                    request, requestID, binID, staffID,
                    status, priority, notes,
                    "Invalid status.");
        }

        if (priority == null || priority.trim().isEmpty() || "Low".equalsIgnoreCase(priority)) {
            priority = creating ? "Normal" : oldRequest.getPriority();
        }
        if ("Emer".equalsIgnoreCase(priority)) {
            priority = "Emergency";
        }

        /*
         * These values match CK_Req_Priority in the supplied schema.
         */
        if (!"Normal".equals(priority)
                && !"High".equals(priority)
                && !"Emergency".equals(priority)) {
            return formError(
                    request, requestID, binID, staffID,
                    status, priority, notes,
                    "Invalid priority. Allowed priorities are Normal, High, Emergency.");
        }

        if ("STF".equals(role)) {
            if (!user.getUserId().equals(oldRequest.getStaffID())) {
                return REDIRECT
                    + request.getContextPath() + "/collection";
            }

            /*
             * Staff may update status, notes, qrData, and photos.
             */
            binID = oldRequest.getBinID();
            staffID = oldRequest.getStaffID();
            priority = oldRequest.getPriority();

            if ("Completed".equals(oldRequest.getStatus())
                    && !"Completed".equals(status) && !"Verified".equals(status)) {
                return formError(
                        request, requestID, binID, staffID,
                        status, priority, notes,
                        "Completed requests cannot be reopened by Staff.");
            }
        } else if ("TEC".equals(role)) {
            // Field technicians handle hardware maintenance tickets (/maintenance), not collection requests
            return REDIRECT + request.getContextPath() + "/collection";
        } else {
            if (staffID.isEmpty()) {
                return formError(
                        request, requestID, binID, staffID,
                        status, priority, notes,
                        "Staff is required.");
            }

            AppUser staff = users.findById(staffID);

            if (staff == null || !"STF".equals(staff.getRoleId())) {
                return formError(
                        request, requestID, binID, staffID,
                        status, priority, notes,
                        "Selected Staff is invalid. Collection tasks must be assigned to Collection Staff (STF).");
            }

            if (!isStaffOfArea(staffID, bin.getAreaID())) {
                return formError(
                        request, requestID, binID, staffID,
                        status, priority, notes,
                        "Selected Staff does not belong to the target area (" + bin.getAreaID() + ").");
            }
        }

        String oldStaffID =
                creating ? null : oldRequest.getStaffID();
        String oldStatus =
                creating ? null : oldRequest.getStatus();
        String oldPriority =
                creating ? null : oldRequest.getPriority();
        String oldNotes =
                creating ? null : oldRequest.getNotes();

        CollectionRequest collection;

        if (creating) {
            collection = new CollectionRequest();
            // Generate next sequential collection request ID (e.g. REQ-009)
            requestID = util.IdGenerator.nextCollectionRequestId();
            collection.setRequestID(requestID);
            collection.setCreatedDate(
                    new Timestamp(System.currentTimeMillis()));
            if ("SUP".equals(role)) {
                collection.setSupervisorID(user.getUserId());
            }
        } else {
            collection = oldRequest;
        }

        collection.setBinID(binID);
        collection.setStaffID(staffID);
        collection.setStatus(status);
        collection.setPriority(priority);
        collection.setNotes(notes);

        if (!photoBefore.isEmpty()) {
            collection.setPhotoBefore(photoBefore);
        }
        if (!photoAfter.isEmpty()) {
            collection.setPhotoAfter(photoAfter);
        }

        if ("In_Progress".equals(status)) {
            if (collection.getStartedDate() == null) {
                collection.setStartedDate(new Timestamp(System.currentTimeMillis()));
            }
        } else if ("Completed".equals(status)) {
            if (collection.getStartedDate() == null) {
                collection.setStartedDate(new Timestamp(System.currentTimeMillis()));
            }
            if (collection.getCompletedDate() == null) {
                collection.setCompletedDate(new Timestamp(System.currentTimeMillis()));
            }
            if (collections.isRecentlyCollected(binID, 30) && !"Completed".equals(oldStatus)) {
                String curNotes = collection.getNotes();
                if (curNotes == null) curNotes = "";
                if (!curNotes.contains("Duplicate Warning")) {
                    collection.setNotes((curNotes.isEmpty() ? "" : curNotes + " ") + "[Duplicate Warning: Collected <30m ago]");
                }
            }
        } else if ("Failed".equals(status) || "Skipped".equals(status)) {
            if (collection.getCompletedDate() == null) {
                collection.setCompletedDate(new Timestamp(System.currentTimeMillis()));
            }
            if (!failureReason.isEmpty()) {
                collection.setFailureReason(failureReason);
            } else if (collection.getFailureReason() == null || collection.getFailureReason().isEmpty()) {
                collection.setFailureReason("Bin Unreachable / Obstacle");
            }
        }

        boolean success = creating
                ? collections.insert(collection)
                : collections.update(collection);

        if (!success) {
            return formError(
                    request, requestID, binID, staffID,
                    status, priority, notes,
                    creating
                            ? "Failed to create Collection Request."
                            : "Failed to update Collection Request.");
        }

        AuditLogDAO.log(
                user.getUserId(),
                creating ? "CREATE_COLLECTION" : "UPDATE_COLLECTION",
                "tblCollectionRequests",
                collection.getRequestID(),
                creating ? null : oldStatus,
                (creating ? "Created" : "Updated status to " + status) + " for Bin " + binID,
                request.getRemoteAddr()
        );

        notifyAfterSave(
                creating, oldStaffID, oldStatus, oldPriority,
                oldNotes, collection, user, role);

        if ("Completed".equals(status)
                && !"Completed".equals(oldStatus)) {
            completeCollection(binID);
        }

        return REDIRECT
                + request.getContextPath() + "/collection";
    }

    // =========================================================
    // FORM ERROR
    // =========================================================
    private String formError(
            HttpServletRequest request,
            String requestID,
            String binID,
            String staffID,
            String status,
            String priority,
            String notes,
            String message)
            throws SQLException, ClassNotFoundException {

        request.setAttribute("ERROR", message);

        CollectionRequest collection = new CollectionRequest();
        collection.setRequestID(requestID);
        collection.setBinID(binID);
        collection.setStaffID(staffID);
        collection.setStatus(status);
        collection.setPriority(priority);
        collection.setNotes(notes);

        CollectionRequest oldRequest = null;

        if (requestID != null && !requestID.trim().isEmpty()) {
            oldRequest = collections.findByID(requestID.trim());
        }

        if (oldRequest != null) {
            collection.setCreatedDate(oldRequest.getCreatedDate());
            request.setAttribute("IS_CREATE", Boolean.FALSE);
        } else {
            collection.setCreatedDate(
                    new Timestamp(System.currentTimeMillis()));
            request.setAttribute("IS_CREATE", Boolean.TRUE);
        }

        prepareForm(request, collection, getCurrentUser(request));
        return FORM;
    }

    // =========================================================
    // NOTIFICATIONS
    // =========================================================
    private void notifyAfterSave(
            boolean creating,
            String oldStaffID,
            String oldStatus,
            String oldPriority,
            String oldNotes,
            CollectionRequest saved,
            AppUser actor,
            String role) {

        if ("STF".equals(role)) {
            boolean statusChanged =
                    !safe(saved.getStatus()).equals(safe(oldStatus));

            boolean notesChanged =
                    !safe(saved.getNotes()).equals(safe(oldNotes));

            if (statusChanged || notesChanged) {
                notifier.collectionUpdatedByStaff(
                        saved, actor.getUserId());
            }
            return;
        }

        if (creating
                || !safe(saved.getStaffID()).equals(safe(oldStaffID))) {
            notifier.collectionAssigned(saved);
            return;
        }

        if (!safe(saved.getStatus()).equals(safe(oldStatus))
                || !safe(saved.getPriority()).equals(safe(oldPriority))) {
            notifier.collectionChangedByManager(
                    saved, actor.getUserId());
        }
    }

    // =========================================================
    // COMPLETE COLLECTION
    // =========================================================
    private void completeCollection(String binID)
            throws SQLException, ClassNotFoundException {

        if (binID == null || binID.trim().isEmpty()) {
            return;
        }

        bins.updateCurrentFill(binID, 0);
        alerts.resolveUnresolvedHighFillAlerts(binID);
    }

    // =========================================================
    // DELETE
    // =========================================================
    private String delete(
            HttpServletRequest request,
            AppUser user)
            throws SQLException, ClassNotFoundException {

        String role = user.getRoleId();

        if (!"ADM".equals(role) && !"MGR".equals(role) && !"SAD".equals(role) && !"SUP".equals(role)) {
            return REDIRECT
                    + request.getContextPath() + "/collection";
        }

        String requestID = safe(request.getParameter("id"));

        if (requestID.isEmpty()) {
            return REDIRECT
                    + request.getContextPath() + "/collection";
        }

        CollectionRequest collection =
                collections.findByID(requestID);

        if (collection == null) {
            return REDIRECT
                    + request.getContextPath() + "/collection";
        }

        if (("MGR".equals(role) || "SUP".equals(role))
                && !isManagerOfBin(
                        user.getUserId(), collection.getBinID())) {
            return REDIRECT
                    + request.getContextPath() + "/collection";
        }

        if (collections.delete(requestID)) {
            notifier.removeFor(
                    Notification.TYPE_COLLECTION, requestID);
        }

        return REDIRECT
                + request.getContextPath() + "/collection";
    }

    // =========================================================
    // VERIFY COLLECTION (SUPERVISOR / MANAGER / ADMIN)
    // =========================================================
    private String verify(
            HttpServletRequest request,
            AppUser user)
            throws SQLException, ClassNotFoundException {

        String role = user.getRoleId();

        if (!"ADM".equals(role) && !"MGR".equals(role) && !"SUP".equals(role) && !"SAD".equals(role)) {
            return DENIED;
        }

        String requestID = safe(request.getParameter("requestID"));
        String notes = safe(request.getParameter("verifyNotes"));

        if (requestID.isEmpty()) {
            return REDIRECT + request.getContextPath() + "/collection";
        }

        CollectionRequest collection = collections.findByID(requestID);
        if (collection == null) {
            return REDIRECT + request.getContextPath() + "/collection";
        }

        if (("MGR".equals(role) || "SUP".equals(role))
                && !isManagerOfBin(user.getUserId(), collection.getBinID())) {
            return REDIRECT + request.getContextPath() + "/collection";
        }

        if (notes.isEmpty()) {
            notes = (collection.getNotes() != null ? collection.getNotes() + " | " : "")
                    + "Verified by " + user.getFullName() + " (" + user.getRoleName() + ")";
        } else {
            notes = (collection.getNotes() != null ? collection.getNotes() + " | " : "")
                    + "Verified: " + notes;
        }

        collections.verifyRequest(requestID, user.getUserId(), notes);
        AuditLogDAO.log(
                user.getUserId(),
                "VERIFY_COLLECTION",
                "tblCollectionRequests",
                requestID,
                collection.getStatus(),
                "Verified collection task " + requestID,
                request.getRemoteAddr()
        );

        return REDIRECT + request.getContextPath() + "/collection";
    }

    // =========================================================
    // PROPOSE SCHEDULE (SUPERVISOR -> MANAGER)
    // =========================================================
    private String proposeSchedule(
            HttpServletRequest request,
            AppUser user)
            throws SQLException, ClassNotFoundException {

        String areaID = safe(request.getParameter("areaID"));
        String proposedChange = safe(request.getParameter("proposedChange"));
        String reason = safe(request.getParameter("reason"));

        if (!proposedChange.isEmpty()) {
            List<AppUser> allManagers = users.search("", "MGR");
            NotificationDAO nDao = new NotificationDAO();
            for (AppUser mgr : allManagers) {
                String msg = "Supervisor " + user.getFullName() + " proposed schedule adjustment for "
                        + areaID + ": " + proposedChange + " (Reason: " + reason + ")";
                nDao.insert(mgr.getUserId(), "COLLECTION", areaID, msg);
            }

            AuditLogDAO.log(
                    user.getUserId(),
                    "PROPOSE_SCHEDULE",
                    "tblAreas",
                    areaID,
                    null,
                    "Proposed schedule update for " + areaID + ": " + proposedChange,
                    request.getRemoteAddr()
            );
        }

        return REDIRECT + request.getContextPath() + "/collection?msg=proposal_sent";
    }

    // =========================================================
    // CURRENT USER
    // =========================================================
    private AppUser getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);

        if (session == null) {
            return null;
        }

        Object obj = session.getAttribute("user");
        return obj instanceof AppUser ? (AppUser) obj : null;
    }

    private boolean isCitizen(AppUser user) {
        return user != null && "USR".equals(user.getRoleId());
    }

    // =========================================================
    // MANAGER AREA
    // =========================================================
    private List<String> getManagerAreaIDs(String managerID) {
        List<String> list = new ArrayList<String>();
        if (managerID == null || managerID.trim().isEmpty()) {
            return list;
        }
        try {
            list.addAll(users.getAssignedAreaIds(managerID.trim()));
            AppUser manager = users.findById(managerID.trim());
            if (manager != null && manager.getAreaID() != null && !manager.getAreaID().trim().isEmpty()) {
                String primaryArea = manager.getAreaID().trim();
                if (!list.contains(primaryArea)) {
                    list.add(primaryArea);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private String getManagerAreaID(String managerID)
            throws SQLException, ClassNotFoundException {
        List<String> areas = getManagerAreaIDs(managerID);
        return areas.isEmpty() ? null : areas.get(0);
    }

    private boolean isManagerOfArea(
            String managerID,
            String areaID)
            throws SQLException, ClassNotFoundException {

        if (areaID == null || areaID.trim().isEmpty()) {
            return false;
        }

        List<String> managerAreaIDs = getManagerAreaIDs(managerID);
        if (managerAreaIDs.isEmpty()) {
            return true; // General manager without zone restrictions
        }

        for (String mArea : managerAreaIDs) {
            if (mArea.equalsIgnoreCase(areaID.trim())) {
                return true;
            }
        }
        return false;
    }

    private boolean isManagerOfBin(
            String managerID,
            String binID)
            throws SQLException, ClassNotFoundException {

        if (binID == null || binID.trim().isEmpty()) {
            return false;
        }

        WasteBin bin = bins.findByID(binID.trim());

        return bin != null
                && isManagerOfArea(managerID, bin.getAreaID());
    }

    // =========================================================
    // STAFF AREA
    // =========================================================
    private boolean isStaffOfArea(
            String staffID,
            String areaID)
            throws SQLException, ClassNotFoundException {

        if (staffID == null || staffID.trim().isEmpty()
                || areaID == null || areaID.trim().isEmpty()) {
            return false;
        }

        AppUser staff = users.findById(staffID.trim());

        if (staff == null
                || !"STF".equals(staff.getRoleId())) {
            return false;
        }

        if (staff.getAreaID() != null
                && areaID.trim().equalsIgnoreCase(staff.getAreaID().trim())) {
            return true;
        }

        List<String> assignedAreas = users.getAssignedAreaIds(staff.getUserId());
        if (assignedAreas != null) {
            for (String a : assignedAreas) {
                if (areaID.trim().equalsIgnoreCase(a.trim())) {
                    return true;
                }
            }
        }

        return false;
    }

    private List<AppUser> getStaffByArea(String areaID)
            throws SQLException, ClassNotFoundException {

        List<AppUser> result = new ArrayList<AppUser>();

        if (areaID == null || areaID.trim().isEmpty()) {
            return result;
        }

        List<AppUser> allStaff = users.search("", "STF");

        if (allStaff == null) {
            return result;
        }

        for (AppUser staff : allStaff) {
            if (staff == null) {
                continue;
            }
            boolean match = false;
            if (staff.getAreaID() != null
                    && areaID.trim().equalsIgnoreCase(staff.getAreaID().trim())) {
                match = true;
            } else {
                List<String> assignedAreas = users.getAssignedAreaIds(staff.getUserId());
                if (assignedAreas != null) {
                    for (String a : assignedAreas) {
                        if (areaID.trim().equalsIgnoreCase(a.trim())) {
                            match = true;
                            break;
                        }
                    }
                }
            }
            if (match) {
                result.add(staff);
            }
        }

        return result;
    }

    private List<WasteBin> getBinsByArea(String areaID)
            throws SQLException, ClassNotFoundException {

        List<WasteBin> result = new ArrayList<WasteBin>();

        if (areaID == null || areaID.trim().isEmpty()) {
            return result;
        }

        List<WasteBin> allBins = bins.getAll();

        if (allBins == null) {
            return result;
        }

        for (WasteBin bin : allBins) {
            if (bin != null
                    && bin.getAreaID() != null
                    && areaID.trim().equalsIgnoreCase(
                            bin.getAreaID().trim())) {
                result.add(bin);
            }
        }

        return result;
    }

    private String safe(String value) {
        return value == null ? "" : value.trim();
    }
}
