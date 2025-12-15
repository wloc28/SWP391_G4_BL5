package authentication_controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import DAO.user.RegisterDAO;
import Models.User;

/**
 * Register Controller - Xử lý đăng ký user
 */
@WebServlet(name = "RegisterController", urlPatterns = {"/register"})
public class RegisterController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/view/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Lấy thông tin từ form
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullname");
        String phoneNumber = request.getParameter("mobile");
        String username = request.getParameter("username");
        
        // Validate input - Kiểm tra các trường bắt buộc
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Email không được để trống!");
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
            return;
        }
        
        if (password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Mật khẩu không được để trống!");
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
            return;
        }
        
        if (fullName == null || fullName.trim().isEmpty()) {
            request.setAttribute("error", "Họ và tên không được để trống!");
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
            return;
        }
        
        if (phoneNumber == null || phoneNumber.trim().isEmpty()) {
            request.setAttribute("error", "Số điện thoại không được để trống!");
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
            return;
        }
        
        // Validate email format
        String emailRegex = "^[A-Za-z0-9+_.-]+@(.+)$";
        String normalizedEmail = email.trim().toLowerCase();
        if (!normalizedEmail.matches(emailRegex)) {
            request.setAttribute("error", "Email không hợp lệ!");
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
            return;
        }
        
        // Validate password - ít nhất 6 ký tự, có chữ và số
        if (password.length() < 6) {
            request.setAttribute("error", "Mật khẩu phải có ít nhất 6 ký tự!");
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
            return;
        }
        
        if (!password.matches(".*[A-Za-z].*") || !password.matches(".*\\d.*")) {
            request.setAttribute("error", "Mật khẩu phải bao gồm cả chữ và số!");
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
            return;
        }
        
        // Validate phone number - chỉ chứa số
        if (!phoneNumber.trim().matches("[0-9]+")) {
            request.setAttribute("error", "Số điện thoại chỉ được chứa số!");
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
            return;
        }
        
        // Validate full name - không chứa số
        if (fullName.trim().matches(".*\\d.*")) {
            request.setAttribute("error", "Họ và tên không được chứa số!");
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
            return;
        }
        
        // Tạo username từ email nếu không có
        if (username == null || username.trim().isEmpty()) {
            username = normalizedEmail.substring(0, normalizedEmail.indexOf("@"));
        }
        
        RegisterDAO registerDAO = new RegisterDAO();
        
        // Kiểm tra email đã tồn tại
        if (registerDAO.checkEmailExists(normalizedEmail)) {
            request.setAttribute("error", "Email này đã được sử dụng!");
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
            return;
        }
        
        // Kiểm tra username đã tồn tại
        if (registerDAO.checkUsernameExists(username.trim())) {
            request.setAttribute("error", "Username này đã được sử dụng!");
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
            return;
        }
        
        // Tạo User object
        User user = new User();
        user.setEmail(normalizedEmail);
        user.setPassword(password);
        user.setFullName(fullName.trim());
        user.setPhoneNumber(phoneNumber.trim());
        user.setUsername(username.trim());
        user.setRole("CUSTOMER");
        user.setStatus("ACTIVE");
        user.setImage("image2"); // Avatar mặc định
        
        // Thêm user vào database
        try {
            System.out.println("=== BẮT ĐẦU ĐĂNG KÝ ===");
            System.out.println("Email: " + normalizedEmail);
            System.out.println("Username: " + username.trim());
            System.out.println("FullName: " + fullName.trim());
            System.out.println("Phone: " + phoneNumber.trim());
            
            boolean success = registerDAO.insertUser(user);
            
            System.out.println("Kết quả insertUser: " + success);
            
            if (success) {
                // Đăng ký thành công - Redirect về trang login với thông báo
                System.out.println("Đăng ký thành công, đang redirect về login...");
                String successMessage = java.net.URLEncoder.encode("Đăng ký thành công! Vui lòng đăng nhập.", "UTF-8");
                String redirectUrl = request.getContextPath() + "/view/login.jsp?success=" + successMessage;
                System.out.println("Redirect URL: " + redirectUrl);
                response.sendRedirect(redirectUrl);
                System.out.println("=== KẾT THÚC ĐĂNG KÝ THÀNH CÔNG ===");
            } else {
                // Đăng ký thất bại
                System.out.println("Đăng ký thất bại - insertUser trả về false!");
                request.setAttribute("error", "Đăng ký thất bại! Vui lòng thử lại.");
                request.getRequestDispatcher("/view/register.jsp").forward(request, response);
            }
        } catch (Exception e) {
            System.err.println("=== LỖI KHI ĐĂNG KÝ ===");
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
            System.err.println("=== END LỖI ===");
            request.setAttribute("error", "Có lỗi xảy ra khi đăng ký: " + e.getMessage());
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
        }
    }
}
