package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Notification;

public class NotificationDAO {

    private static final String INSERT
            = "INSERT INTO tblNotifications "
            + "(userID, notifType, refID, message) "
            + "VALUES (?, ?, ?, ?)";

    private static final String GET_BY_USER
            = "SELECT notificationID, userID, notifType, refID, "
            + "message, createdDate, isRead "
            + "FROM tblNotifications "
            + "WHERE userID = ? "
            + "ORDER BY createdDate DESC, notificationID DESC";

    private static final String COUNT_UNREAD
            = "SELECT COUNT(*) FROM tblNotifications "
            + "WHERE userID = ? AND isRead = 0";

    private static final String MARK_READ
            = "UPDATE tblNotifications SET isRead = 1 "
            + "WHERE notificationID = ? AND userID = ?";

    private static final String MARK_READ_BY_REF
            = "UPDATE tblNotifications SET isRead = 1 "
            + "WHERE userID = ? AND notifType = ? "
            + "AND refID = ? AND isRead = 0";

    private static final String MARK_ALL_READ
            = "UPDATE tblNotifications SET isRead = 1 "
            + "WHERE userID = ? AND isRead = 0";

    private static final String DELETE_BY_REF
            = "DELETE FROM tblNotifications "
            + "WHERE notifType = ? AND refID = ?";

    // =========================================================
    // INSERT
    // =========================================================
    public boolean insert(String userID, String notifType,
            String refID, String message) {

        Connection conn = null;
        PreparedStatement ptm = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(INSERT);

            ptm.setString(1, userID);
            ptm.setString(2, notifType);
            ptm.setString(3, refID);
            ptm.setString(4, message);

            return ptm.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(ptm, conn);
        }

        return false;
    }

    // =========================================================
    // GET NOTIFICATIONS BY USER
    // =========================================================
    public List<Notification> getByUser(String userID) {

        List<Notification> list = new ArrayList<Notification>();

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(GET_BY_USER);
            ptm.setString(1, userID);

            rs = ptm.executeQuery();

            while (rs.next()) {
                Notification notification = new Notification();

                notification.setNotificationID(
                        rs.getInt("notificationID"));
                notification.setUserID(rs.getString("userID"));
                notification.setNotifType(rs.getString("notifType"));
                notification.setRefID(rs.getString("refID"));
                notification.setMessage(rs.getString("message"));
                notification.setCreatedDate(
                        rs.getTimestamp("createdDate"));
                notification.setRead(rs.getBoolean("isRead"));

                list.add(notification);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ptm, conn);
        }

        return list;
    }

    // =========================================================
    // COUNT UNREAD NOTIFICATIONS
    // =========================================================
    public int countUnread(String userID) {

        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(COUNT_UNREAD);
            ptm.setString(1, userID);

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
    // MARK ONE NOTIFICATION AS READ
    // =========================================================
    public boolean markRead(int notificationID, String userID) {

        Connection conn = null;
        PreparedStatement ptm = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(MARK_READ);

            ptm.setInt(1, notificationID);
            ptm.setString(2, userID);

            return ptm.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(ptm, conn);
        }

        return false;
    }

    // =========================================================
    // MARK NOTIFICATIONS AS READ BY REFERENCE
    // =========================================================
    public boolean markReadByRef(String userID, String notifType,
            String refID) {

        Connection conn = null;
        PreparedStatement ptm = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(MARK_READ_BY_REF);

            ptm.setString(1, userID);
            ptm.setString(2, notifType);
            ptm.setString(3, refID);

            return ptm.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(ptm, conn);
        }

        return false;
    }

    // =========================================================
    // MARK ALL NOTIFICATIONS AS READ
    // =========================================================
    public boolean markAllRead(String userID) {

        Connection conn = null;
        PreparedStatement ptm = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(MARK_ALL_READ);
            ptm.setString(1, userID);

            return ptm.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(ptm, conn);
        }

        return false;
    }

    // =========================================================
    // DELETE NOTIFICATIONS BY REFERENCE
    // =========================================================
    public boolean deleteByRef(String notifType, String refID) {

        Connection conn = null;
        PreparedStatement ptm = null;

        try {
            conn = DBContext.getConnection();
            ptm = conn.prepareStatement(DELETE_BY_REF);

            ptm.setString(1, notifType);
            ptm.setString(2, refID);

            return ptm.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(ptm, conn);
        }

        return false;
    }
}
