package model;

import java.sql.Timestamp;

/**
 * Servlet displaying Security Audit Logs (tblAuditLogs)
 * Used by Super Admin and Auditor to track system mutations.
 */
public class AuditLog {
    private int logID;
    private String userID;
    private String action;
    private String tableName;
    private String recordID;
    private String oldValue;
    private String newValue;
    private Timestamp timestamp;
    private String ipAddress;

    // Display helper fields
    private String userFullName;
    private String userRole;

    public AuditLog() {
    }

    public AuditLog(int logID, String userID, String action, String tableName,
                    String recordID, String oldValue, String newValue,
                    Timestamp timestamp, String ipAddress) {
        this.logID = logID;
        this.userID = userID;
        this.action = action;
        this.tableName = tableName;
        this.recordID = recordID;
        this.oldValue = oldValue;
        this.newValue = newValue;
        this.timestamp = timestamp;
        this.ipAddress = ipAddress;
    }

    public int getLogID() {
        return logID;
    }

    public void setLogID(int logID) {
        this.logID = logID;
    }

    public String getUserID() {
        return userID;
    }

    public void setUserID(String userID) {
        this.userID = userID;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getTableName() {
        return tableName;
    }

    public void setTableName(String tableName) {
        this.tableName = tableName;
    }

    public String getRecordID() {
        return recordID;
    }

    public void setRecordID(String recordID) {
        this.recordID = recordID;
    }

    public String getOldValue() {
        return oldValue;
    }

    public void setOldValue(String oldValue) {
        this.oldValue = oldValue;
    }

    public String getNewValue() {
        return newValue;
    }

    public void setNewValue(String newValue) {
        this.newValue = newValue;
    }

    public Timestamp getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(Timestamp timestamp) {
        this.timestamp = timestamp;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }

    public String getUserFullName() {
        return userFullName;
    }

    public void setUserFullName(String userFullName) {
        this.userFullName = userFullName;
    }

    public String getUserRole() {
        return userRole;
    }

    public void setUserRole(String userRole) {
        this.userRole = userRole;
    }

    public String getFormattedTimestamp() {
        if (timestamp == null) return "";
        return new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(timestamp);
    }
}
