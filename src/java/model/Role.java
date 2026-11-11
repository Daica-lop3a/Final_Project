package model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Model for user roles and permissions (tblRoles & tblRolePermissions)
 */
public class Role implements Serializable {
    private String roleId;
    private String roleName;
    private String description;
    private int userCount;
    private boolean active = true;
    private List<Permission> permissions = new ArrayList<Permission>();

    public Role() {
    }

    public Role(String roleId, String roleName, String description) {
        this.roleId = roleId;
        this.roleName = roleName;
        this.description = description;
    }

    public String getRoleId() {
        return roleId;
    }

    public void setRoleId(String roleId) {
        this.roleId = roleId;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getUserCount() {
        return userCount;
    }

    public void setUserCount(int userCount) {
        this.userCount = userCount;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public List<Permission> getPermissions() {
        return permissions;
    }

    public void setPermissions(List<Permission> permissions) {
        this.permissions = permissions != null ? permissions : new ArrayList<Permission>();
    }

    public boolean hasPermission(String permId) {
        if (permId == null || permissions == null) return false;
        for (Permission p : permissions) {
            if (permId.equalsIgnoreCase(p.getPermissionId())) {
                return true;
            }
        }
        return false;
    }

    public Set<String> getPermissionIdSet() {
        Set<String> set = new HashSet<String>();
        if (permissions != null) {
            for (Permission p : permissions) {
                set.add(p.getPermissionId());
            }
        }
        return set;
    }
}
