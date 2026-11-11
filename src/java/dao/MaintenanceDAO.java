package dao;

import model.Maintenance;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class MaintenanceDAO {

    // =========================================================
    // SQL CONSTANTS
    // =========================================================
    private static final String SELECT_COLUMNS
            = "SELECT m.maintenanceID, m.binID, m.technicianID, "
            + "m.maintenanceType, m.status, m.scheduledDate, "
            + "m.completedDate, m.description, m.resolutionNotes, "
            + "m.rootCause, m.repairMethod, m.replacedParts, "
            + "b.binCode, b.location, u.fullName AS technicianName "
            + "FROM tblMaintenance m "
            + "LEFT JOIN tblWasteBins b ON m.binID = b.binID "
            + "LEFT JOIN tblUsers u ON m.technicianID = u.userID ";

    private static final String COUNT_ALL
            = "SELECT COUNT(*) FROM tblMaintenance m";

    private static final String COUNT_BY_STATUS
            = "SELECT COUNT(*) FROM tblMaintenance m WHERE m.status = ?";

    private static final String GET_ALL
            = SELECT_COLUMNS + "ORDER BY m.scheduledDate DESC";

    private static final String FIND_BY_ID
            = SELECT_COLUMNS + "WHERE m.maintenanceID = ?";

    private static final String GET_BY_TECHNICIAN
            = SELECT_COLUMNS
            + "WHERE m.technicianID = ? "
            + "ORDER BY m.scheduledDate DESC";

    private static final String INSERT
            = "INSERT INTO tblMaintenance "
            + "(maintenanceID, binID, technicianID, maintenanceType, "
            + "status, scheduledDate, completedDate, description, "
            + "resolutionNotes, rootCause, repairMethod, replacedParts) "
            + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

    private static final String UPDATE
            = "UPDATE tblMaintenance SET "
            + "binID = ?, technicianID = ?, maintenanceType = ?, "
            + "status = ?, scheduledDate = ?, completedDate = ?, "
            + "description = ?, resolutionNotes = ?, rootCause = ?, "
            + "repairMethod = ?, replacedParts = ? "
            + "WHERE maintenanceID = ?";

    private static final String DELETE
            = "DELETE FROM tblMaintenance WHERE maintenanceID = ?";

    private static final String MANAGER_AREA_CONDITION
            = "b.areaID IN ("
            + "SELECT COALESCE(ua.areaID, u.areaID) "
            + "FROM dbo.tblUsers u "
            + "LEFT JOIN dbo.tblUserAreas ua ON u.userID = ua.userID "
            + "WHERE u.userID = ? AND u.roleID IN ('MGR', 'SUP') "
            + "AND (u.areaID IS NOT NULL OR ua.areaID IS NOT NULL)) ";

    // =========================================================
    // COUNT ALL
    // =========================================================
    public int countAll() {
        return executeCount(COUNT_ALL, new ArrayList<String>());
    }

    // =========================================================
    // COUNT BY STATUS
    // =========================================================
    public int countByStatus(String status) {
        List<String> params = new ArrayList<String>();
        params.add(status);

        return executeCount(COUNT_BY_STATUS, params);
    }

    // =========================================================
    // GET ALL
    // =========================================================
    public List<Maintenance> getAll() {
        return executeListQuery(
                GET_ALL, new ArrayList<String>());
    }

    // =========================================================
    // FIND BY ID
    // =========================================================
    public Maintenance findByID(String maintenanceID) {
        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;
        Maintenance maintenance = null;

        try {
            conn = DBContext.getConnection();

            if (conn != null) {
                ptm = conn.prepareStatement(FIND_BY_ID);
                ptm.setString(1, maintenanceID);

                rs = ptm.executeQuery();

                if (rs.next()) {
                    maintenance = map(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ptm, conn);
        }

        return maintenance;
    }

    // =========================================================
    // GET BY TECHNICIAN
    // =========================================================
    public List<Maintenance> getByTechnician(String technicianID) {
        List<String> params = new ArrayList<String>();
        params.add(technicianID);

        return executeListQuery(GET_BY_TECHNICIAN, params);
    }

    // =========================================================
    // INSERT
    // =========================================================
    public boolean insert(Maintenance maintenance) {
        Connection conn = null;
        PreparedStatement ptm = null;
        boolean check = false;

        try {
            conn = DBContext.getConnection();

            if (conn != null) {
                ptm = conn.prepareStatement(INSERT);

                ptm.setString(1, maintenance.getMaintenanceID());
                ptm.setString(2, maintenance.getBinID());
                ptm.setString(3, maintenance.getTechnicianID());
                ptm.setString(4, maintenance.getMaintenanceType());
                ptm.setString(5, maintenance.getStatus());
                ptm.setTimestamp(6, maintenance.getScheduledDate());
                ptm.setTimestamp(7, maintenance.getCompletedDate());
                ptm.setString(8, maintenance.getDescription());
                ptm.setString(9, maintenance.getResolutionNotes());
                ptm.setString(10, maintenance.getRootCause());
                ptm.setString(11, maintenance.getRepairMethod());
                ptm.setString(12, maintenance.getReplacedParts());

                check = ptm.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(ptm, conn);
        }

        return check;
    }

    // =========================================================
    // UPDATE
    // =========================================================
    public boolean update(Maintenance maintenance) {
        Connection conn = null;
        PreparedStatement ptm = null;
        boolean check = false;

        try {
            conn = DBContext.getConnection();

            if (conn != null) {
                ptm = conn.prepareStatement(UPDATE);

                ptm.setString(1, maintenance.getBinID());
                ptm.setString(2, maintenance.getTechnicianID());
                ptm.setString(3, maintenance.getMaintenanceType());
                ptm.setString(4, maintenance.getStatus());
                ptm.setTimestamp(5, maintenance.getScheduledDate());
                ptm.setTimestamp(6, maintenance.getCompletedDate());
                ptm.setString(7, maintenance.getDescription());
                ptm.setString(8, maintenance.getResolutionNotes());
                ptm.setString(9, maintenance.getRootCause());
                ptm.setString(10, maintenance.getRepairMethod());
                ptm.setString(11, maintenance.getReplacedParts());
                ptm.setString(12, maintenance.getMaintenanceID());

                check = ptm.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(ptm, conn);
        }

        return check;
    }

    // =========================================================
    // DELETE
    // =========================================================
    public boolean delete(String maintenanceID) {
        Connection conn = null;
        PreparedStatement ptm = null;
        boolean check = false;

        try {
            conn = DBContext.getConnection();

            if (conn != null) {
                ptm = conn.prepareStatement(DELETE);
                ptm.setString(1, maintenanceID);

                check = ptm.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(ptm, conn);
        }

        return check;
    }

    // =========================================================
    // GET BY MANAGER
    // Restrict maintenance requests to manager's assigned area.
    // =========================================================
    public List<Maintenance> getByManager(String managerID) {
        String sql
                = "SELECT m.maintenanceID, m.binID, m.technicianID, "
                + "m.maintenanceType, m.status, m.scheduledDate, "
                + "m.completedDate, m.description, m.resolutionNotes, "
                + "m.rootCause, m.repairMethod, m.replacedParts, "
                + "b.binCode, b.location, u.fullName AS technicianName "
                + "FROM tblMaintenance m "
                + "INNER JOIN tblWasteBins b ON b.binID = m.binID "
                + "LEFT JOIN tblUsers u ON m.technicianID = u.userID "
                + "WHERE " + MANAGER_AREA_CONDITION
                + "ORDER BY m.scheduledDate DESC";

        List<String> params = new ArrayList<String>();
        params.add(managerID);

        return executeListQuery(sql, params);
    }

    // =========================================================
    // GET ACTIVE TECHNICIANS BY BIN
    // =========================================================
    public List<String> getActiveTechnicianIdsByBin(String binID) {
        List<String> list = new ArrayList<String>();

        String sql
                = "SELECT DISTINCT technicianID "
                + "FROM tblMaintenance "
                + "WHERE binID = ? "
                + "AND technicianID IS NOT NULL "
                + "AND status IN ('Pending', 'In_Progress')";

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();

            if (conn != null) {
                ptm = conn.prepareStatement(sql);
                ptm.setString(1, binID);

                rs = ptm.executeQuery();

                while (rs.next()) {
                    list.add(rs.getString("technicianID"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ptm, conn);
        }

        return list;
    }

    // =========================================================
    // FILTERED PAGINATION: ADMIN
    // =========================================================
    public List<Maintenance> getFilteredPaged(
            String searchId,
            String technicianID,
            String maintenanceType,
            String status,
            String sortBy,
            String order,
            int offset,
            int pageSize) {

        StringBuilder sql = new StringBuilder(SELECT_COLUMNS);
        sql.append("WHERE 1 = 1 ");

        List<String> params = new ArrayList<String>();

        appendFilters(
                sql, params, "m.",
                searchId, technicianID, maintenanceType, status,
                false, null);

        appendOrderBy(sql, sortBy, order, "m.");

        return executePagedQuery(
                sql.toString(), params, offset, pageSize);
    }

    // =========================================================
    // COUNT FILTERED: ADMIN
    // =========================================================
    public int countFiltered(
            String searchId,
            String technicianID,
            String maintenanceType,
            String status) {

        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM tblMaintenance m "
                + "LEFT JOIN tblWasteBins b ON m.binID = b.binID WHERE 1 = 1 ");

        List<String> params = new ArrayList<String>();

        appendFilters(
                sql, params, "m.",
                searchId, technicianID, maintenanceType, status,
                false, null);

        return executeCount(sql.toString(), params);
    }

    // =========================================================
    // FILTERED PAGINATION: MANAGER
    // =========================================================
    public List<Maintenance> getFilteredByManagerPaged(
            String managerID,
            String searchId,
            String technicianID,
            String maintenanceType,
            String status,
            String sortBy,
            String order,
            int offset,
            int pageSize) {

        StringBuilder sql = new StringBuilder();

        sql.append("SELECT m.maintenanceID, m.binID, m.technicianID, ");
        sql.append("m.maintenanceType, m.status, m.scheduledDate, ");
        sql.append("m.completedDate, m.description, m.resolutionNotes, ");
        sql.append("m.rootCause, m.repairMethod, m.replacedParts, ");
        sql.append("b.binCode, b.location, u.fullName AS technicianName ");
        sql.append("FROM tblMaintenance m ");
        sql.append("INNER JOIN tblWasteBins b ON b.binID = m.binID ");
        sql.append("LEFT JOIN tblUsers u ON m.technicianID = u.userID ");
        sql.append("WHERE ");
        sql.append(MANAGER_AREA_CONDITION);

        List<String> params = new ArrayList<String>();
        params.add(managerID);

        appendFilters(
                sql, params, "m.",
                searchId, technicianID, maintenanceType, status,
                false, null);

        appendOrderBy(sql, sortBy, order, "m.");

        return executePagedQuery(
                sql.toString(), params, offset, pageSize);
    }

    // =========================================================
    // COUNT FILTERED: MANAGER
    // =========================================================
    public int countFilteredByManager(
            String managerID,
            String searchId,
            String technicianID,
            String maintenanceType,
            String status) {

        StringBuilder sql = new StringBuilder();

        sql.append("SELECT COUNT(*) ");
        sql.append("FROM tblMaintenance m ");
        sql.append("INNER JOIN tblWasteBins b ON b.binID = m.binID ");
        sql.append("WHERE ");
        sql.append(MANAGER_AREA_CONDITION);

        List<String> params = new ArrayList<String>();
        params.add(managerID);

        appendFilters(
                sql, params, "m.",
                searchId, technicianID, maintenanceType, status,
                false, null);

        return executeCount(sql.toString(), params);
    }

    // =========================================================
    // FILTERED PAGINATION: TECHNICIAN
        // Restrict tasks to those assigned to the technician.
    // =========================================================
    public List<Maintenance> getFilteredByTechnicianPaged(
            String assignedTechnicianID,
            String searchId,
            String technicianFilter,
            String maintenanceType,
            String status,
            String sortBy,
            String order,
            int offset,
            int pageSize) {

        StringBuilder sql = new StringBuilder(SELECT_COLUMNS);
        sql.append("WHERE m.technicianID = ? ");

        List<String> params = new ArrayList<String>();
        params.add(assignedTechnicianID);

        appendFilters(
                sql, params, "m.",
                searchId, technicianFilter, maintenanceType, status,
                false, null);

        appendOrderBy(sql, sortBy, order, "m.");

        return executePagedQuery(
                sql.toString(), params, offset, pageSize);
    }

    // =========================================================
    // COUNT FILTERED: TECHNICIAN
    // =========================================================
    public int countFilteredByTechnician(
            String assignedTechnicianID,
            String searchId,
            String technicianFilter,
            String maintenanceType,
            String status) {

        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM tblMaintenance m "
                + "LEFT JOIN tblWasteBins b ON m.binID = b.binID "
                + "WHERE m.technicianID = ? ");

        List<String> params = new ArrayList<String>();
        params.add(assignedTechnicianID);

        appendFilters(
                sql, params, "m.",
                searchId, technicianFilter, maintenanceType, status,
                false, null);

        return executeCount(sql.toString(), params);
    }

    // =========================================================
    // FILTERED PAGINATION: STAFF
        // Restrict maintenance records to accessible bins.
    // =========================================================
    public List<Maintenance> getFilteredByBinsPaged(
            List<String> binIDs,
            String searchId,
            String sortBy,
            String order,
            int offset,
            int pageSize) {

        List<Maintenance> list = new ArrayList<Maintenance>();
        List<String> params = new ArrayList<String>();

        String placeholders = buildBinPlaceholders(binIDs, params);

        if (placeholders.isEmpty()) {
            return list;
        }

        StringBuilder sql = new StringBuilder(SELECT_COLUMNS);
        sql.append("WHERE m.binID IN (").append(placeholders).append(") ");

        appendSearchFilter(sql, params, "m.", searchId);
        appendOrderBy(sql, sortBy, order, "m.");

        return executePagedQuery(
                sql.toString(), params, offset, pageSize);
    }

    // =========================================================
    // COUNT FILTERED: STAFF
    // =========================================================
    public int countFilteredByBins(
            List<String> binIDs,
            String searchId) {

        List<String> params = new ArrayList<String>();

        String placeholders = buildBinPlaceholders(binIDs, params);

        if (placeholders.isEmpty()) {
            return 0;
        }

        StringBuilder sql = new StringBuilder();

        sql.append("SELECT COUNT(*) FROM tblMaintenance m ");
        sql.append("LEFT JOIN tblWasteBins b ON m.binID = b.binID ");
        sql.append("WHERE m.binID IN (").append(placeholders).append(") ");

        appendSearchFilter(sql, params, "m.", searchId);

        return executeCount(sql.toString(), params);
    }

    // =========================================================
    // APPEND FILTERS
    // =========================================================
    private void appendFilters(
            StringBuilder sql,
            List<String> params,
            String prefix,
            String searchId,
            String technicianID,
            String maintenanceType,
            String status,
            boolean useTechnicianEquals,
            String ignored) {

        appendSearchFilter(sql, params, prefix, searchId);

        if (hasText(technicianID)) {
            if (useTechnicianEquals) {
                sql.append("AND ").append(prefix)
                        .append("technicianID = ? ");
                params.add(technicianID.trim());
            } else {
                sql.append("AND ").append(prefix)
                        .append("technicianID LIKE ? ");
                params.add("%" + technicianID.trim() + "%");
            }
        }

        if (hasText(maintenanceType)) {
            sql.append("AND ").append(prefix)
                    .append("maintenanceType = ? ");
            params.add(maintenanceType.trim());
        }

        if (hasText(status)) {
            sql.append("AND ").append(prefix).append("status = ? ");
            params.add(status.trim());
        }
    }

    // =========================================================
    // APPEND SEARCH FILTER
    // =========================================================
    private void appendSearchFilter(
            StringBuilder sql,
            List<String> params,
            String prefix,
            String searchId) {

        if (hasText(searchId)) {
            sql.append("AND (")
                    .append(prefix).append("maintenanceID LIKE ? OR ")
                    .append(prefix).append("binID LIKE ? OR ")
                    .append("b.binCode LIKE ? OR ")
                    .append("b.location LIKE ?) ");

            String value = "%" + searchId.trim() + "%";

            params.add(value);
            params.add(value);
            params.add(value);
            params.add(value);
        }
    }

    // =========================================================
    // APPEND ORDER BY
    // =========================================================
    private void appendOrderBy(
            StringBuilder sql,
            String sortBy,
            String order,
            String prefix) {

        String sortColumn = getSortColumn(sortBy, prefix);
        String sortOrder = getSortOrder(order);

        sql.append("ORDER BY ")
                .append(sortColumn).append(" ")
                .append(sortOrder);

        if (!"scheduledDate".equals(removePrefix(sortColumn, prefix))) {
            sql.append(", ").append(prefix).append("scheduledDate DESC");
        }

        sql.append(", ").append(prefix).append("maintenanceID ASC ");
    }

    // =========================================================
    // SORT COLUMN WHITELIST
    // =========================================================
    private String getSortColumn(String sortBy, String prefix) {

        if ("status".equals(sortBy)) {
            return prefix + "status";
        }

        if ("maintenanceType".equals(sortBy)) {
            return prefix + "maintenanceType";
        }

        if ("completedDate".equals(sortBy)) {
            return prefix + "completedDate";
        }

        return prefix + "scheduledDate";
    }

    // =========================================================
    // SORT ORDER WHITELIST
    // =========================================================
    private String getSortOrder(String order) {
        return "ASC".equalsIgnoreCase(order) ? "ASC" : "DESC";
    }

    private String removePrefix(String value, String prefix) {
        if (value.startsWith(prefix)) {
            return value.substring(prefix.length());
        }

        return value;
    }

    // =========================================================
    // BUILD BIN PLACEHOLDERS
    // =========================================================
    private String buildBinPlaceholders(
            List<String> binIDs,
            List<String> params) {

        if (binIDs == null || binIDs.isEmpty()) {
            return "";
        }

        StringBuilder placeholders = new StringBuilder();

        for (String binID : binIDs) {
            if (!hasText(binID)) {
                continue;
            }

            if (placeholders.length() > 0) {
                placeholders.append(", ");
            }

            placeholders.append("?");
            params.add(binID.trim());
        }

        return placeholders.toString();
    }

    // =========================================================
    // EXECUTE LIST QUERY
    // =========================================================
    private List<Maintenance> executeListQuery(
            String sql,
            List<String> params) {

        List<Maintenance> list = new ArrayList<Maintenance>();

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();

            if (conn != null) {
                ptm = conn.prepareStatement(sql);
                setParameters(ptm, params);

                rs = ptm.executeQuery();

                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ptm, conn);
        }

        return list;
    }

    // =========================================================
    // EXECUTE PAGED QUERY
    // =========================================================
    private List<Maintenance> executePagedQuery(
            String sql,
            List<String> params,
            int offset,
            int pageSize) {

        List<Maintenance> list = new ArrayList<Maintenance>();

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();

            if (conn != null) {
                ptm = conn.prepareStatement(
                        sql + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

                setParameters(ptm, params);

                int index = params.size() + 1;
                ptm.setInt(index++, Math.max(0, offset));
                ptm.setInt(index, Math.max(1, pageSize));

                rs = ptm.executeQuery();

                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ptm, conn);
        }

        return list;
    }

    // =========================================================
    // EXECUTE COUNT QUERY
    // =========================================================
    private int executeCount(
            String sql,
            List<String> params) {

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;
        int count = 0;

        try {
            conn = DBContext.getConnection();

            if (conn != null) {
                ptm = conn.prepareStatement(sql);
                setParameters(ptm, params);

                rs = ptm.executeQuery();

                if (rs.next()) {
                    count = rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ptm, conn);
        }

        return count;
    }

    // =========================================================
    // SET PARAMETERS
    // =========================================================
    private void setParameters(
            PreparedStatement ptm,
            List<String> params) throws SQLException {

        for (int i = 0; i < params.size(); i++) {
            ptm.setString(i + 1, params.get(i));
        }
    }

    // =========================================================
    // MAP RESULTSET TO MAINTENANCE
    // =========================================================
    private Maintenance map(ResultSet rs) throws SQLException {
        Maintenance maintenance = new Maintenance();

        maintenance.setMaintenanceID(
                rs.getString("maintenanceID"));

        maintenance.setBinID(
                rs.getString("binID"));

        maintenance.setTechnicianID(
                rs.getString("technicianID"));

        maintenance.setMaintenanceType(
                rs.getString("maintenanceType"));

        maintenance.setStatus(
                rs.getString("status"));

        maintenance.setScheduledDate(
                rs.getTimestamp("scheduledDate"));

        maintenance.setCompletedDate(
                rs.getTimestamp("completedDate"));

        maintenance.setDescription(
                rs.getString("description"));

        try {
            maintenance.setResolutionNotes(rs.getString("resolutionNotes"));
            maintenance.setRootCause(rs.getString("rootCause"));
            maintenance.setRepairMethod(rs.getString("repairMethod"));
            maintenance.setReplacedParts(rs.getString("replacedParts"));
        } catch (SQLException ignored) {}

        try {
            maintenance.setBinCode(rs.getString("binCode"));
            maintenance.setLocation(rs.getString("location"));
        } catch (SQLException ignored) {}

        try {
            maintenance.setTechnicianName(rs.getString("technicianName"));
        } catch (SQLException ignored) {}

        return maintenance;
    }

    // =========================================================
    // TECHNICIAN ADVANCED METRICS: REPAIR COUNT, MTTR & SUCCESS RATE
    // =========================================================

    public int getRepairCountByBin(String binID) {
        if (binID == null || binID.trim().isEmpty()) return 0;
        String sql = "SELECT COUNT(*) FROM tblMaintenance WHERE binID = ? AND status = 'Completed'";
        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            if (conn != null) {
                ptm = conn.prepareStatement(sql);
                ptm.setString(1, binID.trim());
                rs = ptm.executeQuery();
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ptm, conn);
        }
        return 0;
    }

    public double getTechnicianFixSuccessRate(String technicianID) {
        if (technicianID == null || technicianID.trim().isEmpty()) return 100.0;
        String sql = "SELECT COUNT(*) AS total, "
                   + "SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) AS done "
                   + "FROM tblMaintenance WHERE technicianID = ?";
        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            if (conn != null) {
                ptm = conn.prepareStatement(sql);
                ptm.setString(1, technicianID.trim());
                rs = ptm.executeQuery();
                if (rs.next()) {
                    int total = rs.getInt("total");
                    int done = rs.getInt("done");
                    return total > 0 ? Math.round((done * 1000.0 / total)) / 10.0 : 100.0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ptm, conn);
        }
        return 100.0;
    }

    public double getTechnicianMTTRHours(String technicianID) {
        if (technicianID == null || technicianID.trim().isEmpty()) return 1.5;
        String sql = "SELECT AVG(CAST(DATEDIFF(minute, scheduledDate, completedDate) AS float)) / 60.0 AS avgHours "
                   + "FROM tblMaintenance "
                   + "WHERE technicianID = ? AND status = 'Completed' AND completedDate IS NOT NULL AND scheduledDate IS NOT NULL";
        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            if (conn != null) {
                ptm = conn.prepareStatement(sql);
                ptm.setString(1, technicianID.trim());
                rs = ptm.executeQuery();
                if (rs.next()) {
                    double hours = rs.getDouble("avgHours");
                    return hours > 0 ? (Math.round(hours * 10.0) / 10.0) : 1.5;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ptm, conn);
        }
        return 1.5;
    }

    // =========================================================
    // CHECK NON-EMPTY STRING
    // =========================================================
    private boolean hasText(String value) {
        return value != null && !value.trim().isEmpty();
    }
}
