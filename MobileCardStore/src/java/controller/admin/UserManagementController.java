package controller.admin;

import DAO.admin.UserDAO;
import Models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Admin user management controller.
 */
@WebServlet(name = "UserManagementController", urlPatterns = {"/admin/users", "/admin/user-detail"})
public class UserManagementController extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/admin/user-detail".equals(path)) {
            handleDetail(request, response);
        } else {
            handleList(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("status".equalsIgnoreCase(action)) {
            handleStatusUpdate(request, response);
        } else if ("update".equalsIgnoreCase(action)) {
            handleUpdate(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/users");
        }
    }

    private void handleList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        String role = request.getParameter("role");
        String status = request.getParameter("status");
        String sortBy = request.getParameter("sortBy");
        String sortDir = request.getParameter("sortDir");

        if (role == null || role.isEmpty()) role = "ALL";
        if (status == null || status.isEmpty()) status = "ALL";
        if (sortBy == null || sortBy.isEmpty()) sortBy = "created_at";
        if (sortDir == null || sortDir.isEmpty()) sortDir = "DESC";

        int page = 1;
        int pageSize = 12;
        try {
            page = Integer.parseInt(request.getParameter("page"));
            if (page < 1) page = 1;
        } catch (NumberFormatException ignored) {
        }

        try {
            List<User> users = userDAO.listUsers(keyword, role, status, sortBy, sortDir, page, pageSize);
            int total = userDAO.countUsers(keyword, role, status);
            int totalPages = (int) Math.ceil((double) total / pageSize);
            if (totalPages == 0) totalPages = 1;
            if (page > totalPages) page = totalPages;

            request.setAttribute("users", users);
            request.setAttribute("keyword", keyword);
            request.setAttribute("role", role);
            request.setAttribute("status", status);
            request.setAttribute("sortBy", sortBy);
            request.setAttribute("sortDir", sortDir);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalCount", total);
            request.setAttribute("pageSize", pageSize);

            request.getRequestDispatcher("/view/ManageUsers.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Error loading users", e);
        }
    }

    private void handleDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }
        try {
            int userId = Integer.parseInt(idStr);
            User user = userDAO.getUserById(userId);
            if (user == null) {
                response.sendRedirect(request.getContextPath() + "/admin/users?error=Không tìm thấy người dùng.");
                return;
            }
            request.setAttribute("user", user);
            request.getRequestDispatcher("/view/ManageUserDetail.jsp").forward(request, response);
        } catch (NumberFormatException | SQLException e) {
            throw new ServletException("Error loading user detail", e);
        }
    }

    private void handleStatusUpdate(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        String idStr = request.getParameter("userId");
        String newStatus = request.getParameter("status");
        if (idStr == null || newStatus == null) {
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }
        try {
            int userId = Integer.parseInt(idStr);
            userDAO.updateStatus(userId, newStatus);
            // redirect back to detail if coming from detail page
            String redirect = request.getParameter("redirect");
            if ("detail".equalsIgnoreCase(redirect)) {
                response.sendRedirect(request.getContextPath() + "/admin/user-detail?id=" + userId);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/users");
            }
        } catch (NumberFormatException | SQLException e) {
            throw new ServletException("Error updating status", e);
        }
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        try {
            int userId = Integer.parseInt(request.getParameter("userId"));
            String username = request.getParameter("username");
            String fullName = request.getParameter("fullName");
            String phone = request.getParameter("phoneNumber");
            String role = request.getParameter("role");
            String status = request.getParameter("status");
            String balanceStr = request.getParameter("balance");

            java.math.BigDecimal balance = java.math.BigDecimal.ZERO;
            try {
                balance = new java.math.BigDecimal(balanceStr);
            } catch (Exception ignored) {
            }

            User user = new User();
            user.setUserId(userId);
            user.setUsername(username);
            user.setFullName(fullName);
            user.setPhoneNumber(phone);
            user.setRole(role);
            user.setStatus(status);
            user.setBalance(balance);

            userDAO.updateUser(user);
            response.sendRedirect(request.getContextPath() + "/admin/user-detail?id=" + userId);
        } catch (Exception e) {
            throw new ServletException("Error updating user", e);
        }
    }
}

