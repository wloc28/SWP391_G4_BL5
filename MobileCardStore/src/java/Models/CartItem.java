package Models;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * CartItem Model
 * Represents the cart_items table (sản phẩm trong giỏ hàng)
 */
public class CartItem {
    private int cartItemId;
    private int cartId;
    private String productCode;
    private int providerId;
    private String productName; // Snapshot
    private String providerName; // Snapshot
    private BigDecimal unitPrice; // Snapshot giá tại thời điểm thêm vào giỏ
    private int quantity;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // References
    private Cart cart;
    private ProductDisplay product; // Thông tin sản phẩm hiện tại (để so sánh giá)
    
    // Constructors
    public CartItem() {
        this.quantity = 1;
    }
    
    public CartItem(int cartId, String productCode, int providerId, int quantity, BigDecimal unitPrice) {
        this();
        this.cartId = cartId;
        this.productCode = productCode;
        this.providerId = providerId;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
    }
    
    // Getters and Setters
    public int getCartItemId() {
        return cartItemId;
    }
    
    public void setCartItemId(int cartItemId) {
        this.cartItemId = cartItemId;
    }
    
    public int getCartId() {
        return cartId;
    }
    
    public void setCartId(int cartId) {
        this.cartId = cartId;
    }
    
    public String getProductCode() {
        return productCode;
    }
    
    public void setProductCode(String productCode) {
        this.productCode = productCode;
    }
    
    public int getProviderId() {
        return providerId;
    }
    
    public void setProviderId(int providerId) {
        this.providerId = providerId;
    }
    
    public String getProductName() {
        return productName;
    }
    
    public void setProductName(String productName) {
        this.productName = productName;
    }
    
    public String getProviderName() {
        return providerName;
    }
    
    public void setProviderName(String providerName) {
        this.providerName = providerName;
    }
    
    public BigDecimal getUnitPrice() {
        return unitPrice;
    }
    
    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
    }
    
    public int getQuantity() {
        return quantity;
    }
    
    public void setQuantity(int quantity) {
        this.quantity = quantity;
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
    
    public Cart getCart() {
        return cart;
    }
    
    public void setCart(Cart cart) {
        this.cart = cart;
    }
    
    public ProductDisplay getProduct() {
        return product;
    }
    
    public void setProduct(ProductDisplay product) {
        this.product = product;
    }
    
    /**
     * Tính tổng giá của item này (unitPrice * quantity)
     */
    public BigDecimal getSubtotal() {
        if (unitPrice == null) {
            return BigDecimal.ZERO;
        }
        return unitPrice.multiply(new BigDecimal(quantity));
    }
}




