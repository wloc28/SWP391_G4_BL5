package Models;

import java.math.BigDecimal;

/**
 * ProductStorageGroup Model
 * Dùng để hiển thị thông tin nhóm theo product_code
 */
public class ProductStorageGroup {
    private String productCode;
    private String productName;
    private String providerName;
    private int providerId;
    private BigDecimal price;
    private BigDecimal purchasePrice;
    private int totalQuantity;      // Tổng số lượng
    private int availableQuantity;    // Số lượng AVAILABLE
    private int soldQuantity;         // Số lượng SOLD
    private int errorQuantity;        // Số lượng ERROR
    private int expiredQuantity;      // Số lượng EXPIRED
    private String productStatus;     // Trạng thái sản phẩm: ACTIVE/INACTIVE
    
    // Constructors
    public ProductStorageGroup() {
    }
    
    public ProductStorageGroup(String productCode, String productName, String providerName) {
        this.productCode = productCode;
        this.productName = productName;
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
    
    public String getProviderName() {
        return providerName;
    }
    
    public void setProviderName(String providerName) {
        this.providerName = providerName;
    }
    
    public int getProviderId() {
        return providerId;
    }
    
    public void setProviderId(int providerId) {
        this.providerId = providerId;
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
    
    public int getTotalQuantity() {
        return totalQuantity;
    }
    
    public void setTotalQuantity(int totalQuantity) {
        this.totalQuantity = totalQuantity;
    }
    
    public int getAvailableQuantity() {
        return availableQuantity;
    }
    
    public void setAvailableQuantity(int availableQuantity) {
        this.availableQuantity = availableQuantity;
    }
    
    public int getSoldQuantity() {
        return soldQuantity;
    }
    
    public void setSoldQuantity(int soldQuantity) {
        this.soldQuantity = soldQuantity;
    }
    
    public int getErrorQuantity() {
        return errorQuantity;
    }
    
    public void setErrorQuantity(int errorQuantity) {
        this.errorQuantity = errorQuantity;
    }
    
    public int getExpiredQuantity() {
        return expiredQuantity;
    }
    
    public void setExpiredQuantity(int expiredQuantity) {
        this.expiredQuantity = expiredQuantity;
    }
    
    public String getProductStatus() {
        return productStatus;
    }
    
    public void setProductStatus(String productStatus) {
        this.productStatus = productStatus;
    }
    
    @Override
    public String toString() {
        return "ProductStorageGroup{" +
                "productCode='" + productCode + '\'' +
                ", productName='" + productName + '\'' +
                ", providerName='" + providerName + '\'' +
                ", totalQuantity=" + totalQuantity +
                ", availableQuantity=" + availableQuantity +
                '}';
    }
}

