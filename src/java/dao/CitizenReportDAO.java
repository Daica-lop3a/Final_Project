package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import model.CitizenReport;

/**
 * DAO handling citizen feedback and reporting operations (tblCitizenReports)
 * - User: Submit and view personal reports
 * - Supervisor: View area reports, verify and provide resolution feedback
 */
public class CitizenReportDAO {

    private static final String SELECT_BASE
            = "SELECT r.reportID, r.citizenID, r.binID, r.areaID, r.reportType, "
            + "r.title, r.description, r.imageURL, r.status, r.createdDate, "
            + "r.verifiedBy, r.verifiedDate, r.feedbackNote, "
            + "r.latitude, r.longitude, r.rating, r.ratingComment, r.ratedDate, "
            + "u.fullName AS citizenName, b.binCode, a.areaName, v.fullName AS verifierName "
            + "FROM dbo.tblCitizenReports r "
            + "LEFT JOIN dbo.tblUsers u ON r.citizenID = u.userID "
            + "LEFT JOIN dbo.tblWasteBins b ON r.binID = b.binID "
            + "LEFT JOIN dbo.tblAreas a ON r.areaID = a.areaID "
            + "LEFT JOIN dbo.tblUsers v ON r.verifiedBy = v.userID ";

    // ==========================================
    // 1. Create new citizen report (User)
    // ==========================================
    public boolean createReport(CitizenReport report) {
        String sql = "INSERT INTO dbo.tblCitizenReports "
                + "(reportID, citizenID, binID, areaID, reportType, title, description, imageURL, status, createdDate, latitude, longitude) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), ?, ?)";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, report.getReportID());
            ps.setString(2, report.getCitizenID());
            ps.setString(3, report.getBinID() == null || report.getBinID().trim().isEmpty() ? null : report.getBinID());
            ps.setString(4, report.getAreaID() == null || report.getAreaID().trim().isEmpty() ? null : report.getAreaID());
            ps.setString(5, report.getReportType());
            ps.setString(6, report.getTitle());
            ps.setString(7, report.getDescription());
            ps.setString(8, report.getImageURL());
            ps.setString(9, report.getStatus() != null && !report.getStatus().trim().isEmpty() ? report.getStatus() : "Submitted");
            if (report.getLatitude() != null) {
                ps.setDouble(10, report.getLatitude());
            } else {
                ps.setNull(10, java.sql.Types.DECIMAL);
            }
            if (report.getLongitude() != null) {
                ps.setDouble(11, report.getLongitude());
            } else {
                ps.setNull(11, java.sql.Types.DECIMAL);
            }

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBContext.close(null, ps, conn);
        }
    }

    // ==========================================
    // 2. Query reports submitted by a citizen
    // ==========================================
    public List<CitizenReport> getReportsByCitizen(String citizenID) {
        List<CitizenReport> list = new ArrayList<>();
        String sql = SELECT_BASE + "WHERE r.citizenID = ? ORDER BY r.createdDate DESC";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, citizenID);
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
    // 3. Get report by ID
    // ==========================================
    public CitizenReport getReportById(String reportID) {
        String sql = SELECT_BASE + "WHERE r.reportID = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, reportID);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return null;
    }

    // ==========================================
    // 4. Paginated report list for supervisors/managers
    // ==========================================
    public List<CitizenReport> getReports(String areaID, String statusFilter, int page, int pageSize) {
        List<CitizenReport> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(SELECT_BASE);
        sql.append("WHERE 1 = 1 ");

        if (areaID != null && !areaID.trim().isEmpty()) {
            sql.append("AND (r.areaID = ? OR b.areaID = ?) ");
        }
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append("AND r.status = ? ");
        }

        sql.append("ORDER BY r.createdDate DESC ");
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql.toString());
            int idx = 1;
            if (areaID != null && !areaID.trim().isEmpty()) {
                ps.setString(idx++, areaID);
                ps.setString(idx++, areaID);
            }
            if (statusFilter != null && !statusFilter.trim().isEmpty()) {
                ps.setString(idx++, statusFilter);
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
    // 5. M TNG S PHN NH THEO IU KIN
    // ==========================================

    // ==========================================
    // 4B. Get reports filtered by date range
    // ==========================================
    public List<CitizenReport> getReportsByDateRange(Timestamp from, Timestamp to, String areaID, String statusFilter) {
        List<CitizenReport> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(SELECT_BASE);
        sql.append("WHERE 1 = 1 ");

        if (from != null) {
            sql.append("AND r.createdDate >= ? ");
        }
        if (to != null) {
            sql.append("AND r.createdDate <= ? ");
        }
        if (areaID != null && !areaID.trim().isEmpty()) {
            sql.append("AND (r.areaID = ? OR b.areaID = ?) ");
        }
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append("AND r.status = ? ");
        }

        sql.append("ORDER BY r.createdDate DESC");

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
            if (areaID != null && !areaID.trim().isEmpty()) {
                ps.setString(idx++, areaID);
                ps.setString(idx++, areaID);
            }
            if (statusFilter != null && !statusFilter.trim().isEmpty()) {
                ps.setString(idx++, statusFilter);
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
    public int countReports(String areaID, String statusFilter) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM dbo.tblCitizenReports r "
                + "LEFT JOIN dbo.tblWasteBins b ON r.binID = b.binID WHERE 1 = 1 "
        );

        if (areaID != null && !areaID.trim().isEmpty()) {
            sql.append("AND (r.areaID = ? OR b.areaID = ?) ");
        }
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append("AND r.status = ? ");
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql.toString());
            int idx = 1;
            if (areaID != null && !areaID.trim().isEmpty()) {
                ps.setString(idx++, areaID);
                ps.setString(idx++, areaID);
            }
            if (statusFilter != null && !statusFilter.trim().isEmpty()) {
                ps.setString(idx++, statusFilter);
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
    // 6. Verify and update report status (Supervisor)
    // ==========================================
    public boolean verifyReport(String reportID, String supervisorID, String newStatus, String feedbackNote) {
        String sql = "UPDATE dbo.tblCitizenReports "
                + "SET status = ?, verifiedBy = ?, verifiedDate = GETDATE(), feedbackNote = ? "
                + "WHERE reportID = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, newStatus);
            ps.setString(2, supervisorID);
            ps.setString(3, feedbackNote);
            ps.setString(4, reportID);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBContext.close(null, ps, conn);
        }
    }

    // ==========================================
    // 7. SA PHN NH KHI CN  TRNG THI CHO PHP (USER)
    // ==========================================
    public boolean updateReport(CitizenReport report) {
        String sql = "UPDATE dbo.tblCitizenReports "
                + "SET title = ?, description = ?, reportType = ?, binID = ?, areaID = ?, imageURL = ?, latitude = ?, longitude = ? "
                + "WHERE reportID = ? AND citizenID = ? AND (status = 'Submitted' OR status = 'Pending')";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, report.getTitle());
            ps.setString(2, report.getDescription());
            ps.setString(3, report.getReportType());
            ps.setString(4, report.getBinID() == null || report.getBinID().trim().isEmpty() ? null : report.getBinID());
            ps.setString(5, report.getAreaID() == null || report.getAreaID().trim().isEmpty() ? null : report.getAreaID());
            ps.setString(6, report.getImageURL());
            if (report.getLatitude() != null) {
                ps.setDouble(7, report.getLatitude());
            } else {
                ps.setNull(7, java.sql.Types.DECIMAL);
            }
            if (report.getLongitude() != null) {
                ps.setDouble(8, report.getLongitude());
            } else {
                ps.setNull(8, java.sql.Types.DECIMAL);
            }
            ps.setString(9, report.getReportID());
            ps.setString(10, report.getCitizenID());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBContext.close(null, ps, conn);
        }
    }

    // ==========================================
    // 8. Cancel pending report (User)
    // ==========================================
    public boolean cancelReport(String reportID, String citizenID) {
        String sql = "UPDATE dbo.tblCitizenReports "
                + "SET status = 'Cancelled', feedbackNote = 'Cancelled by submitter' "
                + "WHERE reportID = ? AND citizenID = ? AND (status = 'Submitted' OR status = 'Pending')";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, reportID);
            ps.setString(2, citizenID);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBContext.close(null, ps, conn);
        }
    }

    // ==========================================
    // 9. Submit citizen rating (User)
    // ==========================================
    public boolean rateReport(String reportID, String citizenID, int rating, String ratingComment) {
        String sql = "UPDATE dbo.tblCitizenReports "
                + "SET rating = ?, ratingComment = ?, ratedDate = GETDATE() "
                + "WHERE reportID = ? AND citizenID = ? AND status = 'Resolved'";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, rating);
            ps.setString(2, ratingComment);
            ps.setString(3, reportID);
            ps.setString(4, citizenID);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBContext.close(null, ps, conn);
        }
    }

    // Helper map ResultSet sang Object
    private CitizenReport mapResultSet(ResultSet rs) throws SQLException {
        CitizenReport r = new CitizenReport();
        r.setReportID(rs.getString("reportID"));
        r.setCitizenID(rs.getString("citizenID"));
        r.setBinID(rs.getString("binID"));
        r.setAreaID(rs.getString("areaID"));
        r.setReportType(rs.getString("reportType"));
        r.setTitle(rs.getString("title"));
        r.setDescription(rs.getString("description"));
        r.setImageURL(rs.getString("imageURL"));
        r.setStatus(rs.getString("status"));
        r.setCreatedDate(rs.getTimestamp("createdDate"));
        r.setVerifiedBy(rs.getString("verifiedBy"));
        r.setVerifiedDate(rs.getTimestamp("verifiedDate"));
        r.setFeedbackNote(rs.getString("feedbackNote"));

        // Extended fields
        double lat = rs.getDouble("latitude");
        if (!rs.wasNull()) {
            r.setLatitude(lat);
        }
        double lng = rs.getDouble("longitude");
        if (!rs.wasNull()) {
            r.setLongitude(lng);
        }
        int rating = rs.getInt("rating");
        if (!rs.wasNull()) {
            r.setRating(rating);
        }
        r.setRatingComment(rs.getString("ratingComment"));
        r.setRatedDate(rs.getTimestamp("ratedDate"));

        r.setCitizenName(rs.getString("citizenName"));
        r.setBinCode(rs.getString("binCode"));
        r.setAreaName(rs.getString("areaName"));
        r.setVerifierName(rs.getString("verifierName"));
        return r;
    }
}
