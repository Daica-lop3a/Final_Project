package controller;

import dao.AreaDAO;
import dao.BinReadingDAO;
import dao.DeviceDAO;
import dao.UserDAO;
import dao.WasteBinDAO;
import model.AppUser;
import model.Area;
import model.BinReading;
import model.Device;
import model.WasteBin;
import util.Web;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

@WebServlet("/wastebin/detail")
public class BinDetailServlet extends HttpServlet {

    private final WasteBinDAO binDAO = new WasteBinDAO();
    private final BinReadingDAO readingDAO = new BinReadingDAO();
    private final UserDAO userDAO = new UserDAO();
    private final AreaDAO areaDAO = new AreaDAO();
    private final DeviceDAO deviceDAO = new DeviceDAO();

    private static final String DETAIL_URL = "/WEB-INF/views/binDetail.jsp";
    private static final String BIN_LIST_URL = "/wastebin";
    private static final String REDIRECT_PREFIX = "redirect:";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        processRequest(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        processRequest(req, resp);
    }

    private void processRequest(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String url = DETAIL_URL;

        try {
            if (!"GET".equalsIgnoreCase(req.getMethod())) {
                resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
                return;
            }

            String binID = req.getParameter("binID");
            if (binID == null || binID.trim().isEmpty()) {
                binID = req.getParameter("id");
            }
            if (binID == null || binID.trim().isEmpty()) {
                url = getBinListUrl(req);
                return;
            }

            binID = binID.trim();
            WasteBin bin = binDAO.findByID(binID);
            if (bin == null) {
                url = getBinListUrl(req);
                return;
            }

            AppUser user = Web.currentUser(req);

            // Scope check: If user is Manager or Supervisor, ensure bin belongs to their assigned areas
            if (user != null && ("MGR".equalsIgnoreCase(user.getRoleId()) || "SUP".equalsIgnoreCase(user.getRoleId()))) {
                List<String> assignedAreas = userDAO.getAssignedAreaIds(user.getUserId());
                AppUser dbUser = userDAO.findById(user.getUserId());
                if (dbUser != null && dbUser.getAreaID() != null && !dbUser.getAreaID().trim().isEmpty()) {
                    String primaryArea = dbUser.getAreaID().trim();
                    if (!assignedAreas.contains(primaryArea)) {
                        assignedAreas.add(primaryArea);
                    }
                }

                if (!assignedAreas.isEmpty() && (bin.getAreaID() == null || !assignedAreas.contains(bin.getAreaID()))) {
                    url = getBinListUrl(req);
                    return;
                }
            }

            // Load Area information
            Area area = null;
            if (bin.getAreaID() != null && !bin.getAreaID().trim().isEmpty()) {
                area = areaDAO.findById(bin.getAreaID().trim());
            }

            // Load attached IoT Device information
            Device device = deviceDAO.findByBinID(binID);

            // Load readings history
            List<BinReading> readings = readingDAO.getByBin(binID);
            if (readings == null) {
                readings = new ArrayList<BinReading>();
            }

            // -------------------------------------------------------------
            // 30-MINUTE FILL LEVEL FORECAST ALGORITHM (PRJ301 HIGHLIGHT)
            // -------------------------------------------------------------
            int currentFill = (int) Math.round(bin.getCurrentFill());
            double fillRatePerMin = 0.25; // Default accumulation rate in %/min

            // Chronological readings (earliest to latest)
            List<BinReading> chronologicalReadings = new ArrayList<BinReading>(readings);
            Collections.sort(chronologicalReadings, new Comparator<BinReading>() {
                @Override
                public int compare(BinReading r1, BinReading r2) {
                    if (r1.getMeasuredAt() == null || r2.getMeasuredAt() == null) return 0;
                    return r1.getMeasuredAt().compareTo(r2.getMeasuredAt());
                }
            });

            if (chronologicalReadings.size() >= 2) {
                BinReading first = chronologicalReadings.get(0);
                BinReading last = chronologicalReadings.get(chronologicalReadings.size() - 1);
                if (first.getMeasuredAt() != null && last.getMeasuredAt() != null) {
                    long diffMs = last.getMeasuredAt().getTime() - first.getMeasuredAt().getTime();
                    double diffMins = diffMs / 60000.0;
                    if (diffMins > 0) {
                        double deltaFill = last.getFillPercent() - first.getFillPercent();
                        if (deltaFill > 0) {
                            fillRatePerMin = deltaFill / diffMins;
                            // Clamp realistic rate between 0.1% and 1.5% per min
                            if (fillRatePerMin < 0.1) fillRatePerMin = 0.1;
                            if (fillRatePerMin > 1.5) fillRatePerMin = 1.5;
                        }
                    }
                }
            }

            // Project forward for 30 minutes in 10-minute intervals
            int f0 = currentFill;
            int f10 = (int) Math.min(100, Math.round(f0 + fillRatePerMin * 10));
            int f20 = (int) Math.min(100, Math.round(f0 + fillRatePerMin * 20));
            int f30 = (int) Math.min(100, Math.round(f0 + fillRatePerMin * 30));

            // Estimate time until reaching 85% (Overfill Warning) and 100% (Full)
            int timeTo85 = -1;
            int timeToFull = -1;
            if (currentFill >= 85) {
                timeTo85 = 0;
            } else if (fillRatePerMin > 0) {
                timeTo85 = (int) Math.round((85 - currentFill) / fillRatePerMin);
            }

            if (currentFill >= 100) {
                timeToFull = 0;
            } else if (fillRatePerMin > 0) {
                timeToFull = (int) Math.round((100 - currentFill) / fillRatePerMin);
            }

            // Build JSON arrays for Chart.js
            SimpleDateFormat timeFmt = new SimpleDateFormat("HH:mm");
            StringBuilder histLabelsJson = new StringBuilder("[");
            StringBuilder histDataJson = new StringBuilder("[");

            // Limit to last 8 chronological points for clear chart visualization
            int startIndex = Math.max(0, chronologicalReadings.size() - 8);
            for (int i = startIndex; i < chronologicalReadings.size(); i++) {
                BinReading r = chronologicalReadings.get(i);
                if (i > startIndex) {
                    histLabelsJson.append(",");
                    histDataJson.append(",");
                }
                String timeStr = r.getMeasuredAt() != null ? timeFmt.format(r.getMeasuredAt()) : "Pt " + (i + 1);
                histLabelsJson.append("\"").append(timeStr).append("\"");
                histDataJson.append(r.getFillPercent());
            }
            histLabelsJson.append("]");
            histDataJson.append("]");

            req.setAttribute("BIN", bin);
            req.setAttribute("AREA", area);
            req.setAttribute("DEVICE", device);
            req.setAttribute("READINGS", readings);

            // Forecast attributes
            req.setAttribute("FILL_RATE", String.format("%.2f", fillRatePerMin));
            req.setAttribute("F0", f0);
            req.setAttribute("F10", f10);
            req.setAttribute("F20", f20);
            req.setAttribute("F30", f30);
            req.setAttribute("TIME_TO_85", timeTo85);
            req.setAttribute("TIME_TO_FULL", timeToFull);
            req.setAttribute("HIST_LABELS_JSON", histLabelsJson.toString());
            req.setAttribute("HIST_DATA_JSON", histDataJson.toString());

            // Handle live polling / AJAX requests
            if ("json".equalsIgnoreCase(req.getParameter("format")) || "application/json".equals(req.getHeader("Accept"))) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
                java.io.PrintWriter out = resp.getWriter();
                out.print("{");
                out.print("\"binID\":\"" + escapeJson(bin.getBinID()) + "\",");
                out.print("\"binCode\":\"" + escapeJson(bin.getBinCode()) + "\",");
                out.print("\"currentFill\":" + currentFill + ",");
                out.print("\"status\":\"" + escapeJson(bin.getStatus()) + "\",");
                out.print("\"capacity\":" + bin.getCapacity() + ",");
                out.print("\"fillRate\":\"" + String.format(java.util.Locale.US, "%.2f", fillRatePerMin) + "\",");
                out.print("\"f0\":" + f0 + ",");
                out.print("\"f10\":" + f10 + ",");
                out.print("\"f20\":" + f20 + ",");
                out.print("\"f30\":" + f30 + ",");
                out.print("\"timeTo85\":" + timeTo85 + ",");
                out.print("\"timeToFull\":" + timeToFull + ",");
                out.print("\"histLabels\":" + histLabelsJson.toString() + ",");
                out.print("\"histData\":" + histDataJson.toString() + ",");
                out.print("\"readings\":[");
                for (int i = 0; i < Math.min(20, readings.size()); i++) {
                    BinReading r = readings.get(i);
                    if (i > 0) out.print(",");
                    out.print("{");
                    out.print("\"readingID\":" + r.getReadingID() + ",");
                    out.print("\"fillPercent\":" + r.getFillPercent() + ",");
                    out.print("\"measuredAt\":\"" + (r.getMeasuredAt() != null ? new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(r.getMeasuredAt()) : "") + "\"");
                    out.print("}");
                }
                out.print("]");
                out.print("}");
                out.flush();
                return;
            }

        } catch (Exception e) {
            log("Error processing BinDetailServlet", e);
            req.setAttribute("ERROR", "Unable to load waste bin telemetry details.");
            url = getBinListUrl(req);
        } finally {
            if (url != null && url.startsWith(REDIRECT_PREFIX)) {
                resp.sendRedirect(url.substring(REDIRECT_PREFIX.length()));
            } else if (url != null && !resp.isCommitted()) {
                req.getRequestDispatcher(url).forward(req, resp);
            }
        }
    }

    private String getBinListUrl(HttpServletRequest req) {
        return REDIRECT_PREFIX + req.getContextPath() + BIN_LIST_URL;
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
    }
}
