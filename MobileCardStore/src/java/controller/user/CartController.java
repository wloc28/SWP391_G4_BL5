package controller.user;

import DAO.user.CartDAO;
import DAO.user.ProductDAO;
import DAO.admin.VoucherDAO;
import DAO.admin.OrderDAO;
import DAO.admin.TransactionDAO;
import DAO.admin.ProductStorageDAO;
import Models.Cart;
import Models.CartItem;
import Models.ProductDisplay;
import Models.User;
import Models.Voucher;
import Models.ProductStorage;
import java.util.ArrayList;
// Using simple JSON string building instead of Gson library
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * CartController - Xử lý tất cả các thao tác liên quan đến giỏ hàng
 * URL patterns: /cart/* (add, remove, update, view, checkout, apply-voucher)
 */
@WebServlet(name = "CartController", urlPatterns = { 
    "/cart/add", 
    "/cart/remove", 
    "/cart/update", 
    "/cart/view", 
    "/cart/checkout",
    "/cart/apply-voucher",
    "/cart/remove-voucher",
    "/cart/process-checkout"
})
public class CartController extends HttpServlet {

    private CartDAO cartDAO;
    private ProductDAO productDAO;
    private VoucherDAO voucherDAO;
    private OrderDAO orderDAO;
    private TransactionDAO transactionDAO;
    private ProductStorageDAO productStorageDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            cartDAO = new CartDAO();
            productDAO = new ProductDAO();
            voucherDAO = new VoucherDAO();
            orderDAO = new OrderDAO();
            transactionDAO = new TransactionDAO();
            productStorageDAO = new ProductStorageDAO();
        } catch (Exception e) {
            throw new ServletException("Failed to initialize DAOs", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath() + request.getPathInfo();
        
        if (path == null) {
            path = request.getServletPath();
        }

        if (path.contains("/cart/view")) {
            handleViewCart(request, response);
        } else if (path.contains("/cart/checkout")) {
            handleCheckout(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath() + (request.getPathInfo() != null ? request.getPathInfo() : "");
        
        if (path.contains("/cart/add")) {
            handleAddToCart(request, response);
        } else if (path.contains("/cart/remove")) {
            handleRemoveFromCart(request, response);
        } else if (path.contains("/cart/update")) {
            handleUpdateCart(request, response);
        } else if (path.contains("/cart/apply-voucher")) {
            handleApplyVoucher(request, response);
        } else if (path.contains("/cart/remove-voucher")) {
            handleRemoveVoucher(request, response);
        } else if (path.contains("/cart/process-checkout")) {
            handleProcessCheckout(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    /**
     * Kiểm tra user đã đăng nhập chưa
     */
    private User getLoggedInUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        return (User) session.getAttribute("user");
    }

    /**
     * Xử lý thêm sản phẩm vào giỏ hàng
     */
    private void handleAddToCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoggedInUser(request);
        if (user == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Vui lòng đăng nhập để thêm sản phẩm vào giỏ hàng");
            return;
        }

        try {
            String productCode = request.getParameter("productCode");
            String providerIdStr = request.getParameter("providerId");
            String quantityStr = request.getParameter("quantity");

            if (productCode == null || providerIdStr == null || quantityStr == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu thông tin sản phẩm");
                return;
            }

            int providerId = Integer.parseInt(providerIdStr);
            int quantity = Integer.parseInt(quantityStr);

            if (quantity <= 0) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Số lượng phải lớn hơn 0");
                return;
            }

            // Lấy thông tin sản phẩm
            ProductDisplay product = productDAO.getProductByCode(productCode, providerId);
            if (product == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy sản phẩm");
                return;
            }

            // Kiểm tra số lượng tồn kho
            int availableStock = productDAO.getAvailableStock(productCode, providerId);
            if (quantity > availableStock) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, 
                    "Số lượng yêu cầu vượt quá tồn kho. Tồn kho hiện tại: " + availableStock);
                return;
            }

            // Lấy hoặc tạo cart
            Cart cart = cartDAO.getOrCreateCart(user.getUserId());

            // Tạo cart item
            CartItem item = new CartItem();
            item.setCartId(cart.getCartId());
            item.setProductCode(productCode);
            item.setProviderId(providerId);
            item.setProductName(product.getProductName());
            item.setProviderName(product.getProviderName());
            item.setUnitPrice(product.getPrice());
            item.setQuantity(quantity);

            // Thêm vào cart
            boolean success = cartDAO.addOrUpdateCartItem(item);

            if (success) {
                // Trả về JSON response
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\": true, \"message\": \"Đã thêm sản phẩm vào giỏ hàng\"}");
            } else {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Không thể thêm sản phẩm vào giỏ hàng");
            }

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thông tin không hợp lệ");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi hệ thống: " + e.getMessage());
        }
    }

    /**
     * Xử lý xóa sản phẩm khỏi giỏ hàng
     */
    private void handleRemoveFromCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoggedInUser(request);
        if (user == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        try {
            String cartItemIdStr = request.getParameter("cartItemId");
            if (cartItemIdStr == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            int cartItemId = Integer.parseInt(cartItemIdStr);
            boolean success = cartDAO.removeCartItem(cartItemId);

            if (success) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\": true, \"message\": \"Đã xóa sản phẩm khỏi giỏ hàng\"}");
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy sản phẩm trong giỏ hàng");
            }

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Xử lý cập nhật số lượng sản phẩm trong giỏ hàng
     */
    private void handleUpdateCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoggedInUser(request);
        if (user == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        try {
            String cartItemIdStr = request.getParameter("cartItemId");
            String quantityStr = request.getParameter("quantity");

            if (cartItemIdStr == null || quantityStr == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            int cartItemId = Integer.parseInt(cartItemIdStr);
            int quantity = Integer.parseInt(quantityStr);

            if (quantity <= 0) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Số lượng phải lớn hơn 0");
                return;
            }

            // Lấy cart item để kiểm tra thông tin sản phẩm
            Cart cart = cartDAO.getOrCreateCart(user.getUserId());
            List<CartItem> items = cartDAO.getCartItems(cart.getCartId());
            CartItem item = null;
            for (CartItem i : items) {
                if (i.getCartItemId() == cartItemId) {
                    item = i;
                    break;
                }
            }

            if (item == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy sản phẩm trong giỏ hàng");
                return;
            }

            // Kiểm tra tồn kho
            int availableStock = productDAO.getAvailableStock(item.getProductCode(), item.getProviderId());
            if (quantity > availableStock) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, 
                    "Số lượng yêu cầu vượt quá tồn kho. Tồn kho hiện tại: " + availableStock);
                return;
            }

            boolean success = cartDAO.updateCartItemQuantity(cartItemId, quantity);

            if (success) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\": true, \"message\": \"Đã cập nhật số lượng\"}");
            } else {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Xử lý xem giỏ hàng
     */
    private void handleViewCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoggedInUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            Cart cart = cartDAO.getOrCreateCart(user.getUserId());
            List<CartItem> items = cartDAO.getCartItems(cart.getCartId());

            // Load thông tin sản phẩm hiện tại để so sánh giá
            for (CartItem item : items) {
                ProductDisplay product = productDAO.getProductByCode(item.getProductCode(), item.getProviderId());
                item.setProduct(product);
            }

            // Tính tổng tiền
            BigDecimal subtotal = calculateSubtotal(items);
            BigDecimal discount = calculateDiscount(cart, subtotal);
            BigDecimal total = subtotal.subtract(discount);

            request.setAttribute("cart", cart);
            request.setAttribute("items", items);
            request.setAttribute("subtotal", subtotal);
            request.setAttribute("discount", discount);
            request.setAttribute("total", total);

            request.getRequestDispatcher("/view/Cart.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi khi tải giỏ hàng: " + e.getMessage());
            request.getRequestDispatcher("/view/Cart.jsp").forward(request, response);
        }
    }

    /**
     * Xử lý trang checkout
     */
    private void handleCheckout(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoggedInUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            Cart cart = cartDAO.getOrCreateCart(user.getUserId());
            List<CartItem> items = cartDAO.getCartItems(cart.getCartId());

            if (items.isEmpty()) {
                request.setAttribute("error", "Giỏ hàng của bạn đang trống");
                request.getRequestDispatcher("/view/CartCheckout.jsp").forward(request, response);
                return;
            }

            // Load thông tin sản phẩm
            for (CartItem item : items) {
                ProductDisplay product = productDAO.getProductByCode(item.getProductCode(), item.getProviderId());
                item.setProduct(product);
                
                // Kiểm tra tồn kho
                int availableStock = productDAO.getAvailableStock(item.getProductCode(), item.getProviderId());
                if (item.getQuantity() > availableStock) {
                    request.setAttribute("error", 
                        "Sản phẩm " + item.getProductName() + " chỉ còn " + availableStock + " sản phẩm trong kho");
                    request.getRequestDispatcher("/view/CartCheckout.jsp").forward(request, response);
                    return;
                }
            }

            // Tính tổng tiền
            BigDecimal subtotal = calculateSubtotal(items);
            BigDecimal discount = calculateDiscount(cart, subtotal);
            BigDecimal total = subtotal.subtract(discount);

            request.setAttribute("cart", cart);
            request.setAttribute("items", items);
            request.setAttribute("subtotal", subtotal);
            request.setAttribute("discount", discount);
            request.setAttribute("total", total);
            request.setAttribute("user", user);

            request.getRequestDispatcher("/view/CartCheckout.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi khi tải trang thanh toán: " + e.getMessage());
            request.getRequestDispatcher("/view/CartCheckout.jsp").forward(request, response);
        }
    }

    /**
     * Xử lý áp dụng voucher
     */
    private void handleApplyVoucher(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoggedInUser(request);
        if (user == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        try {
            String voucherCode = request.getParameter("voucherCode");
            if (voucherCode == null || voucherCode.trim().isEmpty()) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\": false, \"message\": \"Vui lòng nhập mã voucher\"}");
                return;
            }

            // Lấy voucher
            Voucher voucher = voucherDAO.getVoucherByCode(voucherCode.trim().toUpperCase());
            if (voucher == null) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\": false, \"message\": \"Mã voucher không tồn tại\"}");
                return;
            }

            // Kiểm tra voucher có hợp lệ không
            if (!"ACTIVE".equals(voucher.getStatus())) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\": false, \"message\": \"Voucher không khả dụng\"}");
                return;
            }

            if (voucher.getExpiryDate() != null && voucher.getExpiryDate().before(new java.util.Date())) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\": false, \"message\": \"Voucher đã hết hạn\"}");
                return;
            }

            if (voucher.getUsageLimit() != null && voucher.getUsedCount() >= voucher.getUsageLimit()) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\": false, \"message\": \"Voucher đã hết lượt sử dụng\"}");
                return;
            }

            // Lấy cart và tính tổng tiền
            Cart cart = cartDAO.getOrCreateCart(user.getUserId());
            List<CartItem> items = cartDAO.getCartItems(cart.getCartId());
            BigDecimal subtotal = calculateSubtotal(items);

            // Kiểm tra giá trị đơn hàng tối thiểu
            if (subtotal.compareTo(voucher.getMinOrderValue()) < 0) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\": false, \"message\": \"Đơn hàng phải có giá trị tối thiểu " + 
                    voucher.getMinOrderValue() + " VNĐ để sử dụng voucher này\"}");
                return;
            }

            // Áp dụng voucher
            boolean success = cartDAO.updateCartVoucher(cart.getCartId(), voucher.getVoucherId());

            if (success) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\": true, \"message\": \"Đã áp dụng voucher thành công\"}");
            } else {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\": false, \"message\": \"Không thể áp dụng voucher\"}");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\": false, \"message\": \"Lỗi hệ thống: " + e.getMessage() + "\"}");
        }
    }

    /**
     * Xử lý xóa voucher khỏi giỏ hàng
     */
    private void handleRemoveVoucher(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoggedInUser(request);
        if (user == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        try {
            Cart cart = cartDAO.getOrCreateCart(user.getUserId());
            boolean success = cartDAO.removeCartVoucher(cart.getCartId());

            if (success) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\": true, \"message\": \"Đã xóa voucher\"}");
            } else {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\": false, \"message\": \"Không thể xóa voucher\"}");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\": false, \"message\": \"Lỗi hệ thống\"}");
        }
    }

    /**
     * Xử lý thanh toán
     */
    private void handleProcessCheckout(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoggedInUser(request);
        if (user == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        try {
            Cart cart = cartDAO.getOrCreateCart(user.getUserId());
            List<CartItem> items = cartDAO.getCartItems(cart.getCartId());

            if (items.isEmpty()) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\": false, \"message\": \"Giỏ hàng đang trống\"}");
                return;
            }

            // Kiểm tra tồn kho và tính tổng tiền
            BigDecimal subtotal = BigDecimal.ZERO;
            for (CartItem item : items) {
                int availableStock = productDAO.getAvailableStock(item.getProductCode(), item.getProviderId());
                if (item.getQuantity() > availableStock) {
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    response.getWriter().write("{\"success\": false, \"message\": \"Sản phẩm " + 
                        item.getProductName() + " chỉ còn " + availableStock + " sản phẩm trong kho\"}");
                    return;
                }
                subtotal = subtotal.add(item.getSubtotal());
            }

            BigDecimal discount = calculateDiscount(cart, subtotal);
            BigDecimal total = subtotal.subtract(discount);

            // Kiểm tra số dư ví
            BigDecimal currentBalance = user.getBalance();
            if (currentBalance == null) {
                currentBalance = BigDecimal.ZERO;
            }
            
            if (currentBalance.compareTo(total) < 0) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\": false, \"message\": \"Số dư ví không đủ. Số dư hiện tại: " + 
                    currentBalance + " VNĐ, cần: " + total + " VNĐ\"}");
                return;
            }

            // Xác nhận thanh toán
            // Trừ tiền từ ví
            BigDecimal newBalance = currentBalance.subtract(total);
            boolean balanceUpdated = transactionDAO.updateUserBalance(user.getUserId(), newBalance);
            
            if (!balanceUpdated) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\": false, \"message\": \"Không thể cập nhật số dư ví\"}");
                return;
            }

            // Tạo transaction record
            transactionDAO.createTransaction(
                user.getUserId(),
                null, // orderId sẽ được cập nhật sau
                total.negate(), // Số tiền âm (trừ)
                "PAYMENT",
                "Thanh toán đơn hàng từ giỏ hàng"
            );

            // Tạo đơn hàng cho từng sản phẩm
            int successCount = 0;
            List<Integer> createdOrderIds = new ArrayList<>();
            
            for (CartItem item : items) {
                // Tính discount cho từng item (chia đều)
                BigDecimal itemDiscount = BigDecimal.ZERO;
                if (cart.getVoucher() != null && discount.compareTo(BigDecimal.ZERO) > 0) {
                    BigDecimal itemRatio = item.getSubtotal().divide(subtotal, 4, BigDecimal.ROUND_HALF_UP);
                    itemDiscount = discount.multiply(itemRatio);
                }
                BigDecimal itemTotal = item.getSubtotal().subtract(itemDiscount);

                // Sử dụng productCode thay vì productId
                // Tạo đơn hàng
                int orderId = orderDAO.createOrder(
                    user.getUserId(),
                    item.getProductCode(), // productCode (String)
                    item.getProviderName(),
                    item.getProductName(),
                    item.getUnitPrice(),
                    item.getQuantity(),
                    cart.getVoucherId(),
                    cart.getVoucher() != null ? cart.getVoucher().getCode() : null,
                    itemDiscount,
                    itemTotal,
                    user.getUserId()
                );

                if (orderId > 0) {
                    createdOrderIds.add(orderId);
                    
                    // Lấy và đánh dấu sản phẩm là SOLD
                    List<ProductStorage> soldItems = productStorageDAO.getAndMarkAsSold(
                        item.getProductCode(), 
                        item.getProviderId(), 
                        item.getQuantity(),
                        orderId
                    );
                    
                    // Tạo JSON chứa serial_number và card_code
                    StringBuilder productLogJson = new StringBuilder("[");
                    for (int i = 0; i < soldItems.size(); i++) {
                        ProductStorage soldItem = soldItems.get(i);
                        if (i > 0) productLogJson.append(",");
                        productLogJson.append("{");
                        productLogJson.append("\"serial_number\":\"").append(
                            soldItem.getSerialNumber() != null ? soldItem.getSerialNumber().replace("\"", "\\\"") : ""
                        ).append("\",");
                        productLogJson.append("\"card_code\":\"").append(
                            soldItem.getCardCode() != null ? soldItem.getCardCode().replace("\"", "\\\"") : ""
                        ).append("\"");
                        productLogJson.append("}");
                    }
                    productLogJson.append("]");
                    
                    // Cập nhật product_log cho đơn hàng
                    orderDAO.updateOrderProductLog(orderId, productLogJson.toString());
                    
                    // Cập nhật trạng thái đơn hàng thành COMPLETED
                    orderDAO.completeOrder(orderId);
                    
                    successCount++;
                }
            }

            if (successCount == items.size()) {
                // Cập nhật used_count cho voucher nếu có
                if (cart.getVoucher() != null) {
                    Voucher voucher = cart.getVoucher();
                    voucher.setUsedCount(voucher.getUsedCount() + 1);
                    voucherDAO.updateVoucher(voucher);
                }
                
                // Xóa giỏ hàng sau khi thanh toán thành công
                cartDAO.clearCart(cart.getCartId());
                cartDAO.removeCartVoucher(cart.getCartId());
                
                // Cập nhật balance trong session
                user.setBalance(newBalance);
                request.getSession().setAttribute("user", user);
                request.getSession().setAttribute("info", user);

                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                String orderHistoryUrl = request.getContextPath() + "/order-history";
                response.getWriter().write("{\"success\": true, \"message\": \"Thanh toán thành công! Số tiền đã được trừ từ ví của bạn.\", \"redirect\": \"" + 
                    orderHistoryUrl + "\", \"orderHistoryUrl\": \"" + orderHistoryUrl + "\"}");
            } else {
                // Rollback: hoàn tiền lại
                transactionDAO.updateUserBalance(user.getUserId(), currentBalance);
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\": false, \"message\": \"Có lỗi xảy ra khi đặt hàng\"}");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\": false, \"message\": \"Lỗi hệ thống: " + e.getMessage() + "\"}");
        }
    }

    /**
     * Tính tổng tiền của các items
     */
    private BigDecimal calculateSubtotal(List<CartItem> items) {
        BigDecimal subtotal = BigDecimal.ZERO;
        for (CartItem item : items) {
            subtotal = subtotal.add(item.getSubtotal());
        }
        return subtotal;
    }

    /**
     * Tính số tiền giảm giá từ voucher
     */
    private BigDecimal calculateDiscount(Cart cart, BigDecimal subtotal) {
        if (cart.getVoucher() == null || subtotal.compareTo(BigDecimal.ZERO) <= 0) {
            return BigDecimal.ZERO;
        }

        Voucher voucher = cart.getVoucher();
        
        // Kiểm tra giá trị đơn hàng tối thiểu
        if (subtotal.compareTo(voucher.getMinOrderValue()) < 0) {
            return BigDecimal.ZERO;
        }

        BigDecimal discount = BigDecimal.ZERO;
        if ("PERCENT".equals(voucher.getDiscountType())) {
            // Giảm theo phần trăm
            discount = subtotal.multiply(voucher.getDiscountValue())
                              .divide(new BigDecimal("100"), 2, BigDecimal.ROUND_HALF_UP);
        } else if ("FIXED".equals(voucher.getDiscountType())) {
            // Giảm cố định
            discount = voucher.getDiscountValue();
            // Không được vượt quá tổng tiền
            if (discount.compareTo(subtotal) > 0) {
                discount = subtotal;
            }
        }

        return discount;
    }
}

