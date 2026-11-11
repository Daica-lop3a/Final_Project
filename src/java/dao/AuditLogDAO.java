package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import model.AuditLog;

/**
 * DAO handling system audit logs.
 * Accessible by Super Admin and Auditor.
 */
public class AuditLogDAO {

    private static final String SELECT_BASE
            = "SELECT l.logID, l.userID, l.action, l.tableName, l.recordID, "
            + "l.oldValue, l.newValue, l.timestamp, l.ipAddress, "
            + "u.fullName AS userFullName, u.roleID AS userRole "
            + "FROM dbo.tblAuditLogs l "
            + "LEFT JOIN dbo.tblUsers u ON l.userID = u.userID ";

    // ==========================================
    // 1. GHI NHN HNH NG VO AUDIT LOG
    // ==========================================
    public static void log(String userID, String action, String tableName,
                           String recordID, String oldValue, String newValue, String ipAddress) {
        String sql = "INSERT INTO dbo.tblAuditLogs "
                + "(userID, action, tableName, recordID, oldValue, newValue, timestamp, ipAddress) "
                + "VALUES (?, ?, ?, ?, ?, ?, GETDATE(), ?)";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, userID);
            ps.setString(2, action);
            ps.setString(3, tableName);
            ps.setString(4, recordID);
            ps.setString(5, oldValue);
            ps.setString(6, newValue);
            ps.setString(7, ipAddress);

            ps.executeUpdate();
        } catch (SQLException e) {
            // Non-blocking: failures in audit logging do not interrupt main workflow
            e.printStackTrace();
        } finally {
            DBContext.close(null, ps, conn);
        }
    }

    // ==========================================
    // 2. LY DANH SCH NHT K C PHN TRANG & LC
    // ==========================================
    public List<AuditLog> getLogs(int page, int pageSize, String actionFilter, String userFilter) {
        return getLogs(page, pageSize, actionFilter, userFilter, false);
    }

    public List<AuditLog> getLogs(int page, int pageSize, String actionFilter, String userFilter, boolean excludeSuperAdmin) {
        List<AuditLog> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(SELECT_BASE);
        sql.append("WHERE 1 = 1 ");

        if (excludeSuperAdmin) {
            sql.append("AND (u.roleID IS NULL OR u.roleID <> 'SAD') ");
        }

        if (actionFilter != null && !actionFilter.trim().isEmpty()) {
            sql.append("AND l.action = ? ");
        }
        if (userFilter != null && !userFilter.trim().isEmpty()) {
            sql.append("AND (l.userID LIKE ? OR u.fullName LIKE ?) ");
        }

        sql.append("ORDER BY l.timestamp DESC ");
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql.toString());
            int idx = 1;
            if (actionFilter != null && !actionFilter.trim().isEmpty()) {
                ps.setString(idx++, actionFilter);
            }
            if (userFilter != null && !userFilter.trim().isEmpty()) {
                ps.setString(idx++, "%" + userFilter + "%");
                ps.setString(idx++, "%" + userFilter + "%");
            }
            ps.setInt(idx++, (page - 1) * pageSize);
            ps.setInt(idx, pageSize);

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


    // ==========================================
    // 2B. GET LOGS BY DATE RANGE
    // ==========================================
    public List<AuditLog> getLogsByDateRange(Timestamp from, Timestamp to, String actionFilter, String userFilter) {
        List<AuditLog> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(SELECT_BASE);
        sql.append("WHERE 1 = 1 ");

        if (from != null) {
            sql.append("AND l.timestamp >= ? ");
        }
        if (to != null) {
            sql.append("AND l.timestamp <= ? ");
        }
        if (actionFilter != null && !actionFilter.trim().isEmpty()) {
            sql.append("AND l.action = ? ");
        }
        if (userFilter != null && !userFilter.trim().isEmpty()) {
            sql.append("AND (l.userID LIKE ? OR u.fullName LIKE ?) ");
        }

        sql.append("ORDER BY l.timestamp DESC");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql.toString());
            int idx = 1;
            if (from != null) {
                ps.setTimestamp(idx++, from);
            }
            if (to != null) {
                ps.setTimestamp(idx++, to);
            }
            if (actionFilter != null && !actionFilter.trim().isEmpty()) {
                ps.setString(idx++, actionFilter);
            }
            if (userFilter != null && !userFilter.trim().isEmpty()) {
                ps.setString(idx++, "%" + userFilter + "%");
                ps.setString(idx++, "%" + userFilter + "%");
            }

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

    // ==========================================
    // 3. Count total audit log records
    // ==========================================
    public int countLogs(String actionFilter, String userFilter) {
        return countLogs(actionFilter, userFilter, false);
    }

    public int countLogs(String actionFilter, String userFilter, boolean excludeSuperAdmin) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM dbo.tblAuditLogs l "
                + "LEFT JOIN dbo.tblUsers u ON l.userID = u.userID WHERE 1 = 1 "
        );

        if (excludeSuperAdmin) {
            sql.append("AND (u.roleID IS NULL OR u.roleID <> 'SAD') ");
        }

        if (actionFilter != null && !actionFilter.trim().isEmpty()) {
            sql.append("AND l.action = ? ");
        }
        if (userFilter != null && !userFilter.trim().isEmpty()) {
            sql.append("AND (l.userID LIKE ? OR u.fullName LIKE ?) ");
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql.toString());
            int idx = 1;
            if (actionFilter != null && !actionFilter.trim().isEmpty()) {
                ps.setString(idx++, actionFilter);
            }
            if (userFilter != null && !userFilter.trim().isEmpty()) {
                ps.setString(idx++, "%" + userFilter + "%");
                ps.setString(idx++, "%" + userFilter + "%");
            }
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return 0;
    }

    // ==========================================
    // 4. Query change history for a specific record (History Tracking)
    // ==========================================
    public List<AuditLog> getLogsByRecord(String tableName, String recordID) {
        List<AuditLog> list = new ArrayList<>();
        String sql = SELECT_BASE + "WHERE l.tableName = ? AND l.recordID = ? ORDER BY l.timestamp DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, tableName);
            ps.setString(2, recordID);
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

    // Helper map ResultSet sang Object
    private AuditLog mapResultSet(ResultSet rs) throws SQLException {
        AuditLog l = new AuditLog();
        l.setLogID(rs.getInt("logID"));
        l.setUserID(rs.getString("userID"));
        l.setAction(rs.getString("action"));
        l.setTableName(rs.getString("tableName"));
        l.setRecordID(rs.getString("recordID"));
        l.setOldValue(rs.getString("oldValue"));
        l.setNewValue(rs.getString("newValue"));
        l.setTimestamp(rs.getTimestamp("timestamp"));
        l.setIpAddress(rs.getString("ipAddress"));

        l.setUserFullName(rs.getString("userFullName"));
        l.setUserRole(rs.getString("userRole"));
        return l;
    }
}

