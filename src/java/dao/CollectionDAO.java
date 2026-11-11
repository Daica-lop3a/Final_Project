package dao;

import model.CollectionRequest;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class CollectionDAO {

    private static final String SELECT_COLUMNS =
            "SELECT requestID, binID, supervisorID, staffID, status, "
            + "priority, createdDate, completedDate, notes, "
            + "startedDate, photoBefore, photoAfter, failureReason "
            + "FROM tblCollectionRequests ";

    private static final String GET_ALL =
            SELECT_COLUMNS + "ORDER BY createdDate DESC";

    private static final String GET_BY_ID =
            SELECT_COLUMNS + "WHERE requestID = ?";

    private static final String GET_BY_STAFF =
            SELECT_COLUMNS
            + "WHERE staffID = ? "
            + "ORDER BY createdDate DESC";

    private static final String INSERT =
            "INSERT INTO tblCollectionRequests "
            + "(requestID, binID, staffID, status, "
            + "priority, createdDate, notes) "
            + "VALUES (?, ?, ?, ?, ?, ?, ?)";

    private static final String UPDATE =
            "UPDATE tblCollectionRequests "
            + "SET binID = ?, staffID = ?, status = ?, "
            + "priority = ?, notes = ?, "
            + "startedDate = ?, completedDate = ?, photoBefore = ?, photoAfter = ?, failureReason = ? "
            + "WHERE requestID = ?";

    private static final String DELETE =
            "DELETE FROM tblCollectionRequests "
            + "WHERE requestID = ?";

    private static final String COUNT_ALL =
            "SELECT COUNT(*) FROM tblCollectionRequests";

    private static final String COUNT_BY_STATUS =
            "SELECT COUNT(*) FROM tblCollectionRequests "
            + "WHERE status = ?";

    private static final String MANAGER_CONDITION =
            "b.areaID IN ("
            + "SELECT COALESCE(ua.areaID, u.areaID) "
            + "FROM dbo.tblUsers u "
            + "LEFT JOIN dbo.tblUserAreas ua ON u.userID = ua.userID "
            + "WHERE u.userID = ? AND u.roleID IN ('MGR', 'SUP') "
            + "AND (u.areaID IS NOT NULL OR ua.areaID IS NOT NULL)) ";

    // =========================================================
    // GET ALL
    // =========================================================
    public List<CollectionRequest> getAll()
            throws SQLException, ClassNotFoundException {

        List<CollectionRequest> list = new ArrayList<>();

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();

            if (conn != null) {
                ptm = conn.prepareStatement(GET_ALL);
                rs = ptm.executeQuery();

                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        } finally {
            closeResources(rs, ptm, conn);
        }

        return list;
    }

    // =========================================================
    // GET BY ID
    // =========================================================
    public CollectionRequest findByID(String requestID)
            throws SQLException, ClassNotFoundException {

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;
        CollectionRequest request = null;

        try {
            conn = DBContext.getConnection();

            if (conn != null) {
                ptm = conn.prepareStatement(GET_BY_ID);
                ptm.setString(1, requestID);

                rs = ptm.executeQuery();

                if (rs.next()) {
                    request = map(rs);
                }
            }
        } finally {
            closeResources(rs, ptm, conn);
        }

        return request;
    }

    // =========================================================
    // GET BY STAFF
    // =========================================================
    public List<CollectionRequest> getByStaff(String staffID)
            throws SQLException, ClassNotFoundException {

        List<CollectionRequest> list = new ArrayList<>();

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();

            if (conn != null) {
                ptm = conn.prepareStatement(GET_BY_STAFF);
                ptm.setString(1, staffID);

                rs = ptm.executeQuery();

                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        } finally {
            closeResources(rs, ptm, conn);
        }

        return list;
    }

    // =========================================================
    // INSERT
    // =========================================================
    public boolean insert(CollectionRequest request)
            throws SQLException, ClassNotFoundException {

        Connection conn = null;
        PreparedStatement ptm = null;
        boolean check = false;

        try {
            conn = DBContext.getConnection();

            if (conn != null) {
                ptm = conn.prepareStatement(INSERT);

                ptm.setString(1, request.getRequestID());
                ptm.setString(2, request.getBinID());
                ptm.setString(3, request.getStaffID());
                ptm.setString(4, request.getStatus());
                ptm.setString(5, request.getPriority());
                ptm.setTimestamp(6, request.getCreatedDate());
                ptm.setString(7, request.getNotes());

                check = ptm.executeUpdate() > 0;
            }
        } finally {
            closeResources(null, ptm, conn);
        }

        return check;
    }

    // =========================================================
    // UPDATE
    // =========================================================
    public boolean update(CollectionRequest request)
            throws SQLException, ClassNotFoundException {

        Connection conn = null;
        PreparedStatement ptm = null;
        boolean check = false;

        try {
            conn = DBContext.getConnection();

            if (conn != null) {
                ptm = conn.prepareStatement(UPDATE);

                ptm.setString(1, request.getBinID());
                ptm.setString(2, request.getStaffID());
                ptm.setString(3, request.getStatus());
                ptm.setString(4, request.getPriority());
                ptm.setString(5, request.getNotes());
                ptm.setTimestamp(6, request.getStartedDate());
                ptm.setTimestamp(7, request.getCompletedDate());
                ptm.setString(8, request.getPhotoBefore());
                ptm.setString(9, request.getPhotoAfter());
                ptm.setString(10, request.getFailureReason());
                ptm.setString(11, request.getRequestID());

                check = ptm.executeUpdate() > 0;
            }
        } finally {
            closeResources(null, ptm, conn);
        }

        return check;
    }

    // =========================================================
    // DELETE
    // =========================================================
    public boolean delete(String requestID)
            throws SQLException, ClassNotFoundException {

        Connection conn = null;
        PreparedStatement ptm = null;
        boolean check = false;

        try {
            conn = DBContext.getConnection();

            if (conn != null) {
                ptm = conn.prepareStatement(DELETE);
                ptm.setString(1, requestID);

                check = ptm.executeUpdate() > 0;
            }
        } finally {
            closeResources(null, ptm, conn);
        }

        return check;
    }

    // =========================================================
    // COUNT ALL
    // =========================================================
    public int countAll()
            throws SQLException, ClassNotFoundException {

        return executeCount(COUNT_ALL, new ArrayList<>());
    }

    // =========================================================
    // COUNT BY STATUS
    // =========================================================
    public int countByStatus(String status)
            throws SQLException, ClassNotFoundException {

        List<String> params = new ArrayList<>();
        params.add(status);

        return executeCount(COUNT_BY_STATUS, params);
    }

    public boolean hasActiveRequestForBin(String binID) {
        if (binID == null || binID.trim().isEmpty()) return false;
        String sql = "SELECT COUNT(*) FROM tblCollectionRequests WHERE binID = ? AND status IN ('Pending', 'In_Progress')";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, binID.trim());
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return false;
    }

    public boolean verifyRequest(String requestID, String supervisorID, String notes) {
        if (requestID == null || requestID.trim().isEmpty()) return false;
        String sql = "UPDATE tblCollectionRequests SET status = 'Verified', supervisorID = ?, notes = ? WHERE requestID = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, supervisorID);
            ps.setString(2, notes);
            ps.setString(3, requestID.trim());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            DBContext.close(null, ps, conn);
        }
    }

    public boolean failRequest(String requestID, String failureReason) {
        if (requestID == null || requestID.trim().isEmpty()) return false;
        String sql = "UPDATE tblCollectionRequests SET status = 'Failed', notes = ? WHERE requestID = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, failureReason);
            ps.setString(2, requestID.trim());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            DBContext.close(null, ps, conn);
        }
    }

    public boolean startTask(String requestID) {
        if (requestID == null || requestID.trim().isEmpty()) return false;
        String sql = "UPDATE tblCollectionRequests SET status = 'In_Progress', "
                + "startedDate = COALESCE(startedDate, GETDATE()) WHERE requestID = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, requestID.trim());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            DBContext.close(null, ps, conn);
        }
    }

    public boolean completeTaskWithDetails(String requestID, String notes, String photoBefore, String photoAfter) {
        if (requestID == null || requestID.trim().isEmpty()) return false;
        String sql = "UPDATE tblCollectionRequests SET status = 'Completed', "
                + "completedDate = GETDATE(), notes = ?, photoBefore = ?, photoAfter = ? WHERE requestID = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, notes);
            ps.setString(2, photoBefore);
            ps.setString(3, photoAfter);
            ps.setString(4, requestID.trim());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            DBContext.close(null, ps, conn);
        }
    }

    public boolean failTaskWithReason(String requestID, String failureReason, String notes, String photoBefore) {
        if (requestID == null || requestID.trim().isEmpty()) return false;
        String sql = "UPDATE tblCollectionRequests SET status = 'Failed', "
                + "completedDate = GETDATE(), failureReason = ?, notes = ?, photoBefore = ? WHERE requestID = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, failureReason);
            ps.setString(2, notes);
            ps.setString(3, photoBefore);
            ps.setString(4, requestID.trim());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            DBContext.close(null, ps, conn);
        }
    }

    public boolean skipTaskWithReason(String requestID, String failureReason, String notes) {
        if (requestID == null || requestID.trim().isEmpty()) return false;
        String sql = "UPDATE tblCollectionRequests SET status = 'Skipped', "
                + "completedDate = GETDATE(), failureReason = ?, notes = ? WHERE requestID = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, failureReason);
            ps.setString(2, notes);
            ps.setString(3, requestID.trim());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            DBContext.close(null, ps, conn);
        }
    }

    public boolean isRecentlyCollected(String binID, int withinMinutes) {
        if (binID == null || binID.trim().isEmpty()) return false;
        String sql = "SELECT COUNT(*) FROM tblCollectionRequests "
                + "WHERE binID = ? AND status IN ('Completed', 'Verified') "
                + "AND completedDate >= DATEADD(minute, -?, GETDATE())";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, binID.trim());
            ps.setInt(2, withinMinutes);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return false;
    }

    public int countOverdue(List<String> areaIds) {
        if (areaIds == null || areaIds.isEmpty()) return 0;
        StringBuilder in = new StringBuilder();
        for (int i = 0; i < areaIds.size(); i++) {
            if (i > 0) in.append(",");
            in.append("?");
        }
        String sql = "SELECT COUNT(*) FROM tblCollectionRequests r "
                + "INNER JOIN tblWasteBins b ON r.binID = b.binID "
                + "WHERE b.areaID IN (" + in + ") "
                + "AND r.status IN ('Pending', 'In_Progress') "
                + "AND DATEDIFF(hour, r.createdDate, GETDATE()) >= 4";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            for (int i = 0; i < areaIds.size(); i++) {
                ps.setString(i + 1, areaIds.get(i));
            }
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return 0;
    }

    // =========================================================
    // GET BY MANAGER
        // Restrict collections to manager assigned area.
    // =========================================================
    public List<CollectionRequest> getByManager(String managerID)
            throws SQLException, ClassNotFoundException {

        String sql =
                "SELECT r.requestID, r.binID, r.staffID, "
                + "r.status, r.priority, r.createdDate, r.notes "
                + "FROM tblCollectionRequests r "
                + "INNER JOIN tblWasteBins b ON b.binID = r.binID "
                + "WHERE " + MANAGER_CONDITION
                + "ORDER BY r.createdDate DESC";

        List<String> params = new ArrayList<>();
        params.add(managerID);

        return executeListQuery(sql, params);
    }

    // =========================================================
    // FILTER: ADMIN
    // =========================================================
    public List<CollectionRequest> getFiltered(
            String searchId,
            String staffID,
            String sortBy,
            String order)
            throws SQLException, ClassNotFoundException {

        StringBuilder sql = new StringBuilder(SELECT_COLUMNS);
        sql.append("WHERE 1 = 1 ");

        List<String> params = new ArrayList<>();

        appendSearchCondition(sql, params, "", searchId);

        if (hasText(staffID)) {
            sql.append("AND staffID LIKE ? ");
            params.add("%" + staffID.trim() + "%");
        }

        sql.append("ORDER BY ");
        sql.append(getSortColumn(sortBy, ""));
        sql.append(" ");
        sql.append(getSortOrder(order));

        return executeListQuery(sql.toString(), params);
    }

    // =========================================================
    // FILTER: MANAGER
    // =========================================================
    public List<CollectionRequest> getFilteredByManager(
            String managerID,
            String searchId,
            String staffID,
            String sortBy,
            String order)
            throws SQLException, ClassNotFoundException {

        StringBuilder sql = new StringBuilder();

        sql.append("SELECT r.requestID, r.binID, r.staffID, ");
        sql.append("r.status, r.priority, r.createdDate, r.notes ");
        sql.append("FROM tblCollectionRequests r ");
        sql.append("INNER JOIN tblWasteBins b ON b.binID = r.binID ");
        sql.append("WHERE ");
        sql.append(MANAGER_CONDITION);

        List<String> params = new ArrayList<>();
        params.add(managerID);

        appendSearchCondition(sql, params, "r.", searchId);

        if (hasText(staffID)) {
            sql.append("AND r.staffID LIKE ? ");
            params.add("%" + staffID.trim() + "%");
        }

        sql.append("ORDER BY ");
        sql.append(getSortColumn(sortBy, "r."));
        sql.append(" ");
        sql.append(getSortOrder(order));

        return executeListQuery(sql.toString(), params);
    }

    // =========================================================
    // FILTER: STAFF
    // =========================================================
    public List<CollectionRequest> getFilteredByStaff(
            String staffID,
            String searchId,
            String sortBy,
            String order)
            throws SQLException, ClassNotFoundException {

        StringBuilder sql = new StringBuilder(SELECT_COLUMNS);
        sql.append("WHERE staffID = ? ");

        List<String> params = new ArrayList<>();
        params.add(staffID);

        appendSearchCondition(sql, params, "", searchId);

        sql.append("ORDER BY ");
        sql.append(getSortColumn(sortBy, ""));
        sql.append(" ");
        sql.append(getSortOrder(order));

        return executeListQuery(sql.toString(), params);
    }

    // =========================================================
    // PAGINATION: ADMIN
    // =========================================================
    public List<CollectionRequest> getFilteredPaged(
            String searchId,
            String staffID,
            String sortBy,
            String order,
            int offset,
            int pageSize)
            throws SQLException, ClassNotFoundException {

        StringBuilder sql = new StringBuilder(SELECT_COLUMNS);
        sql.append("WHERE 1 = 1 ");

        List<String> params = new ArrayList<>();

        appendSearchCondition(sql, params, "", searchId);

        if (hasText(staffID)) {
            sql.append("AND staffID LIKE ? ");
            params.add("%" + staffID.trim() + "%");
        }

        sql.append("ORDER BY ");
        sql.append(getSortColumn(sortBy, ""));
        sql.append(" ");
        sql.append(getSortOrder(order));
        sql.append(", requestID ASC ");
        appendPagination(sql);

        return executePagedQuery(
                sql.toString(), params, offset, pageSize);
    }

    // =========================================================
    // PAGINATION: MANAGER
    // =========================================================
    public List<CollectionRequest> getFilteredByManagerPaged(
            String managerID,
            String searchId,
            String staffID,
            String sortBy,
            String order,
            int offset,
            int pageSize)
            throws SQLException, ClassNotFoundException {

        StringBuilder sql = new StringBuilder();

        sql.append("SELECT r.requestID, r.binID, r.staffID, ");
        sql.append("r.status, r.priority, r.createdDate, r.notes ");
        sql.append("FROM tblCollectionRequests r ");
        sql.append("INNER JOIN tblWasteBins b ON b.binID = r.binID ");
        sql.append("WHERE ");
        sql.append(MANAGER_CONDITION);

        List<String> params = new ArrayList<>();
        params.add(managerID);

        appendSearchCondition(sql, params, "r.", searchId);

        if (hasText(staffID)) {
            sql.append("AND r.staffID LIKE ? ");
            params.add("%" + staffID.trim() + "%");
        }

        sql.append("ORDER BY ");
        sql.append(getSortColumn(sortBy, "r."));
        sql.append(" ");
        sql.append(getSortOrder(order));
        sql.append(", r.requestID ASC ");
        appendPagination(sql);

        return executePagedQuery(
                sql.toString(), params, offset, pageSize);
    }

    // =========================================================
    // PAGINATION: STAFF
    // =========================================================
    public List<CollectionRequest> getFilteredByStaffPaged(
            String staffID,
            String searchId,
            String sortBy,
            String order,
            int offset,
            int pageSize)
            throws SQLException, ClassNotFoundException {

        StringBuilder sql = new StringBuilder(SELECT_COLUMNS);
        sql.append("WHERE staffID = ? ");

        List<String> params = new ArrayList<>();
        params.add(staffID);

        appendSearchCondition(sql, params, "", searchId);

        sql.append("ORDER BY ");
        sql.append(getSortColumn(sortBy, ""));
        sql.append(" ");
        sql.append(getSortOrder(order));
        sql.append(", requestID ASC ");
        appendPagination(sql);

        return executePagedQuery(
                sql.toString(), params, offset, pageSize);
    }

    // =========================================================
    // COUNT FILTERED: ADMIN
    // =========================================================
    public int countFiltered(String searchId, String staffID)
            throws SQLException, ClassNotFoundException {

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) ");
        sql.append("FROM tblCollectionRequests ");
        sql.append("WHERE 1 = 1 ");

        List<String> params = new ArrayList<>();

        appendSearchCondition(sql, params, "", searchId);

        if (hasText(staffID)) {
            sql.append("AND staffID LIKE ? ");
            params.add("%" + staffID.trim() + "%");
        }

        return executeCount(sql.toString(), params);
    }

    // =========================================================
    // COUNT FILTERED: MANAGER
    // =========================================================
    public int countFilteredByManager(
            String managerID,
            String searchId,
            String staffID)
            throws SQLException, ClassNotFoundException {

        StringBuilder sql = new StringBuilder();

        sql.append("SELECT COUNT(*) ");
        sql.append("FROM tblCollectionRequests r ");
        sql.append("INNER JOIN tblWasteBins b ON b.binID = r.binID ");
        sql.append("WHERE ");
        sql.append(MANAGER_CONDITION);

        List<String> params = new ArrayList<>();
        params.add(managerID);

        appendSearchCondition(sql, params, "r.", searchId);

        if (hasText(staffID)) {
            sql.append("AND r.staffID LIKE ? ");
            params.add("%" + staffID.trim() + "%");
        }

        return executeCount(sql.toString(), params);
    }

    // =========================================================
    // COUNT FILTERED: STAFF
    // =========================================================
    public int countFilteredByStaff(
            String staffID,
            String searchId)
            throws SQLException, ClassNotFoundException {

        StringBuilder sql = new StringBuilder();

        sql.append("SELECT COUNT(*) ");
        sql.append("FROM tblCollectionRequests ");
        sql.append("WHERE staffID = ? ");

        List<String> params = new ArrayList<>();
        params.add(staffID);

        appendSearchCondition(sql, params, "", searchId);

        return executeCount(sql.toString(), params);
    }

    // =========================================================
    // EXECUTE LIST QUERY
    // =========================================================
    private List<CollectionRequest> executeListQuery(
            String sql,
            List<String> params)
            throws SQLException, ClassNotFoundException {

        List<CollectionRequest> list = new ArrayList<>();

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();

            if (conn != null) {
                ptm = conn.prepareStatement(sql);
                setStringParameters(ptm, params);

                rs = ptm.executeQuery();

                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        } finally {
            closeResources(rs, ptm, conn);
        }

        return list;
    }

    // =========================================================
    // EXECUTE PAGED QUERY
    // =========================================================
    private List<CollectionRequest> executePagedQuery(
            String sql,
            List<String> params,
            int offset,
            int pageSize)
            throws SQLException, ClassNotFoundException {

        List<CollectionRequest> list = new ArrayList<>();

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();

            if (conn != null) {
                ptm = conn.prepareStatement(sql);
                setStringParameters(ptm, params);

                int index = params.size() + 1;

                ptm.setInt(index++, Math.max(0, offset));
                ptm.setInt(index, Math.max(1, pageSize));

                rs = ptm.executeQuery();

                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        } finally {
            closeResources(rs, ptm, conn);
        }

        return list;
    }

    // =========================================================
    // EXECUTE COUNT QUERY
    // =========================================================
    private int executeCount(
            String sql,
            List<String> params)
            throws SQLException, ClassNotFoundException {

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;
        int count = 0;

        try {
            conn = DBContext.getConnection();

            if (conn != null) {
                ptm = conn.prepareStatement(sql);
                setStringParameters(ptm, params);

                rs = ptm.executeQuery();

                if (rs.next()) {
                    count = rs.getInt(1);
                }
            }
        } finally {
            closeResources(rs, ptm, conn);
        }

        return count;
    }

    // =========================================================
    // SET STRING PARAMETERS
    // =========================================================
    private void setStringParameters(
            PreparedStatement ptm,
            List<String> params)
            throws SQLException {

        for (int i = 0; i < params.size(); i++) {
            ptm.setString(i + 1, params.get(i));
        }
    }

    // =========================================================
    // APPEND SEARCH CONDITION
    // =========================================================
    private void appendSearchCondition(
            StringBuilder sql,
            List<String> params,
            String prefix,
            String searchId) {

        if (hasText(searchId)) {
            sql.append("AND (");
            sql.append(prefix).append("requestID LIKE ? OR ");
            sql.append(prefix).append("binID LIKE ?) ");

            String value = "%" + searchId.trim() + "%";

            params.add(value);
            params.add(value);
        }
    }

    // =========================================================
    // PAGINATION SQL
    // =========================================================
    private void appendPagination(StringBuilder sql) {
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
    }

    // =========================================================
    // SORT COLUMN WHITELIST
    // =========================================================
    private String getSortColumn(String sortBy, String prefix) {

        if ("status".equals(sortBy)) {
            return prefix + "status";
        }

        if ("priority".equals(sortBy)) {
            return prefix + "priority";
        }

        return prefix + "createdDate";
    }

    // =========================================================
    // SORT ORDER WHITELIST
    // =========================================================
    private String getSortOrder(String order) {

        if ("ASC".equalsIgnoreCase(order)) {
            return "ASC";
        }

        return "DESC";
    }

    // =========================================================
    // MAP RESULTSET -> OBJECT
    // =========================================================
    private CollectionRequest map(ResultSet rs)
            throws SQLException {

        CollectionRequest request = new CollectionRequest();

        request.setRequestID(rs.getString("requestID"));
        request.setBinID(rs.getString("binID"));
        request.setStaffID(rs.getString("staffID"));
        request.setStatus(rs.getString("status"));
        request.setPriority(rs.getString("priority"));
        request.setCreatedDate(rs.getTimestamp("createdDate"));
        request.setNotes(rs.getString("notes"));
        request.setSupervisorID(safeGetString(rs, "supervisorID"));
        request.setStartedDate(safeGetTimestamp(rs, "startedDate"));
        request.setCompletedDate(safeGetTimestamp(rs, "completedDate"));
        request.setPhotoBefore(safeGetString(rs, "photoBefore"));
        request.setPhotoAfter(safeGetString(rs, "photoAfter"));
        request.setFailureReason(safeGetString(rs, "failureReason"));

        return request;
    }

    private String safeGetString(ResultSet rs, String col) {
        try {
            return rs.getString(col);
        } catch (SQLException ignored) {
            return null;
        }
    }

    private java.sql.Timestamp safeGetTimestamp(ResultSet rs, String col) {
        try {
            return rs.getTimestamp(col);
        } catch (SQLException ignored) {
            return null;
        }
    }

    // =========================================================
    // CHECK NON-EMPTY STRING
    // =========================================================
    private boolean hasText(String value) {
        return value != null && !value.trim().isEmpty();
    }

    // =========================================================
    // CLOSE JDBC RESOURCES
        // Close resources in reverse order of opening.
    // =========================================================
    private void closeResources(
            ResultSet rs,
            PreparedStatement ptm,
            Connection conn)
            throws SQLException {

        SQLException exception = null;

        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) {
                exception = e;
            }
        }

        if (ptm != null) {
            try {
                ptm.close();
            } catch (SQLException e) {
                if (exception == null) {
                    exception = e;
                }
            }
        }

        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                if (exception == null) {
                    exception = e;
                }
            }
        }

        if (exception != null) {
            throw exception;
        }
    }
}
