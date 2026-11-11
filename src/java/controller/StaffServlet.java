package controller;

import dao.CollectionDAO;
import dao.UserDAO;
import model.AppUser;
import model.CollectionRequest;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "StaffServlet", urlPatterns = {"/staff", "/staff/*"})
public class StaffServlet extends HttpServlet {

    private static final String LIST_VIEW = "/WEB-INF/views/staffList.jsp";
    private static final String DENIED = "/WEB-INF/views/denied.jsp";

    private final UserDAO userDAO = new UserDAO();
    private final CollectionDAO collectionDAO = new CollectionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            AppUser currentUser = getCurrentUser(request);
            if (currentUser == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            String role = currentUser.getRoleId();
            if (!"ADM".equals(role) && !"MGR".equals(role) && !"SUP".equals(role) && !"SAD".equals(role)) {
                request.getRequestDispatcher(DENIED).forward(request, response);
                return;
            }

            String search = request.getParameter("search");
            if (search == null) search = "";

            List<AppUser> allStaff = userDAO.search(search, "STF");
            List<String> assignedAreas = getAssignedAreas(currentUser);

            List<AppUser> staffList = new ArrayList<AppUser>();
            Map<String, Integer> activeTasksMap = new HashMap<String, Integer>();
            Map<String, Integer> completedTasksMap = new HashMap<String, Integer>();

            for (AppUser staff : allStaff) {
                if (staff == null) continue;
                String staffArea = staff.getAreaID();

                boolean inScope = false;
                if ("ADM".equals(role) || "SAD".equals(role)) {
                    inScope = true;
                } else if (staffArea != null) {
                    for (String aId : assignedAreas) {
                        if (aId.equalsIgnoreCase(staffArea.trim())) {
                            inScope = true;
                            break;
                        }
                    }
                }

                if (inScope) {
                    staffList.add(staff);
                    int activeCount = 0;
                    int completedCount = 0;
                    try {
                        List<CollectionRequest> requests = collectionDAO.getByStaff(staff.getUserId());
                        if (requests != null) {
                            for (CollectionRequest cr : requests) {
                                String status = cr.getStatus();
                                if ("Pending".equalsIgnoreCase(status) || "In_Progress".equalsIgnoreCase(status)) {
                                    activeCount++;
                                } else if ("Completed".equalsIgnoreCase(status) || "Verified".equalsIgnoreCase(status)) {
                                    completedCount++;
                                }
                            }
                        }
                    } catch (Exception e) {
                        log("Error calculating staff workload for " + staff.getUserId(), e);
                    }
                    activeTasksMap.put(staff.getUserId(), activeCount);
                    completedTasksMap.put(staff.getUserId(), completedCount);
                }
            }

            request.setAttribute("LIST_STAFF", staffList);
            request.setAttribute("ACTIVE_TASKS_MAP", activeTasksMap);
            request.setAttribute("COMPLETED_TASKS_MAP", completedTasksMap);
            request.setAttribute("SEARCH", search);
            request.getRequestDispatcher(LIST_VIEW).forward(request, response);

        } catch (Exception e) {
            log("Error in StaffServlet", e);
            request.setAttribute("ERROR", "Unable to load area staff: " + e.getMessage());
            request.getRequestDispatcher(DENIED).forward(request, response);
        }
    }

    private List<String> getAssignedAreas(AppUser user) {
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

    private AppUser getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;
        return (AppUser) session.getAttribute("user");
    }
}
