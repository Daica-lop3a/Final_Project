package controller;

import dao.AreaDAO;
import dao.AuditLogDAO;
import dao.UserDAO;
import model.Area;
import model.AppUser;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/area/*")
public class AreaServlet extends HttpServlet {

    private final AreaDAO areas = new AreaDAO();
    private final UserDAO users = new UserDAO();

    private static final String AREA_LIST =
            "/WEB-INF/views/areaList.jsp";
    private static final String AREA_FORM =
            "/WEB-INF/views/areaForm.jsp";
    private static final String AREA_VIEW =
            "/WEB-INF/views/areaDetail.jsp";
    private static final String DENIED_PAGE =
            "/WEB-INF/views/denied.jsp";

    private static final String ATTR_AREA = "AREA";
    private static final String ATTR_ERROR = "ERROR";
    private static final String ATTR_IS_EDIT = "IS_EDIT";
    private static final String ATTR_AREAS = "AREAS";
    private static final String ATTR_SEARCH = "SEARCH";
    private static final String ATTR_SORT = "SORT";
    private static final String ATTR_ORDER = "ORDER";
    private static final String ATTR_CURRENT_PAGE = "CURRENT_PAGE";
    private static final String ATTR_TOTAL_PAGES = "TOTAL_PAGES";
    private static final String ATTR_TOTAL_RECORDS = "TOTAL_RECORDS";
    private static final String ATTR_AREA_SCOPE = "AREA_SCOPE";

    private static final String REDIRECT_PREFIX = "redirect:";

    private static final int PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String url = AREA_LIST;

        try {
            AppUser user = getLoggedInUser(request);

            if (user == null) {
                url = REDIRECT_PREFIX
                        + request.getContextPath() + "/login";
                return;
            }

            String path = request.getPathInfo();

            if (path == null || "/".equals(path)) {
                if ("POST".equalsIgnoreCase(request.getMethod())) {
                    response.sendError(
                            HttpServletResponse.SC_NOT_FOUND);
                    return;
                }

                url = showList(request, user);
                return;
            }

            if ("GET".equalsIgnoreCase(request.getMethod())) {
                switch (path) {
                    case "/create":
                        if (!isAdmin(user)) {
                            url = denyAccess(request, response);
                            return;
                        }

                        Area newArea = new Area();
                        // Generate next sequential Area ID (e.g. Area6)
                        newArea.setAreaId(util.IdGenerator.nextAreaId());
                        request.setAttribute(ATTR_AREA, newArea);
                        request.setAttribute("NEXT_AREA_ID", newArea.getAreaId());
                        request.setAttribute(ATTR_IS_EDIT, false);
                        url = AREA_FORM;
                        break;

                    case "/view":
                        url = viewArea(request, response, user);
                        break;

                    case "/edit":
                        if (!isAdmin(user)) {
                            url = denyAccess(request, response);
                            return;
                        }

                        url = editArea(request, response);
                        break;

                    default:
                        response.sendError(
                                HttpServletResponse.SC_NOT_FOUND);
                        return;
                }

            } else if ("POST".equalsIgnoreCase(request.getMethod())) {
                if (!isAdmin(user)) {
                    url = denyAccess(request, response);
                    return;
                }

                switch (path) {
                    case "/save":
                        url = saveArea(request, response);
                        break;

                    case "/delete":
                        url = deleteArea(request, response, user);
                        break;

                    default:
                        response.sendError(
                                HttpServletResponse.SC_NOT_FOUND);
                        return;
                }

            } else {
                response.sendError(
                        HttpServletResponse.SC_METHOD_NOT_ALLOWED);
                return;
            }

        } catch (Exception e) {
            log("Error processing AreaServlet request", e);

            request.setAttribute(ATTR_ERROR,
                    "An error occurred while processing your request.");

            if (!response.isCommitted()) {
                response.setStatus(
                        HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }

            url = AREA_LIST;

        } finally {
            if (url != null && url.startsWith(REDIRECT_PREFIX)) {
                response.sendRedirect(url.substring(
                        REDIRECT_PREFIX.length()));
            } else if (url != null && !response.isCommitted()) {
                request.getRequestDispatcher(url)
                        .forward(request, response);
            }
        }
    }

    // SESSION AND ROLE

    private AppUser getLoggedInUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);

        if (session == null) {
            return null;
        }

        Object obj = session.getAttribute("user");

        return obj instanceof AppUser ? (AppUser) obj : null;
    }

    private String getRole(AppUser user) {
        if (user == null || user.getRoleId() == null) {
            return "";
        }

        return user.getRoleId().trim().toUpperCase(Locale.ROOT);
    }

    private boolean isAdmin(AppUser user) {
        String role = getRole(user);
        return "ADM".equals(role) || "SAD".equals(role);
    }

    private boolean isManager(AppUser user) {
        return "MGR".equals(getRole(user));
    }

    private boolean isSupervisor(AppUser user) {
        return "SUP".equals(getRole(user));
    }

    private List<String> getUserAssignedAreaIDs(AppUser user) {
        List<String> list = new ArrayList<String>();
        if (user == null || user.getUserId() == null) return list;
        list.addAll(users.getAssignedAreaIds(user.getUserId()));
        if (user.getAreaID() != null && !user.getAreaID().trim().isEmpty()) {
            String pArea = user.getAreaID().trim();
            if (!list.contains(pArea)) {
                list.add(pArea);
            }
        }
        return list;
    }

    private boolean isUser(AppUser user) {
        return "USR".equals(getRole(user));
    }

    private String getManagedAreaID(AppUser sessionUser) {
        if (!isManager(sessionUser)
                || sessionUser.getUserId() == null
                || sessionUser.getUserId().trim().isEmpty()) {
            return null;
        }

        AppUser dbUser =
                users.findById(sessionUser.getUserId().trim());

        if (dbUser == null || !isManager(dbUser)) {
            return null;
        }

        String areaID = dbUser.getAreaID();

        if (areaID == null || areaID.trim().isEmpty()) {
            return null;
        }

        return areaID.trim();
    }

    // LIST

    private String showList(HttpServletRequest request, AppUser user) throws IOException {
        String search = request.getParameter("search");
        search = search == null ? "" : search.trim();

        String sort = request.getParameter("sort");

        if (!"areaName".equals(sort)) {
            sort = "areaID";
        }

        String order = "DESC".equalsIgnoreCase(
                request.getParameter("order")) ? "DESC" : "ASC";

        String scope = request.getParameter("scope");

        if (isUser(user)) {
            scope = "my".equalsIgnoreCase(scope) ? "my" : "all";
        } else {
            scope = "all";
        }

        int currentPage = parsePage(request.getParameter("page"));
        List<Area> result = new ArrayList<Area>();
        int totalRecords = 0;

        if (isAdmin(user)) {
            totalRecords = areas.countFiltered(search);
            currentPage = normalizePage(currentPage, totalRecords);

            result = areas.getFilteredPaged(
                    search,
                    sort,
                    order,
                    (currentPage - 1) * PAGE_SIZE,
                    PAGE_SIZE
            );

        } else if (isManager(user)) {
            String managerAreaID = getManagedAreaID(user);

            Area managerArea = managerAreaID == null
                    ? null : areas.findById(managerAreaID);

            if (managerArea != null
                    && matchesSearch(managerArea, search)) {
                result.add(managerArea);
            }

            totalRecords = result.size();
            currentPage = 1;

        } else if (isSupervisor(user) || "STF".equals(getRole(user)) || "TEC".equals(getRole(user)) || "AUD".equals(getRole(user))) {
            List<String> assignedAreas = getUserAssignedAreaIDs(user);
            if ("AUD".equals(getRole(user))) {
                // Auditor can inspect all areas
                totalRecords = areas.countFiltered(search);
                currentPage = normalizePage(currentPage, totalRecords);
                result = areas.getFilteredPaged(search, sort, order, (currentPage - 1) * PAGE_SIZE, PAGE_SIZE);
            } else {
                for (String aId : assignedAreas) {
                    Area a = areas.findById(aId);
                    if (a != null && matchesSearch(a, search)) {
                        result.add(a);
                    }
                }
                totalRecords = result.size();
                currentPage = 1;
            }

        } else if (isUser(user)) {
            String userId = trimToNull(user.getUserId());

            if (userId == null) {
                request.setAttribute(ATTR_ERROR,
                        "Unable to identify the current user.");
                return DENIED_PAGE;
            }

            if ("my".equals(scope)) {
                totalRecords =
                        areas.countFilteredByUser(userId, search);

                currentPage = normalizePage(
                        currentPage, totalRecords);

                result = areas.getFilteredByUserPaged(
                        userId,
                        search,
                        sort,
                        order,
                        (currentPage - 1) * PAGE_SIZE,
                        PAGE_SIZE
                );

            } else {
                totalRecords = areas.countFiltered(search);
                currentPage = normalizePage(
                        currentPage, totalRecords);

                result = areas.getFilteredPaged(
                        search,
                        sort,
                        order,
                        (currentPage - 1) * PAGE_SIZE,
                        PAGE_SIZE
                );
            }

        } else {
            return denyAccess(request, null);
        }

        int totalPages = Math.max(
                1, (int) Math.ceil(
                        (double) totalRecords / PAGE_SIZE));

        request.setAttribute(ATTR_AREAS, result);
        request.setAttribute(ATTR_SEARCH, search);
        request.setAttribute(ATTR_SORT, sort);
        request.setAttribute(ATTR_ORDER, order);
        request.setAttribute(ATTR_CURRENT_PAGE, currentPage);
        request.setAttribute(ATTR_TOTAL_PAGES, totalPages);
        request.setAttribute(ATTR_TOTAL_RECORDS, totalRecords);
        request.setAttribute(ATTR_AREA_SCOPE, scope);

        return AREA_LIST;
    }

    private int parsePage(String pageParam) {
        try {
            return Math.max(1, Integer.parseInt(pageParam));
        } catch (NumberFormatException | NullPointerException e) {
            return 1;
        }
    }

    private int normalizePage(int page, int totalRecords) {
        int totalPages = Math.max(
                1, (int) Math.ceil(
                        (double) totalRecords / PAGE_SIZE));

        return Math.min(Math.max(1, page), totalPages);
    }

    private boolean matchesSearch(Area area, String search) {
        if (search == null || search.trim().isEmpty()) {
            return true;
        }

        String key = search.trim().toLowerCase(Locale.ROOT);

        return containsIgnoreCase(area.getAreaId(), key)
                || containsIgnoreCase(area.getAreaName(), key)
                || containsIgnoreCase(area.getDescription(), key);
    }

    private boolean containsIgnoreCase(String value, String key) {
        return value != null
                && value.toLowerCase(Locale.ROOT).contains(key);
    }

    // VIEW

    private String viewArea(HttpServletRequest request,
            HttpServletResponse response,
            AppUser user)
            throws IOException {

        String areaId = trimToNull(request.getParameter("id"));

        if (areaId == null) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Missing area ID.");
            return null;
        }

        Area area = areas.findById(areaId);

        if (area == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND);
            return null;
        }

        if (!canAccessArea(user, areaId)) {
            return denyAccess(request, response);
        }

        request.setAttribute(ATTR_AREA, area);
        return AREA_VIEW;
    }

    // EDIT - ADMIN ONLY

    private String editArea(HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        String areaId = trimToNull(request.getParameter("id"));

        if (areaId == null) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Missing area ID.");
            return null;
        }

        Area area = areas.findById(areaId);

        if (area == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND);
            return null;
        }

        request.setAttribute(ATTR_AREA, area);
        request.setAttribute(ATTR_IS_EDIT, true);

        return AREA_FORM;
    }

    // SAVE - ADMIN ONLY

    private String saveArea(HttpServletRequest request,
            HttpServletResponse response)
            throws IOException, ServletException {

        AppUser user = (AppUser) request.getSession().getAttribute("user");

        String areaId = trimToNull(request.getParameter("areaId"));
        String areaName = trimToNull(request.getParameter("areaName"));
        String description = request.getParameter("description");

        if (description != null) {
            description = description.trim();
        }

        boolean isEdit = "true".equalsIgnoreCase(
                request.getParameter("isEdit"));

        if (areaId == null || areaName == null) {
            request.setAttribute(ATTR_ERROR,
                    "Area ID and Area Name are required.");

            forwardAreaFormData(
                    request, areaId, areaName,
                    description, isEdit);

            return AREA_FORM;
        }

        // Format constraint validation: Must match AREA-XX (e.g., AREA-01, AREA-02)
        if (!areaId.toUpperCase(Locale.ROOT).matches("^AREA-\\d{2,}$")) {
            request.setAttribute(ATTR_ERROR,
                    "Invalid Area ID format. Must follow pattern 'AREA-XX' (e.g., AREA-01, AREA-02).");

            forwardAreaFormData(
                    request, areaId, areaName,
                    description, isEdit);

            return AREA_FORM;
        }

        if (areaId.length() > 50
                || areaName.length() > 255
                || (description != null
                    && description.length() > 500)) {
            request.setAttribute(ATTR_ERROR,
                    "One or more fields exceed the allowed length.");

            forwardAreaFormData(
                    request, areaId, areaName,
                    description, isEdit);

            return AREA_FORM;
        }

        Area existing = areas.findById(areaId);

        if (isEdit && existing == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Area not found.");
            return null;
        }

        if (!isEdit && existing != null) {
            request.setAttribute(ATTR_ERROR,
                    "Area ID already exists.");

            forwardAreaFormData(
                    request, areaId, areaName,
                    description, false);

            return AREA_FORM;
        }

        boolean duplicateName = isEdit
                ? areas.isAreaNameExist(areaName, areaId)
                : areas.isAreaNameExist(areaName);

        if (duplicateName) {
            request.setAttribute(ATTR_ERROR,
                    "Area name already exists.");

            forwardAreaFormData(
                    request, areaId, areaName,
                    description, isEdit);

            return AREA_FORM;
        }

        Area area = new Area();
        area.setAreaId(areaId);
        area.setAreaName(areaName);
        area.setDescription(description);

        boolean success = isEdit
                ? areas.update(area)
                : areas.insert(area);

        if (success) {
            AuditLogDAO.log(
                    user != null ? user.getUserId() : "SYSTEM",
                    isEdit ? "UPDATE_AREA" : "CREATE_AREA",
                    "tblAreas",
                    areaId,
                    isEdit && existing != null ? existing.getAreaName() : null,
                    isEdit ? ("Updated area: " + areaName) : ("Created area: " + areaName),
                    request.getRemoteAddr()
            );

            return REDIRECT_PREFIX
                    + request.getContextPath() + "/area";
        }

        request.setAttribute(ATTR_ERROR,
                "Unable to save area. Please check the data.");

        forwardAreaFormData(
                request, areaId, areaName,
                description, isEdit);

        return AREA_FORM;
    }

    private void forwardAreaFormData(HttpServletRequest request,
            String areaId,
            String areaName,
            String description,
            boolean isEdit) {

        Area area = new Area();
        area.setAreaId(areaId);
        area.setAreaName(areaName);
        area.setDescription(description);

        request.setAttribute(ATTR_AREA, area);
        request.setAttribute(ATTR_IS_EDIT, isEdit);
    }

    private String trimToNull(String value) {
        if (value == null) {
            return null;
        }

        value = value.trim();
        return value.isEmpty() ? null : value;
    }

    // DELETE - ADMIN ONLY

    private String deleteArea(HttpServletRequest request,
            HttpServletResponse response,
            AppUser user)
            throws IOException, ServletException {

        String areaId = trimToNull(request.getParameter("areaId"));

        if (areaId == null) {
            areaId = trimToNull(request.getParameter("id"));
        }

        if (areaId == null) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Missing area ID.");
            return null;
        }

        Area existing = areas.findById(areaId);

        if (existing == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Area not found.");
            return null;
        }

        boolean deleted = areas.delete(areaId);

        if (deleted) {
            AuditLogDAO.log(
                    user != null ? user.getUserId() : "SYSTEM",
                    "DELETE_AREA",
                    "tblAreas",
                    areaId,
                    existing.getAreaName(),
                    "Deleted area " + areaId + " (" + existing.getAreaName() + ")",
                    request.getRemoteAddr()
            );

            return REDIRECT_PREFIX
                    + request.getContextPath() + "/area";
        }

        request.setAttribute(ATTR_ERROR,
                "Unable to delete area. It may be referenced by other records.");

        return showList(request, user);
    }

    // AREA ACCESS

    private boolean canAccessArea(AppUser user, String areaId) {
        if (user == null || areaId == null
                || areaId.trim().isEmpty()) {
            return false;
        }

        if (isAdmin(user)) {
            return true;
        }

        if (isManager(user)) {
            String managerAreaID = getManagedAreaID(user);

            return managerAreaID != null
                    && managerAreaID.equalsIgnoreCase(areaId.trim());
        }

        if (isUser(user)) {
            String userId = trimToNull(user.getUserId());

            if (userId == null) {
                return false;
            }

            Area userArea = areas.getByUser(userId);

            return userArea != null
                    && userArea.getAreaId() != null
                    && userArea.getAreaId().equalsIgnoreCase(
                            areaId.trim());
        }

        if ("AUD".equals(getRole(user))) {
            return true;
        }

        if (isSupervisor(user) || "STF".equals(getRole(user)) || "TEC".equals(getRole(user))) {
            List<String> assignedAreas = getUserAssignedAreaIDs(user);
            for (String aId : assignedAreas) {
                if (aId.equalsIgnoreCase(areaId.trim())) {
                    return true;
                }
            }
        }

        return false;
    }

    private String denyAccess(HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        request.setAttribute(ATTR_ERROR,
                "You do not have permission to perform this action.");

        if (response != null) {
            response.setStatus(
                    HttpServletResponse.SC_FORBIDDEN);
        }

        return DENIED_PAGE;
    }
}
