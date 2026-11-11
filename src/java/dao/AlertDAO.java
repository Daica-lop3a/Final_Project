package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Alert;

public class AlertDAO {

    // ==================== SQL CONSTANTS ====================

    private static final String SELECT_COLUMNS =
            "alertID, binID, alertType, message, createdDate, isResolved";

    private static final String SELECT_COLUMNS_ALIAS =
            "a.alertID, a.binID, a.alertType, "
            + "a.message, a.createdDate, a.isResolved";

    private static final String COUNT_ALL =
            "SELECT COUNT(*) FROM dbo.tblAlerts";

    private static final String COUNT_UNRESOLVED =
            "SELECT COUNT(*) FROM dbo.tblAlerts WHERE isResolved = 0";

    private static final String GET_ALL =
            "SELECT " + SELECT_COLUMNS
            + " FROM dbo.tblAlerts "
            + "ORDER BY createdDate DESC";

    private static final String GET_BY_ID =
            "SELECT " + SELECT_COLUMNS
            + " FROM dbo.tblAlerts WHERE alertID = ?";

    private static final String INSERT_WITH_DEFAULTS =
            "INSERT INTO dbo.tblAlerts "
            + "(alertID, binID, alertType, message) "
            + "VALUES (?, ?, ?, ?)";

    private static final String INSERT_WITH_ALL_FIELDS =
            "INSERT INTO dbo.tblAlerts "
            + "(alertID, binID, alertType, message, createdDate, isResolved) "
            + "VALUES (?, ?, ?, ?, ?, ?)";

    private static final String UPDATE =
            "UPDATE dbo.tblAlerts SET "
            + "binID = ?, alertType = ?, message = ?, isResolved = ? "
            + "WHERE alertID = ?";

    private static final String DELETE =
            "DELETE FROM dbo.tblAlerts WHERE alertID = ?";

    private static final String SET_RESOLVED =
            "UPDATE dbo.tblAlerts SET isResolved = ? WHERE alertID = ?";

    private static final String HIGH_FILL_TYPES =
            "('High_Fill', 'HighFill', 'Overflow', 'Full')";

    private static final String GET_BY_MANAGER =
            "SELECT " + SELECT_COLUMNS_ALIAS
            + " FROM dbo.tblAlerts a "
            + "INNER JOIN dbo.tblWasteBins b ON b.binID = a.binID "
            + "WHERE b.areaID IN ("
            + "SELECT COALESCE(ua.areaID, u.areaID) "
            + "FROM dbo.tblUsers u "
            + "LEFT JOIN dbo.tblUserAreas ua ON u.userID = ua.userID "
            + "WHERE u.userID = ? AND u.roleID IN ('MGR', 'SUP', 'STF', 'TEC') "
            + "AND (u.areaID IS NOT NULL OR ua.areaID IS NOT NULL)) "
            + "ORDER BY a.createdDate DESC";

    private static final String GET_BY_RECIPIENT =
            "SELECT " + SELECT_COLUMNS_ALIAS
            + " FROM dbo.tblAlerts a "
            + "WHERE EXISTS ("
            + "SELECT 1 FROM dbo.tblNotifications n "
            + "WHERE n.notifType = 'ALERT' "
            + "AND n.refID = a.alertID "
            + "AND n.userID = ?) "
            + "ORDER BY a.createdDate DESC";

    private static final String GET_BY_USER =
            "SELECT " + SELECT_COLUMNS_ALIAS
            + " FROM dbo.tblAlerts a "
            + "WHERE EXISTS ("
            + "SELECT 1 FROM dbo.tblUserTrackedBins t "
            + "WHERE t.binID = a.binID "
            + "AND t.userID = ?) "
            + "ORDER BY a.createdDate DESC";

    private static final String CHECK_UNRESOLVED_HIGH_FILL =
            "SELECT 1 FROM dbo.tblAlerts "
            + "WHERE binID = ? "
            + "AND alertType IN " + HIGH_FILL_TYPES + " "
            + "AND isResolved = 0";

    private static final String RESOLVE_HIGH_FILL =
            "UPDATE dbo.tblAlerts SET isResolved = 1 "
            + "WHERE binID = ? "
            + "AND alertType IN " + HIGH_FILL_TYPES + " "
            + "AND isResolved = 0";

    private static final String CHECK_TRACKED_BIN =
            "SELECT 1 FROM dbo.tblUserTrackedBins "
            + "WHERE userID = ? AND binID = ?";

    private static final String CHECK_RECIPIENT =
            "SELECT 1 FROM dbo.tblNotifications "
            + "WHERE notifType = 'ALERT' "
            + "AND refID = ? AND userID = ?";

    private static final String FILTER_BASE =
            "SELECT " + SELECT_COLUMNS
            + " FROM dbo.tblAlerts WHERE 1 = 1 ";

    private static final String FILTER_MANAGER_BASE =
            "SELECT " + SELECT_COLUMNS_ALIAS
            + " FROM dbo.tblAlerts a "
            + "INNER JOIN dbo.tblWasteBins b ON b.binID = a.binID "
            + "WHERE b.areaID IN ("
            + "SELECT COALESCE(ua.areaID, u.areaID) "
            + "FROM dbo.tblUsers u "
            + "LEFT JOIN dbo.tblUserAreas ua ON u.userID = ua.userID "
            + "WHERE u.userID = ? AND u.roleID IN ('MGR', 'SUP', 'STF', 'TEC') "
            + "AND (u.areaID IS NOT NULL OR ua.areaID IS NOT NULL)) ";

    private static final String FILTER_RECIPIENT_BASE =
            "SELECT " + SELECT_COLUMNS_ALIAS
            + " FROM dbo.tblAlerts a "
            + "WHERE EXISTS ("
            + "SELECT 1 FROM dbo.tblNotifications n "
            + "WHERE n.notifType = 'ALERT' "
            + "AND n.refID = a.alertID "
            + "AND n.userID = ?) ";

    private static final String FILTER_USER_BASE =
            "SELECT " + SELECT_COLUMNS_ALIAS
            + " FROM dbo.tblAlerts a "
            + "WHERE EXISTS ("
            + "SELECT 1 FROM dbo.tblUserTrackedBins t "
            + "WHERE t.binID = a.binID "
            + "AND t.userID = ?) ";

    private static final String COUNT_FILTER_BASE =
            "SELECT COUNT(*) FROM dbo.tblAlerts WHERE 1 = 1 ";

    private static final String COUNT_MANAGER_BASE =
            "SELECT COUNT(*) "
            + "FROM dbo.tblAlerts a "
            + "INNER JOIN dbo.tblWasteBins b ON b.binID = a.binID "
            + "WHERE b.areaID IN ("
            + "SELECT COALESCE(ua.areaID, u.areaID) "
            + "FROM dbo.tblUsers u "
            + "LEFT JOIN dbo.tblUserAreas ua ON u.userID = ua.userID "
            + "WHERE u.userID = ? AND u.roleID IN ('MGR', 'SUP') "
            + "AND (u.areaID IS NOT NULL OR ua.areaID IS NOT NULL)) ";

    private static final String COUNT_RECIPIENT_BASE =
            "SELECT COUNT(*) "
            + "FROM dbo.tblAlerts a "
            + "WHERE EXISTS ("
            + "SELECT 1 FROM dbo.tblNotifications n "
            + "WHERE n.notifType = 'ALERT' "
            + "AND n.refID = a.alertID "
            + "AND n.userID = ?) ";

    private static final String COUNT_USER_BASE =
            "SELECT COUNT(*) "
            + "FROM dbo.tblAlerts a "
            + "WHERE EXISTS ("
            + "SELECT 1 FROM dbo.tblUserTrackedBins t "
            + "WHERE t.binID = a.binID "
            + "AND t.userID = ?) ";

    // ==================== BASIC CRUD ====================

    public int countAll() {
        return executeCountQuery(COUNT_ALL, new ArrayList<Object>());
    }

    public int countUnresolved() {
        return executeCountQuery(
                COUNT_UNRESOLVED, new ArrayList<Object>());
    }

    public List<Alert> getAll() {
        return executeFilteredQuery(
                GET_ALL, new ArrayList<Object>());
    }

    public Alert findByID(String alertID) {
        if (isBlank(alertID)) {
            return null;
        }

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();

            if (conn == null) {
                return null;
            }

            ptm = conn.prepareStatement(GET_BY_ID);
            ptm.setString(1, alertID.trim());

            rs = ptm.executeQuery();

            if (rs.next()) {
                return map(rs);
            }

        } catch (Exception e) {
            System.err.println("Error finding alert by ID.");
            e.printStackTrace();

        } finally {
            DBContext.close(rs, ptm, conn);
        }

        return null;
    }

    public boolean insert(Alert alert) {
        if (alert == null
                || isBlank(alert.getAlertID())
                || isBlank(alert.getBinID())
                || isBlank(alert.getAlertType())
                || alert.getMessage() == null) {
            return false;
        }

        Connection conn = null;
        PreparedStatement ptm = null;

        try {
            conn = DBContext.getConnection();

            if (conn == null) {
                return false;
            }

            if (alert.getCreatedDate() == null) {
                ptm = conn.prepareStatement(INSERT_WITH_DEFAULTS);

                ptm.setString(1, alert.getAlertID().trim());
                ptm.setString(2, alert.getBinID().trim());
                ptm.setString(3, alert.getAlertType().trim());
                ptm.setString(4, alert.getMessage());

            } else {
                ptm = conn.prepareStatement(INSERT_WITH_ALL_FIELDS);

                ptm.setString(1, alert.getAlertID().trim());
                ptm.setString(2, alert.getBinID().trim());
                ptm.setString(3, alert.getAlertType().trim());
                ptm.setString(4, alert.getMessage());
                ptm.setTimestamp(5, alert.getCreatedDate());
                ptm.setBoolean(6, alert.isResolved());
            }

            return ptm.executeUpdate() > 0;

        } catch (Exception e) {
            System.err.println("Error inserting alert.");
            e.printStackTrace();

        } finally {
            DBContext.close(ptm, conn);
        }

        return false;
    }

    public boolean update(Alert alert) {
        if (alert == null
                || isBlank(alert.getAlertID())
                || isBlank(alert.getBinID())
                || isBlank(alert.getAlertType())
                || alert.getMessage() == null) {
            return false;
        }

        Connection conn = null;
        PreparedStatement ptm = null;

        try {
            conn = DBContext.getConnection();

            if (conn == null) {
                return false;
            }

            ptm = conn.prepareStatement(UPDATE);

            ptm.setString(1, alert.getBinID().trim());
            ptm.setString(2, alert.getAlertType().trim());
            ptm.setString(3, alert.getMessage());
            ptm.setBoolean(4, alert.isResolved());
            ptm.setString(5, alert.getAlertID().trim());

            return ptm.executeUpdate() > 0;

        } catch (Exception e) {
            System.err.println("Error updating alert.");
            e.printStackTrace();

        } finally {
            DBContext.close(ptm, conn);
        }

        return false;
    }

    public boolean delete(String alertID) {
        if (isBlank(alertID)) {
            return false;
        }

        Connection conn = null;
        PreparedStatement ptm = null;

        try {
            conn = DBContext.getConnection();

            if (conn == null) {
                return false;
            }

            ptm = conn.prepareStatement(DELETE);
            ptm.setString(1, alertID.trim());

            return ptm.executeUpdate() > 0;

        } catch (Exception e) {
            System.err.println("Error deleting alert.");
            e.printStackTrace();

        } finally {
            DBContext.close(ptm, conn);
        }

        return false;
    }

    public boolean setResolved(String alertID, boolean resolved) {
        if (isBlank(alertID)) {
            return false;
        }

        Connection conn = null;
        PreparedStatement ptm = null;

        try {
            conn = DBContext.getConnection();

            if (conn == null) {
                return false;
            }

            ptm = conn.prepareStatement(SET_RESOLVED);
            ptm.setBoolean(1, resolved);
            ptm.setString(2, alertID.trim());

            return ptm.executeUpdate() > 0;

        } catch (Exception e) {
            System.err.println("Error updating alert resolution.");
            e.printStackTrace();

        } finally {
            DBContext.close(ptm, conn);
        }

        return false;
    }

    // ==================== HIGH-FILL ALERTS ====================

    public boolean hasUnresolvedHighFillAlert(String binID) {
        if (isBlank(binID)) {
            return false;
        }

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();

            if (conn == null) {
                return false;
            }

            ptm = conn.prepareStatement(CHECK_UNRESOLVED_HIGH_FILL);
            ptm.setString(1, binID.trim());

            rs = ptm.executeQuery();

            return rs.next();

        } catch (Exception e) {
            System.err.println("Error checking unresolved high-fill alert.");
            e.printStackTrace();

        } finally {
            DBContext.close(rs, ptm, conn);
        }

        return false;
    }

    public boolean resolveUnresolvedHighFillAlerts(String binID) {
        if (isBlank(binID)) {
            return false;
        }

        Connection conn = null;
        PreparedStatement ptm = null;

        try {
            conn = DBContext.getConnection();

            if (conn == null) {
                return false;
            }

            ptm = conn.prepareStatement(RESOLVE_HIGH_FILL);
            ptm.setString(1, binID.trim());

            return ptm.executeUpdate() > 0;

        } catch (Exception e) {
            System.err.println("Error resolving high-fill alerts.");
            e.printStackTrace();

        } finally {
            DBContext.close(ptm, conn);
        }

        return false;
    }

    // ==================== ROLE-BASED QUERIES ====================

    public List<Alert> getByManager(String managerID) {
        List<Object> params = new ArrayList<Object>();
        params.add(managerID);

        return executeFilteredQuery(GET_BY_MANAGER, params);
    }

    public List<Alert> getByRecipient(String userID) {
        List<Object> params = new ArrayList<Object>();
        params.add(userID);

        return executeFilteredQuery(GET_BY_RECIPIENT, params);
    }

    public List<Alert> getByUser(String userID) {
        List<Object> params = new ArrayList<Object>();
        params.add(userID);

        return executeFilteredQuery(GET_BY_USER, params);
    }

    public boolean isBinTrackedByUser(String userID, String binID) {
        if (isBlank(userID) || isBlank(binID)) {
            return false;
        }

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();

            if (conn == null) {
                return false;
            }

            ptm = conn.prepareStatement(CHECK_TRACKED_BIN);
            ptm.setString(1, userID.trim());
            ptm.setString(2, binID.trim());

            rs = ptm.executeQuery();

            return rs.next();

        } catch (Exception e) {
            System.err.println("Error checking tracked bin.");
            e.printStackTrace();

        } finally {
            DBContext.close(rs, ptm, conn);
        }

        return false;
    }

    public boolean isRecipient(String alertID, String userID) {
        if (isBlank(alertID) || isBlank(userID)) {
            return false;
        }

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();

            if (conn == null) {
                return false;
            }

            ptm = conn.prepareStatement(CHECK_RECIPIENT);
            ptm.setString(1, alertID.trim());
            ptm.setString(2, userID.trim());

            rs = ptm.executeQuery();

            return rs.next();

        } catch (Exception e) {
            System.err.println("Error checking alert recipient.");
            e.printStackTrace();

        } finally {
            DBContext.close(rs, ptm, conn);
        }

        return false;
    }

    // ==================== FILTERED QUERIES ====================

    public List<Alert> getFiltered(
            String searchId, String alertType, String status,
            String sortBy, String order) {

        StringBuilder sql = new StringBuilder(FILTER_BASE);
        List<Object> params = new ArrayList<Object>();

        appendFilter(sql, params, searchId, alertType, status, "");

        appendOrderBy(sql, sortBy, order, "");

        return executeFilteredQuery(sql.toString(), params);
    }

    public List<Alert> getFilteredByManager(
            String managerID, String searchId, String alertType,
            String status, String sortBy, String order) {

        StringBuilder sql = new StringBuilder(FILTER_MANAGER_BASE);
        List<Object> params = new ArrayList<Object>();
        params.add(managerID);

        appendFilter(sql, params, searchId, alertType, status, "a.");

        appendOrderBy(sql, sortBy, order, "a.");

        return executeFilteredQuery(sql.toString(), params);
    }

    public List<Alert> getFilteredByRecipient(
            String userID, String searchId, String alertType,
            String status, String sortBy, String order) {

        StringBuilder sql = new StringBuilder(FILTER_RECIPIENT_BASE);
        List<Object> params = new ArrayList<Object>();
        params.add(userID);

        appendFilter(sql, params, searchId, alertType, status, "a.");

        appendOrderBy(sql, sortBy, order, "a.");

        return executeFilteredQuery(sql.toString(), params);
    }

    public List<Alert> getFilteredByUser(
            String userID, String searchId, String alertType,
            String status, String sortBy, String order) {

        StringBuilder sql = new StringBuilder(FILTER_USER_BASE);
        List<Object> params = new ArrayList<Object>();
        params.add(userID);

        appendFilter(sql, params, searchId, alertType, status, "a.");

        appendOrderBy(sql, sortBy, order, "a.");

        return executeFilteredQuery(sql.toString(), params);
    }

    // ==================== PAGINATION ====================

    public List<Alert> getFilteredPaged(
            String searchId, String alertType, String status,
            String sortBy, String order, int offset, int pageSize) {

        StringBuilder sql = new StringBuilder(FILTER_BASE);
        List<Object> params = new ArrayList<Object>();

        appendFilter(sql, params, searchId, alertType, status, "");

        appendOrderByPaged(sql, sortBy, order, "", false);

        return executeFilteredPagedQuery(
                sql.toString(), params, offset, pageSize);
    }

    public List<Alert> getFilteredByManagerPaged(
            String managerID, String searchId, String alertType,
            String status, String sortBy, String order,
            int offset, int pageSize) {

        StringBuilder sql = new StringBuilder(FILTER_MANAGER_BASE);
        List<Object> params = new ArrayList<Object>();
        params.add(managerID);

        appendFilter(sql, params, searchId, alertType, status, "a.");

        appendOrderByPaged(sql, sortBy, order, "a.", true);

        return executeFilteredPagedQuery(
                sql.toString(), params, offset, pageSize);
    }

    public List<Alert> getFilteredByRecipientPaged(
            String userID, String searchId, String alertType,
            String status, String sortBy, String order,
            int offset, int pageSize) {

        StringBuilder sql = new StringBuilder(FILTER_RECIPIENT_BASE);
        List<Object> params = new ArrayList<Object>();
        params.add(userID);

        appendFilter(sql, params, searchId, alertType, status, "a.");

        appendOrderByPaged(sql, sortBy, order, "a.", true);

        return executeFilteredPagedQuery(
                sql.toString(), params, offset, pageSize);
    }

    public List<Alert> getFilteredByUserPaged(
            String userID, String searchId, String alertType,
            String status, String sortBy, String order,
            int offset, int pageSize) {

        StringBuilder sql = new StringBuilder(FILTER_USER_BASE);
        List<Object> params = new ArrayList<Object>();
        params.add(userID);

        appendFilter(sql, params, searchId, alertType, status, "a.");

        appendOrderByPaged(sql, sortBy, order, "a.", true);

        return executeFilteredPagedQuery(
                sql.toString(), params, offset, pageSize);
    }

    // ==================== FILTERED COUNTS ====================

    public int countFiltered(
            String searchId, String alertType, String status) {

        StringBuilder sql = new StringBuilder(COUNT_FILTER_BASE);
        List<Object> params = new ArrayList<Object>();

        appendFilter(sql, params, searchId, alertType, status, "");

        return executeCountQuery(sql.toString(), params);
    }

    public int countFilteredByManager(
            String managerID, String searchId,
            String alertType, String status) {

        StringBuilder sql = new StringBuilder(COUNT_MANAGER_BASE);
        List<Object> params = new ArrayList<Object>();
        params.add(managerID);

        appendFilter(sql, params, searchId, alertType, status, "a.");

        return executeCountQuery(sql.toString(), params);
    }

    public int countFilteredByRecipient(
            String userID, String searchId,
            String alertType, String status) {

        StringBuilder sql = new StringBuilder(COUNT_RECIPIENT_BASE);
        List<Object> params = new ArrayList<Object>();
        params.add(userID);

        appendFilter(sql, params, searchId, alertType, status, "a.");

        return executeCountQuery(sql.toString(), params);
    }

    public int countFilteredByUser(
            String userID, String searchId,
            String alertType, String status) {

        StringBuilder sql = new StringBuilder(COUNT_USER_BASE);
        List<Object> params = new ArrayList<Object>();
        params.add(userID);

        appendFilter(sql, params, searchId, alertType, status, "a.");

        return executeCountQuery(sql.toString(), params);
    }

    // ==================== HELPER METHODS ====================

    private void appendFilter(
            StringBuilder sql,
            List<Object> params,
            String searchId,
            String alertType,
            String status,
            String prefix) {

        if (!isBlank(searchId)) {
            sql.append("AND (")
                    .append(prefix).append("alertID LIKE ? OR ")
                    .append(prefix).append("binID LIKE ?) ");

            String keyword = "%" + searchId.trim() + "%";
            params.add(keyword);
            params.add(keyword);
        }

        if (!isBlank(alertType)) {
            sql.append("AND ")
                    .append(prefix).append("alertType = ? ");

            params.add(alertType.trim());
        }

        if ("Resolved".equalsIgnoreCase(status)) {
            sql.append("AND ")
                    .append(prefix).append("isResolved = 1 ");
        } else if ("Unresolved".equalsIgnoreCase(status)) {
            sql.append("AND ")
                    .append(prefix).append("isResolved = 0 ");
        }
    }

    private void appendOrderBy(
            StringBuilder sql,
            String sortBy,
            String order,
            String prefix) {

        sql.append("ORDER BY ")
                .append(getSortColumn(sortBy, prefix))
                .append(" ")
                .append(getSortOrder(order));
    }

    private void appendOrderByPaged(
            StringBuilder sql,
            String sortBy,
            String order,
            String prefix,
            boolean alias) {

        sql.append("ORDER BY ")
                .append(getSortColumn(sortBy, prefix))
                .append(" ")
                .append(getSortOrder(order));

        if (alias) {
            sql.append(", a.alertID ASC ");
        } else {
            sql.append(", alertID ASC ");
        }

        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
    }

    private String getSortColumn(String sortBy, String prefix) {
        if ("alertType".equalsIgnoreCase(sortBy)) {
            return prefix + "alertType";
        }

        if ("status".equalsIgnoreCase(sortBy)) {
            return prefix + "isResolved";
        }

        return prefix + "createdDate";
    }

    private String getSortOrder(String order) {
        return "ASC".equalsIgnoreCase(order) ? "ASC" : "DESC";
    }

    private Alert map(ResultSet rs) throws Exception {
        Alert alert = new Alert();

        alert.setAlertID(rs.getString("alertID"));
        alert.setBinID(rs.getString("binID"));
        alert.setAlertType(rs.getString("alertType"));
        alert.setMessage(rs.getString("message"));
        alert.setCreatedDate(rs.getTimestamp("createdDate"));
        alert.setResolved(rs.getBoolean("isResolved"));

        return alert;
    }

    private List<Alert> executeFilteredQuery(
            String sql, List<Object> params) {

        List<Alert> list = new ArrayList<Alert>();

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();

            if (conn == null) {
                return list;
            }

            ptm = conn.prepareStatement(sql);
            bindParameters(ptm, params, 1);

            rs = ptm.executeQuery();

            while (rs.next()) {
                list.add(map(rs));
            }

        } catch (Exception e) {
            System.err.println("Error executing alert query.");
            System.err.println("SQL: " + sql);
            e.printStackTrace();

        } finally {
            DBContext.close(rs, ptm, conn);
        }

        return list;
    }

    private List<Alert> executeFilteredPagedQuery(
            String sql,
            List<Object> params,
            int offset,
            int pageSize) {

        List<Alert> list = new ArrayList<Alert>();

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();

            if (conn == null) {
                return list;
            }

            ptm = conn.prepareStatement(sql);

            int index = bindParameters(ptm, params, 1);

            ptm.setInt(index++, Math.max(0, offset));
            ptm.setInt(index, Math.max(1, pageSize));

            rs = ptm.executeQuery();

            while (rs.next()) {
                list.add(map(rs));
            }

        } catch (Exception e) {
            System.err.println("Error executing paginated alert query.");
            System.err.println("SQL: " + sql);
            e.printStackTrace();

        } finally {
            DBContext.close(rs, ptm, conn);
        }

        return list;
    }

    private int executeCountQuery(
            String sql, List<Object> params) {

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();

            if (conn == null) {
                return 0;
            }

            ptm = conn.prepareStatement(sql);
            bindParameters(ptm, params, 1);

            rs = ptm.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (Exception e) {
            System.err.println("Error executing alert count query.");
            System.err.println("SQL: " + sql);
            e.printStackTrace();

        } finally {
            DBContext.close(rs, ptm, conn);
        }

        return 0;
    }

    private int bindParameters(
            PreparedStatement ptm,
            List<Object> params,
            int startIndex) throws Exception {

        int index = startIndex;

        for (Object param : params) {
            ptm.setObject(index++, param);
        }

        return index;
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}