package controller;

import dao.AlertDAO;
import dao.NotificationDAO;
import dao.UserDAO;
import dao.WasteBinDAO;
import model.Alert;
import model.AppUser;
import model.Notification;
import model.WasteBin;
import service.NotificationService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.Collections;
import java.util.List;


@WebServlet("/alert/*")
public class AlertServlet extends HttpServlet {

    private static final String LIST_URL
            = "/WEB-INF/views/alertList.jsp";
    private static final String FORM_URL
            = "/WEB-INF/views/alertForm.jsp";
    private static final String DETAIL_URL
            = "/WEB-INF/views/alertDetail.jsp";
    private static final String DENIED_URL
            = "/WEB-INF/views/denied.jsp";

    private static final String REDIRECT_PREFIX = "REDIRECT:";

    private static final String ROLE_ADMIN = "ADM";
    private static final String ROLE_MANAGER = "MGR";
    private static final String ROLE_USER = "USR";

    private static final int PAGE_SIZE = 10;

    private final AlertDAO alertDAO = new AlertDAO();
    private final WasteBinDAO binDAO = new WasteBinDAO();
    private final UserDAO userDAO = new UserDAO();
    private final NotificationDAO notificationDAO
            = new NotificationDAO();
    private final NotificationService notifier
            = new NotificationService();

    // =========================================================
    // PROCESS REQUEST
    // =========================================================
    protected void processRequest(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String url = LIST_URL;

        try {
            request.setCharacterEncoding("UTF-8");

            AppUser user = getSessionUser(request);

            if (user == null) {
                url = REDIRECT_PREFIX + "/login";
            } else if ("GET".equalsIgnoreCase(request.getMethod())) {
                url = handleGet(request, response, user);
            } else if ("POST".equalsIgnoreCase(request.getMethod())) {
                url = handlePost(request, response, user);
            } else {
                response.setStatus(
                        HttpServletResponse.SC_METHOD_NOT_ALLOWED);
                request.setAttribute(
                        "ERROR", "Phuong thuc request khong duoc ho tro.");
                url = LIST_URL;
            }

        } catch (Exception e) {
            log("Error at AlertServlet: " + e.getMessage(), e);
            request.setAttribute(
                    "ERROR", "Loi he thong, vui long thu lai.");
            url = LIST_URL;

        } finally {
            /*
             * Chi thuc hien mot thao tac dieu huong:
             * - REDIRECT_PREFIX: sendRedirect()
             * - Con lai: forward()
             */
            if (!response.isCommitted()) {
                if (url.startsWith(REDIRECT_PREFIX)) {
                    String path = url.substring(
                            REDIRECT_PREFIX.length());

                    response.sendRedirect(
                            request.getContextPath() + path);
                } else {
                    request.getRequestDispatcher(url)
                            .forward(request, response);
                }
            }
        }
    }

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
        processRequest(request, response);
    }

    // =========================================================
    // GET HANDLERS
    // =========================================================
    private String handleGet(
            HttpServletRequest request,
            HttpServletResponse response,
            AppUser user)
            throws ServletException, IOException {

        String path = request.getPathInfo();

        if (path == null || "/".equals(path)) {
            loadAlertList(request, user);
            return LIST_URL;
        }

        switch (path) {
            case "/view":
                return viewAlert(request, user);

            case "/create":
                if (!canManage(user)) {
                    return denyAccess(response);
                }

                loadFormData(request, user);
                request.setAttribute("NEXT_ALERT_ID", util.IdGenerator.nextAlertId());
                request.setAttribute("IS_EDIT", false);
                return FORM_URL;

            case "/edit":
                if (!canManage(user)) {
                    return denyAccess(response);
                }

                return editAlert(request, response, user);

            default:
                response.setStatus(
                        HttpServletResponse.SC_NOT_FOUND);
                request.setAttribute(
                        "ERROR", "Trang yeu cau khong ton tai.");
                loadAlertList(request, user);
                return LIST_URL;
        }
    }

    private String handlePost(
            HttpServletRequest request,
            HttpServletResponse response,
            AppUser user)
            throws ServletException, IOException {

        String path = request.getPathInfo();

        if (!canManage(user)) {
            return denyAccess(response);
        }

        if (path == null) {
            response.setStatus(
                    HttpServletResponse.SC_NOT_FOUND);
            request.setAttribute(
                    "ERROR", "Trang yeu cau khong ton tai.");
            loadAlertList(request, user);
            return LIST_URL;
        }

        switch (path) {
            case "/save":
                return saveAlert(request, response, user);

            case "/delete":
                return deleteAlert(request, response, user);

            case "/resolve":
                return resolveAlert(request, response, user);

            default:
                response.setStatus(
                        HttpServletResponse.SC_NOT_FOUND);
                request.setAttribute(
                        "ERROR", "Trang yeu cau khong ton tai.");
                loadAlertList(request, user);
                return LIST_URL;
        }
    }

    // =========================================================
    // ALERT LIST
    // =========================================================
    private void loadAlertList(
            HttpServletRequest request,
            AppUser user) {

        String searchId = value(request.getParameter("searchId"));
        String alertType = value(request.getParameter("alertType"));
        String status = value(request.getParameter("status"));

        String sortBy = normalizeSortBy(
                value(request.getParameter("sortBy")));

        String order = "ASC".equalsIgnoreCase(
                value(request.getParameter("order")))
                ? "ASC" : "DESC";

        int currentPage = Math.max(
                1, parseInt(request.getParameter("page"), 1));

        int totalRecords = countAlerts(
                user, searchId, alertType, status);

        int totalPages = Math.max(
                1, (int) Math.ceil(
                        totalRecords / (double) PAGE_SIZE));

        currentPage = Math.min(currentPage, totalPages);

        int offset = (currentPage - 1) * PAGE_SIZE;

        List<Alert> alerts = getPagedAlerts(
                user,
                searchId,
                alertType,
                status,
                sortBy,
                order,
                offset);

        request.setAttribute("LIST_ALERT", alerts);
        request.setAttribute("SEARCH_ID", searchId);
        request.setAttribute("ALERT_TYPE", alertType);
        request.setAttribute("STATUS", status);
        request.setAttribute("SORT_BY", sortBy);
        request.setAttribute("ORDER", order);
        request.setAttribute("CURRENT_PAGE", currentPage);
        request.setAttribute("TOTAL_PAGES", totalPages);
        request.setAttribute("TOTAL_RECORDS", totalRecords);
        request.setAttribute("PAGE_SIZE", PAGE_SIZE);
    }

    private int countAlerts(
            AppUser user,
            String searchId,
            String alertType,
            String status) {

        String role = roleOf(user);

        if (ROLE_ADMIN.equals(role)) {
            return alertDAO.countFiltered(
                    searchId, alertType, status);
        }

        if (ROLE_MANAGER.equals(role) || "SUP".equals(role) || "STF".equals(role) || "TEC".equals(role)) {
            return alertDAO.countFilteredByManager(
                    user.getUserId(),
                    searchId, alertType, status);
        }

        if (ROLE_USER.equals(role)) {
            return alertDAO.countFilteredByUser(
                    user.getUserId(),
                    searchId, alertType, status);
        }

        return alertDAO.countFilteredByRecipient(
                user.getUserId(),
                searchId, alertType, status);
    }

    private List<Alert> getPagedAlerts(
            AppUser user,
            String searchId,
            String alertType,
            String status,
            String sortBy,
            String order,
            int offset) {

        String role = roleOf(user);

        if (ROLE_ADMIN.equals(role)) {
            return alertDAO.getFilteredPaged(
                    searchId, alertType, status,
                    sortBy, order, offset, PAGE_SIZE);
        }

        if (ROLE_MANAGER.equals(role) || "SUP".equals(role) || "STF".equals(role) || "TEC".equals(role)) {
            return alertDAO.getFilteredByManagerPaged(
                    user.getUserId(),
                    searchId, alertType, status,
                    sortBy, order, offset, PAGE_SIZE);
        }

        if (ROLE_USER.equals(role)) {
            return alertDAO.getFilteredByUserPaged(
                    user.getUserId(),
                    searchId, alertType, status,
                    sortBy, order, offset, PAGE_SIZE);
        }

        return alertDAO.getFilteredByRecipientPaged(
                user.getUserId(),
                searchId, alertType, status,
                sortBy, order, offset, PAGE_SIZE);
    }

    // =========================================================
    // VIEW ALERT
    // =========================================================
    private String viewAlert(
            HttpServletRequest request,
            AppUser user) {

        String alertID = value(request.getParameter("id"));

        if (isBlank(alertID)) {
            request.setAttribute(
                    "ERROR", "Alert ID is required.");
            loadAlertList(request, user);
            return LIST_URL;
        }

        Alert alert = alertDAO.findByID(alertID);

        if (alert == null) {
            request.setAttribute(
                    "ERROR", "Alert does not exist.");
            loadAlertList(request, user);
            return LIST_URL;
        }

        if (!canAccess(user, alert)) {
            request.setAttribute(
                    "ERROR", "Ban khong co quyen truy cap alert nay.");
            return DENIED_URL;
        }

        if (!ROLE_USER.equals(roleOf(user))) {
            notificationDAO.markReadByRef(
                    user.getUserId(),
                    Notification.TYPE_ALERT,
                    alert.getAlertID());
        }

        request.setAttribute("ALERT", alert);
        return DETAIL_URL;
    }

    // =========================================================
    // EDIT ALERT
    // =========================================================
    private String editAlert(
            HttpServletRequest request,
            HttpServletResponse response,
            AppUser user) {

        String alertID = value(request.getParameter("id"));

        if (isBlank(alertID)) {
            request.setAttribute(
                    "ERROR", "Alert ID is required.");
            loadAlertList(request, user);
            return LIST_URL;
        }

        Alert alert = alertDAO.findByID(alertID);

        if (alert == null) {
            request.setAttribute(
                    "ERROR", "Alert does not exist.");
            loadAlertList(request, user);
            return LIST_URL;
        }

        if (!canAccess(user, alert)) {
            return denyAccess(response);
        }

        loadFormData(request, user);
        request.setAttribute("ALERT", alert);
        request.setAttribute("IS_EDIT", true);

        return FORM_URL;
    }

// =========================================================
// SAVE ALERT: CREATE OR UPDATE
// =========================================================
    private String saveAlert(
            HttpServletRequest request,
            HttpServletResponse response,
            AppUser user) {

        String submittedID = value(request.getParameter("alertID"));
        String binID = value(request.getParameter("binID"));
        String alertType = value(request.getParameter("alertType"));
        String message = value(request.getParameter("message"));

        boolean editMode = "true".equalsIgnoreCase(
                value(request.getParameter("isEdit")));

        // Auto-generated ID; no manual input required for creation
        String alertID = editMode ? submittedID : "";

        if (editMode && isBlank(alertID)) {
            return showFormError(
                    request, user, alertID, binID,
                    alertType, message, true,
                    "Alert ID is required when editing.");
        }

        String error = validate(
                alertID, binID, alertType, message, editMode);

        if (error != null) {
            return showFormError(
                    request, user, alertID, binID,
                    alertType, message, editMode, error);
        }

        Alert oldAlert = null;

        if (editMode) {
            oldAlert = alertDAO.findByID(alertID);

            if (oldAlert == null) {
                return showFormError(
                        request, user, alertID, binID,
                        alertType, message, true,
                        "Alert does not exist.");
            }

            if (!canAccess(user, oldAlert)) {
                return denyAccess(response);
            }
        }

        WasteBin bin = binDAO.findByID(binID);

        if (bin == null) {
            return showFormError(
                    request, user, alertID, binID,
                    alertType, message, editMode,
                    "The bin does not exist.");
        }

        if (ROLE_MANAGER.equals(roleOf(user))
                && !managerOwnsBin(user, binID)) {
            return showFormError(
                    request, user, alertID, binID,
                    alertType, message, editMode,
                    "You can only manage alerts for bins "
                    + "in your assigned area.");
        }

        Alert alert;

        if (editMode) {
            // Preserve original ID, createdDate and status
            alert = oldAlert;
        } else {
            alert = new Alert();

            // Generate next sequential alert ID (e.g. ALT-004)
            alertID = util.IdGenerator.nextAlertId();
            alert.setAlertID(alertID);
            alert.setCreatedDate(
                    new Timestamp(System.currentTimeMillis()));
            alert.setResolved(false);
        }

        alert.setBinID(binID);
        alert.setAlertType(alertType);
        alert.setMessage(message);

        if (editMode) {
            if (!alertDAO.update(alert)) {
                return showFormError(
                        request, user, alertID, binID,
                        alertType, message, true,
                        "Failed to update alert.");
            }
        } else {
            if (!alertDAO.insert(alert)) {
                return showFormError(
                        request, user, alertID, binID,
                        alertType, message, false,
                        "Failed to create alert.");
            }

            try {
                notifier.dispatchAlert(alert);
            } catch (Exception e) {
                log("Failed to dispatch alert notification.", e);
            }
        }

        return REDIRECT_PREFIX + "/alert";
    }

    private String showFormError(
            HttpServletRequest request,
            AppUser user,
            String alertID,
            String binID,
            String alertType,
            String message,
            boolean editMode,
            String error) {

        Alert alert = new Alert();
        alert.setAlertID(alertID);
        alert.setBinID(binID);
        alert.setAlertType(alertType);
        alert.setMessage(message);

        request.setAttribute("ERROR", error);
        request.setAttribute("ALERT", alert);
        request.setAttribute("IS_EDIT", editMode);

        loadFormData(request, user);

        return FORM_URL;
    }

    // =========================================================
    // DELETE ALERT
    // =========================================================
    private String deleteAlert(
            HttpServletRequest request,
            HttpServletResponse response,
            AppUser user) {

        String alertID = value(request.getParameter("id"));

        if (isBlank(alertID)) {
            request.setAttribute(
                    "ERROR", "Alert ID is required.");
            loadAlertList(request, user);
            return LIST_URL;
        }

        Alert alert = alertDAO.findByID(alertID);

        if (alert == null) {
            request.setAttribute(
                    "ERROR", "Alert does not exist.");
            loadAlertList(request, user);
            return LIST_URL;
        }

        if (!canAccess(user, alert)) {
            return denyAccess(response);
        }

        if (!alertDAO.delete(alertID)) {
            request.setAttribute(
                    "ERROR", "Failed to delete alert.");
            loadAlertList(request, user);
            return LIST_URL;
        }

        try {
            notifier.removeFor(Notification.TYPE_ALERT, alertID);
        } catch (Exception e) {
            log("Failed to remove alert notifications.", e);
        }

        return REDIRECT_PREFIX + "/alert";
    }

    // =========================================================
    // RESOLVE ALERT
    // =========================================================
    private String resolveAlert(
            HttpServletRequest request,
            HttpServletResponse response,
            AppUser user) {

        String alertID = value(request.getParameter("id"));
        String resolvedValue = value(
                request.getParameter("resolved"));

        if (isBlank(alertID)) {
            request.setAttribute(
                    "ERROR", "Alert ID is required.");
            loadAlertList(request, user);
            return LIST_URL;
        }

        if (!"true".equalsIgnoreCase(resolvedValue)
                && !"false".equalsIgnoreCase(resolvedValue)) {
            request.setAttribute(
                    "ERROR", "Invalid resolved value.");
            loadAlertList(request, user);
            return LIST_URL;
        }

        Alert alert = alertDAO.findByID(alertID);

        if (alert == null) {
            request.setAttribute(
                    "ERROR", "Alert does not exist.");
            loadAlertList(request, user);
            return LIST_URL;
        }

        if (!canAccess(user, alert)) {
            return denyAccess(response);
        }

        boolean resolved = Boolean.parseBoolean(resolvedValue);

        if (!alertDAO.setResolved(alertID, resolved)) {
            request.setAttribute(
                    "ERROR", "Failed to update alert status.");
            loadAlertList(request, user);
            return LIST_URL;
        }

        return REDIRECT_PREFIX + "/alert";
    }

    // =========================================================
    // FORM DATA
    // =========================================================
    private void loadFormData(
            HttpServletRequest request,
            AppUser user) {

        List<WasteBin> bins;

        if (ROLE_MANAGER.equals(roleOf(user))) {
            String areaID = getCurrentManagerAreaID(user);

            if (areaID == null) {
                bins = Collections.emptyList();
            } else {
                bins = binDAO.getByAreas(
                        Collections.singletonList(areaID));
            }
        } else {
            bins = binDAO.getAll();
        }

        request.setAttribute("LIST_BIN", bins);
    }

    // =========================================================
    // VALIDATION
    // =========================================================
    private String validate(
            String alertID,
            String binID,
            String alertType,
            String message,
            boolean editMode) {

        if ((editMode && isBlank(alertID))
                || isBlank(binID)
                || isBlank(alertType)
                || isBlank(message)) {
            return "All required fields must be provided.";
        }

        if (editMode && alertID.length() > 50) {
            return "Alert ID must not exceed 50 characters.";
        }

        if (binID.length() > 50) {
            return "Bin ID must not exceed 50 characters.";
        }

        if (alertType.length() > 50) {
            return "Alert type must not exceed 50 characters.";
        }

        if (message.length() > 500) {
            return "Message must not exceed 500 characters.";
        }

        return null;
    }

    // =========================================================
    // AUTHORIZATION
    // =========================================================
    private AppUser getSessionUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);

        if (session == null) {
            return null;
        }

        Object user = session.getAttribute("user");

        return user instanceof AppUser ? (AppUser) user : null;
    }

    private boolean canManage(AppUser user) {
        String role = roleOf(user);

        return ROLE_ADMIN.equals(role)
                || ROLE_MANAGER.equals(role);
    }

    private boolean canAccess(AppUser user, Alert alert) {
        if (user == null || alert == null) {
            return false;
        }

        String role = roleOf(user);

        if (ROLE_ADMIN.equals(role)) {
            return true;
        }

        if (ROLE_MANAGER.equals(role)) {
            return managerOwnsBin(user, alert.getBinID());
        }

        if (ROLE_USER.equals(role)) {
            return alertDAO.isBinTrackedByUser(
                    user.getUserId(), alert.getBinID());
        }

        return alertDAO.isRecipient(
                alert.getAlertID(), user.getUserId());
    }

    private String getCurrentManagerAreaID(AppUser sessionUser) {
        if (sessionUser == null
                || !ROLE_MANAGER.equals(roleOf(sessionUser))) {
            return null;
        }

        AppUser manager
                = userDAO.findById(sessionUser.getUserId());

        if (manager == null
                || !ROLE_MANAGER.equals(roleOf(manager))) {
            return null;
        }

        String areaID = value(manager.getAreaID());

        return isBlank(areaID) ? null : areaID;
    }

    private boolean managerOwnsBin(
            AppUser manager,
            String binID) {

        if (manager == null || isBlank(binID)) {
            return false;
        }

        String areaID = getCurrentManagerAreaID(manager);

        if (areaID == null) {
            return false;
        }

        WasteBin bin = binDAO.findByID(binID);

        if (bin == null) {
            return false;
        }

        String binAreaID = value(bin.getAreaID());

        return !isBlank(binAreaID)
                && areaID.equalsIgnoreCase(binAreaID);
    }

    // =========================================================
    // UTILITY
    // =========================================================
    private String denyAccess(HttpServletResponse response) {
        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
        return DENIED_URL;
    }

    private String normalizeSortBy(String sortBy) {
        if ("alertType".equals(sortBy)
                || "createdDate".equals(sortBy)
                || "status".equals(sortBy)) {
            return sortBy;
        }

        return "createdDate";
    }

    private String roleOf(AppUser user) {
        if (user == null || user.getRoleId() == null) {
            return "";
        }

        return user.getRoleId().trim().toUpperCase();
    }

    private String value(String input) {
        return input == null ? "" : input.trim();
    }

    private boolean isBlank(String input) {
        return input == null || input.trim().isEmpty();
    }

    private int parseInt(String input, int fallback) {
        try {
            return Integer.parseInt(value(input));
        } catch (NumberFormatException e) {
            return fallback;
        }
    }
}
