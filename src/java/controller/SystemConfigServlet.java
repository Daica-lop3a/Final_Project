package controller;

import dao.AuditLogDAO;
import dao.SystemConfigDAO;
import model.AppUser;
import model.SystemConfig;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Super Admin System Configuration and IoT Rule Management Controller
 * Strictly accessible by Super Admin (SAD).
 */
@WebServlet("/system/config")
public class SystemConfigServlet extends HttpServlet {

    private final SystemConfigDAO configDAO = new SystemConfigDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        AppUser user = (session != null) ? (AppUser) session.getAttribute("user") : null;

        if (user == null || !user.isSuperAdmin()) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        List<SystemConfig> configs = configDAO.getAll();
        req.setAttribute("CONFIGS", configs);

        String msg = req.getParameter("msg");
        if ("saved".equals(msg)) {
            req.setAttribute("SUCCESS_MSG", "System operational parameters and IoT telemetry rules have been successfully applied.");
        }

        req.getRequestDispatcher("/WEB-INF/views/systemConfig.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        AppUser user = (session != null) ? (AppUser) session.getAttribute("user") : null;

        if (user == null || !user.isSuperAdmin()) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        List<SystemConfig> currentConfigs = configDAO.getAll();
        for (SystemConfig cfg : currentConfigs) {
            String paramVal = req.getParameter(cfg.getConfigKey());
            if (paramVal != null && !paramVal.trim().isEmpty() && !paramVal.trim().equals(cfg.getConfigValue())) {
                String oldVal = cfg.getConfigValue();
                String newVal = paramVal.trim();
                boolean ok = configDAO.updateConfig(cfg.getConfigKey(), newVal, user.getUserId());
                if (ok) {
                    AuditLogDAO.log(
                            user.getUserId(),
                            "SYSTEM_CONFIG_UPDATE",
                            "tblSystemConfig",
                            cfg.getConfigKey(),
                            oldVal,
                            newVal,
                            req.getRemoteAddr()
                    );
                }
            }
        }

        resp.sendRedirect(req.getContextPath() + "/system/config?msg=saved");
    }
}
