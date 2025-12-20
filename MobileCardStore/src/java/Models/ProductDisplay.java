package Models;

import java.math.BigDecimal;

/**
 * ProductDisplay Model
 * DTO cho hiển thị sản phẩm từ product_storage (thay thế Product model cũ)
 */
public class ProductDisplay {
    private String productCode;
    private String productName;
    private int providerId;
    private String providerName;
    private String providerType;
    private BigDecimal price;
    private BigDecimal purchasePrice;
    private String description;
    private String imageUrl;
    private int availableCount;
    private String status;
    
    // Constructors
    public ProductDisplay() {
    }
    
    public ProductDisplay(String productCode, String productName, int providerId, String providerName) {
        this.productCode = productCode;
        this.productName = productName;
        this.providerId = providerId;
        this.providerName = providerName;
    }
    
    // Getters and Setters
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
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public String getImageUrl() {
        return imageUrl;
    }
    
    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }
    
    public int getAvailableCount() {
        return availableCount;
    }
    
    public void setAvailableCount(int availableCount) {
        this.availableCount = availableCount;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    /**
     * Get image URL based on provider name
     */
    public String getProviderImageUrl() {
        if (providerName == null) {
            return null;
        }
        
        String name = providerName.trim().toLowerCase();
        if (name.contains("viettel")) {
            return "https://cdn.tgdd.vn/Files/2021/01/07/1318645/logo-1_600x600.jpg";
        } else if (name.contains("vinaphone") || name.contains("vnpt")) {
            return "https://banhangvnpt.vn/Uploads/images/2022/logo%20vinaphone.jpg";
        } else if (name.contains("mobifone")) {
            return "https://ppclink.com/wp-content/uploads/2021/12/icon_WebMobiFone.png";
        }
        
        return null;
    }
    
    /**
     * Check if product is in stock
     */
    public boolean isInStock() {
        return availableCount > 0;
    }
    
    @Override
    public String toString() {
        return "ProductDisplay{" +
                "productCode='" + productCode + '\'' +
                ", productName='" + productName + '\'' +
                ", providerName='" + providerName + '\'' +
                ", price=" + price +
                ", availableCount=" + availableCount +
                '}';
    }
}


