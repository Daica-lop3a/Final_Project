package controller;

import dao.AlertDAO;
import dao.BinReadingDAO;
import dao.CollectionDAO;
import dao.UserDAO;
import dao.WasteBinDAO;
import model.Alert;
import model.AppUser;
import model.BinReading;
import model.CollectionRequest;
import model.WasteBin;
import service.NotificationService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.List;

@WebServlet("/api/bin/update-fill")
public class SensorServlet extends HttpServlet {

    private final WasteBinDAO binDAO = new WasteBinDAO();
    private final BinReadingDAO readingDAO = new BinReadingDAO();
    private final AlertDAO alertDAO = new AlertDAO();
    private final CollectionDAO collectionDAO = new CollectionDAO();
    private final UserDAO userDAO = new UserDAO();
    private final NotificationService notifier = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        doPost(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/plain");
        resp.setCharacterEncoding("UTF-8");

        // =========================
        // GET PARAMETERS
        // =========================
        String binID = req.getParameter("binID");
        String fillValue = req.getParameter("fillPercent");
        String secondaryFillValue = req.getParameter("secondaryFillPercent");
        String sensorFault = req.getParameter("sensorFault");

        // Fallback for raw JSON payload (e.g. from IoT devices or serial bridges)
        if (binID == null || fillValue == null) {
            try {
                java.io.BufferedReader reader = req.getReader();
                StringBuilder sb = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }
                String body = sb.toString();
                if (!body.trim().isEmpty()) {
                    java.util.regex.Matcher mBin = java.util.regex.Pattern.compile("\"(?:binID|bin_id)\"\\s*:\\s*\"([^\"]+)\"").matcher(body);
                    if (mBin.find()) {
                        binID = mBin.group(1);
                    }
                    java.util.regex.Matcher mFill = java.util.regex.Pattern.compile("\"(?:fillPercent|fill_level)\"\\s*:\\s*([0-9]+)").matcher(body);
                    if (mFill.find()) {
                        fillValue = mFill.group(1);
                    }
                }
            } catch (Exception ignored) {
            }
        }

        // =========================
        // VALIDATE BIN ID
        // =========================
        if (binID == null || binID.trim().isEmpty()) {
            resp.getWriter().print("Bin ID is required.");
            return;
        }

        // =========================
        // VALIDATE FILL
        // =========================
        if (fillValue == null || fillValue.trim().isEmpty()) {
            resp.getWriter().print("Fill percent is required.");
            return;
        }

        int fillPercent;
        try {
            fillPercent = Integer.parseInt(fillValue.trim());
        } catch (NumberFormatException e) {
            resp.getWriter().print("Fill percent must be a number.");
            return;
        }

        if (fillPercent < 0 || fillPercent > 100) {
            resp.getWriter().print("Fill percent must be between 0 and 100.");
            return;
        }

        // =========================
        // CHECK BIN
        // =========================
        WasteBin bin = binDAO.findByID(binID);
        if (bin == null) {
            resp.getWriter().print("Waste bin does not exist.");
            return;
        }

        // =========================
        // UPDATE FILL + STATUS
        // =========================
        boolean updated = binDAO.updateFillAndStatus(binID, fillPercent);
        if (!updated) {
            resp.getWriter().print("Cannot update waste bin.");
            return;
        }

        // =========================
        // SAVE SENSOR READING
        // =========================
        BinReading reading = new BinReading();
        reading.setBinID(binID);
        reading.setFillPercent(fillPercent);
        reading.setMeasuredAt(new Timestamp(System.currentTimeMillis()));
        readingDAO.insert(reading);

        // =========================
        // 1. SENSOR CONFLICT DETECTION (PRJ301 REQUIREMENT)
        // =========================
        if (secondaryFillValue != null && !secondaryFillValue.trim().isEmpty()) {
            try {
                int secFill = Integer.parseInt(secondaryFillValue.trim());
                if (Math.abs(fillPercent - secFill) >= 25) {
                    Alert conflictAlert = new Alert();
                    conflictAlert.setAlertID(util.IdGenerator.nextAlertId());
                    conflictAlert.setBinID(binID);
                    conflictAlert.setAlertType("Sensor_Conflict");
                    conflictAlert.setMessage("Telemetry conflict on " + bin.getBinCode()
                            + ": Primary sensor (" + fillPercent + "%) mismatches secondary sensor ("
                            + secFill + "%) by " + Math.abs(fillPercent - secFill) + "%!");
                    conflictAlert.setCreatedDate(new Timestamp(System.currentTimeMillis()));
                    conflictAlert.setResolved(false);
                    if (alertDAO.insert(conflictAlert)) {
                        notifier.dispatchAlert(conflictAlert);
                    }
                }
            } catch (NumberFormatException ignored) {}
        }

        // =========================
        // 2. SENSOR FAULT DETECTION
        // =========================
        if ("true".equalsIgnoreCase(sensorFault)) {
            Alert faultAlert = new Alert();
            faultAlert.setAlertID(util.IdGenerator.nextAlertId());
            faultAlert.setBinID(binID);
            faultAlert.setAlertType("Sensor_Fault");
            faultAlert.setMessage("Hardware fault on " + bin.getBinCode() + ": Telemetry heartbeat lost.");
            faultAlert.setCreatedDate(new Timestamp(System.currentTimeMillis()));
            faultAlert.setResolved(false);
            if (alertDAO.insert(faultAlert)) {
                notifier.dispatchAlert(faultAlert);
            }
        }

        // =========================
        // 3. OVERFILL ALERT (>= 80%)
        // =========================
        if (fillPercent >= 80) {
            if (!alertDAO.hasUnresolvedHighFillAlert(binID)) {
                Alert alert = new Alert();
                alert.setAlertID(util.IdGenerator.nextAlertId());
                alert.setBinID(binID);
                alert.setAlertType("High_Fill");
                alert.setMessage("Waste bin " + bin.getBinCode() + " fill level reached " + fillPercent + "%.");
                alert.setCreatedDate(new Timestamp(System.currentTimeMillis()));
                alert.setResolved(false);

                if (alertDAO.insert(alert)) {
                    notifier.dispatchAlert(alert);
                }
            }

            // =========================
            // 4. AUTOMATIC COLLECTION REQUEST DISPATCH (>= 90%)
            // PRJ301: Automatic collection dispatch when bin fill reaches 90%
            // =========================
            if (fillPercent >= 90) {
                if (!collectionDAO.hasActiveRequestForBin(binID)) {
                    CollectionRequest cr = new CollectionRequest();
                    cr.setRequestID(util.IdGenerator.nextCollectionRequestId());
                    cr.setBinID(binID);
                    cr.setStatus("Pending");
                    cr.setPriority("Emergency");
                    cr.setCreatedDate(new Timestamp(System.currentTimeMillis()));
                    cr.setNotes("Automated logistics dispatch: Bin breached 90% threshold (" + fillPercent + "% full).");

                    // Auto-assign staff in area if available
                    if (bin.getAreaID() != null && !bin.getAreaID().trim().isEmpty()) {
                        List<AppUser> allStaff = userDAO.search("", "STF");
                        for (AppUser s : allStaff) {
                            if (s.getAreaID() != null && bin.getAreaID().trim().equalsIgnoreCase(s.getAreaID().trim())) {
                                cr.setStaffID(s.getUserId());
                                break;
                            }
                        }
                    }

                    try {
                        collectionDAO.insert(cr);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }

        } else {
            // Under 80%: resolve unresolved high fill alerts
            alertDAO.resolveUnresolvedHighFillAlerts(binID);
        }

        // =========================
        // RESPONSE
        // =========================
        resp.getWriter().print(
                "OK - Sensor telemetry recorded for "
                + bin.getBinCode()
                + " | Fill: "
                + fillPercent
                + "%"
        );
    }
}
