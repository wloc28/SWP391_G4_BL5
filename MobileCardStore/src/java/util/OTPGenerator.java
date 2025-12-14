package util;

import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * OTP Generator và Manager
 * Quản lý việc tạo, lưu trữ và xác thực OTP
 */
public class OTPGenerator {
    
    private static final int OTP_LENGTH = 6;
    private static final long OTP_EXPIRY_TIME = 5 * 60 * 1000; // 5 phút
    private static final Random random = new Random();
    
    // Lưu trữ OTP tạm thời: email -> OTPData
    private static final ConcurrentHashMap<String, OTPData> otpStorage = new ConcurrentHashMap<>();
    
    // Scheduler để xóa OTP hết hạn
    private static final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);
    
    static {
        // Chạy task dọn dẹp OTP hết hạn mỗi phút
        scheduler.scheduleAtFixedRate(OTPGenerator::cleanExpiredOTPs, 1, 1, TimeUnit.MINUTES);
    }
    
    /**
     * Tạo OTP mới cho email
     * @param email Email cần tạo OTP
     * @return OTP code (6 chữ số)
     */
    public static String generateOTP(String email) {
        // Tạo OTP 6 chữ số
        StringBuilder otp = new StringBuilder();
        for (int i = 0; i < OTP_LENGTH; i++) {
            otp.append(random.nextInt(10));
        }
        
        String otpCode = otp.toString();
        long expiryTime = System.currentTimeMillis() + OTP_EXPIRY_TIME;
        
        // Lưu OTP với thời gian hết hạn
        otpStorage.put(email, new OTPData(otpCode, expiryTime));
        
        return otpCode;
    }
    
    /**
     * Xác thực OTP
     * @param email Email cần xác thực
     * @param otpCode OTP code nhập vào
     * @return true nếu OTP đúng và chưa hết hạn, false nếu sai hoặc hết hạn
     */
    public static boolean verifyOTP(String email, String otpCode) {
        OTPData otpData = otpStorage.get(email);
        
        if (otpData == null) {
            return false; // Không có OTP cho email này
        }
        
        // Kiểm tra hết hạn
        if (System.currentTimeMillis() > otpData.getExpiryTime()) {
            otpStorage.remove(email); // Xóa OTP hết hạn
            return false;
        }
        
        // Kiểm tra OTP code
        if (otpData.getOtpCode().equals(otpCode)) {
            otpStorage.remove(email); // Xóa OTP sau khi xác thực thành công
            return true;
        }
        
        return false;
    }
    
    /**
     * Xóa OTP của email (sau khi đăng ký thành công)
     * @param email Email cần xóa OTP
     */
    public static void removeOTP(String email) {
        otpStorage.remove(email);
    }
    
    /**
     * Kiểm tra OTP còn hiệu lực không
     * @param email Email cần kiểm tra
     * @return true nếu còn OTP hiệu lực, false nếu không
     */
    public static boolean hasValidOTP(String email) {
        OTPData otpData = otpStorage.get(email);
        if (otpData == null) {
            return false;
        }
        return System.currentTimeMillis() <= otpData.getExpiryTime();
    }
    
    /**
     * Dọn dẹp các OTP hết hạn
     */
    private static void cleanExpiredOTPs() {
        long currentTime = System.currentTimeMillis();
        otpStorage.entrySet().removeIf(entry -> currentTime > entry.getValue().getExpiryTime());
    }
    
    /**
     * Inner class để lưu trữ OTP data
     */
    private static class OTPData {
        private final String otpCode;
        private final long expiryTime;
        
        public OTPData(String otpCode, long expiryTime) {
            this.otpCode = otpCode;
            this.expiryTime = expiryTime;
        }
        
        public String getOtpCode() {
            return otpCode;
        }
        
        public long getExpiryTime() {
            return expiryTime;
        }
    }
}




