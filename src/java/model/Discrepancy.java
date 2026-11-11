package model;

import java.sql.Timestamp;

/**
 * DAO for Audit Data Discrepancies (tblDiscrepancies)
 * Specifically for Auditor (AUD) and Super Admin (SAD) roles
 */
public class Discrepancy {

    private String discrepancyID;
    private String title;
    private String discrepancyType; // Collection_Mismatch, Duplicate_Collection, Incomplete_Data, Sensor_Deviation, Stuck_Sensor, Config_Change, Other
    private String targetEntity;    // Collection, Bin, Device, User, Inspection, Config
    private String targetID;
    private String severity;        // Low, Medium, High, Critical
    private String status;          // Open, Investigating, Resolved, Closed
    private String detectedBy;
    private Timestamp detectedDate;
    private String description;
    private String investigationNotes;
    private String conclusionNotes;
    private String closedBy;
    private Timestamp closedDate;

    // Display helper fields from joins
    private String detectedByName;
    private String closedByName;

    public Discrepancy() {
    }

    public Discrepancy(String discrepancyID, String title, String discrepancyType,
                       String targetEntity, String targetID, String severity,
                       String status, String detectedBy, Timestamp detectedDate,
                       String description) {
        this.discrepancyID = discrepancyID;
        this.title = title;
        this.discrepancyType = discrepancyType;
        this.targetEntity = targetEntity;
        this.targetID = targetID;
        this.severity = severity;
        this.status = status;
        this.detectedBy = detectedBy;
        this.detectedDate = detectedDate;
        this.description = description;
    }

    public String getDiscrepancyID() {
        return discrepancyID;
    }

    public void setDiscrepancyID(String discrepancyID) {
        this.discrepancyID = discrepancyID;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDiscrepancyType() {
        return discrepancyType;
    }

    public void setDiscrepancyType(String discrepancyType) {
        this.discrepancyType = discrepancyType;
    }

    public String getTargetEntity() {
        return targetEntity;
    }

    public void setTargetEntity(String targetEntity) {
        this.targetEntity = targetEntity;
    }

    public String getTargetID() {
        return targetID;
    }

    public void setTargetID(String targetID) {
        this.targetID = targetID;
    }

    public String getSeverity() {
        return severity;
    }

    public void setSeverity(String severity) {
        this.severity = severity;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getDetectedBy() {
        return detectedBy;
    }

    public void setDetectedBy(String detectedBy) {
        this.detectedBy = detectedBy;
    }

    public Timestamp getDetectedDate() {
        return detectedDate;
    }

    public void setDetectedDate(Timestamp detectedDate) {
        this.detectedDate = detectedDate;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getInvestigationNotes() {
        return investigationNotes;
    }

    public void setInvestigationNotes(String investigationNotes) {
        this.investigationNotes = investigationNotes;
    }

    public String getConclusionNotes() {
        return conclusionNotes;
    }

    public void setConclusionNotes(String conclusionNotes) {
        this.conclusionNotes = conclusionNotes;
    }

    public String getClosedBy() {
        return closedBy;
    }

    public void setClosedBy(String closedBy) {
        this.closedBy = closedBy;
    }

    public Timestamp getClosedDate() {
        return closedDate;
    }

    public void setClosedDate(Timestamp closedDate) {
        this.closedDate = closedDate;
    }

    public String getDetectedByName() {
        return detectedByName;
    }

    public void setDetectedByName(String detectedByName) {
        this.detectedByName = detectedByName;
    }

    public String getClosedByName() {
        return closedByName;
    }

    public void setClosedByName(String closedByName) {
        this.closedByName = closedByName;
    }

    // Helper status badges
    public boolean isOpen() {
        return "Open".equalsIgnoreCase(status);
    }

    public boolean isInvestigating() {
        return "Investigating".equalsIgnoreCase(status);
    }

    public boolean isResolved() {
        return "Resolved".equalsIgnoreCase(status);
    }

    public boolean isClosed() {
        return "Closed".equalsIgnoreCase(status);
    }

    public String getSeverityBadgeClass() {
        if ("Critical".equalsIgnoreCase(severity)) return "badge-danger";
        if ("High".equalsIgnoreCase(severity)) return "badge-warning";
        if ("Medium".equalsIgnoreCase(severity)) return "badge-info";
        return "badge-secondary";
    }

    public String getStatusBadgeClass() {
        if ("Closed".equalsIgnoreCase(status)) return "badge-success";
        if ("Resolved".equalsIgnoreCase(status)) return "badge-primary";
        if ("Investigating".equalsIgnoreCase(status)) return "badge-warning";
        return "badge-danger";
    }
}
