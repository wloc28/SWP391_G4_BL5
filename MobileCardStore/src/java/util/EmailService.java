package util;

import java.util.Properties;
import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

/**
 * Email Service để gửi email OTP qua Google SMTP
 */
public class EmailService {
    
    // Cấu hình Gmail SMTP với STARTTLS (port 587)
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static final String FROM_EMAIL = "thanhlct166@gmail.com";
    private static final String FROM_PASSWORD = "hrdy lvkh kfqg gpbc"; // Có thể cần App Password thay vì password thường
    
    /**
     * Gửi email OTP đến địa chỉ email
     * @param toEmail Địa chỉ email nhận
     * @param otpCode Mã OTP
     * @return true nếu gửi thành công, false nếu thất bại
     */
    public static boolean sendOTPEmail(String toEmail, String otpCode) {
        System.out.println("=== BẮT ĐẦU GỬI EMAIL OTP ===");
        System.out.println("From: " + FROM_EMAIL);
        System.out.println("To: " + toEmail);
        System.out.println("OTP: " + otpCode);
        System.out.println("SMTP Host: " + SMTP_HOST);
        System.out.println("SMTP Port: " + SMTP_PORT);
        
        try {
            // Cấu hình properties
            Properties properties = new Properties();
            properties.put("mail.smtp.host", SMTP_HOST);
            properties.put("mail.smtp.port", SMTP_PORT);
            properties.put("mail.smtp.auth", "true");
            properties.put("mail.smtp.starttls.enable", "true");
            properties.put("mail.smtp.starttls.required", "true");
            properties.put("mail.smtp.ssl.trust", SMTP_HOST);
            properties.put("mail.smtp.ssl.protocols", "TLSv1.2");
            properties.put("mail.smtp.connectiontimeout", "10000");
            properties.put("mail.smtp.timeout", "10000");
            properties.put("mail.debug", "true"); // Bật debug mode
            
            System.out.println("Đã cấu hình properties");
            
            // Tạo session với authenticator
            Session session = Session.getInstance(properties, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    System.out.println("Đang xác thực với email: " + FROM_EMAIL);
                    return new PasswordAuthentication(FROM_EMAIL, FROM_PASSWORD);
                }
            });
            
            System.out.println("Đã tạo session");
            
            // Tạo message
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL, "Mobile Card Store"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("Xác thực Email - Mobile Card Store");
            
            // Nội dung email
            String emailContent = buildOTPEmailContent(otpCode);
            message.setContent(emailContent, "text/html; charset=UTF-8");
            
            System.out.println("Đã tạo message, đang gửi...");
            
            // Gửi email
            Transport.send(message);
            
            System.out.println("=== THÀNH CÔNG: OTP email đã được gửi đến: " + toEmail + " ===");
            return true;
            
        } catch (MessagingException e) {
            System.err.println("=== LỖI KHI GỬI EMAIL OTP ===");
            System.err.println("Message: " + e.getMessage());
            System.err.println("Cause: " + (e.getCause() != null ? e.getCause().getMessage() : "null"));
            e.printStackTrace();
            return false;
        } catch (Exception e) {
            System.err.println("=== LỖI KHÔNG XÁC ĐỊNH ===");
            System.err.println("Message: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Tạo nội dung email OTP
     * @param otpCode Mã OTP
     * @return HTML content của email
     */
    private static String buildOTPEmailContent(String otpCode) {
        return "<!DOCTYPE html>" +
               "<html>" +
               "<head>" +
               "<meta charset='UTF-8'>" +
               "<style>" +
               "body { font-family: Arial, sans-serif; }" +
               ".container { max-width: 600px; margin: 0 auto; padding: 20px; }" +
               ".otp-box { background-color: #f4f4f4; padding: 20px; text-align: center; border-radius: 5px; margin: 20px 0; }" +
               ".otp-code { font-size: 32px; font-weight: bold; color: #007bff; letter-spacing: 5px; }" +
               ".warning { color: #dc3545; font-size: 14px; margin-top: 20px; }" +
               "</style>" +
               "</head>" +
               "<body>" +
               "<div class='container'>" +
               "<h2>Xác thực Email - Mobile Card Store</h2>" +
               "<p>Xin chào,</p>" +
               "<p>Cảm ơn bạn đã đăng ký tài khoản tại Mobile Card Store.</p>" +
               "<p>Mã OTP của bạn là:</p>" +
               "<div class='otp-box'>" +
               "<div class='otp-code'>" + otpCode + "</div>" +
               "</div>" +
               "<p>Mã OTP này có hiệu lực trong <strong>5 phút</strong>.</p>" +
               "<p class='warning'>⚠️ Lưu ý: Không chia sẻ mã OTP này với bất kỳ ai.</p>" +
               "<p>Nếu bạn không yêu cầu mã này, vui lòng bỏ qua email này.</p>" +
               "<hr>" +
               "<p style='color: #666; font-size: 12px;'>Đây là email tự động, vui lòng không trả lời email này.</p>" +
               "</div>" +
               "</body>" +
               "</html>";
    }
    
    /**
     * Cập nhật thông tin email và password
     * Gọi method này để cấu hình email thực tế
     */
    public static void configureEmail(String email, String appPassword) {
        // Note: Trong thực tế, nên lưu vào file config hoặc environment variables
        // Đây chỉ là ví dụ, cần cập nhật các constant ở trên
        System.out.println("Cần cập nhật FROM_EMAIL và FROM_PASSWORD trong EmailService.java");
        System.out.println("Email: " + email);
        System.out.println("App Password: " + appPassword);
    }
}

