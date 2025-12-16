/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package authentication_controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import DAO.user.RegisterDAO;
import util.OTPGenerator;
import util.EmailService;

/**
 *
 * @author Admin
 */
@WebServlet(name = "ForgotPassword", urlPatterns = {"/forgotpassword"})
public class ForgotPassword extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/view/ForgotPassword.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "sendOTP";
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
     * Bước 1: Nhập email và gửi OTP reset mật khẩu
     */
    private void handleSendOTP(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");

        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Email không được để trống!");
            // Forward lại JSP, URL trên trình duyệt vẫn là /forgotpassword
            request.getRequestDispatcher("/view/ForgotPassword.jsp").forward(request, response);
            return;
        }

        String normalizedEmail = email.trim().toLowerCase();

        // Kiểm tra email có tồn tại trong hệ thống không
        RegisterDAO registerDAO = new RegisterDAO();
        boolean exists = registerDAO.checkEmailExists(normalizedEmail);

        if (!exists) {
            // Vì lý do bảo mật, có thể dùng message chung chung
            request.setAttribute("error", "Nếu email tồn tại trong hệ thống, chúng tôi đã gửi mã OTP reset mật khẩu.");
            request.getRequestDispatcher("/view/ForgotPassword.jsp").forward(request, response);
            return;
        }

        try {
            HttpSession session = request.getSession();
            session.setAttribute("resetEmail", normalizedEmail);

            String otpCode = OTPGenerator.generateOTP(normalizedEmail);
            boolean emailSent = EmailService.sendOTPEmail(normalizedEmail, otpCode);

            if (!emailSent) {
                request.setAttribute("error", "Không gửi được email OTP. Vui lòng thử lại sau.");
                request.getRequestDispatcher("/view/ForgotPassword.jsp").forward(request, response);
                return;
            }

            request.setAttribute("success", "Đã gửi mã OTP reset mật khẩu tới email của bạn. Vui lòng kiểm tra hộp thư.");
            request.getRequestDispatcher("/view/ForgotPasswordOTP.jsp").forward(request, response);

        } catch (Exception e) {
            System.err.println("=== LỖI KHI GỬI OTP QUÊN MẬT KHẨU ===");
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi gửi OTP: " + e.getMessage());
            request.getRequestDispatcher("/view/ForgotPassword.jsp").forward(request, response);
        }
    }

    /**
     * Bước 2: Người dùng nhập OTP để xác nhận, sau đó chuyển sang màn hình đặt mật khẩu mới
     */
    private void handleVerifyOTP(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            request.setAttribute("error", "Phiên quên mật khẩu đã hết hạn. Vui lòng thử lại.");
            request.getRequestDispatcher("/view/ForgotPassword.jsp").forward(request, response);
            return;
        }

        String email = (String) session.getAttribute("resetEmail");
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Không tìm thấy thông tin email cần reset. Vui lòng thử lại.");
            request.getRequestDispatcher("/view/ForgotPassword.jsp").forward(request, response);
            return;
        }

        String otpInput = request.getParameter("otp");
        if (otpInput == null || otpInput.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập mã OTP.");
            request.getRequestDispatcher("/view/ForgotPasswordOTP.jsp").forward(request, response);
            return;
        }

        boolean valid = OTPGenerator.verifyOTP(email, otpInput.trim());
        if (!valid) {
            request.setAttribute("error", "Mã OTP không đúng hoặc đã hết hạn. Vui lòng thử lại.");
            request.getRequestDispatcher("/view/ForgotPasswordOTP.jsp").forward(request, response);
            return;
        }

        // OTP hợp lệ -> giữ email trong session và chuyển sang trang đặt lại mật khẩu mới
        // Đảm bảo resetEmail vẫn còn trong session để ResetPasswordController dùng
        if (session != null) {
            session.setAttribute("resetEmail", email);
            System.out.println("Đã giữ resetEmail trong session: " + email);
        }
        
        String redirectUrl = request.getContextPath() + "/resetpassword";
        System.out.println("Redirect to: " + redirectUrl);
        response.sendRedirect(redirectUrl);
    }

}
