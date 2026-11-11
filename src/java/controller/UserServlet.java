package controller;

import dao.AuditLogDAO;
import dao.UserDAO;
import model.AppUser;
import java.util.List;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {
    "/user",
    "/user/create",
    "/user/view",
    "/user/edit",
    "/user/save",
    "/user/delete",
    "/user/lock",
    "/user/reset",
    "/user/next-id"
})
public class UserServlet extends HttpServlet {

    private static final String USER_LIST
            = "/WEB-INF/views/userList.jsp";

    private static final String USER_FORM
            = "/WEB-INF/views/userForm.jsp";

    private static final String DEFAULT_PASSWORD = "123456";

    private final UserDAO users = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        String action = action(req);
        javax.servlet.http.HttpSession session = req.getSession(false);
        AppUser loggedInUser = (session != null) ? (AppUser) session.getAttribute("user") : null;

        // AUDITOR READ-ONLY ENFORCEMENT
        if (loggedInUser != null && loggedInUser.isAuditor()) {
            if (!"/view".equals(action) && (action != null && !action.isEmpty())) {
                req.setAttribute("ERROR", "Auditor is strictly read-only and cannot create, modify, or delete user accounts.");
                req.getRequestDispatcher("/WEB-INF/views/denied.jsp").forward(req, resp);
                return;
            }
        }

        if ("/next-id".equals(action)) {
            String roleParam = req.getParameter("roleId");
            if (roleParam == null || roleParam.trim().isEmpty()) {
                roleParam = "STF";
            }
            String nextId = util.IdGenerator.nextUserId(roleParam.trim().toUpperCase());
            resp.setContentType("text/plain");
            resp.setCharacterEncoding("UTF-8");
            resp.getWriter().write(nextId);
            return;
        }

        if ("/create".equals(action)) {
            showForm(req, resp, null);
            return;
        }
        if ("/view".equals(action)) {

            String id = req.getParameter("id");

            if (id == null || id.trim().isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/user");
                return;
            }

            AppUser user = users.findById(id);

            if (user == null) {
                req.setAttribute(
                        "ERROR",
                        "User not found"
                );

                showList(req, resp);
                return;
            }

            if (loggedInUser != null && loggedInUser.isAdmin()) {
                if (user.isSuperAdmin()) {
                    req.getSession().setAttribute("ERROR", "Admin does not have permission to view Super Admin accounts");
                    resp.sendRedirect(req.getContextPath() + "/user");
                    return;
                }
            }

            req.setAttribute("USER", user);
            AuditLogDAO auditLogDAO = new AuditLogDAO();
            req.setAttribute("USER_LOGS", auditLogDAO.getLogsByRecord("tblUsers", id));

            req.getRequestDispatcher(
                    "/WEB-INF/views/userDetail.jsp"
            ).forward(req, resp);

            return;
        }

        if ("/edit".equals(action)) {

            String id = req.getParameter("id");

            if (id == null || id.trim().isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/user");
                return;
            }

            AppUser user = users.findById(id);

            if (user == null) {
                req.setAttribute("ERROR",
                        "User not found");

                showList(req, resp);
                return;
            }

            if (loggedInUser != null && loggedInUser.isAdmin()) {
                if (user.isSuperAdmin() || user.isAdmin()) {
                    req.getSession().setAttribute("ERROR", "Admin does not have permission to edit Super Admin or Admin accounts");
                    resp.sendRedirect(req.getContextPath() + "/user");
                    return;
                }
            }

            showForm(req, resp, user);
            return;
        }

        showList(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        javax.servlet.http.HttpSession session = req.getSession(false);
        AppUser loggedInUser = (session != null) ? (AppUser) session.getAttribute("user") : null;

        // AUDITOR READ-ONLY ENFORCEMENT
        if (loggedInUser != null && loggedInUser.isAuditor()) {
            req.setAttribute("ERROR", "Auditor is strictly read-only and cannot create, modify, lock, or delete user accounts.");
            req.getRequestDispatcher("/WEB-INF/views/denied.jsp").forward(req, resp);
            return;
        }

        String action = action(req);

        if ("/save".equals(action)) {
            save(req, resp);
            return;
        }

        if ("/delete".equals(action)) {
            delete(req, resp);
            return;
        }

        if ("/lock".equals(action)) {
            lock(req, resp);
            return;
        }

        if ("/reset".equals(action)) {
            reset(req, resp);
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/user");
    }

    private String action(HttpServletRequest req) {

        String path = req.getRequestURI()
                .substring(req.getContextPath().length());

        return path.substring("/user".length());
    }

    // =========================
    // LIST
    // =========================
    private void showList(HttpServletRequest req,
        HttpServletResponse resp)
        throws ServletException, IOException {

    try {
        javax.servlet.http.HttpSession session = req.getSession(false);
        AppUser loggedInUser = (session != null) ? (AppUser) session.getAttribute("user") : null;

        String keyword = req.getParameter("keyword");
        String roleId = req.getParameter("roleId");
        String statusFilter = req.getParameter("status");
        String pageParam = req.getParameter("page");

        if (keyword == null) {
            keyword = "";
        }

        if (roleId == null) {
            roleId = "";
        }

        // ROLE ISOLATION: Admin cannot view Super Admin accounts
        String excludeRole = null;
        if (loggedInUser != null && loggedInUser.isAdmin()) {
            excludeRole = "SAD";
            if ("SAD".equalsIgnoreCase(roleId)) {
                roleId = "";
            }
        }

        // CURRENT PAGE
        int currentPage = 1;

        try {
            if (pageParam != null
                    && !pageParam.trim().isEmpty()) {
                currentPage = Integer.parseInt(pageParam);
            }
        } catch (NumberFormatException e) {
            currentPage = 1;
        }

        if (currentPage < 1) {
            currentPage = 1;
        }

        // PAGE SIZE
        int pageSize = 10;

        // COUNT RECORDS
        int totalRecords = users.countSearch(keyword, roleId, excludeRole, statusFilter);

        // TOTAL PAGES
        int totalPages = (int) Math.ceil(
                (double) totalRecords / pageSize);

        if (totalPages < 1) {
            totalPages = 1;
        }

        if (currentPage > totalPages) {
            currentPage = totalPages;
        }

        // GET DATA FOR CURRENT PAGE
        List<AppUser> userList = users.searchPaged(
                keyword,
                roleId,
                excludeRole,
                statusFilter,
                currentPage,
                pageSize);

        // DATA FOR JSP
        req.setAttribute("LIST_USER", userList);
        req.setAttribute("KEYWORD", keyword);
        req.setAttribute("ROLE_ID", roleId);
        req.setAttribute("STATUS_FILTER", statusFilter);

        req.setAttribute(
                "PAGINATION_CURRENT_PAGE", currentPage);
        req.setAttribute(
                "PAGINATION_TOTAL_PAGES", totalPages);
        req.setAttribute(
                "PAGINATION_TOTAL_RECORDS", totalRecords);
        req.setAttribute(
                "PAGINATION_PAGE_SIZE", pageSize);
        req.setAttribute(
                "PAGINATION_BASE_URL",
                req.getContextPath() + "/user");

        req.getRequestDispatcher(USER_LIST)
                .forward(req, resp);

    } catch (Exception e) {

        log("Error at showList: " + e.toString());

        req.setAttribute("ERROR", "System error");

        req.getRequestDispatcher(USER_LIST)
                .forward(req, resp);
    }
}

    // =========================
    // FORM
    // =========================
    private void showForm(HttpServletRequest req,
            HttpServletResponse resp,
            AppUser user)
            throws ServletException, IOException {

        req.setAttribute("USER", user);
        if (user == null) {
            java.util.Map<String, String> nextIds = new java.util.LinkedHashMap<String, String>();
            for (String r : new String[]{"SAD", "ADM", "MGR", "SUP", "STF", "TEC", "AUD", "USR"}) {
                nextIds.put(r, util.IdGenerator.nextUserId(r));
            }
            req.setAttribute("ROLE_NEXT_IDS", nextIds);

            javax.servlet.http.HttpSession session = req.getSession(false);
            AppUser loggedInUser = (session != null) ? (AppUser) session.getAttribute("user") : null;
            String defaultRole = (loggedInUser != null && loggedInUser.isSuperAdmin()) ? "SAD" : "STF";
            req.setAttribute("DEFAULT_ROLE", defaultRole);
            req.setAttribute("NEXT_USER_ID", nextIds.get(defaultRole));
        }

        req.getRequestDispatcher(USER_FORM)
                .forward(req, resp);
    }

    // =========================
    // SAVE
    // =========================
    private void save(HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        String userId = req.getParameter("userId");
        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String phoneNumber = req.getParameter("phoneNumber");
        String roleId = req.getParameter("roleId");
        String oldId = req.getParameter("oldId");
        boolean isCreate = (oldId == null || oldId.trim().isEmpty());

        if (fullName == null) {
            fullName = "";
        }

        if (email == null) {
            email = "";
        }

        if (phoneNumber == null) {
            phoneNumber = "";
        }

        if (roleId == null) {
            roleId = "";
        }

        fullName = fullName.trim();
        email = email.trim();
        phoneNumber = phoneNumber.trim();
        roleId = roleId.trim().toUpperCase();

        // 1. Role validation
        if (!roleId.equals("SAD")
                && !roleId.equals("ADM")
                && !roleId.equals("MGR")
                && !roleId.equals("SUP")
                && !roleId.equals("STF")
                && !roleId.equals("TEC")
                && !roleId.equals("AUD")
                && !roleId.equals("USR")) {

            req.setAttribute("ERROR", "Invalid role selected. Must belong to the 8 system roles.");
            showFormWithValues(req, resp);
            return;
        }

        // 2. Auto-generate ID & Role prefix constraint check on Create
        if (isCreate) {
            if (userId == null || userId.trim().isEmpty()) {
                userId = util.IdGenerator.nextUserId(roleId);
            } else {
                userId = userId.trim().toUpperCase();
            }

            // Strict Role Prefix Constraint: MUST start with roleId + "-"
            String expectedPrefix = roleId + "-";
            if (!userId.startsWith(expectedPrefix)) {
                req.setAttribute("ERROR", "Role constraint violation: Account ID for role " + roleId + " must begin with '" + expectedPrefix + "' (e.g. " + expectedPrefix + "001).");
                showFormWithValues(req, resp);
                return;
            }

            // Format check: PREFIX-digits (e.g. STF-001)
            if (!userId.matches("^[A-Z]{3}-\\d{3,}$")) {
                req.setAttribute("ERROR", "Invalid User ID format: Expected 3-letter role prefix with at least 3 digits (e.g. " + expectedPrefix + "001).");
                showFormWithValues(req, resp);
                return;
            }

            // Duplicate ID check
            if (users.findById(userId) != null) {
                String freshId = util.IdGenerator.nextUserId(roleId);
                if (freshId.equals(userId) || users.findById(freshId) != null) {
                    req.setAttribute("ERROR", "User ID '" + userId + "' already exists in the system.");
                    showFormWithValues(req, resp);
                    return;
                }
                userId = freshId;
            }

            // Duplicate Email check on Create
            if (users.findByEmail(email) != null) {
                req.setAttribute("ERROR", "Email address '" + email + "' is already registered to another user.");
                showFormWithValues(req, resp);
                return;
            }
        } else {
            // Updating existing user
            userId = (userId != null && !userId.trim().isEmpty()) ? userId.trim() : oldId.trim();

            // Duplicate Email check on Update
            AppUser existing = users.findByEmail(email);
            if (existing != null && !existing.getUserId().equalsIgnoreCase(oldId.trim())) {
                req.setAttribute("ERROR", "Email address '" + email + "' is already registered to another user.");
                showFormWithValues(req, resp);
                return;
            }
        }

        // 3. Contact details validation
        if (fullName.length() < 2) {
            req.setAttribute("ERROR", "Full name must be at least 2 characters long.");
            showFormWithValues(req, resp);
            return;
        }

        if (email.length() == 0 || !email.contains("@")) {
            req.setAttribute("ERROR", "Please provide a valid email address.");
            showFormWithValues(req, resp);
            return;
        }

        if (phoneNumber.length() == 0) {
            req.setAttribute("ERROR", "Phone number cannot be empty.");
            showFormWithValues(req, resp);
            return;
        }

        // Vietnamese mobile phone validation: 10 digits starting with 03, 05, 07, 08, 09 or +84
        if (!phoneNumber.matches("^(?:\\+84|0)[35789]\\d{8}$")) {
            req.setAttribute("ERROR", "Invalid Vietnamese phone number. Format must be 10 digits starting with 03, 05, 07, 08, 09 (e.g. 0901234567 or +84901234567).");
            showFormWithValues(req, resp);
            return;
        }

        // 4. Role Hierarchy Protection: Admin cannot manage or create Super Admin or other Admins
        javax.servlet.http.HttpSession session = req.getSession(false);
        AppUser loggedInUser = (session != null) ? (AppUser) session.getAttribute("user") : null;
        if (loggedInUser != null && loggedInUser.isAdmin()) {
            if ("SAD".equals(roleId) || "ADM".equals(roleId)) {
                req.setAttribute("ERROR", "Admin does not have permission to create or assign Super Admin or Admin roles.");
                showFormWithValues(req, resp);
                return;
            }
            AppUser targetUser = users.findById(userId);
            if (targetUser != null && (targetUser.isSuperAdmin() || targetUser.isAdmin())) {
                req.setAttribute("ERROR", "Admin does not have permission to modify Super Admin or Admin accounts.");
                showFormWithValues(req, resp);
                return;
            }
        }

        try {
            AppUser user = new AppUser();
            user.setUserId(userId);
            user.setFullName(fullName);
            user.setEmail(email);
            user.setPhoneNumber(phoneNumber);
            user.setRoleId(roleId);

            if (isCreate) {
                // CREATE
                user.setPassword(DEFAULT_PASSWORD);
                user.setStatus(true);

                boolean result = users.insert(user);
                if (!result) {
                    req.setAttribute("ERROR", "Failed to create account. Please check data and try again.");
                    showFormWithValues(req, resp);
                    return;
                }

                AuditLogDAO.log(
                        loggedInUser != null ? loggedInUser.getUserId() : userId,
                        "CREATE_USER",
                        "tblUsers",
                        userId,
                        null,
                        "Created user account " + fullName + " (" + roleId + ")",
                        req.getRemoteAddr()
                );

            } else {
                // UPDATE
                boolean result = users.update(user);
                if (!result) {
                    req.setAttribute("ERROR", "Failed to update account. Please check data and try again.");
                    showFormWithValues(req, resp);
                    return;
                }

                AuditLogDAO.log(
                        loggedInUser != null ? loggedInUser.getUserId() : userId,
                        "UPDATE_USER",
                        "tblUsers",
                        userId,
                        null,
                        "Updated user profile & role for " + fullName + " (" + roleId + ")",
                        req.getRemoteAddr()
                );
            }

            resp.sendRedirect(req.getContextPath() + "/user");

        } catch (Exception e) {
            log("Error at save: " + e.toString());
            req.setAttribute("ERROR", "System error occurred. Please try again.");
            showFormWithValues(req, resp);
        }
    }

    // =========================
    // DELETE
    // =========================
    private void delete(HttpServletRequest req,
            HttpServletResponse resp)
            throws IOException {

        String userId = req.getParameter("id");

        if (userId == null || userId.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/user");
            return;
        }

        try {
            javax.servlet.http.HttpSession session = req.getSession(false);
            AppUser loggedInUser = (session != null) ? (AppUser) session.getAttribute("user") : null;
            if (loggedInUser != null && loggedInUser.isAdmin()) {
                AppUser target = users.findById(userId);
                if (target != null && (target.isSuperAdmin() || target.isAdmin())) {
                    req.getSession().setAttribute("ERROR", "Admin does not have permission to delete Super Admin or other Admin accounts");
                    resp.sendRedirect(req.getContextPath() + "/user");
                    return;
                }
            }

            boolean result = users.delete(userId);

            if (result) {
                AuditLogDAO.log(
                        loggedInUser != null ? loggedInUser.getUserId() : "SYSTEM",
                        "DELETE_USER",
                        "tblUsers",
                        userId,
                        null,
                        "Deleted/Deactivated user account " + userId,
                        req.getRemoteAddr()
                );
            } else {
                req.getSession().setAttribute(
                        "ERROR",
                        "Failed to delete account");
            }

        } catch (Exception e) {

            log("Error at delete: " + e.toString());

        }

        resp.sendRedirect(req.getContextPath()
                + "/user");
    }

    // =========================
    // LOCK / UNLOCK
    // =========================
    private void lock(HttpServletRequest req,
            HttpServletResponse resp)
            throws IOException {

        String userId = req.getParameter("id");

        if (userId == null || userId.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/user");
            return;
        }

        try {
            javax.servlet.http.HttpSession session = req.getSession(false);
            AppUser loggedInUser = (session != null) ? (AppUser) session.getAttribute("user") : null;
            if (loggedInUser != null && loggedInUser.isAdmin()) {
                AppUser target = users.findById(userId);
                if (target != null && (target.isSuperAdmin() || target.isAdmin())) {
                    req.getSession().setAttribute("ERROR", "Admin does not have permission to lock Super Admin or other Admin accounts");
                    resp.sendRedirect(req.getContextPath() + "/user");
                    return;
                }
            }

            AppUser user = users.findById(userId);

            if (user != null) {

                boolean newStatus = !user.isStatus();

                boolean updated = users.setStatus(userId, newStatus);
                if (updated) {
                    AuditLogDAO.log(
                            loggedInUser != null ? loggedInUser.getUserId() : "SYSTEM",
                            newStatus ? "UNLOCK_USER" : "LOCK_USER",
                            "tblUsers",
                            userId,
                            String.valueOf(user.isStatus()),
                            (newStatus ? "Unlocked" : "Locked") + " user account " + userId,
                            req.getRemoteAddr()
                    );
                }
            }

        } catch (Exception e) {

            log("Error at lock: " + e.toString());
        }

        resp.sendRedirect(req.getContextPath()
                + "/user");
    }

    // =========================
    // RESET PASSWORD
    // =========================
    private void reset(HttpServletRequest req,
            HttpServletResponse resp)
            throws IOException {

        String userId = req.getParameter("id");

        if (userId == null || userId.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/user");
            return;
        }

        try {
            javax.servlet.http.HttpSession session = req.getSession(false);
            AppUser loggedInUser = (session != null) ? (AppUser) session.getAttribute("user") : null;
            if (loggedInUser != null && loggedInUser.isAdmin()) {
                AppUser target = users.findById(userId);
                if (target != null && (target.isSuperAdmin() || target.isAdmin())) {
                    req.getSession().setAttribute("ERROR", "Admin cannot reset password for Super Admin or Admin accounts. Only Super Admin has this permission.");
                    resp.sendRedirect(req.getContextPath() + "/user");
                    return;
                }
            }

            boolean resetResult = users.resetPassword(
                    userId,
                    DEFAULT_PASSWORD
            );

            if (resetResult) {
                AuditLogDAO.log(
                        loggedInUser != null ? loggedInUser.getUserId() : "SYSTEM",
                        "RESET_PASSWORD",
                        "tblUsers",
                        userId,
                        null,
                        "Reset password to default for user " + userId,
                        req.getRemoteAddr()
                );
            }

        } catch (Exception e) {

            log("Error at reset: " + e.toString());
        }

        resp.sendRedirect(req.getContextPath()
                + "/user");
    }

    // =========================
    // FORM VALUES
    // =========================
    private void showFormWithValues(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        AppUser user = new AppUser();

        user.setUserId(req.getParameter("userId"));
        user.setFullName(req.getParameter("fullName"));
        user.setEmail(req.getParameter("email"));
        user.setPhoneNumber(req.getParameter("phoneNumber"));
        user.setRoleId(req.getParameter("roleId"));

        req.setAttribute("USER", user);

        String oldId = req.getParameter("oldId");
        if (oldId == null || oldId.trim().isEmpty()) {
            java.util.Map<String, String> nextIds = new java.util.LinkedHashMap<String, String>();
            for (String r : new String[]{"SAD", "ADM", "MGR", "SUP", "STF", "TEC", "AUD", "USR"}) {
                nextIds.put(r, util.IdGenerator.nextUserId(r));
            }
            req.setAttribute("ROLE_NEXT_IDS", nextIds);

            String roleId = user.getRoleId();
            if (roleId != null && nextIds.containsKey(roleId.toUpperCase())) {
                req.setAttribute("NEXT_USER_ID", nextIds.get(roleId.toUpperCase()));
            } else {
                req.setAttribute("NEXT_USER_ID", nextIds.get("STF"));
            }
        }

        req.getRequestDispatcher(USER_FORM)
                .forward(req, resp);
    }
}
