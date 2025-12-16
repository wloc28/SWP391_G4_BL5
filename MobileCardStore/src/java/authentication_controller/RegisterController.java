package authentication_controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import DAO.user.RegisterDAO;
import Models.User;
import util.OTPGenerator;
import util.EmailService;

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
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "sendOTP"; // Mặc định lần đầu submit form là gửi OTP đăng ký
        }

        switch (action) {
            case "sendOTP":
                handleSendOTP(request, response);
                break;
            case "verifyOTP":
                handleVerifyOTP(request, response);
                break;
            default:
                handleSendOTP(request, response);
        }
    }

    /**
     * 1: Nhận thông tin đăng ký, validate, gửi OTP và verify
     */
    private void handleSendOTP(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // get data
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullname");
        String phoneNumber = request.getParameter("mobile");
        String username = request.getParameter("username");
        
        // Validate input
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
        
        // Validate email
        String emailRegex = "^[A-Za-z0-9+_.-]+@(.+)$";
        String normalizedEmail = email.trim().toLowerCase();
        if (!normalizedEmail.matches(emailRegex)) {
            request.setAttribute("error", "Email không hợp lệ!");
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
            return;
        }
        
        // Validate password min 6 ký tự, có cả chữ, số
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
        
        // Validate sdt chỉ chứa số
        if (!phoneNumber.trim().matches("[0-9]+")) {
            request.setAttribute("error", "Số điện thoại chỉ được chứa số!");
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
            return;
        }
        
        // Validate sdt từ 9~12 số
        if (phoneNumber.length() < 9 || phoneNumber.length() > 12) {
            request.setAttribute("error", "Số điện thoại phải có từ 9~12 số!");
            request.setAttribute("email", email);
            request.setAttribute("fullname", fullName);
            request.setAttribute("mobile", phoneNumber);
            request.setAttribute("username", username);
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
            return;
        }        
        
        // Validate full name
        if (fullName.trim().matches(".*\\d.*")) {
            request.setAttribute("error", "Họ và tên không được chứa số!");
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
            return;
        }
        
        // Tạo username từ email nếu ko nhập
        if (username == null || username.trim().isEmpty()) {
            username = normalizedEmail.substring(0, normalizedEmail.indexOf("@"));
        }
        
        RegisterDAO registerDAO = new RegisterDAO();
        
        // Check email đã tồn tại
        if (registerDAO.checkEmailExists(normalizedEmail)) {
            request.setAttribute("error", "Email này đã được sử dụng!");
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
            return;
        }
        
        // Check username đã tồn tại
        if (registerDAO.checkUsernameExists(username.trim())) {
            request.setAttribute("error", "Username này đã được sử dụng!");
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
            return;
        }

        // Tạo User object tạm trong session, chưa lưu db
        User user = new User();
        user.setEmail(normalizedEmail);
        user.setPassword(password);
        user.setFullName(fullName.trim());
        user.setPhoneNumber(phoneNumber.trim());
        user.setUsername(username.trim());
        user.setRole("CUSTOMER");
        user.setStatus("ACTIVE");
        user.setImage("image2"); // Avatar mặc định

        try {
            // Lưu thông tin đăng ký tạm vào session
            HttpSession session = request.getSession();
            session.setAttribute("pendingUser", user);
            session.setAttribute("registerEmail", normalizedEmail);

            // send email OTP
            String otpCode = OTPGenerator.generateOTP(normalizedEmail);
            boolean emailSent = EmailService.sendOTPEmail(normalizedEmail, otpCode);

            if (!emailSent) {
                request.setAttribute("error", "Không gửi được email OTP. Vui lòng thử lại sau.");
                request.getRequestDispatcher("/view/register.jsp").forward(request, response);
                return;
            }

            request.setAttribute("success", "Đã gửi mã OTP tới email của bạn. Vui lòng kiểm tra hộp thư.");
            request.getRequestDispatcher("/view/verify-otp.jsp").forward(request, response);

        } catch (Exception e) {
            System.err.println("=== LỖI KHI GỬI OTP ĐĂNG KÝ ===");
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
            System.err.println("=== END ERR ===");
            request.setAttribute("error", "Có lỗi xảy ra khi gửi OTP: " + e.getMessage());
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
        }
    }

    /**
     * 2: Nhập OTP, xác thực và tạo tài khoản trong DB
     */
    private void handleVerifyOTP(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            request.setAttribute("error", "Phiên đăng ký đã hết hạn. Vui lòng đăng ký lại.");
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
            return;
        }

        String email = (String) session.getAttribute("registerEmail");
        User pendingUser = (User) session.getAttribute("pendingUser");

        if (email == null || pendingUser == null) {
            request.setAttribute("error", "Không tìm thấy thông tin đăng ký. Vui lòng đăng ký lại.");
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
            return;
        }

        String otpInput = request.getParameter("otp");
        if (otpInput == null || otpInput.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập mã OTP.");
            request.getRequestDispatcher("/view/verify-otp.jsp").forward(request, response);
            return;
        }

        boolean valid = OTPGenerator.verifyOTP(email, otpInput.trim());
        if (!valid) {
            request.setAttribute("error", "Mã OTP không đúng hoặc đã hết hạn. Vui lòng thử lại.");
            request.getRequestDispatcher("/view/verify-otp.jsp").forward(request, response);
            return;
        }

        // OTP đúng -> lưu user vào db
        RegisterDAO registerDAO = new RegisterDAO();
        try {
            boolean success = registerDAO.insertUser(pendingUser);

            if (success) {
                // Xóa dữ liệu tạm
                session.removeAttribute("pendingUser");
                session.removeAttribute("registerEmail");

                String successMessage = java.net.URLEncoder.encode("Đăng ký thành công! Vui lòng đăng nhập.", "UTF-8");
                String redirectUrl = request.getContextPath() + "/login?success=" + successMessage;
                response.sendRedirect(redirectUrl);
            } else {
                request.setAttribute("error", "Đăng ký thất bại! Vui lòng thử lại.");
                request.getRequestDispatcher("/view/register.jsp").forward(request, response);
            }
        } catch (Exception e) {
            System.err.println("=== LỖI KHI LƯU USER SAU OTP ===");
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
            System.err.println("=== END LỖI ===");
            request.setAttribute("error", "Có lỗi xảy ra khi hoàn tất đăng ký: " + e.getMessage());
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
        }
    }
}
