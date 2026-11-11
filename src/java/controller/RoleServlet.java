package controller;

import dao.AuditLogDAO;
import dao.RoleDAO;
import filter.AuthFilter;
import model.AppUser;
import model.Permission;
import model.Role;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Super Admin Dynamic Role & Permission Governance Controller.
 * Enables live configuration of security permissions and operational scopes.
 */
@WebServlet(urlPatterns = {
    "/role",
    "/role/edit",
    "/role/save"
})
public class RoleServlet extends HttpServlet {

    private final RoleDAO roleDAO = new RoleDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        AppUser user = (session != null) ? (AppUser) session.getAttribute("user") : null;

        if (user == null || !user.isSuperAdmin()) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        String path = req.getServletPath();

        // EDIT FORM
        if ("/role/edit".equals(path)) {
            String roleId = req.getParameter("id");
            if (roleId != null && "SAD".equalsIgnoreCase(roleId.trim())) {
                // Super Admin role is master & immutable, cannot be edited
                resp.sendRedirect(req.getContextPath() + "/role");
                return;
            }
            Role role = roleDAO.findById(roleId);
            if (role == null) {
                resp.sendRedirect(req.getContextPath() + "/role");
                return;
            }

            List<Permission> allPerms = roleDAO.getAllPermissions();
            req.setAttribute("ROLE", role);
            req.setAttribute("ALL_PERMISSIONS", allPerms);
            req.getRequestDispatcher("/WEB-INF/views/roleForm.jsp").forward(req, resp);
            return;
        }

        // ROLE LIST / MATRIX
        List<Role> roles = roleDAO.getAllRolesWithCounts();
        req.setAttribute("LIST_ROLES", roles);

        String msg = req.getParameter("msg");
        if ("perms_updated".equals(msg)) {
            req.setAttribute("SUCCESS_MSG", "Role permissions & security matrix updated successfully! Changes are live across all active sessions.");
        }

        req.getRequestDispatcher("/WEB-INF/views/roleList.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        AppUser user = (session != null) ? (AppUser) session.getAttribute("user") : null;

        if (user == null || !user.isSuperAdmin()) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        String roleId = req.getParameter("roleId");
        if (roleId != null && "SAD".equalsIgnoreCase(roleId.trim())) {
            // Super Admin role is master & immutable
            resp.sendRedirect(req.getContextPath() + "/role");
            return;
        }
        String roleName = req.getParameter("roleName");
        String description = req.getParameter("description");
        String[] selectedPerms = req.getParameterValues("permissions");

        List<String> permList = new ArrayList<String>();
        if (selectedPerms != null) {
            permList.addAll(Arrays.asList(selectedPerms));
        }

        if (roleId == null || roleId.trim().isEmpty() || roleName == null || roleName.trim().isEmpty()) {
            req.setAttribute("ERROR", "Role Name and Identifier are required.");
            Role r = roleDAO.findById(roleId);
            if (r == null) r = new Role(roleId, roleName, description);
            req.setAttribute("ROLE", r);
            req.setAttribute("ALL_PERMISSIONS", roleDAO.getAllPermissions());
            req.getRequestDispatcher("/WEB-INF/views/roleForm.jsp").forward(req, resp);
            return;
        }

        roleId = roleId.trim().toUpperCase();

        // Safeguard: Super Admin must always retain SYSTEM_CONFIG permission to prevent lockout
        if ("SAD".equals(roleId) && !permList.contains("SYSTEM_CONFIG")) {
            permList.add("SYSTEM_CONFIG");
        }

        Role role = new Role();
        role.setRoleId(roleId);
        role.setRoleName(roleName.trim());
        role.setDescription(description != null ? description.trim() : "");

        boolean ok = roleDAO.updateRoleWithPermissions(role, permList);

        if (ok) {
            // Hot-reload permissions cache in AuthFilter immediately
            AuthFilter.reloadPermissions();

            // Log security audit trail
            AuditLogDAO.log(
                    user.getUserId(),
                    "UPDATE_ROLE_PERMISSIONS",
                    "tblRoles",
                    roleId,
                    null,
                    "Super Admin updated permissions for " + roleName + " (" + permList.size() + " permissions assigned)",
                    req.getRemoteAddr()
            );

            resp.sendRedirect(req.getContextPath() + "/role?msg=perms_updated");
        } else {
            req.setAttribute("ERROR", "Failed to update role permissions. Please try again.");
            req.setAttribute("ROLE", role);
            req.setAttribute("ALL_PERMISSIONS", roleDAO.getAllPermissions());
            req.getRequestDispatcher("/WEB-INF/views/roleForm.jsp").forward(req, resp);
        }
    }
}
