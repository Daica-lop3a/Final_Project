package controller;

import dao.UserDAO;
import model.AppUser;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private static final String REGISTER_PAGE
            = "/WEB-INF/views/register.jsp";

    private final UserDAO users = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher(REGISTER_PAGE)
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phoneNumber = request.getParameter("phoneNumber");
        String password = request.getParameter("password");
        String confirmPassword
                = request.getParameter("confirmPassword");

        // Remove unnecessary spaces.
        if (fullName != null) {
            fullName = fullName.trim();
        }

        if (email != null) {
            email = email.trim().toLowerCase();
        }

        if (phoneNumber != null) {
            phoneNumber = phoneNumber.trim();
        }

        // Check required fields.
        if (fullName == null || fullName.isEmpty()
                || email == null || email.isEmpty()
                || phoneNumber == null || phoneNumber.isEmpty()
                || password == null || password.isEmpty()
                || confirmPassword == null
                || confirmPassword.isEmpty()) {

            showError(request, response,
                    "Please fill in all fields.");
            return;
        }

        // Check field lengths.
        if (fullName.length() > 100
                || email.length() > 100
                || phoneNumber.length() > 15) {

            showError(request, response,
                    "One or more fields exceed the allowed length.");
            return;
        }

        // Check email format.
        if (!email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            showError(request, response,
                    "Please enter a valid email address.");
            return;
        }

        // Check phone number format.
        if (!phoneNumber.matches("^(?:\\+84|0)[35789]\\d{8}$")) {
            showError(request, response,
                    "Invalid Vietnamese phone number. Format: 03x, 05x, 07x, 08x, 09x (e.g. 0901234567 or +84901234567).");
            return;
        }

        // Check password length.
        if (password.length() < 8) {
            showError(request, response,
                    "Password must contain at least 8 characters.");
            return;
        }

        // Check password confirmation.
        if (!password.equals(confirmPassword)) {
            showError(request, response,
                    "Passwords do not match.");
            return;
        }

        try {
            // Check whether the email already exists.
            AppUser existingUser = users.findByUsername(email);

            if (existingUser != null) {
                showError(request, response,
                        "This email is already registered.");
                return;
            }

            // Generate next sequential user ID (e.g. USR-004)
            String userId = util.IdGenerator.nextUserId("USR");

            // Create a new user account with the standard user role.
            AppUser user = new AppUser(
                    userId,
                    fullName,
                    email,
                    phoneNumber,
                    "USR",
                    password,
                    true
            );

            // Save the user to the database.
            // UserDAO hashes the password before saving it.
            boolean success = users.insert(user);

            if (success) {
                response.sendRedirect(
                        request.getContextPath()
                        + "/login?registered=success");
            } else {
                showError(request, response,
                        "Registration failed. Please try again.");
            }

        } catch (Exception e) {
            log("Error in RegisterServlet", e);

            showError(request, response,
                    "Registration failed. Please try again.");
        }
    }

    private void showError(HttpServletRequest request,
            HttpServletResponse response,
            String message)
            throws ServletException, IOException {

        request.setAttribute("ERROR", message);

        request.getRequestDispatcher(REGISTER_PAGE)
                .forward(request, response);
    }
}
