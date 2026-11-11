    
package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Area;

public class AreaDAO {

    // Map a database row to an Area object.
    private Area mapArea(ResultSet rs) throws Exception {
        Area area = new Area();
        area.setAreaId(rs.getString("areaID"));
        area.setAreaName(rs.getString("areaName"));
        area.setDescription(rs.getString("description"));
        return area;
    }

    // Add a search condition to a SQL query.
    private void appendSearch(
            StringBuilder sql,
            List<Object> params,
            String search,
            String prefix) {

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (")
                    .append(prefix)
                    .append("areaID LIKE ? OR ")
                    .append(prefix)
                    .append("areaName LIKE ?) ");

            String keyword = "%" + search.trim() + "%";
            params.add(keyword);
            params.add(keyword);
        }
    }

    // Validate sorting columns and direction.
    private String getOrderBy(String sort, String prefix) {
        if ("areaName".equals(sort)) {
            return prefix + "areaName";
        }
        return prefix + "areaID";
    }

    private String getSortOrder(String order) {
        return "DESC".equalsIgnoreCase(order) ? "DESC" : "ASC";
    }

    // Check whether an area name already exists.
    public boolean isAreaNameExist(String areaName) {
        if (areaName == null || areaName.trim().isEmpty()) {
            return false;
        }

        String sql = "SELECT COUNT(*) FROM tblAreas "
                + "WHERE LTRIM(RTRIM(areaName)) = LTRIM(RTRIM(?))";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, areaName.trim());

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

    // Check whether an area name exists for another area.
    public boolean isAreaNameExist(String areaName, String excludeAreaId) {
        if (areaName == null || areaName.trim().isEmpty()) {
            return false;
        }

        String sql = "SELECT COUNT(*) FROM tblAreas "
                + "WHERE LTRIM(RTRIM(areaName)) = LTRIM(RTRIM(?)) "
                + "AND areaID <> ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, areaName.trim());
            ps.setString(2, excludeAreaId);

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

    // Get all areas.
    public List<Area> getAll() {
        List<Area> list = new ArrayList<>();

        String sql = "SELECT areaID, areaName, description "
                + "FROM tblAreas ORDER BY areaID";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapArea(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }

        return list;
    }

    // Find an area by ID.
    public Area findById(String areaId) {
        String sql = "SELECT areaID, areaName, description "
                + "FROM tblAreas WHERE areaID = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, areaId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapArea(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }

        return null;
    }

    // Insert an area.
    public boolean insert(Area area) {
        if (area == null || area.getAreaId() == null
                || area.getAreaId().trim().isEmpty()
                || area.getAreaName() == null
                || area.getAreaName().trim().isEmpty()) {
            return false;
        }

        String areaName = area.getAreaName().trim();

        if (isAreaNameExist(areaName)) {
            return false;
        }

        String sql = "INSERT INTO tblAreas "
                + "(areaID, areaName, description) VALUES (?, ?, ?)";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, area.getAreaId().trim());
            ps.setString(2, areaName);
            ps.setString(3, area.getDescription());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(ps, conn);
        }

        return false;
    }

    // Update an area.
    public boolean update(Area area) {
        if (area == null || area.getAreaId() == null
                || area.getAreaId().trim().isEmpty()
                || area.getAreaName() == null
                || area.getAreaName().trim().isEmpty()) {
            return false;
        }

        String areaName = area.getAreaName().trim();

        if (isAreaNameExist(areaName, area.getAreaId())) {
            return false;
        }

        String sql = "UPDATE tblAreas "
                + "SET areaName = ?, description = ? WHERE areaID = ?";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, areaName);
            ps.setString(2, area.getDescription());
            ps.setString(3, area.getAreaId().trim());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(ps, conn);
        }

        return false;
    }

    // Delete an area.
    public boolean delete(String areaId) {
        String sql = "DELETE FROM tblAreas WHERE areaID = ?";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, areaId);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(ps, conn);
        }

        return false;
    }

    // Get areas assigned to a manager.
    public List<Area> getByManager(String managerID) {
        List<Area> list = new ArrayList<>();

        String sql = "SELECT a.areaID, a.areaName, a.description "
                + "FROM tblAreas a "
                + "INNER JOIN tblAreaAssignments aa ON a.areaID = aa.areaID "
                + "WHERE aa.userID = ? "
                + "AND aa.assignmentRole = 'MANAGER' "
                + "ORDER BY a.areaID";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, managerID);
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapArea(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }

        return list;
    }

    // Get filtered areas for Admin and other callers using the global list.
    public List<Area> getFiltered(
            String search, String sort, String order) {

        List<Area> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT areaID, areaName, description FROM tblAreas "
                + "WHERE 1 = 1 ");

        List<Object> params = new ArrayList<>();
        appendSearch(sql, params, search, "");

        sql.append(" ORDER BY ")
                .append(getOrderBy(sort, ""))
                .append(" ")
                .append(getSortOrder(order));

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql.toString());

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapArea(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }

        return list;
    }

    // Get filtered areas assigned to a manager.
    public List<Area> getFilteredByManager(
            String managerID, String search, String sort, String order) {

        List<Area> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT a.areaID, a.areaName, a.description "
                + "FROM tblAreas a "
                + "INNER JOIN tblAreaAssignments aa ON a.areaID = aa.areaID "
                + "WHERE aa.userID = ? "
                + "AND aa.assignmentRole = 'MANAGER' ");

        List<Object> params = new ArrayList<>();
        params.add(managerID);
        appendSearch(sql, params, search, "a");

        sql.append(" ORDER BY ")
                .append(getOrderBy(sort, "a."))
                .append(" ")
                .append(getSortOrder(order));

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql.toString());

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapArea(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }

        return list;
    }

    // Get filtered and paginated areas for Admin and global-list callers.
    public List<Area> getFilteredPaged(
            String search, String sort, String order,
            int offset, int pageSize) {

        List<Area> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT areaID, areaName, description FROM tblAreas "
                + "WHERE 1 = 1 ");

        List<Object> params = new ArrayList<>();
        appendSearch(sql, params, search, "");

        String orderBy = getOrderBy(sort, "");
        sql.append(" ORDER BY ")
                .append(orderBy)
                .append(" ")
                .append(getSortOrder(order));

        if (!"areaID".equals(orderBy)) {
            sql.append(", areaID ASC");
        }

        sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql.toString());

            int index = 1;
            for (Object param : params) {
                ps.setObject(index++, param);
            }

            ps.setInt(index++, Math.max(0, offset));
            ps.setInt(index, Math.max(1, pageSize));

            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapArea(rs));
            }
        } catch (Exception e) {
            System.err.println("Error in getFilteredPaged. SQL: " + sql);
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }

        return list;
    }

    // Get filtered and paginated areas assigned to a manager.
    public List<Area> getFilteredByManagerPaged(
            String managerID, String search, String sort, String order,
            int offset, int pageSize) {

        List<Area> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT a.areaID, a.areaName, a.description "
                + "FROM tblAreas a "
                + "INNER JOIN tblAreaAssignments aa ON a.areaID = aa.areaID "
                + "WHERE aa.userID = ? "
                + "AND aa.assignmentRole = 'MANAGER' ");

        List<Object> params = new ArrayList<>();
        params.add(managerID);
        appendSearch(sql, params, search, "a");

        String orderBy = getOrderBy(sort, "a.");
        sql.append(" ORDER BY ")
                .append(orderBy)
                .append(" ")
                .append(getSortOrder(order));

        if (!"a.areaID".equals(orderBy)) {
            sql.append(", a.areaID ASC");
        }

        sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql.toString());

            int index = 1;
            for (Object param : params) {
                ps.setObject(index++, param);
            }

            ps.setInt(index++, Math.max(0, offset));
            ps.setInt(index, Math.max(1, pageSize));

            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapArea(rs));
            }
        } catch (Exception e) {
            System.err.println(
                    "Error in getFilteredByManagerPaged. SQL: " + sql);
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }

        return list;
    }

    // Count filtered areas for Admin and global-list callers.
    public int countFiltered(String search) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM tblAreas WHERE 1 = 1 ");

        List<Object> params = new ArrayList<>();
        appendSearch(sql, params, search, "");

        return executeCount(sql.toString(), params);
    }

    // Count filtered areas assigned to a manager.
    public int countFilteredByManager(String managerID, String search) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) "
                + "FROM tblAreas a "
                + "INNER JOIN tblAreaAssignments aa ON a.areaID = aa.areaID "
                + "WHERE aa.userID = ? "
                + "AND aa.assignmentRole = 'MANAGER' ");

        List<Object> params = new ArrayList<>();
        params.add(managerID);
        appendSearch(sql, params, search, "a");

        return executeCount(sql.toString(), params);
    }

    // Execute a COUNT query.
    private int executeCount(String sql, List<Object> params) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }

        return 0;
    }

    // Get the area assigned to a regular user.
    public Area getByUser(String userId) {
        String sql = "SELECT a.areaID, a.areaName, a.description "
                + "FROM tblUsers u "
                + "INNER JOIN tblAreas a ON u.areaID = a.areaID "
                + "WHERE u.userID = ? AND u.roleID = 'USR'";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, userId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapArea(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }

        return null;
    }

    // Get areas for the selected user scope.
    public List<Area> getVisibleToUser(String userId, boolean allAreas) {
        if (allAreas) {
            return getAll();
        }

        List<Area> list = new ArrayList<>();
        String sql = "SELECT a.areaID, a.areaName, a.description "
                + "FROM tblUsers u "
                + "INNER JOIN tblAreas a ON u.areaID = a.areaID "
                + "WHERE u.userID = ? AND u.roleID = 'USR' "
                + "ORDER BY a.areaID";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, userId);
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapArea(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }

        return list;
    }

    // Count the area assigned to a regular user after filtering.
    public int countFilteredByUser(String userId, String search) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) "
                + "FROM tblUsers u "
                + "INNER JOIN tblAreas a ON u.areaID = a.areaID "
                + "WHERE u.userID = ? AND u.roleID = 'USR' ");

        List<Object> params = new ArrayList<>();
        params.add(userId);
        appendSearch(sql, params, search, "a");

        return executeCount(sql.toString(), params);
    }

    // Get the filtered and paginated area assigned to a regular user.
    public List<Area> getFilteredByUserPaged(
            String userId, String search, String sort, String order,
            int offset, int pageSize) {

        List<Area> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT a.areaID, a.areaName, a.description "
                + "FROM tblUsers u "
                + "INNER JOIN tblAreas a ON u.areaID = a.areaID "
                + "WHERE u.userID = ? AND u.roleID = 'USR' ");

        List<Object> params = new ArrayList<>();
        params.add(userId);
        appendSearch(sql, params, search, "a");

        String orderBy = getOrderBy(sort, "a.");
        sql.append(" ORDER BY ")
                .append(orderBy)
                .append(" ")
                .append(getSortOrder(order));

        if (!"a.areaID".equals(orderBy)) {
            sql.append(", a.areaID ASC");
        }

        sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql.toString());

            int index = 1;
            for (Object param : params) {
                ps.setObject(index++, param);
            }

            ps.setInt(index++, Math.max(0, offset));
            ps.setInt(index, Math.max(1, pageSize));

            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapArea(rs));
            }
        } catch (Exception e) {
            System.err.println(
                    "Error in getFilteredByUserPaged. SQL: " + sql);
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }

        return list;
    }
}
