package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.CollectionRequest;
import model.ReportSummary;
import model.WasteBin;

public class ReportDAO {

    private static final String BIN_STATISTICS
            = "SELECT b.status, COUNT(*) AS cnt "
            + "FROM tblWasteBins b "
            + "WHERE 1 = 1 ";

    private static final String COLLECTION_STATISTICS
            = "SELECT r.status, COUNT(*) AS cnt "
            + "FROM tblCollectionRequests r "
            + "INNER JOIN tblWasteBins b ON b.binID = r.binID "
            + "WHERE 1 = 1 ";

    private static final String MAINTENANCE_STATISTICS
            = "SELECT m.status, COUNT(*) AS cnt "
            + "FROM tblMaintenance m "
            + "INNER JOIN tblWasteBins b ON b.binID = m.binID "
            + "WHERE 1 = 1 ";

    private static final String COUNT_ALERTS
            = "SELECT COUNT(*) "
            + "FROM tblAlerts a "
            + "INNER JOIN tblWasteBins b ON b.binID = a.binID "
            + "WHERE 1 = 1 ";

    // =====================================================
    // SUMMARY
    // =====================================================
    public ReportSummary getSummary(Timestamp from, Timestamp to,
            List<String> areaIds) {

        ReportSummary summary = new ReportSummary();

        Map<String, Integer> bins = getBinStatistics(areaIds);
        summary.setActiveBins(get(bins, "Active"));
        summary.setFullBins(get(bins, "Full"));
        summary.setBrokenBins(get(bins, "Maintenance"));
        summary.setTotalBins(sum(bins));

        Map<String, Integer> collections
                = getCollectionStatistics(from, to, areaIds);
        summary.setPendingCollections(get(collections, "Pending"));
        summary.setInProgressCollections(get(collections, "In_Progress"));
        summary.setCompletedCollections(get(collections, "Completed"));
        summary.setCancelledCollections(get(collections, "Cancelled"));
        summary.setTotalCollections(sum(collections));

        summary.setTotalAlerts(countAlerts(from, to, areaIds, false));
        summary.setUnresolvedAlerts(countAlerts(from, to, areaIds, true));

        Map<String, Integer> maintenance
                = getMaintenanceStatistics(from, to, areaIds);
        summary.setPendingMaintenance(get(maintenance, "Pending"));
        summary.setInProgressMaintenance(get(maintenance, "In_Progress"));
        summary.setCompletedMaintenance(get(maintenance, "Completed"));
        summary.setTotalMaintenance(sum(maintenance));

        return summary;
    }

    // =====================================================
    // BIN STATISTICS
    // =====================================================
    public Map<String, Integer> getBinStatistics(List<String> areaIds) {

        StringBuilder sql = new StringBuilder(BIN_STATISTICS);
        List<Object> params = new ArrayList<Object>();

        appendAreaFilter(sql, params, "b.areaID", areaIds);
        sql.append("GROUP BY b.status");

        return groupByStatus(sql.toString(), params);
    }

    // =====================================================
    // COLLECTION STATISTICS
    // =====================================================
    public Map<String, Integer> getCollectionStatistics(
            Timestamp from, Timestamp to, List<String> areaIds) {

        StringBuilder sql = new StringBuilder(COLLECTION_STATISTICS);
        List<Object> params = new ArrayList<Object>();

        appendDateFilter(sql, params, "r.createdDate", from, to);
        appendAreaFilter(sql, params, "b.areaID", areaIds);

        sql.append("GROUP BY r.status");

        return groupByStatus(sql.toString(), params);
    }

    // =====================================================
    // MAINTENANCE STATISTICS
    // =====================================================
    public Map<String, Integer> getMaintenanceStatistics(
            Timestamp from, Timestamp to, List<String> areaIds) {

        StringBuilder sql = new StringBuilder(MAINTENANCE_STATISTICS);
        List<Object> params = new ArrayList<Object>();

        appendDateFilter(sql, params, "m.scheduledDate", from, to);
        appendAreaFilter(sql, params, "b.areaID", areaIds);

        sql.append("GROUP BY m.status");

        return groupByStatus(sql.toString(), params);
    }

    // =====================================================
    // ALERT COUNT
    // =====================================================
    public int countAlerts(Timestamp from, Timestamp to,
            List<String> areaIds, boolean onlyUnresolved) {

        StringBuilder sql = new StringBuilder(COUNT_ALERTS);
        List<Object> params = new ArrayList<Object>();

        appendDateFilter(sql, params, "a.createdDate", from, to);
        appendAreaFilter(sql, params, "b.areaID", areaIds);

        if (onlyUnresolved) {
            sql.append("AND a.isResolved = 0 ");
        }

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(sql.toString());

            setParameters(ptm, params);

            rs = ptm.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ptm, conn);
        }

        return 0;
    }

    // =====================================================
    // DETAILED COLLECTIONS
    // =====================================================
    public List<CollectionRequest> getDetailedCollections(
            Timestamp from, Timestamp to, List<String> areaIds) {

        List<CollectionRequest> list = new ArrayList<CollectionRequest>();

        StringBuilder sql = new StringBuilder(
                "SELECT r.requestID, r.binID, r.supervisorID, r.staffID, r.status, "
                + "r.priority, r.createdDate, r.completedDate, r.notes, "
                + "b.binCode, b.location, a.areaName, u.fullName AS staffName "
                + "FROM tblCollectionRequests r "
                + "INNER JOIN tblWasteBins b ON b.binID = r.binID "
                + "LEFT JOIN tblAreas a ON a.areaID = b.areaID "
                + "LEFT JOIN tblUsers u ON u.userID = r.staffID "
                + "WHERE 1 = 1 ");

        List<Object> params = new ArrayList<Object>();
        appendDateFilter(sql, params, "r.createdDate", from, to);
        appendAreaFilter(sql, params, "b.areaID", areaIds);
        sql.append("ORDER BY r.createdDate DESC, r.requestID DESC");

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(sql.toString());
            setParameters(ptm, params);
            rs = ptm.executeQuery();

            while (rs.next()) {
                CollectionRequest c = new CollectionRequest();
                c.setRequestID(rs.getString("requestID"));
                c.setBinID(rs.getString("binID"));
                c.setSupervisorID(rs.getString("supervisorID"));
                c.setStaffID(rs.getString("staffID"));
                c.setStatus(rs.getString("status"));
                c.setPriority(rs.getString("priority"));
                c.setCreatedDate(rs.getTimestamp("createdDate"));
                c.setCompletedDate(rs.getTimestamp("completedDate"));
                c.setNotes(rs.getString("notes"));
                c.setBinCode(rs.getString("binCode"));
                c.setLocation(rs.getString("location"));
                c.setAreaName(rs.getString("areaName"));
                c.setStaffName(rs.getString("staffName"));
                list.add(c);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ptm, conn);
        }

        return list;
    }

    // =====================================================
    // DETAILED BINS
    // =====================================================
    public List<WasteBin> getDetailedBins(List<String> areaIds) {

        List<WasteBin> list = new ArrayList<WasteBin>();

        StringBuilder sql = new StringBuilder(
                "SELECT b.binID, b.binCode, b.location, b.latitude, b.longitude, "
                + "b.capacity, b.currentFill, b.status, b.areaID, b.lastEmptied, "
                + "a.areaName "
                + "FROM tblWasteBins b "
                + "LEFT JOIN tblAreas a ON a.areaID = b.areaID "
                + "WHERE 1 = 1 ");

        List<Object> params = new ArrayList<Object>();
        appendAreaFilter(sql, params, "b.areaID", areaIds);
        sql.append("ORDER BY b.binCode ASC");

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(sql.toString());
            setParameters(ptm, params);
            rs = ptm.executeQuery();

            while (rs.next()) {
                WasteBin b = new WasteBin();
                b.setBinID(rs.getString("binID"));
                b.setBinCode(rs.getString("binCode"));
                b.setLocation(rs.getString("location"));
                b.setLatitude(rs.getDouble("latitude"));
                b.setLongitude(rs.getDouble("longitude"));
                b.setCapacity(rs.getDouble("capacity"));
                b.setCurrentFill(rs.getDouble("currentFill"));
                b.setStatus(rs.getString("status"));
                b.setAreaID(rs.getString("areaID"));
                b.setLastEmptied(rs.getTimestamp("lastEmptied"));
                b.setAreaName(rs.getString("areaName"));
                list.add(b);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ptm, conn);
        }

        return list;
    }

    // =====================================================
    // GROUP BY STATUS
    // =====================================================
    private Map<String, Integer> groupByStatus(
            String sql, List<Object> params) {

        Map<String, Integer> result
                = new LinkedHashMap<String, Integer>();

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(sql);

            setParameters(ptm, params);

            rs = ptm.executeQuery();

            while (rs.next()) {
                result.put(rs.getString(1), rs.getInt(2));
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ptm, conn);
        }

        return result;
    }

    // =====================================================
    // APPEND DATE FILTER
    // "to" is exclusive
    // =====================================================
    private void appendDateFilter(StringBuilder sql,
            List<Object> params, String column,
            Timestamp from, Timestamp to) {

        if (from != null) {
            sql.append("AND ").append(column).append(" >= ? ");
            params.add(from);
        }

        if (to != null) {
            sql.append("AND ").append(column).append(" < ? ");
            params.add(to);
        }
    }

    // =====================================================
    // APPEND AREA FILTER
    // =====================================================
    private void appendAreaFilter(StringBuilder sql,
            List<Object> params, String column,
            List<String> areaIds) {

        if (areaIds == null || areaIds.isEmpty()) {
            return;
        }

        sql.append("AND ").append(column).append(" IN (");

        for (int i = 0; i < areaIds.size(); i++) {
            if (i > 0) {
                sql.append(", ");
            }

            sql.append("?");
            params.add(areaIds.get(i));
        }

        sql.append(") ");
    }

    // =====================================================
    // SET PARAMETERS
    // =====================================================
    private void setParameters(PreparedStatement ptm,
            List<Object> params) throws Exception {

        for (int i = 0; i < params.size(); i++) {
            Object value = params.get(i);

            if (value instanceof Timestamp) {
                ptm.setTimestamp(i + 1, (Timestamp) value);
            } else {
                ptm.setString(i + 1, String.valueOf(value));
            }
        }
    }

    // =====================================================
    // GET VALUE BY STATUS
    // =====================================================
    private int get(Map<String, Integer> map, String key) {

        Integer value = map.get(key);

        return value == null ? 0 : value.intValue();
    }

    // =====================================================
    // SUM STATISTICS
    // =====================================================
    private int sum(Map<String, Integer> map) {

        int total = 0;

        for (Integer value : map.values()) {
            total += value.intValue();
        }

        return total;
    }
}
