package model;

import java.sql.Timestamp;

public class CollectionRequest {

    private String requestID;
    private String binID;
    private String supervisorID;
    private String staffID;
    private String status;      // Pending, In_Progress, Completed, Cancelled
    private String priority;    // Normal, High, Emergency
    private Timestamp createdDate;
    private Timestamp startedDate;
    private Timestamp completedDate;
    private String notes;
    private String photoBefore;
    private String photoAfter;
    private String failureReason;

    // Cc trng h tr hin th danh sch
    private String binCode;
    private String location;
    private String areaName;
    private String staffName;
    private String supervisorName;

    public CollectionRequest() {
    }

    public CollectionRequest(String requestID, String binID, String supervisorID,
                             String staffID, String status, String priority,
                             Timestamp createdDate, Timestamp completedDate, String notes) {
        this.requestID = requestID;
        this.binID = binID;
        this.supervisorID = supervisorID;
        this.staffID = staffID;
        this.status = status;
        this.priority = priority;
        this.createdDate = createdDate;
        this.completedDate = completedDate;
        this.notes = notes;
    }

    public String getRequestID() {
        return requestID;
    }

    public void setRequestID(String requestID) {
        this.requestID = requestID;
    }

    public String getBinID() {
        return binID;
    }

    public void setBinID(String binID) {
        this.binID = binID;
    }

    public String getSupervisorID() {
        return supervisorID;
    }

    public void setSupervisorID(String supervisorID) {
        this.supervisorID = supervisorID;
    }

    public String getStaffID() {
        return staffID;
    }

    public void setStaffID(String staffID) {
        this.staffID = staffID;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getPriority() {
        return priority;
    }

    public void setPriority(String priority) {
        this.priority = priority;
    }

    public Timestamp getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(Timestamp createdDate) {
        this.createdDate = createdDate;
    }

    public Timestamp getCompletedDate() {
        return completedDate;
    }

    public void setCompletedDate(Timestamp completedDate) {
        this.completedDate = completedDate;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
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

    public String getAreaName() {
        return areaName;
    }

    public void setAreaName(String areaName) {
        this.areaName = areaName;
    }

    public String getStaffName() {
        return staffName;
    }

    public void setStaffName(String staffName) {
        this.staffName = staffName;
    }

    public String getSupervisorName() {
        return supervisorName;
    }

    public void setSupervisorName(String supervisorName) {
        this.supervisorName = supervisorName;
    }

    /**
     * Checks if this collection request is overdue (pending or in-progress for at least 4 hours).
     */
    public boolean isOverdue() {
        if ("Completed".equalsIgnoreCase(status) 
                || "Verified".equalsIgnoreCase(status) 
                || "Cancelled".equalsIgnoreCase(status)) {
            return false;
        }
        if (createdDate == null) return false;
        long elapsedHours = (System.currentTimeMillis() - createdDate.getTime()) / (1000 * 60 * 60);
        return elapsedHours >= 4;
    }

    public long getHoursElapsed() {
        if (createdDate == null) return 0;
        return (System.currentTimeMillis() - createdDate.getTime()) / (1000 * 60 * 60);
    }

    public Timestamp getStartedDate() {
        return startedDate;
    }

    public void setStartedDate(Timestamp startedDate) {
        this.startedDate = startedDate;
    }

    public String getPhotoBefore() {
        return photoBefore;
    }

    public void setPhotoBefore(String photoBefore) {
        this.photoBefore = photoBefore;
    }

    public String getPhotoAfter() {
        return photoAfter;
    }

    public void setPhotoAfter(String photoAfter) {
        this.photoAfter = photoAfter;
    }

    public String getFailureReason() {
        return failureReason;
    }

    public void setFailureReason(String failureReason) {
        this.failureReason = failureReason;
    }
}
