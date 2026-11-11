package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        javax.servlet.http.HttpSession session = req.getSession(false);
        if (session != null) {
            model.AppUser user = (model.AppUser) session.getAttribute("user");
            if (user != null) {
                dao.AuditLogDAO.log(user.getUserId(), "LOGOUT", "tblUsers",
                        user.getUserId(), null, "User logged out", req.getRemoteAddr());
            }
            session.invalidate();
        }
        resp.sendRedirect(req.getContextPath() + "/login");
    }
}
