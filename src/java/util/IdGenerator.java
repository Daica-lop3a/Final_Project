package util;

import dao.DBContext;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Sequential ID Generator Utility
 * Generates next sequential IDs (e.g., BIN-011, REQ-009, REP-003, Area6).
 * Replaces random UUIDs with clear, predictable sequential business keys.
 */
public class IdGenerator {

    private static final Pattern NUMBER_PATTERN = Pattern.compile("^(\\d+)\\s*$");

    /**
     * Query table and find the highest numerical suffix matching prefix, then return next ID.
     *
     * @param tableName database table name
     * @param columnName column name holding the primary key ID
     * @param prefix text prefix such as "BIN-", "REQ-", "Area"
     * @param paddingLength number of digits for zero-padding (e.g. 3 for "001")
     * @return next sequential ID string
     */
    public static synchronized String getNextId(String tableName, String columnName, String prefix, int paddingLength) {
        int maxNumber = 0;
        String sql = "SELECT " + columnName + " FROM dbo." + tableName;

        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            while (rs.next()) {
                String val = rs.getString(1);
                if (val != null && val.trim().startsWith(prefix)) {
                    String sub = val.trim().substring(prefix.length());
                    Matcher m = NUMBER_PATTERN.matcher(sub);
                    if (m.find()) {
                        try {
                            int num = Integer.parseInt(m.group(1));
                            if (num > maxNumber) {
                                maxNumber = num;
                            }
                        } catch (NumberFormatException ignored) {}
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, stmt, conn);
        }

        int nextNumber = maxNumber + 1;
        if (paddingLength <= 1) {
            return prefix + nextNumber;
        }
        String format = "%0" + paddingLength + "d";
        return prefix + String.format(format, nextNumber);
    }

    /** Next Waste Bin ID (e.g., BIN-011) */
    public static String nextBinId() {
        return getNextId("tblWasteBins", "binID", "BIN-", 3);
    }

    /** Next IoT Device ID (e.g., DEV-011) */
    public static String nextDeviceId() {
        return getNextId("tblDevices", "deviceID", "DEV-", 3);
    }

    /** Next Campus Area ID (e.g., AREA-06) */
    public static String nextAreaId() {
        return getNextId("tblAreas", "areaID", "AREA-", 2);
    }

    /** Next User Account ID (e.g., STF-002, TEC-001, MGR-001, ADM-001, USR-004) */
    public static String nextUserId(String roleId) {
        String prefix = "USR-";
        if (roleId != null && !roleId.trim().isEmpty()) {
            String r = roleId.trim().toUpperCase();
            switch (r) {
                case "SAD": prefix = "SAD-"; break;
                case "ADM": prefix = "ADM-"; break;
                case "MGR": prefix = "MGR-"; break;
                case "SUP": prefix = "SUP-"; break;
                case "STF": prefix = "STF-"; break;
                case "TEC": prefix = "TEC-"; break;
                case "AUD": prefix = "AUD-"; break;
                case "USR": prefix = "USR-"; break;
                default: prefix = r + "-"; break;
            }
        }
        return getNextId("tblUsers", "userId", prefix, 3);
    }

    /** Next Collection Task Request ID (e.g., REQ-009) */
    public static String nextCollectionRequestId() {
        return getNextId("tblCollectionRequests", "requestID", "REQ-", 3);
    }

    /** Next Maintenance Request ID (e.g., MNT-007) */
    public static String nextMaintenanceId() {
        return getNextId("tblMaintenance", "maintenanceID", "MNT-", 3);
    }

    /** Next Bin Physical Inspection ID (e.g., INSP-004) */
    public static String nextInspectionId() {
        return getNextId("tblBinInspections", "inspectionID", "INSP-", 3);
    }

    /** Next Citizen Feedback Report ID (e.g., REP-003) */
    public static String nextCitizenReportId() {
        return getNextId("tblCitizenReports", "reportID", "REP-", 3);
    }

    /** Next System Alert ID (e.g., ALT-004) */
    public static String nextAlertId() {
        return getNextId("tblAlerts", "alertID", "ALT-", 3);
    }

    /** Next Audit Discrepancy Case ID (e.g., DISC-002) */
    public static String nextDiscrepancyId() {
        return getNextId("tblDiscrepancies", "discrepancyID", "DISC-", 3);
    }
}
