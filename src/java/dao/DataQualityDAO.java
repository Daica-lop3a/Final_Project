package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.AuditLog;
import model.BinInspection;

/**
 * Controller for Data Quality Scanner & Anomaly Detection
 * Provides data integrity auditing for Auditor role (AUD).
 */
public class DataQualityDAO {

    // ==========================================
    // 1. Detect duplicate collection runs (<= 30 minutes)
    // ==========================================
    public List<Map<String, Object>> getDuplicateCollections() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT c1.requestID AS req1, c2.requestID AS req2, c1.binID, "
                + "b.binCode, a.areaName, c1.staffID, u.fullName AS staffName, "
                + "c1.completedDate AS date1, c2.completedDate AS date2, "
                + "DATEDIFF(MINUTE, c1.completedDate, c2.completedDate) AS diffMinutes "
                + "FROM dbo.tblCollectionRequests c1 "
                + "JOIN dbo.tblCollectionRequests c2 ON c1.binID = c2.binID AND c1.requestID < c2.requestID "
                + "LEFT JOIN dbo.tblWasteBins b ON c1.binID = b.binID "
                + "LEFT JOIN dbo.tblAreas a ON b.areaID = a.areaID "
                + "LEFT JOIN dbo.tblUsers u ON c1.staffID = u.userID "
                + "WHERE c1.status IN ('Completed', 'Verified') AND c2.status IN ('Completed', 'Verified') "
                + "  AND DATEDIFF(MINUTE, c1.completedDate, c2.completedDate) BETWEEN 0 AND 30 "
                + "ORDER BY c2.completedDate DESC";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("req1", rs.getString("req1"));
                map.put("req2", rs.getString("req2"));
                map.put("binID", rs.getString("binID"));
                map.put("binCode", rs.getString("binCode"));
                map.put("areaName", rs.getString("areaName"));
                map.put("staffID", rs.getString("staffID"));
                map.put("staffName", rs.getString("staffName"));
                map.put("date1", rs.getTimestamp("date1"));
                map.put("date2", rs.getTimestamp("date2"));
                map.put("diffMinutes", rs.getInt("diffMinutes"));
                list.add(map);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return list;
    }

    // ==========================================
    // 2. Detect incomplete collection dispatches
    // ==========================================
    public List<Map<String, Object>> getIncompleteCollections() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT c.requestID, c.binID, b.binCode, c.status, c.priority, "
                + "c.staffID, u.fullName AS staffName, c.failureReason, c.createdDate, c.completedDate, "
                + "CASE "
                + "  WHEN c.status IN ('Failed', 'Skipped') AND (c.failureReason IS NULL OR LTRIM(RTRIM(c.failureReason)) = '') THEN 'Missing Failure Reason' "
                + "  WHEN c.status IN ('Completed', 'Verified') AND c.completedDate IS NULL THEN 'Missing Completion Timestamp' "
                + "  WHEN c.status IN ('Completed', 'Verified') AND c.staffID IS NULL THEN 'Missing Assigned Staff' "
                + "  ELSE 'Inconsistent Data' "
                + "END AS issueDescription "
                + "FROM dbo.tblCollectionRequests c "
                + "LEFT JOIN dbo.tblWasteBins b ON c.binID = b.binID "
                + "LEFT JOIN dbo.tblUsers u ON c.staffID = u.userID "
                + "WHERE (c.status IN ('Failed', 'Skipped') AND (c.failureReason IS NULL OR LTRIM(RTRIM(c.failureReason)) = '')) "
                + "   OR (c.status IN ('Completed', 'Verified') AND (c.staffID IS NULL OR c.completedDate IS NULL)) "
                + "ORDER BY c.createdDate DESC";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("requestID", rs.getString("requestID"));
                map.put("binID", rs.getString("binID"));
                map.put("binCode", rs.getString("binCode"));
                map.put("status", rs.getString("status"));
                map.put("priority", rs.getString("priority"));
                map.put("staffID", rs.getString("staffID"));
                map.put("staffName", rs.getString("staffName"));
                map.put("failureReason", rs.getString("failureReason"));
                map.put("createdDate", rs.getTimestamp("createdDate"));
                map.put("completedDate", rs.getTimestamp("completedDate"));
                map.put("issueDescription", rs.getString("issueDescription"));
                list.add(map);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return list;
    }

    // ==========================================
    // 3. Reconcile sensor fill vs physical inspection (deviation >= 20%)
    // ==========================================
    public List<BinInspection> getHighSensorDeviations() {
        List<BinInspection> list = new ArrayList<>();
        String sql = "SELECT i.inspectionID, i.binID, b.binCode, a.areaName, "
                + "i.inspectorID, u.fullName AS inspectorName, "
                + "i.inspectionDate, i.actualFillPercent, i.sensorFillPercent, "
                + "i.discrepancyPercent, i.physicalCondition, i.actionTaken, i.notes, i.createdDate "
                + "FROM dbo.tblBinInspections i "
                + "LEFT JOIN dbo.tblWasteBins b ON i.binID = b.binID "
                + "LEFT JOIN dbo.tblAreas a ON b.areaID = a.areaID "
                + "LEFT JOIN dbo.tblUsers u ON i.inspectorID = u.userID "
                + "WHERE ABS(i.discrepancyPercent) >= 20 "
                + "ORDER BY i.inspectionDate DESC";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                BinInspection insp = new BinInspection();
                insp.setInspectionID(rs.getString("inspectionID"));
                insp.setBinID(rs.getString("binID"));
                insp.setBinCode(rs.getString("binCode"));
                insp.setAreaName(rs.getString("areaName"));
                insp.setInspectorID(rs.getString("inspectorID"));
                insp.setInspectorName(rs.getString("inspectorName"));
                insp.setInspectionDate(rs.getTimestamp("inspectionDate"));
                insp.setActualFill(rs.getInt("actualFillPercent"));
                insp.setSensorFill(rs.getInt("sensorFillPercent"));
                insp.setDiscrepancy(rs.getInt("discrepancyPercent"));
                insp.setPhysicalStatus(rs.getString("physicalCondition"));
                insp.setActionTaken(rs.getString("actionTaken"));
                insp.setNotes(rs.getString("notes"));
                insp.setCreatedDate(rs.getTimestamp("createdDate"));
                list.add(insp);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return list;
    }

    // ==========================================
    // 4. THNG K NHN VIN C NHIU SAI LCH / S C
    // ==========================================
    public List<Map<String, Object>> getStaffAnomalyRankings() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT u.userID, u.fullName, "
                + "COUNT(c.requestID) AS totalTasks, "
                + "SUM(CASE WHEN c.status IN ('Failed', 'Skipped') THEN 1 ELSE 0 END) AS failedTasks, "
                + "SUM(CASE WHEN c.status IN ('Completed', 'Verified') THEN 1 ELSE 0 END) AS completedTasks, "
                + "SUM(CASE WHEN c.notes LIKE '%Duplicate%' THEN 1 ELSE 0 END) AS duplicateWarnings "
                + "FROM dbo.tblUsers u "
                + "JOIN dbo.tblCollectionRequests c ON u.userID = c.staffID "
                + "GROUP BY u.userID, u.fullName "
                + "ORDER BY failedTasks DESC, duplicateWarnings DESC";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("userID", rs.getString("userID"));
                map.put("fullName", rs.getString("fullName"));
                map.put("totalTasks", rs.getInt("totalTasks"));
                map.put("failedTasks", rs.getInt("failedTasks"));
                map.put("completedTasks", rs.getInt("completedTasks"));
                map.put("duplicateWarnings", rs.getInt("duplicateWarnings"));
                list.add(map);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return list;
    }

    // ==========================================
    // 5. Device defect and repair frequency metrics
    // ==========================================
    public List<Map<String, Object>> getDeviceAnomalyRankings() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT d.deviceID, d.binID, b.binCode, a.areaName, d.deviceType, "
                + "d.status, d.batteryLevel, d.firmwareVersion, "
                + "COUNT(m.maintenanceID) AS repairCount "
                + "FROM dbo.tblDevices d "
                + "LEFT JOIN dbo.tblWasteBins b ON d.binID = b.binID "
                + "LEFT JOIN dbo.tblAreas a ON b.areaID = a.areaID "
                + "LEFT JOIN dbo.tblMaintenance m ON d.binID = m.binID "
                + "GROUP BY d.deviceID, d.binID, b.binCode, a.areaName, d.deviceType, d.status, d.batteryLevel, d.firmwareVersion "
                + "ORDER BY repairCount DESC, d.batteryLevel ASC";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("deviceID", rs.getString("deviceID"));
                map.put("binID", rs.getString("binID"));
                map.put("binCode", rs.getString("binCode"));
                map.put("areaName", rs.getString("areaName"));
                map.put("deviceType", rs.getString("deviceType"));
                map.put("status", rs.getString("status"));
                map.put("batteryLevel", rs.getInt("batteryLevel"));
                map.put("firmwareVersion", rs.getString("firmwareVersion"));
                map.put("repairCount", rs.getInt("repairCount"));
                list.add(map);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return list;
    }

    // ==========================================
    // 6. THEO DI LCH S THAY I CU HNH NGNG CNH BO
    // ==========================================
    public List<AuditLog> getConfigAuditLogs() {
        List<AuditLog> list = new ArrayList<>();
        String sql = "SELECT l.logID, l.userID, l.action, l.tableName, l.recordID, "
                + "l.oldValue, l.newValue, l.timestamp, l.ipAddress, "
                + "u.fullName AS userFullName, u.roleID AS userRole "
                + "FROM dbo.tblAuditLogs l "
                + "LEFT JOIN dbo.tblUsers u ON l.userID = u.userID "
                + "WHERE l.tableName = 'tblSystemConfig' "
                + "   OR l.action LIKE '%CONFIG%' "
                + "   OR l.action LIKE '%THRESHOLD%' "
                + "   OR l.action LIKE '%PERMISSION%' "
                + "ORDER BY l.timestamp DESC";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
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
                list.add(l);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return list;
    }

    // ==========================================
    // 7. M TNG S LI CHT LNG D LIU ANG C
    // ==========================================
    public int countTotalDataQualityAnomalies() {
        int count = 0;
        count += getDuplicateCollections().size();
        count += getIncompleteCollections().size();
        count += getHighSensorDeviations().size();
        return count;
    }
}
