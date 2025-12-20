package Models;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

/**
 * ProductStorage Model
 * Represents the product_storage table (Kho hệ thống - Thay thế bảng products)
 */
public class ProductStorage {
    private int storageId;
    private Integer cardId; // Link về cards (thẻ từ nhà cung cấp)
    private Integer providerStorageId; // Link về provider_storage
    
    // Thông tin sản phẩm (copy từ provider_storage)
    private int providerId;
    private String providerName;
    private String productCode;
    private String productName;
    private BigDecimal price;
    private BigDecimal purchasePrice;
    
    // Thông tin thẻ
    private String serialNumber;
    private String cardCode;
    private Date expiryDate;
    
    // Trạng thái
    private String status; // 'AVAILABLE', 'SOLD', 'ERROR', 'EXPIRED'
    private Timestamp soldAt;
    private Integer soldToOrderId;
    private String errorMessage;
    
    // Audit
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private boolean isDeleted;
    private Integer createdBy;
    private Integer deletedBy;
    
    // Constructors
    public ProductStorage() {
        this.status = "AVAILABLE";
        this.isDeleted = false;
    }
    
    // Getters and Setters
    public int getStorageId() {
        return storageId;
    }
    
    public void setStorageId(int storageId) {
        this.storageId = storageId;
    }
    
    public Integer getCardId() {
        return cardId;
    }
    
    public void setCardId(Integer cardId) {
        this.cardId = cardId;
    }
    
    public Integer getProviderStorageId() {
        return providerStorageId;
    }
    
    public void setProviderStorageId(Integer providerStorageId) {
        this.providerStorageId = providerStorageId;
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
    
    public String getSerialNumber() {
        return serialNumber;
    }
    
    public void setSerialNumber(String serialNumber) {
        this.serialNumber = serialNumber;
    }
    
    public String getCardCode() {
        return cardCode;
    }
    
    public void setCardCode(String cardCode) {
        this.cardCode = cardCode;
    }
    
    public Date getExpiryDate() {
        return expiryDate;
    }
    
    public void setExpiryDate(Date expiryDate) {
        this.expiryDate = expiryDate;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public Timestamp getSoldAt() {
        return soldAt;
    }
    
    public void setSoldAt(Timestamp soldAt) {
        this.soldAt = soldAt;
    }
    
    public Integer getSoldToOrderId() {
        return soldToOrderId;
    }
    
    public void setSoldToOrderId(Integer soldToOrderId) {
        this.soldToOrderId = soldToOrderId;
    }
    
    public String getErrorMessage() {
        return errorMessage;
    }
    
    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
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
    
    @Override
    public String toString() {
        return "ProductStorage{" +
                "storageId=" + storageId +
                ", providerName='" + providerName + '\'' +
                ", productCode='" + productCode + '\'' +
                ", productName='" + productName + '\'' +
                ", serialNumber='" + serialNumber + '\'' +
                ", cardCode='" + cardCode + '\'' +
                ", status='" + status + '\'' +
                '}';
    }
}

