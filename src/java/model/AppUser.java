package model;

import java.sql.Timestamp;

/**
 * Model for Application Users (AppUser)
 * Supports 8 system roles (RBAC)
 * - SAD: Super Admin
 * - ADM: Admin
 * - MGR: Operations Manager
 * - SUP: Area Supervisor
 * - STF: Collection Staff
 * - TEC: Technician
 * - AUD: Auditor
 * - USR: Citizen User
 */
public class AppUser {

    private String userId;
    private String fullName;
    private String email;
    private String phoneNumber;
    private String roleId;
    private String password;
    private boolean status;
    private Timestamp createdDate;
    private String areaID;

    // Display helper fields
    private String areaName;

    public AppUser() {
    }

    public AppUser(String userId, String fullName, String email,
                   String phoneNumber, String roleId,
                   String password, boolean status) {
        this.userId = userId;
        this.fullName = fullName;
        this.email = email;
        this.phoneNumber = phoneNumber;
        this.roleId = roleId;
        this.password = password;
        this.status = status;
    }

    public AppUser(String userId, String fullName, String email,
                   String phoneNumber, String roleId,
                   String password, boolean status, String areaID) {
        this(userId, fullName, email, phoneNumber, roleId, password, status);
        this.areaID = areaID;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getUserID() {
        return userId;
    }

    public void setUserID(String userID) {
        this.userId = userID;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getRoleId() {
        return roleId;
    }

    public void setRoleId(String roleId) {
        this.roleId = roleId;
    }

    public String getRoleID() {
        return roleId;
    }

    public void setRoleID(String roleID) {
        this.roleId = roleID;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public boolean isStatus() {
        return status;
    }

    public void setStatus(boolean status) {
        this.status = status;
    }

    public Timestamp getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(Timestamp createdDate) {
        this.createdDate = createdDate;
    }

    public String getAreaID() {
        return areaID;
    }

    public void setAreaID(String areaID) {
        this.areaID = areaID;
    }

    public String getAreaId() {
        return areaID;
    }

    public void setAreaId(String areaId) {
        this.areaID = areaId;
    }

    public String getAreaName() {
        return areaName;
    }

    public void setAreaName(String areaName) {
        this.areaName = areaName;
    }

    // ==========================================
    // RBAC role checker helper methods
    // ==========================================
    public boolean isSuperAdmin() {
        return "SAD".equalsIgnoreCase(this.roleId);
    }

    public boolean isAdmin() {
        return "ADM".equalsIgnoreCase(this.roleId);
    }

    public boolean isManager() {
        return "MGR".equalsIgnoreCase(this.roleId);
    }

    public boolean isSupervisor() {
        return "SUP".equalsIgnoreCase(this.roleId);
    }

    public boolean isStaff() {
        return "STF".equalsIgnoreCase(this.roleId);
    }

    public boolean isTechnician() {
        return "TEC".equalsIgnoreCase(this.roleId);
    }

    public boolean isAuditor() {
        return "AUD".equalsIgnoreCase(this.roleId);
    }

    public boolean isCitizen() {
        return "USR".equalsIgnoreCase(this.roleId);
    }

    /**
     * Display name of the user role in English
     */
    public String getRoleName() {
        if (roleId == null) return "Unknown";
        switch (roleId.toUpperCase()) {
            case "SAD": return "Super Admin";
            case "ADM": return "System Admin";
            case "MGR": return "Operations Manager";
            case "SUP": return "Area Supervisor";
            case "STF": return "Collection Staff";
            case "TEC": return "IoT Technician";
            case "AUD": return "System Auditor";
            case "USR": return "Citizen User";
            default: return roleId;
        }
    }
}
