package controller;

import dao.AreaDAO;
import dao.WasteBinDAO;
import model.Area;
import model.WasteBin;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet displaying interactive GIS bin location map (Leaflet.js + OpenStreetMap)
 * Supports both web view and JSON API for real-time polling
 */
@WebServlet({"/map", "/public-map", "/api/bins-location"})
public class MapServlet extends HttpServlet {

    private final WasteBinDAO binDAO = new WasteBinDAO();
    private final AreaDAO areaDAO = new AreaDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        String areaID = req.getParameter("areaID");
        String status = req.getParameter("status");
        String format = req.getParameter("format");

        // Retrieve bins list
        List<WasteBin> bins;
        if (areaID != null && !areaID.trim().isEmpty()) {
            bins = binDAO.getByAreas(java.util.Collections.singletonList(areaID.trim()));
        } else {
            bins = binDAO.getAll();
        }

        // Return JSON for AJAX real-time telemetry polling
        if ("json".equalsIgnoreCase(format) || req.getRequestURI().endsWith("/api/bins-location")) {
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            out.print(toJson(bins));
            out.flush();
            return;
        }

        // Retrieve areas for zone filtering
        List<Area> areas = areaDAO.getAll();

        req.setAttribute("bins", bins);
        req.setAttribute("areas", areas);
        req.setAttribute("selectedArea", areaID);
        req.setAttribute("selectedStatus", status);

        req.getRequestDispatcher("/WEB-INF/views/map.jsp").forward(req, resp);
    }

        // Serialize WasteBins to JSON
    private String toJson(List<WasteBin> bins) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < bins.size(); i++) {
            WasteBin b = bins.get(i);
            sb.append("{")
              .append("\"binID\":\"").append(escape(b.getBinID())).append("\",")
              .append("\"binCode\":\"").append(escape(b.getBinCode())).append("\",")
              .append("\"location\":\"").append(escape(b.getLocation())).append("\",")
              .append("\"areaID\":\"").append(escape(b.getAreaID())).append("\",")
              .append("\"areaName\":\"").append(escape(b.getAreaName() != null ? b.getAreaName() : "")).append("\",")
              .append("\"latitude\":").append(b.getLatitude()).append(",")
              .append("\"longitude\":").append(b.getLongitude()).append(",")
              .append("\"capacity\":").append(b.getCapacity()).append(",")
              .append("\"currentFill\":").append(b.getCurrentFill()).append(",")
              .append("\"status\":\"").append(escape(b.getStatus())).append("\",")
              .append("\"statusColor\":\"").append(escape(b.getStatusColor())).append("\"")
              .append("}");
            if (i < bins.size() - 1) {
                sb.append(",");
            }
        }
        sb.append("]");
        return sb.toString();
    }

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", " ")
                .replace("\r", " ");
    }
}
