package model;

import java.sql.Timestamp;

/**
 * Controller for Citizen Reports and Feedback workflows:
 * Dnh cho User gi phn nh v Supervisor xc minh / iu phi.
 */
public class CitizenReport {
    private String reportID;
    private String citizenID;
    private String binID;
    private String areaID;
    private String reportType; // FULL_BIN, DAMAGED_BIN, DIRTY_AREA, OTHER
    private String title;
    private String description;
    private String imageURL;
    private String status;     // Pending, Verified, Rejected, Resolved
    private Timestamp createdDate;
    private String verifiedBy; // userID of Area Supervisor
    private Timestamp verifiedDate;
    private String feedbackNote;

    // Display helper fields (Join query)
    private String citizenName;
    private String binCode;
    private String areaName;
    private String verifierName;

    public CitizenReport() {
    }

    public CitizenReport(String reportID, String citizenID, String binID, String areaID,
                         String reportType, String title, String description, String imageURL,
                         String status, Timestamp createdDate, String verifiedBy,
                         Timestamp verifiedDate, String feedbackNote) {
        this.reportID = reportID;
        this.citizenID = citizenID;
        this.binID = binID;
        this.areaID = areaID;
        this.reportType = reportType;
        this.title = title;
        this.description = description;
        this.imageURL = imageURL;
        this.status = status;
        this.createdDate = createdDate;
        this.verifiedBy = verifiedBy;
        this.verifiedDate = verifiedDate;
        this.feedbackNote = feedbackNote;
    }

    public String getReportID() {
        return reportID;
    }

    public void setReportID(String reportID) {
        this.reportID = reportID;
    }

    public String getReportId() {
        return reportID;
    }

    public void setReportId(String reportId) {
        this.reportID = reportId;
    }

    public String getCitizenID() {
        return citizenID;
    }

    public void setCitizenID(String citizenID) {
        this.citizenID = citizenID;
    }

    public String getCitizenId() {
        return citizenID;
    }

    public void setCitizenId(String citizenId) {
        this.citizenID = citizenId;
    }

    public String getBinID() {
        return binID;
    }

    public void setBinID(String binID) {
        this.binID = binID;
    }

    public String getBinId() {
        return binID;
    }

    public void setBinId(String binId) {
        this.binID = binId;
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

    public String getReportType() {
        return reportType;
    }

    public void setReportType(String reportType) {
        this.reportType = reportType;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getImageURL() {
        return imageURL;
    }

    public void setImageURL(String imageURL) {
        this.imageURL = imageURL;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(Timestamp createdDate) {
        this.createdDate = createdDate;
    }

    public String getVerifiedBy() {
        return verifiedBy;
    }

    public void setVerifiedBy(String verifiedBy) {
        this.verifiedBy = verifiedBy;
    }

    public Timestamp getVerifiedDate() {
        return verifiedDate;
    }

    public void setVerifiedDate(Timestamp verifiedDate) {
        this.verifiedDate = verifiedDate;
    }

    public String getFeedbackNote() {
        return feedbackNote;
    }

    public void setFeedbackNote(String feedbackNote) {
        this.feedbackNote = feedbackNote;
    }

    public String getCitizenName() {
        return citizenName;
    }

    public void setCitizenName(String citizenName) {
        this.citizenName = citizenName;
    }

    public String getBinCode() {
        return binCode;
    }

    public void setBinCode(String binCode) {
        this.binCode = binCode;
    }

    public String getAreaName() {
        return areaName;
    }

    public void setAreaName(String areaName) {
        this.areaName = areaName;
    }

    public String getVerifierName() {
        return verifierName;
    }

    public void setVerifierName(String verifierName) {
        this.verifierName = verifierName;
    }

    // Advanced fields for Role 8 (Citizen / Public User)
    private Double latitude;
    private Double longitude;
    private Integer rating;
    private String ratingComment;
    private Timestamp ratedDate;

    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public Double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }

    public Integer getRating() {
        return rating;
    }

    public void setRating(Integer rating) {
        this.rating = rating;
    }

    public String getRatingComment() {
        return ratingComment;
    }

    public void setRatingComment(String ratingComment) {
        this.ratingComment = ratingComment;
    }

    public Timestamp getRatedDate() {
        return ratedDate;
    }

    public void setRatedDate(Timestamp ratedDate) {
        this.ratedDate = ratedDate;
    }

    public boolean isEditable() {
        return "Submitted".equalsIgnoreCase(status) || "Pending".equalsIgnoreCase(status);
    }

    public boolean isCancellable() {
        return "Submitted".equalsIgnoreCase(status) || "Pending".equalsIgnoreCase(status);
    }

    public boolean isRateable() {
        return "Resolved".equalsIgnoreCase(status) && (rating == null || rating == 0);
    }

    public String getStatusBadgeClass() {
        if (status == null) return "badge-secondary";
        switch (status) {
            case "Submitted":
            case "Pending":
                return "badge-warning";
            case "Under Review":
                return "badge-info";
            case "Assigned":
                return "badge-primary";
            case "Resolved":
                return "badge-success";
            case "Rejected":
                return "badge-danger";
            case "Cancelled":
                return "badge-secondary";
            default:
                return "badge-secondary";
        }
    }

    public String getFormattedCreatedDate() {
        if (createdDate == null) return "";
        return new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(createdDate);
    }
}
