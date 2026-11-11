package dao;

import model.AppUser;
import util.PasswordUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    private static final String USER_ID_PREFIX_SORT
            = "LEFT(userID, PATINDEX('%[0-9]%', userID + '0') - 1)";

    private static final String USER_ID_NUMBER_SORT
            = "TRY_CONVERT(INT, SUBSTRING(userID, "
            + "PATINDEX('%[0-9]%', userID + '0'), LEN(userID)))";

    private static final String SELECT_COLUMNS
            = "SELECT userID, fullName, email, phoneNumber, "
            + "roleID, password, status, areaID, "
            + "(SELECT areaName FROM dbo.tblAreas WHERE areaID = tblUsers.areaID) AS areaName "
            + "FROM tblUsers ";

    private static final String FIND_BY_USERNAME
            = SELECT_COLUMNS + "WHERE email = ?";

    private static final String FIND_BY_ID
            = SELECT_COLUMNS + "WHERE userID = ?";

    private static final String INSERT
            = "INSERT INTO tblUsers "
            + "(userID, fullName, email, phoneNumber, "
            + "roleID, password, status, areaID) "
            + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

    private static final String UPDATE
            = "UPDATE tblUsers "
            + "SET fullName = ?, email = ?, phoneNumber = ?, "
            + "roleID = ? WHERE userID = ?";

    private static final String UPDATE_PROFILE
            = "UPDATE tblUsers "
            + "SET fullName = ?, email = ?, phoneNumber = ? "
            + "WHERE userID = ?";

    private static final String ASSIGN_AREA
            = "UPDATE tblUsers SET areaID = ? WHERE userID = ?";

    private static final String DELETE
            = "DELETE FROM tblUsers WHERE userID = ?";

    private static final String SET_STATUS
            = "UPDATE tblUsers SET status = ? WHERE userID = ?";

    private static final String RESET_PASSWORD
            = "UPDATE tblUsers SET password = ? WHERE userID = ?";

    private static final String COUNT_SEARCH
            = "SELECT COUNT(*) FROM tblUsers "
            + "WHERE (userID LIKE ? OR fullName LIKE ? "
            + "OR email LIKE ? OR phoneNumber LIKE ?)";

    // =========================================================
    // FIND BY USERNAME (EMAIL)
    // =========================================================
    public AppUser findByUsername(String username) {

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(FIND_BY_USERNAME);
            ptm.setString(1, username);

            rs = ptm.executeQuery();

            if (rs.next()) {
                return map(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ptm, conn);
        }

        return null;
    }

    public AppUser findByEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return null;
        }
        return findByUsername(email.trim());
    }

    // =========================================================
    // FIND BY ID
    // =========================================================
    public AppUser findById(String userId) {

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(FIND_BY_ID);
            ptm.setString(1, userId);

            rs = ptm.executeQuery();

            if (rs.next()) {
                return map(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ptm, conn);
        }

        return null;
    }

    // =========================================================
    // SEARCH USERS
    // =========================================================
    public List<AppUser> search(String keyword, String roleId) {

        List<AppUser> list = new ArrayList<AppUser>();

        StringBuilder sql = new StringBuilder(SELECT_COLUMNS);
        appendSearchCondition(sql, roleId);

        sql.append("ORDER BY ")
                .append(USER_ID_PREFIX_SORT).append(" ASC, ")
                .append("CASE WHEN ")
                .append(USER_ID_NUMBER_SORT)
                .append(" IS NULL THEN 1 ELSE 0 END ASC, ")
                .append(USER_ID_NUMBER_SORT).append(" ASC, ")
                .append("userID ASC");

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(sql.toString());

            int index = setSearchParameters(ptm, keyword, roleId);

            rs = ptm.executeQuery();

            while (rs.next()) {
                list.add(map(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ptm, conn);
        }

        return list;
    }

    // =========================================================
    // INSERT USER
    // =========================================================
    public boolean insert(AppUser user) {

        if (user == null
                || !hasText(user.getUserId())
                || !hasText(user.getPassword())
                || !hasText(user.getEmail())) {
            return false;
        }

        Connection conn = null;
        PreparedStatement ptm = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(INSERT);

            ptm.setString(1, user.getUserId().trim());
            ptm.setString(2, user.getFullName());
            ptm.setString(3, user.getEmail().trim());
            ptm.setString(4, user.getPhoneNumber());
            ptm.setString(5, user.getRoleId());
            ptm.setString(6, PasswordUtil.hash(user.getPassword()));
            ptm.setBoolean(7, user.isStatus());

            if (hasText(user.getAreaID())) {
                ptm.setString(8, user.getAreaID().trim());
            } else {
                ptm.setNull(8, Types.VARCHAR);
            }

            return ptm.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(ptm, conn);
        }

        return false;
    }

    // =========================================================
    // UPDATE USER PROFILE
    // Does not update password, status, or area.
    // =========================================================
    public boolean update(AppUser user) {

        if (user == null || !hasText(user.getUserId())) {
            return false;
        }

        Connection conn = null;
        PreparedStatement ptm = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(UPDATE);

            ptm.setString(1, user.getFullName());
            ptm.setString(2, user.getEmail());
            ptm.setString(3, user.getPhoneNumber());
            ptm.setString(4, user.getRoleId());
            ptm.setString(5, user.getUserId().trim());

            return ptm.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(ptm, conn);
        }

        return false;
    }

    // =========================================================
    // UPDATE USER SELF-PROFILE (IMMUTABLE ROLE & STATUS)
    // =========================================================
    public boolean updateProfile(String userId, String fullName, String email, String phoneNumber) {

        if (!hasText(userId)) {
            return false;
        }

        Connection conn = null;
        PreparedStatement ptm = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(UPDATE_PROFILE);

            ptm.setString(1, fullName != null ? fullName.trim() : "");
            ptm.setString(2, email != null ? email.trim() : "");
            ptm.setString(3, phoneNumber != null ? phoneNumber.trim() : "");
            ptm.setString(4, userId.trim());

            return ptm.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(ptm, conn);
        }

        return false;
    }

    // =========================================================
    // ASSIGN OR REMOVE AREA
    // =========================================================
    public boolean assignArea(String userId, String areaID) {

        if (!hasText(userId)) {
            return false;
        }

        Connection conn = null;
        PreparedStatement ptm = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(ASSIGN_AREA);

            if (hasText(areaID)) {
                ptm.setString(1, areaID.trim());
            } else {
                ptm.setNull(1, Types.VARCHAR);
            }

            ptm.setString(2, userId.trim());

            return ptm.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(ptm, conn);
        }

        return false;
    }

    // =========================================================
    // GET ASSIGNED AREA IDS (FOR MANAGERS & SUPERVISORS)
    // =========================================================
    public List<String> getAssignedAreaIds(String userId) {
        List<String> list = new ArrayList<String>();
        if (!hasText(userId)) return list;
        String sql = "SELECT areaID FROM dbo.tblUserAreas WHERE userID = ?";
        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(sql);
            ptm.setString(1, userId.trim());
            rs = ptm.executeQuery();
            while (rs.next()) {
                list.add(rs.getString("areaID"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ptm, conn);
        }
        return list;
    }

    public boolean addAssignedArea(String userId, String areaID) {
        if (!hasText(userId) || !hasText(areaID)) return false;
        String sql = "IF NOT EXISTS (SELECT 1 FROM dbo.tblUserAreas WHERE userID = ? AND areaID = ?) "
                   + "INSERT INTO dbo.tblUserAreas (userID, areaID, assignedDate) VALUES (?, ?, GETDATE())";
        Connection conn = null;
        PreparedStatement ptm = null;
        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(sql);
            ptm.setString(1, userId.trim());
            ptm.setString(2, areaID.trim());
            ptm.setString(3, userId.trim());
            ptm.setString(4, areaID.trim());
            return ptm.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(ptm, conn);
        }
        return false;
    }

    // =========================================================
    // DELETE USER
    // =========================================================
    public boolean delete(String userId) {

        if (!hasText(userId)) {
            return false;
        }

        Connection conn = null;
        PreparedStatement ptm = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(DELETE);
            ptm.setString(1, userId.trim());

            return ptm.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(ptm, conn);
        }

        return false;
    }

    // =========================================================
    // SET USER STATUS
    // =========================================================
    public boolean setStatus(String userId, boolean status) {

        if (!hasText(userId)) {
            return false;
        }

        Connection conn = null;
        PreparedStatement ptm = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(SET_STATUS);

            ptm.setBoolean(1, status);
            ptm.setString(2, userId.trim());

            return ptm.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(ptm, conn);
        }

        return false;
    }

    // =========================================================
    // RESET PASSWORD
    // =========================================================
    public boolean resetPassword(String userId, String password) {

        if (!hasText(userId) || !hasText(password)) {
            return false;
        }

        Connection conn = null;
        PreparedStatement ptm = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(RESET_PASSWORD);

            ptm.setString(1, PasswordUtil.hash(password));
            ptm.setString(2, userId.trim());

            return ptm.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(ptm, conn);
        }

        return false;
    }

    // =========================================================
    // COUNT SEARCH RESULTS
    // =========================================================
    public int countSearch(String keyword, String roleId) {
        return countSearch(keyword, roleId, null, null);
    }

    public int countSearch(String keyword, String roleId, String excludeRole, String statusFilter) {

        StringBuilder sql = new StringBuilder(COUNT_SEARCH);
        appendRoleCondition(sql, roleId);
        appendExcludeRoleCondition(sql, excludeRole);
        appendStatusCondition(sql, statusFilter);

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(sql.toString());

            setSearchParameters(ptm, keyword, roleId, excludeRole, statusFilter);

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
    // SEARCH USERS WITH PAGINATION
    // =========================================================
    public List<AppUser> searchPaged(
            String keyword, String roleId, int page, int pageSize) {
        return searchPaged(keyword, roleId, null, null, page, pageSize);
    }

    public List<AppUser> searchPaged(
            String keyword, String roleId, String excludeRole, String statusFilter, int page, int pageSize) {

        List<AppUser> list = new ArrayList<AppUser>();

        if (page < 1) {
            page = 1;
        }

        if (pageSize < 1) {
            pageSize = 10;
        }

        StringBuilder sql = new StringBuilder(SELECT_COLUMNS);
        appendSearchCondition(sql, roleId, excludeRole, statusFilter);

        sql.append("ORDER BY ")
                .append(USER_ID_PREFIX_SORT).append(" ASC, ")
                .append("CASE WHEN ")
                .append(USER_ID_NUMBER_SORT)
                .append(" IS NULL THEN 1 ELSE 0 END ASC, ")
                .append(USER_ID_NUMBER_SORT).append(" ASC, ")
                .append("userID ASC ")
                .append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(sql.toString());

            int index = setSearchParameters(ptm, keyword, roleId, excludeRole, statusFilter);

            ptm.setInt(index++, (page - 1) * pageSize);
            ptm.setInt(index, pageSize);

            rs = ptm.executeQuery();

            while (rs.next()) {
                list.add(map(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ptm, conn);
        }

        return list;
    }

    // =========================================================
    // APPEND SEARCH CONDITIONS
    // =========================================================
    private void appendSearchCondition(StringBuilder sql, String roleId) {
        appendSearchCondition(sql, roleId, null, null);
    }

    private void appendSearchCondition(StringBuilder sql, String roleId, String excludeRole, String statusFilter) {

        sql.append("WHERE (userID LIKE ? ")
                .append("OR fullName LIKE ? ")
                .append("OR email LIKE ? ")
                .append("OR phoneNumber LIKE ?) ");

        appendRoleCondition(sql, roleId);
        appendExcludeRoleCondition(sql, excludeRole);
        appendStatusCondition(sql, statusFilter);
    }

    private void appendRoleCondition(StringBuilder sql, String roleId) {

        if (hasText(roleId)) {
            sql.append("AND roleID = ? ");
        }
    }

    private void appendExcludeRoleCondition(StringBuilder sql, String excludeRole) {
        if (hasText(excludeRole)) {
            sql.append("AND roleID <> ? ");
        }
    }

    private void appendStatusCondition(StringBuilder sql, String statusFilter) {
        if ("active".equalsIgnoreCase(statusFilter)) {
            sql.append("AND status = 1 ");
        } else if ("inactive".equalsIgnoreCase(statusFilter) || "locked".equalsIgnoreCase(statusFilter)) {
            sql.append("AND status = 0 ");
        }
    }

    // =========================================================
    // SET SEARCH PARAMETERS
    // Returns the next available parameter index.
    // =========================================================
    private int setSearchParameters(PreparedStatement ptm,
            String keyword, String roleId) throws Exception {
        return setSearchParameters(ptm, keyword, roleId, null, null);
    }

    private int setSearchParameters(PreparedStatement ptm,
            String keyword, String roleId, String excludeRole, String statusFilter) throws Exception {

        String key = "%"
                + (keyword == null ? "" : keyword.trim())
                + "%";

        ptm.setString(1, key);
        ptm.setString(2, key);
        ptm.setString(3, key);
        ptm.setString(4, key);

        int index = 5;

        if (hasText(roleId)) {
            ptm.setString(index++, roleId.trim());
        }

        if (hasText(excludeRole)) {
            ptm.setString(index++, excludeRole.trim());
        }

        return index;
    }

    // =========================================================
    // MAP RESULT SET TO APPUSER
    // =========================================================
    private AppUser map(ResultSet rs) throws Exception {

        AppUser user = new AppUser();

        user.setUserId(rs.getString("userID"));
        user.setFullName(rs.getString("fullName"));
        user.setEmail(rs.getString("email"));
        user.setPhoneNumber(rs.getString("phoneNumber"));
        user.setRoleId(rs.getString("roleID"));
        user.setPassword(rs.getString("password"));
        user.setStatus(rs.getBoolean("status"));
        user.setAreaID(rs.getString("areaID"));
        try {
            user.setAreaName(rs.getString("areaName"));
        } catch (Exception ignored) {
        }

        return user;
    }

    // =========================================================
    // CHECK NON-EMPTY STRING
    // =========================================================
    private boolean hasText(String value) {
        return value != null && !value.trim().isEmpty();
    }
}
