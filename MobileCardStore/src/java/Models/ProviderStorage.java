package Models;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * ProviderStorage Model
 * Represents the provider_storage table - Sản phẩm từ nhà cung cấp
 */
public class ProviderStorage {
    private int providerStorageId;
    private int providerId;
    private String productCode;
    private String productName;
    private BigDecimal price;
    private BigDecimal purchasePrice;
    private int availableQuantity;
    private String imageUrl;
    private String status;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private boolean isDeleted;
    private Integer createdBy;
    private Integer deletedBy;
    
    // References
    private Provider provider;
    
    // Constructors
    public ProviderStorage() {
        this.status = "ACTIVE";
        this.isDeleted = false;
        this.availableQuantity = 0;
    }
    
    // Getters and Setters
    public int getProviderStorageId() {
        return providerStorageId;
    }
    
    public void setProviderStorageId(int providerStorageId) {
        this.providerStorageId = providerStorageId;
    }
    
    public int getProviderId() {
        return providerId;
    }
    
    public void setProviderId(int providerId) {
        this.providerId = providerId;
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
    
    public int getAvailableQuantity() {
        return availableQuantity;
    }
    
    public void setAvailableQuantity(int availableQuantity) {
        this.availableQuantity = availableQuantity;
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
    
    public Integer getCreatedBy() {
        return createdBy;
    }
    
    public void setCreatedBy(Integer createdBy) {
        this.createdBy = createdBy;
    }
    
    public Integer getDeletedBy() {
        return deletedBy;
    }
    
    public void setDeletedBy(Integer deletedBy) {
        this.deletedBy = deletedBy;
    }
    
    public Provider getProvider() {
        return provider;
    }
    
    public void setProvider(Provider provider) {
        this.provider = provider;
    }
    
    @Override
    public String toString() {
        return "ProviderStorage{" +
                "providerStorageId=" + providerStorageId +
                ", providerId=" + providerId +
                ", productCode='" + productCode + '\'' +
                ", productName='" + productName + '\'' +
                ", price=" + price +
                ", purchasePrice=" + purchasePrice +
                ", availableQuantity=" + availableQuantity +
                ", status='" + status + '\'' +
                '}';
    }
}

