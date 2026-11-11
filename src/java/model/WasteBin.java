package model;

import java.sql.Timestamp;

/**
 * Model representing a Smart Waste Bin.
 * Includes GPS coordinates (latitude, longitude) for interactive mapping
 */
public class WasteBin {
    private String binID;
    private String binCode;
    private String location;
    private double latitude;
    private double longitude;
    private double capacity;
    private double currentFill;
    private String status; // Active, Maintenance, Full, Inactive
    private String areaID;
    private Timestamp lastEmptied;
    private Timestamp lastUpdated;

    // Trng h tr hin th
    private String areaName;

    public WasteBin() {
    }

    public WasteBin(String binID, String binCode, String location,
                    double latitude, double longitude, double capacity,
                    double currentFill, String status, String areaID) {
        this.binID = binID;
        this.binCode = binCode;
        this.location = location;
        this.latitude = latitude;
        this.longitude = longitude;
        this.capacity = capacity;
        this.currentFill = currentFill;
        this.status = status;
        this.areaID = areaID;
    }

    public WasteBin(String binID, String binCode, String location,
                    double capacity, double currentFill,
                    String status, String areaID) {
        this.binID = binID;
        this.binCode = binCode;
        this.location = location;
        this.capacity = capacity;
        this.currentFill = currentFill;
        this.status = status;
        this.areaID = areaID;
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

    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }

    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }

    public double getCapacity() {
        return capacity;
    }

    public void setCapacity(double capacity) {
        this.capacity = capacity;
    }

    public double getCurrentFill() {
        return currentFill;
    }

    public void setCurrentFill(double currentFill) {
        this.currentFill = currentFill;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
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

    public Timestamp getLastEmptied() {
        return lastEmptied;
    }

    public void setLastEmptied(Timestamp lastEmptied) {
        this.lastEmptied = lastEmptied;
    }

    public Timestamp getLastUpdated() {
        return lastUpdated;
    }

    public void setLastUpdated(Timestamp lastUpdated) {
        this.lastUpdated = lastUpdated;
    }

    public String getAreaName() {
        return areaName;
    }

    public void setAreaName(String areaName) {
        this.areaName = areaName;
    }

    // Helper method returning status badge colors for Map and UI
    public String getStatusColor() {
        if ("Maintenance".equalsIgnoreCase(status)) return "secondary"; // Gray
        if (currentFill >= 85) return "danger";    // Red
        if (currentFill >= 60) return "warning";   // Amber
        return "success";                          // xanh
    }
}
