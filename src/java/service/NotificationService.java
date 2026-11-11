package service;

import dao.MaintenanceDAO;
import dao.NotificationDAO;
import dao.UserDAO;
import dao.WasteBinDAO;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

import model.Alert;
import model.AppUser;
import model.CollectionRequest;
import model.Maintenance;
import model.Notification;
import model.WasteBin;

/**
 * Determines notification recipients and saves notifications to tblNotifications.
 *
 * - High_Fill / Overflow alerts: Staff and Manager assigned to the bin's area.
 * - Equipment alerts: Manager assigned to the bin's area and technicians
 *   with active maintenance tasks for that bin.
 * - Maintenance updates: Assigned technician and the Manager of the bin's area.
 * - Collection updates: Assigned Staff and the Manager of the bin's area.
 *
 * Admin users are excluded because they can view system-wide records.
 */
public class NotificationService {

    private final NotificationDAO notifications
            = new NotificationDAO();

    private final UserDAO users
            = new UserDAO();

    private final MaintenanceDAO maintenances
            = new MaintenanceDAO();

    private final WasteBinDAO bins
            = new WasteBinDAO();

    // =========================================================
    // ALERT
    // =========================================================
   public int dispatchAlert(Alert alert) {

    if (alert == null
            || alert.getBinID() == null
            || alert.getAlertID() == null) {
        return 0;
    }

    WasteBin bin = bins.findByID(alert.getBinID());

    if (bin == null) {
        return 0;
    }

    Set<String> recipients = new LinkedHashSet<String>();

    recipients.addAll(
            getUserIDsByArea("MGR", bin.getAreaID()));

    String type = alert.getAlertType();

    boolean fillAlert = "High_Fill".equalsIgnoreCase(type)
            || "HighFill".equalsIgnoreCase(type)
            || "Overflow".equalsIgnoreCase(type)
            || "Full".equalsIgnoreCase(type);

    if (fillAlert) {
        recipients.addAll(
                getUserIDsByArea("STF", bin.getAreaID()));
    } else {
        recipients.addAll(
                maintenances.getActiveTechnicianIdsByBin(
                        bin.getBinID()));
    }

    String message = type + " alert for "
            + bin.getBinCode() + ": " + alert.getMessage();

    int sent = 0;

    for (String userID : recipients) {
        if (send(
                userID,
                Notification.TYPE_ALERT,
                alert.getAlertID(),
                message)) {
            sent++;
        }
    }

    return sent;
}

    // =========================================================
    // MAINTENANCE
    // =========================================================

    /**
     * Notify the newly assigned technician when an Admin or Manager
     * creates a maintenance task or changes its assigned technician.
     */
    public void maintenanceAssigned(Maintenance m) {

        if (m == null) {
            return;
        }

        WasteBin bin = bins.findByID(m.getBinID());

        send(
                m.getTechnicianID(),
                Notification.TYPE_MAINTENANCE,
                m.getMaintenanceID(),
                "You have been assigned to maintenance task for "
                + binCode(bin, m.getBinID())
                + " (" + m.getMaintenanceType() + ")"
                + schedule(m) + ".");
    }

    /**
     * Notify the assigned technician when an Admin or Manager
     * changes the maintenance status.
     */
    public void maintenanceChangedByManager(
            Maintenance m,
            String actorID) {

        if (m == null) {
            return;
        }

        if (m.getTechnicianID() != null
                && m.getTechnicianID().equals(actorID)) {
            return;
        }

        WasteBin bin = bins.findByID(m.getBinID());

        send(
                m.getTechnicianID(),
                Notification.TYPE_MAINTENANCE,
                m.getMaintenanceID(),
                "Maintenance " + m.getMaintenanceID() + " ("
                + binCode(bin, m.getBinID())
                + ") has been updated: " + m.getStatus() + ".");
    }

    /**
     * Notify the Manager of the bin's area when a technician
     * updates the maintenance status or result.
     */
    public void maintenanceUpdatedByTechnician(
            Maintenance m,
            String actorID) {

        if (m == null) {
            return;
        }

        WasteBin bin = bins.findByID(m.getBinID());

        if (bin == null) {
            return;
        }

        String message = "Technician " + actorID
                + " updated maintenance " + m.getMaintenanceID()
                + " (" + bin.getBinCode() + "): "
                + m.getStatus() + ".";

        for (String managerID
                : getUserIDsByArea("MGR", bin.getAreaID())) {

            send(
                    managerID,
                    Notification.TYPE_MAINTENANCE,
                    m.getMaintenanceID(),
                    message);
        }
    }

    // =========================================================
    // COLLECTION
    // =========================================================

    /**
     * Notify the assigned Staff member when an Admin or Manager
     * assigns a collection request or changes its assigned Staff member.
     */
    public void collectionAssigned(CollectionRequest r) {

        if (r == null) {
            return;
        }

        WasteBin bin = bins.findByID(r.getBinID());

        send(
                r.getStaffID(),
                Notification.TYPE_COLLECTION,
                r.getRequestID(),
                "You have been assigned to collect bin "
                + binCode(bin, r.getBinID())
                + " (Priority: " + r.getPriority() + ").");
    }

    /**
     * Notify the assigned Staff member when an Admin or Manager
     * changes the collection status or priority.
     */
    public void collectionChangedByManager(
            CollectionRequest r,
            String actorID) {

        if (r == null) {
            return;
        }

        if (r.getStaffID() != null
                && r.getStaffID().equals(actorID)) {
            return;
        }

        WasteBin bin = bins.findByID(r.getBinID());

        send(
                r.getStaffID(),
                Notification.TYPE_COLLECTION,
                r.getRequestID(),
                "Collection request " + r.getRequestID() + " ("
                + binCode(bin, r.getBinID())
                + ") updated: " + r.getStatus()
                + ", Priority: " + r.getPriority() + ".");
    }

    /**
     * Notify the Manager of the bin's area when Staff updates
     * a collection request's status or result.
     */
    public void collectionUpdatedByStaff(
            CollectionRequest r,
            String actorID) {

        if (r == null) {
            return;
        }

        WasteBin bin = bins.findByID(r.getBinID());

        if (bin == null) {
            return;
        }

        String message = "Staff " + actorID
                + " updated collection request " + r.getRequestID()
                + " (" + bin.getBinCode() + "): "
                + r.getStatus() + ".";

        for (String managerID
                : getUserIDsByArea("MGR", bin.getAreaID())) {

            send(
                    managerID,
                    Notification.TYPE_COLLECTION,
                    r.getRequestID(),
                    message);
        }
    }

    // =========================================================
    // CLEAN UP
    // =========================================================
    public void removeFor(String notifType, String refID) {

        if (refID != null && !refID.trim().isEmpty()) {
            notifications.deleteByRef(notifType, refID);
        }
    }

    // =========================================================
    // GET USER IDS BY AREA AND ROLE
    // =========================================================
    private List<String> getUserIDsByArea(
            String roleID,
            String areaID) {

        List<String> result = new ArrayList<String>();

        if (roleID == null
                || roleID.trim().isEmpty()
                || areaID == null
                || areaID.trim().isEmpty()) {

            return result;
        }

        List<AppUser> areaUsers = users.search("", roleID);

        for (AppUser user : areaUsers) {

            if (user.getUserId() == null
                    || user.getAreaID() == null) {
                continue;
            }

            if (areaID.trim().equalsIgnoreCase(
                    user.getAreaID().trim())) {

                result.add(user.getUserId());
            }
        }

        return result;
    }

    // =========================================================
    // SEND NOTIFICATION
    // =========================================================
    private boolean send(
            String userID,
            String type,
            String refID,
            String message) {

        if (userID == null || userID.trim().isEmpty()) {
            return false;
        }

        if (message != null && message.length() > 500) {
            message = message.substring(0, 497) + "...";
        }

        return notifications.insert(
                userID,
                type,
                refID,
                message);
    }

    // =========================================================
    // GET BIN CODE
    // =========================================================
    private String binCode(
            WasteBin bin,
            String fallback) {

        return bin != null ? bin.getBinCode() : fallback;
    }

    // =========================================================
    // FORMAT MAINTENANCE SCHEDULE
    // =========================================================
    private String schedule(Maintenance m) {

        if (m.getScheduledDate() == null) {
            return "";
        }

        String s = m.getScheduledDate().toString();

        // Format: yyyy-MM-dd HH:mm
        return ", scheduled for " + (s.length() >= 16
                ? s.substring(0, 16) : s);
    }
}