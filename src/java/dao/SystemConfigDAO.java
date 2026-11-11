package dao;

import model.SystemConfig;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO managing system parameters and sensor rules (tblSystemConfig)
 * Restricted to Super Admin (SAD).
 */
public class SystemConfigDAO {

    public List<SystemConfig> getAll() {
        List<SystemConfig> list = new ArrayList<SystemConfig>();
        String sql = "SELECT configKey, configValue, description, category, updatedBy, lastUpdated "
                + "FROM dbo.tblSystemConfig ORDER BY category, configKey";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                SystemConfig cfg = new SystemConfig();
                cfg.setConfigKey(rs.getString("configKey"));
                cfg.setConfigValue(rs.getString("configValue"));
                cfg.setDescription(rs.getString("description"));
                cfg.setCategory(rs.getString("category"));
                cfg.setUpdatedBy(rs.getString("updatedBy"));
                cfg.setLastUpdated(rs.getTimestamp("lastUpdated"));
                list.add(cfg);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }

        return list;
    }

    public SystemConfig findByKey(String key) {
        if (key == null || key.trim().isEmpty()) {
            return null;
        }

        String sql = "SELECT configKey, configValue, description, category, updatedBy, lastUpdated "
                + "FROM dbo.tblSystemConfig WHERE configKey = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, key.trim());
            rs = ps.executeQuery();

            if (rs.next()) {
                SystemConfig cfg = new SystemConfig();
                cfg.setConfigKey(rs.getString("configKey"));
                cfg.setConfigValue(rs.getString("configValue"));
                cfg.setDescription(rs.getString("description"));
                cfg.setCategory(rs.getString("category"));
                cfg.setUpdatedBy(rs.getString("updatedBy"));
                cfg.setLastUpdated(rs.getTimestamp("lastUpdated"));
                return cfg;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }

        return null;
    }

    public String getValue(String key, String defaultValue) {
        SystemConfig cfg = findByKey(key);
        return (cfg != null && cfg.getConfigValue() != null) ? cfg.getConfigValue() : defaultValue;
    }

    public boolean updateConfig(String key, String value, String updatedBy) {
        if (key == null || key.trim().isEmpty() || value == null) {
            return false;
        }

        String sql = "UPDATE dbo.tblSystemConfig "
                + "SET configValue = ?, updatedBy = ?, lastUpdated = GETDATE() "
                + "WHERE configKey = ?";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, value.trim());
            ps.setString(2, updatedBy);
            ps.setString(3, key.trim());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(null, ps, conn);
        }

        return false;
    }
}
