package controller.user;

import DAO.admin.PaymentGatewayTransactionDAO;
import DAO.admin.TransactionDAO;
import DAO.user.daoUser;
import Models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import util.PayOSConfig;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

/**
 * WalletPayOSServlet
 *  - POST /wallet/payos        : tạo payment request tới PayOS, redirect user sang trang thanh toán
 *  - GET  /wallet/payos-return : xử lý kết quả PayOS redirect về, cộng tiền vào ví
 *  - GET  /wallet/payos-cancel : xử lý khi user hủy thanh toán, redirect về trang nạp tiền
 */
@WebServlet(name = "WalletPayOSServlet", urlPatterns = { "/wallet/payos", "/wallet/payos-return", "/wallet/payos-cancel" })
public class WalletPayOSServlet extends HttpServlet {

    private TransactionDAO transactionDAO;
    private PaymentGatewayTransactionDAO paymentGatewayTransactionDAO;
    private daoUser userDAO;

    @Override
    public void init() throws ServletException {
        transactionDAO = new TransactionDAO();
        paymentGatewayTransactionDAO = new PaymentGatewayTransactionDAO();
        userDAO = new daoUser();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/wallet/payos".equals(path)) {
            createPayment(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/wallet/payos-return".equals(path)) {
            handleReturn(request, response);
        } else if ("/wallet/payos-cancel".equals(path)) {
            handleCancel(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    /** B1: Gửi request tới PayOS để lấy checkoutUrl rồi redirect user */
    private void createPayment(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        HttpSession session = request.getSession();
        User user = (User) (session.getAttribute("info") != null
                ? session.getAttribute("info")
                : session.getAttribute("user"));

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/view/login.jsp");
            return;
        }

        String amountStr = request.getParameter("amount");
        if (amountStr == null || amountStr.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập số tiền cần nạp");
            request.getRequestDispatcher("/wallet").forward(request, response);
            return;
        }

        try {
            BigDecimal amount = new BigDecimal(amountStr.trim());
            if (amount.compareTo(BigDecimal.ZERO) <= 0) {
                request.setAttribute("error", "Số tiền nạp phải lớn hơn 0");
                request.getRequestDispatcher("/wallet").forward(request, response);
                return;
            }

            int orderCode = PayOSConfig.genOrderCode();
            String description = "Nạp tiền vào ví - User ID: " + user.getUserId();
            String cancelUrl = PayOSConfig.CANCEL_URL;
            String returnUrl = PayOSConfig.RETURN_URL;

            // PayOS yêu cầu amount là số nguyên (VND)
            int amountInt = amount.intValue();

            // Tính signature theo PayOS: các trường sắp xếp theo thứ tự bảng chữ cái
            String signature = PayOSConfig.createPaymentSignature(amountInt, cancelUrl, description, orderCode, returnUrl);

            // Tạo JSON request body với signature
            String jsonBody = "{"
                    + "\"orderCode\":" + orderCode + ","
                    + "\"amount\":" + amountInt + ","
                    + "\"description\":\"" + description.replace("\"", "\\\"") + "\","
                    + "\"cancelUrl\":\"" + cancelUrl + "\","
                    + "\"returnUrl\":\"" + returnUrl + "\","
                    + "\"signature\":\"" + signature + "\""
                    + "}";

            System.out.println("PayOS Request JSON: " + jsonBody);
            System.out.println("PayOS Signature: " + signature);

            // Gọi API PayOS
            URL url = new URL(PayOSConfig.ENDPOINT);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setRequestProperty("x-client-id", PayOSConfig.CLIENT_ID);
            conn.setRequestProperty("x-api-key", PayOSConfig.API_KEY);
            conn.setDoOutput(true);
            conn.setConnectTimeout(30000); // 30 seconds
            conn.setReadTimeout(30000); // 30 seconds

            try (OutputStream os = conn.getOutputStream()) {
                os.write(jsonBody.getBytes(StandardCharsets.UTF_8));
            }

            int responseCode = conn.getResponseCode();
            System.out.println("PayOS HTTP Response Code: " + responseCode);
            
            BufferedReader in = null;
            try {
                in = new BufferedReader(new InputStreamReader(
                        responseCode >= 200 && responseCode < 300
                                ? conn.getInputStream()
                                : conn.getErrorStream(),
                        StandardCharsets.UTF_8));
                StringBuilder resp = new StringBuilder();
                String line;
                while ((line = in.readLine()) != null) {
                    resp.append(line);
                }
                
                String respBody = resp.toString();
                System.out.println("PayOS Response Body: " + respBody);
                
                if (responseCode < 200 || responseCode >= 300) {
                    // Lỗi từ PayOS
                    String errorMsg = "PayOS API trả về lỗi (HTTP " + responseCode + ")";
                    int errorIdx = respBody.indexOf("\"message\"");
                    if (errorIdx != -1) {
                        int start = respBody.indexOf('"', errorIdx + 9 + 1);
                        int end = respBody.indexOf('"', start + 1);
                        if (start != -1 && end != -1) {
                            errorMsg = respBody.substring(start + 1, end);
                        }
                    }
                    request.setAttribute("error", errorMsg);
                    request.getRequestDispatcher("/wallet").forward(request, response);
                    return;
                }
                
                // Parse checkoutUrl từ JSON response
                String checkoutUrl = null;
                int idx = respBody.indexOf("\"checkoutUrl\"");
                if (idx != -1) {
                    int start = respBody.indexOf('"', idx + 12 + 1);
                    int end = respBody.indexOf('"', start + 1);
                    if (start != -1 && end != -1) {
                        checkoutUrl = respBody.substring(start + 1, end);
                    }
                }

                if (checkoutUrl == null || checkoutUrl.isEmpty()) {
                    // Thử parse error message
                    String errorMsg = "Không lấy được checkoutUrl từ PayOS";
                    int errorIdx = respBody.indexOf("\"message\"");
                    if (errorIdx != -1) {
                        int start = respBody.indexOf('"', errorIdx + 9 + 1);
                        int end = respBody.indexOf('"', start + 1);
                        if (start != -1 && end != -1) {
                            errorMsg = respBody.substring(start + 1, end);
                        }
                    }
                    request.setAttribute("error", errorMsg);
                    request.getRequestDispatcher("/wallet").forward(request, response);
                    return;
                }

                // Parse thông tin từ PayOS response để lưu sau
                String paymentLinkId = null;
                int paymentLinkIdIdx = respBody.indexOf("\"id\"");
                if (paymentLinkIdIdx != -1) {
                    int start = respBody.indexOf(':', paymentLinkIdIdx) + 1;
                    int end = respBody.indexOf(',', start);
                    if (end == -1) end = respBody.indexOf('}', start);
                    if (start != -1 && end != -1) {
                        paymentLinkId = respBody.substring(start, end).trim();
                    }
                }

                // Lưu thông tin vào session
                session.setAttribute("payos_deposit_amount", amount);
                session.setAttribute("payos_order_code", orderCode);
                session.setAttribute("payos_payment_link_id", paymentLinkId);
                session.setAttribute("payos_request_log", respBody); // Lưu full response để log

                System.out.println("PayOS checkoutUrl: " + checkoutUrl);
                response.sendRedirect(checkoutUrl);
                
            } finally {
                if (in != null) {
                    try { in.close(); } catch (IOException e) {}
                }
            }

        } catch (java.net.UnknownHostException e) {
            e.printStackTrace();
            request.setAttribute("error", "Không thể kết nối đến PayOS. Vui lòng kiểm tra kết nối mạng.");
            request.getRequestDispatcher("/wallet").forward(request, response);
        } catch (java.net.SocketTimeoutException e) {
            e.printStackTrace();
            request.setAttribute("error", "Kết nối PayOS quá thời gian chờ. Vui lòng thử lại.");
            request.getRequestDispatcher("/wallet").forward(request, response);
        } catch (java.io.IOException e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi kết nối PayOS: " + e.getMessage());
            request.getRequestDispatcher("/wallet").forward(request, response);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Số tiền không hợp lệ");
            request.getRequestDispatcher("/wallet").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            String errorMsg = "Lỗi khi tạo payment request: " + e.getMessage();
            if (e.getCause() != null) {
                errorMsg += " (" + e.getCause().getMessage() + ")";
            }
            request.setAttribute("error", errorMsg);
            request.getRequestDispatcher("/wallet").forward(request, response);
        }
    }

    /** B2: PayOS redirect về, kiểm tra checksum và resultCode, cộng tiền nếu OK */
    private void handleReturn(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        HttpSession session = request.getSession();
        User user = (User) (session.getAttribute("info") != null
                ? session.getAttribute("info")
                : session.getAttribute("user"));

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/view/login.jsp");
            return;
        }

        String code = request.getParameter("code");
        String desc = request.getParameter("desc");
        String data = request.getParameter("data");
        String signature = request.getParameter("signature");

        System.out.println("=== PayOS Return Callback ===");
        System.out.println("code: " + code);
        System.out.println("desc: " + desc);
        System.out.println("data: " + data);
        System.out.println("signature: " + signature);

        // PayOS trả về code=00 nghĩa là thành công
        if (!"00".equals(code)) {
            String errorMsg = "Thanh toán PayOS thất bại";
            if (desc != null && !desc.isEmpty()) {
                errorMsg += " (" + desc + ")";
            }
            request.setAttribute("error", errorMsg);
            request.getRequestDispatcher("/view/WalletDeposit.jsp").forward(request, response);
            return;
        }

        // Kiểm tra checksum (nếu PayOS gửi về)
        if (signature != null && data != null) {
            String expectedSignature = PayOSConfig.signSHA256(data);
            if (!expectedSignature.equalsIgnoreCase(signature)) {
                request.setAttribute("error", "Chữ ký PayOS không hợp lệ");
                request.getRequestDispatcher("/view/WalletDeposit.jsp").forward(request, response);
                return;
            }
        }

        try {
            // Parse data để lấy amount và orderCode (nếu PayOS gửi về JSON trong data)
            BigDecimal amount = (BigDecimal) session.getAttribute("payos_deposit_amount");
            if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
                // Thử parse từ data nếu có
                if (data != null && data.contains("\"amount\"")) {
                    int idx = data.indexOf("\"amount\"");
                    int start = data.indexOf(':', idx) + 1;
                    int end = data.indexOf(',', start);
                    if (end == -1) end = data.indexOf('}', start);
                    if (start != -1 && end != -1) {
                        try {
                            int amountInt = Integer.parseInt(data.substring(start, end).trim());
                            amount = BigDecimal.valueOf(amountInt);
                        } catch (NumberFormatException e) {
                            // ignore
                        }
                    }
                }
            }

            if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
                request.setAttribute("error", "Không xác định được số tiền nạp");
                request.getRequestDispatcher("/view/WalletDeposit.jsp").forward(request, response);
                return;
            }

            BigDecimal currentBalance = user.getBalance() != null ? user.getBalance() : BigDecimal.ZERO;
            BigDecimal newBalance = currentBalance.add(amount);

            boolean balanceUpdated = transactionDAO.updateUserBalance(user.getUserId(), newBalance);
            if (!balanceUpdated) {
                request.setAttribute("error", "Không thể cập nhật số dư. Vui lòng liên hệ hỗ trợ.");
                request.getRequestDispatcher("/view/WalletDeposit.jsp").forward(request, response);
                return;
            }

            // Ghi transaction DEPOSIT và lấy transaction_id
            Integer orderCode = (Integer) session.getAttribute("payos_order_code");
            String description = "Nạp ví qua PayOS" + (orderCode != null ? " - OrderCode: " + orderCode : "");

            int transactionId = transactionDAO.createTransactionAndGetId(
                    user.getUserId(),
                    null,
                    amount,
                    "DEPOSIT",
                    description
            );

            if (transactionId <= 0) {
                // rollback
                try { transactionDAO.updateUserBalance(user.getUserId(), currentBalance); } catch (Exception ignored) {}
                request.setAttribute("error", "Không thể ghi nhận giao dịch nạp tiền.");
                request.getRequestDispatcher("/view/WalletDeposit.jsp").forward(request, response);
                return;
            }

            // Parse thông tin từ PayOS callback để lưu vào payment_gateway_transactions
            String paymentLinkId = (String) session.getAttribute("payos_payment_link_id");
            String gatewayTransactionId = null;
            String bankCode = null;
            
            // Parse từ data parameter (nếu PayOS gửi về JSON)
            if (data != null && !data.isEmpty()) {
                // Tìm gatewayTransactionId trong data
                int transIdIdx = data.indexOf("\"transactionId\"");
                if (transIdIdx == -1) transIdIdx = data.indexOf("\"id\"");
                if (transIdIdx != -1) {
                    int start = data.indexOf(':', transIdIdx) + 1;
                    int end = data.indexOf(',', start);
                    if (end == -1) end = data.indexOf('}', start);
                    if (start != -1 && end != -1) {
                        gatewayTransactionId = data.substring(start, end).trim().replace("\"", "");
                    }
                }
                
                // Tìm bankCode trong data
                int bankIdx = data.indexOf("\"bankCode\"");
                if (bankIdx != -1) {
                    int start = data.indexOf(':', bankIdx) + 1;
                    int end = data.indexOf(',', start);
                    if (end == -1) end = data.indexOf('}', start);
                    if (start != -1 && end != -1) {
                        bankCode = data.substring(start, end).trim().replace("\"", "");
                    }
                }
            }

            // Lưu vào payment_gateway_transactions
            String fullResponseLog = (String) session.getAttribute("payos_request_log");
            if (fullResponseLog == null) {
                fullResponseLog = "code=" + code + ", desc=" + desc + ", data=" + data + ", signature=" + signature;
            }

            boolean pgTransactionCreated = paymentGatewayTransactionDAO.createPaymentGatewayTransaction(
                    transactionId,
                    "PAYOS", // gateway_name (cần update enum trong DB để thêm 'PAYOS')
                    paymentLinkId != null ? paymentLinkId : String.valueOf(orderCode), // payment_ref_id
                    gatewayTransactionId, // gateway_transaction_id
                    amount, // amount
                    bankCode, // bank_code
                    code, // response_code
                    fullResponseLog, // full_response_log
                    user.getUserId() // created_by
            );

            if (!pgTransactionCreated) {
                System.out.println("Warning: Không thể lưu payment_gateway_transaction cho transaction_id=" + transactionId);
            }

            // Reload user
            User updatedUser = userDAO.getUserById(user.getUserId());
            if (updatedUser != null) {
                if (session.getAttribute("info") != null) session.setAttribute("info", updatedUser);
                if (session.getAttribute("user") != null) session.setAttribute("user", updatedUser);
                request.setAttribute("balance", updatedUser.getBalance());
            } else {
                user.setBalance(newBalance);
                if (session.getAttribute("info") != null) session.setAttribute("info", user);
                if (session.getAttribute("user") != null) session.setAttribute("user", user);
                request.setAttribute("balance", newBalance);
            }

            session.removeAttribute("payos_deposit_amount");
            session.removeAttribute("payos_order_code");

            request.setAttribute("success", "Thanh toán PayOS thành công. Đã nạp " + amount.toPlainString() + " đ vào ví.");
            request.getRequestDispatcher("/view/WalletDeposit.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi xử lý kết quả PayOS: " + e.getMessage());
            request.getRequestDispatcher("/view/WalletDeposit.jsp").forward(request, response);
        }
    }

    /** B3: Xử lý khi user hủy thanh toán PayOS, redirect về trang nạp tiền */
    private void handleCancel(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        
        HttpSession session = request.getSession();
        
        // Xóa các session attributes liên quan đến PayOS nếu có
        session.removeAttribute("payos_deposit_amount");
        session.removeAttribute("payos_order_code");
        session.removeAttribute("payos_payment_link_id");
        session.removeAttribute("payos_request_log");
        
        // Redirect về trang nạp tiền
        response.sendRedirect(request.getContextPath() + "/wallet");
    }
}

