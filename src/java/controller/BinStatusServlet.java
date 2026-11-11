package controller;

import dao.WasteBinDAO;
import model.WasteBin;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/api/bin/status")
public class BinStatusServlet extends HttpServlet {

    private final WasteBinDAO binDAO = new WasteBinDAO();

    @Override
    protected void doGet(HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {
        processRequest(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {
        processRequest(req, resp);
    }

    private void processRequest(HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        resp.setHeader("Cache-Control", "no-store");

        try {
            if (!"GET".equalsIgnoreCase(req.getMethod())) {
                resp.setStatus(
                        HttpServletResponse.SC_METHOD_NOT_ALLOWED);

                writeError(resp, "Method not allowed.");
                return;
            }

            String targetBinID = req.getParameter("binID");
            if (targetBinID == null || targetBinID.trim().isEmpty()) {
                targetBinID = req.getParameter("id");
            }

            if (targetBinID != null && !targetBinID.trim().isEmpty()) {
                WasteBin targetBin = binDAO.findByID(targetBinID.trim());
                if (targetBin == null) {
                    resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    writeError(resp, "Bin not found.");
                    return;
                }
                dao.BinReadingDAO readingDAO = new dao.BinReadingDAO();
                List<model.BinReading> readings = readingDAO.getByBin(targetBin.getBinID());
                if (readings == null) readings = new java.util.ArrayList<model.BinReading>();

                PrintWriter out = resp.getWriter();
                out.print("{");
                out.print("\"binID\":\"" + escapeJson(targetBin.getBinID()) + "\",");
                out.print("\"binCode\":\"" + escapeJson(targetBin.getBinCode()) + "\",");
                out.print("\"currentFill\":" + targetBin.getCurrentFill() + ",");
                out.print("\"status\":\"" + escapeJson(targetBin.getStatus()) + "\",");
                out.print("\"capacity\":" + targetBin.getCapacity() + ",");
                out.print("\"location\":\"" + escapeJson(targetBin.getLocation()) + "\",");
                out.print("\"readings\":[");
                for (int i = 0; i < Math.min(20, readings.size()); i++) {
                    model.BinReading r = readings.get(i);
                    if (i > 0) out.print(",");
                    out.print("{");
                    out.print("\"readingID\":" + r.getReadingID() + ",");
                    out.print("\"fillPercent\":" + r.getFillPercent() + ",");
                    out.print("\"measuredAt\":\"" + (r.getMeasuredAt() != null ? new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(r.getMeasuredAt()) : "") + "\"");
                    out.print("}");
                }
                out.print("]");
                out.print("}");
                out.flush();
                return;
            }

            List<WasteBin> list = binDAO.getAll();

            if (list == null) {
                resp.setStatus(
                        HttpServletResponse.SC_INTERNAL_SERVER_ERROR);

                writeError(resp, "Unable to retrieve bin status.");
                return;
            }

            PrintWriter out = resp.getWriter();

            out.print("[");

            for (int i = 0; i < list.size(); i++) {
                WasteBin bin = list.get(i);

                if (bin == null) {
                    continue;
                }

                // Them dau phay truoc moi phan tu sau phan tu dau tien.
                if (hasWrittenBin(list, i)) {
                    out.print(",");
                }

                out.print("{");

                out.print("\"binID\":\"");
                out.print(escapeJson(bin.getBinID()));
                out.print("\",");

                out.print("\"binCode\":\"");
                out.print(escapeJson(bin.getBinCode()));
                out.print("\",");

                out.print("\"currentFill\":");
                out.print(bin.getCurrentFill());
                out.print(",");

                out.print("\"status\":\"");
                out.print(escapeJson(bin.getStatus()));
                out.print("\"");

                out.print("}");
            }

            out.print("]");
            out.flush();

        } catch (Exception e) {
            log("Error processing BinStatusServlet", e);

            if (!resp.isCommitted()) {
                resp.reset();
                resp.setStatus(
                        HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");

                writeError(resp, "Unable to retrieve bin status.");
            }
        }
    }

    private boolean hasWrittenBin(List<WasteBin> list, int index) {
        for (int i = 0; i < index; i++) {
            if (list.get(i) != null) {
                return true;
            }
        }

        return false;
    }

    private void writeError(HttpServletResponse resp, String message)
            throws IOException {

        PrintWriter out = resp.getWriter();

        out.print("{\"error\":\"");
        out.print(escapeJson(message));
        out.print("\"}");

        out.flush();
    }

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }

        StringBuilder result = new StringBuilder();

        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);

            switch (c) {
                case '"':
                    result.append("\\\"");
                    break;
                case '\\':
                    result.append("\\\\");
                    break;
                case '\b':
                    result.append("\\b");
                    break;
                case '\f':
                    result.append("\\f");
                    break;
                case '\n':
                    result.append("\\n");
                    break;
                case '\r':
                    result.append("\\r");
                    break;
                case '\t':
                    result.append("\\t");
                    break;
                default:
                    if (c < 0x20) {
                        result.append(String.format("\\u%04x", (int) c));
                    } else {
                        result.append(c);
                    }
                    break;
            }
        }

        return result.toString();
    }
}