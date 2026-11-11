package dao;

import model.CatalogItem;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO managing system classification catalogs (tblCatalogs)
 * Module: Catalog Management (CRUD)
 */
public class CatalogDAO {

    private CatalogItem mapResultSet(ResultSet rs) throws SQLException {
        CatalogItem item = new CatalogItem();
        item.setCatalogId(rs.getInt("catalogID"));
        item.setCatalogType(rs.getString("catalogType"));
        item.setItemCode(rs.getString("itemCode"));
        item.setItemName(rs.getString("itemName"));
        item.setDescription(rs.getString("description"));
        item.setDisplayOrder(rs.getInt("displayOrder"));
        item.setActive(rs.getBoolean("isActive"));
        return item;
    }

    public List<CatalogItem> getAll() {
        List<CatalogItem> list = new ArrayList<CatalogItem>();
        String sql = "SELECT catalogID, catalogType, itemCode, itemName, description, displayOrder, isActive "
                + "FROM dbo.tblCatalogs ORDER BY catalogType, displayOrder, itemCode";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return list;
    }

    public List<CatalogItem> getByType(String type) {
        List<CatalogItem> list = new ArrayList<CatalogItem>();
        String sql = "SELECT catalogID, catalogType, itemCode, itemName, description, displayOrder, isActive "
                + "FROM dbo.tblCatalogs WHERE catalogType = ? ORDER BY displayOrder, itemCode";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, type);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return list;
    }

    public CatalogItem findById(int id) {
        String sql = "SELECT catalogID, catalogType, itemCode, itemName, description, displayOrder, isActive "
                + "FROM dbo.tblCatalogs WHERE catalogID = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return null;
    }

    public boolean insert(CatalogItem item) {
        String sql = "INSERT INTO dbo.tblCatalogs (catalogType, itemCode, itemName, description, displayOrder, isActive) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, item.getCatalogType().trim());
            ps.setString(2, item.getItemCode().trim());
            ps.setString(3, item.getItemName().trim());
            ps.setString(4, item.getDescription() != null ? item.getDescription().trim() : "");
            ps.setInt(5, item.getDisplayOrder());
            ps.setBoolean(6, item.isActive());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBContext.close(null, ps, conn);
        }
        return false;
    }

    public boolean update(CatalogItem item) {
        String sql = "UPDATE dbo.tblCatalogs SET catalogType = ?, itemCode = ?, itemName = ?, description = ?, displayOrder = ?, isActive = ? "
                + "WHERE catalogID = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, item.getCatalogType().trim());
            ps.setString(2, item.getItemCode().trim());
            ps.setString(3, item.getItemName().trim());
            ps.setString(4, item.getDescription() != null ? item.getDescription().trim() : "");
            ps.setInt(5, item.getDisplayOrder());
            ps.setBoolean(6, item.isActive());
            ps.setInt(7, item.getCatalogId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBContext.close(null, ps, conn);
        }
        return false;
    }

    public boolean delete(int id) {
        String sql = "DELETE FROM dbo.tblCatalogs WHERE catalogID = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBContext.close(null, ps, conn);
        }
        return false;
    }
}
