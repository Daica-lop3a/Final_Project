package model;

import java.sql.Timestamp;

public class Maintenance {
    private String maintenanceID;
    private String binID;
    private String technicianID;
    private String maintenanceType; // Repair, Inspection, Replacement, Sensor_Check
    private String status;          // Pending, In_Progress, Completed, Cancelled
    private Timestamp scheduledDate;
    private Timestamp completedDate;
    private String description;
    private String resolutionNotes;
    private String rootCause;
    private String repairMethod;
    private String replacedParts;

    // Cc trng h tr hin th
    private String binCode;
    private String location;
    private String technicianName;

    public Maintenance() {
    }

    public Maintenance(String maintenanceID, String binID, String technicianID,
                       String maintenanceType, String status, Timestamp scheduledDate,
                       Timestamp completedDate, String description, String resolutionNotes) {
        this.maintenanceID = maintenanceID;
        this.binID = binID;
        this.technicianID = technicianID;
        this.maintenanceType = maintenanceType;
        this.status = status;
        this.scheduledDate = scheduledDate;
        this.completedDate = completedDate;
        this.description = description;
        this.resolutionNotes = resolutionNotes;
    }

    public String getMaintenanceID() {
        return maintenanceID;
    }

    public void setMaintenanceID(String maintenanceID) {
        this.maintenanceID = maintenanceID;
    }

    public String getBinID() {
        return binID;
    }

    public void setBinID(String binID) {
        this.binID = binID;
    }

    public String getTechnicianID() {
        return technicianID;
    }

    public void setTechnicianID(String technicianID) {
        this.technicianID = technicianID;
    }

    public String getMaintenanceType() {
        return maintenanceType;
    }

    public void setMaintenanceType(String maintenanceType) {
        this.maintenanceType = maintenanceType;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getScheduledDate() {
        return scheduledDate;
    }

    public void setScheduledDate(Timestamp scheduledDate) {
        this.scheduledDate = scheduledDate;
    }

    public Timestamp getCompletedDate() {
        return completedDate;
    }

    public void setCompletedDate(Timestamp completedDate) {
        this.completedDate = completedDate;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getResolutionNotes() {
        return resolutionNotes;
    }

    public void setResolutionNotes(String resolutionNotes) {
        this.resolutionNotes = resolutionNotes;
    }

    public String getBinCode() {
        return binCode;
    }

    public void setBinCode(String binCode) {
        this.binCode = binCode;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getTechnicianName() {
        return technicianName;
    }

    public void setTechnicianName(String technicianName) {
        this.technicianName = technicianName;
    }

    public String getRootCause() {
        return rootCause;
    }

    public void setRootCause(String rootCause) {
        this.rootCause = rootCause;
    }

    public String getRepairMethod() {
        return repairMethod;
    }

    public void setRepairMethod(String repairMethod) {
        this.repairMethod = repairMethod;
    }

    public String getReplacedParts() {
        return replacedParts;
    }

    public void setReplacedParts(String replacedParts) {
        this.replacedParts = replacedParts;
    }
}
