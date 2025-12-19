package controller.user;

import DAO.user.CartDAO;
import DAO.user.ProductDAO;
import DAO.admin.VoucherDAO;
import Models.Cart;
import Models.CartItem;
import Models.ProductDisplay;
import Models.User;
import Models.Voucher;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.Date;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * CartController
 * Xử lý các thao tác giỏ hàng: thêm, xóa, cập nhật, áp dụng voucher
 */
@WebServlet(name = "CartController", urlPatterns = {"/cart", "/cart/*"})
public class CartController extends HttpServlet {
    
    private CartDAO cartDAO;
    private ProductDAO productDAO;
    private VoucherDAO voucherDAO;
    
    @Override
    public void init() throws ServletException {
        cartDAO = new CartDAO();
        productDAO = new ProductDAO();
        voucherDAO = new VoucherDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra đăng nhập
        User user = getCurrentUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/view/login.jsp");
            return;
        }
        
        try {
            // Hiển thị giỏ hàng
            showCart(request, response, user);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            try {
                showCart(request, response, user);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra đăng nhập
        User user = getCurrentUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/view/login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        try {
            if ("add".equals(action)) {
                addToCart(request, response, user);
            } else if ("update".equals(action)) {
                updateCartItem(request, response, user);
            } else if ("remove".equals(action)) {
                removeCartItem(request, response, user);
            } else if ("applyVoucher".equals(action)) {
                applyVoucher(request, response, user);
            } else if ("removeVoucher".equals(action)) {
                removeVoucher(request, response, user);
            } else {
                showCart(request, response, user);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/cart?error=operation_failed");
        }
    }
    
    /**
     * Lấy user hiện tại từ session
     */
    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            user = (User) session.getAttribute("info");
        }
        return user;
    }
    
    /**
     * Hiển thị giỏ hàng
     */
    private void showCart(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        try {
            // Lấy hoặc tạo cart
            Cart cart = cartDAO.getOrCreateCart(user.getUserId());
            
            // Lấy tất cả items trong cart
            List<CartItem> items = cartDAO.getCartItems(cart.getCartId());
            
            // Debug: Log số lượng items
            System.out.println("[CartController] Cart ID: " + cart.getCartId() + ", Items count: " + items.size());
            
            // Lấy thông tin sản phẩm hiện tại cho mỗi item (để so sánh giá)
            for (CartItem item : items) {
                try {
                    ProductDisplay product = productDAO.getProductByCode(item.getProductCode(), item.getProviderId());
                    item.setProduct(product);
                    System.out.println("[CartController] Item: " + item.getProductCode() + " - " + item.getProductName() + ", Qty: " + item.getQuantity());
                } catch (Exception e) {
                    // Nếu không lấy được, bỏ qua
                    System.out.println("[CartController] Error loading product for item: " + item.getProductCode() + " - " + e.getMessage());
                }
            }
            
            // Tính tổng giá trị giỏ hàng
            BigDecimal subtotal = calculateSubtotal(items);
            
            // Tính discount nếu có voucher
            BigDecimal discount = BigDecimal.ZERO;
            BigDecimal total = subtotal;
            
            if (cart.getVoucher() != null) {
                Voucher voucher = cart.getVoucher();
                discount = calculateDiscount(voucher, subtotal);
                total = subtotal.subtract(discount);
                if (total.compareTo(BigDecimal.ZERO) < 0) {
                    total = BigDecimal.ZERO;
                }
            }
            
            // Lấy danh sách voucher available
            List<Voucher> availableVouchers = voucherDAO.getAvailableVouchers();
            
            request.setAttribute("cart", cart);
            request.setAttribute("cartItems", items);
            request.setAttribute("subtotal", subtotal);
            request.setAttribute("discount", discount);
            request.setAttribute("total", total);
            request.setAttribute("availableVouchers", availableVouchers);
            
            request.getRequestDispatcher("/view/Cart.jsp").forward(request, response);
            
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi kết nối database: " + e.getMessage());
            request.getRequestDispatcher("/view/Cart.jsp").forward(request, response);
        }
    }
    
    /**
     * Thêm sản phẩm vào giỏ hàng
     */
    private void addToCart(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        try {
            String productCode = request.getParameter("productCode");
            String providerIdStr = request.getParameter("providerId");
            String quantityStr = request.getParameter("quantity");
            
            if (productCode == null || providerIdStr == null) {
                response.sendRedirect(request.getContextPath() + "/cart?error=invalid_params");
                return;
            }
            
            int providerId = Integer.parseInt(providerIdStr);
            int quantity = 1;
            if (quantityStr != null && !quantityStr.isEmpty()) {
                try {
                    quantity = Integer.parseInt(quantityStr);
                    if (quantity <= 0) quantity = 1;
                } catch (NumberFormatException e) {
                    quantity = 1;
                }
            }
            
            // Lấy thông tin sản phẩm
            ProductDisplay product = productDAO.getProductByCode(productCode, providerId);
            if (product == null) {
                response.sendRedirect(request.getContextPath() + "/cart?error=product_not_found");
                return;
            }
            
            // Kiểm tra stock
            int availableStock = productDAO.getAvailableStock(productCode, providerId);
            if (availableStock < quantity) {
                String redirectUrl = request.getParameter("redirect");
                if (redirectUrl != null && !redirectUrl.isEmpty()) {
                    String separator = redirectUrl.contains("?") ? "&" : "?";
                    response.sendRedirect(redirectUrl + separator + "error=insufficient_stock");
                } else {
                    response.sendRedirect(request.getContextPath() + "/cart?error=insufficient_stock");
                }
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
            cartDAO.addOrUpdateCartItem(item);
            
            // Redirect về trang trước hoặc cart
            String redirectUrl = request.getParameter("redirect");
            if (redirectUrl != null && !redirectUrl.isEmpty()) {
                // Kiểm tra xem redirectUrl đã có query string chưa
                String separator = redirectUrl.contains("?") ? "&" : "?";
                response.sendRedirect(redirectUrl + separator + "success=added_to_cart");
            } else {
                response.sendRedirect(request.getContextPath() + "/cart?success=added_to_cart");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/cart?error=add_failed");
        }
    }
    
    /**
     * Cập nhật quantity của cart item
     */
    private void updateCartItem(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        try {
            String cartItemIdStr = request.getParameter("cartItemId");
            String quantityStr = request.getParameter("quantity");
            
            if (cartItemIdStr == null || quantityStr == null) {
                response.sendRedirect(request.getContextPath() + "/cart?error=invalid_params");
                return;
            }
            
            int cartItemId;
            int quantity;
            
            try {
                cartItemId = Integer.parseInt(cartItemIdStr);
                quantity = Integer.parseInt(quantityStr);
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/cart?error=invalid_params");
                return;
            }
            
            // Lấy cart item để kiểm tra
            Cart cart = cartDAO.getOrCreateCart(user.getUserId());
            List<CartItem> items = cartDAO.getCartItems(cart.getCartId());
            CartItem targetItem = null;
            for (CartItem item : items) {
                if (item.getCartItemId() == cartItemId) {
                    targetItem = item;
                    break;
                }
            }
            
            if (targetItem == null) {
                response.sendRedirect(request.getContextPath() + "/cart?error=item_not_found");
                return;
            }
            
            // Kiểm tra stock
            int availableStock = productDAO.getAvailableStock(targetItem.getProductCode(), targetItem.getProviderId());
            if (quantity > availableStock) {
                response.sendRedirect(request.getContextPath() + "/cart?error=insufficient_stock");
                return;
            }
            
            if (quantity <= 0) {
                // Nếu quantity <= 0, xóa item
                cartDAO.removeCartItem(cartItemId);
            } else {
                // Cập nhật quantity
                cartDAO.updateCartItemQuantity(cartItemId, quantity);
            }
            
            response.sendRedirect(request.getContextPath() + "/cart?success=updated");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/cart?error=update_failed");
        }
    }
    
    /**
     * Xóa item khỏi giỏ hàng
     */
    private void removeCartItem(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        try {
            String cartItemIdStr = request.getParameter("cartItemId");
            
            if (cartItemIdStr == null) {
                response.sendRedirect(request.getContextPath() + "/cart?error=invalid_params");
                return;
            }
            
            int cartItemId = Integer.parseInt(cartItemIdStr);
            cartDAO.removeCartItem(cartItemId);
            
            response.sendRedirect(request.getContextPath() + "/cart?success=removed");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/cart?error=remove_failed");
        }
    }
    
    /**
     * Áp dụng voucher cho giỏ hàng
     */
    private void applyVoucher(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        try {
            String voucherIdStr = request.getParameter("voucherId");
            
            if (voucherIdStr == null || voucherIdStr.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/cart?error=invalid_voucher");
                return;
            }
            
            int voucherId;
            try {
                voucherId = Integer.parseInt(voucherIdStr);
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/cart?error=invalid_voucher");
                return;
            }
            
            // Lấy voucher
            Voucher voucher = voucherDAO.getVoucherById(voucherId);
            if (voucher == null) {
                response.sendRedirect(request.getContextPath() + "/cart?error=voucher_not_found");
                return;
            }
            
            // Validate voucher
            String validationError = validateVoucher(voucher);
            if (validationError != null) {
                response.sendRedirect(request.getContextPath() + "/cart?error=" + validationError);
                return;
            }
            
            // Lấy cart
            Cart cart = cartDAO.getOrCreateCart(user.getUserId());
            
            // Lấy items để tính subtotal
            List<CartItem> items = cartDAO.getCartItems(cart.getCartId());
            BigDecimal subtotal = calculateSubtotal(items);
            
            // Kiểm tra min_order_value
            if (subtotal.compareTo(voucher.getMinOrderValue()) < 0) {
                response.sendRedirect(request.getContextPath() + "/cart?error=min_order_not_met&minOrder=" + voucher.getMinOrderValue());
                return;
            }
            
            // Áp dụng voucher
            cartDAO.updateCartVoucher(cart.getCartId(), voucher.getVoucherId());
            
            response.sendRedirect(request.getContextPath() + "/cart?success=voucher_applied");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/cart?error=apply_voucher_failed");
        }
    }
    
    /**
     * Xóa voucher khỏi giỏ hàng
     */
    private void removeVoucher(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        try {
            Cart cart = cartDAO.getOrCreateCart(user.getUserId());
            cartDAO.removeCartVoucher(cart.getCartId());
            
            response.sendRedirect(request.getContextPath() + "/cart?success=voucher_removed");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/cart?error=remove_voucher_failed");
        }
    }
    
    /**
     * Validate voucher
     */
    private String validateVoucher(Voucher voucher) {
        // Kiểm tra status
        if (!"ACTIVE".equals(voucher.getStatus())) {
            return "voucher_inactive";
        }
        
        // Kiểm tra expiry date
        if (voucher.getExpiryDate() != null) {
            Date now = new Date();
            if (voucher.getExpiryDate().before(now)) {
                return "voucher_expired";
            }
        }
        
        // Kiểm tra usage limit
        if (voucher.getUsageLimit() != null) {
            if (voucher.getUsedCount() >= voucher.getUsageLimit()) {
                return "voucher_limit_reached";
            }
        }
        
        return null; // Valid
    }
    
    /**
     * Tính tổng giá trị giỏ hàng (subtotal)
     */
    private BigDecimal calculateSubtotal(List<CartItem> items) {
        BigDecimal subtotal = BigDecimal.ZERO;
        for (CartItem item : items) {
            subtotal = subtotal.add(item.getSubtotal());
        }
        return subtotal;
    }
    
    /**
     * Tính discount từ voucher
     */
    private BigDecimal calculateDiscount(Voucher voucher, BigDecimal subtotal) {
        if (voucher == null || subtotal == null) {
            return BigDecimal.ZERO;
        }
        
        BigDecimal discount = BigDecimal.ZERO;
        
        if ("PERCENT".equals(voucher.getDiscountType())) {
            // Discount theo phần trăm
            discount = subtotal.multiply(voucher.getDiscountValue())
                              .divide(new BigDecimal(100), 2, java.math.RoundingMode.HALF_UP);
        } else if ("FIXED".equals(voucher.getDiscountType())) {
            // Discount cố định
            discount = voucher.getDiscountValue();
            // Không được vượt quá subtotal
            if (discount.compareTo(subtotal) > 0) {
                discount = subtotal;
            }
        }
        
        return discount;
    }
}

