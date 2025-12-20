package DAO.user;

import DAO.DBConnection;
import Models.Cart;
import Models.CartItem;
import Models.Voucher;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Cart DAO
 * Xử lý các thao tác database cho Cart và CartItem
 */
public class CartDAO {
    
    /**
     * Lấy hoặc tạo cart cho user
     */
    public Cart getOrCreateCart(int userId) throws SQLException {
        // Thử lấy cart hiện có
        Cart cart = getCartByUserId(userId);
        
        if (cart == null) {
            // Tạo cart mới
            cart = createCart(userId);
        }
        
        return cart;
    }
    
    /**
     * Lấy cart theo user_id
     */
    public Cart getCartByUserId(int userId) throws SQLException {
        String sql = """
            SELECT c.*, v.voucher_id as v_voucher_id, v.code as v_code, 
                   v.discount_type, v.discount_value, v.min_order_value, 
                   v.usage_limit, v.used_count, v.expiry_date, v.status as v_status
            FROM cart c
            LEFT JOIN vouchers v ON c.voucher_id = v.voucher_id AND v.is_deleted = 0
            WHERE c.user_id = ?
            """;
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Cart cart = mapResultSetToCart(rs);
                    
                    // Map voucher nếu có
                    if (rs.getObject("v_voucher_id") != null) {
                        Voucher voucher = new Voucher();
                        voucher.setVoucherId(rs.getInt("v_voucher_id"));
                        voucher.setCode(rs.getString("v_code"));
                        voucher.setDiscountType(rs.getString("discount_type"));
                        voucher.setDiscountValue(rs.getBigDecimal("discount_value"));
                        voucher.setMinOrderValue(rs.getBigDecimal("min_order_value"));
                        voucher.setUsageLimit(rs.getObject("usage_limit") != null ? rs.getInt("usage_limit") : null);
                        voucher.setUsedCount(rs.getInt("used_count"));
                        if (rs.getTimestamp("expiry_date") != null) {
                            voucher.setExpiryDate(new java.util.Date(rs.getTimestamp("expiry_date").getTime()));
                        }
                        voucher.setStatus(rs.getString("v_status"));
                        cart.setVoucher(voucher);
                    }
                    
                    return cart;
                }
            }
        }
        
        return null;
    }
    
    /**
     * Tạo cart mới cho user
     */
    public Cart createCart(int userId) throws SQLException {
        String sql = "INSERT INTO cart (user_id, created_at, updated_at) VALUES (?, NOW(), NOW())";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, userId);
            ps.executeUpdate();
            
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    Cart cart = new Cart();
                    cart.setCartId(rs.getInt(1));
                    cart.setUserId(userId);
                    return cart;
                }
            }
        }
        
        return null;
    }
    
    /**
     * Cập nhật voucher cho cart
     */
    public boolean updateCartVoucher(int cartId, Integer voucherId) throws SQLException {
        String sql = "UPDATE cart SET voucher_id = ?, updated_at = NOW() WHERE cart_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            if (voucherId != null) {
                ps.setInt(1, voucherId);
            } else {
                ps.setNull(1, java.sql.Types.INTEGER);
            }
            ps.setInt(2, cartId);
            
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * Xóa voucher khỏi cart
     */
    public boolean removeCartVoucher(int cartId) throws SQLException {
        return updateCartVoucher(cartId, null);
    }
    
    /**
     * Lấy tất cả items trong cart
     */
    public List<CartItem> getCartItems(int cartId) throws SQLException {
        List<CartItem> items = new ArrayList<>();
        String sql = """
            SELECT * FROM cart_items 
            WHERE cart_id = ? 
            ORDER BY created_at ASC
            """;
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, cartId);
            
            try (ResultSet rs = ps.executeQuery()) {
                int count = 0;
                while (rs.next()) {
                    CartItem item = mapResultSetToCartItem(rs);
                    items.add(item);
                    count++;
                    System.out.println("[CartDAO] Loaded cart item: ID=" + item.getCartItemId() + 
                                     ", Product=" + item.getProductCode() + 
                                     ", Provider=" + item.getProviderId() + 
                                     ", Qty=" + item.getQuantity() + 
                                     ", Name=" + item.getProductName());
                }
                System.out.println("[CartDAO] Total items loaded: " + count);
            }
        }
        
        return items;
    }
    
    /**
     * Thêm item vào cart hoặc cập nhật quantity nếu đã tồn tại
     */
    public boolean addOrUpdateCartItem(CartItem item) throws SQLException {
        // Kiểm tra xem item đã tồn tại chưa
        CartItem existing = getCartItem(item.getCartId(), item.getProductCode(), item.getProviderId());
        
        if (existing != null) {
            // Cập nhật quantity
            int newQuantity = existing.getQuantity() + item.getQuantity();
            return updateCartItemQuantity(existing.getCartItemId(), newQuantity);
        } else {
            // Thêm mới
            return addCartItem(item);
        }
    }
    
    /**
     * Thêm item mới vào cart
     */
    public boolean addCartItem(CartItem item) throws SQLException {
        String sql = """
            INSERT INTO cart_items 
            (cart_id, product_code, provider_id, product_name, provider_name, unit_price, quantity, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW())
            """;
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, item.getCartId());
            ps.setString(2, item.getProductCode());
            ps.setInt(3, item.getProviderId());
            ps.setString(4, item.getProductName());
            ps.setString(5, item.getProviderName());
            ps.setBigDecimal(6, item.getUnitPrice());
            ps.setInt(7, item.getQuantity());
            
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * Cập nhật quantity của cart item
     */
    public boolean updateCartItemQuantity(int cartItemId, int quantity) throws SQLException {
        String sql = "UPDATE cart_items SET quantity = ?, updated_at = NOW() WHERE cart_item_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, quantity);
            ps.setInt(2, cartItemId);
            
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * Xóa item khỏi cart
     */
    public boolean removeCartItem(int cartItemId) throws SQLException {
        String sql = "DELETE FROM cart_items WHERE cart_item_id = ?";
        
        System.out.println("[CartDAO] removeCartItem called with cartItemId: " + cartItemId);
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, cartItemId);
            
            int rowsAffected = ps.executeUpdate();
            System.out.println("[CartDAO] removeCartItem - rows affected: " + rowsAffected);
            
            boolean result = rowsAffected > 0;
            System.out.println("[CartDAO] removeCartItem - result: " + result);
            
            return result;
        } catch (SQLException e) {
            System.err.println("[CartDAO] removeCartItem - SQLException: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }
    
    /**
     * Xóa tất cả items trong cart
     */
    public boolean clearCart(int cartId) throws SQLException {
        String sql = "DELETE FROM cart_items WHERE cart_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, cartId);
            
            return ps.executeUpdate() >= 0; // >= 0 vì có thể cart đã rỗng
        }
    }
    
    /**
     * Lấy cart item theo cart_id, product_code, provider_id
     */
    public CartItem getCartItem(int cartId, String productCode, int providerId) throws SQLException {
        String sql = """
            SELECT * FROM cart_items 
            WHERE cart_id = ? AND product_code = ? AND provider_id = ?
            """;
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, cartId);
            ps.setString(2, productCode);
            ps.setInt(3, providerId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToCartItem(rs);
                }
            }
        }
        
        return null;
    }
    
    /**
     * Map ResultSet to Cart object
     */
    private Cart mapResultSetToCart(ResultSet rs) throws SQLException {
        Cart cart = new Cart();
        cart.setCartId(rs.getInt("cart_id"));
        cart.setUserId(rs.getInt("user_id"));
        
        Integer voucherId = rs.getInt("voucher_id");
        if (!rs.wasNull()) {
            cart.setVoucherId(voucherId);
        }
        
        cart.setCreatedAt(rs.getTimestamp("created_at"));
        cart.setUpdatedAt(rs.getTimestamp("updated_at"));
        
        return cart;
    }
    
    /**
     * Đếm số lượng items trong cart
     */
    public int getCartItemCount(int cartId) throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM cart_items WHERE cart_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, cartId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count");
                }
            }
        }
        
        return 0;
    }
    
    /**
     * Đếm số lượng items trong cart của user
     */
    public int getCartItemCountByUserId(int userId) throws SQLException {
        Cart cart = getCartByUserId(userId);
        if (cart == null) {
            return 0;
        }
        return getCartItemCount(cart.getCartId());
    }
    
    /**
     * Map ResultSet to CartItem object
     */
    private CartItem mapResultSetToCartItem(ResultSet rs) throws SQLException {
        CartItem item = new CartItem();
        item.setCartItemId(rs.getInt("cart_item_id"));
        item.setCartId(rs.getInt("cart_id"));
        item.setProductCode(rs.getString("product_code"));
        item.setProviderId(rs.getInt("provider_id"));
        
        // Đọc product_name và provider_name, xử lý null
        String productName = rs.getString("product_name");
        String providerName = rs.getString("provider_name");
        item.setProductName(productName != null ? productName : "");
        item.setProviderName(providerName != null ? providerName : "");
        
        item.setUnitPrice(rs.getBigDecimal("unit_price"));
        item.setQuantity(rs.getInt("quantity"));
        item.setCreatedAt(rs.getTimestamp("created_at"));
        item.setUpdatedAt(rs.getTimestamp("updated_at"));
        
        return item;
    }
}

