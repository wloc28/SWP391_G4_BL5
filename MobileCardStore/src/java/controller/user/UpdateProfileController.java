package controller.user;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.user.daoUser;
import dao.user.RegisterDAO;
import models.User;

/**
 * Update Profile Controller
 */
@WebServlet(name = "UpdateProfileController", urlPatterns = {"/updateProfile"})
public class UpdateProfileController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        
        // Kiểm tra đã đăng nhập chưa
        if (session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/view/login.jsp");
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
        String username = request.getParameter("username");
        String fullName = request.getParameter("fullname");
        String phoneNumber = request.getParameter("phone");
        String imageCode = request.getParameter("imageCode"); // Mã số avatar (image1, image2, image3)
        
        // Validate input
        if (username == null || username.trim().isEmpty()) {
            request.setAttribute("error", "Username không được để trống!");
            request.getRequestDispatcher("/viewProfile").forward(request, response);
            return;
        }
        
        if (fullName == null || fullName.trim().isEmpty()) {
            request.setAttribute("error", "Họ và tên không được để trống!");
            request.getRequestDispatcher("/viewProfile").forward(request, response);
            return;
        }
        
        if (phoneNumber == null || phoneNumber.trim().isEmpty()) {
            request.setAttribute("error", "Số điện thoại không được để trống!");
            request.getRequestDispatcher("/viewProfile").forward(request, response);
            return;
        }
        
        // Validate phone number - chỉ chứa số
        if (!phoneNumber.trim().matches("[0-9]+")) {
            request.setAttribute("error", "Số điện thoại chỉ được chứa số!");
            request.getRequestDispatcher("/viewProfile").forward(request, response);
            return;
        }
        
        // Validate full name - không chứa số
        if (fullName.trim().matches(".*\\d.*")) {
            request.setAttribute("error", "Họ và tên không được chứa số!");
            request.getRequestDispatcher("/viewProfile").forward(request, response);
            return;
        }
        
        // Kiểm tra username đã tồn tại (trừ chính user hiện tại)
        daoUser userDAO = new daoUser();
        User currentUser = userDAO.getUserById(userId);
        
        if (currentUser == null) {
            request.setAttribute("error", "Không tìm thấy thông tin user!");
            request.getRequestDispatcher("/viewProfile").forward(request, response);
            return;
        }
        
        // Nếu username thay đổi, kiểm tra trùng
        if (!username.trim().equals(currentUser.getUsername())) {
            RegisterDAO registerDAO = new RegisterDAO();
            if (registerDAO.checkUsernameExists(username.trim())) {
                request.setAttribute("error", "Username này đã được sử dụng!");
                request.getRequestDispatcher("/viewProfile").forward(request, response);
                return;
            }
        }
        
        // Xử lý image code
        String finalImageCode = imageCode;
        if (finalImageCode == null || finalImageCode.trim().isEmpty()) {
            // Nếu không có imageCode mới, giữ nguyên avatar hiện tại
            finalImageCode = currentUser.getImage();
            if (finalImageCode == null || finalImageCode.trim().isEmpty()) {
                // Nếu user chưa có avatar, set mặc định
                finalImageCode = "image2";
            }
        }
        
        // Cập nhật thông tin user
        User user = new User();
        user.setUserId(userId);
        user.setUsername(username.trim());
        user.setFullName(fullName.trim());
        user.setPhoneNumber(phoneNumber.trim());
        user.setImage(finalImageCode.trim()); // Lưu mã số vào database
        
        boolean success = userDAO.updateUser(user);
        
        if (success) {
            // Cập nhật session
            User updatedUser = userDAO.getUserById(userId);
            session.setAttribute("user", updatedUser);
            session.setAttribute("username", updatedUser.getUsername());
            
            // Redirect với success message
            String successMessage = java.net.URLEncoder.encode("Cập nhật thông tin thành công!", "UTF-8");
            response.sendRedirect(request.getContextPath() + "/viewProfile?success=" + successMessage);
        } else {
            // Redirect với error message
            String errorMessage = java.net.URLEncoder.encode("Cập nhật thông tin thất bại! Vui lòng thử lại.", "UTF-8");
            response.sendRedirect(request.getContextPath() + "/viewProfile?error=" + errorMessage);
        }
    }
}

