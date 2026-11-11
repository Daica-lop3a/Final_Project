package dao;


import model.BinInspection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class BinInspectionDAO {

    private static final String SELECT_BASE =
            "SELECT i.inspectionID, i.binID, i.inspectorID, i.inspectionDate, "
            + "i.actualFillPercent, i.sensorFillPercent, i.discrepancyPercent, "
            + "i.physicalCondition, i.actionTaken, i.notes, i.createdDate, "
            + "b.binCode, b.location, b.areaID, a.areaName, u.fullName AS inspectorName "
            + "FROM tblBinInspections i "
            + "INNER JOIN tblWasteBins b ON i.binID = b.binID "
            + "LEFT JOIN tblAreas a ON b.areaID = a.areaID "
            + "LEFT JOIN tblUsers u ON i.inspectorID = u.userID ";

    private BinInspection map(ResultSet rs) throws SQLException {
        BinInspection insp = new BinInspection();
        insp.setInspectionID(rs.getString("inspectionID"));
        insp.setBinID(rs.getString("binID"));
        insp.setInspectorID(rs.getString("inspectorID"));
        insp.setInspectionDate(rs.getTimestamp("inspectionDate"));
        insp.setActualFillPercent(rs.getInt("actualFillPercent"));
        insp.setSensorFillPercent(rs.getInt("sensorFillPercent"));
        insp.setDiscrepancyPercent(rs.getInt("discrepancyPercent"));
        insp.setPhysicalCondition(rs.getString("physicalCondition"));
        insp.setActionTaken(rs.getString("actionTaken"));
        insp.setNotes(rs.getString("notes"));
        insp.setCreatedDate(rs.getTimestamp("createdDate"));
        insp.setBinCode(rs.getString("binCode"));
        insp.setLocation(rs.getString("location"));
        insp.setAreaID(rs.getString("areaID"));
        insp.setAreaName(rs.getString("areaName"));
        insp.setInspectorName(rs.getString("inspectorName"));
        return insp;
    }

    public List<BinInspection> getAll() {
        List<BinInspection> list = new ArrayList<BinInspection>();
        String sql = SELECT_BASE + "ORDER BY i.inspectionDate DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(map(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return list;
    }

    public List<BinInspection> getByAreaIds(List<String> areaIds) {
        List<BinInspection> list = new ArrayList<BinInspection>();
        if (areaIds == null || areaIds.isEmpty()) return list;

        StringBuilder inClause = new StringBuilder();
        for (int i = 0; i < areaIds.size(); i++) {
            if (i > 0) inClause.append(",");
            inClause.append("?");
        }

        String sql = SELECT_BASE + "WHERE b.areaID IN (" + inClause + ") ORDER BY i.inspectionDate DESC";
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
            while (rs.next()) {
                list.add(map(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return list;
    }

    public List<BinInspection> getByBin(String binID) {
        List<BinInspection> list = new ArrayList<BinInspection>();
        if (binID == null || binID.trim().isEmpty()) return list;

        String sql = SELECT_BASE + "WHERE i.binID = ? ORDER BY i.inspectionDate DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, binID.trim());
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(map(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return list;
    }

    public BinInspection findById(String id) {
        if (id == null || id.trim().isEmpty()) return null;
        String sql = SELECT_BASE + "WHERE i.inspectionID = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, id.trim());
            rs = ps.executeQuery();
            if (rs.next()) {
                return map(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return null;
    }

    public boolean insert(BinInspection insp) {
        if (insp == null) return false;
        String sql = "INSERT INTO tblBinInspections (inspectionID, binID, inspectorID, "
                + "inspectionDate, actualFillPercent, sensorFillPercent, discrepancyPercent, "
                + "physicalCondition, actionTaken, notes, createdDate) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, insp.getInspectionID());
            ps.setString(2, insp.getBinID());
            ps.setString(3, insp.getInspectorID());
            ps.setTimestamp(4, insp.getInspectionDate() != null ? insp.getInspectionDate() : new Timestamp(System.currentTimeMillis()));
            ps.setInt(5, insp.getActualFillPercent());
            ps.setInt(6, insp.getSensorFillPercent());
            ps.setInt(7, insp.getDiscrepancyPercent());
            ps.setString(8, insp.getPhysicalCondition());
            ps.setString(9, insp.getActionTaken());
            ps.setString(10, insp.getNotes());
            ps.setTimestamp(11, insp.getCreatedDate() != null ? insp.getCreatedDate() : new Timestamp(System.currentTimeMillis()));
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(null, ps, conn);
        }
        return false;
    }

    public boolean update(BinInspection insp) {
        if (insp == null) return false;
        String sql = "UPDATE tblBinInspections SET binID = ?, inspectorID = ?, "
                + "actualFillPercent = ?, sensorFillPercent = ?, discrepancyPercent = ?, "
                + "physicalCondition = ?, actionTaken = ?, notes = ? "
                + "WHERE inspectionID = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, insp.getBinID());
            ps.setString(2, insp.getInspectorID());
            ps.setInt(3, insp.getActualFillPercent());
            ps.setInt(4, insp.getSensorFillPercent());
            ps.setInt(5, insp.getDiscrepancyPercent());
            ps.setString(6, insp.getPhysicalCondition());
            ps.setString(7, insp.getActionTaken());
            ps.setString(8, insp.getNotes());
            ps.setString(9, insp.getInspectionID());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(null, ps, conn);
        }
        return false;
    }

    public boolean delete(String id) {
        if (id == null || id.trim().isEmpty()) return false;
        String sql = "DELETE FROM tblBinInspections WHERE inspectionID = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, id.trim());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(null, ps, conn);
        }
        return false;
    }

    public int countByAreaIds(List<String> areaIds) {
        if (areaIds == null || areaIds.isEmpty()) return 0;
        StringBuilder inClause = new StringBuilder();
        for (int i = 0; i < areaIds.size(); i++) {
            if (i > 0) inClause.append(",");
            inClause.append("?");
        }
        String sql = "SELECT COUNT(*) FROM tblBinInspections i "
                + "INNER JOIN tblWasteBins b ON i.binID = b.binID "
                + "WHERE b.areaID IN (" + inClause + ")";
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

    public int countDiscrepancies(List<String> areaIds) {
        if (areaIds == null || areaIds.isEmpty()) return 0;
        StringBuilder inClause = new StringBuilder();
        for (int i = 0; i < areaIds.size(); i++) {
            if (i > 0) inClause.append(",");
            inClause.append("?");
        }
        String sql = "SELECT COUNT(*) FROM tblBinInspections i "
                + "INNER JOIN tblWasteBins b ON i.binID = b.binID "
                + "WHERE b.areaID IN (" + inClause + ") AND ABS(i.discrepancyPercent) >= 20";
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
}
