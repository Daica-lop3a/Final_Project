package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import model.Discrepancy;

/**
 * DAO for Audit Data Discrepancies (tblDiscrepancies)
 * Restricted to Auditor (AUD) and Super Admin (SAD).
 */
public class DiscrepancyDAO {

    private static final String SELECT_BASE
            = "SELECT d.discrepancyID, d.title, d.discrepancyType, d.targetEntity, d.targetID, "
            + "d.severity, d.status, d.detectedBy, d.detectedDate, d.description, "
            + "d.investigationNotes, d.conclusionNotes, d.closedBy, d.closedDate, "
            + "u1.fullName AS detectedByName, u2.fullName AS closedByName "
            + "FROM dbo.tblDiscrepancies d "
            + "LEFT JOIN dbo.tblUsers u1 ON d.detectedBy = u1.userID "
            + "LEFT JOIN dbo.tblUsers u2 ON d.closedBy = u2.userID ";

    // ==========================================
    // 1. Create new discrepancy record (CREATE)
    // ==========================================
    public boolean create(Discrepancy d) {
        String sql = "INSERT INTO dbo.tblDiscrepancies "
                + "(discrepancyID, title, discrepancyType, targetEntity, targetID, "
                + "severity, status, detectedBy, detectedDate, description, investigationNotes) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), ?, ?)";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, d.getDiscrepancyID());
            ps.setString(2, d.getTitle());
            ps.setString(3, d.getDiscrepancyType());
            ps.setString(4, d.getTargetEntity());
            ps.setString(5, d.getTargetID());
            ps.setString(6, d.getSeverity() != null ? d.getSeverity() : "Medium");
            ps.setString(7, d.getStatus() != null ? d.getStatus() : "Open");
            ps.setString(8, d.getDetectedBy());
            ps.setString(9, d.getDescription());
            ps.setString(10, d.getInvestigationNotes());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBContext.close(null, ps, conn);
        }
    }

    // ==========================================
    // 2. Update investigation findings (UPDATE)
    // ==========================================
    public boolean update(Discrepancy d) {
        String sql = "UPDATE dbo.tblDiscrepancies "
                + "SET title = ?, discrepancyType = ?, severity = ?, status = ?, "
                + "description = ?, investigationNotes = ? "
                + "WHERE discrepancyID = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, d.getTitle());
            ps.setString(2, d.getDiscrepancyType());
            ps.setString(3, d.getSeverity());
            ps.setString(4, d.getStatus());
            ps.setString(5, d.getDescription());
            ps.setString(6, d.getInvestigationNotes());
            ps.setString(7, d.getDiscrepancyID());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBContext.close(null, ps, conn);
        }
    }

    // ==========================================
    // 3. Close discrepancy case (CLOSE CASE)
    // ==========================================
    public boolean closeCase(String discrepancyID, String conclusionNotes, String closedBy) {
        String sql = "UPDATE dbo.tblDiscrepancies "
                + "SET status = 'Closed', conclusionNotes = ?, closedBy = ?, closedDate = GETDATE() "
                + "WHERE discrepancyID = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, conclusionNotes);
            ps.setString(2, closedBy);
            ps.setString(3, discrepancyID);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBContext.close(null, ps, conn);
        }
    }

    // ==========================================
    // 4. Query case by ID
    // ==========================================
    public Discrepancy getByID(String discrepancyID) {
        String sql = SELECT_BASE + "WHERE d.discrepancyID = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, discrepancyID);
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
    // 5. LY DANH SCH C B LC V PHN TRANG
    // ==========================================
    public List<Discrepancy> getFiltered(String type, String status, String severity,
                                         String search, int page, int pageSize) {
        List<Discrepancy> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(SELECT_BASE);
        sql.append("WHERE 1 = 1 ");

        if (type != null && !type.trim().isEmpty()) {
            sql.append("AND d.discrepancyType = ? ");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append("AND d.status = ? ");
        }
        if (severity != null && !severity.trim().isEmpty()) {
            sql.append("AND d.severity = ? ");
        }
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (d.discrepancyID LIKE ? OR d.title LIKE ? OR d.targetID LIKE ? OR d.description LIKE ?) ");
        }

        sql.append("ORDER BY d.detectedDate DESC ");
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql.toString());
            int idx = 1;
            if (type != null && !type.trim().isEmpty()) {
                ps.setString(idx++, type);
            }
            if (status != null && !status.trim().isEmpty()) {
                ps.setString(idx++, status);
            }
            if (severity != null && !severity.trim().isEmpty()) {
                ps.setString(idx++, severity);
            }
            if (search != null && !search.trim().isEmpty()) {
                String kw = "%" + search + "%";
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
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
    // 5B. GET BY DATE RANGE FOR AUDIT EXPORT
    // ==========================================
    public List<Discrepancy> getByDateRange(Timestamp from, Timestamp to, String type, String status) {
        List<Discrepancy> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(SELECT_BASE);
        sql.append("WHERE 1 = 1 ");

        if (from != null) {
            sql.append("AND d.detectedDate >= ? ");
        }
        if (to != null) {
            sql.append("AND d.detectedDate <= ? ");
        }
        if (type != null && !type.trim().isEmpty()) {
            sql.append("AND d.discrepancyType = ? ");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append("AND d.status = ? ");
        }

        sql.append("ORDER BY d.detectedDate DESC");

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
            if (type != null && !type.trim().isEmpty()) {
                ps.setString(idx++, type);
            }
            if (status != null && !status.trim().isEmpty()) {
                ps.setString(idx++, status);
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
    // 6. Count cases matching criteria
    // ==========================================
    public int countFiltered(String type, String status, String severity, String search) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM dbo.tblDiscrepancies d WHERE 1 = 1 ");

        if (type != null && !type.trim().isEmpty()) {
            sql.append("AND d.discrepancyType = ? ");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append("AND d.status = ? ");
        }
        if (severity != null && !severity.trim().isEmpty()) {
            sql.append("AND d.severity = ? ");
        }
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (d.discrepancyID LIKE ? OR d.title LIKE ? OR d.targetID LIKE ? OR d.description LIKE ?) ");
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql.toString());
            int idx = 1;
            if (type != null && !type.trim().isEmpty()) {
                ps.setString(idx++, type);
            }
            if (status != null && !status.trim().isEmpty()) {
                ps.setString(idx++, status);
            }
            if (severity != null && !severity.trim().isEmpty()) {
                ps.setString(idx++, severity);
            }
            if (search != null && !search.trim().isEmpty()) {
                String kw = "%" + search + "%";
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
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

    public List<Discrepancy> getAll() {
        return getFiltered(null, null, null, null, 1, 1000);
    }

    public int countTotal() {
        return countFiltered(null, null, null, null);
    }

    public int countByStatus(String status) {
        return countFiltered(null, status, null, null);
    }

    public List<Discrepancy> getRecent(int limit) {
        return getFiltered(null, null, null, null, 1, limit);
    }

    private Discrepancy mapResultSet(ResultSet rs) throws SQLException {
        Discrepancy d = new Discrepancy();
        d.setDiscrepancyID(rs.getString("discrepancyID"));
        d.setTitle(rs.getString("title"));
        d.setDiscrepancyType(rs.getString("discrepancyType"));
        d.setTargetEntity(rs.getString("targetEntity"));
        d.setTargetID(rs.getString("targetID"));
        d.setSeverity(rs.getString("severity"));
        d.setStatus(rs.getString("status"));
        d.setDetectedBy(rs.getString("detectedBy"));
        d.setDetectedDate(rs.getTimestamp("detectedDate"));
        d.setDescription(rs.getString("description"));
        d.setInvestigationNotes(rs.getString("investigationNotes"));
        d.setConclusionNotes(rs.getString("conclusionNotes"));
        d.setClosedBy(rs.getString("closedBy"));
        d.setClosedDate(rs.getTimestamp("closedDate"));

        d.setDetectedByName(rs.getString("detectedByName"));
        d.setClosedByName(rs.getString("closedByName"));
        return d;
    }
}
