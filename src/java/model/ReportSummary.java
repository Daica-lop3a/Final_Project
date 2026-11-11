package model;

/**
 * Summary metrics for the /report analytics view.
 * Contains aggregated data transfer objects without business logic.
 */
public class ReportSummary {

    // ===== Waste Bin =====
    private int totalBins;
    private int activeBins;
    private int fullBins;
    private int brokenBins;      // status = 'Maintenance'

    // ===== Collection Request =====
    private int totalCollections;
    private int pendingCollections;
    private int inProgressCollections;
    private int completedCollections;
    private int cancelledCollections;

    // ===== Alert =====
    private int totalAlerts;
    private int unresolvedAlerts;

    // ===== Maintenance =====
    private int totalMaintenance;
    private int pendingMaintenance;
    private int inProgressMaintenance;
    private int completedMaintenance;

    public ReportSummary() {
    }

    public int getTotalBins() { return totalBins; }
    public void setTotalBins(int totalBins) { this.totalBins = totalBins; }

    public int getActiveBins() { return activeBins; }
    public void setActiveBins(int activeBins) { this.activeBins = activeBins; }

    public int getFullBins() { return fullBins; }
    public void setFullBins(int fullBins) { this.fullBins = fullBins; }

    public int getBrokenBins() { return brokenBins; }
    public void setBrokenBins(int brokenBins) { this.brokenBins = brokenBins; }

    public int getTotalCollections() { return totalCollections; }
    public void setTotalCollections(int totalCollections) { this.totalCollections = totalCollections; }

    public int getPendingCollections() { return pendingCollections; }
    public void setPendingCollections(int pendingCollections) { this.pendingCollections = pendingCollections; }

    public int getInProgressCollections() { return inProgressCollections; }
    public void setInProgressCollections(int inProgressCollections) { this.inProgressCollections = inProgressCollections; }

    public int getCompletedCollections() { return completedCollections; }
    public void setCompletedCollections(int completedCollections) { this.completedCollections = completedCollections; }

    public int getCancelledCollections() { return cancelledCollections; }
    public void setCancelledCollections(int cancelledCollections) { this.cancelledCollections = cancelledCollections; }

    public int getTotalAlerts() { return totalAlerts; }
    public void setTotalAlerts(int totalAlerts) { this.totalAlerts = totalAlerts; }

    public int getUnresolvedAlerts() { return unresolvedAlerts; }
    public void setUnresolvedAlerts(int unresolvedAlerts) { this.unresolvedAlerts = unresolvedAlerts; }

    public int getTotalMaintenance() { return totalMaintenance; }
    public void setTotalMaintenance(int totalMaintenance) { this.totalMaintenance = totalMaintenance; }

    public int getPendingMaintenance() { return pendingMaintenance; }
    public void setPendingMaintenance(int pendingMaintenance) { this.pendingMaintenance = pendingMaintenance; }

    public int getInProgressMaintenance() { return inProgressMaintenance; }
    public void setInProgressMaintenance(int inProgressMaintenance) { this.inProgressMaintenance = inProgressMaintenance; }

    public int getCompletedMaintenance() { return completedMaintenance; }
    public void setCompletedMaintenance(int completedMaintenance) { this.completedMaintenance = completedMaintenance; }
}
