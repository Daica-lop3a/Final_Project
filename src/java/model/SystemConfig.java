package model;

import java.sql.Timestamp;

/**
 * Model for system parameters and IoT sensor rules (tblSystemConfig)
 */
public class SystemConfig {
    private String configKey;
    private String configValue;
    private String description;
    private String category; // 'SYSTEM', 'IOT_SENSOR', 'SECURITY'
    private String updatedBy;
    private Timestamp lastUpdated;

    public SystemConfig() {
    }

    public SystemConfig(String configKey, String configValue, String description, String category) {
        this.configKey = configKey;
        this.configValue = configValue;
        this.description = description;
        this.category = category;
    }

    public String getConfigKey() {
        return configKey;
    }

    public void setConfigKey(String configKey) {
        this.configKey = configKey;
    }

    public String getConfigValue() {
        return configValue;
    }

    public void setConfigValue(String configValue) {
        this.configValue = configValue;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getUpdatedBy() {
        return updatedBy;
    }

    public void setUpdatedBy(String updatedBy) {
        this.updatedBy = updatedBy;
    }

    public Timestamp getLastUpdated() {
        return lastUpdated;
    }

    public void setLastUpdated(Timestamp lastUpdated) {
        this.lastUpdated = lastUpdated;
    }
}
