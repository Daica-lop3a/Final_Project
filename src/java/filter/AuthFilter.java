package filter;

import dao.RoleDAO;
import model.AppUser;

import java.io.IOException;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Dynamic Security & RBAC Access Control Filter.
 * Enforces dynamic permissions configured by Super Admin via /role.
 */
@WebFilter("/*")
public class AuthFilter implements Filter {

    private static final String[] PUBLIC_PREFIX = {
        "/login",
        "/logout",
        "/register",
        "/forgot-password",
        "/reset-password",
        "/verify-otp",
        "/public-bins",
        "/api/bin/update-fill",
        "/SensorServlet",
        "/css/",
        "/js/",
        "/images/",
        "/favicon.ico"
    };

    // Mapping of Protected URL -> Required Functional Permission ID
    private static final Map<String, String> URL_PERM_MAP = new LinkedHashMap<String, String>();

    // Live In-Memory Cache: URL -> Set of Allowed Role IDs (Hot-swappable)
    private static volatile Map<String, Set<String>> ACCESS = new ConcurrentHashMap<String, Set<String>>();

    static {
        // 1. Identity & Access Management
        URL_PERM_MAP.put("/user/create", "USER_MGMT");
        URL_PERM_MAP.put("/user/edit", "USER_MGMT");
        URL_PERM_MAP.put("/user/save", "USER_MGMT");
        URL_PERM_MAP.put("/user/delete", "USER_MGMT");
        URL_PERM_MAP.put("/user/lock", "USER_MGMT");
        URL_PERM_MAP.put("/user/reset", "USER_MGMT");
        URL_PERM_MAP.put("/user/next-id", "USER_MGMT");
        URL_PERM_MAP.put("/user/view", "USER_MGMT");
        URL_PERM_MAP.put("/user", "USER_MGMT");

        // 2. Campus Zone & Area Management
        URL_PERM_MAP.put("/area/save", "AREA_MGMT");
        URL_PERM_MAP.put("/area/delete", "AREA_MGMT");
        URL_PERM_MAP.put("/area/create", "AREA_MGMT");
        URL_PERM_MAP.put("/area/edit", "AREA_MGMT");

        // 3. Smart Waste Bin Operations
        URL_PERM_MAP.put("/wastebin/save", "BIN_MANAGE");
        URL_PERM_MAP.put("/wastebin/delete", "BIN_MANAGE");
        URL_PERM_MAP.put("/wastebin/create", "BIN_MANAGE");
        URL_PERM_MAP.put("/wastebin/edit", "BIN_MANAGE");

        // 4. Collection Dispatch & Scheduling
        URL_PERM_MAP.put("/collection/verify", "COLLECTION_DISPATCH");
        URL_PERM_MAP.put("/collection/propose-schedule", "COLLECTION_DISPATCH");
        URL_PERM_MAP.put("/collection/staff-by-bin", "COLLECTION_DISPATCH");
        URL_PERM_MAP.put("/collection/delete", "COLLECTION_DISPATCH");
        URL_PERM_MAP.put("/collection/create", "COLLECTION_DISPATCH");
        URL_PERM_MAP.put("/staff", "COLLECTION_DISPATCH");

        // 5. Collection Execution
        URL_PERM_MAP.put("/collection/start", "COLLECTION_EXECUTE");
        URL_PERM_MAP.put("/collection/area-data", "COLLECTION_EXECUTE");

        // 6. Bin Inspections & Audits
        URL_PERM_MAP.put("/inspection/save", "INSPECTION_MGMT");
        URL_PERM_MAP.put("/inspection/delete", "INSPECTION_MGMT");
        URL_PERM_MAP.put("/inspection/create", "INSPECTION_MGMT");
        URL_PERM_MAP.put("/inspection/edit", "INSPECTION_MGMT");
        URL_PERM_MAP.put("/inspection", "INSPECTION_MGMT");

        // 7. Maintenance & Hardware Repairs
        URL_PERM_MAP.put("/maintenance/save", "MAINTENANCE_MGMT");
        URL_PERM_MAP.put("/maintenance/delete", "MAINTENANCE_MGMT");
        URL_PERM_MAP.put("/maintenance/create", "MAINTENANCE_MGMT");
        URL_PERM_MAP.put("/maintenance/edit", "MAINTENANCE_MGMT");
        URL_PERM_MAP.put("/maintenance", "MAINTENANCE_MGMT");

        // 8. Citizen Reports & Community Feedback
        URL_PERM_MAP.put("/citizen-report/save", "CITIZEN_REPORTS");
        URL_PERM_MAP.put("/citizen-report/update", "CITIZEN_REPORTS");
        URL_PERM_MAP.put("/citizen-report/cancel", "CITIZEN_REPORTS");
        URL_PERM_MAP.put("/citizen-report/rate", "CITIZEN_REPORTS");
        URL_PERM_MAP.put("/citizen-report/create", "CITIZEN_REPORTS");
        URL_PERM_MAP.put("/citizen-report/edit", "CITIZEN_REPORTS");
        URL_PERM_MAP.put("/citizen-report/verify", "CITIZEN_REPORTS");
        URL_PERM_MAP.put("/feedback/save", "CITIZEN_REPORTS");
        URL_PERM_MAP.put("/feedback/update", "CITIZEN_REPORTS");
        URL_PERM_MAP.put("/feedback/cancel", "CITIZEN_REPORTS");
        URL_PERM_MAP.put("/feedback/rate", "CITIZEN_REPORTS");
        URL_PERM_MAP.put("/feedback/create", "CITIZEN_REPORTS");
        URL_PERM_MAP.put("/feedback/edit", "CITIZEN_REPORTS");
        URL_PERM_MAP.put("/feedback/verify", "CITIZEN_REPORTS");

        // 9. Alert Management
        URL_PERM_MAP.put("/alert/save", "ALERT_MGMT");
        URL_PERM_MAP.put("/alert/delete", "ALERT_MGMT");
        URL_PERM_MAP.put("/alert/create", "ALERT_MGMT");
        URL_PERM_MAP.put("/alert/edit", "ALERT_MGMT");
        URL_PERM_MAP.put("/alert/resolve", "ALERT_MGMT");

        // 10. Analytics Dashboard & Reports
        URL_PERM_MAP.put("/report", "ANALYTICS_EXPORT");
        URL_PERM_MAP.put("/export", "ANALYTICS_EXPORT");

        // 11. Security Audit Logs Trail
        URL_PERM_MAP.put("/audit-log", "AUDIT_LOGS");
        URL_PERM_MAP.put("/log", "AUDIT_LOGS");

        // 12. Data Discrepancy & Quality Scanner
        URL_PERM_MAP.put("/discrepancy/view", "DISCREPANCY_AUDIT");
        URL_PERM_MAP.put("/discrepancy/create", "DISCREPANCY_AUDIT");
        URL_PERM_MAP.put("/discrepancy/save", "DISCREPANCY_AUDIT");
        URL_PERM_MAP.put("/discrepancy/investigate", "DISCREPANCY_AUDIT");
        URL_PERM_MAP.put("/discrepancy/close", "DISCREPANCY_AUDIT");
        URL_PERM_MAP.put("/discrepancy", "DISCREPANCY_AUDIT");
        URL_PERM_MAP.put("/data-quality", "DISCREPANCY_AUDIT");
        URL_PERM_MAP.put("/audit/data-quality", "DISCREPANCY_AUDIT");

        // 13. IoT Devices & Catalogs
        URL_PERM_MAP.put("/device/save", "DEVICE_MGMT");
        URL_PERM_MAP.put("/device/delete", "DEVICE_MGMT");
        URL_PERM_MAP.put("/device/create", "DEVICE_MGMT");
        URL_PERM_MAP.put("/device/edit", "DEVICE_MGMT");
        URL_PERM_MAP.put("/device/assign", "DEVICE_MGMT");
        URL_PERM_MAP.put("/device/import", "DEVICE_MGMT");
        URL_PERM_MAP.put("/device", "DEVICE_MGMT");
        URL_PERM_MAP.put("/catalog/save", "DEVICE_MGMT");
        URL_PERM_MAP.put("/catalog/delete", "DEVICE_MGMT");
        URL_PERM_MAP.put("/catalog", "DEVICE_MGMT");

        // 14. Master Governance & System Settings
        URL_PERM_MAP.put("/admin-approval", "SYSTEM_CONFIG");
        URL_PERM_MAP.put("/system/config", "SYSTEM_CONFIG");
        URL_PERM_MAP.put("/system/backup", "SYSTEM_CONFIG");
        URL_PERM_MAP.put("/role", "SYSTEM_CONFIG");
        URL_PERM_MAP.put("/role/edit", "SYSTEM_CONFIG");
        URL_PERM_MAP.put("/role/save", "SYSTEM_CONFIG");

        // Load permissions initially
        reloadPermissions();
    }

    /**
     * Hot-reloads dynamic role permissions directly from Database into memory.
     * Can be invoked after any update in RoleServlet without server restart.
     */
    public static synchronized void reloadPermissions() {
        Map<String, Set<String>> newAccess = new ConcurrentHashMap<String, Set<String>>();
        Set<String> allRoles = roles("SAD", "ADM", "MGR", "SUP", "STF", "TEC", "AUD", "USR");

        // 1. Universal baseline URLs open to all authenticated users
        newAccess.put("/dashboard", allRoles);
        newAccess.put("/map", allRoles);
        newAccess.put("/profile", allRoles);
        newAccess.put("/api/bins-location", allRoles);
        newAccess.put("/api/bin/status", allRoles);
        newAccess.put("/public-map", allRoles);
        newAccess.put("/help", allRoles);
        newAccess.put("/guide", allRoles);
        newAccess.put("/notification", allRoles);
        newAccess.put("/wastebin/view", allRoles);
        newAccess.put("/wastebin/detail", allRoles);
        newAccess.put("/wastebin", allRoles);
        newAccess.put("/area/view", allRoles);
        newAccess.put("/area", allRoles);
        newAccess.put("/citizen-report/detail", allRoles);
        newAccess.put("/citizen-report/view", allRoles);
        newAccess.put("/citizen-report", allRoles);
        newAccess.put("/feedback/detail", allRoles);
        newAccess.put("/feedback/view", allRoles);
        newAccess.put("/feedback", allRoles);
        newAccess.put("/alert", allRoles);

        // 2. Query dynamic role permissions from DB
        RoleDAO roleDAO = new RoleDAO();
        Map<String, Set<String>> rolePermMap = roleDAO.getRolePermissionsMap();

        // 3. Map URLs to allowed roles dynamically
        for (Map.Entry<String, String> entry : URL_PERM_MAP.entrySet()) {
            String url = entry.getKey();
            String permId = entry.getValue();

            Set<String> allowedRoles = new HashSet<String>();
            // Super Admin always retains master governance
            allowedRoles.add("SAD");

            for (Map.Entry<String, Set<String>> roleEntry : rolePermMap.entrySet()) {
                String roleId = roleEntry.getKey();
                Set<String> perms = roleEntry.getValue();
                if (perms != null && perms.contains(permId)) {
                    allowedRoles.add(roleId);
                }
            }

            newAccess.put(url, Collections.unmodifiableSet(allowedRoles));
        }

        // 4. Multi-permission URLs: Collection operations require either DISPATCH or EXECUTE
        Set<String> collectionRoles = new HashSet<String>();
        collectionRoles.add("SAD");
        for (Map.Entry<String, Set<String>> roleEntry : rolePermMap.entrySet()) {
            String roleId = roleEntry.getKey();
            Set<String> perms = roleEntry.getValue();
            if (perms != null && (perms.contains("COLLECTION_DISPATCH") || perms.contains("COLLECTION_EXECUTE"))) {
                collectionRoles.add(roleId);
            }
        }
        newAccess.put("/collection/view", Collections.unmodifiableSet(collectionRoles));
        newAccess.put("/collection", Collections.unmodifiableSet(collectionRoles));
        newAccess.put("/collection/save", Collections.unmodifiableSet(collectionRoles));
        newAccess.put("/collection/edit", Collections.unmodifiableSet(collectionRoles));

        ACCESS = newAccess;
        System.out.println("[AuthFilter] Dynamic RBAC permissions reloaded successfully. Protected routes: " + ACCESS.size());
    }

    private static Set<String> roles(String... values) {
        return new HashSet<String>(Arrays.asList(values));
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        reloadPermissions();
    }

    @Override
    public void doFilter(ServletRequest rq, ServletResponse rp, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) rq;
        HttpServletResponse resp = (HttpServletResponse) rp;

        req.setCharacterEncoding("UTF-8");

        String ctx = req.getContextPath();
        String path = req.getRequestURI().substring(ctx.length());

        if (path.isEmpty()) {
            path = "/";
        }

        // PUBLIC LANDING PAGE
        if ("/".equals(path) || "/index.jsp".equals(path)) {
            chain.doFilter(rq, rp);
            return;
        }

        // PUBLIC STATIC & AUTH URLS
        for (String prefix : PUBLIC_PREFIX) {
            if (path.equals(prefix) || path.startsWith(prefix)) {
                chain.doFilter(rq, rp);
                return;
            }
        }

        // Disable browser caching for protected resources
        resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        resp.setHeader("Pragma", "no-cache");
        resp.setDateHeader("Expires", 0);

        // GET USER FROM SESSION
        AppUser me = null;
        if (req.getSession(false) != null) {
            Object sessionUser = req.getSession(false).getAttribute("user");
            if (sessionUser instanceof AppUser) {
                me = (AppUser) sessionUser;
            }
        }

        // LOGIN REQUIRED
        if (me == null) {
            resp.sendRedirect(ctx + "/login");
            return;
        }

        String roleId = me.getRoleId();

        // DENY SESSION WITH MISSING ROLE
        if (roleId == null || roleId.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Your account does not have a valid role.");
            return;
        }

        roleId = roleId.trim().toUpperCase();

        // CHECK DYNAMIC ACCESS BY URL
        for (Map.Entry<String, Set<String>> entry : ACCESS.entrySet()) {
            String url = entry.getKey();

            // Exact match or sub-path match; avoid matching unrelated paths like /areaSomething
            if (path.equals(url) || path.startsWith(url + "/")) {
                Set<String> allowedRoles = entry.getValue();

                if (!allowedRoles.contains(roleId)) {
                    resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    req.setAttribute("ERROR", "You do not have permission to access this page (" + url + ").");
                    req.getRequestDispatcher("/WEB-INF/views/denied.jsp").forward(req, resp);
                    return;
                }
                break;
            }
        }

        chain.doFilter(rq, rp);
    }

    @Override
    public void destroy() {
    }
}
