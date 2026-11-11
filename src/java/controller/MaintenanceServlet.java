package controller;

import dao.AuditLogDAO;
import dao.CollectionDAO;
import dao.MaintenanceDAO;
import dao.NotificationDAO;
import dao.UserDAO;
import dao.WasteBinDAO;

import model.AppUser;
import model.CollectionRequest;
import model.Maintenance;
import model.Notification;
import model.WasteBin;

import service.NotificationService;
import util.Web;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Set;


@WebServlet("/maintenance/*")
public class MaintenanceServlet extends HttpServlet {

    private static final String LIST
            = "/WEB-INF/views/maintenanceList.jsp";

    private static final String FORM
            = "/WEB-INF/views/maintenanceForm.jsp";

    private static final String DETAIL
            = "/WEB-INF/views/maintenanceDetail.jsp";

    private static final String DENIED
            = "/WEB-INF/views/denied.jsp";

    private final MaintenanceDAO maintenanceDAO
            = new MaintenanceDAO();

    private final WasteBinDAO binDAO
            = new WasteBinDAO();

    private final UserDAO userDAO
            = new UserDAO();

    private final CollectionDAO collectionDAO
            = new CollectionDAO();

    private final NotificationDAO notificationDAO
            = new NotificationDAO();

    private final NotificationService notifier
            = new NotificationService();

    @Override
    protected void doGet(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        processRequest(req, resp);
    }

    @Override
    protected void doPost(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        processRequest(req, resp);
    }

    // =====================================================
    // PROCESS REQUEST
    // =====================================================
    private void processRequest(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        String url = LIST;

        try {
            AppUser user = getCurrentUser(req);

            if (user == null) {
                url = "redirect:" + req.getContextPath() + "/login";

            } else {
                String path = req.getPathInfo();
                String method = req.getMethod();

                if ("GET".equalsIgnoreCase(method)) {

                    if (path == null || "/".equals(path)) {
                        url = showList(req, user);

                    } else if ("/view".equals(path)) {
                        url = view(req, user);

                    } else if ("/create".equals(path)) {
                        url = createForm(req, user);

                    } else if ("/edit".equals(path)) {
                        url = editForm(req, user);

                    } else {
                        url = DENIED;
                        resp.setStatus(
                                HttpServletResponse.SC_FORBIDDEN);
                    }

                } else if ("POST".equalsIgnoreCase(method)) {

                    if ("/save".equals(path)) {
                        url = save(req, user);

                    } else if ("/delete".equals(path)) {
                        url = delete(req, user);

                    } else {
                        url = DENIED;
                        resp.setStatus(
                                HttpServletResponse.SC_FORBIDDEN);
                    }

                } else {
                    resp.sendError(
                            HttpServletResponse.SC_METHOD_NOT_ALLOWED);
                    url = null;
                }
            }

        } catch (Exception e) {
            log("Error processing MaintenanceServlet request", e);

            if (!resp.isCommitted()) {
                req.setAttribute(
                        "ERROR",
                        "An error occurred while processing the maintenance request.");

                url = LIST;
            } else {
                url = null;
            }

        } finally {
            if (url != null && !resp.isCommitted()) {

                if (url.startsWith("redirect:")) {
                    resp.sendRedirect(
                            url.substring("redirect:".length()));

                } else {
                    req.getRequestDispatcher(url)
                            .forward(req, resp);
                }
            }
        }
    }

    // =====================================================
    // MAINTENANCE LIST
    // =====================================================
    private String showList(
            HttpServletRequest req,
            AppUser user)
            throws Exception {

        String role = user.getRoleId();
        String userID = user.getUserId();

        if (!isAllowedToViewList(role)) {
            return DENIED;
        }

        String searchId = safe(req.getParameter("searchId"));
        String technicianID
                = safe(req.getParameter("technicianID"));
        String maintenanceType
                = safe(req.getParameter("maintenanceType"));
        String status = safe(req.getParameter("status"));
        String sortBy = safe(req.getParameter("sortBy"));
        String order = safe(req.getParameter("order"));

        if (!isValidSortBy(sortBy)) {
            sortBy = "scheduledDate";
        }

        if (!"ASC".equalsIgnoreCase(order)
                && !"DESC".equalsIgnoreCase(order)) {
            order = "DESC";
        }

        List<String> staffBinIDs = null;
        int totalRecords;

        if ("STF".equals(role)) {
            // Staff only sees maintenance for assigned collection bins.
            technicianID = "";
            maintenanceType = "";
            status = "";

            staffBinIDs = getStaffBinIDs(userID);

            totalRecords = maintenanceDAO.countFilteredByBins(
                    staffBinIDs,
                    searchId);

        } else if ("TEC".equals(role)) {
            totalRecords
                    = maintenanceDAO.countFilteredByTechnician(
                            userID,
                            searchId,
                            technicianID,
                            maintenanceType,
                            status);

        } else if ("MGR".equals(role) || "SUP".equals(role)) {
            totalRecords
                    = maintenanceDAO.countFilteredByManager(
                            userID,
                            searchId,
                            technicianID,
                            maintenanceType,
                            status);

        } else {
            totalRecords = maintenanceDAO.countFiltered(
                    searchId,
                    technicianID,
                    maintenanceType,
                    status);
        }

        int pageSize = 10;
        int currentPage = parsePositiveInt(
                req.getParameter("page"), 1);

        int totalPages = Math.max(
                1,
                (int) Math.ceil(
                        totalRecords / (double) pageSize));

        if (currentPage > totalPages) {
            currentPage = totalPages;
        }

        int offset = (currentPage - 1) * pageSize;

        List<Maintenance> list;

        if ("STF".equals(role)) {
            list = maintenanceDAO.getFilteredByBinsPaged(
                    staffBinIDs,
                    searchId,
                    sortBy,
                    order,
                    offset,
                    pageSize);

        } else if ("TEC".equals(role)) {
            list = maintenanceDAO.getFilteredByTechnicianPaged(
                    userID,
                    searchId,
                    technicianID,
                    maintenanceType,
                    status,
                    sortBy,
                    order,
                    offset,
                    pageSize);

        } else if ("MGR".equals(role) || "SUP".equals(role)) {
            list = maintenanceDAO.getFilteredByManagerPaged(
                    userID,
                    searchId,
                    technicianID,
                    maintenanceType,
                    status,
                    sortBy,
                    order,
                    offset,
                    pageSize);

        } else {
            list = maintenanceDAO.getFilteredPaged(
                    searchId,
                    technicianID,
                    maintenanceType,
                    status,
                    sortBy,
                    order,
                    offset,
                    pageSize);
        }

        if ("TEC".equals(role)) {
            double fixSuccessRate = maintenanceDAO.getTechnicianFixSuccessRate(userID);
            double mttrHours = maintenanceDAO.getTechnicianMTTRHours(userID);
            req.setAttribute("FIX_SUCCESS_RATE", fixSuccessRate);
            req.setAttribute("MTTR_HOURS", mttrHours);
        }

        req.setAttribute("LIST_MAINTENANCE", list);
        req.setAttribute("SEARCH_ID", searchId);
        req.setAttribute("TECHNICIAN_ID", technicianID);
        req.setAttribute("MAINTENANCE_TYPE", maintenanceType);
        req.setAttribute("STATUS", status);
        req.setAttribute("SORT_BY", sortBy);
        req.setAttribute("ORDER", order);
        req.setAttribute("CURRENT_PAGE", currentPage);
        req.setAttribute("TOTAL_PAGES", totalPages);
        req.setAttribute("TOTAL_RECORDS", totalRecords);
        req.setAttribute("PAGE_SIZE", pageSize);

        return LIST;
    }

    private boolean isAllowedToViewList(String role) {
        return "ADM".equals(role)
                || "MGR".equals(role)
                || "TEC".equals(role)
                || "STF".equals(role)
                || "SUP".equals(role)
                || "SAD".equals(role);
    }

    private boolean isValidSortBy(String sortBy) {
        return "status".equals(sortBy)
                || "maintenanceType".equals(sortBy)
                || "completedDate".equals(sortBy)
                || "scheduledDate".equals(sortBy);
    }

    // =====================================================
    // VIEW MAINTENANCE
    // =====================================================
    private String view(
            HttpServletRequest req,
            AppUser user)
            throws Exception {

        String id = safe(req.getParameter("id"));

        if (id.isEmpty()) {
            return redirectToList(req);
        }

        Maintenance maintenance
                = maintenanceDAO.findByID(id);

        if (maintenance == null) {
            return redirectToList(req);
        }

        if (!canAccessMaintenance(user, maintenance)) {
            return DENIED;
        }

        notificationDAO.markReadByRef(
                user.getUserId(),
                Notification.TYPE_MAINTENANCE,
                maintenance.getMaintenanceID());

        req.setAttribute("MAINTENANCE", maintenance);

        return DETAIL;
    }

    // =====================================================
    // CREATE FORM
    // =====================================================
    private String createForm(
            HttpServletRequest req,
            AppUser user)
            throws Exception {

        String role = user.getRoleId();

        if (!"ADM".equals(role) && !"MGR".equals(role) && !"SUP".equals(role) && !"SAD".equals(role) && !"STF".equals(role) && !"TEC".equals(role)) {
            return DENIED;
        }

        Maintenance maintenance = new Maintenance();
        // Prefill next sequential maintenance ID (e.g. MNT-007)
        maintenance.setMaintenanceID(util.IdGenerator.nextMaintenanceId());
        maintenance.setStatus("Pending");
        if ("TEC".equals(role)) {
            maintenance.setTechnicianID(user.getUserId());
        }
        maintenance.setScheduledDate(null);
        maintenance.setCompletedDate(null);

        loadFormData(req, user);

        req.setAttribute("MAINTENANCE", maintenance);
        req.setAttribute("MODE", "CREATE");

        return FORM;
    }

    // =====================================================
    // EDIT FORM
    // =====================================================
    private String editForm(
            HttpServletRequest req,
            AppUser user)
            throws Exception {

        String id = safe(req.getParameter("id"));

        if (id.isEmpty()) {
            return redirectToList(req);
        }

        Maintenance maintenance
                = maintenanceDAO.findByID(id);

        if (maintenance == null) {
            return redirectToList(req);
        }

        if (!canEditMaintenance(user, maintenance)) {
            return DENIED;
        }

        loadFormData(req, user);

        // Ensure the selected bin is always present in LIST_BIN
        @SuppressWarnings("unchecked")
        List<WasteBin> formBins = (List<WasteBin>) req.getAttribute("LIST_BIN");
        if (formBins != null && maintenance.getBinID() != null && !maintenance.getBinID().trim().isEmpty()) {
            boolean found = false;
            for (WasteBin b : formBins) {
                if (b.getBinID() != null && b.getBinID().equalsIgnoreCase(maintenance.getBinID().trim())) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                WasteBin targetBin = binDAO.findByID(maintenance.getBinID().trim());
                if (targetBin != null) {
                    formBins.add(0, targetBin);
                }
            }
        }

        req.setAttribute("MAINTENANCE", maintenance);
        req.setAttribute("MODE", "EDIT");

        return FORM;
    }

    // =====================================================
    // SAVE MAINTENANCE
    // =====================================================
    private String save(
            HttpServletRequest req,
            AppUser user)
            throws Exception {

        String role = user.getRoleId();

        String maintenanceID
                = safe(req.getParameter("maintenanceID"));
        String binID = safe(req.getParameter("binID"));
        String technicianID
                = safe(req.getParameter("technicianID"));
        String maintenanceType
                = safe(req.getParameter("maintenanceType"));
        String status = safe(req.getParameter("status"));
        String scheduledDate
                = safe(req.getParameter("scheduledDate"));
        String completedDate
                = safe(req.getParameter("completedDate"));
        String description = req.getParameter("description");
        String resolutionNotes = req.getParameter("resolutionNotes");
        String rootCause = req.getParameter("rootCause");
        String repairMethod = req.getParameter("repairMethod");
        String replacedParts = req.getParameter("replacedParts");

        boolean isCreate = maintenanceID.isEmpty();

        if (!"ADM".equals(role)
                && !"MGR".equals(role)
                && !"TEC".equals(role)
                && !"SUP".equals(role)
                && !"SAD".equals(role)
                && !"STF".equals(role)) {
            return DENIED;
        }

        Maintenance old = null;

        if (!isCreate) {
            old = maintenanceDAO.findByID(maintenanceID);

            if (old == null) {
                return formError(
                        req,
                        user,
                        null,
                        "Maintenance record does not exist.");
            }
        }

        // Staff may only create new maintenance tickets for bins in their assigned area.
        if ("STF".equals(role)) {
            if (!isCreate) {
                return DENIED;
            }
            if (binID.isEmpty() || !isManagerOfBin(user, binID)) {
                return formError(
                        req,
                        user,
                        null,
                        "You can only submit maintenance requests for bins in your assigned area.");
            }
            status = "Pending";
            if (technicianID.isEmpty()) {
                WasteBin targetBin = binDAO.findByID(binID);
                if (targetBin != null && targetBin.getAreaID() != null) {
                    List<AppUser> techs = getTechniciansByArea(targetBin.getAreaID());
                    if (!techs.isEmpty()) {
                        technicianID = techs.get(0).getUserId();
                    }
                }
            }
        }

        // Technician may create or update their assigned maintenance.
        if ("TEC".equals(role)) {
            if (isCreate) {
                technicianID = user.getUserId();
            } else {
                if (old == null
                        || !user.getUserId().equals(
                                old.getTechnicianID())) {
                    return DENIED;
                }

                // Do not allow technicians to change assignment or schedule.
                binID = safe(old.getBinID());
                technicianID = safe(old.getTechnicianID());
                maintenanceType = safe(old.getMaintenanceType());
                scheduledDate = old.getScheduledDate() == null
                        ? ""
                        : toDateTimeLocal(old.getScheduledDate());
            }
        }

        // Manager / Supervisor may edit only records in their own area.
        if ("MGR".equals(role) || "SUP".equals(role)) {
            if (old != null
                    && !isManagerOfBin(user, old.getBinID())) {
                return DENIED;
            }

            if (binID.isEmpty()
                    || !isManagerOfBin(user, binID)) {
                return formError(
                        req,
                        user,
                        null,
                        "You can only manage maintenance for bins in your area.");
            }
        }

        if (binID.isEmpty()
                || technicianID.isEmpty()
                || maintenanceType.isEmpty()
                || status.isEmpty()) {
            return formError(
                    req,
                    user,
                    null,
                    "Please enter all required information.");
        }

        WasteBin selectedBin = binDAO.findByID(binID);

        if (selectedBin == null) {
            return formError(
                    req,
                    user,
                    null,
                    "The selected Waste Bin is invalid.");
        }

        if (!isValidStatus(status)) {
            return formError(
                    req,
                    user,
                    null,
                    "Invalid maintenance status.");
        }

        if (!isValidType(maintenanceType)) {
            return formError(
                    req,
                    user,
                    null,
                    "Invalid maintenance type.");
        }

        AppUser technician = userDAO.findById(technicianID);

        if (technician == null
                || !"TEC".equals(technician.getRoleId())) {
            return formError(
                    req,
                    user,
                    null,
                    "The selected technician is invalid.");
        }

        if (("MGR".equals(role) || "SUP".equals(role))
                && !isTechnicianOfArea(
                        technicianID,
                        selectedBin.getAreaID())) {
            return formError(
                    req,
                    user,
                    null,
                    "The selected technician does not belong to the bin's area.");
        }

        Timestamp scheduledTimestamp
                = parseTimestamp(scheduledDate);

        Timestamp completedTimestamp
                = parseTimestamp(completedDate);

        if (!scheduledDate.isEmpty()
                && scheduledTimestamp == null) {
            return formError(
                    req,
                    user,
                    null,
                    "Invalid scheduled date.");
        }

        if (!completedDate.isEmpty()
                && completedTimestamp == null) {
            return formError(
                    req,
                    user,
                    null,
                    "Invalid completed date.");
        }

        if ("Completed".equals(status)
                && completedTimestamp == null) {
            completedTimestamp
                    = new Timestamp(System.currentTimeMillis());
        }

        if (!"Completed".equals(status)) {
            completedTimestamp = null;
        }

        Maintenance maintenance = new Maintenance();

        // Generate next sequential maintenance ID (e.g. MNT-007)
        maintenance.setMaintenanceID(
                isCreate
                        ? util.IdGenerator.nextMaintenanceId()
                        : maintenanceID);

        maintenance.setBinID(binID);
        maintenance.setTechnicianID(technicianID);
        maintenance.setMaintenanceType(maintenanceType);
        maintenance.setStatus(status);
        maintenance.setScheduledDate(scheduledTimestamp);
        maintenance.setCompletedDate(completedTimestamp);
        maintenance.setDescription(description);
        maintenance.setResolutionNotes(resolutionNotes);
        maintenance.setRootCause(rootCause);
        maintenance.setRepairMethod(repairMethod);
        maintenance.setReplacedParts(replacedParts);

        if (scheduledTimestamp == null && isCreate) {
            scheduledTimestamp = new Timestamp(System.currentTimeMillis() + 86400000L);
            maintenance.setScheduledDate(scheduledTimestamp);
        }

        boolean success;

        if (isCreate) {
            if (!"ADM".equals(role) && !"MGR".equals(role) && !"SUP".equals(role) && !"SAD".equals(role) && !"STF".equals(role) && !"TEC".equals(role)) {
                return DENIED;
            }

            success = maintenanceDAO.insert(maintenance);

            if (success) {
                AuditLogDAO.log(
                        user.getUserId(),
                        "CREATE_MAINTENANCE",
                        "tblMaintenance",
                        maintenance.getMaintenanceID(),
                        null,
                        "Created " + maintenanceType + " request for Bin " + binID,
                        req.getRemoteAddr()
                );
                notifier.maintenanceAssigned(maintenance);
            }

        } else {
            success = maintenanceDAO.update(maintenance);

            if (success) {
                notifyAfterUpdate(
                        old,
                        maintenance,
                        user,
                        role);
            }
        }

        if (!success) {
            return formError(
                    req,
                    user,
                    maintenance,
                    "Unable to save maintenance.");
        }

        return "redirect:"
                + req.getContextPath()
                + "/maintenance";
    }

    // =====================================================
    // FORM ERROR
    // =====================================================
    private String formError(
            HttpServletRequest req,
            AppUser user,
            Maintenance submitted,
            String message)
            throws Exception {

        Maintenance maintenance = submitted;

        if (maintenance == null) {
            maintenance = new Maintenance();

            maintenance.setMaintenanceID(
                    safe(req.getParameter("maintenanceID")));
            maintenance.setBinID(
                    safe(req.getParameter("binID")));
            maintenance.setTechnicianID(
                    safe(req.getParameter("technicianID")));
            maintenance.setMaintenanceType(
                    safe(req.getParameter("maintenanceType")));
            maintenance.setStatus(
                    safe(req.getParameter("status")));
            maintenance.setScheduledDate(
                    parseTimestamp(
                            req.getParameter("scheduledDate")));
            maintenance.setCompletedDate(
                    parseTimestamp(
                            req.getParameter("completedDate")));
            maintenance.setDescription(
                    req.getParameter("description"));
            maintenance.setResolutionNotes(
                    req.getParameter("resolutionNotes"));
            maintenance.setRootCause(
                    req.getParameter("rootCause"));
            maintenance.setRepairMethod(
                    req.getParameter("repairMethod"));
            maintenance.setReplacedParts(
                    req.getParameter("replacedParts"));
        }

        req.setAttribute("ERROR", message);
        req.setAttribute("MAINTENANCE", maintenance);

        String id = safe(maintenance.getMaintenanceID());

        req.setAttribute(
                "MODE",
                id.isEmpty() ? "CREATE" : "EDIT");

        loadFormData(req, user);

        // Ensure the selected bin is always present in LIST_BIN on validation error
        @SuppressWarnings("unchecked")
        List<WasteBin> formBins = (List<WasteBin>) req.getAttribute("LIST_BIN");
        if (formBins != null && maintenance.getBinID() != null && !maintenance.getBinID().trim().isEmpty()) {
            boolean found = false;
            for (WasteBin b : formBins) {
                if (b.getBinID() != null && b.getBinID().equalsIgnoreCase(maintenance.getBinID().trim())) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                WasteBin targetBin = binDAO.findByID(maintenance.getBinID().trim());
                if (targetBin != null) {
                    formBins.add(0, targetBin);
                }
            }
        }

        return FORM;
    }

    // =====================================================
    // DELETE MAINTENANCE
    // =====================================================
    private String delete(
            HttpServletRequest req,
            AppUser user)
            throws Exception {

        String role = user.getRoleId();

        if (!"ADM".equals(role) && !"MGR".equals(role)) {
            return DENIED;
        }

        String id = safe(req.getParameter("id"));

        if (id.isEmpty()) {
            return redirectToList(req);
        }

        Maintenance maintenance
                = maintenanceDAO.findByID(id);

        if (maintenance == null) {
            return redirectToList(req);
        }

        if ("MGR".equals(role)
                && !isManagerOfBin(user, maintenance.getBinID())) {
            return DENIED;
        }

        if (maintenanceDAO.delete(id)) {
            notifier.removeFor(
                    Notification.TYPE_MAINTENANCE,
                    id);
        }

        return redirectToList(req);
    }

    // =====================================================
    // LOAD FORM DATA
    // =====================================================
    private void loadFormData(
            HttpServletRequest req,
            AppUser user)
            throws Exception {

        List<WasteBin> bins;
        List<AppUser> technicians;

        if ("MGR".equals(user.getRoleId()) || "SUP".equals(user.getRoleId()) || "STF".equals(user.getRoleId())) {
            List<String> managerAreaIDs = getManagerAreaIDs(user.getUserId());
            if (managerAreaIDs.isEmpty()) {
                bins = binDAO.getAll();
                technicians = userDAO.search("", "TEC");
            } else {
                bins = new ArrayList<WasteBin>();
                technicians = new ArrayList<AppUser>();
                for (String aId : managerAreaIDs) {
                    bins.addAll(getBinsByArea(aId));
                    technicians.addAll(getTechniciansByArea(aId));
                }
            }
        } else {
            bins = binDAO.getAll();
            technicians = userDAO.search("", "TEC");
        }

        req.setAttribute("LIST_BIN", bins);
        req.setAttribute("LIST_TECHNICIAN", technicians);
    }

    // =====================================================
    // NOTIFICATIONS AFTER UPDATE
    // =====================================================
    private void notifyAfterUpdate(
            Maintenance old,
            Maintenance updated,
            AppUser actor,
            String role) {

        boolean technicianChanged
                = !safe(updated.getTechnicianID()).equals(
                        safe(old.getTechnicianID()));

        boolean statusChanged
                = !safe(updated.getStatus()).equals(
                        safe(old.getStatus()));

        boolean descriptionChanged
                = !safe(updated.getDescription()).equals(
                        safe(old.getDescription()));

        if ("TEC".equals(role)) {
            if (statusChanged || descriptionChanged) {
                notifier.maintenanceUpdatedByTechnician(
                        updated,
                        actor.getUserId());
            }
            return;
        }

        if (technicianChanged) {
            notifier.maintenanceAssigned(updated);
            return;
        }

        if (statusChanged) {
            notifier.maintenanceChangedByManager(
                    updated,
                    actor.getUserId());
        }
    }

    // =====================================================
    // STAFF COLLECTION BIN IDS
    // =====================================================
    private List<String> getStaffBinIDs(String staffID) throws SQLException, ClassNotFoundException {
        List<CollectionRequest> collections
                = collectionDAO.getByStaff(staffID);

        Set<String> binIDs = new HashSet<String>();

        if (collections != null) {
            for (CollectionRequest collection : collections) {
                String binID = safe(collection.getBinID());

                if (!binID.isEmpty()) {
                    binIDs.add(binID);
                }
            }
        }

        return new ArrayList<String>(binIDs);
    }

    // =====================================================
    // KEEP EXISTING HELPER: STAFF MAINTENANCE FILTER
    // =====================================================
    private List<Maintenance> getByStaffCollection(
            String staffID) throws ClassNotFoundException, SQLException {

        List<Maintenance> all = maintenanceDAO.getAll();
        List<CollectionRequest> collections
                = collectionDAO.getByStaff(staffID);

        Set<String> binIDs = new HashSet<String>();

        if (collections != null) {
            for (CollectionRequest collection : collections) {
                String binID = safe(collection.getBinID());

                if (!binID.isEmpty()) {
                    binIDs.add(binID);
                }
            }
        }

        List<Maintenance> result
                = new ArrayList<Maintenance>();

        if (all != null) {
            for (Maintenance maintenance : all) {
                if (binIDs.contains(safe(maintenance.getBinID()))) {
                    result.add(maintenance);
                }
            }
        }

        return result;
    }

    // =====================================================
    // KEEP EXISTING HELPER: IN-MEMORY FILTERS
    // =====================================================
    private List<Maintenance> applyFilters(
            List<Maintenance> source,
            String searchId,
            String technicianID,
            String maintenanceType,
            String status,
            String sortBy,
            String order) {

        List<Maintenance> result
                = new ArrayList<Maintenance>();

        if (source == null) {
            return result;
        }

        String search = safe(searchId).toLowerCase();
        String technician = safe(technicianID).toLowerCase();
        String type = safe(maintenanceType);
        String currentStatus = safe(status);

        for (Maintenance maintenance : source) {
            String maintenanceID
                    = safe(maintenance.getMaintenanceID()).toLowerCase();
            String binID
                    = safe(maintenance.getBinID()).toLowerCase();
            String currentTechnician
                    = safe(maintenance.getTechnicianID()).toLowerCase();

            if (!search.isEmpty()
                    && !maintenanceID.contains(search)
                    && !binID.contains(search)) {
                continue;
            }

            if (!technician.isEmpty()
                    && !currentTechnician.contains(technician)) {
                continue;
            }

            if (!type.isEmpty()
                    && !type.equals(
                            safe(maintenance.getMaintenanceType()))) {
                continue;
            }

            if (!currentStatus.isEmpty()
                    && !currentStatus.equals(
                            safe(maintenance.getStatus()))) {
                continue;
            }

            result.add(maintenance);
        }

        sortMaintenance(result, sortBy, order);

        return result;
    }

    // =====================================================
    // KEEP EXISTING HELPER: SORT
    // =====================================================
    private void sortMaintenance(
            List<Maintenance> list,
            String sortBy,
            String order) {

        Comparator<Maintenance> comparator;

        if ("status".equals(sortBy)) {
            comparator = new Comparator<Maintenance>() {
                @Override
                public int compare(Maintenance a, Maintenance b) {
                    return safe(a.getStatus()).compareToIgnoreCase(
                            safe(b.getStatus()));
                }
            };

        } else if ("maintenanceType".equals(sortBy)) {
            comparator = new Comparator<Maintenance>() {
                @Override
                public int compare(Maintenance a, Maintenance b) {
                    return safe(a.getMaintenanceType()).compareToIgnoreCase(
                            safe(b.getMaintenanceType()));
                }
            };

        } else if ("completedDate".equals(sortBy)) {
            comparator = new Comparator<Maintenance>() {
                @Override
                public int compare(Maintenance a, Maintenance b) {
                    return compareTimestamp(
                            a.getCompletedDate(),
                            b.getCompletedDate());
                }
            };

        } else {
            comparator = new Comparator<Maintenance>() {
                @Override
                public int compare(Maintenance a, Maintenance b) {
                    return compareTimestamp(
                            a.getScheduledDate(),
                            b.getScheduledDate());
                }
            };
        }

        Collections.sort(list, comparator);

        if ("DESC".equalsIgnoreCase(order)) {
            Collections.reverse(list);
        }
    }

    private int compareTimestamp(Timestamp a, Timestamp b) {
        if (a == null && b == null) {
            return 0;
        }

        if (a == null) {
            return -1;
        }

        if (b == null) {
            return 1;
        }

        return a.compareTo(b);
    }

    // =====================================================
    // ACCESS CONTROL
    // =====================================================
    private boolean canAccessMaintenance(
            AppUser user,
            Maintenance maintenance)
            throws Exception {

        String role = user.getRoleId();

        if ("ADM".equals(role) || "SAD".equals(role)) {
            return true;
        }

        if ("MGR".equals(role) || "SUP".equals(role)) {
            return isManagerOfBin(user, maintenance.getBinID());
        }

        if ("TEC".equals(role)) {
            return user.getUserId().equals(
                    maintenance.getTechnicianID());
        }

        if ("STF".equals(role)) {
            return hasStaffCollectionAssignment(
                    user.getUserId(),
                    maintenance.getBinID());
        }

        return false;
    }

    private boolean canEditMaintenance(
            AppUser user,
            Maintenance maintenance)
            throws Exception {

        String role = user.getRoleId();

        if ("ADM".equals(role) || "SAD".equals(role)) {
            return true;
        }

        if ("MGR".equals(role) || "SUP".equals(role)) {
            return isManagerOfBin(user, maintenance.getBinID());
        }

        if ("TEC".equals(role)) {
            return user.getUserId().equals(
                    maintenance.getTechnicianID());
        }

        return false;
    }

    // =====================================================
    // STAFF ACCESS TO A BIN
    // =====================================================
    private boolean hasStaffCollectionAssignment(
            String staffID,
            String binID) throws SQLException, ClassNotFoundException {

        if (binID == null || binID.trim().isEmpty()) {
            return false;
        }

        List<CollectionRequest> collections
                = collectionDAO.getByStaff(staffID);

        if (collections == null) {
            return false;
        }

        for (CollectionRequest collection : collections) {
            if (binID.equals(collection.getBinID())) {
                return true;
            }
        }

        return false;
    }

    // =====================================================
    // MANAGER AREA
    // =====================================================
    private List<String> getManagerAreaIDs(String managerID) {
        List<String> list = new ArrayList<String>();
        if (managerID == null || managerID.trim().isEmpty()) {
            return list;
        }
        try {
            list.addAll(userDAO.getAssignedAreaIds(managerID.trim()));
            AppUser manager = userDAO.findById(managerID.trim());
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

    private String getManagerAreaID(String managerID) {
        List<String> areas = getManagerAreaIDs(managerID);
        return areas.isEmpty() ? null : areas.get(0);
    }

    private boolean isManagerOfArea(
            String managerID,
            String areaID) {

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
            AppUser user,
            String binID) {

        if (user == null || binID == null || binID.trim().isEmpty()) {
            return false;
        }

        WasteBin bin = binDAO.findByID(binID.trim());

        return bin != null
                && isManagerOfArea(
                        user.getUserId(),
                        bin.getAreaID());
    }

    private List<WasteBin> getBinsByArea(String areaID) {
        List<WasteBin> result = new ArrayList<WasteBin>();

        if (areaID == null || areaID.trim().isEmpty()) {
            return result;
        }

        List<WasteBin> allBins = binDAO.getAll();

        if (allBins != null) {
            for (WasteBin bin : allBins) {
                if (bin.getAreaID() != null
                        && areaID.equalsIgnoreCase(
                                bin.getAreaID().trim())) {
                    result.add(bin);
                }
            }
        }

        return result;
    }

    private List<AppUser> getTechniciansByArea(String areaID) {
        List<AppUser> result = new ArrayList<AppUser>();

        if (areaID == null || areaID.trim().isEmpty()) {
            return result;
        }

        List<AppUser> technicians = userDAO.search("", "TEC");

        if (technicians != null) {
            for (AppUser technician : technicians) {
                if (technician.getAreaID() != null
                        && areaID.equalsIgnoreCase(
                                technician.getAreaID().trim())) {
                    result.add(technician);
                }
            }
        }

        return result;
    }

    private boolean isTechnicianOfArea(
            String technicianID,
            String areaID) {

        if (technicianID == null
                || technicianID.trim().isEmpty()
                || areaID == null
                || areaID.trim().isEmpty()) {
            return false;
        }

        AppUser technician = userDAO.findById(technicianID.trim());

        return technician != null
                && "TEC".equals(technician.getRoleId())
                && technician.getAreaID() != null
                && areaID.equalsIgnoreCase(
                        technician.getAreaID().trim());
    }

    // =====================================================
    // VALIDATION HELPERS
    // =====================================================
    private boolean isValidStatus(String status) {
        return "Pending".equals(status)
                || "In_Progress".equals(status)
                || "Completed".equals(status)
                || "Cancelled".equals(status);
    }

    private boolean isValidType(String type) {
        return "Repair".equals(type)
                || "Inspection".equals(type)
                || "Replacement".equals(type)
                || "Sensor_Check".equals(type)
                || "Calibration".equals(type);
    }

    private Timestamp parseTimestamp(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }

        try {
            String normalized = value.trim().replace("T", " ");

            // Red
            if (normalized.length() == 16) {
                normalized += ":00";
            }

            return Timestamp.valueOf(normalized);

        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    private String toDateTimeLocal(Timestamp timestamp) {
        if (timestamp == null) {
            return "";
        }

        return timestamp.toLocalDateTime()
                .toString()
                .substring(0, 16);
    }

    private int parsePositiveInt(String value, int defaultValue) {
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }

        try {
            int parsed = Integer.parseInt(value.trim());
            return parsed > 0 ? parsed : defaultValue;
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private String safe(String value) {
        return value == null ? "" : value.trim();
    }

    private String redirectToList(HttpServletRequest req) {
        return "redirect:"
                + req.getContextPath()
                + "/maintenance";
    }

    private AppUser getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);

        if (session == null) {
            return null;
        }

        Object value = session.getAttribute("user");

        return value instanceof AppUser
                ? (AppUser) value
                : null;
    }

    // =====================================================
    // ACCESS DENIED
    // =====================================================
    private void showDenied(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setStatus(HttpServletResponse.SC_FORBIDDEN);

        req.getRequestDispatcher(DENIED)
                .forward(req, resp);
    }
}
