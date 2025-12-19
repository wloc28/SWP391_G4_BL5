package Models;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * Provider Model
 * Represents the providers table
 */
public class Provider {
    private int providerId;
    private String providerName;
    private String providerType; // 'TEL' or 'GAME'
    private String productCode; // Mã sản phẩm fix cứng (VD: VT10K, VN20K)
    private String productName; // Tên sản phẩm (VD: Thẻ 10.000đ)
    private BigDecimal price; // Giá bán cho khách hàng
    private BigDecimal purchasePrice; // Giá nhập từ provider
    private int quantity; // Số lượng hàng còn ở provider
    private String imageUrl;
    private String status; // 'ACTIVE' or 'INACTIVE'
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private boolean isDeleted;
    
    // Constructors
    public Provider() {
        this.providerType = "TEL";
        this.status = "ACTIVE";
        this.isDeleted = false;
    }
    
    public Provider(String providerName, String providerType) {
        this();
        this.providerName = providerName;
        this.providerType = providerType;
    }
    
    // Getters and Setters
    public int getProviderId() {
        return providerId;
    }
    
    public void setProviderId(int providerId) {
        this.providerId = providerId;
    }
    
    public String getProviderName() {
        return providerName;
    }
    
    public void setProviderName(String providerName) {
        this.providerName = providerName;
    }
    
    public String getProviderType() {
        return providerType;
    }
    
    public void setProviderType(String providerType) {
        this.providerType = providerType;
    }
    
    public String getImageUrl() {
        return imageUrl;
    }
    
    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
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
    
    public String getProductCode() {
        return productCode;
    }
    
    public void setProductCode(String productCode) {
        this.productCode = productCode;
    }
    
    public String getProductName() {
        return productName;
    }
    
    public void setProductName(String productName) {
        this.productName = productName;
    }
    
    public BigDecimal getPrice() {
        return price;
    }
    
    public void setPrice(BigDecimal price) {
        this.price = price;
    }
    
    public BigDecimal getPurchasePrice() {
        return purchasePrice;
    }
    
    public void setPurchasePrice(BigDecimal purchasePrice) {
        this.purchasePrice = purchasePrice;
    }
    
    public int getQuantity() {
        return quantity;
    }
    
    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }
    
    @Override
    public String toString() {
        return "Provider{" +
                "providerId=" + providerId +
                ", providerName='" + providerName + '\'' +
                ", providerType='" + providerType + '\'' +
                ", productCode='" + productCode + '\'' +
                ", productName='" + productName + '\'' +
                ", price=" + price +
                ", purchasePrice=" + purchasePrice +
                ", quantity=" + quantity +
                ", status='" + status + '\'' +
                '}';
    }
}

