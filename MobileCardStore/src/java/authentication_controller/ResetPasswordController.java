package authentication_controller;

import DAO.user.daoUser;
import Models.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Xử lý đặt lại mật khẩu sau khi xác thực OTP (quên mật khẩu)
 */
@WebServlet(name = "ResetPasswordController", urlPatterns = {"/resetpassword"})
public class ResetPasswordController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Hiển thị form reset password
        HttpSession session = request.getSession(false);
        String resetEmail = session != null ? (String) session.getAttribute("resetEmail") : null;
        
        if (resetEmail == null || resetEmail.trim().isEmpty()) {
            // Không có email trong session -> redirect về forgot password
            request.setAttribute("error", "Phiên đặt lại mật khẩu đã hết hạn. Vui lòng thực hiện lại quên mật khẩu.");
            request.getRequestDispatcher("/view/ForgotPassword.jsp").forward(request, response);
            return;
        }
        
        request.setAttribute("email", resetEmail);
        request.getRequestDispatcher("/view/ResetPassword.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String newPassword = request.getParameter("newpassword");
        String reNewPassword = request.getParameter("renewpassword");

        HttpSession session = request.getSession(false);
        if (session == null) {
            request.setAttribute("error", "Phiên đặt lại mật khẩu đã hết hạn. Vui lòng thực hiện lại quên mật khẩu.");
            request.getRequestDispatcher("/view/ForgotPassword.jsp").forward(request, response);
            return;
        }
        
        String email = (String) session.getAttribute("resetEmail");
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Phiên đặt lại mật khẩu đã hết hạn. Vui lòng thực hiện lại quên mật khẩu.");
            request.getRequestDispatcher("/view/ForgotPassword.jsp").forward(request, response);
            return;
        }

        if (newPassword == null || newPassword.trim().isEmpty()
                || reNewPassword == null || reNewPassword.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ mật khẩu mới.");
            request.getRequestDispatcher("/view/ResetPassword.jsp").forward(request, response);
            return;
        }

        if (!newPassword.equals(reNewPassword)) {
            request.setAttribute("error", "Mật khẩu nhập lại không khớp.");
            request.getRequestDispatcher("/view/ResetPassword.jsp").forward(request, response);
            return;
        }

        // Đơn giản: kiểm tra độ dài tối thiểu
        if (newPassword.length() < 6) {
            request.setAttribute("error", "Mật khẩu mới phải có ít nhất 6 ký tự.");
            request.getRequestDispatcher("/view/ResetPassword.jsp").forward(request, response);
            return;
        }

        String normalizedEmail = email.trim().toLowerCase();
        
        try {
            System.out.println("========================================");
            System.out.println("=== ResetPasswordController.doPost ===");
            System.out.println("Email from session: " + email);
            System.out.println("Email normalized: " + normalizedEmail);
            System.out.println("New password: " + newPassword);
            System.out.println("New password length: " + (newPassword != null ? newPassword.length() : 0));
            
            daoUser userDao = new daoUser();
            
            // Bước 1: Update password trong database
            System.out.println("\n--- BƯỚC 1: UPDATE PASSWORD ---");
            boolean updated = userDao.updatePasswordByEmail(normalizedEmail, newPassword);
            System.out.println("Update password result: " + updated);

            if (!updated) {
                System.out.println("✗ UPDATE THẤT BẠI - Không thể cập nhật mật khẩu trong DB");
                request.setAttribute("error", "Không thể cập nhật mật khẩu. Email không tồn tại hoặc đã bị xóa. Vui lòng thử lại.");
                request.setAttribute("email", email);
                request.getRequestDispatcher("/view/ResetPassword.jsp").forward(request, response);
                return;
            }

            System.out.println("✓ UPDATE THÀNH CÔNG!");

            // Bước 2: Verify - Kiểm tra lại bằng cách login với password mới
            System.out.println("\n--- BƯỚC 2: VERIFY PASSWORD MỚI ---");
            User verifyUser = userDao.login(normalizedEmail, newPassword);
            
            if (verifyUser == null) {
                System.out.println("✗ VERIFY THẤT BẠI - Không thể login với password mới!");
                System.out.println("Có thể password chưa được lưu đúng trong DB");
                request.setAttribute("error", "Đã cập nhật mật khẩu nhưng xác thực thất bại. Vui lòng thử lại quên mật khẩu.");
                request.setAttribute("email", email);
                request.getRequestDispatcher("/view/ResetPassword.jsp").forward(request, response);
                return;
            }
            
            System.out.println("✓ VERIFY THÀNH CÔNG!");
            System.out.println("User ID: " + verifyUser.getUserId());
            System.out.println("Email: " + verifyUser.getEmail());
            System.out.println("Username: " + verifyUser.getUsername());

            // Xóa thông tin reset khỏi session
            session.removeAttribute("resetEmail");
            System.out.println("Đã xóa resetEmail khỏi session");

            // Redirect về trang login với thông báo thành công
            String successMessage = java.net.URLEncoder.encode("Đặt lại mật khẩu thành công! Vui lòng đăng nhập với mật khẩu mới.", "UTF-8");
            String redirectUrl = request.getContextPath() + "/login?success=" + successMessage;
            System.out.println("\nRedirect URL: " + redirectUrl);
            System.out.println("=== END ResetPasswordController.doPost ===");
            System.out.println("========================================\n");
            
            response.sendRedirect(redirectUrl);

        } catch (Exception e) {
            System.err.println("========================================");
            System.err.println("=== LỖI KHI RESET MẬT KHẨU ===");
            System.err.println("Exception type: " + e.getClass().getName());
            System.err.println("Exception message: " + e.getMessage());
            e.printStackTrace();
            System.err.println("========================================\n");
            request.setAttribute("error", "Có lỗi xảy ra khi đặt lại mật khẩu: " + e.getMessage());
            request.setAttribute("email", email);
            request.getRequestDispatcher("/view/ResetPassword.jsp").forward(request, response);
        }
    }
}



