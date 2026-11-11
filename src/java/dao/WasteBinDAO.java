package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import model.WasteBin;

public class WasteBinDAO {

    private static final String DISPLAY_STATUS
            = "CASE "
            + "WHEN status = 'Maintenance' THEN 'Maintenance' "
            + "WHEN currentFill >= 80 THEN 'Full' "
            + "ELSE 'Active' END";

    private static final String BIN_NUMBER_SORT
            = "TRY_CONVERT(INT, SUBSTRING(binID, 4, LEN(binID)))";

    private static final String SELECT_COLUMNS
            = "SELECT binID, binCode, location, latitude, longitude, capacity, "
            + "currentFill, " + DISPLAY_STATUS + " AS status, "
            + "areaID, lastEmptied, lastUpdated, "
            + "(SELECT areaName FROM dbo.tblAreas WHERE areaID = dbo.tblWasteBins.areaID) AS areaName "
            + "FROM dbo.tblWasteBins ";

    private static final String COUNT_ALL
            = "SELECT COUNT(*) FROM dbo.tblWasteBins";

    private static final String INSERT
            = "INSERT INTO dbo.tblWasteBins "
            + "(binID, binCode, location, latitude, longitude, capacity, "
            + "currentFill, status, areaID, lastUpdated) "
            + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";

    private static final String UPDATE
            = "UPDATE dbo.tblWasteBins "
            + "SET binCode = ?, location = ?, latitude = ?, longitude = ?, "
            + "capacity = ?, areaID = ?, lastUpdated = GETDATE() "
            + "WHERE binID = ?";

    private static final String DELETE
            = "DELETE FROM dbo.tblWasteBins WHERE binID = ?";

    private static final String UPDATE_CURRENT_FILL
            = "UPDATE dbo.tblWasteBins "
            + "SET currentFill = ?, "
            + "status = CASE "
            + "WHEN status = 'Maintenance' THEN 'Maintenance' "
            + "WHEN ? >= 80 THEN 'Full' "
            + "ELSE 'Active' END "
            + "WHERE binID = ?";

    private static final String FILTERED_COUNTS
            = "SELECT COUNT(*) AS totalRecords, "
            + "COALESCE(SUM(CASE WHEN "
            + DISPLAY_STATUS
            + " = 'Active' THEN 1 ELSE 0 END), 0) AS activeCount, "
            + "COALESCE(SUM(CASE WHEN currentFill >= 80 "
            + "THEN 1 ELSE 0 END), 0) AS highFillCount "
            + "FROM dbo.tblWasteBins WHERE 1 = 1 ";

    // =========================================================
    // MAP RESULT SET TO WASTEBIN
    // =========================================================
    private WasteBin mapWasteBin(ResultSet rs) throws Exception {

        WasteBin bin = new WasteBin();

        bin.setBinID(rs.getString("binID"));
        bin.setBinCode(rs.getString("binCode"));
        bin.setLocation(rs.getString("location"));
        bin.setLatitude(rs.getDouble("latitude"));
        bin.setLongitude(rs.getDouble("longitude"));
        bin.setCapacity(rs.getDouble("capacity"));
        bin.setCurrentFill(rs.getDouble("currentFill"));
        bin.setStatus(rs.getString("status"));
        bin.setAreaID(rs.getString("areaID"));
        try {
            bin.setLastEmptied(rs.getTimestamp("lastEmptied"));
            bin.setLastUpdated(rs.getTimestamp("lastUpdated"));
            bin.setAreaName(rs.getString("areaName"));
        } catch (Exception ignored) {
        }

        return bin;
    }

    // =========================================================
    // GET ORDER BY
    // =========================================================
    private String getOrderBy(String sort, String order) {

        String orderBy;

        if ("binCode".equals(sort)) {
            orderBy = "binCode";
        } else if ("capacity".equals(sort)) {
            orderBy = "capacity";
        } else if ("currentFill".equals(sort)) {
            orderBy = "currentFill";
        } else {
            orderBy = BIN_NUMBER_SORT;
        }

        String direction = "DESC".equalsIgnoreCase(order)
                ? "DESC" : "ASC";

        if ("binCode".equals(sort)
                || "capacity".equals(sort)
                || "currentFill".equals(sort)) {
            return orderBy + " " + direction
                    + ", " + BIN_NUMBER_SORT + " ASC";
        }

        return orderBy + " " + direction + ", binID ASC";
    }

    // =========================================================
    // GET ALL
    // =========================================================
    public List<WasteBin> getAll() {

        List<WasteBin> list = new ArrayList<WasteBin>();

        String sql = SELECT_COLUMNS
                + "ORDER BY " + BIN_NUMBER_SORT + " ASC, binID ASC";

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(sql);
            rs = ptm.executeQuery();

            while (rs.next()) {
                list.add(mapWasteBin(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ptm, conn);
        }

        return list;
    }


    // =========================================================
    // GET BINS BY DATE RANGE
    // =========================================================
    public List<WasteBin> getBinsByDateRange(Timestamp from, Timestamp to) {
        List<WasteBin> list = new ArrayList<WasteBin>();
        StringBuilder sql = new StringBuilder(SELECT_COLUMNS);
        sql.append("WHERE 1 = 1 ");

        if (from != null) {
            sql.append("AND (lastUpdated >= ? OR lastEmptied >= ?) ");
        }
        if (to != null) {
            sql.append("AND (lastUpdated <= ? OR lastEmptied <= ?) ");
        }

        sql.append("ORDER BY " + BIN_NUMBER_SORT + " ASC, binID ASC");

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(sql.toString());
            int idx = 1;
            if (from != null) {
                ptm.setTimestamp(idx++, from);
                ptm.setTimestamp(idx++, from);
            }
            if (to != null) {
                ptm.setTimestamp(idx++, to);
                ptm.setTimestamp(idx++, to);
            }
            rs = ptm.executeQuery();
            while (rs.next()) {
                list.add(mapWasteBin(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ptm, conn);
        }
        return list;
    }

    // =========================================================
    // COUNT ALL
    // =========================================================
    public int countAll() {

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(COUNT_ALL);
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

    // =========================================================
    // COUNT BY STATUS
    // =========================================================
    public int countByStatus(String status) {

        String sql = "SELECT COUNT(*) FROM dbo.tblWasteBins "
                + "WHERE " + DISPLAY_STATUS + " = ?";

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(sql);
            ptm.setString(1, status);

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

    // =========================================================
    // FIND BY ID
    // =========================================================
    public WasteBin findByID(String binID) {

        String sql = SELECT_COLUMNS + "WHERE binID = ?";

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(sql);
            ptm.setString(1, binID);

            rs = ptm.executeQuery();

            if (rs.next()) {
                return mapWasteBin(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ptm, conn);
        }

        return null;
    }

    public WasteBin findByCode(String binCode) {
        if (binCode == null || binCode.trim().isEmpty()) {
            return null;
        }

        String sql = SELECT_COLUMNS + "WHERE binCode = ?";

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(sql);
            ptm.setString(1, binCode.trim());

            rs = ptm.executeQuery();

            if (rs.next()) {
                return mapWasteBin(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ptm, conn);
        }

        return null;
    }

    // =========================================================
    // INSERT
    // =========================================================
    public boolean insert(WasteBin bin) {

        if (bin == null) {
            return false;
        }

        Connection conn = null;
        PreparedStatement ptm = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(INSERT);

            ptm.setString(1, bin.getBinID());
            ptm.setString(2, bin.getBinCode());
            ptm.setString(3, bin.getLocation());
            ptm.setDouble(4, bin.getLatitude());
            ptm.setDouble(5, bin.getLongitude());
            ptm.setDouble(6, bin.getCapacity());

            double fill = bin.getCurrentFill();
            ptm.setDouble(7, fill);

            String status = "Maintenance".equalsIgnoreCase(bin.getStatus())
                    ? "Maintenance"
                    : (fill >= 80 ? "Full" : "Active");

            ptm.setString(8, status);
            ptm.setString(9, bin.getAreaID());

            return ptm.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(ptm, conn);
        }

        return false;
    }

    // =========================================================
    // UPDATE BIN INFORMATION
    // Does not change currentFill or status.
    // =========================================================
    public boolean update(WasteBin bin) {

        if (bin == null) {
            return false;
        }

        Connection conn = null;
        PreparedStatement ptm = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(UPDATE);

            ptm.setString(1, bin.getBinCode());
            ptm.setString(2, bin.getLocation());
            ptm.setDouble(3, bin.getLatitude());
            ptm.setDouble(4, bin.getLongitude());
            ptm.setDouble(5, bin.getCapacity());
            ptm.setString(6, bin.getAreaID());
            ptm.setString(7, bin.getBinID());

            return ptm.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(ptm, conn);
        }

        return false;
    }

    // =========================================================
    // DELETE
    // =========================================================
    public boolean delete(String binID) {

        Connection conn = null;
        PreparedStatement ptm = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(DELETE);
            ptm.setString(1, binID);

            return ptm.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(ptm, conn);
        }

        return false;
    }

    // =========================================================
    // UPDATE CURRENT FILL
    // =========================================================
    public boolean updateCurrentFill(String binID, int currentFill) {

        if (currentFill < 0 || currentFill > 100) {
            return false;
        }

        Connection conn = null;
        PreparedStatement ptm = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(UPDATE_CURRENT_FILL);

            ptm.setInt(1, currentFill);
            ptm.setInt(2, currentFill);
            ptm.setString(3, binID);

            return ptm.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(ptm, conn);
        }

        return false;
    }

    // =========================================================
    // UPDATE FILL AND STATUS
    // =========================================================
    public boolean updateFillAndStatus(String binID, int fillPercent) {
        return updateCurrentFill(binID, fillPercent);
    }

    // =========================================================
    // GET FILTERED
    // =========================================================
    public List<WasteBin> getFiltered(
            String search,
            String areaID,
            String status,
            String fillLevel,
            String sort,
            String order) {

        return getFiltered(
                search, areaID, status, fillLevel,
                sort, order, null);
    }

    public List<WasteBin> getFiltered(
            String search,
            String areaID,
            String status,
            String fillLevel,
            String sort,
            String order,
            List<String> allowedAreaIds) {

        List<WasteBin> list = new ArrayList<WasteBin>();

        StringBuilder sql = new StringBuilder(SELECT_COLUMNS);
        sql.append("WHERE 1 = 1 ");

        List<Object> params = new ArrayList<Object>();

        appendAreaScope(sql, params, allowedAreaIds);
        appendSearchFilter(sql, params, search);
        appendAreaFilter(sql, params, areaID);
        appendStatusFilter(sql, status);
        appendFillLevelFilter(sql, fillLevel);

        sql.append("ORDER BY ").append(getOrderBy(sort, order));

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(sql.toString());
            bindParams(ptm, params);

            rs = ptm.executeQuery();

            while (rs.next()) {
                list.add(mapWasteBin(rs));
            }

        } catch (Exception e) {
            System.err.println("Error in WasteBinDAO.getFiltered()");
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ptm, conn);
        }

        return list;
    }

    // =========================================================
    // GET BINS BY AREAS
    // =========================================================
    public List<WasteBin> getByAreas(List<String> areaIds) {

        return getFiltered(
                "", "", "", "",
                "binID", "ASC", areaIds);
    }

    // =========================================================
    // GET FILTERED WITH PAGINATION
    // =========================================================
    public List<WasteBin> getFilteredPaged(
            String search,
            String areaID,
            String status,
            String fillLevel,
            String sort,
            String order,
            List<String> allowedAreaIds,
            int offset,
            int pageSize) {

        List<WasteBin> list = new ArrayList<WasteBin>();

        StringBuilder sql = new StringBuilder(SELECT_COLUMNS);
        sql.append("WHERE 1 = 1 ");

        List<Object> params = new ArrayList<Object>();

        appendAreaScope(sql, params, allowedAreaIds);
        appendSearchFilter(sql, params, search);
        appendAreaFilter(sql, params, areaID);
        appendStatusFilter(sql, status);
        appendFillLevelFilter(sql, fillLevel);

        sql.append("ORDER BY ").append(getOrderBy(sort, order))
                .append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(sql.toString());

            int index = bindParams(ptm, params);
            ptm.setInt(index++, Math.max(0, offset));
            ptm.setInt(index, Math.max(1, pageSize));

            rs = ptm.executeQuery();

            while (rs.next()) {
                list.add(mapWasteBin(rs));
            }

        } catch (Exception e) {
            System.err.println("Error in WasteBinDAO.getFilteredPaged()");
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ptm, conn);
        }

        return list;
    }

    // =========================================================
    // GET FILTERED COUNTS
    // Return: [totalRecords, activeCount, highFillCount]
    // =========================================================
    public int[] getFilteredCounts(
            String search,
            String areaID,
            String status,
            String fillLevel,
            List<String> allowedAreaIds) {

        int[] counts = new int[]{0, 0, 0};

        StringBuilder sql = new StringBuilder(FILTERED_COUNTS);
        List<Object> params = new ArrayList<Object>();

        appendAreaScope(sql, params, allowedAreaIds);
        appendSearchFilter(sql, params, search);
        appendAreaFilter(sql, params, areaID);
        appendStatusFilter(sql, status);
        appendFillLevelFilter(sql, fillLevel);

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(sql.toString());
            bindParams(ptm, params);

            rs = ptm.executeQuery();

            if (rs.next()) {
                counts[0] = rs.getInt("totalRecords");
                counts[1] = rs.getInt("activeCount");
                counts[2] = rs.getInt("highFillCount");
            }

        } catch (Exception e) {
            System.err.println("Error in WasteBinDAO.getFilteredCounts()");
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ptm, conn);
        }

        return counts;
    }

    // =========================================================
    // APPEND AREA SCOPE
    // null = unrestricted; empty list = no accessible areas
    // =========================================================
    private void appendAreaScope(
            StringBuilder sql,
            List<Object> params,
            List<String> allowedAreaIds) {

        if (allowedAreaIds == null) {
            return;
        }

        if (allowedAreaIds.isEmpty()) {
            sql.append("AND 1 = 0 ");
            return;
        }

        sql.append("AND areaID IN (");

        for (int i = 0; i < allowedAreaIds.size(); i++) {
            if (i > 0) {
                sql.append(", ");
            }

            sql.append("?");
            params.add(allowedAreaIds.get(i));
        }

        sql.append(") ");
    }

    // =========================================================
    // APPEND SEARCH FILTER
    // =========================================================
    private void appendSearchFilter(
            StringBuilder sql,
            List<Object> params,
            String search) {

        if (search == null || search.trim().isEmpty()) {
            return;
        }

        sql.append("AND (binCode LIKE ? OR location LIKE ?) ");

        String keyword = "%" + search.trim() + "%";
        params.add(keyword);
        params.add(keyword);
    }

    // =========================================================
    // APPEND AREA FILTER
    // =========================================================
    private void appendAreaFilter(
            StringBuilder sql,
            List<Object> params,
            String areaID) {

        if (areaID == null || areaID.trim().isEmpty()) {
            return;
        }

        sql.append("AND areaID = ? ");
        params.add(areaID.trim());
    }

    // =========================================================
    // APPEND STATUS FILTER
    // =========================================================
    private void appendStatusFilter(
            StringBuilder sql,
            String status) {

        if (status == null || status.trim().isEmpty()) {
            return;
        }

        if ("Maintenance".equalsIgnoreCase(status)) {
            sql.append("AND status = 'Maintenance' ");
        } else if ("Full".equalsIgnoreCase(status)) {
            sql.append("AND status <> 'Maintenance' ");
            sql.append("AND currentFill >= 80 ");
        } else if ("Active".equalsIgnoreCase(status)) {
            sql.append("AND status <> 'Maintenance' ");
            sql.append("AND currentFill < 80 ");
        }
    }

    // =========================================================
    // APPEND FILL LEVEL FILTER
    // =========================================================
    private void appendFillLevelFilter(
            StringBuilder sql,
            String fillLevel) {

        if ("Low".equalsIgnoreCase(fillLevel)) {
            sql.append("AND currentFill < 50 ");
        } else if ("Medium".equalsIgnoreCase(fillLevel)) {
            sql.append("AND currentFill >= 50 AND currentFill < 80 ");
        } else if ("High".equalsIgnoreCase(fillLevel)) {
            sql.append("AND currentFill >= 80 ");
        }
    }

    // =========================================================
    // BIND PARAMETERS
    // =========================================================
    private int bindParams(
            PreparedStatement ptm,
            List<Object> params) throws Exception {

        int index = 1;

        for (Object param : params) {
            ptm.setObject(index++, param);
        }

        return index;
    }
}
