package dao;

import model.Permission;
import model.Role;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * DAO handling user roles and dynamic permissions management.
 * Accessible by Super Admin.
 */
public class RoleDAO {

    public List<Role> getAllRolesWithCounts() {
        List<Role> list = new ArrayList<Role>();
        String sql = "SELECT r.roleID, r.roleName, r.description, "
                + "(SELECT COUNT(*) FROM dbo.tblUsers u WHERE u.roleID = r.roleID) AS userCount "
                + "FROM dbo.tblRoles r "
                + "ORDER BY CASE r.roleID "
                + "  WHEN 'SAD' THEN 1 "
                + "  WHEN 'ADM' THEN 2 "
                + "  WHEN 'MGR' THEN 3 "
                + "  WHEN 'SUP' THEN 4 "
                + "  WHEN 'STF' THEN 5 "
                + "  WHEN 'TEC' THEN 6 "
                + "  WHEN 'AUD' THEN 7 "
                + "  WHEN 'USR' THEN 8 "
                + "  ELSE 9 END";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                Role role = new Role();
                role.setRoleId(rs.getString("roleID"));
                role.setRoleName(rs.getString("roleName"));
                role.setDescription(rs.getString("description"));
                role.setUserCount(rs.getInt("userCount"));
                list.add(role);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }

        // Attach permissions for each role
        for (Role role : list) {
            role.setPermissions(getPermissionsForRole(role.getRoleId()));
        }

        return list;
    }

    public Role findById(String roleId) {
        if (roleId == null || roleId.trim().isEmpty()) {
            return null;
        }

        String sql = "SELECT r.roleID, r.roleName, r.description, "
                + "(SELECT COUNT(*) FROM dbo.tblUsers u WHERE u.roleID = r.roleID) AS userCount "
                + "FROM dbo.tblRoles r WHERE r.roleID = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, roleId.trim());
            rs = ps.executeQuery();

            if (rs.next()) {
                Role role = new Role();
                role.setRoleId(rs.getString("roleID"));
                role.setRoleName(rs.getString("roleName"));
                role.setDescription(rs.getString("description"));
                role.setUserCount(rs.getInt("userCount"));
                role.setPermissions(getPermissionsForRole(role.getRoleId()));
                return role;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }

        return null;
    }

    public List<Permission> getPermissionsForRole(String roleId) {
        List<Permission> list = new ArrayList<Permission>();
        if (roleId == null || roleId.trim().isEmpty()) {
            return list;
        }

        String sql = "SELECT p.permissionID, p.permissionName, p.category, p.description "
                + "FROM dbo.tblPermissions p "
                + "INNER JOIN dbo.tblRolePermissions rp ON p.permissionID = rp.permissionID "
                + "WHERE rp.roleID = ? "
                + "ORDER BY p.category, p.permissionName";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, roleId.trim());
            rs = ps.executeQuery();

            while (rs.next()) {
                Permission p = new Permission();
                p.setPermissionId(rs.getString("permissionID"));
                p.setPermissionName(rs.getString("permissionName"));
                p.setCategory(rs.getString("category"));
                p.setDescription(rs.getString("description"));
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }

        return list;
    }

    public List<Permission> getAllPermissions() {
        List<Permission> list = new ArrayList<Permission>();
        String sql = "SELECT permissionID, permissionName, category, description "
                + "FROM dbo.tblPermissions "
                + "ORDER BY category, permissionName";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                Permission p = new Permission();
                p.setPermissionId(rs.getString("permissionID"));
                p.setPermissionName(rs.getString("permissionName"));
                p.setCategory(rs.getString("category"));
                p.setDescription(rs.getString("description"));
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }

        return list;
    }

    /**
     * Map of RoleId -> Set of PermissionIds for memory cache & instant lookup.
     */
    public Map<String, Set<String>> getRolePermissionsMap() {
        Map<String, Set<String>> map = new HashMap<String, Set<String>>();
        String sql = "SELECT roleID, permissionID FROM dbo.tblRolePermissions";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                String roleId = rs.getString("roleID");
                String permId = rs.getString("permissionID");
                Set<String> perms = map.get(roleId);
                if (perms == null) {
                    perms = new HashSet<String>();
                    map.put(roleId, perms);
                }
                perms.add(permId);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }

        return map;
    }

    /**
     * Atomically updates role metadata and permissions in a single transaction.
     */
    public boolean updateRoleWithPermissions(Role role, List<String> permissionIds) {
        if (role == null || role.getRoleId() == null) {
            return false;
        }

        Connection conn = null;
        PreparedStatement psRole = null;
        PreparedStatement psDel = null;
        PreparedStatement psIns = null;

        String roleSql = "UPDATE dbo.tblRoles SET roleName = ?, description = ? WHERE roleID = ?";
        String delSql = "DELETE FROM dbo.tblRolePermissions WHERE roleID = ?";
        String insSql = "INSERT INTO dbo.tblRolePermissions (roleID, permissionID) VALUES (?, ?)";

        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false); // Begin Transaction

            // 1. Update Role Metadata
            psRole = conn.prepareStatement(roleSql);
            psRole.setString(1, role.getRoleName());
            psRole.setString(2, role.getDescription());
            psRole.setString(3, role.getRoleId().trim());
            psRole.executeUpdate();

            // 2. Clear old permissions
            psDel = conn.prepareStatement(delSql);
            psDel.setString(1, role.getRoleId().trim());
            psDel.executeUpdate();

            // 3. Insert new permissions
            if (permissionIds != null && !permissionIds.isEmpty()) {
                psIns = conn.prepareStatement(insSql);
                for (String pId : permissionIds) {
                    if (pId != null && !pId.trim().isEmpty()) {
                        psIns.setString(1, role.getRoleId().trim());
                        psIns.setString(2, pId.trim());
                        psIns.addBatch();
                    }
                }
                psIns.executeBatch();
            }

            conn.commit(); // Commit Transaction
            return true;

        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return false;
        } finally {
            DBContext.close(psRole, null);
            DBContext.close(psDel, null);
            DBContext.close(psIns, null);
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }
}
