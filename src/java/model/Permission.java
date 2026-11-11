package model;

import java.io.Serializable;

/**
 * Dynamic System Permission Model (tblPermissions)
 */
public class Permission implements Serializable {

    private String permissionId;
    private String permissionName;
    private String category;
    private String description;

    public Permission() {
    }

    public Permission(String permissionId, String permissionName, String category, String description) {
        this.permissionId = permissionId;
        this.permissionName = permissionName;
        this.category = category;
        this.description = description;
    }

    public String getPermissionId() {
        return permissionId;
    }

    public void setPermissionId(String permissionId) {
        this.permissionId = permissionId;
    }

    public String getPermissionName() {
        return permissionName;
    }

    public void setPermissionName(String permissionName) {
        this.permissionName = permissionName;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    @Override
    public String toString() {
        return permissionName != null ? permissionName : permissionId;
    }
}
