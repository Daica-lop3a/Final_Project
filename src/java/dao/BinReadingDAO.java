/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

/**
 *
 * @author ASUS
 */
import model.BinReading;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class BinReadingDAO {

    public boolean insert(BinReading reading) {

        String sql = "INSERT INTO tblBinReadings "
                + "(binID, fillPercent, measuredAt) "
                + "VALUES (?, ?, ?)";

        Connection cn = null;
        PreparedStatement ps = null;

        try {
            cn = DBContext.getConnection();

            ps = cn.prepareStatement(sql);

            ps.setString(1, reading.getBinID());
            ps.setInt(2, reading.getFillPercent());
            ps.setTimestamp(3, reading.getMeasuredAt());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            throw new RuntimeException(e);

        } finally {
            DBContext.close(ps, cn);
        }
    }

    public List<BinReading> getByBin(String binID) {

        List<BinReading> list = new ArrayList<>();

        String sql = "SELECT readingID, binID, fillPercent, measuredAt "
                + "FROM tblBinReadings "
                + "WHERE binID = ? "
                + "ORDER BY measuredAt DESC";

        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            cn = DBContext.getConnection();

            ps = cn.prepareStatement(sql);
            ps.setString(1, binID);

            rs = ps.executeQuery();

            while (rs.next()) {

                BinReading reading = new BinReading();

                reading.setReadingID(rs.getInt("readingID"));
                reading.setBinID(rs.getString("binID"));
                reading.setFillPercent(rs.getInt("fillPercent"));
                reading.setMeasuredAt(rs.getTimestamp("measuredAt"));

                list.add(reading);
            }

        } catch (Exception e) {
            e.printStackTrace();

        } finally {
            DBContext.close(rs, ps, cn);
        }

        return list;
    }
}
