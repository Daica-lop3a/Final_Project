package controller;

import dao.AuditLogDAO;
import dao.CitizenReportDAO;
import dao.CollectionDAO;
import dao.DiscrepancyDAO;
import dao.ReportDAO;
import dao.UserDAO;
import dao.WasteBinDAO;
import model.AppUser;
import model.AuditLog;
import model.CitizenReport;
import model.CollectionRequest;
import model.Discrepancy;
import model.WasteBin;

import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Enterprise Data Export Controller (CSV with UTF-8 BOM).
 * Supports targeted date-range filtering (From Date -> To Date),
 * role-based zone scoping, and multi-entity reports.
 */
@WebServlet("/export")
public class ExportServlet extends HttpServlet {

    private final WasteBinDAO binDAO = new WasteBinDAO();
    private final CollectionDAO collectionDAO = new CollectionDAO();
    private final CitizenReportDAO citizenReportDAO = new CitizenReportDAO();
    private final ReportDAO reportDAO = new ReportDAO();
    private final AuditLogDAO auditDAO = new AuditLogDAO();
    private final DiscrepancyDAO discrepancyDAO = new DiscrepancyDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        AppUser currentUser = (session != null) ? (AppUser) session.getAttribute("user") : null;

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String type = req.getParameter("type");
        if (type == null || type.trim().isEmpty()) {
            type = "bins";
        }
        type = type.trim().toLowerCase();

        // Date range parameters
        String fromDateStr = req.getParameter("fromDate");
        String toDateStr = req.getParameter("toDate");
        String areaId = req.getParameter("areaId");

        Timestamp from = parseStartOfDay(fromDateStr);
        Timestamp to = parseEndOfDay(toDateStr);

        // Sanity swap if from is after to
        if (from != null && to != null && from.after(to)) {
            Timestamp temp = from;
            from = to;
            to = temp;
            String tempStr = fromDateStr;
            fromDateStr = toDateStr;
            toDateStr = tempStr;
        }

        // Role-based zone scoping
        List<String> allowedAreaIds = null;
        String role = currentUser.getRoleId();
        if ("MGR".equals(role) || "SUP".equals(role)) {
            allowedAreaIds = new ArrayList<>();
            allowedAreaIds.addAll(userDAO.getAssignedAreaIds(currentUser.getUserId()));
            AppUser dbUser = userDAO.findById(currentUser.getUserId());
            if (dbUser != null && dbUser.getAreaID() != null && !dbUser.getAreaID().trim().isEmpty()) {
                String pArea = dbUser.getAreaID().trim();
                if (!allowedAreaIds.contains(pArea)) {
                    allowedAreaIds.add(pArea);
                }
            }
            if (areaId != null && !areaId.trim().isEmpty() && allowedAreaIds.contains(areaId.trim())) {
                allowedAreaIds = new ArrayList<>();
                allowedAreaIds.add(areaId.trim());
            }
        } else if (areaId != null && !areaId.trim().isEmpty()) {
            allowedAreaIds = new ArrayList<>();
            allowedAreaIds.add(areaId.trim());
        }

        // Construct intuitive export filename
        String timestamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String dateSuffix;
        if (fromDateStr != null && !fromDateStr.trim().isEmpty() && toDateStr != null && !toDateStr.trim().isEmpty()) {
            dateSuffix = fromDateStr.trim() + "_to_" + toDateStr.trim();
        } else if (fromDateStr != null && !fromDateStr.trim().isEmpty()) {
            dateSuffix = "from_" + fromDateStr.trim();
        } else if (toDateStr != null && !toDateStr.trim().isEmpty()) {
            dateSuffix = "until_" + toDateStr.trim();
        } else {
            dateSuffix = "all_" + timestamp;
        }

        String filename = "SmartWaste_" + type + "_" + dateSuffix + ".csv";

        resp.setContentType("text/csv; charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

        // Write UTF-8 BOM (\uFEFF) so Excel properly recognizes UTF-8 encoding
        OutputStreamWriter osw = new OutputStreamWriter(resp.getOutputStream(), StandardCharsets.UTF_8);
        PrintWriter writer = new PrintWriter(osw);
        writer.write('\uFEFF');

        switch (type) {
            case "collections":
                exportCollections(writer, from, to, allowedAreaIds);
                break;
            case "bins":
                exportBins(writer, from, to);
                break;
            case "reports":
                exportReports(writer, from, to, (allowedAreaIds != null && !allowedAreaIds.isEmpty()) ? allowedAreaIds.get(0) : null);
                break;
            case "audit":
                String actionFilter = req.getParameter("action");
                String userFilter = req.getParameter("user");
                exportAuditLogs(writer, from, to, actionFilter, userFilter);
                break;
            case "discrepancies":
                String discType = req.getParameter("discType");
                String discStatus = req.getParameter("status");
                exportDiscrepancies(writer, from, to, discType, discStatus);
                break;
            default:
                exportBins(writer, from, to);
                break;
        }

        writer.flush();
    }

    private void exportBins(PrintWriter w, Timestamp from, Timestamp to) {
        w.println("Bin ID,Bin Code,Location,Zone,Capacity (L),Fill Level (%),Status,Last Emptied,Last Updated");
        List<WasteBin> bins;
        if (from != null || to != null) {
            bins = binDAO.getBinsByDateRange(from, to);
        } else {
            bins = binDAO.getAll();
        }

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        for (WasteBin b : bins) {
            String emptiedStr = b.getLastEmptied() != null ? sdf.format(b.getLastEmptied()) : "";
            String updatedStr = b.getLastUpdated() != null ? sdf.format(b.getLastUpdated()) : "";
            w.printf("\"%s\",\"%s\",\"%s\",\"%s\",%.1f,%.1f,\"%s\",\"%s\",\"%s\"\n",
                    escape(b.getBinID()),
                    escape(b.getBinCode()),
                    escape(b.getLocation()),
                    escape(b.getAreaName()),
                    b.getCapacity(),
                    b.getCurrentFill(),
                    escape(b.getStatus()),
                    emptiedStr,
                    updatedStr);
        }
    }

    private void exportCollections(PrintWriter w, Timestamp from, Timestamp to, List<String> areaIds) {
        w.println("Request ID,Bin ID,Bin Code,Location,Zone,Collection Staff,Status,Priority,Created Date,Completed Date,Notes");
        List<CollectionRequest> list;
        try {
            list = reportDAO.getDetailedCollections(from, to, areaIds);
        } catch (Exception e) {
            list = new ArrayList<>();
        }

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        for (CollectionRequest r : list) {
            String createdStr = r.getCreatedDate() != null ? sdf.format(r.getCreatedDate()) : "";
            String completedStr = r.getCompletedDate() != null ? sdf.format(r.getCompletedDate()) : "";
            String staff = (r.getStaffName() != null && !r.getStaffName().trim().isEmpty())
                    ? r.getStaffName() : (r.getStaffID() != null ? r.getStaffID() : "Unassigned");

            w.printf("\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"\n",
                    escape(r.getRequestID()),
                    escape(r.getBinID()),
                    escape(r.getBinCode()),
                    escape(r.getLocation()),
                    escape(r.getAreaName()),
                    escape(staff),
                    escape(r.getStatus()),
                    escape(r.getPriority()),
                    createdStr,
                    completedStr,
                    escape(r.getNotes()));
        }
    }

    private void exportReports(PrintWriter w, Timestamp from, Timestamp to, String areaId) {
        w.println("Report ID,Title,Issue Type,Zone,Bin Code,Reporter,Status,Submitted Date,Verified By,Verified Date,Feedback Note");
        List<CitizenReport> list = citizenReportDAO.getReportsByDateRange(from, to, areaId, null);
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        for (CitizenReport r : list) {
            String dateStr = r.getCreatedDate() != null ? sdf.format(r.getCreatedDate()) : "";
            String verDateStr = r.getVerifiedDate() != null ? sdf.format(r.getVerifiedDate()) : "";
            w.printf("\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"\n",
                    escape(r.getReportID()),
                    escape(r.getTitle()),
                    escape(r.getReportType()),
                    escape(r.getAreaName()),
                    escape(r.getBinCode()),
                    escape(r.getCitizenName()),
                    escape(r.getStatus()),
                    dateStr,
                    escape(r.getVerifierName() != null ? r.getVerifierName() : r.getVerifiedBy()),
                    verDateStr,
                    escape(r.getFeedbackNote()));
        }
    }

    private void exportAuditLogs(PrintWriter w, Timestamp from, Timestamp to, String actionFilter, String userFilter) {
        w.println("Timestamp,User,Role,Action,Target Table,Record ID,Change Details,IP Address");
        List<AuditLog> list = auditDAO.getLogsByDateRange(from, to, actionFilter, userFilter);
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        for (AuditLog l : list) {
            String dateStr = l.getTimestamp() != null ? sdf.format(l.getTimestamp()) : "";
            w.printf("\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"\n",
                    dateStr,
                    escape(l.getUserFullName() != null ? l.getUserFullName() : l.getUserID()),
                    escape(l.getUserRole()),
                    escape(l.getAction()),
                    escape(l.getTableName()),
                    escape(l.getRecordID()),
                    escape(l.getNewValue()),
                    escape(l.getIpAddress()));
        }
    }

    private void exportDiscrepancies(PrintWriter w, Timestamp from, Timestamp to, String typeFilter, String statusFilter) {
        w.println("Discrepancy ID,Title,Type,Target Entity,Target ID,Severity,Status,Detected By,Detected Date,Description,Investigation Notes,Conclusion Notes,Closed By,Closed Date");
        List<Discrepancy> list = discrepancyDAO.getByDateRange(from, to, typeFilter, statusFilter);
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        for (Discrepancy d : list) {
            String detDate = d.getDetectedDate() != null ? sdf.format(d.getDetectedDate()) : "";
            String clsDate = d.getClosedDate() != null ? sdf.format(d.getClosedDate()) : "";
            w.printf("\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"\n",
                    escape(d.getDiscrepancyID()),
                    escape(d.getTitle()),
                    escape(d.getDiscrepancyType()),
                    escape(d.getTargetEntity()),
                    escape(d.getTargetID()),
                    escape(d.getSeverity()),
                    escape(d.getStatus()),
                    escape(d.getDetectedByName() != null ? d.getDetectedByName() : d.getDetectedBy()),
                    detDate,
                    escape(d.getDescription()),
                    escape(d.getInvestigationNotes()),
                    escape(d.getConclusionNotes()),
                    escape(d.getClosedByName() != null ? d.getClosedByName() : d.getClosedBy()),
                    clsDate);
        }
    }

    private Timestamp parseStartOfDay(String dateStr) {
        if (dateStr == null || dateStr.trim().isEmpty()) return null;
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Date d = sdf.parse(dateStr.trim());
            Calendar cal = Calendar.getInstance();
            cal.setTime(d);
            cal.set(Calendar.HOUR_OF_DAY, 0);
            cal.set(Calendar.MINUTE, 0);
            cal.set(Calendar.SECOND, 0);
            cal.set(Calendar.MILLISECOND, 0);
            return new Timestamp(cal.getTimeInMillis());
        } catch (Exception e) {
            return null;
        }
    }

    private Timestamp parseEndOfDay(String dateStr) {
        if (dateStr == null || dateStr.trim().isEmpty()) return null;
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Date d = sdf.parse(dateStr.trim());
            Calendar cal = Calendar.getInstance();
            cal.setTime(d);
            cal.set(Calendar.HOUR_OF_DAY, 23);
            cal.set(Calendar.MINUTE, 59);
            cal.set(Calendar.SECOND, 59);
            cal.set(Calendar.MILLISECOND, 999);
            return new Timestamp(cal.getTimeInMillis());
        } catch (Exception e) {
            return null;
        }
    }

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("\"", "\"\"");
    }
}
