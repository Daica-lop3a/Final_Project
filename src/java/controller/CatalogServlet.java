package controller;

import dao.AuditLogDAO;
import dao.CatalogDAO;
import model.AppUser;
import model.CatalogItem;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Controller for system catalogs (tblCatalogs)
 * Serves Super Admin and Admin
 */
@WebServlet(urlPatterns = {
    "/catalog",
    "/catalog/save",
    "/catalog/delete"
})
public class CatalogServlet extends HttpServlet {

    private final CatalogDAO catalogDAO = new CatalogDAO();

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

        if (currentUser.isCitizen()) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        String filterType = req.getParameter("type");
        List<CatalogItem> list;
        if (filterType != null && !filterType.trim().isEmpty()) {
            list = catalogDAO.getByType(filterType.trim());
        } else {
            list = catalogDAO.getAll();
        }

        req.setAttribute("CATALOG_LIST", list);
        req.setAttribute("FILTER_TYPE", filterType != null ? filterType : "");
        req.getRequestDispatcher("/WEB-INF/views/catalogList.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        AppUser currentUser = getCurrentUser(req);
        if (currentUser == null || (!currentUser.isSuperAdmin() && !currentUser.isAdmin())) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String uri = req.getRequestURI();

        if (uri.endsWith("/save")) {
            saveCatalogItem(req, resp, currentUser);
            return;
        }

        if (uri.endsWith("/delete")) {
            deleteCatalogItem(req, resp, currentUser);
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/catalog");
    }

    private void saveCatalogItem(HttpServletRequest req, HttpServletResponse resp, AppUser user)
            throws IOException {
        String idRaw = req.getParameter("catalogId");
        String catalogType = req.getParameter("catalogType");
        String itemCode = req.getParameter("itemCode");
        String itemName = req.getParameter("itemName");
        String description = req.getParameter("description");
        String orderRaw = req.getParameter("displayOrder");
        boolean active = "true".equalsIgnoreCase(req.getParameter("isActive")) || "on".equalsIgnoreCase(req.getParameter("isActive"));

        if (catalogType == null || itemCode == null || itemName == null ||
            catalogType.trim().isEmpty() || itemCode.trim().isEmpty() || itemName.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/catalog?error=missing_fields");
            return;
        }

        int catalogId = 0;
        try {
            if (idRaw != null && !idRaw.trim().isEmpty()) {
                catalogId = Integer.parseInt(idRaw.trim());
            }
        } catch (NumberFormatException ignored) {}

        int displayOrder = 1;
        try {
            if (orderRaw != null && !orderRaw.trim().isEmpty()) {
                displayOrder = Integer.parseInt(orderRaw.trim());
            }
        } catch (NumberFormatException ignored) {}

        CatalogItem item = new CatalogItem(catalogId, catalogType.trim(), itemCode.trim(), itemName.trim(), description, displayOrder, active);

        boolean success;
        if (catalogId <= 0) {
            success = catalogDAO.insert(item);
            if (success) {
                AuditLogDAO.log(user.getUserId(), "CREATE_CATALOG", "tblCatalogs", itemCode, null, "Added catalog item: " + itemName + " (" + catalogType + ")", req.getRemoteAddr());
            }
        } else {
            success = catalogDAO.update(item);
            if (success) {
                AuditLogDAO.log(user.getUserId(), "UPDATE_CATALOG", "tblCatalogs", String.valueOf(catalogId), null, "Updated catalog item: " + itemName + " (" + catalogType + ")", req.getRemoteAddr());
            }
        }

        resp.sendRedirect(req.getContextPath() + "/catalog?msg=saved");
    }

    private void deleteCatalogItem(HttpServletRequest req, HttpServletResponse resp, AppUser user)
            throws IOException {
        String idRaw = req.getParameter("id");
        try {
            int id = Integer.parseInt(idRaw);
            catalogDAO.delete(id);
            AuditLogDAO.log(user.getUserId(), "DELETE_CATALOG", "tblCatalogs", String.valueOf(id), null, "Deleted catalog item #" + id, req.getRemoteAddr());
        } catch (Exception ignored) {}

        resp.sendRedirect(req.getContextPath() + "/catalog?msg=deleted");
    }

    private AppUser getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") instanceof AppUser) {
            return (AppUser) session.getAttribute("user");
        }
        return null;
    }
}
