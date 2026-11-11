package dao;

import model.AdminPasswordRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO handling Admin password reset requests for Super Admin approval.
 * Admin Approval and Password Management.
 */
public class AdminPasswordRequestDAO {

    private static final String SELECT_ALL
            = "SELECT r.requestID, r.adminID, u.fullName AS adminName, u.email AS adminEmail, "
            + "r.reason, r.status, r.temporaryPassword, r.requestDate, "
            + "r.resolvedBy, s.fullName AS resolverName, r.resolvedDate, r.resolutionNote "
            + "FROM dbo.tblAdminPasswordRequests r "
            + "JOIN dbo.tblUsers u ON r.adminID = u.userID "
            + "LEFT JOIN dbo.tblUsers s ON r.resolvedBy = s.userID "
            + "ORDER BY CASE r.status WHEN 'Pending' THEN 1 ELSE 2 END, r.requestDate DESC";

    public List<AdminPasswordRequest> getAllRequests() {
        List<AdminPasswordRequest> list = new ArrayList<AdminPasswordRequest>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(SELECT_ALL);
            rs = ps.executeQuery();

            while (rs.next()) {
                AdminPasswordRequest req = new AdminPasswordRequest();
                req.setRequestId(rs.getInt("requestID"));
                req.setAdminId(rs.getString("adminID"));
                req.setAdminName(rs.getString("adminName"));
                req.setAdminEmail(rs.getString("adminEmail"));
                req.setReason(rs.getString("reason"));
                req.setStatus(rs.getString("status"));
                req.setTemporaryPassword(rs.getString("temporaryPassword"));
                req.setRequestDate(rs.getTimestamp("requestDate"));
                req.setResolvedBy(rs.getString("resolvedBy"));
                req.setResolverName(rs.getString("resolverName"));
                req.setResolvedDate(rs.getTimestamp("resolvedDate"));
                req.setResolutionNote(rs.getString("resolutionNote"));
                list.add(req);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }

        return list;
    }

    public int countPending() {
        String sql = "SELECT COUNT(*) FROM dbo.tblAdminPasswordRequests WHERE status = 'Pending'";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
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

    public AdminPasswordRequest findById(int requestId) {
        String sql = "SELECT r.requestID, r.adminID, u.fullName AS adminName, u.email AS adminEmail, "
                + "r.reason, r.status, r.temporaryPassword, r.requestDate, "
                + "r.resolvedBy, s.fullName AS resolverName, r.resolvedDate, r.resolutionNote "
                + "FROM dbo.tblAdminPasswordRequests r "
                + "JOIN dbo.tblUsers u ON r.adminID = u.userID "
                + "LEFT JOIN dbo.tblUsers s ON r.resolvedBy = s.userID "
                + "WHERE r.requestID = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, requestId);
            rs = ps.executeQuery();

            if (rs.next()) {
                AdminPasswordRequest req = new AdminPasswordRequest();
                req.setRequestId(rs.getInt("requestID"));
                req.setAdminId(rs.getString("adminID"));
                req.setAdminName(rs.getString("adminName"));
                req.setAdminEmail(rs.getString("adminEmail"));
                req.setReason(rs.getString("reason"));
                req.setStatus(rs.getString("status"));
                req.setTemporaryPassword(rs.getString("temporaryPassword"));
                req.setRequestDate(rs.getTimestamp("requestDate"));
                req.setResolvedBy(rs.getString("resolvedBy"));
                req.setResolverName(rs.getString("resolverName"));
                req.setResolvedDate(rs.getTimestamp("resolvedDate"));
                req.setResolutionNote(rs.getString("resolutionNote"));
                return req;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }

        return null;
    }

    public boolean createRequest(String adminId, String reason) {
        String sql = "INSERT INTO dbo.tblAdminPasswordRequests (adminID, reason, status, requestDate) "
                + "VALUES (?, ?, 'Pending', GETDATE())";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, adminId);
            ps.setString(2, reason != null ? reason.trim() : "Admin password reset request");
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(null, ps, conn);
        }

        return false;
    }

    public boolean approve(int requestId, String superAdminId, String tempPassword, String note) {
        String sql = "UPDATE dbo.tblAdminPasswordRequests "
                + "SET status = 'Approved', temporaryPassword = ?, resolvedBy = ?, resolvedDate = GETDATE(), resolutionNote = ? "
                + "WHERE requestID = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, tempPassword);
            ps.setString(2, superAdminId);
            ps.setString(3, note != null ? note.trim() : "Approved by Super Admin");
            ps.setInt(4, requestId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(null, ps, conn);
        }

        return false;
    }

    public boolean reject(int requestId, String superAdminId, String note) {
        String sql = "UPDATE dbo.tblAdminPasswordRequests "
                + "SET status = 'Rejected', resolvedBy = ?, resolvedDate = GETDATE(), resolutionNote = ? "
                + "WHERE requestID = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, superAdminId);
            ps.setString(2, note != null ? note.trim() : "Rejected by Super Admin");
            ps.setInt(3, requestId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(null, ps, conn);
        }

        return false;
    }
}
