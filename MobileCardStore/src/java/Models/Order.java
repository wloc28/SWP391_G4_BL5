package Models;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * Order Model
 * Represents the orders table
 */
public class Order {
    private int orderId;
    private int userId;
    
    // Product information
    private int productCode;
    private String providerName;
    private String productName;
    private BigDecimal unitPrice;
    private int quantity;
    
    // Product log JSON (stored as String, can be parsed to JSON)
    private String productLog;
    
    // Voucher information
    private Integer voucherId;
    private String voucherCode;
    private BigDecimal discountAmount;
    
    // Total amount
    private BigDecimal totalAmount;
    private String status; // 'PENDING', 'PROCESSING', 'COMPLETED', 'FAILED'
    
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private boolean isDeleted;
    
    // References (optional, for convenience)
    private User user;
    private Product product;
    private Voucher voucher;
    
    // Constructors
    public Order() {
        this.discountAmount = BigDecimal.ZERO;
        this.status = "PENDING";
        this.isDeleted = false;
    }
    
    public Order(int userId, int productCode, int quantity, BigDecimal totalAmount) {
        this();
        this.userId = userId;
        this.productCode = productCode;
        this.quantity = quantity;
        this.totalAmount = totalAmount;
    }
    
    // Getters and Setters
    public int getOrderId() {
        return orderId;
    }
    
    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }
    
    public int getUserId() {
        return userId;
    }
    
    public void setUserId(int userId) {
        this.userId = userId;
    }
    
    public int getProductCode() {
        return productCode;
    }
    
    public void setProductCode(int productCode) {
        this.productCode = productCode;
    }
    
    public String getProviderName() {
        return providerName;
    }
    
    public void setProviderName(String providerName) {
        this.providerName = providerName;
    }
    
    public String getProductName() {
        return productName;
    }
    
    public void setProductName(String productName) {
        this.productName = productName;
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
    
    public String getProductLog() {
        return productLog;
    }
    
    public void setProductLog(String productLog) {
        this.productLog = productLog;
    }
    
    public Integer getVoucherId() {
        return voucherId;
    }
    
    public void setVoucherId(Integer voucherId) {
        this.voucherId = voucherId;
    }
    
    public String getVoucherCode() {
        return voucherCode;
    }
    
    public void setVoucherCode(String voucherCode) {
        this.voucherCode = voucherCode;
    }
    
    public BigDecimal getDiscountAmount() {
        return discountAmount;
    }
    
    public void setDiscountAmount(BigDecimal discountAmount) {
        this.discountAmount = discountAmount;
    }
    
    public BigDecimal getTotalAmount() {
        return totalAmount;
    }
    
    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
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
    
    public boolean isDeleted() {
        return isDeleted;
    }
    
    public void setDeleted(boolean deleted) {
        isDeleted = deleted;
    }
    
    public User getUser() {
        return user;
    }
    
    public void setUser(User user) {
        this.user = user;
    }
    
    public Product getProduct() {
        return product;
    }
    
    public void setProduct(Product product) {
        this.product = product;
    }
    
    public Voucher getVoucher() {
        return voucher;
    }
    
    public void setVoucher(Voucher voucher) {
        this.voucher = voucher;
    }
    
    @Override
    public String toString() {
        return "Order{" +
                "orderId=" + orderId +
                ", userId=" + userId +
                ", productCode=" + productCode +
                ", productName='" + productName + '\'' +
                ", quantity=" + quantity +
                ", totalAmount=" + totalAmount +
                ", status='" + status + '\'' +
                '}';
    }
}

