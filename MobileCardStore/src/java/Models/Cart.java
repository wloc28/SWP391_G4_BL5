package Models;

import java.sql.Timestamp;

/**
 * Cart Model
 * Represents the cart table (giỏ hàng của người dùng)
 */
public class Cart {
    private int cartId;
    private int userId;
    private Integer voucherId; // Voucher áp dụng cho toàn bộ giỏ hàng
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // References
    private User user;
    private Voucher voucher;
    
    // Constructors
    public Cart() {
    }
    
    public Cart(int userId) {
        this.userId = userId;
    }
    
    // Getters and Setters
    public int getCartId() {
        return cartId;
    }
    
    public void setCartId(int cartId) {
        this.cartId = cartId;
    }
    
    public int getUserId() {
        return userId;
    }
    
    public void setUserId(int userId) {
        this.userId = userId;
    }
    
    public Integer getVoucherId() {
        return voucherId;
    }
    
    public void setVoucherId(Integer voucherId) {
        this.voucherId = voucherId;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    public Timestamp getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    public User getUser() {
        return user;
    }
    
    public void setUser(User user) {
        this.user = user;
    }
    
    public Voucher getVoucher() {
        return voucher;
    }
    
    public void setVoucher(Voucher voucher) {
        this.voucher = voucher;
    }
}




