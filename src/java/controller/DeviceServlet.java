package controller;

import dao.AuditLogDAO;
import dao.DeviceDAO;
import dao.WasteBinDAO;
import model.AppUser;
import model.Device;
import model.WasteBin;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Controller for IoT Devices and Smart Sensors Management.
 * Accessible by Super Admin, Admin, and Technician.
 */
@WebServlet(urlPatterns = {
    "/device",
    "/device/create",
    "/device/edit",
    "/device/save",
    "/device/delete",
    "/device/assign",
    "/device/import"
})
public class DeviceServlet extends HttpServlet {

    private final DeviceDAO deviceDAO = new DeviceDAO();
    private final WasteBinDAO binDAO = new WasteBinDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        AppUser currentUser = getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String path = req.getServletPath() + (req.getPathInfo() != null ? req.getPathInfo() : "");
        String action = req.getServletPath();
        if (req.getRequestURI().endsWith("/create")) action = "/device/create";
        else if (req.getRequestURI().endsWith("/edit")) action = "/device/edit";

        if ("/device/create".equals(action)) {
            req.setAttribute("LIST_BIN", binDAO.getAll());
            Device dev = new Device();
            // Generate next sequential device ID (e.g. DEV-011)
            dev.setDeviceId(util.IdGenerator.nextDeviceId());
            req.setAttribute("DEVICE", dev);
            req.setAttribute("NEXT_DEVICE_ID", dev.getDeviceId());
            req.setAttribute("IS_EDIT", false);
            req.getRequestDispatcher("/WEB-INF/views/deviceForm.jsp").forward(req, resp);
            return;
        }

        if ("/device/edit".equals(action)) {
            String deviceId = req.getParameter("id");
            Device dev = deviceDAO.findById(deviceId);
            if (dev == null) {
                resp.sendRedirect(req.getContextPath() + "/device?error=not_found");
                return;
            }
            req.setAttribute("LIST_BIN", binDAO.getAll());
            req.setAttribute("DEVICE", dev);
            req.setAttribute("IS_EDIT", true);
            req.getRequestDispatcher("/WEB-INF/views/deviceForm.jsp").forward(req, resp);
            return;
        }

        // LIST DEVICES
        String keyword = req.getParameter("keyword");
        String deviceType = req.getParameter("deviceType");
        String status = req.getParameter("status");

        List<Device> list = deviceDAO.search(keyword, deviceType, status);
        List<WasteBin> unassignedBins = deviceDAO.getUnassignedBins();
        List<String> duplicateBins = deviceDAO.getDuplicateAssignedBins();
        List<String> stuckSensors = deviceDAO.getStuckSensors();

        req.setAttribute("LIST_DEVICE", list);
        req.setAttribute("UNASSIGNED_BINS", unassignedBins);
        req.setAttribute("DUPLICATE_BINS", duplicateBins);
        req.setAttribute("STUCK_SENSORS", stuckSensors);
        req.setAttribute("KEYWORD", keyword != null ? keyword : "");
        req.setAttribute("DEVICE_TYPE", deviceType != null ? deviceType : "");
        req.setAttribute("STATUS", status != null ? status : "");
        req.setAttribute("LIST_BIN", binDAO.getAll());

        req.getRequestDispatcher("/WEB-INF/views/deviceList.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        AppUser currentUser = getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String uri = req.getRequestURI();

        if (uri.endsWith("/save")) {
            saveDevice(req, resp, currentUser);
            return;
        }

        if (uri.endsWith("/delete")) {
            deleteDevice(req, resp, currentUser);
            return;
        }

        if (uri.endsWith("/assign")) {
            assignDevice(req, resp, currentUser);
            return;
        }

        if (uri.endsWith("/import")) {
            importDevices(req, resp, currentUser);
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/device");
    }

    private void saveDevice(HttpServletRequest req, HttpServletResponse resp, AppUser user)
            throws ServletException, IOException {
        String deviceId = req.getParameter("deviceId");
        String deviceName = req.getParameter("deviceName");
        String deviceType = req.getParameter("deviceType");
        String binId = req.getParameter("binId");
        String status = req.getParameter("status");
        String batteryRaw = req.getParameter("batteryLevel");
        String firmwareVersion = req.getParameter("firmwareVersion");
        boolean isEdit = "true".equalsIgnoreCase(req.getParameter("isEdit"));

        if (deviceId == null || deviceId.trim().isEmpty() || deviceName == null || deviceName.trim().isEmpty()) {
            req.setAttribute("ERROR", "Device ID and Device Name are required.");
            req.setAttribute("DEVICE", new Device(deviceId, deviceName, deviceType, binId, status, 100));
            req.setAttribute("IS_EDIT", isEdit);
            req.setAttribute("LIST_BIN", binDAO.getAll());
            req.getRequestDispatcher("/WEB-INF/views/deviceForm.jsp").forward(req, resp);
            return;
        }

        int battery = 100;
        try {
            if (batteryRaw != null && !batteryRaw.trim().isEmpty()) {
                battery = Math.max(0, Math.min(100, Integer.parseInt(batteryRaw.trim())));
            }
        } catch (NumberFormatException ignored) {}

        Device dev = new Device();
        dev.setDeviceId(deviceId.trim());
        dev.setDeviceName(deviceName.trim());
        dev.setDeviceType(deviceType != null ? deviceType.trim() : "Ultrasonic Fill Sensor");
        dev.setBinId(binId != null && !binId.trim().isEmpty() ? binId.trim() : null);
        dev.setStatus(status != null ? status.trim() : "Active");
        dev.setBatteryLevel(battery);
        dev.setFirmwareVersion(firmwareVersion != null && !firmwareVersion.trim().isEmpty() ? firmwareVersion.trim() : "v1.2.0");

        boolean success;
        if (!isEdit) {
            Device existing = deviceDAO.findById(deviceId);
            if (existing != null) {
                req.setAttribute("ERROR", "Device ID '" + deviceId + "' already exists.");
                req.setAttribute("DEVICE", dev);
                req.setAttribute("IS_EDIT", false);
                req.setAttribute("LIST_BIN", binDAO.getAll());
                req.getRequestDispatcher("/WEB-INF/views/deviceForm.jsp").forward(req, resp);
                return;
            }
            success = deviceDAO.insert(dev);
        } else {
            success = deviceDAO.update(dev);
        }

        if (success) {
            AuditLogDAO.log(
                    user.getUserId(),
                    isEdit ? "UPDATE_DEVICE" : "CREATE_DEVICE",
                    "tblDevices",
                    deviceId,
                    null,
                    (isEdit ? "Updated" : "Registered") + " IoT device " + deviceId + " (" + deviceName + ")",
                    req.getRemoteAddr()
            );
            resp.sendRedirect(req.getContextPath() + "/device?msg=" + (isEdit ? "updated" : "created"));
        } else {
            req.setAttribute("ERROR", "Unable to save device. Please check database constraints.");
            req.setAttribute("DEVICE", dev);
            req.setAttribute("IS_EDIT", isEdit);
            req.setAttribute("LIST_BIN", binDAO.getAll());
            req.getRequestDispatcher("/WEB-INF/views/deviceForm.jsp").forward(req, resp);
        }
    }

    private void deleteDevice(HttpServletRequest req, HttpServletResponse resp, AppUser user)
            throws IOException {
        String deviceId = req.getParameter("id");
        if (deviceId != null && !deviceId.trim().isEmpty()) {
            boolean deleted = deviceDAO.delete(deviceId.trim());
            if (deleted) {
                AuditLogDAO.log(
                        user.getUserId(),
                        "DELETE_DEVICE",
                        "tblDevices",
                        deviceId,
                        null,
                        "Deleted IoT device " + deviceId,
                        req.getRemoteAddr()
                );
            }
        }
        resp.sendRedirect(req.getContextPath() + "/device?msg=deleted");
    }

    private void assignDevice(HttpServletRequest req, HttpServletResponse resp, AppUser user)
            throws IOException {
        String deviceId = req.getParameter("deviceId");
        String binId = req.getParameter("binId");

        Device dev = deviceDAO.findById(deviceId);
        if (dev != null) {
            dev.setBinId(binId != null && !binId.trim().isEmpty() ? binId.trim() : null);
            deviceDAO.update(dev);
            AuditLogDAO.log(
                    user.getUserId(),
                    "ASSIGN_DEVICE",
                    "tblDevices",
                    deviceId,
                    null,
                    "Assigned IoT device " + deviceId + " to bin " + (binId != null ? binId : "NONE"),
                    req.getRemoteAddr()
            );
        }
        resp.sendRedirect(req.getContextPath() + "/device?msg=assigned");
    }

    private void importDevices(HttpServletRequest req, HttpServletResponse resp, AppUser user)
            throws IOException {
        String csvData = req.getParameter("csvData");
        if (csvData == null || csvData.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/device?error=empty_csv");
            return;
        }

        int count = 0;
        String[] lines = csvData.split("\\r?\\n");
        for (String rawLine : lines) {
            String line = rawLine.trim();
            if (line.isEmpty() || line.startsWith("#") || line.toLowerCase().startsWith("deviceid")) {
                continue;
            }
            String[] parts = line.split(",");
            if (parts.length >= 3) {
                String devId = parts[0].trim();
                String name = parts[1].trim();
                String type = parts[2].trim();
                String binId = parts.length > 3 && !parts[3].trim().isEmpty() ? parts[3].trim() : null;
                String status = parts.length > 4 && !parts[4].trim().isEmpty() ? parts[4].trim() : "Active";
                int battery = 100;
                if (parts.length > 5) {
                    try { battery = Integer.parseInt(parts[5].trim()); } catch (Exception ignored) {}
                }

                if (deviceDAO.findById(devId) == null) {
                    Device dev = new Device(devId, name, type, binId, status, battery);
                    if (deviceDAO.insert(dev)) {
                        count++;
                    }
                }
            }
        }

        if (count > 0) {
            AuditLogDAO.log(
                    user.getUserId(),
                    "IMPORT_DEVICES_CSV",
                    "tblDevices",
                    "BULK",
                    null,
                    "Imported " + count + " IoT devices from CSV",
                    req.getRemoteAddr()
            );
        }

        resp.sendRedirect(req.getContextPath() + "/device?msg=imported&count=" + count);
    }

    private AppUser getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") instanceof AppUser) {
            return (AppUser) session.getAttribute("user");
        }
        return null;
    }
}
