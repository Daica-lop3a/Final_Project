package model;

import java.sql.Timestamp;

/**
 * Model for IoT Sensors and Smart Devices (tblDevices)
 * Supports Device Management module and linkage with Waste Bins
 */
public class Device {

    private String deviceId;
    private String deviceName;
    private String deviceType;
    private String binId;
    private String binLocation;
    private String binCode;
    private String status; // Active, Inactive, Maintenance
    private int batteryLevel; // 0 - 100
    private Timestamp lastPing;
    private Timestamp installedDate;
    private String firmwareVersion = "v1.2.0";
    private int repairCount = 0;

    public Device() {
    }

    public Device(String deviceId, String deviceName, String deviceType, String binId, String status, int batteryLevel) {
        this.deviceId = deviceId;
        this.deviceName = deviceName;
        this.deviceType = deviceType;
        this.binId = binId;
        this.status = status;
        this.batteryLevel = batteryLevel;
        this.firmwareVersion = "v1.2.0";
    }

    public String getDeviceId() {
        return deviceId;
    }

    public void setDeviceId(String deviceId) {
        this.deviceId = deviceId;
    }

    public String getDeviceName() {
        return deviceName;
    }

    public void setDeviceName(String deviceName) {
        this.deviceName = deviceName;
    }

    public String getDeviceType() {
        return deviceType;
    }

    public void setDeviceType(String deviceType) {
        this.deviceType = deviceType;
    }

    public String getBinId() {
        return binId;
    }

    public void setBinId(String binId) {
        this.binId = binId;
    }

    public String getBinLocation() {
        return binLocation;
    }

    public void setBinLocation(String binLocation) {
        this.binLocation = binLocation;
    }

    public String getBinCode() {
        return binCode;
    }

    public void setBinCode(String binCode) {
        this.binCode = binCode;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getBatteryLevel() {
        return batteryLevel;
    }

    public void setBatteryLevel(int batteryLevel) {
        this.batteryLevel = batteryLevel;
    }

    public Timestamp getLastPing() {
        return lastPing;
    }

    public void setLastPing(Timestamp lastPing) {
        this.lastPing = lastPing;
    }

    public Timestamp getInstalledDate() {
        return installedDate;
    }

    public void setInstalledDate(Timestamp installedDate) {
        this.installedDate = installedDate;
    }

    public String getFirmwareVersion() {
        return firmwareVersion != null ? firmwareVersion : "v1.2.0";
    }

    public void setFirmwareVersion(String firmwareVersion) {
        this.firmwareVersion = firmwareVersion;
    }

    public int getRepairCount() {
        return repairCount;
    }

    public void setRepairCount(int repairCount) {
        this.repairCount = repairCount;
    }
}
