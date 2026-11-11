package controller;

import dao.AuditLogDAO;
import dao.BinInspectionDAO;
import dao.MaintenanceDAO;
import dao.UserDAO;
import dao.WasteBinDAO;
import model.AppUser;
import model.BinInspection;
import model.Maintenance;
import model.WasteBin;

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

@WebServlet(name = "BinInspectionServlet", urlPatterns = {"/inspection", "/inspection/*"})
public class BinInspectionServlet extends HttpServlet {

    private static final String LIST_VIEW = "/WEB-INF/views/inspectionList.jsp";
    private static final String FORM_VIEW = "/WEB-INF/views/inspectionForm.jsp";
    private static final String DENIED = "/WEB-INF/views/denied.jsp";

    private final BinInspectionDAO inspectionDAO = new BinInspectionDAO();
    private final WasteBinDAO binDAO = new WasteBinDAO();
    private final UserDAO userDAO = new UserDAO();
    private final MaintenanceDAO maintenanceDAO = new MaintenanceDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            AppUser user = getCurrentUser(request);
            if (user == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            String role = user.getRoleId();
            if (!"ADM".equals(role) && !"MGR".equals(role) && !"SUP".equals(role) && !"SAD".equals(role) && !"STF".equals(role) && !"TEC".equals(role) && !"AUD".equals(role)) {
                request.getRequestDispatcher(DENIED).forward(request, response);
                return;
            }

            String path = request.getPathInfo();
            String method = request.getMethod();

            // AUDITOR READ-ONLY ENFORCEMENT
            if (user.isAuditor()) {
                if (!"GET".equalsIgnoreCase(method) || (path != null && !path.isEmpty() && !"/".equals(path))) {
                    request.setAttribute("ERROR", "Auditor is strictly read-only and cannot create, modify or delete inspections.");
                    request.getRequestDispatcher(DENIED).forward(request, response);
                    return;
                }
                showList(request, response, user);
                return;
            }

            if ("GET".equalsIgnoreCase(method)) {
                if (path == null || "/".equals(path) || path.isEmpty()) {
                    showList(request, response, user);
                } else if ("/create".equals(path)) {
                    showCreateForm(request, response, user);
                } else if ("/edit".equals(path)) {
                    showEditForm(request, response, user);
                } else {
                    showList(request, response, user);
                }
            } else if ("POST".equalsIgnoreCase(method)) {
                if ("/save".equals(path)) {
                    saveInspection(request, response, user);
                } else if ("/delete".equals(path)) {
                    deleteInspection(request, response, user);
                } else {
                    response.sendRedirect(request.getContextPath() + "/inspection");
                }
            }
        } catch (Exception e) {
            log("Error in BinInspectionServlet", e);
            request.setAttribute("ERROR", "An error occurred during inspection management: " + e.getMessage());
            request.getRequestDispatcher(DENIED).forward(request, response);
        }
    }

    private void showList(HttpServletRequest request, HttpServletResponse response, AppUser user)
            throws ServletException, IOException, SQLException, ClassNotFoundException {
        String role = user.getRoleId();
        List<BinInspection> inspections;
        List<String> userAreas = getUserAssignedAreas(user);

        if ("ADM".equals(role) || "SAD".equals(role) || "AUD".equals(role)) {
            inspections = inspectionDAO.getAll();
        } else {
            inspections = inspectionDAO.getByAreaIds(userAreas);
        }

        int totalCount = inspections.size();
        int discrepancyCount = 0;
        for (BinInspection insp : inspections) {
            if (insp.isHighDiscrepancy()) {
                discrepancyCount++;
            }
        }

        request.setAttribute("LIST_INSPECTIONS", inspections);
        request.setAttribute("TOTAL_COUNT", totalCount);
        request.setAttribute("DISCREPANCY_COUNT", discrepancyCount);
        request.getRequestDispatcher(LIST_VIEW).forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response, AppUser user)
            throws ServletException, IOException, SQLException, ClassNotFoundException {
        List<WasteBin> availableBins = getAvailableBins(user);
        BinInspection inspection = new BinInspection();
        // Prefill next sequential inspection ID (e.g. INSP-004)
        inspection.setInspectionID(util.IdGenerator.nextInspectionId());
        inspection.setPhysicalCondition("Good");
        inspection.setActionTaken("None");

        String preselectedBinID = request.getParameter("binID");
        if (preselectedBinID != null && !preselectedBinID.trim().isEmpty()) {
            WasteBin bin = binDAO.findByID(preselectedBinID.trim());
            if (bin != null) {
                inspection.setBinID(bin.getBinID());
                inspection.setSensorFillPercent((int) Math.round(bin.getCurrentFill()));
            }
        } else if (!availableBins.isEmpty()) {
            inspection.setBinID(availableBins.get(0).getBinID());
            inspection.setSensorFillPercent((int) Math.round(availableBins.get(0).getCurrentFill()));
        }

        request.setAttribute("INSPECTION", inspection);
        request.setAttribute("LIST_BINS", availableBins);
        request.setAttribute("MODE", "CREATE");
        request.getRequestDispatcher(FORM_VIEW).forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response, AppUser user)
            throws ServletException, IOException, SQLException, ClassNotFoundException {
        String id = request.getParameter("id");
        if (id == null || id.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/inspection");
            return;
        }

        BinInspection inspection = inspectionDAO.findById(id.trim());
        if (inspection == null) {
            response.sendRedirect(request.getContextPath() + "/inspection");
            return;
        }

        if (!canAccessBin(user, inspection.getBinID())) {
            request.getRequestDispatcher(DENIED).forward(request, response);
            return;
        }

        List<WasteBin> availableBins = getAvailableBins(user);
        request.setAttribute("INSPECTION", inspection);
        request.setAttribute("LIST_BINS", availableBins);
        request.setAttribute("MODE", "EDIT");
        request.getRequestDispatcher(FORM_VIEW).forward(request, response);
    }

    private void saveInspection(HttpServletRequest request, HttpServletResponse response, AppUser user)
            throws ServletException, IOException, SQLException, ClassNotFoundException {
        String inspectionID = safe(request.getParameter("inspectionID"));
        String binID = safe(request.getParameter("binID"));
        String physicalCondition = safe(request.getParameter("physicalCondition"));
        String actionTaken = safe(request.getParameter("actionTaken"));
        String notes = safe(request.getParameter("notes"));
        boolean createMaintenance = "on".equalsIgnoreCase(request.getParameter("createMaintenance"))
                || "true".equalsIgnoreCase(request.getParameter("createMaintenance"));

        int actualFillPercent = 0;
        int sensorFillPercent = 0;
        try {
            actualFillPercent = Integer.parseInt(safe(request.getParameter("actualFillPercent")));
        } catch (NumberFormatException ignored) {}

        WasteBin bin = binDAO.findByID(binID);
        if (bin == null || !canAccessBin(user, binID)) {
            request.setAttribute("ERROR", "Invalid Waste Bin or access unauthorized for your area.");
            showCreateForm(request, response, user);
            return;
        }

        // Live sensor fill
        sensorFillPercent = (int) Math.round(bin.getCurrentFill());
        int discrepancyPercent = actualFillPercent - sensorFillPercent;

        boolean isCreate = inspectionID.isEmpty();
        BinInspection inspection;
        if (isCreate) {
            inspection = new BinInspection();
            // Generate next sequential inspection ID (e.g. INSP-004)
            inspection.setInspectionID(util.IdGenerator.nextInspectionId());
            inspection.setCreatedDate(new Timestamp(System.currentTimeMillis()));
        } else {
            inspection = inspectionDAO.findById(inspectionID);
            if (inspection == null) {
                response.sendRedirect(request.getContextPath() + "/inspection");
                return;
            }
        }

        inspection.setBinID(binID);
        inspection.setInspectorID(user.getUserId());
        inspection.setInspectionDate(new Timestamp(System.currentTimeMillis()));
        inspection.setActualFillPercent(actualFillPercent);
        inspection.setSensorFillPercent(sensorFillPercent);
        inspection.setDiscrepancyPercent(discrepancyPercent);
        inspection.setPhysicalCondition(physicalCondition.isEmpty() ? "Good" : physicalCondition);
        inspection.setActionTaken(actionTaken.isEmpty() ? "None" : actionTaken);
        inspection.setNotes(notes);

        boolean success = isCreate ? inspectionDAO.insert(inspection) : inspectionDAO.update(inspection);

        if (success) {
            AuditLogDAO.log(
                    user.getUserId(),
                    isCreate ? "CREATE_INSPECTION" : "UPDATE_INSPECTION",
                    "tblBinInspections",
                    inspection.getInspectionID(),
                    isCreate ? null : "Modified",
                    "Inspection for Bin " + bin.getBinCode() + " (Actual: " + actualFillPercent + "%, Sensor: " + sensorFillPercent + "%)",
                    request.getRemoteAddr()
            );

            // Auto-create maintenance request if discrepancy is severe or explicitly requested
            if (createMaintenance || Math.abs(discrepancyPercent) >= 20 || "Damaged".equalsIgnoreCase(physicalCondition)) {
                createAutomatedMaintenance(bin, user, inspection);
            }
        }

        response.sendRedirect(request.getContextPath() + "/inspection?msg=saved");
    }

    private void createAutomatedMaintenance(WasteBin bin, AppUser user, BinInspection insp) {
        try {
            Maintenance m = new Maintenance();
            // Generate next sequential maintenance ID (e.g. MNT-007)
            m.setMaintenanceID(util.IdGenerator.nextMaintenanceId());
            m.setBinID(bin.getBinID());
            m.setMaintenanceType(Math.abs(insp.getDiscrepancyPercent()) >= 20 ? "Sensor_Check" : "Repair");
            m.setStatus("Pending");
            m.setScheduledDate(new Timestamp(System.currentTimeMillis() + 86400000L)); // next day
            m.setDescription("Auto-generated from Physical Inspection " + insp.getInspectionID()
                    + " by " + user.getFullName() + ". Discrepancy: " + insp.getDiscrepancyPercent()
                    + "%, Condition: " + insp.getPhysicalCondition() + ". Notes: " + insp.getNotes());

            // Assign to first available technician in this area if any, or default technician
            List<AppUser> areaTechs = userDAO.search("", "TEC");
            String assignedTechID = null;
            for (AppUser tech : areaTechs) {
                if (tech.getAreaID() != null && tech.getAreaID().equalsIgnoreCase(bin.getAreaID())) {
                    assignedTechID = tech.getUserId();
                    break;
                }
            }
            if (assignedTechID == null && !areaTechs.isEmpty()) {
                assignedTechID = areaTechs.get(0).getUserId();
            }
            if (assignedTechID != null) {
                m.setTechnicianID(assignedTechID);
                maintenanceDAO.insert(m);
            }
        } catch (Exception e) {
            log("Error auto-creating maintenance from inspection", e);
        }
    }

    private void deleteInspection(HttpServletRequest request, HttpServletResponse response, AppUser user)
            throws ServletException, IOException, SQLException, ClassNotFoundException {
        if ("STF".equals(user.getRoleId()) || "TEC".equals(user.getRoleId())) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            request.getRequestDispatcher(DENIED).forward(request, response);
            return;
        }
        String id = safe(request.getParameter("id"));
        if (!id.isEmpty()) {
            BinInspection insp = inspectionDAO.findById(id);
            if (insp != null && canAccessBin(user, insp.getBinID())) {
                inspectionDAO.delete(id);
                AuditLogDAO.log(
                        user.getUserId(),
                        "DELETE_INSPECTION",
                        "tblBinInspections",
                        id,
                        null,
                        "Deleted inspection " + id,
                        request.getRemoteAddr()
                );
            }
        }
        response.sendRedirect(request.getContextPath() + "/inspection");
    }

    private List<String> getUserAssignedAreas(AppUser user) {
        List<String> list = new ArrayList<String>();
        if (user == null) return list;
        list.addAll(userDAO.getAssignedAreaIds(user.getUserId()));
        if (user.getAreaID() != null && !user.getAreaID().trim().isEmpty()) {
            String pArea = user.getAreaID().trim();
            if (!list.contains(pArea)) {
                list.add(pArea);
            }
        }
        return list;
    }

    private boolean canAccessBin(AppUser user, String binID) throws SQLException, ClassNotFoundException {
        if ("ADM".equals(user.getRoleId()) || "SAD".equals(user.getRoleId())) {
            return true;
        }
        WasteBin bin = binDAO.findByID(binID);
        if (bin == null || bin.getAreaID() == null) {
            return false;
        }
        List<String> userAreas = getUserAssignedAreas(user);
        for (String aId : userAreas) {
            if (aId.equalsIgnoreCase(bin.getAreaID().trim())) {
                return true;
            }
        }
        return false;
    }

    private List<WasteBin> getAvailableBins(AppUser user) throws SQLException, ClassNotFoundException {
        List<WasteBin> allBins = binDAO.getAll();
        if ("ADM".equals(user.getRoleId()) || "SAD".equals(user.getRoleId())) {
            return allBins;
        }
        List<String> userAreas = getUserAssignedAreas(user);
        List<WasteBin> result = new ArrayList<WasteBin>();
        for (WasteBin b : allBins) {
            if (b != null && b.getAreaID() != null) {
                for (String aId : userAreas) {
                    if (aId.equalsIgnoreCase(b.getAreaID().trim())) {
                        result.add(b);
                        break;
                    }
                }
            }
        }
        return result;
    }

    private AppUser getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;
        return (AppUser) session.getAttribute("user");
    }

    private String safe(String s) {
        return s == null ? "" : s.trim();
    }
}
