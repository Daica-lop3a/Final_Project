package controller;

import dao.AreaDAO;
import dao.AuditLogDAO;
import dao.DeviceDAO;
import dao.UserDAO;
import dao.WasteBinDAO;
import model.Area;
import model.AppUser;
import model.WasteBin;
import util.Web;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/wastebin/*")
public class WasteBinServlet extends HttpServlet {

    private static final String BIN_LIST =
            "/WEB-INF/views/wasteBinList.jsp";

    private static final String BIN_FORM =
            "/WEB-INF/views/wasteBinForm.jsp";

    private static final String BIN_DETAIL =
            "/WEB-INF/views/binDetail.jsp";

    private final WasteBinDAO bins = new WasteBinDAO();
    private final AreaDAO areas = new AreaDAO();
    private final UserDAO users = new UserDAO();
    private final DeviceDAO deviceDAO = new DeviceDAO();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String path = request.getPathInfo();
        AppUser user = Web.currentUser(request);

        if (user == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login");
            return;
        }

        // USR chi duoc xem danh sach va chi tiet.
        if (isUSR(user)) {
            if (path == null || "/".equals(path) || "/list".equals(path)) {
                showList(request, response);
                return;
            }

            if ("/view".equals(path)) {
                viewBin(request, response);
                return;
            }

            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        if (path == null || "/".equals(path) || "/list".equals(path)) {
            showList(request, response);
            return;
        }

        if ("/create".equals(path)) {
            if (!canManage(user)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            showForm(request, response, null);
            return;
        }

        if ("/view".equals(path)) {
            viewBin(request, response);
            return;
        }

        if ("/edit".equals(path)) {
            if (!canManage(user)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            String binID = value(request.getParameter("id"));
            WasteBin bin = findBin(binID);

            if (bin == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            if (!canAccessBin(request, bin)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            showForm(request, response, bin);
            return;
        }

        response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        AppUser user = Web.currentUser(request);
        String path = request.getPathInfo();

        if (user == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login");
            return;
        }

        // Chi ADM, MGR, TEC duoc tao/sua/xoa theo quyen hien tai.
        if (!canManage(user)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        if ("/save".equals(path)) {
            save(request, response);
            return;
        }

        if ("/delete".equals(path)) {
            delete(request, response);
            return;
        }

        if ("/import".equals(path)) {
            importBins(request, response);
            return;
        }

        response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

    private void showList(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        AppUser user = Web.currentUser(request);
        boolean isUser = isUSR(user);

        String search = value(request.getParameter("search"));
        String areaID = value(request.getParameter("areaID"));
        String status = value(request.getParameter("status"));
        String fillLevel = value(request.getParameter("fillLevel"));
        String sort = value(request.getParameter("sort"));
        String order = value(request.getParameter("order"));

        // USR bat buoc chon Area truoc khi xem Waste Bins.
        if (isUser) {
            if (areaID.isEmpty()) {
                prepareEmptyBinList(request, search, "", status,
                        fillLevel, sort, order,
                        "Please select an area to view waste bins.");
                request.getRequestDispatcher(BIN_LIST)
                        .forward(request, response);
                return;
            }

            if (areas.findById(areaID) == null) {
                prepareEmptyBinList(request, search, "", status,
                        fillLevel, sort, order,
                        "Selected area does not exist.");
                request.getRequestDispatcher(BIN_LIST)
                        .forward(request, response);
                return;
            }
        }

        if (sort.isEmpty()) {
            sort = "binID";
        }

        if (!"binID".equals(sort)
                && !"binCode".equals(sort)
                && !"capacity".equals(sort)
                && !"currentFill".equals(sort)) {
            sort = "binID";
        }

        order = "DESC".equalsIgnoreCase(order) ? "DESC" : "ASC";

        int currentPage = parseInt(request.getParameter("page"), 1);
        int pageSize = parseInt(request.getParameter("pageSize"), 10);

        if (pageSize != 10 && pageSize != 20 && pageSize != 50) {
            pageSize = 10;
        }
        currentPage = Math.max(1, currentPage);

        // USR: Area duoc chon; MGR: Area trong tblUsers.areaID.
        // Admin and other roles keep full access scope.
        List<String> allowedIds = allowedAreaIds(request);

        int[] counts = bins.getFilteredCounts(
                search, areaID, status, fillLevel, allowedIds);

        int totalRecords = counts[0];
        int totalPages = Math.max(1,
                (int) Math.ceil(totalRecords / (double) pageSize));

        if (currentPage > totalPages) {
            currentPage = totalPages;
        }

        int offset = (currentPage - 1) * pageSize;

        request.setAttribute("LIST_BIN", bins.getFilteredPaged(
                search, areaID, status, fillLevel, sort, order,
                allowedIds, offset, pageSize));
        request.setAttribute("LIST_AREA", loadAreas(request));
        request.setAttribute("SEARCH", search);
        request.setAttribute("AREA_ID", areaID);
        request.setAttribute("STATUS", status);
        request.setAttribute("FILL_LEVEL", fillLevel);
        request.setAttribute("SORT", sort);
        request.setAttribute("ORDER", order);
        request.setAttribute("CURRENT_PAGE", currentPage);
        request.setAttribute("TOTAL_PAGES", totalPages);
        request.setAttribute("TOTAL_RECORDS", totalRecords);
        request.setAttribute("PAGE_SIZE", pageSize);
        request.setAttribute("ACTIVE_COUNT", counts[1]);
        request.setAttribute("HIGH_FILL_COUNT", counts[2]);
        request.setAttribute("UNASSIGNED_BINS", deviceDAO.getUnassignedBins());
        request.setAttribute("DUPLICATE_BINS", deviceDAO.getDuplicateAssignedBins());

        request.getRequestDispatcher(BIN_LIST).forward(request, response);
    }

    private void prepareEmptyBinList(
            HttpServletRequest request,
            String search,
            String areaID,
            String status,
            String fillLevel,
            String sort,
            String order,
            String error) {

        request.setAttribute("ERROR", error);
        request.setAttribute("LIST_BIN", Collections.emptyList());
        request.setAttribute("LIST_AREA", loadAreas(request));
        request.setAttribute("SEARCH", search);
        request.setAttribute("AREA_ID", areaID);
        request.setAttribute("STATUS", status);
        request.setAttribute("FILL_LEVEL", fillLevel);
        request.setAttribute("SORT", sort.isEmpty() ? "binID" : sort);
        request.setAttribute("ORDER",
                "DESC".equalsIgnoreCase(order) ? "DESC" : "ASC");
        request.setAttribute("CURRENT_PAGE", 1);
        request.setAttribute("TOTAL_PAGES", 1);
        request.setAttribute("TOTAL_RECORDS", 0);
        request.setAttribute("PAGE_SIZE", 10);
        request.setAttribute("ACTIVE_COUNT", 0);
        request.setAttribute("HIGH_FILL_COUNT", 0);
    }

    private void viewBin(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        AppUser user = Web.currentUser(request);
        String binID = value(request.getParameter("id"));
        WasteBin bin = findBin(binID);

        if (bin == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // USR co the xem public bin; neu co truyen areaID thi phai trung khop voi Area cua bin.
        if (isUSR(user)) {
            String selectedArea = value(request.getParameter("areaID"));

            if (!selectedArea.isEmpty()) {
                if (areas.findById(selectedArea) == null || !selectedArea.equals(bin.getAreaID())) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
            } else {
                if (bin.getAreaID() == null || areas.findById(bin.getAreaID()) == null) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
            }
        }

        if (!canAccessBin(request, bin)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        request.setAttribute("BIN", bin);
        AuditLogDAO auditLogDAO = new AuditLogDAO();
        request.setAttribute("BIN_LOGS", auditLogDAO.getLogsByRecord("tblWasteBins", bin.getBinID()));
        response.sendRedirect(request.getContextPath() + "/wastebin/detail?binID=" + java.net.URLEncoder.encode(bin.getBinID(), "UTF-8"));
    }

    private void showForm(HttpServletRequest request,
            HttpServletResponse response,
            WasteBin bin)
            throws ServletException, IOException {

        request.setAttribute("BIN", bin);
        if (bin == null) {
            // Generate next sequential bin ID for form preview
            request.setAttribute("NEXT_BIN_ID", util.IdGenerator.nextBinId());
        }
        request.setAttribute("LIST_AREA", loadAreas(request));
        request.getRequestDispatcher(BIN_FORM).forward(request, response);
    }

    private void save(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String binID = value(request.getParameter("binID"));
        String binCode = value(request.getParameter("binCode")).trim().toUpperCase();
        String location = value(request.getParameter("location"));
        String capacityRaw = value(request.getParameter("capacity"));
        String status = value(request.getParameter("status"));
        String areaID = value(request.getParameter("areaID"));

        if (binID.isEmpty() || binCode.isEmpty()
                || location.isEmpty() || areaID.isEmpty()) {
            request.setAttribute("ERROR",
                    "Bin ID, bin code, location and area are required.");
            showFormWithValues(request, response, binID, binCode,
                    location, capacityRaw, status, areaID);
            return;
        }

        // VALIDATION: Bin Code Format constraint (e.g. BIN-A1-01, BIN-B2-05)
        if (!binCode.matches("^BIN-[A-Z0-9]+(-[0-9]+)+$") && !binCode.matches("^BIN-[A-Z0-9]{2,15}$")) {
            request.setAttribute("ERROR",
                    "Bin Code must follow the standard format 'BIN-XX-NN' (e.g. BIN-A1-01) with uppercase alphanumeric characters and hyphens.");
            showFormWithValues(request, response, binID, binCode,
                    location, capacityRaw, status, areaID);
            return;
        }

        // VALIDATION: Bin Code Length constraint
        if (binCode.length() < 5 || binCode.length() > 30) {
            request.setAttribute("ERROR",
                    "Bin Code must be between 5 and 30 characters.");
            showFormWithValues(request, response, binID, binCode,
                    location, capacityRaw, status, areaID);
            return;
        }

        // VALIDATION: Location length
        if (location.length() < 3) {
            request.setAttribute("ERROR", "Location description must be at least 3 characters.");
            showFormWithValues(request, response, binID, binCode,
                    location, capacityRaw, status, areaID);
            return;
        }

        double capacity;
        try {
            capacity = Double.parseDouble(capacityRaw);
        } catch (NumberFormatException e) {
            request.setAttribute("ERROR", "Capacity must be a number.");
            showFormWithValues(request, response, binID, binCode,
                    location, capacityRaw, status, areaID);
            return;
        }

        if (capacity <= 0 || capacity > 5000) {
            request.setAttribute("ERROR",
                    "Capacity must be between 1 and 5,000 liters.");
            showFormWithValues(request, response, binID, binCode,
                    location, capacityRaw, status, areaID);
            return;
        }

        if (areas.findById(areaID) == null) {
            request.setAttribute("ERROR", "Selected area does not exist.");
            showFormWithValues(request, response, binID, binCode,
                    location, capacityRaw, status, areaID);
            return;
        }

        AppUser user = Web.currentUser(request);
        WasteBin oldBin = bins.findByID(binID);

        // VALIDATION: Unique Bin Code
        WasteBin existingByCode = bins.findByCode(binCode);
        if (existingByCode != null && (oldBin == null || !existingByCode.getBinID().equals(binID))) {
            request.setAttribute("ERROR", "Bin Code '" + binCode + "' already exists. Please choose a unique code.");
            showFormWithValues(request, response, binID, binCode,
                    location, capacityRaw, status, areaID);
            return;
        }

        // Manager can only create/edit bins in their assigned area.
        if (user != null && "MGR".equalsIgnoreCase(user.getRoleId())) {
            String managerAreaID = getManagerAreaID(user);

            if (managerAreaID == null
                    || !managerAreaID.equals(areaID)
                    || (oldBin != null
                    && !managerAreaID.equals(oldBin.getAreaID()))) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
        }

        // Disallow editing bins outside permitted scope.
        if (oldBin != null && !canAccessBin(request, oldBin)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        double latitude = 10.841128;
        double longitude = 106.809883;
        try {
            String latRaw = request.getParameter("latitude");
            if (latRaw != null && !latRaw.trim().isEmpty()) {
                latitude = Double.parseDouble(latRaw.trim());
            }
            String lngRaw = request.getParameter("longitude");
            if (lngRaw != null && !lngRaw.trim().isEmpty()) {
                longitude = Double.parseDouble(lngRaw.trim());
            }
        } catch (Exception ignored) {
        }

        if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
            request.setAttribute("ERROR", "Invalid GPS coordinates.");
            showFormWithValues(request, response, binID, binCode,
                    location, capacityRaw, status, areaID);
            return;
        }

        boolean success;
        if (oldBin == null) {
            WasteBin bin = new WasteBin();
            bin.setBinID(binID);
            bin.setBinCode(binCode);
            bin.setLocation(location);
            bin.setLatitude(latitude);
            bin.setLongitude(longitude);
            bin.setCapacity(capacity);
            bin.setCurrentFill(0);
            bin.setStatus(status);
            bin.setAreaID(areaID);
            success = bins.insert(bin);
        } else {
            oldBin.setBinCode(binCode);
            oldBin.setLocation(location);
            oldBin.setLatitude(latitude);
            oldBin.setLongitude(longitude);
            oldBin.setCapacity(capacity);
            oldBin.setStatus(status);
            oldBin.setAreaID(areaID);
            success = bins.update(oldBin);
        }

        if (!success) {
            request.setAttribute("ERROR", "Cannot save waste bin.");
            showFormWithValues(request, response, binID, binCode,
                    location, capacityRaw, status, areaID);
            return;
        }

        AuditLogDAO.log(
                user != null ? user.getUserId() : "SYSTEM",
                oldBin == null ? "CREATE_BIN" : "UPDATE_BIN",
                "tblWasteBins",
                binID,
                oldBin != null ? oldBin.getLocation() : null,
                oldBin == null ? ("Created bin " + binCode + " at " + location) : ("Updated bin " + binCode + " status=" + status),
                request.getRemoteAddr()
        );

        response.sendRedirect(request.getContextPath() + "/wastebin");
    }

    private void delete(HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        String binID = value(request.getParameter("id"));
        WasteBin bin = findBin(binID);

        if (bin == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        if (!canAccessBin(request, bin)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        AppUser user = Web.currentUser(request);
        if (user != null && "SUP".equalsIgnoreCase(user.getRoleId())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Supervisors cannot delete bins.");
            return;
        }

        boolean deleted = bins.delete(binID);
        if (!deleted) {
            response.sendError(HttpServletResponse.SC_CONFLICT,
                    "Cannot delete this bin. It may be used by other records.");
            return;
        }

        AuditLogDAO.log(
                user != null ? user.getUserId() : "SYSTEM",
                "DELETE_BIN",
                "tblWasteBins",
                binID,
                bin.getLocation(),
                "Deleted bin " + binID + " (" + bin.getBinCode() + ")",
                request.getRemoteAddr()
        );

        response.sendRedirect(request.getContextPath() + "/wastebin");
    }

    // ============================================================
    // ADVANCED: Batch import bins from CSV file
    // ============================================================
    private void importBins(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        AppUser user = Web.currentUser(request);
        if (!canManage(user)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String csvData = request.getParameter("csvData");
        if (csvData == null || csvData.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/wastebin?error=empty_csv");
            return;
        }

        int successCount = 0;
        String[] lines = csvData.split("\\r?\\n");
        for (String rawLine : lines) {
            String line = rawLine.trim();
            if (line.isEmpty() || line.startsWith("#") || line.toLowerCase().startsWith("bincode")) {
                continue;
            }
            String[] parts = line.split(",");
            if (parts.length >= 6) {
                String binCode = parts[0].trim();
                String location = parts[1].trim();
                double lat = 10.841128;
                double lng = 106.809883;
                double cap = 120.0;
                String areaID = parts[5].trim();
                try {
                    lat = Double.parseDouble(parts[2].trim());
                    lng = Double.parseDouble(parts[3].trim());
                    cap = Double.parseDouble(parts[4].trim());
                } catch (Exception ignored) {
                }

                if (areas.findById(areaID) != null && bins.findByCode(binCode) == null) {
                    WasteBin b = new WasteBin();
                    b.setBinID("BIN-" + (System.currentTimeMillis() % 100000) + "-" + (successCount + 1));
                    b.setBinCode(binCode);
                    b.setLocation(location);
                    b.setLatitude(lat);
                    b.setLongitude(lng);
                    b.setCapacity(cap);
                    b.setCurrentFill(0);
                    b.setStatus("Active");
                    b.setAreaID(areaID);
                    if (bins.insert(b)) {
                        successCount++;
                    }
                }
            }
        }

        if (successCount > 0) {
            AuditLogDAO.log(
                    user != null ? user.getUserId() : "SYSTEM",
                    "IMPORT_BINS_CSV",
                    "tblWasteBins",
                    "BULK",
                    null,
                    "Imported " + successCount + " waste bins via CSV",
                    request.getRemoteAddr()
            );
        }

        response.sendRedirect(request.getContextPath() + "/wastebin?msg=imported&count=" + successCount);
    }

    private void showFormWithValues(
            HttpServletRequest request,
            HttpServletResponse response,
            String binID,
            String binCode,
            String location,
            String capacityRaw,
            String status,
            String areaID)
            throws ServletException, IOException {

        WasteBin bin = new WasteBin();
        bin.setBinID(binID);
        bin.setBinCode(binCode);
        bin.setLocation(location);
        bin.setStatus(status);
        bin.setAreaID(areaID);

        try {
            bin.setCapacity(Double.parseDouble(capacityRaw));
        } catch (Exception e) {
            bin.setCapacity(0);
        }

        bin.setCurrentFill(0);
        request.setAttribute("BIN", bin);
        request.setAttribute("LIST_AREA", loadAreas(request));
        request.getRequestDispatcher(BIN_FORM).forward(request, response);
    }

    private List<String> allowedAreaIds(HttpServletRequest request) {
        AppUser user = Web.currentUser(request);

        if (isUSR(user)) {
            String areaID = value(request.getParameter("areaID"));
            if (areaID.isEmpty() || areas.findById(areaID) == null) {
                return Collections.emptyList();
            }
            return Collections.singletonList(areaID);
        }

        if (user != null && ("MGR".equalsIgnoreCase(user.getRoleId()) || "SUP".equalsIgnoreCase(user.getRoleId()) || "STF".equalsIgnoreCase(user.getRoleId()))) {
            List<String> assigned = users.getAssignedAreaIds(user.getUserId());
            AppUser dbUser = users.findById(user.getUserId());
            if (dbUser != null && dbUser.getAreaID() != null && !dbUser.getAreaID().trim().isEmpty()) {
                if (!assigned.contains(dbUser.getAreaID().trim())) assigned.add(dbUser.getAreaID().trim());
            }
            if (!assigned.isEmpty()) return assigned;
            String areaID = getManagerAreaID(user);
            if (areaID == null) {
                return Collections.emptyList();
            }
            return Collections.singletonList(areaID);
        }

        // Admin and other roles keep full access scope.
        return null;
    }

    private List<Area> loadAreas(HttpServletRequest request) {
        AppUser user = Web.currentUser(request);

        if (user != null && ("MGR".equalsIgnoreCase(user.getRoleId()) || "SUP".equalsIgnoreCase(user.getRoleId()) || "STF".equalsIgnoreCase(user.getRoleId()))) {
            List<String> areaIDs = users.getAssignedAreaIds(user.getUserId());
            AppUser dbUser = users.findById(user.getUserId());
            if (dbUser != null && dbUser.getAreaID() != null && !dbUser.getAreaID().trim().isEmpty()) {
                if (!areaIDs.contains(dbUser.getAreaID().trim())) areaIDs.add(dbUser.getAreaID().trim());
            }
            if (!areaIDs.isEmpty()) {
                List<Area> result = new ArrayList<Area>();
                for (String aId : areaIDs) {
                    Area a = areas.findById(aId);
                    if (a != null) result.add(a);
                }
                return result;
            }
            String areaID = getManagerAreaID(user);
            if (areaID == null) {
                return Collections.emptyList();
            }
            Area area = areas.findById(areaID);
            if (area == null) {
                return Collections.emptyList();
            }
            return Collections.singletonList(area);
        }

        return areas.getAll();
    }

    private boolean canAccessBin(HttpServletRequest request, WasteBin bin) {
        AppUser user = Web.currentUser(request);

        if (user == null || bin == null) {
            return false;
        }

        if ("MGR".equalsIgnoreCase(user.getRoleId()) || "SUP".equalsIgnoreCase(user.getRoleId()) || "STF".equalsIgnoreCase(user.getRoleId())) {
            List<String> assignedAreas = users.getAssignedAreaIds(user.getUserId());
            AppUser dbUser = users.findById(user.getUserId());
            if (dbUser != null && dbUser.getAreaID() != null && !dbUser.getAreaID().trim().isEmpty()) {
                String primaryArea = dbUser.getAreaID().trim();
                if (!assignedAreas.contains(primaryArea)) {
                    assignedAreas.add(primaryArea);
                }
            }
            if (assignedAreas.isEmpty()) {
                return true; // General operations manager
            }
            return bin.getAreaID() != null && assignedAreas.contains(bin.getAreaID());
        }

        if (isUSR(user)) {
            String selectedArea = value(request.getParameter("areaID"));
            if (!selectedArea.isEmpty()) {
                return selectedArea.equals(bin.getAreaID()) && areas.findById(selectedArea) != null;
            }
            return bin.getAreaID() != null && areas.findById(bin.getAreaID()) != null;
        }

        return true;
    }

    // Lay area hien tai cua Manager tu tblUsers, khong dung tblAreaAssignments.
    private String getManagerAreaID(AppUser sessionUser) {
        if (sessionUser == null || sessionUser.getUserId() == null) {
            return null;
        }

        AppUser dbUser = users.findById(sessionUser.getUserId());
        if (dbUser == null
                || !"MGR".equalsIgnoreCase(dbUser.getRoleId())) {
            return null;
        }

        String areaID = value(dbUser.getAreaID());
        return areaID.isEmpty() ? null : areaID;
    }

    private WasteBin findBin(String binID) {
        if (binID == null || binID.trim().isEmpty()) {
            return null;
        }
        return bins.findByID(binID.trim());
    }

    private boolean canManage(AppUser user) {
        if (user == null) {
            return false;
        }
        String role = user.getRoleId();
        return "ADM".equalsIgnoreCase(role)
                || "SAD".equalsIgnoreCase(role)
                || "MGR".equalsIgnoreCase(role)
                || "SUP".equalsIgnoreCase(role)
                || "TEC".equalsIgnoreCase(role);
    }

    private boolean isUSR(AppUser user) {
        return user != null
                && "USR".equalsIgnoreCase(user.getRoleId());
    }

    private String value(String input) {
        return input == null ? "" : input.trim();
    }

    private int parseInt(String input, int defaultValue) {
        try {
            return Integer.parseInt(input);
        } catch (Exception e) {
            return defaultValue;
        }
    }
}
