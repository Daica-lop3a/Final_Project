package model;

/**
 * Model for system catalogs: bin status, bin types, device types (tblCatalogs)
 * Used for Catalog Management (CRUD)
 */
public class CatalogItem {

    private int catalogId;
    private String catalogType; // BIN_STATUS, BIN_TYPE, DEVICE_TYPE
    private String itemCode;
    private String itemName;
    private String description;
    private int displayOrder;
    private boolean active;

    public CatalogItem() {
    }

    public CatalogItem(int catalogId, String catalogType, String itemCode, String itemName, String description, int displayOrder, boolean active) {
        this.catalogId = catalogId;
        this.catalogType = catalogType;
        this.itemCode = itemCode;
        this.itemName = itemName;
        this.description = description;
        this.displayOrder = displayOrder;
        this.active = active;
    }

    public int getCatalogId() {
        return catalogId;
    }

    public void setCatalogId(int catalogId) {
        this.catalogId = catalogId;
    }

    public String getCatalogType() {
        return catalogType;
    }

    public void setCatalogType(String catalogType) {
        this.catalogType = catalogType;
    }

    public String getItemCode() {
        return itemCode;
    }

    public void setItemCode(String itemCode) {
        this.itemCode = itemCode;
    }

    public String getItemName() {
        return itemName;
    }

    public void setItemName(String itemName) {
        this.itemName = itemName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getDisplayOrder() {
        return displayOrder;
    }

    public void setDisplayOrder(int displayOrder) {
        this.displayOrder = displayOrder;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }
}
