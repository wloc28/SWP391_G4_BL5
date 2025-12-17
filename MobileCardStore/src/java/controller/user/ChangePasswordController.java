package controller.user;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import DAO.user.daoUser;

/**
 * Change Password Controller
 */
@WebServlet(name = "ChangePasswordController", urlPatterns = {"/changePassword"})
public class ChangePasswordController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        
        // Kiểm tra đã đăng nhập chưa
        if (session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // Lấy userId từ session
        Integer userId = (Integer) session.getAttribute("userId");
        
        if (userId == null) {
            request.setAttribute("error", "Không tìm thấy thông tin user!");
            request.getRequestDispatcher("/view/ViewProfile.jsp").forward(request, response);
            return;
        }
        
        // Lấy thông tin từ form
        String oldPassword = request.getParameter("oldPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");
        
        // Validate input
        if (oldPassword == null || oldPassword.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập mật khẩu cũ!");
            request.getRequestDispatcher("/viewProfile").forward(request, response);
            return;
        }
        
        
        if (newPassword == null || newPassword.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập mật khẩu mới!");
            request.getRequestDispatcher("/viewProfile").forward(request, response);
            return;
        }
        
        if (confirmPassword == null || confirmPassword.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng xác nhận mật khẩu mới!");
            request.getRequestDispatcher("/viewProfile").forward(request, response);
            return;
        }
        
        // Kiểm tra mật khẩu mới và xác nhận khớp
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu mới và xác nhận không khớp!");
            request.getRequestDispatcher("/viewProfile").forward(request, response);
            return;
        }
        
        // Validate password - ít nhất 6 ký tự, có chữ và số
        if (newPassword.length() < 6) {
            request.setAttribute("error", "Mật khẩu mới phải có ít nhất 6 ký tự!");
            request.getRequestDispatcher("/viewProfile").forward(request, response);
            return;
        }
        
        if (!newPassword.matches(".*[A-Za-z].*") || !newPassword.matches(".*\\d.*")) {
            request.setAttribute("error", "Mật khẩu mới phải bao gồm cả chữ và số!");
            request.getRequestDispatcher("/viewProfile").forward(request, response);
            return;
        }
        
        // Đổi mật khẩu
        daoUser userDAO = new daoUser();
        boolean success = userDAO.changePassword(userId, oldPassword, newPassword);
        
        if (success) {
            // Redirect với success message
            String successMessage = java.net.URLEncoder.encode("Đổi mật khẩu thành công!", "UTF-8");
            response.sendRedirect(request.getContextPath() + "/viewProfile?success=" + successMessage);
        } else {
            // Redirect với error message
            String errorMessage = java.net.URLEncoder.encode("Đổi mật khẩu thất bại! Mật khẩu cũ không đúng.", "UTF-8");
            response.sendRedirect(request.getContextPath() + "/viewProfile?error=" + errorMessage);
        }
    }
}

