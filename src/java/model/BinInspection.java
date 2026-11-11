package model;

import java.sql.Timestamp;

/**
 * Model representing an on-site physical waste bin inspection.
 * Compares physical waste fill level against live IoT sensor readings
 * to detect calibration drift, sensor lens obstructions, and hardware damage.
 */
public class BinInspection {

    private String inspectionID;
    private String binID;
    private String inspectorID;
    private Timestamp inspectionDate;
    private int actualFillPercent;
    private int sensorFillPercent;
    private int discrepancyPercent;
    private String physicalCondition; // Good, Damaged_Lid, Sensor_Obstructed, Vandalized, Overflowing_Surroundings
    private String actionTaken;        // None, Dispatched_Collection, Created_Maintenance, Cleaned_Sensor
    private String notes;
    private Timestamp createdDate;

    // Display fields
    private String binCode;
    private String location;
    private String areaID;
    private String areaName;
    private String inspectorName;

    public BinInspection() {
    }

    public BinInspection(String inspectionID, String binID, String inspectorID,
                         Timestamp inspectionDate, int actualFillPercent, int sensorFillPercent,
                         int discrepancyPercent, String physicalCondition, String actionTaken,
                         String notes) {
        this.inspectionID = inspectionID;
        this.binID = binID;
        this.inspectorID = inspectorID;
        this.inspectionDate = inspectionDate;
        this.actualFillPercent = actualFillPercent;
        this.sensorFillPercent = sensorFillPercent;
        this.discrepancyPercent = discrepancyPercent;
        this.physicalCondition = physicalCondition;
        this.actionTaken = actionTaken;
        this.notes = notes;
    }

    public String getInspectionID() {
        return inspectionID;
    }

    public void setInspectionID(String inspectionID) {
        this.inspectionID = inspectionID;
    }

    public String getBinID() {
        return binID;
    }

    public void setBinID(String binID) {
        this.binID = binID;
    }

    public String getInspectorID() {
        return inspectorID;
    }

    public void setInspectorID(String inspectorID) {
        this.inspectorID = inspectorID;
    }

    public Timestamp getInspectionDate() {
        return inspectionDate;
    }

    public void setInspectionDate(Timestamp inspectionDate) {
        this.inspectionDate = inspectionDate;
    }

    public int getActualFillPercent() {
        return actualFillPercent;
    }

    public void setActualFillPercent(int actualFillPercent) {
        this.actualFillPercent = actualFillPercent;
    }

    public int getSensorFillPercent() {
        return sensorFillPercent;
    }

    public void setSensorFillPercent(int sensorFillPercent) {
        this.sensorFillPercent = sensorFillPercent;
    }

    public int getDiscrepancyPercent() {
        return discrepancyPercent;
    }

    public void setDiscrepancyPercent(int discrepancyPercent) {
        this.discrepancyPercent = discrepancyPercent;
    }

    public String getPhysicalCondition() {
        return physicalCondition;
    }

    public void setPhysicalCondition(String physicalCondition) {
        this.physicalCondition = physicalCondition;
    }

    // Alias methods for compatibility
    public int getActualFill() {
        return actualFillPercent;
    }

    public void setActualFill(int actualFill) {
        this.actualFillPercent = actualFill;
    }

    public int getSensorFill() {
        return sensorFillPercent;
    }

    public void setSensorFill(int sensorFill) {
        this.sensorFillPercent = sensorFill;
    }

    public int getDiscrepancy() {
        return discrepancyPercent;
    }

    public void setDiscrepancy(int discrepancy) {
        this.discrepancyPercent = discrepancy;
    }

    public String getPhysicalStatus() {
        return physicalCondition;
    }

    public void setPhysicalStatus(String physicalStatus) {
        this.physicalCondition = physicalStatus;
    }

    public String getActionTaken() {
        return actionTaken;
    }

    public void setActionTaken(String actionTaken) {
        this.actionTaken = actionTaken;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public Timestamp getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(Timestamp createdDate) {
        this.createdDate = createdDate;
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

    public String getAreaID() {
        return areaID;
    }

    public void setAreaID(String areaID) {
        this.areaID = areaID;
    }

    public String getAreaName() {
        return areaName;
    }

    public void setAreaName(String areaName) {
        this.areaName = areaName;
    }

    public String getInspectorName() {
        return inspectorName;
    }

    public void setInspectorName(String inspectorName) {
        this.inspectorName = inspectorName;
    }

    public boolean isHighDiscrepancy() {
        return Math.abs(discrepancyPercent) >= 20;
    }
}
