package util;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Random;

/**
 * PayOSConfig - cấu hình kết nối PayOS và hàm hỗ trợ ký request.
 */
public class PayOSConfig {

    // ====== CẤU HÌNH PAYOS ======
    public static final String CLIENT_ID = "bae977bf-29f8-425f-ad1c-35e058fa1cdc";
    public static final String API_KEY = "0b0aca71-433c-4bb6-ba6f-7f3ceb1c4327";
    public static final String CHECKSUM_KEY = "b639e467eec153c9e8b4d89d340fd0fbf861634e9901851cbeef53322620ec48";

    // Endpoint PayOS (sandbox hoặc production)
    public static final String ENDPOINT = "https://api-merchant.payos.vn/v2/payment-requests";

    // URL PayOS redirect user về sau thanh toán
    public static final String RETURN_URL = "http://localhost:8080/MobileCardStore/wallet/payos-return";

    // URL PayOS gọi webhook (server-to-server)
    public static final String CANCEL_URL = "http://localhost:8080/MobileCardStore/wallet/payos-cancel";

    /**
     * Sinh orderCode ngẫu nhiên (PayOS yêu cầu số nguyên dương)
     */
    public static int genOrderCode() {
        Random random = new Random();
        // PayOS yêu cầu orderCode là số nguyên dương, tạo số 6-9 chữ số
        return random.nextInt(900000) + 100000;
    }

    /**
     * Lấy thời gian hiện tại định dạng yyyy-MM-dd HH:mm:ss
     */
    public static String getCurrentDateTime() {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        return LocalDateTime.now().format(formatter);
    }

    /**
     * Hàm ký HMAC SHA256 theo hướng dẫn PayOS
     * @param data Chuỗi dữ liệu cần ký
     */
    public static String signSHA256(String data) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            SecretKeySpec secretKey = new SecretKeySpec(CHECKSUM_KEY.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
            mac.init(secretKey);
            byte[] bytes = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));

            StringBuilder hash = new StringBuilder();
            for (byte b : bytes) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hash.append('0');
                hash.append(hex);
            }
            return hash.toString();
        } catch (Exception e) {
            e.printStackTrace();
            return "";
        }
    }

    /**
     * Tạo signature cho PayOS payment request
     * Theo PayOS: signature = HMAC_SHA256(checksum_key, "amount={amount}&cancelUrl={cancelUrl}&description={description}&orderCode={orderCode}&returnUrl={returnUrl}")
     * Các trường được sắp xếp theo thứ tự bảng chữ cái
     */
    public static String createPaymentSignature(int amount, String cancelUrl, String description, int orderCode, String returnUrl) {
        // Sắp xếp theo thứ tự bảng chữ cái: amount, cancelUrl, description, orderCode, returnUrl
        String data = "amount=" + amount
                + "&cancelUrl=" + cancelUrl
                + "&description=" + description
                + "&orderCode=" + orderCode
                + "&returnUrl=" + returnUrl;
        
        return signSHA256(data);
    }
}

