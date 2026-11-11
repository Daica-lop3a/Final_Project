package dao;

import model.Device;
import model.WasteBin;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO qu???n l?? thi???t b??? c???m bi???n IoT (tblDevices)
 * Supports Device Management module
 */
public class DeviceDAO {

    private static final String SELECT_BASE
            = "SELECT d.deviceID, d.deviceName, d.deviceType, d.binID, d.status, "
            + "d.batteryLevel, d.lastPing, d.installedDate, d.firmwareVersion, "
            + "b.binCode, b.location AS binLocation, "
            + "(SELECT COUNT(*) FROM dbo.tblMaintenance m WHERE m.binID = d.binID AND m.status = 'Completed') AS repairCount "
            + "FROM dbo.tblDevices d "
            + "LEFT JOIN dbo.tblWasteBins b ON d.binID = b.binID ";

    private Device mapResultSet(ResultSet rs) throws SQLException {
        Device dev = new Device();
        dev.setDeviceId(rs.getString("deviceID"));
        dev.setDeviceName(rs.getString("deviceName"));
        dev.setDeviceType(rs.getString("deviceType"));
        dev.setBinId(rs.getString("binID"));
        dev.setStatus(rs.getString("status"));
        dev.setBatteryLevel(rs.getInt("batteryLevel"));
        dev.setLastPing(rs.getTimestamp("lastPing"));
        dev.setInstalledDate(rs.getTimestamp("installedDate"));
        try {
            dev.setFirmwareVersion(rs.getString("firmwareVersion"));
            dev.setRepairCount(rs.getInt("repairCount"));
        } catch (SQLException ignored) {}
        dev.setBinCode(rs.getString("binCode"));
        dev.setBinLocation(rs.getString("binLocation"));
        return dev;
    }

    public List<Device> getAll() {
        List<Device> list = new ArrayList<Device>();
        String sql = SELECT_BASE + "ORDER BY d.deviceID";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
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

    public List<Device> search(String keyword, String deviceType, String status) {
        List<Device> list = new ArrayList<Device>();
        StringBuilder sql = new StringBuilder(SELECT_BASE);
        sql.append("WHERE 1 = 1 ");

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (d.deviceID LIKE ? OR d.deviceName LIKE ? OR b.binCode LIKE ? OR b.location LIKE ?) ");
        }
        if (deviceType != null && !deviceType.trim().isEmpty()) {
            sql.append("AND d.deviceType = ? ");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append("AND d.status = ? ");
        }

        sql.append("ORDER BY d.deviceID");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql.toString());
            int idx = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = "%" + keyword.trim() + "%";
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
            }
            if (deviceType != null && !deviceType.trim().isEmpty()) {
                ps.setString(idx++, deviceType.trim());
            }
            if (status != null && !status.trim().isEmpty()) {
                ps.setString(idx++, status.trim());
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

    public Device findById(String deviceId) {
        if (deviceId == null || deviceId.trim().isEmpty()) {
            return null;
        }
        String sql = SELECT_BASE + "WHERE d.deviceID = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, deviceId.trim());
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

    public Device findByBinID(String binID) {
        if (binID == null || binID.trim().isEmpty()) {
            return null;
        }
        String sql = SELECT_BASE + "WHERE d.binID = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, binID.trim());
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

    public boolean insert(Device dev) {
        String sql = "INSERT INTO dbo.tblDevices (deviceID, deviceName, deviceType, binID, status, batteryLevel, lastPing, installedDate, firmwareVersion) "
                + "VALUES (?, ?, ?, ?, ?, ?, GETDATE(), ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, dev.getDeviceId().trim());
            ps.setString(2, dev.getDeviceName().trim());
            ps.setString(3, dev.getDeviceType().trim());

            if (dev.getBinId() != null && !dev.getBinId().trim().isEmpty()) {
                ps.setString(4, dev.getBinId().trim());
            } else {
                ps.setNull(4, java.sql.Types.VARCHAR);
            }

            ps.setString(5, dev.getStatus() != null ? dev.getStatus() : "Active");
            ps.setInt(6, dev.getBatteryLevel() > 0 ? dev.getBatteryLevel() : 100);

            if (dev.getInstalledDate() != null) {
                ps.setTimestamp(7, dev.getInstalledDate());
            } else {
                ps.setTimestamp(7, new Timestamp(System.currentTimeMillis()));
            }

            ps.setString(8, dev.getFirmwareVersion() != null ? dev.getFirmwareVersion() : "v1.2.0");

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBContext.close(null, ps, conn);
        }
        return false;
    }

    public boolean update(Device dev) {
        String sql = "UPDATE dbo.tblDevices SET deviceName = ?, deviceType = ?, binID = ?, status = ?, batteryLevel = ?, firmwareVersion = ? "
                + "WHERE deviceID = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, dev.getDeviceName().trim());
            ps.setString(2, dev.getDeviceType().trim());

            if (dev.getBinId() != null && !dev.getBinId().trim().isEmpty()) {
                ps.setString(3, dev.getBinId().trim());
            } else {
                ps.setNull(3, java.sql.Types.VARCHAR);
            }

            ps.setString(4, dev.getStatus() != null ? dev.getStatus() : "Active");
            ps.setInt(5, dev.getBatteryLevel());
            ps.setString(6, dev.getFirmwareVersion() != null ? dev.getFirmwareVersion() : "v1.2.0");
            ps.setString(7, dev.getDeviceId().trim());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBContext.close(null, ps, conn);
        }
        return false;
    }

    public boolean delete(String deviceId) {
        if (deviceId == null || deviceId.trim().isEmpty()) {
            return false;
        }
        String sql = "DELETE FROM dbo.tblDevices WHERE deviceID = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, deviceId.trim());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBContext.close(null, ps, conn);
        }
        return false;
    }

    // ============================================================
    // N??NG CAO: PH??T HI???N TH??NG R??C CH??A C?? THI???T B??? HO???C B??? G??N TR??NG
    // ============================================================

    /**
     * T??m danh s??ch Th??ng r??c ch??a ???????c g???n b???t k??? thi???t b??? c???m bi???n n??o
     */
    public List<WasteBin> getUnassignedBins() {
        List<WasteBin> list = new ArrayList<WasteBin>();
        String sql = "SELECT b.binID, b.binCode, b.location, b.latitude, b.longitude, b.capacity, b.currentFill, b.status, b.areaID "
                + "FROM dbo.tblWasteBins b "
                + "WHERE b.binID NOT IN (SELECT d.binID FROM dbo.tblDevices d WHERE d.binID IS NOT NULL) "
                + "ORDER BY b.binID";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
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
                list.add(bin);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return list;
    }

    /**
     * Find list of Waste Bins with duplicate assigned devices (more than 1 device linked to the same bin).
     */
    public List<String> getDuplicateAssignedBins() {
        List<String> list = new ArrayList<String>();
        String sql = "SELECT binID, COUNT(*) AS devCount "
                + "FROM dbo.tblDevices "
                + "WHERE binID IS NOT NULL "
                + "GROUP BY binID "
                + "HAVING COUNT(*) > 1";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(rs.getString("binID") + " (" + rs.getInt("devCount") + " devices)");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return list;
    }

    /**
     * Detect sensors stuck at constant reading across successive telemetry inputs.
     * Returns sensors where last 5 consecutive readings are identical.
     */
    public List<String> getStuckSensors() {
        List<String> list = new ArrayList<String>();
        String sql = "SELECT b.binCode, b.location, MIN(sub.fillPercent) AS stuckVal "
                   + "FROM ("
                   + "    SELECT binID, fillPercent, ROW_NUMBER() OVER (PARTITION BY binID ORDER BY measuredAt DESC) AS rn "
                   + "    FROM dbo.tblBinReadings"
                   + ") sub "
                   + "JOIN dbo.tblWasteBins b ON sub.binID = b.binID "
                   + "WHERE sub.rn <= 5 "
                   + "GROUP BY sub.binID, b.binCode, b.location "
                   + "HAVING COUNT(*) >= 5 AND MIN(sub.fillPercent) = MAX(sub.fillPercent)";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(rs.getString("binCode") + " (" + rs.getString("location") + ") -> Stuck at " + rs.getInt("stuckVal") + "% fill across 5 consecutive cycles");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return list;
    }
}
