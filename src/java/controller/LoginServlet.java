package controller;

import dao.AuditLogDAO;
import dao.UserDAO;
import model.AppUser;
import util.PasswordUtil;

import java.io.IOException;
import java.util.concurrent.ConcurrentHashMap;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * COM-01 and COM-06: Unified Authentication and Account Lockout Guard
 * - Shared across all 8 roles
 * - Enforces max 5 consecutive failed login attempts before locking account
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private static final String LOGIN_PAGE = "/WEB-INF/views/login.jsp";
    private static final String SUCCESS = "/dashboard";
    private static final int MAX_FAILED_ATTEMPTS = 5;

    // Thread-safe map tracking failed login attempts per user
    public static final ConcurrentHashMap<String, Integer> FAILED_ATTEMPTS = new ConcurrentHashMap<String, Integer>();

    private final UserDAO users = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String msg = request.getParameter("msg");
        if ("reset_success".equals(msg)) {
            request.setAttribute("SUCCESS", "Your password has been successfully reset. Please sign in with your new credentials.");
        } else if ("logged_out".equals(msg)) {
            request.setAttribute("SUCCESS", "You have been logged out successfully.");
        }

        request.getRequestDispatcher(LOGIN_PAGE)
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username != null) {
            username = username.trim();
        }

        try {
            AppUser user = users.findByUsername(username);

            if (user == null) {
                request.setAttribute("ERROR", "Invalid email or password");
                request.setAttribute("OLD_USERNAME", username);

            } else if (!user.isStatus()) {
                request.setAttribute("ERROR", "Your account has been locked. Please contact your Super Administrator.");
                request.setAttribute("OLD_USERNAME", username);

            } else if (password == null || !PasswordUtil.verify(password, user.getPassword())) {
                // Failed login attempt counter & lockout protection
                int attempts = FAILED_ATTEMPTS.getOrDefault(user.getUserId(), 0) + 1;
                FAILED_ATTEMPTS.put(user.getUserId(), attempts);

                if (attempts >= MAX_FAILED_ATTEMPTS) {
                    // Automatically lock account after exceeding threshold
                    users.setStatus(user.getUserId(), false);
                    AuditLogDAO.log(user.getUserId(), "SECURITY_LOCKOUT", "tblUsers",
                            user.getUserId(), "status: active", "status: locked (exceeded 5 failed login attempts)", request.getRemoteAddr());
                    FAILED_ATTEMPTS.remove(user.getUserId());
                    request.setAttribute("ERROR", "Account locked: Maximum login attempts exceeded (5/5). Your account is now locked for security. Please contact Super Admin.");
                } else {
                    int remaining = MAX_FAILED_ATTEMPTS - attempts;
                    request.setAttribute("ERROR", "Invalid email or password. (" + remaining + " attempts remaining before account lockout)");
                }
                request.setAttribute("OLD_USERNAME", username);

            } else {
                // Successful login - reset failed attempt counter
                FAILED_ATTEMPTS.remove(user.getUserId());

                HttpSession session = request.getSession(true);
                try {
                    request.changeSessionId();
                } catch (Exception ignored) {}

                session.setAttribute("user", user);

                // Log login action to security audit trail
                AuditLogDAO.log(user.getUserId(), "LOGIN", "tblUsers",
                        user.getUserId(), null, "User logged in successfully (" + user.getRoleName() + ")", request.getRemoteAddr());

                response.sendRedirect(request.getContextPath() + SUCCESS);
                return;
            }

        } catch (Exception e) {
            log("Error in LoginServlet", e);
            request.setAttribute("ERROR", "A system error occurred. Please try again.");
        }

        request.getRequestDispatcher(LOGIN_PAGE)
                .forward(request, response);
    }
}
